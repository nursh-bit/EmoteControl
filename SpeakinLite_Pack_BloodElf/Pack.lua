-- SpeakinLite - Blood Elf Race Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "race_bloodelf",
  name = "Blood Elf Race Pack",
  defaults = { race = "BLOODELF" },
  triggers = {
    -- Combat
    {
      id = "belf_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "readies for battle with practiced elegance.",
        "prepares to fight, grace and magic intertwined.",
        "enters combat stance, Silvermoon's pride evident.",
        "assumes fighting position with arcane precision.",
        "grips their weapon, magic thrumming.",
      },
    },

    {
      id = "belf_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "sheathes their weapon with aristocratic poise.",
        "stands victorious, elegance maintained.",
        "adjusts their hair, battle concluded flawlessly.",
        "relaxes, another demonstration of sin'dorei superiority.",
        "nods, glory to Silvermoon.",
      },
    },

    {
      id = "belf_death",
      event = "PLAYER_DEAD",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "falls gracefully, even in death.",
        "collapses, beauty undiminished.",
        "dies with quiet dignity.",
        "meets their end, still looking good.",
        "falls, but dies stylishly.",
      },
    },

    {
      id = "belf_alive",
      event = "PLAYER_ALIVE",
      cooldown = 0,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "rises with renewed arcane energy.",
        "returns to life, grace restored.",
        "stands again, elegance intact.",
        "revives, magic flowing once more.",
        "rises, the Sunwell provides.",
      },
    },

    -- Racial ability
    {
      id = "belf_arcane_torrent",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { unit = "player", spellName = "Arcane Torrent" },
      messages = {
        "Arcane Torrent. Mana drain engaged.",
        "Consuming arcane energy. Mine now.",
        "If Midnight has magic, I take it.",
        "Arcane theft protocol active.",
        "Draining power with sin'dorei efficiency.",
        "Torrent deployed. Magic absorbed.",
        "Arcane consumption online.",
        "Mana vampirism activated.",
      },
    },
  },
})
