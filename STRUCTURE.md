-- EmoteControl Structure Overview and Documentation

## Project Structure

```
EmoteControl/
├── SpeakinLite/                 (Main addon folder)
│   ├── SpeakinLite.toc         (Addon manifest)
│   ├── Core.lua                 (Main event engine and triggers)
│   ├── Utils.lua                (Utility functions - loaded first)
│   ├── Registry.lua             (Pack management and trigger indexing)
│   ├── LibEmoteControl.lua      (Pack developer API)
│   ├── Settings.lua             (Settings UI panel)
│   ├── Options.lua              (Legacy options interface)
│   ├── Editor.lua               (Per-trigger editor UI)
│   ├── ImportExport.lua         (Configuration sharing)
│   └── TriggerBuilder.lua       (Visual trigger creation tool)
│
├── SpeakinLite_Pack_*           (Phrase packs - 41 total)
│   ├── SpeakinLite_Pack_*.toc
│   └── Pack.lua
│
├── CHANGELOG.md
└── FEATURES.md
```

## Module Responsibilities

### Core.lua
- Main event frame and listener
- Trigger evaluation and execution
- Message output and channel management
- Rate limiting and cooldown logic
- Statistics tracking

### Utils.lua (Load First)
- String utilities (SafeLower, TrimString)
- Number utilities (ClampNumber)
- Channel normalization
- Player info queries (class, race, zone, spec)
- Table utilities (ShallowCopy)

### Registry.lua
- Manages registered trigger packs
- Spell ID/name caching and resolution
- Trigger indexing by event
- Pack enable/disable status
- Condition validation

### LibEmoteControl.lua (Pack Developer API)
- RegisterPack() for pack registration
- CreateSpellTrigger() helper
- CreateTrigger() helper
- Condition builder functions
- Message template helpers (Pick, RandomNum)
- Utility functions for pack developers

### Settings.lua & Options.lua
- User configuration interface
- Channel, cooldown, and rate limit settings
- Event toggle controls
- Category management
- Pack selection UI

### Editor.lua
- Per-trigger customization interface
- Override cooldown, channel, messages
- Enable/disable individual triggers
- Visual trigger browsing

### ImportExport.lua
- Export trigger configurations
- Import shared configurations
- Base64 encoding/decoding
- Configuration backup/restore

### TriggerBuilder.lua
- Visual trigger creation
- Form-based trigger definition
- Condition builder interface
- Event type selection

## Key Design Patterns

### 1. Namespace Management
```lua
EmoteControl = EmoteControl or {}
SpeakinLite = EmoteControl  -- Backward compatibility
local addon = EmoteControl
```

### 2. Database Access
```lua
local db = addon:GetDB()
if not db then return end
```

### 3. Trigger Evaluation
```lua
if addon:ShouldTriggerBeActive(trigger) and 
   addon:TriggerCooldownOk(trigger) then
  -- Execute trigger
end
```

### 4. Message Substitution
```lua
local ctx = addon:MakeContext(...)
local msg = addon:ApplySubs(template, ctx)
```

### 5. Pack Registration
```lua
EmoteControl:RegisterPack({
  id = "my_pack",
  name = "My Pack",
  triggers = { ... }
})
```

## API for Pack Developers

### LibEmoteControl Public API

```lua
-- Register a pack
LibEmoteControl:RegisterPack(pack)

-- Create triggers
LibEmoteControl:CreateSpellTrigger(spellID, messages, options)
LibEmoteControl:CreateTrigger(event, messages, options)

-- Build conditions
LibEmoteControl:CreateCondition(field, value)
LibEmoteControl:CombineConditions(cond1, cond2, ...)

-- Message templates
LibEmoteControl:Pick("option1", "option2", ...)
LibEmoteControl:RandomNum(min, max)

-- Utilities
LibEmoteControl:GetDB()
LibEmoteControl:IsPackEnabled(packId)
LibEmoteControl:Print(msg)
```

## Message Template Syntax

### Available Tokens
- `<player>` - Character name
- `<spell>` - Spell name
- `<target>` - Target name
- `<zone>` - Current zone
- `<spec>` - Current specialization
- `<class>` - Character class
- `<race>` - Character race
- `<level>` - Character level
- `<health>`, `<health%%>`, `<healthmax>`
- `<power>`, `<power%%>`, `<powermax>`, `<powername>`
- `<combo>` - Combo points
- `<target-health%%>` - Target health %
- `<guild>` - Guild name
- `<achievement>` - Achievement name
- `<item>`, `<itemlink>` - Item info
- `<quality>` - Item quality

### Dynamic Content
- `<pick:option1|option2|option3>` - Random selection
- `<rng:1-100>` - Random number in range

## Trigger Event Types

### Spell Events
- `UNIT_SPELLCAST_SUCCEEDED` - When a spell is cast
- `UNIT_SPELLCAST_FAILED` - When a spell fails

### Combat Events
- `COMBAT_CRITICAL_HIT` - Critical damage dealt
- `COMBAT_DODGED` - Attack dodged
- `COMBAT_PARRIED` - Attack parried
- `COMBAT_INTERRUPTED` - Spell interrupted

### Player Events
- `PLAYER_LEVEL_UP` - Level increased
- `PLAYER_DEAD` - Character dies
- `PLAYER_UNGHOST` - Released from ghost form

### Loot Events
- `LOOT_ITEM_PUSHED_INTO_CONTAINERS` - Item looted

### Achievement Events
- `ACHIEVEMENT_EARNED` - Achievement completed

### UI Events
- `BAG_FULL` - Inventory full
- `REPAIR_NEEDED` - Equipment durability low

## Condition Fields

- `class` - Character class
- `race` - Character race
- `specID` - Specialization ID
- `unit` - Event target unit (player, pet, etc.)
- `inInstance` - Inside instance
- `instanceType` - Instance type (raid, dungeon, etc.)
- `requiresTarget` - Requires valid target
- `targetType` - Type of target
- `spellID` - Spell ID
- `spellName` - Spell name
- `randomChance` - Percent chance (0-100)
- `inCombat` - In combat
- `inGroup` - In group/raid
- `groupSize` - Group size requirement
- `hasAura` - Has specific aura

## Configuration Storage

### SavedVariables
- `EmoteControlDB` - Main configuration database
  - User settings
  - Pack enable/disable status
  - Trigger overrides
  - Statistics

## File Load Order (from .toc)

1. Utils.lua - Utilities (must be first)
2. Registry.lua - Pack/trigger management
3. Core.lua - Main engine
4. ImportExport.lua - Configuration sharing
5. TriggerBuilder.lua - Trigger builder UI
6. Settings.lua - Settings UI
7. Options.lua - Options UI
8. Editor.lua - Per-trigger editor

## Backward Compatibility

The addon maintains backward compatibility with the "SpeakinLite" name:
- SavedVariables supports both `EmoteControlDB` and `SpeakinLiteDB`
- Namespace aliases (`SpeakinLite = EmoteControl`) maintained in all modules
- Existing packs continue to work without modification

## Contributing to the Project

When adding new features:
1. Add new methods to the appropriate module
2. Update LibEmoteControl.lua if adding pack developer features
3. Maintain the namespace pattern
4. Add documentation comments to public functions
5. Test with existing packs
