-- SpeakinLite - Vulpera Race Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "race_vulpera",
  name = "Vulpera Race Pack",
  defaults = { race = "VULPERA" },
  triggers = {
    -- Combat start
    {
      id = "vulpera_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "enters combat, clever and scrappy.",
        "prepares to fight, desert cunning engaged.",
        "assumes battle stance, small but fierce.",
        "stands ready, survivor's instinct.",
        "grins, ready to outfox the enemy.",
      },
    },
    
    -- Combat end
    {
      id = "vulpera_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "relaxes, another close call survived.",
        "stands victorious, clever as always.",
        "grins, outsmarted them again.",
        "dusts themselves off, caravan moves on.",
        "calms, ready for the next adventure.",
      },
    },
    
    -- Death
    {
      id = "vulpera_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, but the caravan continues.",
        "collapses, survival failed this time.",
        "succumbs, desert claims another.",
        "meets their end, scrappy to the last.",
      },
    },
    
    -- Resurrection
    {
      id = "vulpera_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, vulpera resilience.",
        "stands again, can't keep a good fox down.",
        "returns, the caravan needs them.",
        "revives, survivors always bounce back.",
      },
    },
    
    -- Bag of Tricks (racial)
    {
      id = "bag_of_tricks",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Bag of Tricks" },
      messages = {
        "Bag of Tricks! Let's see what we have here.",
        "Pulling something clever from the bag.",
        "Bag of Tricks deployed. Surprises!",
        "Reaching into the bag. Vulpera ingenuity!",
      },
    },
    
    -- Make Camp (racial)
    {
      id = "make_camp",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { spellName = "Make Camp" },
      messages = {
        "Make Camp! Setting up shop.",
        "Making camp. Rest and resupply.",
        "Camp deployed. Vulpera hospitality!",
        "Setting up the tent. Home away from home!",
      },
    },
  },
})
