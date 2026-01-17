-- SpeakinLite - Void Elf Race Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
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
      },
    },
  },
})
