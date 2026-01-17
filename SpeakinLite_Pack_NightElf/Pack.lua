-- SpeakinLite - Night Elf Race Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "race_nightelf",
  name = "Night Elf Race Pack",
  defaults = { race = "NIGHTELF" },
  triggers = {
    -- Combat start
    {
      id = "nightelf_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "calls upon Elune, moon-blessed fury awakening.",
        "enters combat with the grace of a Sentinel.",
        "prepares for battle, ancient warrior spirit rising.",
        "assumes a battle stance, millennia of skill guiding them.",
        "readies for combat, eyes glowing with moonlight.",
        "channels the fury of Ashenvale's defenders.",
        "enters the fray, swift as shadow.",
      },
    },
    
    -- Combat end
    {
      id = "nightelf_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "offers thanks to Elune, battle won.",
        "relaxes, moonlight fading from their eyes.",
        "stands victorious, nature's balance maintained.",
        "exhales, ancient calm returning.",
        "nods, another threat to the world tree ended.",
        "sheathes their weapon, Kaldorei honor upheld.",
        "returns to serenity, battle concluded.",
      },
    },
    
    -- Death
    {
      id = "nightelf_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls, whispering a prayer to Elune.",
        "collapses, returning to the cycle.",
        "succumbs, the moon's light dimming.",
        "falls in battle, ancient pride intact.",
      },
    },
    
    -- Resurrection
    {
      id = "nightelf_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises again, Elune's blessing renewed.",
        "returns, moonlight restored.",
        "stands once more, the Goddess watches still.",
        "revives, ancient resilience enduring.",
      },
    },
    
    -- Shadowmeld (racial ability)
    {
      id = "shadowmeld",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "utility",
      conditions = { spellName = "Shadowmeld" },
      messages = {
        "Shadowmeld. Blending with the night.",
        "Melding into shadows. Ancient technique.",
        "Shadowmeld engaged. Invisible as moonlight.",
        "Fading into darkness. The night protects.",
        "Gone. As silent as starfall.",
        "Shadowmeld online. Unseen observer.",
        "Stealth via moonlight. Sentinel tradition.",
      },
    },

    -- Nature-themed flavor
    {
      id = "nightelf_nature",
      event = "ZONE_CHANGED_NEW_AREA",
      cooldown = 120,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "pauses to feel the natural energies of this place.",
        "listens to the whispers of the trees.",
        "senses the balance of nature here.",
        "connects with the land, ancient bond renewed.",
      },
    },

    {
      id = "nightelf_moon",
      event = "PLAYER_UPDATE_RESTING",
      cooldown = 120,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "gazes at the moon, feeling Elune's presence.",
        "rests peacefully, blessed by moonlight.",
        "meditates under the stars, ancient peace.",
        "finds solace in the night, as their ancestors did.",
      },
    },

    {
      id = "nightelf_achievement",
      event = "ACHIEVEMENT_EARNED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "celebrates with quiet dignity, Elune smiles.",
        "honors this achievement in the old ways.",
        "stands proud, another chapter in their long story.",
        "marks this victory, as Sentinels have for ages.",
      },
    },

    {
      id = "nightelf_mount",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellName = "Summon", randomChance = 0.3 },
      messages = {
        "calls their mount with an ancient whistle.",
        "summons their companion, bond forged over centuries.",
        "whistles softly, mount answering the call.",
        "beckons their steed with Darnassian words.",
      },
    },

    {
      id = "nightelf_wisp",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "becomes a wisp, spirit form embraced.",
        "transitions to wisp form, ancient cycle continues.",
        "fades into a wisp of light.",
        "transforms, whisper on the wind.",
      },
    },
  },
})
