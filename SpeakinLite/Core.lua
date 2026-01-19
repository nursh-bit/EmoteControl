-- EmoteControl - Core Engine
-- Lightweight, modular announcer addon with phrase packs

local ADDON_NAME = ...

-- Initialize the EmoteControl namespace with backward compatibility
EmoteControl = EmoteControl or {}
SpeakinLite = EmoteControl  -- Backward compatibility alias
local addon = EmoteControl

-- Metadata
addon.ADDON_NAME = ADDON_NAME
addon.VERSION = "0.9.5"
addon.DB_VERSION = 2

-- Create event frame for listener registration
local frame = CreateFrame("Frame")

-- SavedVariables (initialized on PLAYER_LOGIN)
local db
addon.db = nil

-- Runtime rate limiting cache
addon._sentTimes = addon._sentTimes or {}

local function SetDefault(tbl, key, value)
  if type(tbl) ~= "table" then return end
  if tbl[key] == nil then
    tbl[key] = value
  end
end

-- Apply recommended default settings for a fresh database
function addon:ApplyRecommendedDefaults(db)
  if type(db) ~= "table" then return end
  
  -- Use a defaults table for maintainability
  local defaults = {
    enabled = true,
    channel = "EMOTE",
    fallbackToSelf = true,
    globalCooldown = 6,
    rotationProtection = "MEDIUM",
    maxPerMinute = 8,
    repairThreshold = 0.2,
    enableSpellTriggers = true,
    enableNonSpellTriggers = true,
    onlyLearnedSpells = true,
    enableCombatLogTriggers = false,
    enableLootTriggers = true,
    enableAchievementTriggers = true,
    enableLevelUpTriggers = true,
  }
  
  for key, value in pairs(defaults) do
    db[key] = value
  end
end

function addon:ApplyMigrations(db)
  if type(db) ~= "table" then return end
  local v = tonumber(db.version) or 0

  if v < 1 then
    v = 1
  end

  if v < 2 then
    SetDefault(db, "enableCombatLogTriggers", true)
    SetDefault(db, "enableLootTriggers", true)
    SetDefault(db, "enableAchievementTriggers", true)
    SetDefault(db, "enableLevelUpTriggers", true)
    SetDefault(db, "repairThreshold", 0.2)
    v = 2
  end

  db.version = v
end

function addon:ShowOnboarding()
  addon:Print("Welcome! Use /sl options for quick setup and pack selection.")
  addon:Print("Tip: Try SELF channel with 6s cooldown and 8/min for low spam.")

  if type(addon.OpenOptions) == "function" then
    local inCombat = (type(InCombatLockdown) == "function") and InCombatLockdown()
    if not inCombat then
      pcall(addon.OpenOptions, addon)
    end
  end
end

local SendChat = (C_ChatInfo and type(C_ChatInfo.SendChatMessage) == "function" and C_ChatInfo.SendChatMessage) or SendChatMessage
local CanChatSend = (C_ChatInfo and type(C_ChatInfo.CanChatMessageBeSent) == "function" and C_ChatInfo.CanChatMessageBeSent) or nil

local function IsOutdoorRestrictedChat(chatType)
  -- EMOTE works everywhere, so only SAY/YELL/CHANNEL are restricted outdoors
  return chatType == "SAY" or chatType == "YELL" or chatType == "CHANNEL"
end

local function GetRotationFloorSeconds()
  if not db then return 0 end
  local mode = db.rotationProtection
  if type(mode) ~= "string" then return 0 end
  mode = string.upper(mode)
  return addon.ROTATION_PROTECTION[mode] or 0
end

-- Remove sent times older than 60 seconds using more efficient shifting
local function PruneSentTimes(now)
  local t = addon._sentTimes
  if type(t) ~= "table" then return end
  
  -- Find the first non-expired entry index
  local writeIdx = 1
  for readIdx = 1, #t do
    if (now - t[readIdx]) <= 60 then
      if writeIdx ~= readIdx then
        t[writeIdx] = t[readIdx]
      end
      writeIdx = writeIdx + 1
    end
  end
  
  -- Clear remaining entries
  for i = writeIdx, #t do
    t[i] = nil
  end
end

local function GlobalRateOk()
  if not db then return false end
  local maxPerMin = tonumber(db.maxPerMinute)
  if not maxPerMin or maxPerMin <= 0 then return true end

  local now = GetTime()
  PruneSentTimes(now)
  return #addon._sentTimes < maxPerMin
end

local function NoteGlobalSend()
  local now = GetTime()
  PruneSentTimes(now)
  table.insert(addon._sentTimes, now)
end

-- Apply template substitutions (tokens and random selection) to a message
function addon:ApplySubs(template, ctx)
  if type(template) ~= "string" then return "" end
  ctx = ctx or {}

  local out = template

  -- <pick:a|b|c> - random selection from pipe-separated options
  out = out:gsub("<pick:([^>]+)>", function(body)
    local opts = {}
    for part in string.gmatch(body, "[^|]+") do
      part = (part:gsub("^%s+", ""):gsub("%s+$", ""))
      if part ~= "" then table.insert(opts, part) end
    end
    return addon:RandomFrom(opts) or ""
  end)

  -- <rng:1-100> - random number in range
  out = out:gsub("<rng:(%d+)%-(%d+)>", function(a, b)
    local lo = tonumber(a) or 0
    local hi = tonumber(b) or lo
    if hi < lo then lo, hi = hi, lo end
    return tostring(math.random(lo, hi))
  end)

  -- Token substitution map for efficient and maintainable replacement
  local tokens = {
    -- Player info tokens
    player = ctx.player or "",
    spell = ctx.spell or "",
    target = ctx.target or "",
    zone = ctx.zone or "",
    spec = ctx.spec or "",
    class = ctx.class or "",
    instance = ctx.instanceType or "",
    race = ctx.race or "",
    guild = ctx.guild or "",
    level = ctx.level or "1",
    -- Health and power tokens
    ["health%%"] = ctx.healthPct or "0",
    health = ctx.health or "0",
    healthmax = ctx.healthMax or "0",
    ["power%%"] = ctx.powerPct or "0",
    power = ctx.power or "0",
    powermax = ctx.powerMax or "0",
    powername = ctx.powerName or "Power",
    combo = ctx.combo or "0",
    ["target-health%%"] = ctx.targetHealthPct or "0",
    -- Loot and achievement tokens
    achievement = ctx.achievement or "",
    item = ctx.item or "",
    itemlink = ctx.itemLink or "",
    quality = ctx.quality or "",
  }
  
  -- Apply all token substitutions at once
  for token, value in pairs(tokens) do
    out = out:gsub("<" .. token .. ">", value)
  end

  return out
end

