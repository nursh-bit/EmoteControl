-- EmoteControl - Goblin Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_goblin",
  name = "Goblin Race Pack",
  defaults = { race = "GOBLIN" },
  triggers = {
    -- Combat
    {
      id = "goblin_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "cracks knuckles, ready to negotiate violently.",
        "readies for combat, profit motive engaged.",
        "prepares to fight, explosives at the ready.",
        "enters battle mode, business is business.",
        "grins maniacally, this should be profitable.",
      },
    },

    {
      id = "goblin_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "stands victorious, already calculating profits.",
        "dusts off, another successful transaction.",
        "grins, violence is good for business.",
        "relaxes, invoice pending.",
        "nods approvingly, time is money.",
      },
    },

    {
      id = "goblin_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, muttering about insurance claims.",
        "collapses, this is bad for business.",
        "dies, already planning the lawsuit.",
        "hits the ground with a small explosion.",
        "falls, final thoughts are about profit margins.",
      },
    },

    {
      id = "goblin_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "springs back to life, time is money!",
        "returns, can't make profit while dead.",
        "revives, business resumes.",
        "stands again, downtime costs money.",
        "rises, opportunity waits for no goblin.",
      },
    },

    -- Racial ability
    {
      id = "goblin_rocket_jump",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "movement",
      conditions = { unit = "player", spellName = "Rocket Jump" },
      messages = {
        "Rocket Jump. Explosive mobility!",
        "Launching via rocket boots.",
        "If Midnight wanted me grounded, too bad.",
        "Rocket jump engaged. Safety optional.",
        "Explosive propulsion activated.",
        "Rocket boots online. WHEEE!",
        "Launching with goblin engineering.",
        "Rocket protocol: go up fast.",
      },
    },

    {
      id = "goblin_rocket_barrage",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { unit = "player", spellName = "Rocket Barrage" },
      messages = {
        "Rocket Barrage! Area denial for a fee.",
        "Launching rockets. Business is booming.",
        "If Midnight wanted peace, wrong zip code.",
        "Barrage engaged. Explosives on the house.",
        "Rockets away. Profit and chaos.",
      },
    },
  },
})
