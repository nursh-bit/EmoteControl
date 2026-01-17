-- SpeakinLite - Common Pack
-- Universal triggers that work for all classes and races

SpeakinLite = SpeakinLite or {}
local addon = SpeakinLite

local pack = {
  name = "Common",
  version = "0.8.0",
  triggers = {
    -- ========================================
    -- Death & Resurrection
    -- ========================================
    {
      id = "player_died",
      event = "PLAYER_DEAD",
      cooldown = 5,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "has fallen.",
        "lies defeated on the ground.",
        "collapses, lifeless.",
        "has been slain!",
        "meets an untimely demise.",
        "takes a dirt nap.",
        "fell to <target>.",
        "wasn't prepared for that.",
        "adds another death to the count.",
        "will be back... eventually.",
      },
    },
    {
      id = "player_resurrected",
      event = "PLAYER_ALIVE",
      cooldown = 5,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "returns from the grave!",
        "is back in action!",
        "has been resurrected.",
        "shakes off death's grip.",
        "rises once more!",
        "dusts themself off and gets back up.",
        "cheated death... this time.",
        "respawns with renewed determination.",
        "is alive and ready for round two!",
        "returns, a bit worse for wear.",
      },
    },
    {
      id = "player_resurrected_by_other",
      event = "RESURRECT_REQUEST",
      cooldown = 5,
      category = "flavor",
      channel = "SAY",
      messages = {
        "Thank you for the rez!",
        "Appreciate the save!",
        "Back in the fight, thanks!",
        "You're a lifesaver!",
        "Ready to go again, thanks!",
        "Much obliged for the resurrection!",
        "That was close, thanks for pulling me back!",
      },
    },
    
    -- ========================================
    -- Combat Entry/Exit
    -- ========================================
    {
      id = "combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "readies for battle!",
        "enters combat stance.",
        "draws their weapon.",
        "prepares to engage!",
        "charges into the fray!",
      },
    },
    {
      id = "combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "sheathes their weapon.",
        "relaxes their stance.",
        "wipes the blood from their blade.",
        "catches their breath.",
        "stands victorious.",
      },
    },

    -- ========================================
    -- Level Up
    -- ========================================
    {
      id = "level_up",
      event = "PLAYER_LEVEL_UP",
      cooldown = 10,
      category = "flavor",
      channel = "SAY",
      messages = {
        "Level <level>! Growing stronger!",
        "DING! Level <level> achieved!",
        "Another level, another challenge! Level <level>!",
        "Hit level <level>! Onward and upward!",
        "Level <level> unlocked! Progress!",
        "Reached level <level>! The journey continues!",
        "Level <level> complete! What's next?",
      },
    },

    -- ========================================
    -- Achievement Earned
    -- ========================================
    {
      id = "achievement_earned",
      event = "ACHIEVEMENT_EARNED",
      cooldown = 10,
      category = "flavor",
      channel = "SAY",
      messages = {
        "Achievement unlocked: <achievement>!",
        "Just earned <achievement>!",
        "Completed <achievement>!",
        "Check it out: <achievement>!",
        "<achievement> - another one for the collection!",
        "Finally got <achievement>!",
      },
    },

    -- ========================================
    -- Loot (Epic+ items)
    -- ========================================
    {
      id = "loot_epic",
      event = "CHAT_MSG_LOOT",
      cooldown = 30,
      category = "flavor",
      channel = "SAY",
      messages = {
        "Nice! Just looted <item>!",
        "Epic drop: <item>!",
        "Score! Got <item>!",
        "RNG blessed me with <item>!",
        "Finally! <item> is mine!",
        "Look at this beauty: <item>!",
      },
    },

    -- ========================================
    -- Social Interactions
    -- ========================================
    {
      id = "party_invite_accepted",
      event = "GROUP_JOINED",
      cooldown = 60,
      category = "flavor",
      channel = "PARTY",
      messages = {
        "Ready when you are!",
        "Let's do this!",
        "Joined up! What's the plan?",
        "Here and ready to go!",
        "Party time!",
        "Reporting for duty!",
      },
    },
    {
      id = "party_left",
      event = "GROUP_LEFT",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "parts ways with the group.",
        "heads off solo.",
        "waves goodbye to the party.",
        "departs from the group.",
      },
    },

    -- ========================================
    -- Zone Changes
    -- ========================================
    {
      id = "zone_changed",
      event = "ZONE_CHANGED_NEW_AREA",
      cooldown = 120,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "arrives in <zone>.",
        "enters <zone> cautiously.",
        "steps into <zone> territory.",
        "makes their way to <zone>.",
        "explores the lands of <zone>.",
      },
    },
    {
      id = "entered_dungeon",
      event = "PLAYER_ENTERING_WORLD",
      cooldown = 120,
      category = "flavor",
      channel = "INSTANCE",
      conditions = { inInstance = true },
      messages = {
        "Ready for this challenge!",
        "Let's clear this place!",
        "Time to show them what we've got!",
        "Ready to roll!",
        "Here we go!",
      },
    },
    
    -- ========================================
    -- Combat Log Reactions
    -- ========================================
    {
      id = "combat_crit",
      event = "COMBAT_CRITICAL_HIT",
      cooldown = 15,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "lands a devastating critical hit!",
        "strikes with lethal precision!",
        "deals a crushing blow!",
        "finds the weak spot!",
        "hits with maximum force!",
        "unleashes a critical strike!",
      },
    },
    {
      id = "combat_dodged",
      event = "COMBAT_DODGED",
      cooldown = 20,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "watches their attack get dodged!",
        "misses as the enemy sidesteps!",
        "swings wide as the foe dodges!",
        "is evaded!",
      },
    },
    {
      id = "combat_parried",
      event = "COMBAT_PARRIED",
      cooldown = 20,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "has their attack parried!",
        "is deflected by the enemy's weapon!",
        "strikes but is turned aside!",
        "is blocked skillfully!",
      },
    },
    {
      id = "combat_interrupt",
      event = "COMBAT_INTERRUPTED",
      cooldown = 20,
      category = "flavor",
      channel = "SAY",
      messages = {
        "Not casting that!",
        "Interrupted!",
        "Shut down!",
        "Spell canceled!",
        "No you don't!",
      },
    },
  },
}

addon:RegisterPack(pack)

