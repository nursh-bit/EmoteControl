# Emote Control v0.9.1 - Maintenance Update

## Highlights
- Loot quality filters now work for epic/legendary drops.
- Lower combat-log overhead in busy fights.
- Trigger rebuilds now unregister unused dynamic events.
- Trigger editor backdrops are Retail 10.0+ safe.

## Fixes
- Quality-based conditions (`quality`) now match loot triggers correctly.
- Health threshold conditions avoid divide-by-zero cases.
- Spell trigger context is reused per event to reduce allocations.
- Editor save feedback uses the addon prefix.

## Compatibility
- Retail `## Interface: 120000`
- No changes to saved variables schema.
