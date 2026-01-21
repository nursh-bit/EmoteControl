-- EmoteControl - Shared Utility Functions
-- Core utilities for string, number, table, and player info handling.
-- This file is loaded first according to the .toc file

EmoteControl = EmoteControl or {}
SpeakinLite = EmoteControl  -- Backward compatibility alias
local addon = EmoteControl

-- String utilities
function addon:SafeLower(s)
  if type(s) ~= "string" then return nil end
  return string.lower(s)
end

-- Safe string trimming utility
function addon:TrimString(s)
  if type(s) ~= "string" then return "" end
  return s:gsub("^%s+", ""):gsub("%s+$", "")
end

-- Number utilities
function addon:ClampNumber(n, lo, hi)
  if type(n) ~= "number" then return lo end
  if n < lo then return lo end
  if n > hi then return hi end
  return n
end

-- Channel utilities - normalize user input to standard channel names
function addon:NormalizeChannel(s)
  if type(s) ~= "string" then return nil end
  s = self:SafeLower(s)
  if not s then return nil end
  
  -- Create a map for channel aliases
  local channels = {
    self = "SELF", local_ = "SELF", me = "SELF", 
    auto = "AUTO", smart = "AUTO",
    say = "SAY", 
    yell = "YELL", 
    emote = "EMOTE", e = "EMOTE", 
    party = "PARTY", p = "PARTY", 
    raid = "RAID", r = "RAID", 
    instance = "INSTANCE", i = "INSTANCE",
  }
  
  -- Handle local as a reserved word
  if s == "local" then s = "local_" end
  
  return channels[s]
end

-- Chat output utility
function addon:Print(msg)
  if msg == nil then return end
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99EmoteControl|r: " .. tostring(msg))
  end
end

-- Database accessor
function addon:GetDB()
  return self.db
    or rawget(_G, "EmoteControlDB")
    or rawget(_G, "SpeakinLiteDB")
end

-- Random selection from list
function addon:RandomFrom(list)
  if type(list) ~= "table" then return nil end
  local n = #list
  if n <= 0 then return nil end
  return list[math.random(n)]
end

-- Player info utilities with fallback and safety checks
function addon:GetPlayerClass()
  local _, classFile = UnitClass("player")
  return classFile or ""
end

function addon:GetPlayerRaceFile()
  local _, raceFile = UnitRace("player")
  return raceFile or ""
end

-- Get current specialization info with multiple fallback paths
function addon:GetSpecInfo()
  if type(GetSpecialization) ~= "function" or type(GetSpecializationInfo) ~= "function" then
    return nil, ""
  end
  local specIndex = GetSpecialization()
  if not specIndex then return nil, "" end
  local id, name = GetSpecializationInfo(specIndex)
  return id, (type(name) == "string" and name or "")
end

function addon:GetZone()
  return GetZoneText() or ""
end

-- Determine instance type with clear return values
function addon:GetInstanceType()
  local inInst, instType = IsInInstance()
  return inInst, (instType or "")
end

-- Table utilities
function addon:ShallowCopy(src)
  if type(src) ~= "table" then return {} end
  local dst = {}
  for k, v in pairs(src) do
    dst[k] = v
  end
  return dst
end

function addon:MergeInto(dst, src)
  if type(dst) ~= "table" or type(src) ~= "table" then return dst end
  for k, v in pairs(src) do
    if dst[k] == nil then
      dst[k] = v
    end
  end
  return dst
end

-- Constants
addon.ROTATION_PROTECTION = {
  OFF = 0,
  LOW = 12,
  MEDIUM = 6,
  HIGH = 2
}
