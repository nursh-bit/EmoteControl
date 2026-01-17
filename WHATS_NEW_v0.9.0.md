# Emote Control v0.9.0 - New Features Summary

## 🎉 Six Major Features Added!

### 1. **Usage Statistics** ✅
Track your roleplay activity with comprehensive statistics!

**Commands:**
- `/sl stats` - View detailed usage statistics
- `/sl resetstats` - Reset all statistics

**What's Tracked:**
- Total messages sent (lifetime & session)
- Top 10 most-used triggers
- Category breakdown (combat, flavor, utility, etc.)
- Per-trigger fire counts
- Session vs lifetime comparisons

**Example Output:**
```
=== Emote Control Usage Statistics ===
Total Messages Sent: 1,234 (Session: 45)

Top 10 Most Used Triggers:
  1. warrior_charge [movement] - 156 times (session: 8)
  2. combat_start [flavor] - 89 times (session: 5)
  ...

By Category:
  movement: 234
  flavor: 189
  ...
```

---

### 2. **Death & Resurrection Messages** ✅
Automatically react to death and resurrection events!

**New Triggers:**
- `PLAYER_DEAD` - Messages when you die
  - "has fallen."
  - "wasn't prepared for that."
  - "adds another death to the count."

- `PLAYER_ALIVE` - Messages when you respawn
  - "returns from the grave!"
  - "shakes off death's grip."
  - "is alive and ready for round two!"

- `RESURRECT_REQUEST` - Thank your healer!
  - "Thank you for the rez!"
  - "You're a lifesaver!"

**Also Added:**
- Level-up announcements (`PLAYER_LEVEL_UP`)
- Achievement notifications (`ACHIEVEMENT_EARNED`)
- Epic loot celebrations (`CHAT_MSG_LOOT`)
- Party join/leave messages
- Zone change flavor
- Dungeon entry messages

---

### 3. **Pet & Mount Summons** ✅
Flavor messages for summoning companions!

**Supported:**
- **Mounts** (ground & flying)
- **Hunter Pets** (Call Pet, Revive Pet, Dismiss Pet)
- **Warlock Demons** (Imp, Voidwalker, Succubus, Felhunter)
- **Mage Utilities** (Conjure Food, Ritual of Refreshment)
- **Other Activities:**
  - Checking mail
  - Opening bank
  - Talking to vendors
  - Fishing
  - Cooking/campfires
  - Hearthstone
  - Flight path selection

**Example Messages:**
- "summons their trusty mount."
- "whistles loudly, calling their faithful companion."
- "tears open reality, summoning a voidwalker."
- "checks their mailbox, hoping for a letter."

---

### 4. **Combat Log Integration** ✅
React dynamically to combat events!

**New Combat Events:**
- `COMBAT_CRITICAL_HIT` - Big crits!
  - "lands a devastating critical hit!"
  - "strikes with lethal precision!"

- `COMBAT_DODGED` - Missed attacks
  - "watches their attack get dodged!"

- `COMBAT_PARRIED` - Parried strikes
  - "has their attack parried!"

- `COMBAT_INTERRUPTED` - Successful interrupts
  - "Not casting that!"
  - "Interrupted!"

**How It Works:**
- Monitors `COMBAT_LOG_EVENT_UNFILTERED`
- Filters for player-sourced events
- Triggers on crits, misses, dodges, parries, blocks, interrupts
- Includes damage amounts and spell names in context

---

### 5. **Mood/Personality Profiles** ✅
Switch between different message personalities!

**Command:**
```
/sl mood [profile]
```

**Available Moods:**
- `default` - Balanced, neutral messages
- `serious` - Grim, focused, tactical
- `humorous` - Witty, lighthearted, comedic
- `dark` - Menacing, edgy, aggressive
- `heroic` - Noble, valorous, inspiring

**How to Use:**
```
/sl mood humorous    # Switch to funny messages
/sl mood serious     # Switch to tactical messages
/sl mood            # Check current mood
```

**Example (Warrior Combat Start):**
- **Default:** "roars into battle, weapon raised high."
- **Serious:** "enters combat stance, weapon drawn."
- **Humorous:** "Did someone order violence? Special delivery."
- **Dark:** "advances, hungering for blood."
- **Heroic:** "FOR GLORY AND HONOR!"

**Pack Support:**
Triggers can define mood-specific messages using `messagesByMood`:
```lua
{
  id = "my_trigger",
  event = "PLAYER_REGEN_DISABLED",
  messagesByMood = {
    default = {"Default message"},
    humorous = {"Funny message"},
    serious = {"Tactical message"},
  },
}
```

---

### 6. **In-Game Trigger Builder** ✅
Create custom triggers without editing Lua!

**Command:**
```
/sl builder
```

**Features:**
- **Visual Interface** - No code required!
- **Event Selection** - Dropdown of all available events
- **Cooldown Settings** - Set trigger frequency
- **Channel Selection** - Choose where messages appear
- **Multi-Message Support** - Add multiple message variants
- **Spell Conditions** - Filter by spell name/ID
- **Live Preview** - See what you're creating
- **Instant Save** - Triggers activate immediately

