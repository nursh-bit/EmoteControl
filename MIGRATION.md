-- EMOTECONTROL MIGRATION GUIDE

## Updating from EmoteControl to EmoteControl

This guide helps pack developers update their packs for the latest EmoteControl structure.

## What Changed

### 1. Addon Naming
- **Old**: EmoteControl
- **New**: EmoteControl
- **Status**: Backward compatible - old references still work

### 2. File Structure
The core addon is still in the `EmoteControl/` folder, but references use `EmoteControl` consistently.

```lua
-- Old (still works)
if EmoteControl then
  EmoteControl:RegisterPack(...)
end

-- New (recommended)
if EmoteControl then
  EmoteControl:RegisterPack(...)
end
```

### 3. SavedVariables
- **Old**: EmoteControlDB, EmoteControlDB
- **New**: EmoteControlDB only
- **Migration**: Automatic - old database is still recognized

## Updating Your Pack

### Step 1: Update .toc File

**Before:**
```
## Dependencies: EmoteControl
## X-EmoteControl-PackType: Common
```

**After:**
```
## Dependencies: EmoteControl
## X-EmoteControl-PackType: Common
```

### Step 2: Update Pack.lua Namespace

**Before:**
```lua
EmoteControl = EmoteControl or EmoteControl or {}
EmoteControl = EmoteControl
local addon = EmoteControl

addon:RegisterPack({
  id = "my_pack",
  triggers = {...}
})
```

**After:**
```lua
EmoteControl = EmoteControl or {}
EmoteControl = EmoteControl  -- Backward compatibility
local addon = EmoteControl

addon:RegisterPack({
  id = "my_pack",
  triggers = {...}
})
```

### Step 3: Use New Library Functions (Optional)

You can now use the enhanced LibEmoteControl for cleaner code:

**Before:**
```lua
local triggers = {
  {
    event = "UNIT_SPELLCAST_SUCCEEDED",
    spellID = 12345,
    messages = {"Cast it!", "Using it!"},
    cooldown = 10,
  }
}
```

**After:**
```lua
local lib = LibEmoteControl or EmoteControl
local triggers = {
  lib:CreateSpellTrigger(12345, {"Cast it!", "Using it!"}, {cooldown = 10})
}
```

### Step 4: Use Message Template Helpers (Optional)

**Before:**
```lua
messages = {
  "Hello <pick:world|friend|there>",
  "Random: <rng:1-10>"
}
```

**After (with helpers):**
```lua
local lib = LibEmoteControl
messages = {
  "Hello " .. lib:Pick("world", "friend", "there"),
  "Random: " .. lib:RandomNum(1, 10)
}
```

## Compatibility Checklist

- [ ] Pack .toc file has correct Interface version
- [ ] Pack.lua uses updated namespace initialization
- [ ] Pack.id is set (not relying on auto-generation)
- [ ] All trigger definitions are valid
- [ ] Message templates use valid tokens
- [ ] Conditions use valid field names
- [ ] Tested with current EmoteControl version

## Backward Compatibility

Your existing packs will continue to work without any changes due to:

1. **Namespace aliases**: `EmoteControl = EmoteControl`
2. **Function compatibility**: All old functions still exist
3. **Database compatibility**: Old SavedVariables are still recognized
4. **Event compatibility**: All event handlers work the same

However, we recommend updating your pack for future compatibility and access to new features.

## New Features Available

### 1. LibEmoteControl API
Simplified pack development with helper functions:

```lua
local lib = LibEmoteControl
local pack = {
  id = "my_pack",
  name = "My Pack",
  triggers = {
    lib:CreateSpellTrigger(
      12345,
      {"Boom!", "Pow!"},
      {
        category = "rotation",
        randomChance = 0.5
      }
    )
  }
}
lib:RegisterPack(pack)
```

### 2. Enhanced Conditions

