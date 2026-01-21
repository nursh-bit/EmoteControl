-- EmoteControl - Core Engine
-- Lightweight, modular announcer addon with phrase packs

local ADDON_NAME = ...

-- Initialize the EmoteControl namespace with backward compatibility
EmoteControl = EmoteControl or {}
SpeakinLite = EmoteControl  -- Backward compatibility alias
local addon = EmoteControl

-- Metadata
addon.ADDON_NAME = ADDON_NAME
addon.VERSION = "0.10.15"
addon.DB_VERSION = 5

addon.L = addon.L or {}
local L = addon.L

local function InitLocale()
  local defaults = {
    WELCOME_1 = "Welcome! Use /sl options for quick setup and pack selection.",
    WELCOME_2 = "Tip: Try SELF channel with 6s cooldown and 8/min for low spam.",
    HELP_HEADER = "Commands:",
    HELP_STATUS = "/sl status - View addon status",
    HELP_STATS = "/sl stats - View usage statistics",
    HELP_RESETSTATS = "/sl resetstats - Reset usage statistics",
    HELP_MOOD = "/sl mood [profile] - Change personality (default/serious/humorous/dark/heroic)",
    HELP_DEBUG = "/sl debug - View debug info",
    HELP_OPTIONS = "/sl options - Open options panel",
    HELP_PACKS = "/sl packs [list] - Manage packs or list packs",
    HELP_EDITOR = "/sl editor - Customize triggers",
    HELP_BUILDER = "/sl builder - Create custom triggers visually",
    HELP_IMPORTEXPORT = "/sl import | /sl export - Share configurations",
    HELP_ONOFF = "/sl on | /sl off - Enable/disable addon",
    HELP_CHANNEL = "/sl channel <type> - Set default channel",
    HELP_COOLDOWN = "/sl cooldown <seconds> - Set global cooldown",
    HELP_TEST = "/sl test <triggerId> - Test a trigger immediately",
    HELP_COOLDOWNS = "/sl cooldowns - Show active trigger cooldowns",
    HELP_QUIET = "/sl quiet [HH-HH|off] - Quiet hours schedule",
    HELP_PACKPROFILE = "/sl packprofile [on|off] - Spec-based pack profiles",
    LOADED = "Emote Control loaded. /sl help",
    AUTO_ENABLED = "Welcome! Auto-enabled your class, race, and daily activities packs.",
  }

  for k, v in pairs(defaults) do
    if L[k] == nil then
      L[k] = v
    end
  end
end

-- Create event frame for listener registration
local frame = CreateFrame("Frame")
local loadStart = GetTime()

-- Taint diagnostics (for debugging - no debugstack to avoid taint propagation)
local taintFrame = CreateFrame("Frame")
taintFrame:RegisterEvent("ADDON_ACTION_BLOCKED")
taintFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
taintFrame:SetScript("OnEvent", function(_, event, addonName, funcName)
  if addonName == "SpeakinLite" or addonName == ADDON_NAME then
    local sourceLine
    if type(debugstack) == "function" then
      local stack
      if type(securecallfunction) == "function" then
        stack = securecallfunction(debugstack, 3, 1, 1)
      else
        stack = debugstack(3, 1, 1)
      end
      if type(stack) == "string" then
        sourceLine = stack:match("Interface/AddOns/[^%s]+:%d+")
      end
    end
    if sourceLine then
      print(string.format("|cffff0000%s|r addon=%s func=%s line=%s", event, tostring(addonName), tostring(funcName), sourceLine))
    else
      print(string.format("|cffff0000%s|r addon=%s func=%s line=unknown", event, tostring(addonName), tostring(funcName)))
    end
  end
end)

-- Event registration helpers with combat lockdown protection
local function ScheduleRebuildAfterCombat()
  if addon._rebuildTicker or not (C_Timer and C_Timer.NewTicker) then return end
  addon._rebuildTicker = C_Timer.NewTicker(1, function()
    if not (InCombatLockdown and InCombatLockdown()) then
      addon._rebuildTicker:Cancel()
      addon._rebuildTicker = nil
      if addon._rebuildAfterCombat then
        addon._rebuildAfterCombat = nil
        if type(addon.RebuildAndRegister) == "function" then
          addon:RebuildAndRegister()
        end
      end
    end
  end)
end

local function SecureRegisterEvent(targetFrame, eventName)
  if not targetFrame or not eventName then return end
  if type(targetFrame.RegisterEvent) ~= "function" then return end
  -- Avoid securecallfunction to reduce taint propagation
  pcall(targetFrame.RegisterEvent, targetFrame, eventName)
end

local function SecureUnregisterEvent(targetFrame, eventName)
  if not targetFrame or not eventName then return end
  if type(targetFrame.UnregisterEvent) ~= "function" then return end
  -- Avoid securecallfunction to reduce taint propagation
  pcall(targetFrame.UnregisterEvent, targetFrame, eventName)
end

local function QueueRebuildAndRegister()
  if C_Timer and C_Timer.After then
    C_Timer.After(0, function()
      if InCombatLockdown and InCombatLockdown() then
        addon._rebuildAfterCombat = true
        ScheduleRebuildAfterCombat()
        return
      end
      if type(addon.RebuildAndRegister) == "function" then
        addon:RebuildAndRegister()
      end
    end)
    return
  end

  if type(addon.RebuildAndRegister) == "function" then
    addon:RebuildAndRegister()
  end
end

