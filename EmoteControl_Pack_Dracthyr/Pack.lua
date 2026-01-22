-- EmoteControl - Dracthyr Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_dracthyr",
  name = "Dracthyr Race Pack",
  defaults = { race = "DRACTHYR" },
  triggers = {
    -- Combat start
    {
      id = "dracthyr_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "unfurls their wings, draconic power awakening.",
        "enters combat, dragonflights' legacy alive.",
        "prepares for battle, scales shimmering.",
        "assumes fighting stance, dragon and mortal unified.",
        "readies for combat, Neltharion's creation unleashed.",
        "channels draconic fury, wings spread wide.",
        "enters the fray with dragon-born strength.",
      },
    },
    
    -- Combat end
    {
      id = "dracthyr_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "folds their wings, battle concluded.",
        "relaxes, draconic essence calming.",
        "stands tall, dragonflights' honor upheld.",
        "exhales a satisfied breath, scales glinting.",
        "nods, another victory for dragonkind.",
        "returns to calm, wings settling.",
        "stands proud, dragon heritage proven.",
      },
    },
    
    -- Death
    {
      id = "dracthyr_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, wings folding in defeat.",
        "collapses, draconic strength fading.",
        "succumbs, even dragons can fall.",
        "falls, scales dimming.",
        "falls, dragonfire flickering out.",
      },
    },
    
    -- Resurrection
    {
      id = "dracthyr_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises again, dragon resilience eternal.",
        "returns, dragonflights' gift renewed.",
        "stands once more, wings spread anew.",
        "revives, draconic power restored.",
        "awakens, embers of power reignited.",
      },
    },
    
    -- Tail Swipe (racial ability placeholder)
    {
      id = "tail_swipe",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Tail Swipe" },
      messages = {
        "Tail Swipe! Dragon reflexes.",
        "Swiping with draconic tail.",
        "Tail attack deployed. Stand back.",
        "Dragon tail says: move.",
        "Tail swipe engaged. Knockback incoming.",
      },
    },

    {
      id = "wing_buffet",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Wing Buffet" },
      messages = {
        "Wing Buffet! Powerful wings deployed.",
        "Buffeting with dragon wings.",
        "Wind from dragon wings. Move away.",
        "Wing attack engaged.",
        "Dragon wings create distance.",
      },
    },

    -- Draconic flavor
    {
      id = "dracthyr_flight",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellName = "Soar", randomChance = 0.4 },
      messages = {
        "takes to the sky on dragon wings.",
        "soars gracefully, true dragon flight.",
        "launches into the air, wings powerful.",
        "flies with the grace of dragonkind.",
        "beats their wings and climbs skyward.",
      },
    },

    {
      id = "dracthyr_achievement",
      event = "ACHIEVEMENT_EARNED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "roars triumphantly, dragon pride evident.",
        "celebrates with draconic dignity.",
        "spreads their wings in victory.",
        "honors this achievement, dragonflights approve.",
        "basks in victory, wings held high.",
      },
    },

    {
      id = "dracthyr_empowered",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellName = "Empower", randomChance = 0.3 },
      messages = {
        "channels draconic magic, scales glowing.",
        "empowers their spell with dragon essence.",
        "weaves magic as only Dracthyr can.",
        "focuses draconic power into the spell.",
        "draws on draconic might to empower the cast.",
      },
    },

    {
      id = "dracthyr_visage",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { spellName = "Chosen Identity" },
      messages = {
        "Chosen Identity. Form shifted.",
        "Changing form, dragon versatility.",
        "Visage adjusted. Adaptable as always.",
        "Form change complete. Still dragon inside.",
        "Identity shifted. Dragon flexibility.",
      },
    },

    {
      id = "dracthyr_rest",
      event = "PLAYER_UPDATE_RESTING",
      cooldown = 120,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "settles down, wings folded peacefully.",
        "rests, draconic essence recharging.",
        "curls up comfortably, dragon-style.",
        "finds repose, as dragons do.",
        "rests quietly, scales cooling and calm.",
      },
    },
  },
})
