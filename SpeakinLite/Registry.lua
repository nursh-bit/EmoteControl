-- EmoteControl - Pack Registry and Trigger Index
-- Packs are separate LoadOnDemand addons that call EmoteControl:RegisterPack({...}).

EmoteControl = EmoteControl or SpeakinLite or {}
SpeakinLite = EmoteControl
local addon = EmoteControl

addon.Packs = addon.Packs or {}
addon.TriggersByEvent = addon.TriggersByEvent or {}
addon.EventsToRegister = addon.EventsToRegister or {}
addon.TriggerById = addon.TriggerById or {}
addon._spellIdCache = addon._spellIdCache or {}
addon._spellNameCache = addon._spellNameCache or {}

function addon:IsPackEnabled(packId)
  if type(packId) ~= "string" or packId == "" then return true end
  local theDb = rawget(_G, "EmoteControlDB") or rawget(_G, "SpeakinLiteDB")
  if type(theDb) ~= "table" then return true end
  local pe = theDb.packEnabled
  if type(pe) ~= "table" then return true end
  local v = pe[packId]
  if v == nil then return true end
  return v == true
end

function addon:RegisterPack(pack)
  if type(pack) ~= "table" then return end
  if type(pack.id) ~= "string" or pack.id == "" then
    if type(pack.name) == "string" and pack.name ~= "" then
      local fallback = addon:SafeLower(pack.name) or ""
      fallback = fallback:gsub("%s+", ""):gsub("[^%w_]", "")
      if fallback ~= "" then
        pack.id = fallback
      else
        return
      end
    else
      return
    end
  end
  if type(pack.triggers) ~= "table" then pack.triggers = {} end
  addon.Packs[pack.id] = pack
end

local function ResolveSpellIDFromCSpell(spellIdentifier)
  if not (C_Spell and type(C_Spell.GetSpellIDForSpellIdentifier) == "function") then return nil end
  local ok, id = pcall(C_Spell.GetSpellIDForSpellIdentifier, spellIdentifier)
  if ok and type(id) == "number" then return id end
  return nil
end

local function ResolveSpellIDFromGetSpellInfo(spellIdentifier)
  if type(GetSpellInfo) ~= "function" then return nil end
  local ok, a, b, c, d, e, f, spellID = pcall(GetSpellInfo, spellIdentifier)
  if ok and type(spellID) == "number" then return spellID end
  if ok and type(f) == "number" then return f end
  return nil
end

local function ResolveSpellNameFromID(spellID)
  if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
    local ok, info = pcall(C_Spell.GetSpellInfo, spellID)
    if ok and type(info) == "table" and type(info.name) == "string" then
      return info.name
    end
  end
  if type(GetSpellInfo) == "function" then
    local ok, name = pcall(GetSpellInfo, spellID)
    if ok and type(name) == "string" then return name end
  end
  return nil
end

function addon:ResolveSpellID(spellIdentifier)
  if type(spellIdentifier) == "number" then return spellIdentifier end
  if type(spellIdentifier) ~= "string" then return nil end

  local key = addon:SafeLower(spellIdentifier)
  if key and addon._spellIdCache[key] then
    return addon._spellIdCache[key]
  end

  local id = ResolveSpellIDFromCSpell(spellIdentifier)
  if not id then
    id = ResolveSpellIDFromGetSpellInfo(spellIdentifier)
  end

  if type(id) == "number" and id > 0 and key then
    addon._spellIdCache[key] = id
  end

  return id
end

function addon:GetSpellName(spellID)
  if type(spellID) ~= "number" then return nil end
  
  -- Check cache first
  if addon._spellNameCache[spellID] then
    return addon._spellNameCache[spellID]
  end
  
  -- Resolve and cache
  local name = ResolveSpellNameFromID(spellID)
  if type(name) == "string" then
    addon._spellNameCache[spellID] = name
  end
  
  return name
end

local function NamespaceId(packId, trigId)
  if type(trigId) ~= "string" or trigId == "" then return nil end
  if string.find(trigId, ":", 1, true) then return trigId end
  return packId .. ":" .. trigId
end

local CONDITION_KEYS = {
  class = true,
  race = true,
  specID = true,
  unit = true,
  inInstance = true,
  instanceType = true,
  requiresTarget = true,
  targetType = true,
  spellID = true,
  spellName = true,
  spell = true,
  -- Extended conditions
  randomChance = true,
  inCombat = true,
  inGroup = true,
  groupSize = true,
  hasAura = true,
  targetIsBoss = true,
  healthBelow = true,
  healthAbove = true,
  quality = true,
}

local function DefaultsToConditions(defaults)
  local cond = {}
  if type(defaults) ~= "table" then return cond end
  if type(defaults.conditions) == "table" then
    for k, v in pairs(defaults.conditions) do
      cond[k] = v
    end
  end
  for k, _ in pairs(CONDITION_KEYS) do
    if defaults[k] ~= nil and cond[k] == nil then
      cond[k] = defaults[k]
    end
  end
  return cond
end

function addon:BuildTriggerIndex()
  addon.TriggersByEvent = {}
  addon.EventsToRegister = {}
  addon.TriggerById = {}

  for packId, pack in pairs(addon.Packs) do
    if addon:IsPackEnabled(packId) then
      local defaults = pack.defaults
      local defaultCond = DefaultsToConditions(defaults)

      for idx, trig in ipairs(pack.triggers or {}) do
        if type(trig) == "table" and type(trig.event) == "string" and type(trig.messages) == "table" and #trig.messages > 0 then
          local t = addon:ShallowCopy(trig)

          local rawId = t.id
          if type(rawId) ~= "string" or rawId == "" then
            rawId = tostring(idx)
          end
          t.id = NamespaceId(packId, rawId) or (packId .. ":" .. tostring(idx))

          t.packId = packId
          t.lastFired = 0

          -- Merge pack defaults into trigger (only where missing)
          if type(defaults) == "table" then
            if t.cooldown == nil then t.cooldown = defaults.cooldown end
            if t.channel == nil then t.channel = defaults.channel end
            if t.category == nil then t.category = defaults.category end
            if t.intensity == nil then t.intensity = defaults.intensity end
          end

          -- Merge conditions
          t.conditions = addon:ShallowCopy(defaultCond)
          if type(trig.conditions) == "table" then
            for k, v in pairs(trig.conditions) do
              t.conditions[k] = v
            end
          end

          -- Pre-resolve spell gating
          local cond = t.conditions or {}
          local spellID = cond.spellID
          local spellName = cond.spellName or cond.spell
          if not spellID and spellName then
            spellID = addon:ResolveSpellID(spellName)
          end
          t._spellID = spellID
          t._spellNameLower = addon:SafeLower(spellName)

          local bucket = addon.TriggersByEvent[t.event]
          if not bucket then
            bucket = { list = {}, bySpellID = {} }
            addon.TriggersByEvent[t.event] = bucket
          end

          if t._spellID then
            bucket.bySpellID[t._spellID] = bucket.bySpellID[t._spellID] or {}
            table.insert(bucket.bySpellID[t._spellID], t)
          else
            table.insert(bucket.list, t)
          end

          addon.EventsToRegister[t.event] = true
          addon.TriggerById[t.id] = t
        end
      end
    end
  end
end
