-- SpeakinLite - Orc Race Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "race_orc",
  name = "Orc Race Pack",
  defaults = { race = "ORC" },
  triggers = {
    -- Combat
    {
      id = "orc_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "roars, ready for honorable combat.",
        "grips their weapon, orcish fury awakening.",
        "enters battle stance, strength of Orgrimmar evident.",
        "prepares to fight with the spirit of the Horde.",
        "readies for war, blood and thunder.",
      },
    },

    {
      id = "orc_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "stands victorious, honor satisfied.",
        "sheathes their weapon, strength proven.",
        "nods approvingly, another worthy battle.",
        "relaxes, victory achieved with orcish might.",
        "grins, Lok'tar ogar.",
      },
    },

    {
      id = "orc_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls with an honorable roar.",
        "collapses, dying as an orc should.",
        "meets death with orcish defiance.",
        "falls, but dies with honor.",
        "hits the ground, strength undiminished in death.",
      },
    },

    {
      id = "orc_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises with renewed fury.",
        "returns to life, orcish resilience evident.",
        "stands again, ready for battle.",
        "revives, strength restored.",
        "rises, the Horde needs them still.",
      },
    },

    -- Racial ability
    {
      id = "orc_blood_fury",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "cooldowns",
      conditions = { unit = "player", spellName = "Blood Fury" },
      messages = {
        "Blood Fury. Orcish rage activated.",
        "Channeling ancestral fury.",
        "If Midnight wanted calm, wrong race.",
        "Blood fury engaged. Power increased.",
        "Rage of Draenor unleashed.",
        "Orcish strength amplified.",
        "Blood fury online. Lok'tar!",
        "Fury protocol activated.",
      },
    },
  },
})
