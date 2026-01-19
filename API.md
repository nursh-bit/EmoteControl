-- EMOTECONTROL PUBLIC API DOCUMENTATION

## Core API Functions

### Initialization & Status

```lua
EmoteControl:GetDB()
-- Returns the current database table
-- Returns: table or nil

EmoteControl:GetVersion()
-- Returns current addon version
-- Returns: string (e.g., "0.9.5")

EmoteControl:IsEnabled()
-- Check if addon is globally enabled
-- Returns: boolean
```

### Pack Management

```lua
EmoteControl:RegisterPack(pack)
-- Register a new trigger pack
-- pack.id: string (auto-generated if not provided)
-- pack.name: string
-- pack.description: string
-- pack.triggers: table of trigger definitions
-- Returns: boolean

EmoteControl:IsPackEnabled(packId)
-- Check if a pack is enabled by user
-- Returns: boolean

EmoteControl:GetPacks()
-- Get all registered packs
-- Returns: table {id = pack, ...}
```

### Trigger Management

```lua
EmoteControl:GetTriggerById(triggerId)
-- Get a specific trigger by ID
-- Returns: table trigger or nil

EmoteControl:GetTriggersByEvent(event)
-- Get all triggers for an event
-- Returns: table of triggers

EmoteControl:ShouldTriggerBeActive(trigger)
-- Check if trigger should be evaluated
-- Returns: boolean

EmoteControl:TriggerCooldownOk(trigger)
-- Check if trigger cooldown has elapsed
-- Returns: boolean

EmoteControl:ExecuteTrigger(trigger, context)
-- Execute a trigger and send its message
-- Returns: boolean success
```

### Message Processing

```lua
EmoteControl:ApplySubs(template, context)
-- Apply token substitutions to a message template
-- template: string with tokens like <player>, <spell>, etc
-- context: table with token values
-- Returns: string with substitutions applied

EmoteControl:MakeContext(unit, extra)
-- Create a context table for message substitution
-- unit: unit ID or nil
-- extra: additional context data
-- Returns: table context

EmoteControl:Output(msg, channel)
-- Output a message to the specified channel
-- msg: string message to send
-- channel: "SELF", "SAY", "EMOTE", "PARTY", "RAID", etc
-- Returns: nil
```

### Spell Utilities

```lua
EmoteControl:ResolveSpellID(identifier)
-- Convert spell name or ID to spell ID number
-- identifier: number or string
-- Returns: number spellID or nil

EmoteControl:GetSpellName(spellID)
-- Get spell name from spell ID
-- spellID: number
-- Returns: string name or nil

EmoteControl:IsSpellKnownByPlayer(spellID)
-- Check if player knows a specific spell
-- spellID: number
-- Returns: boolean
```

### Utility Functions

```lua
EmoteControl:SafeLower(string)
-- Safely convert string to lowercase
-- Returns: string or nil

EmoteControl:TrimString(string)
-- Remove leading and trailing whitespace
-- Returns: string

EmoteControl:ClampNumber(number, min, max)
-- Clamp a number between min and max
-- Returns: number

EmoteControl:RandomFrom(table)
-- Get random element from table
-- Returns: any or nil

EmoteControl:NormalizeChannel(string)
-- Convert channel alias to standard name
-- Supports: self, say, yell, emote, party, raid, instance
-- Returns: string or nil

EmoteControl:ShallowCopy(table)
-- Create a shallow copy of a table
-- Returns: table
```

### Statistics

```lua
EmoteControl:RecordTriggerStat(trigger, message)
-- Record usage statistics for a trigger
-- Returns: nil

EmoteControl:GetStats()
-- Get all usage statistics
-- Returns: table with stats data or nil

EmoteControl:ResetStats()
-- Clear all statistics
-- Returns: nil

EmoteControl:ShowStats()
-- Display statistics in chat
-- Returns: nil
```

### Player Information

```lua
EmoteControl:GetPlayerClass()
-- Get player class (e.g., "WARRIOR")
-- Returns: string

EmoteControl:GetPlayerRaceFile()
-- Get player race (e.g., "Human")
-- Returns: string

EmoteControl:GetSpecInfo()
-- Get current specialization info
-- Returns: specID (number), specName (string)

EmoteControl:GetZone()
-- Get current zone name
-- Returns: string

EmoteControl:GetInstanceType()
-- Get instance type if in instance
-- Returns: inInstance (boolean), instanceType (string)
```

### Settings & Overrides

```lua
EmoteControl:GetTriggerOverride(triggerId)
-- Get per-trigger override settings
-- Returns: table override or nil

EmoteControl:GetTriggerMessages(trigger)
-- Get effective messages considering overrides and moods
-- Returns: table of message strings

EmoteControl:GetTriggerChannel(trigger)
-- Get effective channel considering overrides
-- Returns: string channel or nil

EmoteControl:ApplyRecommendedDefaults(db)
-- Apply recommended default settings
-- Returns: nil

EmoteControl:ApplyMigrations(db)
-- Apply database migrations for version updates
-- Returns: nil
```

## LibEmoteControl (Pack Developer API)

