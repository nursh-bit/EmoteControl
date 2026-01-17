# Emote Control Cooldown Guide

## Understanding Cooldowns

Cooldowns prevent message spam by limiting how often a trigger can fire.

### Cooldown Types

#### 1. **Per-Trigger Cooldown**
Each trigger has its own cooldown timer.
```lua
{
  id = "my_trigger",
  cooldown = 45,  -- Can only fire once every 45 seconds
  messages = {...}
}
```

#### 2. **Global Cooldown**
Set in `/sl options` - applies a minimum cooldown to ALL triggers.
- Default: 6 seconds
- Range: 0-60 seconds
- Overrides trigger cooldowns if higher

#### 3. **Rotation Protection**
Special cooldown for spell rotation triggers (UNIT_SPELLCAST_SUCCEEDED).
- **OFF**: No extra protection
- **LOW**: 12 second minimum
- **MEDIUM**: 6 second minimum (default)
- **HIGH**: 2 second minimum

Prevents spam from frequently-cast spells.

### Recommended Cooldowns by Trigger Type

#### Combat Events (30-60 seconds)
```lua
{
  id = "combat_start",
  event = "PLAYER_REGEN_DISABLED",
  cooldown = 45,  -- Don't spam every pull
}
```

#### Death/Resurrection (0-10 seconds)
```lua
{
  id = "death",
  event = "PLAYER_DEAD",
  cooldown = 0,  -- You don't die that often anyway
}
```

#### Spell Rotations (10-20 seconds)
```lua
{
  id = "fireball",
  event = "UNIT_SPELLCAST_SUCCEEDED",
  cooldown = 15,  -- Frequently cast, higher cooldown
}
```

#### Big Cooldowns (15-30 seconds)
```lua
{
  id = "combustion",
  event = "UNIT_SPELLCAST_SUCCEEDED",
  cooldown = 20,  -- Major ability, announce it
}
```

#### Flavor/Emotes (30-60 seconds)
```lua
{
  id = "flavor_emote",
  cooldown = 45,  -- Occasional flavor, not spam
  channel = "EMOTE",
}
```

### Adding Randomness

Want messages to fire randomly? Use `randomChance`:

```lua
{
  id = "random_combat",
  event = "PLAYER_REGEN_DISABLED",
  cooldown = 30,  -- Minimum 30 seconds between attempts
  conditions = {
    randomChance = 0.5  -- 50% chance to fire when cooldown is ready
  },
  messages = {...}
}
```

This effectively makes it fire every 30-60 seconds randomly!

### Rate Limiting

Additional spam protection:

#### Max Messages Per Minute
Set in `/sl options` (default: 12)
- Limits total messages across ALL triggers
- Prevents overwhelming chat
- Recommended: 10-15 for active play

#### Example Calculation
- 12 messages per minute = 1 message every 5 seconds average
- With multiple triggers, they'll compete for slots
- Higher cooldowns = more consistent firing

### Current Combat Cooldowns

All combat start/end triggers are set to **45 seconds**:
- Warrior, Paladin, Hunter, Rogue, Priest
- Death Knight, Shaman, Mage, Warlock, Druid
- Monk, Demon Hunter, Evoker
- All 12 race packs
- Common pack

This means:
- ✅ Won't spam in long fights
- ✅ Will announce at start of new encounters
- ✅ Gives 45 seconds between combat announcements
- ✅ Combined with randomChance, can vary 30-60+ seconds

### Customizing Cooldowns

#### Via Editor UI
1. Type `/sl editor`
2. Select a trigger
3. Change the cooldown value
4. Click Save

#### Via Pack Files
Edit the `Pack.lua` file directly:
```lua
{
  id = "my_trigger",
  cooldown = 60,  -- Change this value
  messages = {...}
}
```

### Pro Tips

1. **Combat triggers**: 30-60 seconds (use randomChance for variety)
2. **Spell rotations**: 10-20 seconds (depends on cast frequency)
3. **Big cooldowns**: 15-30 seconds (important to announce)
4. **Flavor/RP**: 45-90 seconds (occasional fun, not spam)
5. **Death events**: 0-5 seconds (rare enough already)
6. **Achievement/Loot**: 5-10 seconds (exciting moments!)

### Testing Your Cooldowns

1. Enable only one pack: `/sl packs`
2. Test in combat
3. Watch for spam
4. Adjust cooldowns up if too frequent
5. Adjust down if too rare

### Example: Perfect Combat Setup

```lua
{
  id = "combat_start",
  event = "PLAYER_REGEN_DISABLED",
  cooldown = 45,
  conditions = {
    randomChance = 0.7  -- 70% chance = fires ~every 64 seconds average
  },
  channel = "EMOTE",
  messages = {
    "enters combat, ready for battle.",
    "assumes a fighting stance.",
    "prepares to engage the enemy.",
  }
}
```

This setup:
- Minimum 45 seconds between fires
- 70% chance when ready = average 64 seconds
- Effectively random 45-90+ second intervals
- Won't spam, but will announce regularly
- Uses EMOTE so works everywhere

---

**Remember**: It's better to have cooldowns too HIGH than too LOW. You can always reduce them if triggers feel too rare!
