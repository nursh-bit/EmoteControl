# Emote Control v0.8.0 - Feature Guide

## 🎯 Quick Start

### New Template Variables

Use these in your custom messages:

#### Health & Combat
- `<health%>` - Your health percentage (0-100)
- `<health>` - Current health value
- `<healthmax>` - Maximum health
- `<power%>` - Power percentage (mana/rage/energy)
- `<power>` - Current power value
- `<powername>` - Name of your power type
- `<combo>` - Combo points (rogues/druids/etc)
- `<target-health%>` - Target's health percentage

#### Character Info
- `<guild>` - Your guild name
- `<level>` - Your character level
- `<race>` - Your race name

#### Event-Specific
- `<achievement>` - Achievement name (in achievement triggers)
- `<item>` - Item name (in loot triggers)
- `<itemlink>` - Full item link with color
- `<quality>` - Item quality (Epic, Legendary, etc)

#### Examples
```lua
messages = {
  "At <health%>% health, still fighting!",
  "Level <level> <race> <class> reporting for duty!",
  "Looted <itemlink>! <quality> quality!",
  "Achievement unlocked: <achievement>!",
}
```

---

## 🎲 Advanced Conditions

### Random Chance
```lua
conditions = {
  randomChance = 0.5  -- 50% chance to trigger
}
```

### Combat State
```lua
conditions = {
  inCombat = true  -- Only trigger in combat
}
```

### Group Requirements
```lua
conditions = {
  inGroup = true,  -- Must be in a group
  groupSize = { min = 5, max = 40 }  -- Raid-sized groups only
}
```

### Buff/Aura Checks
```lua
conditions = {
  hasAura = "Bloodlust"  -- Only trigger when you have this buff
}
```

### Boss Targeting
```lua
conditions = {
  targetIsBoss = true  -- Only trigger on boss enemies
}
```

### Health Thresholds
```lua
conditions = {
  healthBelow = 30  -- Only when below 30% health
}
```

### Complete Example
```lua
{
  id = "low_health_warning",
  event = "PLAYER_REGEN_DISABLED",
  cooldown = 60,
  conditions = {
    healthBelow = 20,
    inGroup = true,
    randomChance = 0.5
  },
  messages = {
    "Getting low on health at <health%>%!",
    "Need heals! Down to <health%>%!",
  }
}
```

---

## 📦 Import/Export System

### Exporting Your Configuration

1. Type `/sl export` to open the Import/Export UI
2. Click **"Generate Export"**
3. Copy the generated string (starts with `SL1:`)
4. Share with friends or save as backup

### Importing Configurations

1. Type `/sl import`
2. Paste the import string into the text box
3. Choose:
   - **Import (Replace)**: Replaces all your current overrides
   - **Import (Merge)**: Adds new triggers without removing existing ones
4. Click the button

### Use Cases
- **Share** funny trigger packs with guildmates
- **Backup** your custom configurations
- **Try** community-created trigger packs
- **Collaborate** on trigger development

---

## 💬 Conditional Message Variants

Messages can now change based on your group state!

### Basic Example
```lua
messages = {
  solo = {"Fighting alone, as usual."},
  party = {"Let's do this, team!"},
  raid = {"25 people and I still pulled aggro."},
  instance = {"Dungeon mode activated!"}
}
```

### How It Works
- **solo**: Used when not in a group
- **party**: Used in 5-man groups
- **raid**: Used in raid groups
- **instance**: Used when in an instance/dungeon

### Fallback Behavior
If you don't specify all variants, the addon will:
1. Try to use the appropriate variant for your situation
2. Fall back to any available variant
3. Use standard message list if no variants match

### Advanced Example
```lua
{
  id = "death_announcement",
  event = "PLAYER_DEAD",
  cooldown = 0,
  messages = {
    solo = {
      "I have made a tactical error.",
      "Death is just a setback.",
    },
    party = {
      "Sorry team, I died.",
      "Rezzing in a moment...",
    },
    raid = {
      "Down. Healer shortage?",
      "Floor tank reporting for duty.",
    }
  }
}
```

---

## 🎓 Spec-Specific Packs

### What Are They?
Packs that only trigger for specific specializations, allowing for highly targeted announcements.

### Example: Fire Mage
- Only triggers when you're in Fire spec
- Announces Combustion, Pyroblast, Phoenix Flames, etc.
- Spec-specific flavor and personality

### Example: Protection Paladin
- Tank-specific announcements
- Defensive cooldown tracking
- Low health warnings for healers
- Group-aware messages

