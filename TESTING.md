# EmoteControl Testing Matrix

## Static checks
- `find SpeakinLite SpeakinLite_Pack_* -name '*.lua' -print0 | xargs -0 -n1 luac -p`
- Run this before packaging or release.

## In-game smoke checks (Retail)
1. Login with a clean profile.
2. Run `/sl status` and confirm:
   - addon enabled
   - packs loaded
   - no Lua errors
3. Open:
   - `/sl options`
   - `/sl packs`
   - `/sl editor`
   - `/sl builder`
   - `/sl import`

## Trigger path checks
1. Spell trigger:
   - cast a known spell with a matching class/race pack trigger
   - verify one message only (cooldown honored)
2. Combat log pseudo-events:
   - generate a crit / interrupt and verify trigger fires
3. Non-spell events:
   - death/resurrect
   - zone change
   - achievement earned
   - level up (or simulated on PTR/test character)

## Pack enable/disable checks
1. Disable one pack in `/sl packs`.
2. Reproduce one trigger from that pack and verify no output.
3. Re-enable and confirm output returns.

## Import/export checks
1. Export overrides.
2. Import with merge and replace.
3. Attempt malformed import strings and verify friendly errors.

## Compatibility checks
1. Test with default UI only.
2. Test with common UI addons loaded.
3. Confirm no slash command conflicts for `/sl` and `/emotecontrol`.
