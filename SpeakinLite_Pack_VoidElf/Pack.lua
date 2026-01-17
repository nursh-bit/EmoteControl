-- EmoteControl - Void Elf Race Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

EmoteControl:RegisterPack({
  id = "race_voidelf",
  name = "Void Elf Race Pack",
  defaults = { race = "VOIDELF" },
  triggers = {
    -- Combat start
    {
      id = "voidelf_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "channels the Void, shadows coiling around them.",
        "embraces the darkness within, ready to fight.",
        "enters combat, void energy crackling.",
        "prepares to unleash the power of the Rift.",
        "stands ready, touched by the Void.",
        "lets void whispers guide their strikes.",
        "enters battle, shadows answering their call.",
      },
    },
    
    -- Combat end
    {
      id = "voidelf_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "releases the Void, shadows dissipating.",
        "stands victorious, void whispers fading.",
        "relaxes, the darkness receding.",
        "calms, having mastered the Void once more.",
        "exhales, void energy settling.",
        "silences the whispers, control maintained.",
        "stands tall, void power contained.",
      },
    },
    
    -- Death
    {
      id = "voidelf_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, consumed by the Void.",
        "collapses, void energy scattering.",
        "succumbs, the whispers overwhelming.",
        "falls to darkness.",
        "dissolves into shadow.",
      },
    },
    
    -- Resurrection
    {
      id = "voidelf_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "returns from the Void, shadows reforming.",
        "rises again, void-touched resilience.",
        "stands once more, the Rift endures.",
        "returns, void energy restored.",
        "reforms from shadow, unbroken.",
      },
    },
    
    -- Spatial Rift (racial ability)
    {
      id = "spatial_rift",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Spatial Rift" },
      messages = {
        "Spatial Rift. Tearing through reality.",
        "Opening a rift. Physics are optional.",
        "Void portal deployed. Quick escape ready.",
        "Rift created. The Void provides shortcuts.",
        "Space has been compromised.",
        "Reality? More like suggestion.",
        "Rift online. Teleport pending.",
      },
    },

    -- Void-themed flavor
    {
      id = "voidelf_whispers",
      event = "ZONE_CHANGED_NEW_AREA",
      cooldown = 120,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "pauses, hearing void whispers in this place.",
        "senses the Void's presence here.",
        "feels shadow energies swirling nearby.",
        "hears echoes from the Rift.",
        "listens as the Void murmurs in the distance.",
      },
    },
    
    {
      id = "voidelf_magic",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellName = "Portal", randomChance = 0.4 },
      messages = {
        "weaves void energy into the portal.",
        "channels shadows alongside arcane power.",
        "bends space with void-touched magic.",
        "calls upon the Rift to aid their spell.",
        "threads shadow into the portal's arcane weave.",
      },
    },

    {
      id = "voidelf_achievement",
      event = "ACHIEVEMENT_EARNED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "celebrates, void energy flickering with excitement.",
        "smiles, the Void approves of this achievement.",
        "nods proudly, mastery recognized.",
        "stands tall, void whispers pleased.",
        "accepts this honor, shadows curling in approval.",
      },
    },

    {
      id = "voidelf_rest",
      event = "PLAYER_UPDATE_RESTING",
      cooldown = 120,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "settles in, void whispers growing quiet.",
        "relaxes, allowing the shadows to rest.",
        "finds peace, even the Void needs respite.",
        "meditates, balancing light and shadow within.",
        "rests, the whispers soft and distant.",
      },
    },
  },
})