**Supported Events:**
- UNIT_SPELLCAST_SUCCEEDED
- PLAYER_REGEN_DISABLED / ENABLED
- ACHIEVEMENT_EARNED
- PLAYER_LEVEL_UP
- PLAYER_DEAD / ALIVE
- COMBAT_CRITICAL_HIT
- COMBAT_DODGED / PARRIED / INTERRUPTED

**How to Create a Trigger:**
1. `/sl builder` - Open the builder
2. Select an event (e.g., "UNIT_SPELLCAST_SUCCEEDED")
3. Set cooldown (e.g., 10 seconds)
4. Choose channel (e.g., "EMOTE")
5. Add messages (one per line):
   ```
   casts <spell> with flair!
   channels arcane energy into <spell>!
   unleashes <spell> upon <target>!
   ```
6. (Optional) Add spell name filter
7. Click "Save Trigger"

**Persistence:**
- Custom triggers saved to SavedVariables
- Loaded automatically on login
- Can be edited/deleted via the builder

---

## 🔧 Technical Improvements

### Race Pack Loading Fix
- Added `X-Emote Control-Race` metadata tags
- Race packs now only load for the correct race
- Fixed: All race packs were loading for everyone

### Event Registrations
Added support for:
- PLAYER_DEAD
- PLAYER_ALIVE
- RESURRECT_REQUEST
- GROUP_JOINED / GROUP_LEFT
- ZONE_CHANGED_NEW_AREA
- MAIL_SHOW
- BANKFRAME_OPENED
- MERCHANT_SHOW
- TAXIMAP_OPENED
- COMBAT_LOG_EVENT_UNFILTERED

### Combat Log Parser
- Parses COMBAT_LOG_EVENT_UNFILTERED
- Filters for player-sourced events
- Maps combat subevents to trigger events
- Extracts damage, spell info, miss types

---

## 📊 Statistics Schema

Stored in `Emote ControlDB.stats`:
```lua
{
  totalMessages = 1234,           -- Lifetime
  sessionMessages = 45,            -- Current session
  triggers = {
    ["trigger_id"] = {
      count = 156,                 -- Lifetime fires
      lastFired = timestamp,
      firstFired = timestamp,
      category = "movement",
      packName = "warrior"
    },
  },
  session = {
    ["trigger_id"] = 8,            -- Session fires
  }
}
```

---

## 🎮 New Slash Commands

```
/sl stats                      - View usage statistics
/sl resetstats                 - Reset statistics
/sl mood [profile]             - Change personality profile
/sl builder                    - Open trigger builder UI
```

---

## 📦 Updated Files

**Core Addon:**
- `Core.lua` - Stats tracking, mood profiles, combat log, new events
- `TriggerBuilder.lua` - NEW! Visual trigger creation UI
- `Emote Control.toc` - Updated to v0.9.0

**Packs:**
- `Emote Control_Pack_Common/Pack.lua` - Death/res, combat log, social triggers
- `Emote Control_Pack_DailyActivities/Pack.lua` - Pet/mount/activity triggers
- `Emote Control_Pack_Warrior/Pack.lua` - Example mood-based trigger
- All race pack `.toc` files - Added race tags

**Race Pack Loading:**
- All 26 race .toc files updated with `X-Emote Control-Race` tags

---

## 🚀 Usage Examples

### Track Your Roleplay Activity
```
/sl stats
> Total Messages Sent: 523 (Session: 12)
> Top trigger: warrior_charge [movement] - 87 times
```

### Switch Personalities
```
/sl mood humorous
> Mood profile set to: humorous
# Now all your messages are funny!
```

### Create a Custom Trigger
```
/sl builder
# Visual UI opens
# Create trigger for "Divine Shield" cast
# Add messages: "Bubble time!", "INVINCIBLE!", etc.
# Save and it works immediately!
```

### View Combat Stats
```
# After combat
/sl stats
> combat_crit: 23 times
> combat_interrupt: 5 times
```

---

## 🎨 Mood Profile Guidelines

**When to use each mood:**
- **default** - Balanced, works everywhere
- **serious** - Raids, M+, rated PvP
- **humorous** - Casual content, guild runs, fun times
- **dark** - Shadow priest, death knight, warlock vibes
- **heroic** - Paladin, warrior, champion fantasy

**Switching on the fly:**
```bash
/sl mood serious     # Starting raid
# ... raid happens ...
/sl mood humorous    # After raid, doing mount runs
```

---

## 📈 What's Next?

Potential future features:
- Weather/time-of-day variants
- Zone-specific trigger packs
- Quest completion reactions
- Trade/duel flavor
- Reputation gain messages
- More mood profiles (snarky, formal, poetic, etc.)
- Trigger import/export via builder UI
- Conditional logic builder (visual if/then)

---

## 🐛 Bug Fixes in This Release

1. **Race packs now load correctly** - Added race tag checks
2. **Evoker spec change trigger** - Fixed event type
3. **Demon Hunter syntax error** - Fixed typo in category
4. **EMOTE channel** - Now works everywhere (not restricted)
5. **Combat cooldowns** - Standardized to 45 seconds

---

## 💡 Pro Tips

1. **Use `/sl stats` regularly** - See which triggers fire most
2. **Experiment with moods** - Find your favorite personality
3. **Create custom triggers** - Add your own spells and flavor
4. **Check session stats** - Reset between activities to compare
5. **Combine moods with packs** - Disable packs you don't want

---

**Enjoy v0.9.0!** 🎉
