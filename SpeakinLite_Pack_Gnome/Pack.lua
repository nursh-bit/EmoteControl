-- SpeakinLite - Gnome Race Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "race_gnome",
  name = "Gnome Race Pack",
  defaults = { race = "GNOME" },
  triggers = {
    -- Combat
    {
      id = "gnome_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "adjusts their goggles and prepares for battle.",
        "activates combat protocols with technical precision.",
        "grins maniacally, combat systems online.",
        "readies their weapon, Gnomeregan engineering engaged.",
        "enters fight mode, intellect weaponized.",
      },
    },

    {
      id = "gnome_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "deactivates combat mode, already planning improvements.",
        "makes mental notes for equipment upgrades.",
        "grins, another successful field test.",
        "checks their gear for optimization opportunities.",
        "stands victorious, data collected.",
      },
    },

    {
      id = "gnome_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, muttering calculations.",
        "collapses, already planning the comeback.",
        "dies, but the blueprints survive.",
        "hits the ground with a small mechanical whir.",
        "falls, curiosity undiminished.",
      },
    },

    {
      id = "gnome_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "springs back to life with renewed enthusiasm.",
        "returns, eager to test new theories.",
        "stands again, death merely a setback.",
        "revives, already implementing improvements.",
        "rises, gnomish resilience operational.",
      },
    },

    -- Racial ability
    {
      id = "gnome_escape_artist",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { unit = "player", spellName = "Escape Artist" },
      messages = {
        "Escape Artist. Engineering my freedom.",
        "Breaking free via gnomish ingenuity.",
        "If Midnight wanted control, I have gadgets.",
        "Escape mechanism activated.",
        "Freedom through technology.",
        "Gnomish escape protocols online.",
        "Escaping with characteristic cleverness.",
        "Engineering solution deployed.",
      },
    },
  },
})