local function SafeRegisterEvent(eventName)
  if InCombatLockdown and InCombatLockdown() then
    addon._rebuildAfterCombat = true
    ScheduleRebuildAfterCombat()
    return
  end
  SecureRegisterEvent(frame, eventName)
end

local function SafeUnregisterEvent(eventName)
  if InCombatLockdown and InCombatLockdown() then
    addon._rebuildAfterCombat = true
    ScheduleRebuildAfterCombat()
    return
  end
  SecureUnregisterEvent(frame, eventName)
end

local function RegisterCoreEvents()
  local function doRegister()
    SecureRegisterEvent(frame, "PLAYER_LOGIN")
    SecureRegisterEvent(frame, "PLAYER_DEAD")
    SecureRegisterEvent(frame, "PLAYER_ALIVE")
    SecureRegisterEvent(frame, "RESURRECT_REQUEST")
    SecureRegisterEvent(frame, "GROUP_JOINED")
    SecureRegisterEvent(frame, "GROUP_LEFT")
    SecureRegisterEvent(frame, "ZONE_CHANGED_NEW_AREA")
    SecureRegisterEvent(frame, "PLAYER_ENTERING_WORLD")
    SecureRegisterEvent(frame, "MAIL_SHOW")
    SecureRegisterEvent(frame, "BANKFRAME_OPENED")
    SecureRegisterEvent(frame, "MERCHANT_SHOW")
    SecureRegisterEvent(frame, "TAXIMAP_OPENED")
    SecureRegisterEvent(frame, "COMBAT_LOG_EVENT_UNFILTERED")
  end

  if InCombatLockdown and InCombatLockdown() then
    if addon._coreRegisterTicker == nil and C_Timer and C_Timer.NewTicker then
      addon._coreRegisterTicker = C_Timer.NewTicker(1, function()
        if not InCombatLockdown() then
          addon._coreRegisterTicker:Cancel()
          addon._coreRegisterTicker = nil
          doRegister()
        end
      end)
    end
    return
  end

  doRegister()
end

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
    adaptiveCooldowns = false,
    adaptiveCooldownMax = 2,
    packProfilesEnabled = false,
    quietHoursEnabled = false,
    quietHoursStart = 23,
    quietHoursEnd = 7,
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

  if v < 3 then
    SetDefault(db, "quietHoursEnabled", false)
    SetDefault(db, "quietHoursStart", 23)
    SetDefault(db, "quietHoursEnd", 7)
    v = 3
  end

  if v < 4 then
    SetDefault(db, "adaptiveCooldowns", false)
    SetDefault(db, "adaptiveCooldownMax", 2)
    v = 4
  end

  if v < 5 then
    SetDefault(db, "packProfilesEnabled", false)
    v = 5
  end

  db.version = v
end

function addon:ShowOnboarding()
  addon:Print(L.WELCOME_1)
  addon:Print(L.WELCOME_2)

  if type(addon.OpenOptions) == "function" then
    local inCombat = (type(InCombatLockdown) == "function") and InCombatLockdown()
    if not inCombat then
      pcall(addon.OpenOptions, addon)
    end
  end
end

local function SendChat(msg, channel, ...)
  if C_ChatInfo and type(C_ChatInfo.SendChatMessage) == "function" then
    return C_ChatInfo.SendChatMessage(msg, channel, ...)
  end
  local legacySend = rawget(_G, "SendChatMessage")
  if type(legacySend) == "function" then
    return legacySend(msg, channel, ...)
  end
end
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

local function TryNoteGlobalSend()
  if not db then return false end
  local maxPerMin = tonumber(db.maxPerMinute)
  if not maxPerMin or maxPerMin <= 0 then
    return true
  end

  local now = GetTime()
  PruneSentTimes(now)
  if #addon._sentTimes >= maxPerMin then
    return false
  end
  table.insert(addon._sentTimes, now)
  return true
end

local function GetSendLoad()
  if not db then return 0 end
  local maxPerMin = tonumber(db.maxPerMinute)
  if not maxPerMin or maxPerMin <= 0 then return 0 end
  local now = GetTime()
  PruneSentTimes(now)
  local load = #addon._sentTimes / maxPerMin
  return addon:ClampNumber(load, 0, 1)
end

function addon:IsQuietHours()
  if not db or db.quietHoursEnabled ~= true then return false end
  local startHour = tonumber(db.quietHoursStart)
  local endHour = tonumber(db.quietHoursEnd)
  if startHour == nil or endHour == nil then return false end

  local nowHour = (date and tonumber(date("%H"))) or 0

  if startHour == endHour then
    return true
  end

  if startHour < endHour then
    return nowHour >= startHour and nowHour < endHour
  end
  return nowHour >= startHour or nowHour < endHour
end

-- ========================================
-- Minimap Button
-- ========================================

local function GetMinimapRadii()
  if not Minimap then return 80, 80 end
  local w = Minimap:GetWidth() or 140
  local h = Minimap:GetHeight() or 140
  local rx = (w / 2) + 8
  local ry = (h / 2) + 8
  return rx, ry
end

