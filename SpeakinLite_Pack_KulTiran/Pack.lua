-- EmoteControl - Kul Tiran Human Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_kultiran",
  name = "Kul Tiran Race Pack",
  defaults = { race = "KULTIRAN" },
  triggers = {
    -- Combat start
    {
      id = "kultiran_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "braces for battle, sea-hardened and ready.",
        "enters combat with maritime determination.",
        "prepares to fight, Kul Tiran strong.",
        "stands ready, tough as the sea.",
        "assumes combat stance, built like a ship.",
      },
    },
    
    -- Combat end
    {
      id = "kultiran_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "relaxes, another storm weathered.",
        "stands victorious, Kul Tiran pride.",
        "grins, tough as the tides.",
        "exhales, the sea endures.",
        "calms, ready for the next wave.",
      },
    },
    
    -- Death
    {
      id = "kultiran_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, but the sea remembers.",
        "collapses, washed away.",
        "succumbs, the tide claims them.",
        "meets their end at last.",
      },
    },
    
    -- Resurrection
    {
      id = "kultiran_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, like the tide.",
        "stands again, sea-forged resilience.",
        "returns, Kul Tiran endurance.",
        "revives, the ocean provides.",
      },
    },
    
    -- Haymaker (racial ability)
    {
      id = "haymaker",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Haymaker" },
      messages = {
        "Haymaker! Punching with dock worker strength.",
        "Delivering a Kul Tiran knuckle sandwich.",
        "Haymaker deployed. They'll feel that.",
        "POW! Maritime might!",
      },
    },
  },
})
