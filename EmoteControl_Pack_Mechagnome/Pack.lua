-- EmoteControl - Mechagnome Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_mechagnome",
  name = "Mechagnome Race Pack",
  defaults = { race = "MECHAGNOME" },
  triggers = {
    -- Combat start
    {
      id = "mechagnome_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "activates combat protocols, gears whirring.",
        "enters battle mode, mechanisms engaging.",
        "prepares for combat, servos humming.",
        "stands ready, precision engineering.",
        "initializes combat routines.",
      },
    },
    
    -- Combat end
    {
      id = "mechagnome_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "powers down combat mode, efficient.",
        "stands victorious, systems optimal.",
        "relaxes, gears settling.",
        "completes combat protocols successfully.",
        "enters standby, ready for repairs.",
      },
    },
    
    -- Death
    {
      id = "mechagnome_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "shuts down, critical failure.",
        "collapses, systems offline.",
        "ceases function, awaiting reboot.",
        "experiences catastrophic malfunction.",
        "powers down, diagnostics pending.",
      },
    },
    
    -- Resurrection
    {
      id = "mechagnome_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "reboots successfully, systems online.",
        "restarts, backup protocols engaged.",
        "returns to function, repaired.",
        "revives, mechanical resilience.",
        "systems restart, functionality restored.",
      },
    },
    
    -- Combat Analysis (racial)
    {
      id = "combat_analysis",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Combat Analysis" },
      messages = {
        "Combat Analysis running. Calculating optimal strategy.",
        "Analyzing combat data. Processing...",
        "Combat protocols updated. Efficiency increased.",
        "Running diagnostics. Performance optimized.",
        "Analysis complete. Adjusting for maximum output.",
      },
    },
    
    -- Hyper Organic Light Originator (racial)
    {
      id = "emergency_failsafe",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "defensive",
      conditions = { spellName = "Emergency Failsafe" },
      messages = {
        "Emergency Failsafe activated! Self-repair engaged.",
        "Failsafe protocols online. Restoring systems.",
        "Emergency repairs initiated.",
        "Activating backup systems!",
        "Failsafe engaged. Systems stabilizing.",
      },
    },
  },
})