-- Output a message to the specified or default channel with fallback handling
function addon:Output(msg, channelOverride)
  if not msg or msg == "" then return end

  local channel = channelOverride or (db and db.channel) or "SELF"
  channel = string.upper(channel)

  -- Self output is always safe and doesn't require group checks
  if channel == "SELF" then
    addon:Print(msg)
    NoteGlobalSend()
    return
  end

  -- Validate and handle group channels with intelligent fallback
  local inInstance = IsInInstance()
  
  -- Fallback from restricted channels
  if not inInstance and IsOutdoorRestrictedChat(channel) and (not db or db.fallbackToSelf ~= false) then
    channel = "EMOTE"
  elseif channel == "PARTY" then
    if not IsInGroup(LE_PARTY_CATEGORY_HOME) then
      addon:Print(msg)
      NoteGlobalSend()
      return
    end
  elseif channel == "RAID" then
    if not IsInRaid() then
      addon:Print(msg)
      NoteGlobalSend()
      return
    end
  elseif channel == "INSTANCE" then
    if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
      if IsInGroup(LE_PARTY_CATEGORY_HOME) then
        channel = "PARTY"
      else
        addon:Print(msg)
        NoteGlobalSend()
        return
      end
    else
      channel = "INSTANCE_CHAT"
    end
  end

  -- Final safety check before sending
  if CanChatSend then
    local ok, canSend = pcall(CanChatSend, channel, msg)
    if ok and canSend == false then
      addon:Print(msg)
      NoteGlobalSend()
      return
    end
  end

  -- Attempt to send the message with fallback
  local ok = pcall(SendChat, msg, channel)
  if not ok then
    addon:Print(msg)
  end
  NoteGlobalSend()
end

function addon:IsSpellKnownByPlayer(spellID)
  if type(spellID) ~= "number" then return false end

  if type(IsSpellKnown) == "function" then
    local ok, known = pcall(IsSpellKnown, spellID)
    if ok and known then return true end
  end

  if type(IsPlayerSpell) == "function" then
    local ok, known = pcall(IsPlayerSpell, spellID)
    if ok and known then return true end
  end

  return false
end

function addon:GetTriggerOverride(triggerId)
  if not db or type(db.triggerOverrides) ~= "table" then return nil end
  return db.triggerOverrides[triggerId]
end

function addon:ShouldTriggerBeActive(trig)
  if not db or db.enabled == false then return false end
  if not GlobalRateOk() then return false end

  local ov = addon:GetTriggerOverride(trig.id)
  if ov and ov.enabled == false then return false end

  -- Category toggle
  local cat = trig.category or "general"
  if type(db.categoriesEnabled) == "table" then
    local v = db.categoriesEnabled[cat]
    if v == false then return false end
  end

  return true
end

function addon:TriggerCooldownOk(trig)
  if not addon:ShouldTriggerBeActive(trig) then return false end

  local ov = addon:GetTriggerOverride(trig.id)

  local now = GetTime()
  local cd = (ov and tonumber(ov.cooldown)) or tonumber(trig.cooldown)
  if type(cd) ~= "number" then
    cd = tonumber(db.globalCooldown)
  end
  cd = addon:ClampNumber(cd or 0, 0, 600)

  -- Rotation protection applies a floor to spell triggers
  if trig.event == "UNIT_SPELLCAST_SUCCEEDED" then
    local floor = GetRotationFloorSeconds()
    if floor and floor > 0 and cd < floor then
      cd = floor
    end
  end

  if cd <= 0 then
    return true
  end

  if trig.lastFired and (now - trig.lastFired) < cd then
    return false
  end

  return true
end

function addon:GetTriggerMessages(trig)
  local ov = addon:GetTriggerOverride(trig.id)
  if ov and type(ov.messages) == "table" and #ov.messages > 0 then
    return ov.messages
  end
  
  -- Check for mood-specific messages
  local mood = db and db.moodProfile or "default"
  if trig.messagesByMood and type(trig.messagesByMood) == "table" then
    if mood ~= "default" and trig.messagesByMood[mood] then
      return trig.messagesByMood[mood]
    end
    -- Fall back to default mood if available
    if trig.messagesByMood.default then
      return trig.messagesByMood.default
    end
  end
  
  return trig.messages
end

function addon:GetTriggerChannel(trig)
  local ov = addon:GetTriggerOverride(trig.id)
  if ov and type(ov.channel) == "string" and ov.channel ~= "" then
    return string.upper(ov.channel)
  end
  if type(trig.channel) == "string" and trig.channel ~= "" then
    return string.upper(trig.channel)
  end
  return nil
end

-- ========================================
-- Usage Statistics
-- ========================================

function addon:RecordTriggerStat(trig, message)
  if not db or not trig or not trig.id then return end
  
  -- Initialize stats table if needed
  db.stats = db.stats or {}
  db.stats.triggers = db.stats.triggers or {}
  db.stats.session = db.stats.session or {}
  
  local trigID = trig.id
  local now = time()
  
  -- Lifetime stats
  db.stats.triggers[trigID] = db.stats.triggers[trigID] or {
    count = 0,
    lastFired = 0,
    firstFired = 0,
    category = trig.category or "unknown",
    packName = trig.packName or "unknown"
  }
  
  local stat = db.stats.triggers[trigID]
  stat.count = stat.count + 1
  stat.lastFired = now
  
  if stat.firstFired == 0 then
    stat.firstFired = now
  end
  
  -- Session stats (resets on login)
  db.stats.session[trigID] = (db.stats.session[trigID] or 0) + 1
  
  -- Total messages sent (global counter)
  db.stats.totalMessages = (db.stats.totalMessages or 0) + 1
  db.stats.sessionMessages = (db.stats.sessionMessages or 0) + 1
end

function addon:GetStats()
  if not db or not db.stats then return nil end
  return db.stats
end

function addon:ResetStats()
  if not db then return end
  db.stats = {
    triggers = {},
    session = {},
    totalMessages = 0,
    sessionMessages = 0
  }
  addon:Print("Usage statistics have been reset.")
end

