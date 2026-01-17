-- EmoteControl - Zandalari Troll Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_zandalaritroll",
  name = "Zandalari Troll Race Pack",
  defaults = { race = "ZANDALARITROLL" },
  triggers = {
    -- Combat start
    {
      id = "zandalari_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "enters combat, Zandalari pride evident.",
        "prepares to fight, empire's finest.",
        "assumes battle stance, regal and deadly.",
        "stands ready, blessed by the loa.",
        "channels ancient power, Zandalar eternal.",
      },
    },
    
    -- Combat end
    {
      id = "zandalari_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "relaxes, another victory for Zandalar.",
        "stands tall, empire endures.",
        "composes themselves, regal bearing restored.",
        "exhales, the loa are pleased.",
        "calms, honor of the empire intact.",
      },
    },
    
    -- Death
    {
      id = "zandalari_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, but the empire remembers.",
        "collapses, the loa will judge.",
        "succumbs, Zandalar mourns.",
        "meets their end, regal to the last.",
      },
    },
    
    -- Resurrection
    {
      id = "zandalari_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, Zandalari pride restored.",
        "stands again, blessed by the loa.",
        "returns, the empire needs them.",
        "revives, Zandalar eternal.",
      },
    },
    
    -- Pterrordax Swoop (racial)
    {
      id = "pterrordax_swoop",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Pterrordax Swoop" },
      messages = {
        "Pterrordax Swoop! Taking to the skies.",
        "Swooping down, Zandalari style.",
        "Pterrordax deployed. Ancient tactics.",
        "Flying in! The empire strikes from above!",
      },
    },
    
    -- Regeneratin' (racial)
    {
      id = "regeneratin",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "defensive",
      conditions = { spellName = "Regeneratin'" },
      messages = {
        "Regeneratin'! Zandalari healing power.",
        "Trollish regeneration engaged.",
        "Healing up, mon. The empire endures.",
        "Regeneratin' active. Can't keep us down!",
      },
    },
  },
})
