-- EmoteControl - Context and Token Management
-- Handles lazy creation of context data for message substitution

local ADDON_NAME, namespace = ...
local addon = EmoteControl

-- ========================================
-- Token Resolvers
-- ========================================

local resolvers = {}

-- Helper to get unit name/realm
local function GetUnitNameFull(unit)
  if not UnitName then return nil end
  local name, realm = UnitName(unit)
  if not name then return nil end
  if realm and realm ~= "" then
    return name .. "-" .. realm
  end
  return name
end

-- Player Basic
resolvers.player = function() return (UnitName and UnitName("player")) or "" end
resolvers["player-full"] = function() return GetUnitNameFull("player") end
resolvers.level = function() return tostring((UnitLevel and UnitLevel("player")) or 1) end
resolvers.race = function() return (UnitRace and UnitRace("player")) or "" end
resolvers.class = function() return (UnitClass and UnitClass("player")) or "" end
resolvers.className = resolvers.class
resolvers["class-name"] = resolvers.class
resolvers.faction = function() return (UnitFactionGroup and UnitFactionGroup("player")) or "" end
resolvers.realm = function() return (GetRealmName and GetRealmName()) or "" end
resolvers.guild = function() return (GetGuildInfo and GetGuildInfo("player")) or "" end

-- Player Detailed
resolvers.zone = function() 
    if C_Map and C_Map.GetBestMapForUnit then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local info = C_Map.GetMapInfo(mapID)
            if info and info.name then return info.name end
        end
    end
    return (GetZoneText and GetZoneText()) or "" 
end
resolvers.subzone = function() return (GetSubZoneText and GetSubZoneText()) or "" end
resolvers.mapID = function() 
    return (C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")) or "" 
end
resolvers.mapid = resolvers.mapID
resolvers.continent = function(ctx)
    local mapID = ctx.mapID
    if type(mapID) == "number" and C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapID)
        if info and info.parentMapID then
            local parent = C_Map.GetMapInfo(info.parentMapID)
            return parent and parent.name or ""
        end
    end
    return ""
end

resolvers.spec = function() 
    local _, name = addon:GetSpecInfo() 
    return name 
end
resolvers.specID = function() 
    local id, _ = addon:GetSpecInfo() 
    return tostring(id or "") 
end
resolvers.role = function()
    if GetSpecialization and GetSpecializationRole then
        local specIndex = GetSpecialization()
        if specIndex then return GetSpecializationRole(specIndex) end
    end
    return ""
end
resolvers.ilvl = function() 
    if GetAverageItemLevel then
        return tostring(select(2, GetAverageItemLevel()) or "") 
    end
    return ""
end


-- Health/Power
resolvers.health = function() return tostring((UnitHealth and UnitHealth("player")) or 0) end
resolvers.healthmax = function() return tostring((UnitHealthMax and UnitHealthMax("player")) or 1) end
resolvers["health%"] = function() 
    local h = (UnitHealth and UnitHealth("player")) or 0
    local m = (UnitHealthMax and UnitHealthMax("player")) or 1
    if not m or m == 0 then return "0" end
    return tostring(math.floor((h/m)*100)) 
end
resolvers.healthPct = resolvers["health%"] -- alias

resolvers.power = function() return tostring((UnitPower and UnitPower("player")) or 0) end
resolvers.powermax = function() return tostring((UnitPowerMax and UnitPowerMax("player")) or 1) end
resolvers["power%"] = function() 
    local p = (UnitPower and UnitPower("player")) or 0
    local m = (UnitPowerMax and UnitPowerMax("player")) or 1
    if not m or m == 0 then return "0" end
    return tostring(math.floor((p/m)*100)) 
end
resolvers.powerPct = resolvers["power%"]

resolvers.powername = function()
    local powerType = (UnitPowerType and UnitPowerType("player")) or 0
    if powerType == 0 then return "Mana" end
    if powerType == 1 then return "Rage" end
    if powerType == 2 then return "Focus" end
    if powerType == 3 then return "Energy" end
    if powerType == 6 then return "Runic Power" end
    return "Power"
end
resolvers.combo = function() return tostring((UnitPower and UnitPower("player", 4)) or 0) end

