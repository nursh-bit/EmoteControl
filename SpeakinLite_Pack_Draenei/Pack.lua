-- SpeakinLite - Draenei Race Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "race_draenei",
  name = "Draenei Race Pack",
  defaults = { race = "DRAENEI" },
  triggers = {
    -- Combat
    {
      id = "draenei_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "channels the Light with ancient conviction.",
        "readies for battle, faith unwavering.",
        "prepares to fight, guided by the Naaru.",
        "enters combat with twenty-five thousand years of resolve.",
        "stands ready, the Exodar's strength manifest.",
      },
    },

    {
      id = "draenei_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "lowers their weapon, victory blessed by the Light.",
        "stands victorious, faith confirmed.",
        "offers a prayer of thanks to the Naaru.",
        "relaxes, another battle won with honor.",
        "rests, the Light's purpose fulfilled.",
      },
    },

    {
      id = "draenei_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, entrusting their spirit to the Light.",
        "collapses, faith unshaken even in death.",
        "dies with dignity, as draenei do.",
        "meets their end with ancient grace.",
        "falls, but the Light endures.",
      },
    },

    {
      id = "draenei_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, the Light restoring them.",
        "returns to life, faith renewed.",
        "stands again, blessed by the Naaru.",
        "revives with ancient determination.",
        "rises, the journey continues.",
      },
    },

    -- Racial ability
    {
      id = "draenei_gift",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { unit = "player", spellName = "Gift of the Naaru" },
      messages = {
        "Gift of the Naaru. Healing through the Light.",
        "Channeling the Naaru's blessing.",
        "If Midnight wounds, the Light mends.",
        "Gift bestowed. Health restored.",
        "Naaru healing engaged.",
        "The Light provides. Generously.",
        "Gift of healing deployed.",
        "Blessed healing activated.",
      },
    },
  },
})
