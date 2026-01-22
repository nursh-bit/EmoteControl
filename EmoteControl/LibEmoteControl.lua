-- LibEmoteControl.lua
-- Core EmoteControl library for pack developers
-- Provides the public API for registering and managing trigger packs

local ADDON_NAME = ...
local lib = _G.LibEmoteControl or {}
_G.LibEmoteControl = lib

lib.version = "1.0"

-- ============================================================================
-- PACK REGISTRATION API
-- ============================================================================

--- Register a new trigger pack with EmoteControl
-- @param pack Table containing pack definition:
--   - id: string, unique pack identifier (auto-generated if not provided)
--   - name: string, human-readable pack name
--   - author: string, pack author name
--   - description: string, pack description
--   - triggers: table, array of trigger definitions
-- @return boolean true if pack was successfully registered
function lib:RegisterPack(pack)
  if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
    return false
  end
  return EmoteControl:RegisterPack(pack)
end

-- ============================================================================
-- TRIGGER DEFINITION HELPERS
-- ============================================================================

--- Create a spell trigger definition
-- @param spellID number or string, spell ID or name
-- @param messages table, array of message strings
-- @param options table, optional trigger configuration
-- @return table trigger definition
function lib:CreateSpellTrigger(spellID, messages, options)
  local trigger = {
    event = "UNIT_SPELLCAST_SUCCEEDED",
    spellID = spellID,
    messages = messages or {},
  }
  
  if type(options) == "table" then
    for k, v in pairs(options) do
      trigger[k] = v
    end
  end
  
  return trigger
end

--- Create a non-spell trigger definition
-- @param event string, WoW event name
-- @param messages table, array of message strings
-- @param options table, optional trigger configuration
-- @return table trigger definition
function lib:CreateTrigger(event, messages, options)
  local trigger = {
    event = event,
    messages = messages or {},
  }
  
  if type(options) == "table" then
    for k, v in pairs(options) do
      trigger[k] = v
    end
  end
  
  return trigger
end

-- ============================================================================
-- CONDITION HELPERS
-- ============================================================================

--- Create a condition for filtering triggers
-- @param field string, condition field name
-- @param value any, condition value
-- @return table condition table
function lib:CreateCondition(field, value)
  return { [field] = value }
end

--- Combine multiple conditions (AND logic)
-- @param ... conditions to combine
-- @return table combined condition table
function lib:CombineConditions(...)
  local combined = {}
  for i = 1, select("#", ...) do
    local cond = select(i, ...)
    if type(cond) == "table" then
      for k, v in pairs(cond) do
        combined[k] = v
      end
    end
  end
  return combined
end

-- ============================================================================
-- MESSAGE TEMPLATE HELPERS
-- ============================================================================

--- Create a message template with random selection
-- Example: lib:Pick("Hello", "Hi", "Greetings") -> <pick:Hello|Hi|Greetings>
-- @param ... strings to choose from randomly
-- @return string message template with pick syntax
function lib:Pick(...)
  local parts = {}
  for i = 1, select("#", ...) do
    table.insert(parts, tostring(select(i, ...)))
  end
  return "<pick:" .. table.concat(parts, "|") .. ">"
end

--- Create a message template with random number range
-- Example: lib:RandomNum(1, 100) -> <rng:1-100>
-- @param min number, minimum value
-- @param max number, maximum value
-- @return string message template with rng syntax
function lib:RandomNum(min, max)
  return "<rng:" .. tonumber(min) .. "-" .. tonumber(max) .. ">"
end

-- ============================================================================
-- UTILITY FUNCTIONS FOR PACKS
-- ============================================================================

--- Get the current database reference
-- @return table the EmoteControl database
function lib:GetDB()
  if not EmoteControl or type(EmoteControl.GetDB) ~= "function" then
    return nil
  end
  return EmoteControl:GetDB()
end

--- Check if a specific pack is enabled
-- @param packId string, pack identifier
-- @return boolean true if pack is enabled
function lib:IsPackEnabled(packId)
  if not EmoteControl or type(EmoteControl.IsPackEnabled) ~= "function" then
    return true
  end
  return EmoteControl:IsPackEnabled(packId)
end

--- Log a message from the pack
-- @param msg string, message to log
function lib:Print(msg)
  if not EmoteControl or type(EmoteControl.Print) ~= "function" then
    print("[EmoteControl] " .. tostring(msg))
    return
  end
  EmoteControl:Print(msg)
end

-- Return the library for chaining
return lib
