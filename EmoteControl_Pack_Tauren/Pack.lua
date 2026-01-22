-- EmoteControl - Tauren Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_tauren",
  name = "Tauren Race Pack",
  defaults = { race = "TAUREN" },
  triggers = {
    -- Combat
    {
      id = "tauren_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "readies for battle, strength of the plains evident.",
        "prepares to fight with the blessing of the Earth Mother.",
        "assumes combat stance, Mulgore's might manifest.",
        "enters battle with tauren resolve.",
        "grips their weapon, ancestors watching.",
      },
    },

    {
      id = "tauren_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "stands victorious, honoring the Earth Mother.",
        "lowers their weapon, battle concluded with dignity.",
        "offers thanks to the ancestors.",
        "relaxes, nature's balance maintained.",
        "rests, another threat to the plains removed.",
      },
    },

    {
      id = "tauren_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, returning to the Earth Mother.",
        "collapses with quiet dignity.",
        "meets death with tauren grace.",
        "falls like a mighty kodo.",
        "dies, the ancestors call.",
      },
    },

    {
      id = "tauren_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, the Earth Mother grants another chance.",
        "returns to life with renewed purpose.",
        "stands again, blessed by nature.",
        "revives, strength of the plains restored.",
        "rises, the journey continues.",
      },
    },

    -- Racial ability
    {
      id = "tauren_war_stomp",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { unit = "player", spellName = "War Stomp" },
      messages = {
        "War Stomp. Earth trembles.",
        "Stomping with the force of Thunder Bluff.",
        "If Midnight stands near, it falls.",
        "Ground shake engaged.",
        "War stomp deployed. Feel the earth.",
        "Tauren stomp activated.",
        "Stomping with ancestral might.",
        "Earth tremor protocol online.",
      },
    },
  },
})
