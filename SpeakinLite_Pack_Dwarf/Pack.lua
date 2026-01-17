-- SpeakinLite - Dwarf Race Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "race_dwarf",
  name = "Dwarf Race Pack",
  defaults = { race = "DWARF" },
  triggers = {
    -- Combat
    {
      id = "dwarf_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "grips their weapon with dwarven determination.",
        "growls, ready for a proper scrap.",
        "plants their feet like the mountains of Ironforge.",
        "readies for battle with a hearty war cry.",
        "prepares to fight with the strength of Khaz Modan.",
      },
    },

    {
      id = "dwarf_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "sheathes their weapon and grins victoriously.",
        "dusts off their armor, job well done.",
        "nods approvingly at the defeated foes.",
        "considers finding ale to celebrate.",
        "stands proud, another victory for Ironforge.",
      },
    },

    {
      id = "dwarf_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls like a mountain crumbling.",
        "collapses, muttering something about ale.",
        "dies as stubbornly as they lived.",
        "hits the ground with dwarven finality.",
        "falls, but the clan remembers.",
      },
    },

    {
      id = "dwarf_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises with characteristic dwarven resilience.",
        "gets back up, tougher than stone.",
        "shakes off death like ale foam.",
        "stands again, stubborn as ever.",
        "returns, ready for round two.",
      },
    },

    -- Racial ability
    {
      id = "dwarf_stoneform",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "defensive",
      conditions = { unit = "player", spellName = "Stoneform" },
      messages = {
        "Stoneform. Becoming literal stone.",
        "Turning to stone. Temporarily invulnerable.",
        "If Midnight wanted flesh, I am rock.",
        "Stone mode activated. Damage reduced.",
        "Ironforge resilience engaged.",
        "Hard as the mountains now.",
        "Stoneform online. Unbreakable.",
        "Dwarf defense: ultimate form.",
      },
    },
  },
})