```lua
LibEmoteControl:RegisterPack(pack)
-- Register a trigger pack
-- Returns: boolean

LibEmoteControl:CreateSpellTrigger(spellID, messages, options)
-- Helper to create a spell trigger
-- Returns: table trigger definition

LibEmoteControl:CreateTrigger(event, messages, options)
-- Helper to create a trigger
-- Returns: table trigger definition

LibEmoteControl:CreateCondition(field, value)
-- Helper to create a condition
-- Returns: table condition

LibEmoteControl:CombineConditions(...)
-- Combine multiple conditions
-- Returns: table combined condition

LibEmoteControl:Pick(...)
-- Create a pick template
-- Usage: LibEmoteControl:Pick("Hello", "Hi") -> "<pick:Hello|Hi>"
-- Returns: string template

LibEmoteControl:RandomNum(min, max)
-- Create a random number template
-- Usage: LibEmoteControl:RandomNum(1, 100) -> "<rng:1-100>"
-- Returns: string template

LibEmoteControl:GetDB()
-- Get the database
-- Returns: table or nil

LibEmoteControl:IsPackEnabled(packId)
-- Check if pack is enabled
-- Returns: boolean

LibEmoteControl:Print(msg)
-- Log a message
-- Returns: nil
```

## Trigger Definition Structure

```lua
local trigger = {
  -- Identification
  id = "unique_trigger_id",
  name = "Display Name",
  description = "What this trigger does",
  
  -- Event & Conditions
  event = "UNIT_SPELLCAST_SUCCEEDED",  -- Required
  spellID = 12345,  -- For spell triggers
  
  -- Messaging
  messages = {"Hello!", "Hi there!"},
  messagesByMood = {
    default = {"Hello!"},
    aggressive = {"Grr!"}
  },
  
  -- Configuration
  cooldown = 10,  -- Seconds between triggers
  channel = "EMOTE",  -- Output channel
  category = "rotation",  -- Pack category
  enabled = true,
  
  -- Conditions for filtering
  class = "WARRIOR",  -- Only trigger for Warriors
  race = "Human",
  specID = 71,
  inInstance = true,
  requiresTarget = true,
  randomChance = 50,  -- 50% chance
  
  -- Pack reference
  packName = "Pack Name",
  packId = "pack_id"
}
```

## Context Data Structure

```lua
local context = {
  -- Player info
  player = "PlayerName",
  class = "WARRIOR",
  race = "Human",
  spec = "Protection",
  level = 70,
  guild = "Guild Name",
  zone = "Valdrakken",
  instanceType = "raid",
  
  -- Health info
  health = 25000,
  healthMax = 35000,
  healthPct = "71%",
  
  -- Power info (mana, energy, rage, etc)
  power = 500,
  powerMax = 1000,
  powerPct = "50%",
  powerName = "Rage",
  combo = 5,
  
  -- Target info
  target = "Target Name",
  targetHealthPct = "45%",
  
  -- Spell/Item info
  spell = "Spell Name",
  item = "Item Name",
  itemLink = "|cff...|h...|h|r",
  quality = "Legendary",
  
  -- Achievement info
  achievement = "Achievement Name"
}
```

## Database Structure (SavedVariables)

```lua
EmoteControlDB = {
  version = 2,
  
  -- User settings
  enabled = true,
  channel = "EMOTE",
  fallbackToSelf = true,
  globalCooldown = 6,
  rotationProtection = "MEDIUM",
  maxPerMinute = 8,
  moodProfile = "default",
  
  -- Event toggles
  enableSpellTriggers = true,
  enableNonSpellTriggers = true,
  enableCombatLogTriggers = false,
  enableLootTriggers = true,
  enableAchievementTriggers = true,
  enableLevelUpTriggers = true,
  onlyLearnedSpells = true,
  
  -- Pack management
  packEnabled = {
    pack_id = true,
    another_pack = false
  },
  
  -- Per-trigger overrides
  triggerOverrides = {
    ["trigger:id"] = {
      enabled = false,
      cooldown = 20,
      channel = "SAY",
      messages = {"Custom message"}
    }
  },
  
  -- Category toggles
  categoriesEnabled = {
    rotation = true,
    flavor = false
  },
  
  -- Statistics
  stats = {
    triggers = {
      ["trigger:id"] = {
        count = 42,
        firstFired = 1234567890,
        lastFired = 1234567999,
        category = "rotation",
        packName = "Pack Name"
      }
    },
    session = {
      ["trigger:id"] = 3
    },
    totalMessages = 150,
    sessionMessages = 5
  }
}
```

## Constants

```lua
EmoteControl.ROTATION_PROTECTION = {
  OFF = 0,
  LOW = 12,
  MEDIUM = 6,
  HIGH = 2
}

EmoteControl.VERSION = "0.9.5"
EmoteControl.DB_VERSION = 2
```

## Event Hooks

Events you can listen to on the addon's frame:

```lua
-- None currently exposed, but you can register with:
frame:RegisterEvent("EVENT_NAME")
frame:SetScript("OnEvent", function(self, event, ...) end)
```

## Slash Commands

User-facing commands:

```
/sl help - Show help
/sl options - Open main options
/sl packs - Open pack selection
/sl editor - Open trigger editor
/sl stats - Show usage statistics
/sl defaults - Apply recommended settings
/sl import - Import configuration
/sl export - Export configuration
```

## Best Practices for Pack Development

1. **Use descriptive IDs**: Pack IDs should be lowercase with underscores
2. **Provide context**: Include helpful descriptions and names
3. **Handle edge cases**: Check for nil values and invalid data
4. **Performance**: Minimize expensive operations in message templates
5. **Backward compatibility**: Test with different WoW versions
6. **Documentation**: Document any custom tokens or special conditions
