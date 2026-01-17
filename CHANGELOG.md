# Emote Control Changelog

## Version 0.8.0 - Major Feature Update

### New Features (1-4): Extended Template Variables & New Event Triggers

#### 1. Extended Template Variables
Added many new template variables for message customization:
- **Health & Power**: `<health%>`, `<health>`, `<healthmax>`, `<power%>`, `<power>`, `<powermax>`, `<powername>`
- **Combat**: `<combo>` (combo points), `<target-health%>`
- **Character Info**: `<guild>`, `<level>`, `<race>`
- **Event-Specific**: `<achievement>`, `<item>`, `<itemlink>`, `<quality>`

#### 2. Achievement Earned Triggers
- New `ACHIEVEMENT_EARNED` event support
- Automatically announces when you earn achievements
- Includes achievement name and points in context

#### 3. Level-Up Triggers
- New `PLAYER_LEVEL_UP` event support
- Celebrate reaching new levels with custom messages
- `<level>` and `<newLevel>` variables available

#### 4. Loot Triggers
- New `CHAT_MSG_LOOT` and `LOOT_READY` event support
- Announce epic and legendary item drops
- Quality-based filtering with `<item>`, `<itemlink>`, `<quality>` variables

### New Features (5-8): Smart Pack Management & Advanced Conditions

#### 5. Auto-Enable Class/Race Packs
- First-time login automatically enables your class pack
- Automatically enables your race pack
- Common pack always enabled by default
- Smoother new user experience

#### 6. Extended Conditions
Added powerful new condition types for triggers:
- **`randomChance`**: Probability-based triggering (0.0 to 1.0)
- **`inCombat`**: Trigger only in/out of combat
- **`inGroup`**: Require group membership
- **`groupSize`**: Filter by group size (min/max)
- **`hasAura`**: Check for specific buff/debuff
- **`targetIsBoss`**: Only trigger on boss enemies
- **`healthBelow`**: Trigger when health drops below threshold
- **`healthAbove`**: Trigger when health is above threshold

#### 7. Import/Export System
- **Export** all your custom trigger overrides to a shareable string
- **Import** configurations from other players
- **Merge mode**: Add new triggers without losing existing ones
- **Replace mode**: Complete configuration replacement
- Base64-encoded, safe serialization
- Access via `/sl import` or `/sl export`
- New UI panel for easy sharing

#### 8. Spec-Specific Packs
Created example spec packs for more targeted announcements:
- **Fire Mage Pack**: Combustion, Pyroblast, Phoenix Flames, etc.
- **Protection Paladin Pack**: Tank-specific abilities and warnings
- Uses `specID` condition for precise targeting
- Template for creating more spec packs

### New Features (9-10): Message Variants & Profession Support

#### 9. Conditional Message Variants
Messages can now vary based on group state:
```lua
messages = {
  solo = {"Fighting alone!"},
  party = {"Let's do this, team!"},
  raid = {"25 people, one goal!"},
  instance = {"Dungeon time!"}
}
```
- Automatically selects appropriate message based on context
- Falls back gracefully if specific variant not available

#### 10. Profession Triggers Pack
New pack for profession-related activities:
- **Gathering**: Herbalism, Mining, Skinning, Fishing
- **Crafting**: All major professions (Blacksmithing, Tailoring, etc.)
- **Utility**: Cooking Fire, Archaeology Survey
- **Class Utilities**: Soulwell, Refreshment Table
- All use emotes for non-intrusive announcements

### Core Improvements

#### Enhanced Context System
- `MakeContext()` now accepts `extraData` parameter for event-specific info
- Richer context for all triggers
- Better support for custom event handlers

#### Updated Editor
- Hint text now shows all available template variables
- Better documentation for users creating custom triggers

#### New Slash Commands
- `/sl import` - Open import/export UI
- `/sl export` - Open import/export UI
- Updated `/sl help` with new commands

### New Packs
- **Emote Control_Pack_Professions**: Profession and crafting triggers
- **Emote Control_Pack_FireMage**: Fire Mage specialization pack
- **Emote Control_Pack_ProtectionPaladin**: Protection Paladin specialization pack

### Technical Changes
- Added `ImportExport.lua` module with Base64 encoding/decoding
- Enhanced condition matching system with 8 new condition types
- Improved message selection logic for conditional variants
- Extended `CONDITION_KEYS` in Registry for new condition types
- Event handlers for ACHIEVEMENT_EARNED, PLAYER_LEVEL_UP, CHAT_MSG_LOOT
- Auto-enable logic in PLAYER_LOGIN handler

### Files Modified
- `Emote Control/Core.lua` - Major enhancements to context, conditions, events
- `Emote Control/Registry.lua` - Added new condition keys
- `Emote Control/Editor.lua` - Updated hint text
- `Emote Control/Emote Control.toc` - Added ImportExport.lua
- `Emote Control/ImportExport.lua` - NEW FILE

### Files Created
- `Emote Control_Pack_Professions/` - NEW PACK
- `Emote Control_Pack_FireMage/` - NEW PACK
- `Emote Control_Pack_ProtectionPaladin/` - NEW PACK

---

## Version 0.7.1 - Emote Support & Code Refactoring

### Features
- Added emote support for flavor announcements
- Created 12 race-specific packs
- Added emote flavor triggers to all 13 class packs
- Converted Common pack to use emotes

### Code Quality
- Created `Utils.lua` for shared utility functions
- Eliminated code duplication across modules
- Optimized rate limiting algorithm
- Implemented spell name/ID caching
- Standardized TOC file metadata

### Packs Added
- All race packs: Human, Dwarf, Night Elf, Gnome, Draenei, Worgen, Orc, Undead, Tauren, Troll, Blood Elf, Goblin

---

## Version 0.7.0 - Initial Release

### Core Features
- Modular pack system
- Event-driven trigger architecture
- Template variable system
- Rate limiting and spam control
- Dual UI support (Legacy + Modern)
- Trigger override system
- Pack management UI

### Initial Packs
- Common Pack
- 13 Class Packs (Warrior, Paladin, Hunter, Rogue, Priest, Death Knight, Shaman, Mage, Warlock, Druid, Monk, Demon Hunter, Evoker)
