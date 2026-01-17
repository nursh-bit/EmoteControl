-- EmoteControl - Troll Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_troll",
  name = "Troll Race Pack",
  defaults = { race = "TROLL" },
  triggers = {
    -- Combat
    {
      id = "troll_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "readies for battle, spirits at their side.",
        "grins wickedly, tusks gleaming.",
        "prepares to fight with troll ferocity.",
        "enters combat with primal energy.",
        "stands ready, the loa watching.",
      },
    },

    {
      id = "troll_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "relaxes, victory assured by the loa.",
        "grins, another fight won.",
        "stands victorious, spirits satisfied.",
        "sheathes their weapon, battle done properly.",
        "nods, the Darkspear way prevails.",
      },
    },

    {
      id = "troll_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, muttering to the spirits.",
        "collapses, the loa will remember.",
        "dies with a defiant laugh.",
        "meets their end, tusks held high.",
        "falls, but the spirits linger.",
      },
    },

    {
      id = "troll_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, the loa grant another chance.",
        "returns to life with troll resilience.",
        "stands again, spirits willing.",
        "revives, regeneration kicking in.",
        "rises, death merely inconvenient.",
      },
    },

    -- Racial ability
    {
      id = "troll_berserking",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "cooldowns",
      conditions = { unit = "player", spellName = "Berserking" },
      messages = {
        "Berserking. Troll fury unleashed.",
        "Going berserk, mon.",
        "If Midnight wanted calm, wrong race.",
        "Berserker mode engaged.",
        "Rage of the Darkspear activated.",
        "Troll speed online. Watch out.",
        "Berserking protocol active.",
        "Fury engaged. Stay back.",
      },
    },
  },
})
