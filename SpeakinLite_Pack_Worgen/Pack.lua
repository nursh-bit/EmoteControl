-- EmoteControl - Worgen Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_worgen",
  name = "Worgen Race Pack",
  defaults = { race = "WORGEN" },
  triggers = {
    -- Combat
    {
      id = "worgen_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "snarls, feral instincts awakening.",
        "bares fangs, ready for the hunt.",
        "growls, the beast stirring within.",
        "assumes a predatory stance.",
        "prepares to fight with lupine ferocity.",
      },
    },

    {
      id = "worgen_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "calms, civilization reasserting control.",
        "relaxes, the beast satisfied.",
        "stands victorious, instincts and intellect balanced.",
        "sheathes claws, hunt concluded.",
        "breathes deeply, returning to composure.",
      },
    },

    {
      id = "worgen_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls with a lupine howl.",
        "collapses, the beast finally still.",
        "dies as they lived: fiercely.",
        "falls, Gilneas will remember.",
        "meets their end with a final snarl.",
      },
    },

    {
      id = "worgen_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, the beast refuses to stay down.",
        "returns to life with renewed fury.",
        "stands again, resilient as the wilds.",
        "revives, instincts sharp once more.",
        "rises, the hunt continues.",
      },
    },

    -- Racial ability
    {
      id = "worgen_darkflight",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "movement",
      conditions = { unit = "player", spellName = "Darkflight" },
      messages = {
        "Darkflight. Running on all fours.",
        "Unleashing lupine speed.",
        "If Midnight chases me, good luck.",
        "Beast sprint engaged.",
        "Running wild and free.",
        "Darkflight activated. Catch me if you can.",
        "Feral speed online.",
        "The beast runs free.",
      },
    },
  },
})
