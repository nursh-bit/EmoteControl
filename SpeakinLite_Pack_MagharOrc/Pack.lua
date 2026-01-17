-- EmoteControl - Mag'har Orc Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_magharorc",
  name = "Mag'har Orc Race Pack",
  defaults = { race = "MAGHARORC" },
  triggers = {
    -- Combat start
    {
      id = "maghar_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "roars into battle, uncorrupted fury.",
        "enters combat, true orcish strength.",
        "prepares to fight, honor and steel.",
        "stands ready, Draenor pride.",
        "assumes battle stance, unbowed and unbroken.",
      },
    },
    
    -- Combat end
    {
      id = "maghar_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "relaxes, victorious and honorable.",
        "stands tall, Mag'har dominance.",
        "grins, another worthy fight.",
        "exhales, strength proven.",
        "calms, honor satisfied.",
      },
    },
    
    -- Death
    {
      id = "maghar_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, but dies with honor.",
        "collapses, a warrior's end.",
        "succumbs, the ancestors await.",
        "meets death as an orc should.",
      },
    },
    
    -- Resurrection
    {
      id = "maghar_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, Mag'har resilience.",
        "stands again, unbroken spirit.",
        "returns, honor demands it.",
        "revives, Draenor endures.",
      },
    },
    
    -- Ancestral Call (racial)
    {
      id = "ancestral_call",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Ancestral Call" },
      messages = {
        "Ancestral Call! The spirits answer.",
        "Calling upon the ancestors.",
        "Ancestral power flows. Mag'har might!",
        "Spirits rise! Honor the old ways!",
      },
    },
  },
})