-- Target
resolvers.target = function() return (UnitName and UnitName("target")) or "nobody" end
resolvers["target-full"] = function() return GetUnitNameFull("target") or "nobody" end
resolvers["target-class"] = function() return (UnitClass and UnitClass("target")) or "" end
resolvers["target-race"] = function() return (UnitRace and UnitRace("target")) or "" end
resolvers["target-level"] = function() return tostring((UnitLevel and UnitLevel("target")) or "") end
resolvers["target-dead"] = function() return (UnitIsDeadOrGhost and UnitIsDeadOrGhost("target")) and "true" or "false" end
resolvers["target-realm"] = function() 
    if not UnitName then return "" end
    local _, r = UnitName("target"); 
    return r or "" 
end

resolvers["target-health"] = function() return tostring((UnitHealth and UnitHealth("target")) or 0) end
resolvers["target-healthmax"] = function() return tostring((UnitHealthMax and UnitHealthMax("target")) or 1) end
resolvers["target-health%"] = function()
    if not UnitExists or not UnitExists("target") then return "0" end
    local h = (UnitHealth and UnitHealth("target")) or 0
    local m = (UnitHealthMax and UnitHealthMax("target")) or 1
    if not m or m == 0 then return "0" end
    return tostring(math.floor((h/m)*100)) 
end

-- Instance/Group
resolvers.inInstance = function() return (IsInInstance and IsInInstance()) or false end
resolvers["in-instance"] = function(ctx) return ctx.inInstance and "true" or "false" end

local function SafeGetInstanceInfo()
    if GetInstanceInfo then return GetInstanceInfo() end
    return nil, nil, nil, nil, nil, nil, nil, nil, nil
end

resolvers.instanceName = function() local name = SafeGetInstanceInfo(); return name or "" end
resolvers["instance-name"] = resolvers.instanceName
resolvers.instanceType = function() local _, type = SafeGetInstanceInfo(); return type or "" end
resolvers["instance-type"] = resolvers.instanceType

resolvers.instanceDifficulty = function() local _, _, _, diffName = SafeGetInstanceInfo(); return diffName or "" end
resolvers["instance-difficulty"] = resolvers.instanceDifficulty
resolvers["instance-difficulty-id"] = function() local _, _, diffID = SafeGetInstanceInfo(); return tostring(diffID or "") end
resolvers["instance-mapid"] = function() local _, _, _, _, _, _, _, mapID = SafeGetInstanceInfo(); return tostring(mapID or "") end
resolvers["instance-lfgid"] = function() local _, _, _, _, _, _, _, _, lfgID = SafeGetInstanceInfo(); return tostring(lfgID or "") end

resolvers.groupType = function()
    if IsInRaid and IsInRaid() then return "raid" end
    if IsInGroup and IsInGroup() then return "party" end
    return "solo"
end
resolvers["group-type"] = resolvers.groupType

resolvers.groupSize = function()
    local n = 1
    if GetNumGroupMembers then
        n = GetNumGroupMembers()
        if n <= 0 then n = 1 end
    end
    return n
end
resolvers["group-size"] = function(ctx) return tostring(ctx.groupSize) end
resolvers["party-size"] = resolvers["group-size"]

resolvers["is-raid"] = function() return (IsInRaid and IsInRaid()) and "true" or "false" end
resolvers["is-party"] = function() return ((IsInGroup and IsInGroup()) and not (IsInRaid and IsInRaid())) and "true" or "false" end

-- Time
resolvers.time = function() return (date and date("%H:%M")) or "" end
resolvers.date = function() return (date and date("%Y-%m-%d")) or "" end
resolvers.weekday = function() return (date and date("%A")) or "" end

-- Spell (relies on _spellID being set in ctx)
resolvers.spell = function(ctx)
    if ctx._spellID then
        return addon:GetSpellName(ctx._spellID) or tostring(ctx._spellID)
    end
    return ""
end

-- Affixes (Mythic+)
local function GetAffixesCached(ctx)
    if ctx and ctx._affixes ~= nil then
        return ctx._affixes
    end
    local names = {}
    if C_MythicPlus and C_MythicPlus.GetCurrentAffixes then
         local affixes = C_MythicPlus.GetCurrentAffixes() or {}
         for _, aff in ipairs(affixes) do
            if type(aff) == "table" and aff.name then 
                ---@diagnostic disable-next-line: undefined-field
                table.insert(names, aff.name) 
            end
         end
    end
    if ctx then
        ctx._affixes = names
    end
    return names
