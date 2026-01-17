-- EmoteControl - Lightforged Draenei Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_lightforgeddraenei",
  name = "Lightforged Draenei Race Pack",
  defaults = { race = "LIGHTFORGEDDRAENEI" },
  triggers = {
    -- Combat start
    {
      id = "lightforged_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "radiates holy light, blessed by the Naaru.",
        "channels the Light, forged in its glory.",
        "enters combat, righteous fury blazing.",
        "prepares to smite evil with sacred power.",
        "stands ready, Light eternal.",
      },
    },
    
    -- Combat end
    {
      id = "lightforged_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "lowers their weapon, Light's justice served.",
        "stands victorious, blessed by the Naaru.",
        "relaxes, the Light's work complete.",
        "exhales, sacred duty fulfilled.",
        "calms, Light still burning within.",
      },
    },
    
    -- Death
    {
      id = "lightforged_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, but the Light endures.",
        "succumbs, faith unbroken.",
        "collapses, yet still blessed.",
        "meets their end, Light eternal.",
      },
    },
    
    -- Resurrection
    {
      id = "lightforged_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, reforged in the Light.",
        "stands again, blessed and unbroken.",
        "returns, the Naaru's champion.",
        "revives, Light renewed.",
      },
    },
    
    -- Light's Judgment (racial ability)
    {
      id = "lights_judgment",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Light's Judgment" },
      messages = {
        "Light's Judgment! Holy vengeance descends.",
        "Calling down the Light's wrath.",
        "Judgment deployed. The Light condemns.",
        "Holy strike incoming. Justice served.",
      },
    },
  },
})
