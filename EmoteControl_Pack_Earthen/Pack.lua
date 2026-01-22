-- EmoteControl - Earthen Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_earthen",
  name = "Earthen Race Pack",
  defaults = { race = "EARTHEN" },
  triggers = {
    -- Combat start
    {
      id = "earthen_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "braces for battle, stone-forged and unbreakable.",
        "enters combat, earthen resilience awakened.",
        "prepares to fight, carved from the earth itself.",
        "stands ready, ancient and immovable.",
        "channels titan-given strength.",
      },
    },
    
    -- Combat end
    {
      id = "earthen_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "relaxes, stone-steady once more.",
        "stands victorious, earthen endurance proven.",
        "calms, as unmovable as the mountains.",
        "exhales, titan-forged strength intact.",
        "settles, ancient purpose fulfilled.",
      },
    },
    
    -- Death
    {
      id = "earthen_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "crumbles, returning to the earth.",
        "falls, even stone can break.",
        "collapses, the titans witness.",
        "meets their end, stone-still.",
        "falls, dust settling where they stood.",
      },
    },
    
    -- Resurrection
    {
      id = "earthen_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "reforms, earthen resilience eternal.",
        "stands again, stone-forged anew.",
        "returns, the titans' work endures.",
        "revives, unbreakable as always.",
        "rises, stone and spark renewed.",
      },
    },
    
    -- Azerite Surge (racial ability - placeholder)
    {
      id = "earthen_racial",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Azerite Surge" },
      messages = {
        "Azerite Surge! Titan power flows.",
        "Channeling earthen might.",
        "Azerite engaged. Stone and crystal!",
        "Titan-forged power unleashed!",
        "Azerite surges through their core.",
      },
    },
  },
})
