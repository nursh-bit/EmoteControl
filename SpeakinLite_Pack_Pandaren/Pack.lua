-- EmoteControl - Pandaren Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_pandaren",
  name = "Pandaren Race Pack",
  defaults = { race = "PANDAREN" },
  triggers = {
    -- Combat start
    {
      id = "pandaren_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "assumes a martial arts stance, ready for combat.",
        "enters battle with measured calm.",
        "prepares to fight, inner peace focused.",
        "stands ready, balance in all things.",
        "channels chi, warrior spirit awakened.",
      },
    },
    
    -- Combat end
    {
      id = "pandaren_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "relaxes, harmony restored.",
        "stands victorious, balance maintained.",
        "exhales slowly, inner peace returns.",
        "calms, the lesson learned.",
        "bows respectfully, combat complete.",
      },
    },
    
    -- Death
    {
      id = "pandaren_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, but the journey continues.",
        "collapses, balance lost.",
        "succumbs, returning to the earth.",
        "meets their end with dignity.",
        "falls softly, lesson learned.",
      },
    },
    
    -- Resurrection
    {
      id = "pandaren_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, inner peace restored.",
        "stands again, resilient as bamboo.",
        "returns, balance requires it.",
        "revives, the journey must continue.",
        "stands, calm strength renewed.",
      },
    },
    
    -- Quaking Palm (racial)
    {
      id = "quaking_palm",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Quaking Palm" },
      messages = {
        "Quaking Palm! Pressure point strike.",
        "Delivering a stunning blow. Martial arts!",
        "Quaking Palm deployed. Sleep now.",
        "Chi strike! Feel the earth shake!",
        "Palm strike lands. Tranquility restored.",
      },
    },
    
    -- Flavor: Food lover
    {
      id = "pandaren_food",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellName = "Food" },
      messages = {
        "sits down to enjoy a good meal.",
        "savors the food, culinary appreciation.",
        "eats contentedly, food brings joy.",
        "enjoys the feast, life's simple pleasures.",
        "takes a mindful bite, savoring the moment.",
      },
    },
  },
})
