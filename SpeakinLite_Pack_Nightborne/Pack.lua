-- EmoteControl - Nightborne Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_nightborne",
  name = "Nightborne Race Pack",
  defaults = { race = "NIGHTBORNE" },
  triggers = {
    -- Combat start
    {
      id = "nightborne_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "channels ancient Nightwell magic, elegant and deadly.",
        "enters combat with Suramar refinement.",
        "prepares to fight, arcane mastery evident.",
        "assumes a graceful battle stance.",
        "stands ready, ten thousand years of knowledge.",
      },
    },
    
    -- Combat end
    {
      id = "nightborne_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "relaxes, elegance restored.",
        "stands victorious, Suramar pride intact.",
        "composes themselves, refinement maintained.",
        "exhales, another victory for the Nightborne.",
        "calms, arcane energies settling.",
      },
    },
    
    -- Death
    {
      id = "nightborne_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, even ten thousand years couldn't prepare for this.",
        "collapses, ancient magic fading.",
        "succumbs, grace lost.",
        "meets their end, the Nightwell weeps.",
        "falls, Suramar's light dimming for a moment.",
      },
    },
    
    -- Resurrection
    {
      id = "nightborne_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises, Nightborne resilience eternal.",
        "stands again, ancient and unbroken.",
        "returns, Suramar endures.",
        "revives, refined as ever.",
        "awakens, arcane poise restored.",
      },
    },
    
    -- Arcane Pulse (racial)
    {
      id = "arcane_pulse",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Arcane Pulse" },
      messages = {
        "Arcane Pulse! Nightwell magic unleashed.",
        "Releasing ancient arcane power.",
        "Pulse deployed. Suramar style.",
        "Arcane surge! Feel the Nightwell's might.",
        "Nightwell energy bursts forth in a pulse.",
      },
    },
  },
})