local function UpdateMinimapButtonPosition(btn)
  if not btn or not db or not db.minimap or not Minimap then return end
  local angle = tonumber(db.minimap.angle) or 225
  local rad = math.rad(angle)
  local rx, ry = GetMinimapRadii()
  local x = math.cos(rad) * rx
  local y = math.sin(rad) * ry
  btn:ClearAllPoints()
  btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateMinimapButton()
  if addon._minimapButton or not Minimap then return end
  if db and db.minimap and db.minimap.hide then return end

  local btn = CreateFrame("Button", "EmoteControlMinimapButton", Minimap)
  btn:SetSize(31, 31)
  btn:SetFrameStrata("MEDIUM")
  btn:SetMovable(true)
  btn:RegisterForDrag("LeftButton")

  local icon = btn:CreateTexture(nil, "BACKGROUND")
  icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
  icon:SetSize(20, 20)
  icon:SetPoint("CENTER")
  btn.icon = icon

  local border = btn:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetSize(54, 54)
  border:SetPoint("CENTER", btn, "CENTER", 0, 0)

  btn:SetScript("OnDragStart", function(self)
    self._dragging = true
  end)

  btn:SetScript("OnDragStop", function(self)
    self._dragging = false
    if not db then return end
    db.minimap = db.minimap or { hide = false, angle = 225 }
    local x, y = GetCursorPosition()
    local scale = (Minimap and Minimap:GetEffectiveScale()) or UIParent:GetScale()
    x = x / scale
    y = y / scale
    local mx, my = Minimap:GetCenter()
    if not (mx and my) then return end
    local angle = math.deg(math.atan2(y - my, x - mx))
    if angle < 0 then angle = angle + 360 end
    db.minimap.angle = angle
    UpdateMinimapButtonPosition(self)
  end)

  btn:SetScript("OnClick", function(self, button)
    if self._dragging then return end
    if button == "RightButton" then
      if type(addon.OpenEditor) == "function" then
        addon:OpenEditor()
      end
      return
    end
    if type(addon.OpenOptions) == "function" then
      addon:OpenOptions()
    end
  end)

  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Emote Control")
    GameTooltip:AddLine("Left-click: Options", 1, 1, 1)
    GameTooltip:AddLine("Right-click: Trigger Editor", 1, 1, 1)
    GameTooltip:AddLine("Drag: Move", 1, 1, 1)
    GameTooltip:Show()
  end)

  btn:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  addon._minimapButton = btn
  UpdateMinimapButtonPosition(btn)
end

-- ApplySubs and MakeContext are now in Context.lua


