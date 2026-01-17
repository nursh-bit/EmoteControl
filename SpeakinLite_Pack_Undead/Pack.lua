-- SpeakinLite - Undead Race Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "race_undead",
  name = "Undead Race Pack",
  defaults = { race = "SCOURGE" },  -- Undead is "SCOURGE" in the API
  triggers = {
    -- Combat
    {
      id = "undead_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "readies for battle, death already conquered.",
        "prepares to fight with undead determination.",
        "enters combat, free from the Lich King's will.",
        "assumes fighting stance, Forsaken and fearless.",
        "grips their weapon, mortality no longer a concern.",
      },
    },

    {
      id = "undead_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "stands victorious, already dead inside.",
        "relaxes, another pointless victory.",
        "sheathes their weapon with hollow satisfaction.",
        "nods grimly, the dark lady watches.",
        "rests, as much as the undead can.",
      },
    },

    {
      id = "undead_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, dying a second time.",
        "collapses, death almost familiar now.",
        "meets their second end with grim acceptance.",
        "falls, whispering curses.",
        "dies again. Getting good at this.",
      },
    },

    {
      id = "undead_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises again. Death is just a habit.",
        "returns to unlife, as before.",
        "stands once more, undeath persistent.",
        "revives with hollow determination.",
        "rises, the Forsaken endure.",
      },
    },

    -- Racial ability
    {
      id = "undead_will",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { unit = "player", spellName = "Will of the Forsaken" },
      messages = {
        "Will of the Forsaken. Free will asserted.",
        "Breaking mental control. Again.",
        "If Midnight wants my mind, denied.",
        "Forsaken will engaged.",
        "Mind control resisted.",
        "Free will restored. The dark lady provides.",
        "Will of the undead activated.",
        "Mental freedom online.",
      },
    },
  },
})
