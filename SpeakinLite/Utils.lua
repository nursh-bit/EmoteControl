-- SpeakinLite - Shared Utility Functions
-- This file must be loaded first (see .toc file)

SpeakinLite = SpeakinLite or {}
local addon = SpeakinLite

-- String utilities
function addon:SafeLower(s)
  if type(s) ~= "string" then return nil end
  return string.lower(s)
end

-- Number utilities
function addon:ClampNumber(n, lo, hi)
  if type(n) ~= "number" then return lo end
  if n < lo then return lo end
  if n > hi then return hi end
  return n
end

-- Channel utilities
function addon:NormalizeChannel(s)
  if type(s) ~= "string" then return nil end
  s = self:SafeLower(s)
  if not s then return nil end
  
  if s == "self" or s == "local" or s == "me" then return "SELF" end
  if s == "say" then return "SAY" end
  if s == "yell" then return "YELL" end
  if s == "emote" or s == "e" then return "EMOTE" end
  if s == "party" or s == "p" then return "PARTY" end
  if s == "raid" or s == "r" then return "RAID" end
  if s == "instance" or s == "i" then return "INSTANCE" end
  
  return nil
end

-- Chat output utility
function addon:Print(msg)
  if msg == nil then return end
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99SpeakinLite|r: " .. tostring(msg))
  end
end

-- Database accessor
function addon:GetDB()
  return self.db or rawget(_G, "SpeakinLiteDB")
end

-- Random selection from list
function addon:RandomFrom(list)
  if type(list) ~= "table" then return nil end
  local n = #list
  if n <= 0 then return nil end
  return list[math.random(n)]
end

-- Player info utilities
function addon:GetPlayerClass()
  local _, classFile = UnitClass("player")
  return classFile or ""
end

function addon:GetPlayerRaceFile()
  local _, raceFile = UnitRace("player")
  return raceFile or ""
end

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
