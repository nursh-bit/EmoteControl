-- EmoteControl - Highmountain Tauren Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_highmountaintauren",
  name = "Highmountain Tauren Race Pack",
  defaults = { race = "HIGHMOUNTAINTAUREN" },
  triggers = {
    -- Combat start
    {
      id = "highmountain_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "charges into battle, mountain-strong.",
        "enters combat, blessed by the eagle.",
        "prepares to fight, Highmountain pride.",
        "stands ready, strength of the peaks.",
        "assumes combat stance, steadfast as stone.",
      },
    },
    
    -- Combat end
    {
      id = "highmountain_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "relaxes, another threat overcome.",
        "stands victorious, Highmountain endures.",
        "calms, the mountain provides.",
        "exhales, as immovable as the peaks.",
        "settles, strength renewed.",
      },
    },
    
    -- Death
    {
      id = "highmountain_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, returning to the earth.",
        "collapses, but the mountain remembers.",
        "succumbs, the ancestors call.",
        "meets the earth, spirit enduring.",
        "falls, the peaks echo their passing.",
      },
    },
    
    -- Resurrection
    {
      id = "highmountain_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, Highmountain strength restored.",
        "stands again, blessed by the spirits.",
        "returns, the mountain's champion.",
        "revives, steadfast as ever.",
        "rises, the eagle's blessing renewed.",
      },
    },
    
    -- Bull Rush (racial)
    {
      id = "bull_rush",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Bull Rush" },
      messages = {
        "Bull Rush! Charging with mountain fury.",
        "Rushing forward, unstoppable force.",
        "Bull Rush engaged. Move or be moved.",
        "Charging! Highmountain style!",
        "Stampeding forward with ancestral power.",
      },
    },
  },
})
