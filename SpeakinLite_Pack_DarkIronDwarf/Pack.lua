-- EmoteControl - Dark Iron Dwarf Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_darkirondwarf",
  name = "Dark Iron Dwarf Race Pack",
  defaults = { race = "DARKIRONDWARF" },
  triggers = {
    -- Combat start
    {
      id = "darkiron_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "ignites with inner fire, ready for battle.",
        "channels the flames of Blackrock.",
        "enters combat, molten fury rising.",
        "prepares to fight, fire in their eyes.",
        "stands ready, forged in flame.",
      },
    },
    
    -- Combat end
    {
      id = "darkiron_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "cools down, flames subsiding.",
        "stands victorious, forged strong.",
        "relaxes, inner fire banked.",
        "grins, another fight won.",
        "sheathes their weapon, battle over.",
      },
    },
    
    -- Death
    {
      id = "darkiron_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, flames extinguished.",
        "collapses, fire fading.",
        "meets their end, but not forgotten.",
        "succumbs, the forge calls them home.",
      },
    },
    
    -- Resurrection
    {
      id = "darkiron_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, flames rekindled.",
        "stands again, reforged.",
        "returns, fire eternal.",
        "revives, Dark Iron resilience.",
      },
    },
    
    -- Fireblood (racial ability)
    {
      id = "fireblood",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Fireblood" },
      messages = {
        "Fireblood! Inner flames ignite.",
        "Burning with molten fury.",
        "Fireblood activated. Let's get hot.",
        "Flames surge. Dark Iron power!",
      },
    },
    
    -- Mole Machine (fun ability)
    {
      id = "mole_machine",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { spellName = "Mole Machine" },
      messages = {
        "Mole Machine deployed! Underground travel engaged.",
        "Digging a tunnel. Dark Iron engineering!",
        "Mole Machine activated. See you there!",
        "Going underground. Efficiency!",
      },
    },
  },
})
