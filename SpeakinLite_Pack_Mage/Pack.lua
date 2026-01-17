-- EmoteControl - Mage Pack

if not EmoteControl or type(EmoteControl.RegisterPack) ~= "function" then
  return
end

-- Notes:
-- cooldown is per trigger, in seconds. Use higher cooldowns for rotation spells to avoid spam.

EmoteControl:RegisterPack({
  id = "mage",
  name = "Mage Pack",
  triggers = {
    -- Emote flavor triggers
    {
      id = "mage_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      conditions = { class = "MAGE", unit = "player" },
      messages = {
        "begins weaving arcane energies.",
        "conjures devastating magic.",
        "channels raw elemental power.",
        "prepares to unleash destruction.",
        "enters combat, spell components ready.",
      },
    },
    {
      id = "mage_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      conditions = { class = "MAGE", unit = "player" },
      messages = {
        "lowers their staff, magic subsiding.",
        "dismisses the spell matrix.",
        "stands victoriously, intellectually superior.",
        "relaxes, arcane energy dissipating.",
        "nods, another demonstration complete.",
      },
    },

    -- Movement / Utility
    {
      id = "mage_blink",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 6,
      conditions = { class = "MAGE", unit = "player", spellID = 1953, spellName = "Blink" },
      messages = {
        "Blink. Space is optional.",
        "I was here. Now I am there.",
        "Short-range teleport, long-range attitude.",
        "The laws of physics just filed a complaint.",
        "Blink engaged. Keep up.",
        "A step through the arcane seam.",
        "If the Void is watching, it just lost track of me.",
        "Midnight can chase my afterimage.",
      },
    },
    {
      id = "mage_shimmer",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 6,
      conditions = { class = "MAGE", unit = "player", spellID = 212653, spellName = "Shimmer" },
      messages = {
        "Shimmer. Like Blink, but with style.",
        "Reality, politely, make room.",
        "Phase shift: on.",
        "I refuse to be where the bad things are.",
        "I slipped sideways in the timeline.",
        "A shimmer of possibility.",
        "Too slow. Try prophecy next time.",
      },
    },
    {
      id = "mage_slow_fall",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 10,
      conditions = { class = "MAGE", unit = "player", spellID = 130, spellName = "Slow Fall" },
      messages = {
        "Slow Fall. Gravity can wait.",
        "Feather mode activated.",
        "I prefer my landings optional.",
        "Dropping with dignity.",
        "Arcane safety harness deployed.",
        "The ground is doing too much. I will arrive later.",
      },
    },
    {
      id = "mage_remove_curse",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 10,
      conditions = { class = "MAGE", unit = "player", spellID = 475, spellName = "Remove Curse" },
      messages = {
        "Remove Curse. Bad vibes evicted.",
        "That hex is not on the guest list.",
        "Cursed? Not on my watch.",
        "Arcane housekeeping, aisle three.",
        "Un-cursed. You are welcome.",
      },
    },

    -- Control / Defense
    {
      id = "mage_counterspell",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 8,
      conditions = { class = "MAGE", unit = "player", spellID = 2139, spellName = "Counterspell" },
      messages = {
        "Counterspell. Please stop talking.",
        "No casting. Only vibes.",
        "That spell is cancelled.",
        "Silence. The arcane is speaking.",
        "I edited your incantation. It now says: no.",
        "This is why the Kirin Tor invented punctuation.",
        "Your monologue ends here.",
        "Midnight is loud enough. You do not get a turn.",
      },
    },
    {
      id = "mage_polymorph",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 12,
      conditions = { class = "MAGE", unit = "player", spellID = 118, spellName = "Polymorph" },
      messages = {
        "Polymorph. Congratulations on your new career as livestock.",
        "Behold: the classic sheep solution.",
        "You are now a harmless problem.",
        "Temporary barn time.",
        "A gentle reminder that free will is negotiable.",
        "Sheep mode. Please do not resist.",
        "The Sunwell did not prepare you for this.",
      },
    },
    {
      id = "mage_frost_nova",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 10,
      conditions = { class = "MAGE", unit = "player", spellID = 122, spellName = "Frost Nova" },
      messages = {
        "Frost Nova. Everyone hold hands.",
        "Stop right there.",
        "Freeze. Think about what you did.",
        "Personal space enforced.",
        "Ice time.",
        "All movement has been politely declined.",
      },
    },
    {
      id = "mage_ice_block",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", spellID = 45438, spellName = "Ice Block" },
      messages = {
        "Ice Block. I have entered my bubble era.",
        "Emergency freezer deployed.",
        "If you need me, file a request in triplicate.",
        "I am temporarily unavailable for consequences.",
        "Brb, becoming a popsicle.",
        "I will now ignore the entire encounter.",
        "Void whispers? Not through two feet of ice.",
      },
    },
    {
      id = "mage_ice_barrier",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 12,
      conditions = { class = "MAGE", unit = "player", spellID = 11426, spellName = "Ice Barrier" },
      messages = {
        "Ice Barrier. Armor, but make it cold.",
        "Shield up. Please do not touch.",
        "Temporary invincibility. Do not quote me on that.",
        "Frosty protection online.",
        "If you hit me, the ice gets a vote.",
      },
    },
    {
      id = "mage_invisibility",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", spellID = 66, spellName = "Invisibility" },
      messages = {
        "Invisibility. I am not here.",
        "You cannot hit what you cannot find.",
        "I have decided to be a rumor.",
        "Now you see me. Now you do not.",
        "A stealth mechanic, but classy.",
        "If Midnight wants me, it can submit a ticket.",
      },
    },
    {
      id = "mage_mirror_image",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", spellID = 55342, spellName = "Mirror Image" },
      messages = {
        "Mirror Image. There are now several of me. This is a problem.",
        "Multiplying my mistakes.",
        "Decoys deployed. Pick the wrong one.",
        "The Kirin Tor calls this: delegation.",
        "Illusions online. Confidence also online.",
        "You wanted a mage? You get a committee.",
      },
    },

    -- Buffs / Rituals
    {
      id = "mage_arcane_intellect",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      conditions = { class = "MAGE", unit = "player", spellID = 1459, spellName = "Arcane Intellect" },
      messages = {
        "Arcane Intellect. Think faster.",
        "Brains buffed. Use responsibly.",
        "Knowledge is power. Also mana.",
        "I have enhanced your thinking. Do not waste it.",
        "Kirin Tor approved cognitive upgrade.",
        "Intellect applied. No refunds.",
        "If the Void whispers, now you can argue back.",
      },
    },
    {
      id = "mage_conjure_refreshment",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      conditions = { class = "MAGE", unit = "player", spellID = 190336, spellName = "Conjure Refreshment" },
      messages = {
        "Conjure Refreshment. Snacks manifest.",
        "I have summoned carbs from the ether.",
        "Arcane catering services, open for business.",
        "Food for the road. Or the raid.",
        "The laws of conservation of mass are crying.",
        "A table for heroes. Please do not stand in it.",
        "Silvermoon taught many secrets. This one is delicious.",
      },
    },
    {
      id = "mage_time_warp",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      conditions = { class = "MAGE", unit = "player", spellID = 80353, spellName = "Time Warp" },
      messages = {
        "Time Warp. Everyone panic faster.",
        "Borrowing time. Please return it in good condition.",
        "The timeline flexes.",
        "Chronomancy engaged. Try not to break history.",
        "We are now speed-running reality.",
        "Midnight will arrive sooner at this rate.",
      },
    },

    -- Theft and Firepower
    {
      id = "mage_spellsteal",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 10,
      conditions = { class = "MAGE", unit = "player", spellID = 30449, spellName = "Spellsteal" },
      messages = {
        "Spellsteal. Mine now.",
        "I liked your buff, so I took it.",
        "Consider this a magical borrowing.",
        "Arcane kleptomania engaged.",
        "Thank you for the donation.",
        "If you wanted to keep it, you should have guarded it.",
      },
    },

    -- Big cooldowns
    {
      id = "mage_arcane_power",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      conditions = { class = "MAGE", unit = "player", spellID = 12042, spellName = "Arcane Power" },
      messages = {
        "Arcane Power. Dialing up the universe.",
        "Power spike. Please admire responsibly.",
        "Mana converts to attitude.",
        "I am temporarily my own raid boss.",
        "Arcane amplitude increased.",
        "The Ley Lines approve.",
      },
    },
    {
      id = "mage_icy_veins",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      conditions = { class = "MAGE", unit = "player", spellID = 12472, spellName = "Icy Veins" },
      messages = {
        "Icy Veins. Chill mode: aggressive.",
        "Cold-blooded casting engaged.",
        "Frost accelerates.",
        "Let it snow. Let it hurt.",
        "Ice in my veins, Void in the distance.",
      },
    },
    {
      id = "mage_combustion",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      conditions = { class = "MAGE", unit = "player", spellID = 190319, spellName = "Combustion" },
      messages = {
        "Combustion. Science says this is fine.",
        "Ignition sequence: yes.",
        "Everything is about to be on fire.",
        "Pyromancy: enthusiast mode.",
        "I have chosen arson, but with math.",
        "Midnight is dark. I brought my own sun.",
      },
    },

    -- Rotation staples (high cooldown to reduce spam)
    {
      id = "mage_fireball",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", spellID = 133, spellName = "Fireball" },
      messages = {
        "Fireball. The classic.",
        "Delivering heat by express arcane mail.",
        "Small sun, applied directly to forehead.",
        "Fire solves problems. This is one of those.",
        "This is why Dalaran has building codes.",
      },
    },
    {
      id = "mage_frostbolt",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", spellID = 116, spellName = "Frostbolt" },
      messages = {
        "Frostbolt. Consider chilling out.",
        "Applying cold facts.",
        "A bolt of winter, fresh from Northrend.",
        "Cooling the encounter. Also the target.",
        "Ice, delivered.",
      },
    },
    {
      id = "mage_arcane_blast",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", spellID = 30451, spellName = "Arcane Blast" },
      messages = {
        "Arcane Blast. Pure intention.",
        "Raw arcana, no filter.",
        "Ley energy, directed.",
        "This is what happens when you read too many tomes.",
        "Arcane impact pending.",
      },
    },
    {
      id = "mage_ice_lance",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", spellID = 30455, spellName = "Ice Lance" },
      messages = {
        "Ice Lance. Pointy problems require pointy solutions.",
        "A shard of winter, expedited.",
        "Sharp, cold, and personal.",
        "I brought a spear to a spell fight.",
        "This is why mages do not need knives.",
      },
    },
    {
      id = "mage_pyroblast",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 25,
      conditions = { class = "MAGE", unit = "player", spellID = 11366, spellName = "Pyroblast" },
      messages = {
        "Pyroblast. Commitment issues? Not today.",
        "Charging up a whole problem.",
        "This one has a signature.",
        "Launching a fireball with ambition.",
        "If it lives, it is just resilient.",
        "A bigger sun, for a bigger argument.",
      },
    },
    {
      id = "mage_arcane_barrage",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", spellID = 44425, spellName = "Arcane Barrage" },
      messages = {
        "Arcane Barrage. I have opinions, in bulk.",
        "Spraying arcane certainty.",
        "A barrage of 'no'.",
        "Releasing stored arcane grievances.",
        "Dalaran sends its regards.",
      },
    },

    -- ====================================================================
    -- FIRE MAGE SPEC-SPECIFIC TRIGGERS (SpecID: 63)
    -- ====================================================================
    {
      id = "mage_phoenix_flames",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 10,
      conditions = { class = "MAGE", unit = "player", specID = 63, spellName = "Phoenix Flames" },
      messages = {
        "Phoenix Flames. Rise from the ashes.",
        "Summoning the phoenix's fury.",
        "Phoenix fire, seek and destroy.",
        "The phoenix hunts.",
        "Reborn in flame. Repeatedly.",
        "Phoenix deployed. Fire never dies.",
      },
    },
    {
      id = "mage_living_bomb",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      conditions = { class = "MAGE", unit = "player", specID = 63, spellName = "Living Bomb" },
      messages = {
        "Living Bomb planted. Tick tock.",
        "You're a bomb now. Surprise!",
        "Living Bomb active. Explosion imminent.",
        "Enjoy your new explosive personality.",
        "Countdown initiated. Stand back.",
      },
    },
    {
      id = "mage_meteor",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", specID = 63, spellName = "Meteor" },
      messages = {
        "Meteor. Extinction-level event incoming.",
        "Calling down a meteor. Because I can.",
        "Meteor strike authorized.",
        "Dinosaurs had it easy. This is a REAL meteor.",
        "Summoning space rocks. For violence.",
        "The sky delivers my regards.",
      },
    },
    {
      id = "mage_flamestrike",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 12,
      conditions = { class = "MAGE", unit = "player", spellName = "Flamestrike" },
      messages = {
        "Flamestrike. Fire from above.",
        "Calling down the flames.",
        "Flamestrike incoming. Move or burn.",
        "Raining fire on their heads.",
        "Area-of-effect arson.",
      },
    },

    -- ====================================================================
    -- FROST MAGE SPEC-SPECIFIC TRIGGERS (SpecID: 64)
    -- ====================================================================
    {
      id = "mage_comet_storm",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      conditions = { class = "MAGE", unit = "player", specID = 64, spellName = "Comet Storm" },
      messages = {
        "Comet Storm. Ice from the sky.",
        "Summoning frozen meteors.",
        "Comet bombardment engaged.",
        "The sky is falling. It is cold.",
        "Ice storm deployed from orbit.",
      },
    },
    {
      id = "mage_frozen_orb",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      conditions = { class = "MAGE", unit = "player", specID = 64, spellName = "Frozen Orb" },
      messages = {
        "Frozen Orb. Spinning death ball of ice.",
        "Orb deployed. Please avoid.",
        "Ice sphere activated.",
        "Frozen chaos incoming.",
        "Orbital ice engaged.",
      },
    },
    {
      id = "mage_brain_freeze",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      category = "flavor",
      channel = "EMOTE",
      conditions = { class = "MAGE", unit = "player", specID = 64, spellName = "Flurry", randomChance = 0.3 },
      messages = {
        "grins, Brain Freeze proc detected.",
        "channels instant ice, precision cold.",
        "unleashes frozen fury without casting.",
        "smirks, the cold responds instantly.",
      },
    },

    -- ====================================================================
    -- ARCANE MAGE SPEC-SPECIFIC TRIGGERS (SpecID: 62)
    -- ====================================================================
    {
      id = "mage_arcane_missiles",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      conditions = { class = "MAGE", unit = "player", specID = 62, spellName = "Arcane Missiles" },
      messages = {
        "Arcane Missiles. Pew pew pew.",
        "Missile barrage engaged.",
        "Arcane projectiles deployed.",
        "Firing magic missiles. Plural.",
        "Rapid-fire arcane pain.",
      },
    },
    {
      id = "mage_arcane_surge",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      conditions = { class = "MAGE", unit = "player", specID = 62, spellName = "Arcane Surge" },
      messages = {
        "Arcane Surge. Power levels critical.",
        "Surge activated. Maximum arcane.",
        "The Ley Lines scream in approval.",
        "Power spike to the extreme.",
        "Arcane overload: intentional.",
      },
    },
    {
      id = "mage_evocation",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      conditions = { class = "MAGE", unit = "player", specID = 62, spellName = "Evocation" },
      messages = {
        "Evocation. Mana recovery protocol.",
        "Channeling the Ley Lines.",
        "Refueling via arcane meditation.",
        "Mana restoration engaged.",
        "Evocation online. Please wait.",
      },
    },
  },
})