function addon:ShowStats()
  local stats = addon:GetStats()
  if not stats or not stats.triggers then
    addon:Print("No statistics available yet.")
    return
  end
  
  addon:Print("=== Emote Control - Usage Statistics ===")
  addon:Print(string.format("Total Messages Sent: %d (Session: %d)", 
    stats.totalMessages or 0, 
    stats.sessionMessages or 0))
  
  -- Build sorted list of triggers by usage
  local sorted = {}
  for trigID, data in pairs(stats.triggers) do
    table.insert(sorted, {
      id = trigID,
      count = data.count,
      category = data.category,
      sessionCount = stats.session[trigID] or 0
    })
  end
  
  table.sort(sorted, function(a, b) return a.count > b.count end)
  
  addon:Print("\nTop 10 Most Used Triggers:")
  for i = 1, math.min(10, #sorted) do
    local t = sorted[i]
    addon:Print(string.format("  %d. %s [%s] - %d times (session: %d)", 
      i, t.id, t.category, t.count, t.sessionCount))
  end
  
  -- Category breakdown
  local categories = {}
  for _, data in pairs(stats.triggers) do
    local cat = data.category or "unknown"
    categories[cat] = (categories[cat] or 0) + data.count
  end
  
  addon:Print("\nBy Category:")
  local catSorted = {}
  for cat, count in pairs(categories) do
    table.insert(catSorted, {cat = cat, count = count})
  end
  table.sort(catSorted, function(a, b) return a.count > b.count end)
  
  for _, data in ipairs(catSorted) do
    addon:Print(string.format("  %s: %d", data.cat, data.count))
  end
end

-- Loot processing (handles async item info in Retail)
local function GetItemQuality(itemLink)
  if C_Item and type(C_Item.GetItemInfo) == "function" then
    local info = C_Item.GetItemInfo(itemLink)
    if type(info) == "table" and type(info.quality) == "number" then
      return info.quality
    end
  end
  if type(GetItemInfo) == "function" then
    local _, _, quality = GetItemInfo(itemLink)
    if type(quality) == "number" then return quality end
  end
  return nil
end

local function QualityName(quality)
  if quality == 5 then return "Legendary" end
  if quality == 4 then return "Epic" end
  if quality == 3 then return "Rare" end
  if quality == 2 then return "Uncommon" end
  return ""
end

function addon:ProcessLootMessage(message, eventName, attempts)
  if type(message) ~= "string" then return end
  local fullLink = message:match("|c.-|H.-|h.-|h|r")
  if not fullLink then return end

  local quality = GetItemQuality(fullLink)
  if not quality then
    local itemID = tonumber(fullLink:match("item:(%d+)"))
    if itemID and (attempts or 0) < 2 then
      addon._pendingLoot = addon._pendingLoot or {}
      addon._pendingLoot[itemID] = addon._pendingLoot[itemID] or {}
      table.insert(addon._pendingLoot[itemID], {
        message = message,
        eventName = eventName,
        attempts = (attempts or 0) + 1
      })
      if C_Item and type(C_Item.RequestLoadItemData) == "function" then
        pcall(C_Item.RequestLoadItemData, itemID)
      end
    end
    return
  end

  local extraData = {
    item = fullLink,
    itemLink = fullLink,
    quality = QualityName(quality),
    qualityNum = tostring(quality or 0),
  }

  local args = { quality = quality }
  local ctx = addon:MakeContext(nil, extraData)
  local bucket = addon.TriggersByEvent and addon.TriggersByEvent[eventName]
  if not bucket then return end

  for _, trig in ipairs(bucket.list or {}) do
    if addon:TriggerCooldownOk(trig) and addon:MatchesTrigger(trig, eventName, args) then
      addon:FireTrigger(trig, ctx)
    end
  end
end

function addon:MakeContext(spellID, extraData)
  local _, instType = addon:GetInstanceType()
  local _, specName = addon:GetSpecInfo()
  
  -- Health and Power
  local health = UnitHealth("player") or 0
  local healthMax = UnitHealthMax("player") or 1
  local healthPct = math.floor((health / healthMax) * 100)
  
  local power = UnitPower("player") or 0
  local powerMax = UnitPowerMax("player") or 1
  local powerPct = math.floor((power / powerMax) * 100)
  
  local powerType = UnitPowerType("player")
  local powerName = powerType == 0 and "Mana" or 
                    powerType == 1 and "Rage" or 
                    powerType == 2 and "Focus" or 
                    powerType == 3 and "Energy" or 
                    powerType == 6 and "Runic Power" or "Power"
  
  -- Combo points (for rogues, druids, etc)
  local combo = 0
  if type(UnitPower) == "function" then
    combo = UnitPower("player", 4) or 0 -- POWER_TYPE_COMBO_POINTS = 4
  end
  
  -- Target health
  local targetHealthPct = 0
  if UnitExists("target") then
    local tHealth = UnitHealth("target") or 0
    local tHealthMax = UnitHealthMax("target") or 1
    targetHealthPct = math.floor((tHealth / tHealthMax) * 100)
  end
  
  -- Guild
  local guildName = GetGuildInfo("player") or ""
  
  -- Level
  local level = UnitLevel("player") or 1
  
  -- Race
  local raceName = UnitRace("player") or ""
  
  local ctx = {
    player = UnitName("player") or "",
    target = UnitName("target") or "nobody",
    zone = addon:GetZone(),
    class = addon:GetPlayerClass(),
    spec = specName,
    instanceType = instType or "",
    spell = spellID and (addon:GetSpellName(spellID) or tostring(spellID)) or "",
    health = tostring(health),
    healthMax = tostring(healthMax),
    healthPct = tostring(healthPct),
    power = tostring(power),
    powerMax = tostring(powerMax),
    powerPct = tostring(powerPct),
    powerName = powerName,
    combo = tostring(combo),
    targetHealthPct = tostring(targetHealthPct),
    guild = guildName,
    level = tostring(level),
    race = raceName,
  }
  
  -- Merge any extra contextual data (for achievements, loot, etc)
  if type(extraData) == "table" then
    for k, v in pairs(extraData) do
      ctx[k] = v
    end
  end
  
  return ctx
end

function addon:FireTrigger(trig, ctx)
  local messages = addon:GetTriggerMessages(trig)
  if type(messages) ~= "table" then return end

  -- Check for conditional message variants
  local messageList = messages
  if messages.solo or messages.party or messages.raid or messages.instance then
    -- Conditional messages based on group state
    local inRaid = IsInRaid()
    local inParty = IsInGroup()
    local inInstance = IsInInstance()
    
    if inRaid and messages.raid then
      messageList = messages.raid
    elseif inParty and messages.party then
      messageList = messages.party
    elseif inInstance and messages.instance then
      messageList = messages.instance
    elseif messages.solo then
      messageList = messages.solo
    else
      -- Fallback to any available list
      messageList = messages.raid or messages.party or messages.instance or messages.solo or messages
    end
  end

  local template = addon:RandomFrom(messageList)
  if not template then return end

  local msg = addon:ApplySubs(template, ctx)
  if msg == "" then return end

  trig.lastFired = GetTime()
  addon:Output(msg, addon:GetTriggerChannel(trig))
  
  -- Track usage statistics
  addon:RecordTriggerStat(trig, msg)
end

local function StringOrTableMatch(value, condValue)
  if condValue == nil then return true end
  if type(condValue) == "string" then
    return value == condValue
  end
  if type(condValue) == "table" then
    for _, v in ipairs(condValue) do
      if value == v then return true end
    end
    return false
  end
  return true
end

function addon:MatchesTrigger(trig, eventName, args)
  local cond = trig.conditions or {}
  args = args or {}

  -- Class gating
  if type(cond.class) == "string" then
    if addon:GetPlayerClass() ~= cond.class then
      return false
    end
  end

  -- Race gating (file is uppercase like "HUMAN", "UNDEAD")
  if cond.race ~= nil then
    local want = cond.race
    if type(want) == "string" then
      want = string.upper(want)
    elseif type(want) == "table" then
      local t = {}
      for _, v in ipairs(want) do
        if type(v) == "string" then table.insert(t, string.upper(v)) end
      end
      want = t
    end
    if not StringOrTableMatch(addon:GetPlayerRaceFile(), want) then
      return false
    end
  end

  -- Spec gating (by specID)
  if cond.specID ~= nil then
    local specID = select(1, addon:GetSpecInfo())
    if type(cond.specID) == "number" then
      if specID ~= cond.specID then return false end
    elseif type(cond.specID) == "table" then
      local ok = false
      for _, v in ipairs(cond.specID) do
        if specID == v then ok = true break end
      end
      if not ok then return false end
    end
  end

  -- Instance gating
  if type(cond.inInstance) == "boolean" then
    local inInstance = IsInInstance()
    if inInstance ~= cond.inInstance then
      return false
    end
  end

  -- Instance type gating ("none", "party", "raid", "pvp", "arena", "scenario")
  if cond.instanceType ~= nil then
    local _, instType = addon:GetInstanceType()
    if not StringOrTableMatch(instType, cond.instanceType) then
      return false
    end
  end

  -- Unit gating (for spellcast events)
  if type(cond.unit) == "string" and type(args.unit) == "string" then
    if args.unit ~= cond.unit then
      return false
    end
  end

  -- Target gating
  if cond.requiresTarget == true then
    if not UnitExists("target") then return false end
  end
  if type(cond.targetType) == "string" then
    if not UnitExists("target") then return false end
    local tt = string.lower(cond.targetType)
    if tt == "enemy" and UnitIsFriend("player", "target") then return false end
    if tt == "friendly" and not UnitIsFriend("player", "target") then return false end
  end

  -- Spell gating
  if args.spellID then
    if trig._spellID and trig._spellID ~= args.spellID then
      return false
    end

    if not trig._spellID then
      local spellName = addon:GetSpellName(args.spellID)
      local spellNameLower = addon:SafeLower(spellName)
      if trig._spellNameLower then
        local want = trig._spellNameLower
        if type(want) == "string" and want:sub(-1) == "*" then
          local prefix = want:sub(1, -2)
          if not (spellNameLower and spellNameLower:sub(1, #prefix) == prefix) then
            return false
          end
        else
          if spellNameLower ~= want then
            return false
          end
        end
      elseif trig._spellNameLowerList then
        local ok = false
        for _, want in ipairs(trig._spellNameLowerList) do
          if type(want) == "string" and want:sub(-1) == "*" then
            local prefix = want:sub(1, -2)
            if spellNameLower and spellNameLower:sub(1, #prefix) == prefix then
              ok = true
              break
            end
          elseif spellNameLower == want then
            ok = true
            break
          end
        end
        if not ok then
          return false
        end
      end
    end
  end
  
  -- Extended conditions
  
  -- Loot quality gating (e.g., epic/legendary)
  if cond.quality ~= nil and args.quality ~= nil then
    if type(cond.quality) == "number" then
      if args.quality ~= cond.quality then return false end
    elseif type(cond.quality) == "string" then
      local want = tonumber(cond.quality)
      if want and args.quality ~= want then return false end
    elseif type(cond.quality) == "table" then
      local ok = false
      for _, v in ipairs(cond.quality) do
        local want = tonumber(v) or v
        if want == args.quality then ok = true break end
      end
      if not ok then return false end
    end
  end
  
  -- Random chance (0.0 to 1.0, where 0.5 = 50%)
  if type(cond.randomChance) == "number" then
    if math.random() > cond.randomChance then
      return false
    end
  end
  
  -- In combat check
  if type(cond.inCombat) == "boolean" then
    local inCombat = UnitAffectingCombat("player")
    if inCombat ~= cond.inCombat then
      return false
    end
  end
  
  -- In group check
  if type(cond.inGroup) == "boolean" then
    local inGroup = IsInGroup() or IsInRaid()
    if inGroup ~= cond.inGroup then
      return false
    end
  end
  
  -- Group size check
  if type(cond.groupSize) == "table" then
    local size = GetNumGroupMembers() or 0
    if IsInRaid() then
      size = GetNumGroupMembers()
    elseif IsInGroup() then
      size = GetNumGroupMembers()
    else
      size = 1
    end
    
    if cond.groupSize.min and size < cond.groupSize.min then
      return false
    end
    if cond.groupSize.max and size > cond.groupSize.max then
      return false
    end
  end
  
  -- Has aura/buff check
  if type(cond.hasAura) == "string" or type(cond.hasAura) == "number" then
    local foundAura = false
    if type(AuraUtil) == "table" and type(AuraUtil.FindAuraByName) == "function" then
      -- Retail API
      foundAura = AuraUtil.FindAuraByName(cond.hasAura, "player") ~= nil
    elseif type(UnitBuff) == "function" then
      -- Classic API - scan buffs
      for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        if not name then break end
        if name == cond.hasAura or spellId == cond.hasAura then
          foundAura = true
          break
        end
      end
    end
    if not foundAura then
      return false
    end
  end
  
  -- Target is boss check
  if cond.targetIsBoss == true then
    if not UnitExists("target") then return false end
    local classification = UnitClassification("target")
    if classification ~= "worldboss" and classification ~= "rareelite" and classification ~= "elite" then
      -- Also check if it's a dungeon/raid boss
      if not (UnitLevel("target") == -1 or (IsInInstance() and UnitIsEnemy("player", "target"))) then
        return false
      end
    end
  end
  
  -- Health percentage threshold
  if type(cond.healthBelow) == "number" or type(cond.healthAbove) == "number" then
    local healthMax = UnitHealthMax("player") or 0
    local healthPct = 0
    if healthMax > 0 then
      healthPct = (UnitHealth("player") / healthMax) * 100
    end
    if type(cond.healthBelow) == "number" and healthPct >= cond.healthBelow then
      return false
    end
    if type(cond.healthAbove) == "number" and healthPct <= cond.healthAbove then
      return false
    end
  end

  return true
end

function addon:LoadPacksForPlayer()
  -- Option B loader:
  -- Load every enabled addon whose folder name starts with "SpeakinLite_Pack_"
  -- or "EmoteControl_Pack_",
  -- but only when its custom metadata matches the player.
  --
  -- Packs should set one (or more) of these in their .toc:
  --   ## X-EmoteControl-PackType: Common | Race | Professions | Activities
  --   ## X-EmoteControl-Class: MAGE
  --   ## X-EmoteControl-Race: VOIDELF
  -- (Legacy keys with X-SpeakinLite-* are also supported.)

  local function Load(name)
    if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
      pcall(C_AddOns.LoadAddOn, name)
      return
    end
    if type(LoadAddOn) == "function" then
      pcall(LoadAddOn, name)
    end
  end

  local function GetNum()
    if C_AddOns and type(C_AddOns.GetNumAddOns) == "function" then
      return C_AddOns.GetNumAddOns()
    end
    if type(GetNumAddOns) == "function" then
      return GetNumAddOns()
    end
    return 0
  end

  local function GetInfo(i)
    if C_AddOns and type(C_AddOns.GetAddOnInfo) == "function" then
      return C_AddOns.GetAddOnInfo(i)
    end
    if type(GetAddOnInfo) == "function" then
      return GetAddOnInfo(i)
    end
    return nil
  end

  local function GetMeta(addonName, field)
    if C_AddOns and type(C_AddOns.GetAddOnMetadata) == "function" then
      return C_AddOns.GetAddOnMetadata(addonName, field)
    end
    if type(GetAddOnMetadata) == "function" then
      return GetAddOnMetadata(addonName, field)
    end
    return nil
  end

  local playerClass = addon:SafeLower(addon:GetPlayerClass()) or ""
  local playerRace = addon:SafeLower(addon:GetPlayerRaceFile()) or ""

  local prefixes = {"SpeakinLite_Pack_", "EmoteControl_Pack_"}
  local function HasPackPrefix(name)
    for _, prefix in ipairs(prefixes) do
      if string.sub(name, 1, #prefix) == prefix then
        return true
      end
    end
    return false
  end
  local n = GetNum()
  for i = 1, n do
    local name = GetInfo(i)
    if type(name) == "string" and HasPackPrefix(name) then
      local packType = addon:SafeLower(
        GetMeta(name, "X-EmoteControl-PackType") or GetMeta(name, "X-SpeakinLite-PackType")
      )
      local classTag = addon:SafeLower(
        GetMeta(name, "X-EmoteControl-Class") or GetMeta(name, "X-SpeakinLite-Class")
      )
      local raceTag = addon:SafeLower(
        GetMeta(name, "X-EmoteControl-Race") or GetMeta(name, "X-SpeakinLite-Race")
      )

      -- Determine if we should load this pack
      local shouldLoad = false
      
      -- Always load if no tags (legacy), common, professions, or activities
      if (not packType and not classTag and not raceTag) or 
         packType == "common" or 
         packType == "professions" or
         packType == "activities" then
        shouldLoad = true
      end
      
      -- Load if class matches
      if classTag and classTag == playerClass then
        shouldLoad = true
      end
      
      -- Load if race pack AND race matches
      if packType == "race" and raceTag and raceTag == playerRace then
        shouldLoad = true
      end
      
      if shouldLoad then
        Load(name)
      end
    end
  end
end

local function NormalizePackIdFromAddonName(name)
  if type(name) ~= "string" then return nil end
  local prefixes = {"SpeakinLite_Pack_", "EmoteControl_Pack_"}
  for _, prefix in ipairs(prefixes) do
    if string.sub(name, 1, #prefix) == prefix then
      name = string.sub(name, #prefix + 1)
      break
    end
  end
  name = addon:SafeLower(name) or name
  name = name:gsub("%s+", ""):gsub("[^%w_]", "")
  if name == "" then return nil end
  return name
end

function addon:GetAvailablePackAddOns()
  local packs = {}

  local function GetNum()
    if C_AddOns and type(C_AddOns.GetNumAddOns) == "function" then
      return C_AddOns.GetNumAddOns()
    end
    if type(GetNumAddOns) == "function" then
      return GetNumAddOns()
    end
    return 0
  end

  local function GetInfo(i)
    if C_AddOns and type(C_AddOns.GetAddOnInfo) == "function" then
      return C_AddOns.GetAddOnInfo(i)
    end
    if type(GetAddOnInfo) == "function" then
      return GetAddOnInfo(i)
    end
    return nil
  end

  local function GetMeta(addonName, field)
    if C_AddOns and type(C_AddOns.GetAddOnMetadata) == "function" then
      return C_AddOns.GetAddOnMetadata(addonName, field)
    end
    if type(GetAddOnMetadata) == "function" then
      return GetAddOnMetadata(addonName, field)
    end
    return nil
  end

  local function IsLoaded(addonName)
    if C_AddOns and type(C_AddOns.IsAddOnLoaded) == "function" then
      return C_AddOns.IsAddOnLoaded(addonName)
    end
    if type(IsAddOnLoaded) == "function" then
      return IsAddOnLoaded(addonName)
    end
    return false
  end

  local function HasPackPrefix(name)
    if type(name) ~= "string" then return false end
    local prefixes = {"SpeakinLite_Pack_", "EmoteControl_Pack_"}
    for _, prefix in ipairs(prefixes) do
      if string.sub(name, 1, #prefix) == prefix then
        return true
      end
    end
    return false
  end

  local n = GetNum()
  for i = 1, n do
    local name, title, notes, loadable, reason, security = GetInfo(i)
    if type(name) == "string" and HasPackPrefix(name) then
      local packType = addon:SafeLower(
        GetMeta(name, "X-EmoteControl-PackType") or GetMeta(name, "X-SpeakinLite-PackType")
      )
      local classTag = addon:SafeLower(
        GetMeta(name, "X-EmoteControl-Class") or GetMeta(name, "X-SpeakinLite-Class")
      )
      local raceTag = addon:SafeLower(
        GetMeta(name, "X-EmoteControl-Race") or GetMeta(name, "X-SpeakinLite-Race")
      )
      local packId = addon:SafeLower(
        GetMeta(name, "X-EmoteControl-PackId") or GetMeta(name, "X-SpeakinLite-PackId")
      )

      if not packId or packId == "" then
        if packType == "race" and raceTag then
          packId = "race_" .. raceTag
        elseif classTag then
          packId = classTag
        else
          packId = NormalizePackIdFromAddonName(name)
        end
      end

      if packId then
        packs[packId] = {
          id = packId,
          addonName = name,
          title = title or name,
          loadable = loadable,
          loaded = IsLoaded(name),
          packType = packType,
          classTag = classTag,
          raceTag = raceTag,
          reason = reason,
          security = security,
        }
      end
    end
  end

  return packs
end

function addon:GetPackDescriptors()
  local descriptors = {}
  local available = addon:GetAvailablePackAddOns()

  for id, pack in pairs(addon.Packs or {}) do
    local info = available[id]
      descriptors[id] = {
      id = id,
      name = pack.name or (info and info.title) or id,
      addonName = info and info.addonName,
      loaded = true,
      loadable = info and info.loadable,
      available = true,
        reason = info and info.reason,
        security = info and info.security,
    }
  end

  for id, info in pairs(available) do
    if not descriptors[id] then
      descriptors[id] = {
        id = id,
        name = info.title or info.addonName or id,
        addonName = info.addonName,
        loaded = info.loaded,
        loadable = info.loadable,
        available = true,
        reason = info.reason,
        security = info.security,
      }
    else
      descriptors[id].loaded = info.loaded or descriptors[id].loaded
      descriptors[id].loadable = info.loadable
      descriptors[id].addonName = descriptors[id].addonName or info.addonName
      descriptors[id].reason = descriptors[id].reason or info.reason
      descriptors[id].security = descriptors[id].security or info.security
    end
  end

  local list = {}
  for _, v in pairs(descriptors) do
    table.insert(list, v)
  end
  table.sort(list, function(a, b)
    local aLoaded = a.loaded and 1 or 0
    local bLoaded = b.loaded and 1 or 0
    if aLoaded ~= bLoaded then
      return aLoaded > bLoaded
    end
    return (a.name or a.id) < (b.name or b.id)
  end)
  return list
end

function addon:SetPackEnabled(packId, enabled, addonName)
  local theDb = addon:GetDB() or {}
  theDb.packEnabled = theDb.packEnabled or {}
  theDb.packEnabled[packId] = enabled and true or false
  EmoteControlDB = theDb
  SpeakinLiteDB = EmoteControlDB

  if enabled and addonName then
    if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
      pcall(C_AddOns.LoadAddOn, addonName)
    elseif type(LoadAddOn) == "function" then
      pcall(LoadAddOn, addonName)
    end
  end

  if type(addon.RebuildAndRegister) == "function" then
    addon:RebuildAndRegister()
  end
end

function addon:RebuildAndRegister()
  if type(addon.BuildTriggerIndex) == "function" then
    addon:BuildTriggerIndex()
  end
  
  addon._registeredEvents = addon._registeredEvents or {}
  local keep = {
    GET_ITEM_INFO_RECEIVED = true,
    ITEM_DATA_LOAD_RESULT = true,
    PLAYER_REGEN_DISABLED = true,
    PLAYER_REGEN_ENABLED = true,
  }
  
  for eventName in pairs(addon._registeredEvents) do
    if not (addon.EventsToRegister and addon.EventsToRegister[eventName]) and not keep[eventName] then
      frame:UnregisterEvent(eventName)
      addon._registeredEvents[eventName] = nil
    end
  end
  
  for eventName in pairs(addon.EventsToRegister or {}) do
    frame:RegisterEvent(eventName)
    addon._registeredEvents[eventName] = true
  end
  
  for eventName in pairs(keep) do
    frame:RegisterEvent(eventName)
    addon._registeredEvents[eventName] = true
  end
end

function addon:HandleEvent(eventName, ...)
  if not db or db.enabled == false then return end

  -- Item info async load for loot parsing (Retail async cache)
  if eventName == "GET_ITEM_INFO_RECEIVED" or eventName == "ITEM_DATA_LOAD_RESULT" then
    local itemID, success = ...
    if not success or not addon._pendingLoot or not itemID then
      return
    end
    local pending = addon._pendingLoot[itemID]
    if not pending then return end
    addon._pendingLoot[itemID] = nil
    for _, entry in ipairs(pending) do
      addon:ProcessLootMessage(entry.message, entry.eventName, entry.attempts or 0)
    end
    return
  end

  if eventName == "UI_ERROR_MESSAGE" then
    local _, message = ...
    local errFull = _G.ERR_INV_FULL or _G.ERR_BAG_FULL
    if message and errFull and message == errFull then
      local bucket = addon.TriggersByEvent and addon.TriggersByEvent.BAG_FULL
      if bucket then
        local ctx = addon:MakeContext(nil)
        for _, trig in ipairs(bucket.list or {}) do
          if addon:TriggerCooldownOk(trig) and addon:MatchesTrigger(trig, "BAG_FULL", {}) then
            addon:FireTrigger(trig, ctx)
          end
        end
      end
    end
    return
  end

  if eventName == "UPDATE_INVENTORY_DURABILITY" then
    local bucket = addon.TriggersByEvent and addon.TriggersByEvent.REPAIR_NEEDED
    if bucket then
      local lowestPct
      for slot = 1, 18 do
        if type(GetInventoryItemDurability) == "function" then
          local cur, max = GetInventoryItemDurability("player", slot)
          if cur and max and max > 0 then
            local pct = cur / max
            if not lowestPct or pct < lowestPct then
              lowestPct = pct
            end
          end
        end
      end
      local threshold = (db and tonumber(db.repairThreshold)) or 0.2
      if lowestPct and lowestPct <= threshold then
        local ctx = addon:MakeContext(nil)
        for _, trig in ipairs(bucket.list or {}) do
          if addon:TriggerCooldownOk(trig) and addon:MatchesTrigger(trig, "REPAIR_NEEDED", {}) then
            addon:FireTrigger(trig, ctx)
          end
        end
      end
    end
    return
  end

  if eventName == "UNIT_SPELLCAST_SUCCEEDED" then
    if db.enableSpellTriggers == false then return end
  else
    if db.enableNonSpellTriggers == false then return end
  end

  if eventName == "COMBAT_LOG_EVENT_UNFILTERED" and db.enableCombatLogTriggers == false then
    return
  end
  if (eventName == "CHAT_MSG_LOOT" or eventName == "LOOT_READY") and db.enableLootTriggers == false then
    return
  end
  if eventName == "ACHIEVEMENT_EARNED" and db.enableAchievementTriggers == false then
    return
  end
  if eventName == "PLAYER_LEVEL_UP" and db.enableLevelUpTriggers == false then
    return
  end

  local bucket = addon.TriggersByEvent and addon.TriggersByEvent[eventName]
  if not bucket then return end

  local args = {}

  if eventName == "UNIT_SPELLCAST_SUCCEEDED" then
    local unit, _, spellID = ...
    if unit ~= "player" then return end
    if type(spellID) ~= "number" then return end

    if db.onlyLearnedSpells then
      if not addon:IsSpellKnownByPlayer(spellID) then
        return
      end
    end

    args.unit = unit
    args.spellID = spellID
    local ctx = addon:MakeContext(spellID)

    local listForSpell = bucket.bySpellID and bucket.bySpellID[spellID]
    if listForSpell then
      for _, trig in ipairs(listForSpell) do
        if addon:TriggerCooldownOk(trig) and addon:MatchesTrigger(trig, eventName, args) then
          addon:FireTrigger(trig, ctx)
        end
      end
    end

    for _, trig in ipairs(bucket.list or {}) do
      if addon:TriggerCooldownOk(trig) and addon:MatchesTrigger(trig, eventName, args) then
        addon:FireTrigger(trig, ctx)
      end
    end

    return
  end
  
  -- Achievement earned event
  if eventName == "ACHIEVEMENT_EARNED" then
    local achievementID = ...
    if achievementID then
      local achievementID, name, points, completed, month, day, year, description, flags, icon, rewardText = GetAchievementInfo(achievementID)
      local extraData = {
        achievement = name or ("Achievement #" .. tostring(achievementID)),
        achievementID = tostring(achievementID),
        achievementPoints = tostring(points or 0),
      }
      local ctx = addon:MakeContext(nil, extraData)
      
      for _, trig in ipairs(bucket.list or {}) do
        if addon:TriggerCooldownOk(trig) and addon:MatchesTrigger(trig, eventName, args) then
          addon:FireTrigger(trig, ctx)
        end
      end
    end
    return
  end
  
  -- Player level up event
  if eventName == "PLAYER_LEVEL_UP" then
    local newLevel = ...
    local extraData = {
      level = tostring(newLevel or UnitLevel("player")),
      newLevel = tostring(newLevel or UnitLevel("player")),
    }
    local ctx = addon:MakeContext(nil, extraData)
    
    for _, trig in ipairs(bucket.list or {}) do
      if addon:TriggerCooldownOk(trig) and addon:MatchesTrigger(trig, eventName, args) then
        addon:FireTrigger(trig, ctx)
      end
    end
    return
  end
  
  -- Loot event (for epic/legendary drops)
  if eventName == "CHAT_MSG_LOOT" or eventName == "LOOT_READY" then
    local message = ...
    if type(message) == "string" then
      addon:ProcessLootMessage(message, eventName, 0)
    end
    return
  end
  
  -- Combat Log Event (for crits, dodges, parries, interrupts, etc.)
  if eventName == "COMBAT_LOG_EVENT_UNFILTERED" then
    addon._combatLogInfo = addon._combatLogInfo or {}
    local eventInfo = addon._combatLogInfo
    eventInfo[1], eventInfo[2], eventInfo[3], eventInfo[4], eventInfo[5], eventInfo[6], eventInfo[7],
    eventInfo[8], eventInfo[9], eventInfo[10], eventInfo[11], eventInfo[12], eventInfo[13], eventInfo[14],
    eventInfo[15], eventInfo[16], eventInfo[17], eventInfo[18], eventInfo[19], eventInfo[20], eventInfo[21] =
      CombatLogGetCurrentEventInfo()

    local subevent = eventInfo[2]
    local sourceGUID = eventInfo[4]
    local destName = eventInfo[9]

    -- Only process events where player is the source
    if sourceGUID ~= UnitGUID("player") then
      return
    end

    -- Map combat log subevents to our trigger system
    local triggerEventName = nil
    local extraData = {}
    local spellId, spellName

    if subevent == "SWING_DAMAGE" then
      local amount = eventInfo[12]
      local critical = eventInfo[18]
      if critical then
        triggerEventName = "COMBAT_CRITICAL_HIT"
        extraData.damage = tostring(amount or 0)
        extraData.spell = "attack"
      end
    elseif subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" or subevent == "RANGE_DAMAGE" then
      spellId = eventInfo[12]
      spellName = eventInfo[13]
      local amount = eventInfo[15]
      local critical = eventInfo[21]
      if critical then
        triggerEventName = "COMBAT_CRITICAL_HIT"
        extraData.damage = tostring(amount or 0)
        extraData.spell = spellName or "spell"
      end
    elseif subevent == "SWING_MISSED" then
      local missType = eventInfo[12]
      if missType == "PARRY" then
        triggerEventName = "COMBAT_PARRIED"
      else
        triggerEventName = "COMBAT_DODGED"
      end
      extraData.missType = tostring(missType or "MISS")
    elseif subevent == "SPELL_MISSED" or subevent == "RANGE_MISSED" then
      spellId = eventInfo[12]
      spellName = eventInfo[13]
      local missType = eventInfo[15]
      if missType == "PARRY" then
        triggerEventName = "COMBAT_PARRIED"
      else
        triggerEventName = "COMBAT_DODGED"
      end
      extraData.missType = tostring(missType or "MISS")
    elseif subevent == "SPELL_INTERRUPT" then
      spellId = eventInfo[12]
      spellName = eventInfo[13]
      local extraSpellName = eventInfo[16]
      triggerEventName = "COMBAT_INTERRUPTED"
      extraData.spell = spellName or "spell"
      extraData.interruptedSpell = extraSpellName or "unknown"
    end

    -- If we found a combat event to process, fire triggers for it
    if triggerEventName then
      local bucket = addon.TriggersByEvent and addon.TriggersByEvent[triggerEventName]
      if bucket then
        extraData.target = destName or "enemy"
        local ctx = addon:MakeContext(spellId, extraData)

        for _, trig in ipairs(bucket.list or {}) do
          if addon:TriggerCooldownOk(trig) and addon:MatchesTrigger(trig, triggerEventName, args) then
            addon:FireTrigger(trig, ctx)
          end
        end
      end
    end

    return
  end

  -- Non-spell events (generic)
  local ctx = addon:MakeContext(nil)

  for _, trig in ipairs(bucket.list or {}) do
    if addon:TriggerCooldownOk(trig) and addon:MatchesTrigger(trig, eventName, args) then
      addon:FireTrigger(trig, ctx)
    end
  end
end

local function PrintHelp()
  addon:Print("Commands:")
  addon:Print("/sl status - View addon status")
  addon:Print("/sl stats - View usage statistics")
  addon:Print("/sl resetstats - Reset usage statistics")
  addon:Print("/sl mood [profile] - Change personality (default/serious/humorous/dark/heroic)")
  addon:Print("/sl debug - View debug info")
  addon:Print("/sl options - Open options panel")
  addon:Print("/sl packs - Manage packs")
  addon:Print("/sl editor - Customize triggers")
  addon:Print("/sl builder - Create custom triggers visually")
  addon:Print("/sl import | /sl export - Share configurations")
  addon:Print("/sl on | /sl off - Enable/disable addon")
  addon:Print("/sl channel <type> - Set default channel")
  addon:Print("/sl cooldown <seconds> - Set global cooldown")
end

local function HandleSlash(msg)
  msg = msg or ""
  local cmd, rest = msg:match("^(%S+)%s*(.-)%s*$")
  cmd = addon:SafeLower(cmd)

  if not cmd or cmd == "" or cmd == "help" then
    PrintHelp()
    return
  end

  if cmd == "status" then
    addon:Print("Version " .. addon.VERSION)
    addon:Print("Enabled: " .. tostring(db and db.enabled ~= false))
    addon:Print("Channel: " .. tostring(db and db.channel))
    addon:Print("Fallback to Self: " .. tostring(db and db.fallbackToSelf))
    addon:Print("Spell triggers: " .. tostring(db and db.enableSpellTriggers))
    addon:Print("Non-spell triggers: " .. tostring(db and db.enableNonSpellTriggers))
    addon:Print("Combat log triggers: " .. tostring(db and db.enableCombatLogTriggers))
    addon:Print("Loot triggers: " .. tostring(db and db.enableLootTriggers))
    addon:Print("Achievement triggers: " .. tostring(db and db.enableAchievementTriggers))
    addon:Print("Level-up triggers: " .. tostring(db and db.enableLevelUpTriggers))
    addon:Print("Only learned spells: " .. tostring(db and db.onlyLearnedSpells))
    addon:Print("Rotation protection: " .. tostring(db and db.rotationProtection))
    addon:Print("Global cooldown: " .. tostring(db and db.globalCooldown) .. "s")
    addon:Print("Max per minute: " .. tostring(db and db.maxPerMinute))
    local nPacks = 0
    for _ in pairs(addon.Packs or {}) do nPacks = nPacks + 1 end
    addon:Print("Loaded packs: " .. nPacks)
    return
  end
  
  if cmd == "debug" then
    addon:Print("=== Debug Info ===")
    addon:Print("Settings API: " .. tostring(Settings ~= nil))
    addon:Print("Settings.OpenToCategory: " .. tostring(Settings and type(Settings.OpenToCategory) == "function"))
    addon:Print("Settings Category: " .. tostring(addon._settingsCategory ~= nil))
    addon:Print("Settings Category ID: " .. tostring(addon._settingsCategoryId))
    addon:Print("OpenSettings function: " .. tostring(type(addon.OpenSettings) == "function"))
    addon:Print("InterfaceOptions: " .. tostring(InterfaceOptions_AddCategory ~= nil))
    addon:Print("InterfaceOptionsFrame_OpenToCategory: " .. tostring(InterfaceOptionsFrame_OpenToCategory ~= nil))
    return
  end

  if cmd == "options" then
    if type(addon.OpenOptions) == "function" then
      addon:OpenOptions()
    else
      addon:Print("Options UI not available.")
    end
    return
  end

  if cmd == "packs" then
    if type(addon.OpenPacksPanel) == "function" then
      addon:OpenPacksPanel()
    else
      addon:Print("Packs UI not available. Use Interface Options > Emote Control > Packs.")
    end
    return
  end

  if cmd == "editor" then
    if type(addon.OpenEditor) == "function" then
      addon:OpenEditor()
    else
      addon:Print("Editor UI not available.")
    end
    return
  end
  
  if cmd == "builder" or cmd == "create" then
    if type(addon.OpenTriggerBuilder) == "function" then
      addon:OpenTriggerBuilder()
    else
      addon:Print("Trigger Builder UI not available.")
    end
    return
  end

  if cmd == "import" or cmd == "export" or cmd == "importexport" then
    if type(addon.OpenImportExportUI) == "function" then
      addon:OpenImportExportUI()
    else
      addon:Print("Import/Export UI not available.")
    end
    return
  end

  if cmd == "on" then
    db.enabled = true
    addon:Print("Enabled")
    return
  end

  if cmd == "off" then
    db.enabled = false
    addon:Print("Disabled")
    return
  end

  if cmd == "channel" then
    local ch = addon:NormalizeChannel(rest)
    if not ch then
      addon:Print("Unknown channel. Try: self, party, raid, instance, say, yell, emote")
      return
    end
    db.channel = ch
    addon:Print("Channel set to " .. ch)
    return
  end

  if cmd == "cooldown" then
    local n = tonumber(rest)
    if not n then
      addon:Print("Usage: /sl cooldown 6")
      return
    end
    db.globalCooldown = addon:ClampNumber(n, 0, 600)
    addon:Print("Global cooldown set to " .. db.globalCooldown .. "s")
    return
  end
  
  if cmd == "mood" then
    local moods = {"default", "serious", "humorous", "dark", "heroic"}
    local mood = addon:SafeLower(rest)
    
    if not mood or mood == "" then
      addon:Print("Current mood: " .. (db.moodProfile or "default"))
      addon:Print("Available moods: default, serious, humorous, dark, heroic")
      return
    end
    
    local found = false
    for _, m in ipairs(moods) do
      if m == mood then
        found = true
        break
      end
    end
    
    if not found then
      addon:Print("Unknown mood. Available: default, serious, humorous, dark, heroic")
      return
    end
    
    db.moodProfile = mood
    addon:Print("Mood profile set to: " .. mood)
    return
  end

  if cmd == "stats" then
    addon:ShowStats()
    return
  end
  
  if cmd == "resetstats" then
    addon:ResetStats()
    return
  end

  PrintHelp()
end

SLASH_EMOTECONTROL1 = "/emotecontrol"
SLASH_EMOTECONTROL2 = "/ec"
SlashCmdList["EMOTECONTROL"] = HandleSlash

SLASH_SPEAKINLITE1 = "/sl"
SLASH_SPEAKINLITE2 = "/speakinlite"
SlashCmdList["SPEAKINLITE"] = HandleSlash

frame:SetScript("OnEvent", function(_, eventName, ...)
  if eventName == "PLAYER_LOGIN" then
    EmoteControlDB = EmoteControlDB or SpeakinLiteDB or {}
    SpeakinLiteDB = EmoteControlDB
    db = EmoteControlDB
    addon.db = db

    SetDefault(db, "enabled", true)
    SetDefault(db, "channel", "EMOTE")
    SetDefault(db, "fallbackToSelf", true)
    SetDefault(db, "globalCooldown", 6)
    SetDefault(db, "rotationProtection", "MEDIUM")
    SetDefault(db, "enableSpellTriggers", true)
    SetDefault(db, "enableNonSpellTriggers", true)
    SetDefault(db, "onlyLearnedSpells", true)
    SetDefault(db, "maxPerMinute", 12)
    SetDefault(db, "enableCombatLogTriggers", true)
    SetDefault(db, "enableLootTriggers", true)
    SetDefault(db, "enableAchievementTriggers", true)
    SetDefault(db, "enableLevelUpTriggers", true)
    SetDefault(db, "repairThreshold", 0.2)
    SetDefault(db, "onboardingShown", false)
    SetDefault(db, "version", addon.DB_VERSION)

    if type(db.packEnabled) ~= "table" then db.packEnabled = {} end
    if type(db.categoriesEnabled) ~= "table" then
      db.categoriesEnabled = {
        general = true,
        rotation = true,
        utility = true,
        defensive = true,
        cooldowns = true,
        movement = true,
        flavor = true,
      }
    end
    if type(db.triggerOverrides) ~= "table" then db.triggerOverrides = {} end

    addon:ApplyMigrations(db)
    
    -- Initialize mood profile
    if type(db.moodProfile) ~= "string" then
      db.moodProfile = "default"
    end
    
    -- Initialize stats
    if type(db.stats) ~= "table" then
      db.stats = {
        triggers = {},
        session = {},
        totalMessages = 0,
        sessionMessages = 0
      }
    end
    
    -- Reset session stats on login
    db.stats.session = {}
    db.stats.sessionMessages = 0
    
    -- Auto-enable class and race packs on first login
    if db.firstLogin == nil then
      db.firstLogin = false
      
      local playerClass = addon:GetPlayerClass()
      local playerRace = addon:GetPlayerRaceFile()
      
      -- Auto-enable class pack
      local classPack = string.lower(playerClass)
      if classPack and classPack ~= "" then
        db.packEnabled[classPack] = true
      end
      
      -- Auto-enable race pack
      local racePack = "race_" .. string.lower(playerRace)
      if playerRace and playerRace ~= "" then
        db.packEnabled[racePack] = true
      end
      
      -- Always enable common and daily activities packs
      db.packEnabled["common"] = true
      db.packEnabled["dailyactivities"] = true
      
      addon:Print("Welcome! Auto-enabled your class, race, and daily activities packs.")
    end

    -- Seed random number generator (if available)
    if math.randomseed then
      math.randomseed(math.floor(GetTime() * 1000) % 2147483647)
    elseif random then
      -- Some WoW versions use a global random function
      random(1, 1000)
    else
      -- Fallback: just call math.random a few times to initialize
      math.random(); math.random(); math.random()
    end

    addon:LoadPacksForPlayer()
    addon:LoadCustomTriggers()  -- Load user-created triggers
    addon:RebuildAndRegister()
    if type(addon.CreateSettingsPanel) == "function" then
      addon:CreateSettingsPanel()
    end
    if type(addon.CreatePacksSettingsPanel) == "function" then
      addon:CreatePacksSettingsPanel()
    end

    if db.onboardingShown ~= true then
      db.onboardingShown = true
      addon:ShowOnboarding()
    end

    addon:Print("Emote Control loaded. /sl help")
    return
  end

  addon:HandleEvent(eventName, ...)
end)

-- Register core events
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("PLAYER_ALIVE")
frame:RegisterEvent("RESURRECT_REQUEST")
frame:RegisterEvent("GROUP_JOINED")
frame:RegisterEvent("GROUP_LEFT")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("MAIL_SHOW")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("TAXIMAP_OPENED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
