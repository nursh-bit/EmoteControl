# Emote Control v0.9.2 - 1.0 Readiness Pass

## Highlights
- First-run onboarding opens options and gives quick setup tips.
- Quick setup button applies recommended, low-spam defaults.
- Pack discovery shows available-but-not-loaded packs.
- New event toggles for combat log, loot, achievements, and level-up.
- SavedVariables now have versioning and a migration helper.

## Quick Setup Defaults
- Channel: SELF
- Global cooldown: 6 seconds
- Max per minute: 8
- Rotation protection: MEDIUM
- Combat log triggers: OFF

## Pack Discovery
- Packs are listed even if not loaded yet.
- Enabling a pack can auto-load it and rebuild triggers.

## QA Checklist (1.0)
- /reload, verify version is 0.9.2.
- Open /sl options, toggle each event type and verify behavior.
- Enable a not-loaded pack and confirm it loads + triggers rebuild.
- Verify combat log triggers are silent when disabled.
- Enter combat and open editor/settings to ensure no UI errors.

## Compatibility
- Retail `## Interface: 120000`
- SavedVariables schema now versioned; no data loss expected.