-- Output a message to the specified or default channel with fallback handling
function addon:Output(msg, channelOverride)
  if not msg or msg == "" then return end

  if not TryNoteGlobalSend() then return end

  local channel = channelOverride or (db and db.channel) or "SELF"
  channel = string.upper(channel)

  if channel == "AUTO" then
    if IsInGroup and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
      channel = "INSTANCE"
    elseif IsInRaid and IsInRaid() then
      channel = "RAID"
    elseif IsInGroup and IsInGroup(LE_PARTY_CATEGORY_HOME) then
      channel = "PARTY"
    else
      channel = "SELF"
    end
  end

  -- Self output is always safe and doesn't require group checks
  if channel == "SELF" then
    addon:Print(msg)
    return
  end

  -- Validate and handle group channels with intelligent fallback
  local inInstance = IsInInstance and IsInInstance() or false
  
  -- Fallback from restricted channels
  if not inInstance and IsOutdoorRestrictedChat(channel) and (not db or db.fallbackToSelf ~= false) then
    channel = "EMOTE"
  elseif channel == "PARTY" then
    if not (IsInGroup and IsInGroup(LE_PARTY_CATEGORY_HOME)) then
      addon:Print(msg)
      return
    end
  elseif channel == "RAID" then
    if not (IsInRaid and IsInRaid()) then
      addon:Print(msg)
      return
    end
  elseif channel == "INSTANCE" then
    if not (IsInGroup and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
      if IsInGroup and IsInGroup(LE_PARTY_CATEGORY_HOME) then
        channel = "PARTY"
      else
        addon:Print(msg)
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
      return
    end
  end

  -- Attempt to send the message with fallback
  local ok, err = pcall(SendChat, msg, channel)
  if not ok then
    addon:Print("Chat failed: " .. tostring(err) .. ", sending to SELF.")
    addon:Print(msg)
  end
end

-- IsSpellKnownByPlayer is now in Context.lua


function addon:GetTriggerOverride(triggerId)
  if not db or type(db.triggerOverrides) ~= "table" then return nil end
  return db.triggerOverrides[triggerId]
end

function addon:ShouldTriggerBeActive(trig)
  if not db or db.enabled == false then return false end
  if addon:IsQuietHours() then return false end
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

function addon:GetTriggerCooldownSeconds(trig)
  local ov = addon:GetTriggerOverride(trig.id)

  local cd = (ov and tonumber(ov.cooldown)) or tonumber(trig.cooldown)
  if type(cd) ~= "number" then
    cd = tonumber(db and db.globalCooldown)
  end
  cd = addon:ClampNumber(cd or 0, 0, 600)

  if trig.event == "UNIT_SPELLCAST_SUCCEEDED" then
    local floor = GetRotationFloorSeconds()
    if floor and floor > 0 and cd < floor then
      cd = floor
    end
  end

  if cd > 0 and db and db.adaptiveCooldowns == true then
    local maxMult = tonumber(db.adaptiveCooldownMax) or 2
    maxMult = addon:ClampNumber(maxMult, 1, 5)
    local load = GetSendLoad()
    if load > 0 then
      cd = cd * (1 + (maxMult - 1) * load)
    end
  end

  return cd or 0
end

function addon:GetTriggerMessages(trig)
  local function ResolveLocaleMessages(messages)
    if type(messages) ~= "table" then return messages end
    if messages[1] ~= nil or messages.solo or messages.party or messages.raid or messages.instance then
      return messages
    end
    local locale = (type(GetLocale) == "function") and GetLocale() or nil
    if locale and type(messages[locale]) == "table" then
      return messages[locale]
    end
    if type(messages.default) == "table" then
      return messages.default
    end
    return messages
  end

  local ov = addon:GetTriggerOverride(trig.id)
  if ov and type(ov.messages) == "table" and #ov.messages > 0 then
    return ResolveLocaleMessages(ov.messages)
  end
  
  -- Check for mood-specific messages
  local mood = db and db.moodProfile or "default"
  if trig.messagesByMood and type(trig.messagesByMood) == "table" then
    if mood ~= "default" and trig.messagesByMood[mood] then
        return ResolveLocaleMessages(trig.messagesByMood[mood])
    end
    -- Fall back to default mood if available
    if trig.messagesByMood.default then
      return ResolveLocaleMessages(trig.messagesByMood.default)
    end
  end
  
  return ResolveLocaleMessages(trig.messages)
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

function addon:PruneStats(maxAgeDays)
  if not db or type(db.stats) ~= "table" then return end
  if type(db.stats.triggers) ~= "table" then return end

  local maxDays = tonumber(maxAgeDays) or 30
  if maxDays < 1 then maxDays = 1 end
  local cutoff = time() - (maxDays * 24 * 60 * 60)

  for trigId, stat in pairs(db.stats.triggers) do
    local lastFired = type(stat) == "table" and tonumber(stat.lastFired) or 0
    local exists = addon.TriggerById and addon.TriggerById[trigId]
    if not exists then
      db.stats.triggers[trigId] = nil
    elseif lastFired > 0 and lastFired < cutoff then
      db.stats.triggers[trigId] = nil
      db.stats.session[trigId] = nil
    end
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
  local legacyGetItemInfo = rawget(_G, "GetItemInfo")
  if type(legacyGetItemInfo) == "function" then
    local _, _, quality = legacyGetItemInfo(itemLink)
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

-- MakeContext is now in Context.lua


function addon:FireTrigger(trig, ctx)
  local messages = addon:GetTriggerMessages(trig)
  if type(messages) ~= "table" then return end

  -- Check for conditional message variants
  local messageList = messages
  if messages.solo or messages.party or messages.raid or messages.instance then
    -- Conditional messages based on group state
    local inRaid = IsInRaid and IsInRaid() or false
    local inParty = IsInGroup and IsInGroup() or false
    local inInstance = IsInInstance and IsInInstance() or false
    
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
        if specID == v then ok = true; break end
      end
      if not ok then return false end
    end
  end

  -- Instance gating
  if type(cond.inInstance) == "boolean" then
    local inInstance = IsInInstance and IsInInstance() or false
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
    if not (UnitExists and UnitExists("target")) then return false end
  end
  if type(cond.targetType) == "string" then
    if not (UnitExists and UnitExists("target")) then return false end
    local tt = string.lower(cond.targetType)
    if tt == "enemy" and (UnitIsFriend and UnitIsFriend("player", "target")) then return false end
    if tt == "friendly" and not (UnitIsFriend and UnitIsFriend("player", "target")) then return false end
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
        if want == args.quality then ok = true; break end
      end
      if not ok then return false end
    end
  end
  
  -- Random chance (0.0 to 1.0, where 0.5 = 50%)
  if cond.randomChance ~= nil then
    local chance = tonumber(cond.randomChance)
    if chance then
      if chance <= 0 then return false end
      if chance < 1 and math.random() > chance then
        return false
      end
    end
  end
  
  -- In combat check
  if type(cond.inCombat) == "boolean" then
    local inCombat = UnitAffectingCombat and UnitAffectingCombat("player") or false
    if inCombat ~= cond.inCombat then
      return false
    end
  end
  
  -- In group check
  if type(cond.inGroup) == "boolean" then
    local inGroup = (IsInGroup and IsInGroup()) or (IsInRaid and IsInRaid()) or false
    if inGroup ~= cond.inGroup then
      return false
    end
  end
  
  -- Group size check
  if type(cond.groupSize) == "table" then
    local size = (GetNumGroupMembers and GetNumGroupMembers()) or 0
    if IsInRaid and IsInRaid() then
      size = GetNumGroupMembers and GetNumGroupMembers() or 0
    elseif IsInGroup and IsInGroup() then
      size = GetNumGroupMembers and GetNumGroupMembers() or 0
    else
      size = 1
    end

    local minSize = tonumber(cond.groupSize.min)
    local maxSize = tonumber(cond.groupSize.max)
    if minSize and size < minSize then
      return false
    end
    if maxSize and size > maxSize then
      return false
    end
  end
  
  -- Has aura/buff check
  if type(cond.hasAura) == "string" or type(cond.hasAura) == "number" then
    local foundAura = false
    if type(AuraUtil) == "table" and type(AuraUtil.FindAuraByName) == "function" then
      -- Retail API
      foundAura = AuraUtil.FindAuraByName(cond.hasAura, "player") ~= nil
    else
      local legacyUnitBuff = rawget(_G, "UnitBuff")
      if type(legacyUnitBuff) == "function" then
        -- Classic API - scan buffs
        for i = 1, 40 do
          local name, _, _, _, _, _, _, _, _, spellId = legacyUnitBuff("player", i)
          if not name then break end
          if name == cond.hasAura or spellId == cond.hasAura then
            foundAura = true
            break
          end
        end
      end
    end
    if not foundAura then
      return false
    end
  end
  
  -- Target is boss check
  if cond.targetIsBoss == true then
    if not (UnitExists and UnitExists("target")) then return false end
    local classification = UnitClassification and UnitClassification("target") or ""
    if classification ~= "worldboss" and classification ~= "rareelite" and classification ~= "elite" then
      -- Also check if it's a dungeon/raid boss
      local targetLevel = UnitLevel and UnitLevel("target") or 0
      local inInstance = IsInInstance and IsInInstance() or false
      local isEnemy = UnitIsEnemy and UnitIsEnemy("player", "target") or false
      if not (targetLevel == -1 or (inInstance and isEnemy)) then
        return false
      end
    end
  end
  
  -- Health percentage threshold
  if cond.healthBelow ~= nil or cond.healthAbove ~= nil then
    local below = tonumber(cond.healthBelow)
    local above = tonumber(cond.healthAbove)
    local healthMax = (UnitHealthMax and UnitHealthMax("player")) or 0
    local healthPct = 0
    if healthMax > 0 then
      healthPct = ((UnitHealth and UnitHealth("player")) or 0) / healthMax * 100
    end
    if below then
      below = addon:ClampNumber(below, 0, 100)
      if healthPct >= below then return false end
    end
    if above then
      above = addon:ClampNumber(above, 0, 100)
      if healthPct <= above then return false end
    end
  end

  return true
end

local PACK_PREFIXES = {"SpeakinLite_Pack_", "EmoteControl_Pack_"}

-- Note: LoadAddOn is completely protected in modern WoW and cannot be called
-- after the initial addon loading phase. Packs must be enabled via the
-- AddOns menu at character select, then /reload to take effect.
local function Addons_Load(name)
  if InCombatLockdown and InCombatLockdown() then return end 
  local loaded, reason
  if C_AddOns and C_AddOns.LoadAddOn then
    loaded, reason = C_AddOns.LoadAddOn(name)
  elseif LoadAddOn then
    loaded, reason = LoadAddOn(name)
  end
  return loaded, reason
end

local function Addons_GetNum()
  if C_AddOns and type(C_AddOns.GetNumAddOns) == "function" then
    return C_AddOns.GetNumAddOns()
  end
  local legacyGetNumAddOns = rawget(_G, "GetNumAddOns")
  if type(legacyGetNumAddOns) == "function" then
    return legacyGetNumAddOns()
  end
  return 0
end

local function Addons_GetInfo(i)
  if C_AddOns and type(C_AddOns.GetAddOnInfo) == "function" then
    return C_AddOns.GetAddOnInfo(i)
  end
  local legacyGetAddOnInfo = rawget(_G, "GetAddOnInfo")
  if type(legacyGetAddOnInfo) == "function" then
    return legacyGetAddOnInfo(i)
  end
  return nil
end

local function Addons_GetMeta(addonName, field)
  if C_AddOns and type(C_AddOns.GetAddOnMetadata) == "function" then
    return C_AddOns.GetAddOnMetadata(addonName, field)
  end
  local legacyGetAddOnMetadata = rawget(_G, "GetAddOnMetadata")
  if type(legacyGetAddOnMetadata) == "function" then
    return legacyGetAddOnMetadata(addonName, field)
  end
  return nil
end

local function Addons_IsLoaded(addonName)
  if C_AddOns and type(C_AddOns.IsAddOnLoaded) == "function" then
    return C_AddOns.IsAddOnLoaded(addonName)
  end
  local legacyIsAddOnLoaded = rawget(_G, "IsAddOnLoaded")
  if type(legacyIsAddOnLoaded) == "function" then
    return legacyIsAddOnLoaded(addonName)
  end
  return false
end

local function HasPackPrefix(name)
  if type(name) ~= "string" then return false end
  for _, prefix in ipairs(PACK_PREFIXES) do
    if string.sub(name, 1, #prefix) == prefix then
      return true
    end
  end
  return false
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

  local playerClass = addon:SafeLower(addon:GetPlayerClass()) or ""
  local playerRace = addon:SafeLower(addon:GetPlayerRaceFile()) or ""

  local n = Addons_GetNum()
  for i = 1, n do
    local name = Addons_GetInfo(i)
    if type(name) == "string" and HasPackPrefix(name) then
      local packType = addon:SafeLower(
        Addons_GetMeta(name, "X-EmoteControl-PackType") or Addons_GetMeta(name, "X-SpeakinLite-PackType")
      )
      local classTag = addon:SafeLower(
        Addons_GetMeta(name, "X-EmoteControl-Class") or Addons_GetMeta(name, "X-SpeakinLite-Class")
      )
      local raceTag = addon:SafeLower(
        Addons_GetMeta(name, "X-EmoteControl-Race") or Addons_GetMeta(name, "X-SpeakinLite-Race")
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
        Addons_Load(name)
      end
    end
  end

  -- Also load any packs explicitly enabled by the user (only safe at login, before combat)
  local function IsPackExplicitlyEnabled(packId)
    if type(packId) ~= "string" or packId == "" then return false end
    local theDb = addon:GetDB() or {}
    if theDb.packProfilesEnabled == true then
      local specId = select(1, addon:GetSpecInfo())
      if specId and type(theDb.packEnabledBySpec) == "table" then
        local t = theDb.packEnabledBySpec[specId]
        if type(t) == "table" then
          local v = t[packId]
          if v ~= nil then return v == true end
        end
      end
    end
    if type(theDb.packEnabled) == "table" then
      local v = theDb.packEnabled[packId]
      if v ~= nil then return v == true end
    end
    return false
  end

  -- Note: We cannot call LoadAddOn after the initial load phase in modern WoW.
  -- Packs that aren't loaded yet will need a /reload after being enabled.
  -- The pack will be loaded on next login/reload if enabled in the AddOns menu.
end

local function NormalizePackIdFromAddonName(name)
  if type(name) ~= "string" then return nil end
  for _, prefix in ipairs(PACK_PREFIXES) do
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

  local n = Addons_GetNum()
  for i = 1, n do
    local name, title, notes, loadable, reason, security = Addons_GetInfo(i)
    if type(name) == "string" and HasPackPrefix(name) then
      local packType = addon:SafeLower(
        Addons_GetMeta(name, "X-EmoteControl-PackType") or Addons_GetMeta(name, "X-SpeakinLite-PackType")
      )
      local classTag = addon:SafeLower(
        Addons_GetMeta(name, "X-EmoteControl-Class") or Addons_GetMeta(name, "X-SpeakinLite-Class")
      )
      local raceTag = addon:SafeLower(
        Addons_GetMeta(name, "X-EmoteControl-Race") or Addons_GetMeta(name, "X-SpeakinLite-Race")
      )
      local packId = addon:SafeLower(
        Addons_GetMeta(name, "X-EmoteControl-PackId") or Addons_GetMeta(name, "X-SpeakinLite-PackId")
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
          loaded = Addons_IsLoaded(name),
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
  if theDb.packProfilesEnabled == true then
    local specId = select(1, addon:GetSpecInfo())
    if specId then
      theDb.packEnabledBySpec = theDb.packEnabledBySpec or {}
      theDb.packEnabledBySpec[specId] = theDb.packEnabledBySpec[specId] or {}
      theDb.packEnabledBySpec[specId][packId] = enabled and true or false
    else
      theDb.packEnabled = theDb.packEnabled or {}
      theDb.packEnabled[packId] = enabled and true or false
    end
  else
    theDb.packEnabled = theDb.packEnabled or {}
    theDb.packEnabled[packId] = enabled and true or false
  end
  EmoteControlDB = theDb
  SpeakinLiteDB = EmoteControlDB

  -- Note: LoadAddOn is protected in modern WoW and can cause taint.
  -- Packs marked LoadOnDemand will load on the next /reload.
  if enabled and addonName then
    local isLoaded = Addons_IsLoaded(addonName)
    if not isLoaded then
      addon:Print("Pack enabled. Type /reload to load it.")
    end
  end

  if type(addon.RebuildAndRegister) == "function" then
    QueueRebuildAndRegister()
  end
end

function addon:GetPackEnabled(packId)
  if type(packId) ~= "string" or packId == "" then return true end
  local theDb = addon:GetDB() or {}

  if theDb.packProfilesEnabled == true then
    local specId = select(1, addon:GetSpecInfo())
    if specId and type(theDb.packEnabledBySpec) == "table" then
      local t = theDb.packEnabledBySpec[specId]
      if type(t) == "table" then
        local v = t[packId]
        if v ~= nil then return v == true end
      end
    end
  end

  if type(theDb.packEnabled) == "table" then
    local v = theDb.packEnabled[packId]
    if v ~= nil then return v == true end
  end

  return true
end

function addon:RebuildAndRegister()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    addon._rebuildAfterCombat = true
    return
  end
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
      SafeUnregisterEvent(eventName)
      addon._registeredEvents[eventName] = nil
    end
  end
  
  for eventName in pairs(addon.EventsToRegister or {}) do
    SafeRegisterEvent(eventName)
    addon._registeredEvents[eventName] = true
  end
  
  for eventName in pairs(keep) do
    SafeRegisterEvent(eventName)
    addon._registeredEvents[eventName] = true
  end
end

function addon:HandleEvent(eventName, ...)
  if eventName == "PLAYER_REGEN_ENABLED" and addon._rebuildAfterCombat then
    addon._rebuildAfterCombat = nil
    addon:RebuildAndRegister()
    return
  end
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
    local errFull = rawget(_G, "ERR_INV_FULL") or rawget(_G, "ERR_BAG_FULL")
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
          local ok, cur, max = pcall(GetInventoryItemDurability, slot)
          if ok and cur and max and max > 0 then
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
      local name, points
      if GetAchievementInfo then
         local _, achName, achPoints = GetAchievementInfo(achievementID)
         name = achName
         points = achPoints
      end
      
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
    local currentLevel = newLevel or (UnitLevel and UnitLevel("player")) or 1
    local extraData = {
      level = tostring(currentLevel),
      newLevel = tostring(currentLevel),
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
    -- Reuse a single table for combat log event info to avoid per-event allocations
    local eventInfo = addon._combatLogInfo
    if not eventInfo then
      eventInfo = {}
      addon._combatLogInfo = eventInfo
    else
      wipe(eventInfo)
    end

    -- Use select to grab params without table allocation (11.0/12.0 safe)
    -- CombatLogGetCurrentEventInfo returns: timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...
    local _, subevent, _, sourceGUID, _, _, _, _, destName = CombatLogGetCurrentEventInfo()
    
    eventInfo[2] = subevent
    eventInfo[4] = sourceGUID
    eventInfo[9] = destName

    -- Extract payload args based on subevent
    if subevent == "SWING_DAMAGE" then
        eventInfo[12], _, _, _, _, _, eventInfo[18] = select(12, CombatLogGetCurrentEventInfo())
    elseif subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" or subevent == "RANGE_DAMAGE" then
        eventInfo[12], eventInfo[13], _, eventInfo[15], _, _, _, _, _, eventInfo[21] = select(12, CombatLogGetCurrentEventInfo())
    elseif subevent == "SWING_MISSED" then
        eventInfo[12] = select(12, CombatLogGetCurrentEventInfo())
    elseif subevent == "SPELL_MISSED" or subevent == "RANGE_MISSED" then
        eventInfo[12], eventInfo[13], _, eventInfo[15] = select(12, CombatLogGetCurrentEventInfo())
    elseif subevent == "SPELL_INTERRUPT" then
        eventInfo[12], eventInfo[13], _, _, eventInfo[16] = select(12, CombatLogGetCurrentEventInfo())
    end

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
  addon:Print(L.HELP_HEADER)
  addon:Print(L.HELP_STATUS)
  addon:Print(L.HELP_STATS)
  addon:Print(L.HELP_RESETSTATS)
  addon:Print(L.HELP_MOOD)
  addon:Print(L.HELP_DEBUG)
  addon:Print(L.HELP_OPTIONS)
  addon:Print(L.HELP_PACKS)
  addon:Print(L.HELP_EDITOR)
  addon:Print(L.HELP_BUILDER)
  addon:Print(L.HELP_IMPORTEXPORT)
  addon:Print(L.HELP_ONOFF)
  addon:Print(L.HELP_CHANNEL)
  addon:Print(L.HELP_COOLDOWN)
  addon:Print(L.HELP_TEST)
  addon:Print(L.HELP_COOLDOWNS)
  addon:Print(L.HELP_QUIET)
  addon:Print(L.HELP_PACKPROFILE)
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
    addon:Print("Adaptive cooldowns: " .. tostring(db and db.adaptiveCooldowns) .. " (max x" .. tostring(db and db.adaptiveCooldownMax) .. ")")
    addon:Print("Spec-based pack profiles: " .. tostring(db and db.packProfilesEnabled))
    addon:Print("Quiet hours: " .. tostring(db and db.quietHoursEnabled) .. " (" .. tostring(db and db.quietHoursStart) .. "-" .. tostring(db and db.quietHoursEnd) .. ")")
    local nPacks = 0
    for _ in pairs(addon.Packs or {}) do nPacks = nPacks + 1 end
    addon:Print("Loaded packs: " .. nPacks)
    return
  end
  
  if cmd == "debug" then
    addon:Print("=== Debug Info ===")
    if type(addon._loadTime) == "number" then
      addon:Print("Load time: " .. string.format("%.2f", addon._loadTime * 1000) .. "ms")
    end
    addon:Print("Settings API: " .. tostring(Settings ~= nil))
    addon:Print("Settings.OpenToCategory: " .. tostring(Settings and type(Settings.OpenToCategory) == "function"))
    addon:Print("Settings Category: " .. tostring(addon._settingsCategory ~= nil))
    addon:Print("Settings Category ID: " .. tostring(addon._settingsCategoryId))
    addon:Print("OpenSettings function: " .. tostring(type(addon.OpenSettings) == "function"))
    addon:Print("InterfaceOptions: " .. tostring(rawget(_G, "InterfaceOptions_AddCategory") ~= nil))
    addon:Print("InterfaceOptionsFrame_OpenToCategory: " .. tostring(rawget(_G, "InterfaceOptionsFrame_OpenToCategory") ~= nil))
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
    local sub, filter = rest:match("^(%S+)%s*(.-)%s*$")
    if sub == "list" then
      local list = {}
      if type(addon.GetPackDescriptors) == "function" then
        list = addon:GetPackDescriptors()
      else
        for id, pack in pairs(addon.Packs or {}) do
          table.insert(list, { id = id, name = (pack and pack.name) or id, loaded = true })
        end
      end
      local needle = addon:SafeLower(filter or "") or ""
      addon:Print("Packs:")
      local shown = 0
      for _, entry in ipairs(list) do
        local label = entry.name or entry.id
        local hay = addon:SafeLower(label .. " " .. tostring(entry.id or "")) or ""
        if needle == "" or hay:find(needle, 1, true) then
          local enabled = (type(addon.GetPackEnabled) == "function") and addon:GetPackEnabled(entry.id) or addon:IsPackEnabled(entry.id)
          local status = enabled and "enabled" or "disabled"
          local loaded = (entry.loaded == false) and "not loaded" or "loaded"
          addon:Print("- " .. label .. " (" .. status .. ", " .. loaded .. ")")
          shown = shown + 1
          if shown >= 50 then
            addon:Print("..." .. tostring(#list - shown) .. " more. Use /sl packs list <filter>.")
            break
          end
        end
      end
      return
    end

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

  if cmd == "test" then
    local trigId = rest
    if not trigId or trigId == "" then
      addon:Print("Usage: /sl test <triggerId>")
      addon:Print("Tip: Use /sl editor to view trigger IDs.")
      return
    end
    local trig = addon.TriggerById and addon.TriggerById[trigId]
    if not trig then
      addon:Print("Trigger not found: " .. trigId)
      return
    end
    local ctx = addon:MakeContext(trig.spellID)
    addon:FireTrigger(trig, ctx)
    addon:Print("Tested trigger: " .. trigId)
    return
  end

  if cmd == "cooldowns" then
    local now = GetTime()
    local list = {}
    for id, trig in pairs(addon.TriggerById or {}) do
      if trig.lastFired then
        local cd = addon:GetTriggerCooldownSeconds(trig)
        if cd and cd > 0 then
          local remaining = cd - (now - trig.lastFired)
          if remaining > 0 then
            table.insert(list, {
              id = id,
              remaining = remaining,
              category = trig.category or "general",
            })
          end
        end
      end
    end

    if #list == 0 then
      addon:Print("No active trigger cooldowns.")
      return
    end

    table.sort(list, function(a, b) return a.remaining > b.remaining end)
    addon:Print("Active cooldowns (top 10):")
    for i = 1, math.min(10, #list) do
      local t = list[i]
      addon:Print(string.format("  %d. %s [%s] - %.1fs", i, t.id, t.category, t.remaining))
    end
    return
  end

  if cmd == "quiet" then
    local arg = addon:SafeLower(rest or "")
    if arg == "" then
      local enabled = db and db.quietHoursEnabled
      local startHour = db and db.quietHoursStart
      local endHour = db and db.quietHoursEnd
      addon:Print("Quiet hours: " .. tostring(enabled) .. " (" .. tostring(startHour) .. "-" .. tostring(endHour) .. ")")
      return
    end

    if arg == "off" then
      db.quietHoursEnabled = false
      addon:Print("Quiet hours disabled.")
      return
    end

    local startStr, endStr = arg:match("^(%d+)%s*%-%s*(%d+)$")
    local startHour = tonumber(startStr)
    local endHour = tonumber(endStr)
    if startHour == nil or endHour == nil or startHour < 0 or startHour > 23 or endHour < 0 or endHour > 23 then
      addon:Print("Usage: /sl quiet 23-7 (24h clock) or /sl quiet off")
      return
    end

    db.quietHoursEnabled = true
    db.quietHoursStart = startHour
    db.quietHoursEnd = endHour
    addon:Print("Quiet hours set to " .. startHour .. "-" .. endHour .. ".")
    return
  end

  if cmd == "packprofile" then
    local arg = addon:SafeLower(rest or "")
    if arg == "" then
      local specId, specName = addon:GetSpecInfo()
      addon:Print("Spec-based pack profiles: " .. tostring(db and db.packProfilesEnabled))
      addon:Print("Current spec: " .. tostring(specName or "") .. " (" .. tostring(specId or "") .. ")")
      return
    end
    if arg == "on" then
      db.packProfilesEnabled = true
      addon:Print("Spec-based pack profiles enabled.")
      if type(addon.RebuildAndRegister) == "function" then
        addon:RebuildAndRegister()
      end
      return
    end
    if arg == "off" then
      db.packProfilesEnabled = false
      addon:Print("Spec-based pack profiles disabled.")
      if type(addon.RebuildAndRegister) == "function" then
        addon:RebuildAndRegister()
      end
      return
    end
    addon:Print("Usage: /sl packprofile on|off")
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

local function RegisterSlashCommands()
  -- Mitigation: avoid touching globals if already registered or explicitly disabled.
  if db and db.disableSlashCommands == true then return end
  if type(SlashCmdList) ~= "table" then return end

  if rawget(_G, "SLASH_EMOTECONTROL1") == nil then
    rawset(_G, "SLASH_EMOTECONTROL1", "/emotecontrol")
  end
  if rawget(_G, "SLASH_EMOTECONTROL2") == nil then
    rawset(_G, "SLASH_EMOTECONTROL2", "/ec")
  end
  if type(SlashCmdList["EMOTECONTROL"]) ~= "function" then
    SlashCmdList["EMOTECONTROL"] = HandleSlash
  end

  if rawget(_G, "SLASH_SPEAKINLITE1") == nil then
    rawset(_G, "SLASH_SPEAKINLITE1", "/sl")
  end
  if rawget(_G, "SLASH_SPEAKINLITE2") == nil then
    rawset(_G, "SLASH_SPEAKINLITE2", "/speakinlite")
  end
  if type(SlashCmdList["SPEAKINLITE"]) ~= "function" then
    SlashCmdList["SPEAKINLITE"] = HandleSlash
  end
end

frame:SetScript("OnEvent", function(_, eventName, ...)
  if eventName == "PLAYER_LOGIN" then
    EmoteControlDB = EmoteControlDB or SpeakinLiteDB or {}
    SpeakinLiteDB = EmoteControlDB
    db = EmoteControlDB
    addon.db = db

    InitLocale()

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
    SetDefault(db, "minimap", { hide = false, angle = 225 })
    SetDefault(db, "version", addon.DB_VERSION)
    SetDefault(db, "disableSlashCommands", false)

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
      
      addon:Print(L.AUTO_ENABLED)
    end

    -- Seed random number generator (if available)
    local randomseed = rawget(math, "randomseed") or rawget(_G, "randomseed")
    if type(randomseed) == "function" then
      randomseed(math.floor(GetTime() * 1000) % 2147483647)
    elseif type(random) == "function" then
      -- Some WoW versions use a global random function
      local _ = random(1, 1000)
    else
      -- Fallback: just call math.random a few times to initialize
      math.random(); math.random(); math.random()
    end

    addon:LoadPacksForPlayer()
    addon:LoadCustomTriggers()  -- Load user-created triggers
    addon:RebuildAndRegister()
    addon:PruneStats(30)
    CreateMinimapButton()
    if type(addon.CreateSettingsPanel) == "function" then
      addon:CreateSettingsPanel()
    end
    if type(addon.CreatePacksSettingsPanel) == "function" then
      addon:CreatePacksSettingsPanel()
    end

    -- Register slash commands late to reduce taint exposure at login.
    RegisterSlashCommands()

    if db.onboardingShown ~= true then
      db.onboardingShown = true
      addon:ShowOnboarding()
    end

    addon._loadTime = GetTime() - loadStart
    addon:Print(L.LOADED)
    
    return
  end

  addon:HandleEvent(eventName, ...)
end)

-- Register core events
RegisterCoreEvents()
