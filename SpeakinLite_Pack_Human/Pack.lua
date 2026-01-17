-- EmoteControl - Human Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_human",
  name = "Human Race Pack",
  defaults = { race = "HUMAN" },
  triggers = {
    -- Combat start (uses emote to avoid restrictions)
    {
      id = "human_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "readies their weapon with practiced discipline.",
        "draws steel with the confidence of Stormwind.",
        "assumes a combat stance, human determination evident.",
        "prepares to fight for the Alliance.",
        "channels the spirit of their ancestors.",
      },
    },

    -- Combat end
    {
      id = "human_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "sheathes their weapon with practiced efficiency.",
        "exhales slowly, the fight concluded.",
        "stands victorious, as humans do.",
        "brushes off dust with casual dignity.",
        "adjusts their gear, already planning the next move.",
      },
    },

    -- Death
    {
      id = "human_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, but not without honor.",
        "collapses, determination fading last.",
        "meets their end with quiet courage.",
        "dies as they lived: stubbornly.",
        "falls, but the Alliance endures.",
      },
    },

    -- Resurrection
    {
      id = "human_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises with renewed determination.",
        "returns to life, unbowed.",
        "stands again, resilient as ever.",
        "shakes off death like an inconvenience.",
        "lives again. Humans are persistent.",
      },
    },

    -- Zone entry
    {
      id = "human_enter_world",
      event = "PLAYER_ENTERING_WORLD",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "arrives in <zone>, ready to represent Stormwind.",
        "enters <zone> with human versatility.",
        "steps into <zone>, diplomacy and steel both ready.",
        "surveys <zone> with practiced tactical awareness.",
        "arrives bearing the colors of the Alliance.",
      },
    },

    -- Racial ability
    {
      id = "human_every_man",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { unit = "player", spellName = "Every Man for Himself" },
      messages = {
        "Every Man for Himself. Human tenacity engaged.",
        "Breaking free through sheer willpower.",
        "If Midnight wanted control, I have opinions.",
        "Human stubbornness: activated.",
        "Freedom via determination.",
        "Stormwind doesn't raise quitters.",
        "Every human for themselves. Starting with me.",
        "Escaping with characteristic resilience.",
      },
    },
  },
})