### Creating Your Own
```lua
Emote Control:RegisterPack({
  id = "myspec",
  name = "My Spec Pack",
  defaults = { 
    class = "MAGE",
    specID = 63  -- Fire Mage
  },
  triggers = {
    -- Your spec-specific triggers here
  }
})
```

### Spec IDs
Find spec IDs using:
```lua
/run local id = GetSpecializationInfo(GetSpecialization()); print(id)
```

---

## 🛠️ Profession Triggers

The new Professions Pack includes triggers for:

### Gathering Professions
- **Herbalism**: Herb Gathering
- **Mining**: Mining ore veins
- **Skinning**: Skinning beasts
- **Fishing**: Casting your line

### Crafting Professions
- **Blacksmithing**: Forging at the anvil
- **Tailoring**: Sewing cloth armor
- **Leatherworking**: Crafting leather gear
- **Jewelcrafting**: Cutting gems
- **Enchanting**: Imbuing items with magic
- **Inscription**: Creating glyphs
- **Alchemy**: Transmuting materials
- **Engineering**: Using gadgets (Nitro Boosts!)

### Utility
- **Cooking Fire**: Setting up to cook
- **Archaeology**: Surveying for artifacts
- **Soulwell**: Warlock healthstones
- **Refreshment Table**: Mage food/water

### All Use Emotes
Profession triggers use the `EMOTE` channel by default, so they're non-intrusive and work everywhere!

---

## 🎉 Achievement & Level-Up Triggers

### Achievement Announcements
```lua
{
  id = "achievement_earned",
  event = "ACHIEVEMENT_EARNED",
  cooldown = 5,
  messages = {
    "Achievement unlocked: <achievement>!",
    "Earned <achievement> (<achievementPoints> points)!",
    "New achievement: <achievement>!",
  }
}
```

### Level-Up Celebrations
```lua
{
  id = "level_up",
  event = "PLAYER_LEVEL_UP",
  cooldown = 0,
  messages = {
    "Ding! Level <level> achieved!",
    "Level <newLevel>! The grind continues!",
    "Reached level <level>. One step closer to max!",
  }
}
```

---

## 🎁 Epic Loot Announcements

### Quality-Based Filtering
```lua
{
  id = "epic_loot",
  event = "CHAT_MSG_LOOT",
  cooldown = 10,
  conditions = {
    quality = 4  -- Epic quality
  },
  messages = {
    "Looted <itemlink>! Epic!",
    "Got <item>! The RNG gods smile upon me!",
  }
}
```

### Quality Levels
- **2**: Uncommon (green)
- **3**: Rare (blue)
- **4**: Epic (purple)
- **5**: Legendary (orange)

---

## 🚀 Auto-Enable Feature

On your first login, Emote Control will automatically:
1. ✅ Enable the **Common** pack
2. ✅ Enable your **Class** pack (e.g., Warrior, Mage)
3. ✅ Enable your **Race** pack (e.g., Human, Orc)

No manual configuration needed! Just install and play.

---

## 📝 Tips & Tricks

### Combining Conditions
```lua
conditions = {
  class = "WARRIOR",
  specID = 73,  -- Arms
  inCombat = true,
  healthAbove = 50,
  randomChance = 0.3
}
```

### Using Pick and RNG
```lua
messages = {
  "Dealt <rng:1000-9999> damage! (probably)",
  "<pick:Fire|Ice|Arcane> magic is the best!",
}
```

### Context-Aware Messages
```lua
messages = {
  party = {
    "<player> used <spell> on <target>!",
  },
  solo = {
    "Cast <spell>. <target> didn't stand a chance.",
  }
}
```

---

## 🎮 Slash Commands Reference

- `/sl status` - View addon status
- `/sl options` - Open options panel
- `/sl packs` - Manage packs
- `/sl editor` - Customize triggers
- `/sl import` - Import/Export UI
- `/sl export` - Import/Export UI
- `/sl on` - Enable addon
- `/sl off` - Disable addon
- `/sl channel <type>` - Set default channel
- `/sl cooldown <seconds>` - Set global cooldown

---

## 🤝 Sharing Your Creations

1. Create awesome custom triggers
2. Export them with `/sl export`
3. Share the string on:
   - Discord servers
   - WoW forums
   - Guild chat
   - Reddit

4. Others can import and enjoy!

---

## 📚 Further Reading

- See `CHANGELOG.md` for full version history
- Check individual pack files for examples
- Use `/sl editor` to see all available triggers
- Experiment with conditions and templates!

---

**Happy Announcing! 🎉**