end

resolvers.affixes = function(ctx) return table.concat(GetAffixesCached(ctx), ", ") end
resolvers["affix-1"] = function(ctx) local a = GetAffixesCached(ctx); return a[1] or "" end
resolvers["affix-2"] = function(ctx) local a = GetAffixesCached(ctx); return a[2] or "" end
resolvers["affix-3"] = function(ctx) local a = GetAffixesCached(ctx); return a[3] or "" end
resolvers["affix-4"] = function(ctx) local a = GetAffixesCached(ctx); return a[4] or "" end

resolvers.keystoneMapID = function()
    if C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo then
        local mapID = C_ChallengeMode.GetActiveKeystoneInfo()
        if mapID then return tostring(mapID) end
    end
    return ""
end
resolvers["keystone-mapid"] = resolvers.keystoneMapID

resolvers["keystone-level"] = function()
    if C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo then
        local _, level = C_ChallengeMode.GetActiveKeystoneInfo()
        if level then return tostring(level) end
    end
    return ""
end


-- ========================================
-- Context Factory
-- ========================================

function addon:MakeContext(spellID, extraData)
  local ctx = {
    _spellID = spellID
  }
  
  -- Merge extraData immediately (overrides resolvers)
  if extraData then
    for k, v in pairs(extraData) do
      ctx[k] = v
    end
  end

  setmetatable(ctx, {
    __index = function(t, k)
      -- Check resolvers
      local r = resolvers[k]
      if r then
        local v = r(t) -- pass table as self
        rawset(t, k, v) -- cache result
        return v
      end
      return nil
    end
  })
  
  return ctx
end

-- ========================================
-- Substitution Engine
-- ========================================

local function EscapeSubValue(value)
    return tostring(value or ""):gsub("%%", "%%%%")
end

function addon:ApplySubs(template, ctx)
  if type(template) ~= "string" then return "" end
  ctx = ctx or {}

  local out = template

  -- <pick:a|b|c> - random selection
  out = out:gsub("<pick:([^>]+)>", function(body)
    local opts = {}
    for part in string.gmatch(body, "[^|]+") do
      part = addon:TrimString(part)
      if part ~= "" then table.insert(opts, part) end
    end
    return addon:RandomFrom(opts) or ""
  end)

  -- <rng:1-100> - random number
  out = out:gsub("<rng:(%d+)%-(%d+)>", function(a, b)
    local lo = tonumber(a) or 0
    local hi = tonumber(b) or lo
    if hi < lo then lo, hi = hi, lo end
    return tostring(math.random(lo, hi))
  end)

  -- General token substitution
  -- We now use the lazy context directly
  out = out:gsub("<([^>]+)>", function(token)
    local val = ctx[token]
    if val ~= nil then
       return EscapeSubValue(val)
    end
    return "<" .. token .. ">"
  end)

  return out
end

-- ========================================
-- Performance Utils
-- ========================================

-- Cached Spell Known Check
do
  local checkSpell
  -- Detect best API once
  if C_Spell and C_Spell.IsSpellKnownOrOverridesKnown then
    checkSpell = C_Spell.IsSpellKnownOrOverridesKnown
  elseif C_Spell and C_Spell.IsSpellKnown then
    checkSpell = C_Spell.IsSpellKnown
  else
    checkSpell = IsSpellKnownOrOverridesKnown or IsSpellKnown or IsPlayerSpell
  end

  local spellCache = {}
  local f = CreateFrame("Frame")
  f:RegisterEvent("SPELLS_CHANGED")
  f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
  f:SetScript("OnEvent", function() 
      table.wipe(spellCache) 
  end)

  function addon:IsSpellKnownByPlayer(spellID)
     if type(spellID) ~= "number" then return false end
     
     local cached = spellCache[spellID]
     if cached ~= nil then return cached end
     
     local known = false
     if checkSpell then
         local ok, res = pcall(checkSpell, spellID)
         if ok and res then known = true end
     end
     
     spellCache[spellID] = known
     return known
  end
end