```lua
local trigger = {
  event = "UNIT_SPELLCAST_SUCCEEDED",
  spellID = 12345,
  messages = {"Casting now!"},
  
  -- Enhanced conditions
  inCombat = true,  -- Only in combat
  randomChance = 0.75,  -- 75% chance
  hasAura = "Blessing of Kings",  -- Requires aura
  groupSize = 5,  -- Only in groups of 5+
}
```

### 3. Message Templates

All message templates now support these dynamic tokens:

- **Health**: `<health>`, `<health%%>`, `<healthmax>`
- **Power**: `<power>`, `<power%%>`, `<powermax>`, `<powername>`
- **Combo**: `<combo>`
- **Target**: `<target>`, `<target-health%%>`
- **Target Details**: `<target-full>`, `<target-realm>`, `<target-class>`, `<target-race>`, `<target-level>`
- **Selection**: `<pick:a|b|c>`
- **Random**: `<rng:1-100>`
- **Instance**: `<instance>`, `<instance-type>`, `<instanceName>`, `<instanceDifficulty>`, `<instance-difficulty-id>`, `<instance-mapid>`, `<instance-lfgid>`, `<in-instance>`
- **Group**: `<group-size>`, `<party-size>`, `<group-type>`
- **Mythic+**: `<keystone-level>`, `<keystone-mapid>`, `<affixes>`, `<affix-1>` ... `<affix-4>`

You can also localize message lists by client locale:

```lua
messages = {
  enUS = {"Ready!"},
  esES = {"¡Listo!"},
  default = {"Ready!"}
}
```

### 4. Mood-Specific Messages

Triggers can have mood-specific messages:

```lua
local trigger = {
  event = "UNIT_SPELLCAST_SUCCEEDED",
  spellID = 12345,
  messagesByMood = {
    default = {"Casting spell!"},
    aggressive = {"DESTROY!"},
    humorous = {"Wheee! Pew pew!"}
  }
}
```

### 5. Better Statistics

Statistics are now automatically tracked:

```lua
-- User can view stats via /sl stats
local stats = EmoteControl:GetStats()
if stats and stats.triggers then
  for triggerId, data in pairs(stats.triggers) do
    print(triggerId .. " fired " .. data.count .. " times")
  end
end
```

## Common Issues & Solutions

### Issue: Pack not showing up
**Solution**: 
1. Check that Dependencies in .toc is set to `EmoteControl`
2. Verify folder name starts with `EmoteControl_Pack_`
3. Check pack.id is set and unique

### Issue: EmoteControl is nil
**Solution**:
1. Ensure EmoteControl is listed in Dependencies
2. Make sure your pack is LoadOnDemand
3. Call registration in your Pack.lua file

### Issue: Messages not showing
**Solution**:
1. Check trigger event is valid
2. Verify conditions are met
3. Check channel is accessible
4. Review cooldown settings
5. Check pack is enabled in options

## Testing Your Updated Pack

1. **Create a test trigger**:
```lua
addon:RegisterPack({
  id = "test_pack",
  name = "Test Pack",
  triggers = {
    {
      event = "PLAYER_LOGIN",
      messages = {"Pack loaded successfully!"}
    }
  }
})
```

2. **Load the addon**: `/reload ui`
3. **Check for errors**: Open chat and look for error messages
4. **Verify pack shows up**: `/sl packs` should list your pack
5. **Test a trigger**: Use `/run EmoteControl:Output("Test message", "EMOTE")`

## Getting Help

For questions or issues:
1. Check the API.md for function reference
2. Review STRUCTURE.md for design patterns
3. Look at existing packs for examples
4. Check for error messages in chat
5. Use `/script` commands to debug

## Version History

### 0.10.5 (Current)
- Added AUTO channel, quiet hours, and adaptive cooldowns
- Added locale message tables and spec-based pack profiles
- Expanded context tokens and slash commands
- Improved pack discovery/listing and trigger builder conditions

### 0.9.4 and earlier
- Original EmoteControl releases
- All functionality preserved in new version
