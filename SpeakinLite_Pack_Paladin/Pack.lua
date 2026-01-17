-- SpeakinLite - Paladin Pack

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "paladin",
  name = "Paladin Pack",
  defaults = { class = "PALADIN", unit = "player" },
  triggers = {
    -- Emote flavor triggers
    {
      id = "paladin_combat_start",
      event = "PLAYER_REGEN_DISABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "channels the Light, ready to smite evil.",
        "raises their weapon, blessed by righteousness.",
        "prepares for holy combat.",
        "stands firm, the Light's champion.",
        "enters battle with divine purpose.",
      },
    },
    {
      id = "paladin_combat_end",
      event = "PLAYER_REGEN_ENABLED",
      cooldown = 45,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "lowers their weapon, justice served.",
        "offers a prayer of thanks.",
        "stands victorious, the Light prevails.",
        "sheathes their weapon, righteousness satisfied.",
        "nods, another victory for the Light.",
      },
    },

    -- Divine Shield
    {
      id = "divine_shield",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "defensive",
      conditions = { spellName = "Divine Shield" },
      messages = {
        "Divine Shield. I have pressed the bubble.",
        "Immunity engaged. The Light provides.",
        "Invulnerable. Consequences postponed.",
        "Divine protection online. Try harder.",
        "If Midnight wants me, it will have to wait.",
        "Bubble activated. Judge me if you will.",
        "The Light says no damage allowed.",
        "Immunity granted. Thank the Light, not me.",
      },
    },

    -- Lay on Hands
    {
      id = "lay_on_hands",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "utility",
      conditions = { spellName = "Lay on Hands" },
      messages = {
        "Lay on Hands. Immediate health restoration.",
        "Emergency heal deployed.",
        "The Light provides. Generously.",
        "Full HP granted via divine intervention.",
        "If death was imminent, it has been cancelled.",
        "Miracle healing activated.",
        "The Light delivers express service.",
        "Saved via holy intervention.",
      },
    },

    -- Blessing of Protection
    {
      id = "blessing_of_protection",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      category = "defensive",
      conditions = { spellName = "Blessing of Protection" },
      messages = {
        "Blessing of Protection. Physical immunity granted.",
        "Blessed bubble deployed.",
        "The Light shields the faithful.",
        "Melee attacks declined with divine authority.",
        "If swords are the problem, the Light is the solution.",
        "Protection granted. The Light approves.",
        "Physical damage: not today.",
        "Blessing deployed. Stay safe.",
      },
    },

    -- Blessing of Freedom
    {
      id = "blessing_of_freedom",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      category = "utility",
      conditions = { spellName = "Blessing of Freedom" },
      messages = {
        "Blessing of Freedom. Movement unrestricted.",
        "Freedom granted via divine decree.",
        "Slows and roots: removed.",
        "The Light liberates.",
        "If Midnight wanted to slow us, too bad.",
        "Freedom blessed upon the worthy.",
        "Movement debuffs cancelled by holy authority.",
        "Liberty granted. Run free.",
      },
    },

    -- Avenging Wrath
    {
      id = "avenging_wrath",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 45,
      category = "cooldowns",
      conditions = { spellName = "Avenging Wrath" },
      messages = {
        "Avenging Wrath. Holy fury activated.",
        "Righteous anger engaged.",
        "The Light has opinions. They are aggressive.",
        "Divine power spike incoming.",
        "If Midnight thought I was nice, it was mistaken.",
        "Wrath mode: on.",
        "Holy vengeance online.",
        "The Light judges. Harshly.",
      },
    },

    -- Hammer of Justice
    {
      id = "hammer_of_justice",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 12,
      category = "utility",
      conditions = { spellName = "Hammer of Justice" },
      messages = {
        "Hammer of Justice. Stun delivered.",
        "Judgement via hammer.",
        "You have been tried and stunned.",
        "The Light brings order. Aggressively.",
        "If Midnight needs a timeout, here it is.",
        "Justice hammer deployed.",
        "Holy stun online.",
        "Order restored via blunt force.",
      },
    },

    -- Word of Glory
    {
      id = "word_of_glory",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      category = "utility",
      conditions = { spellName = "Word of Glory" },
      messages = {
        "Word of Glory. Healing via holy words.",
        "The Light mends wounds.",
        "Glorious healing deployed.",
        "HP restored through divine vocabulary.",
        "If damage was done, it has been undone.",
        "Glory granted. Health included.",
        "Holy restoration online.",
        "The Light speaks. HP listens.",
      },
    },

    -- Divine Steed
    {
      id = "divine_steed",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      category = "movement",
      conditions = { spellName = "Divine Steed" },
      messages = {
        "Divine Steed. Blessed speed engaged.",
        "The Light provides a horse. Temporarily.",
        "Galloping with divine approval.",
        "Fast travel via holy steed.",
        "If Midnight wants to chase me, good luck.",
        "Blessed mount deployed.",
        "Speed granted by the Light.",
        "Divine horse mode: activated.",
      },
    },

    -- Consecration
    {
      id = "consecration",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      category = "rotation",
      conditions = { spellName = "Consecration" },
      messages = {
        "Consecration. This ground is now holy.",
        "Blessed circle deployed.",
        "The Light claims this territory.",
        "Sacred ground online.",
        "If Midnight stands here, it will regret it.",
        "Consecrated area established.",
        "Holy zone activated.",
        "The floor is now blessed. And dangerous.",
      },
    },

    -- Judgement
    {
      id = "judgement",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      category = "rotation",
      conditions = { spellName = "Judgement" },
      messages = {
        "Judgement. You have been evaluated.",
        "Verdict delivered via holy light.",
        "The Light judges. You lose.",
        "Judgement cast. Guilty as charged.",
        "If Midnight wanted mercy, wrong class.",
        "Holy verdict: guilty.",
        "Judged and found wanting.",
        "The Light has opinions about you.",
      },
    },

    -- Spec change
    {
      id = "spec_changed",
      event = "PLAYER_SPECIALIZATION_CHANGED",
      cooldown = 10,
      messages = {
        "Spec shift detected: <spec>. The Light adapts.",
        "<spec> mode. Justice recalibrated.",
        "Switched to <spec>. The Light provides versatility.",
        "<spec> selected. Holy strategy adjusted.",
        "New spec, same righteousness: <spec>.",
      },
    },

    -- ====================================================================
    -- PROTECTION PALADIN SPEC-SPECIFIC TRIGGERS (SpecID: 66)
    -- ====================================================================
    {
      id = "paladin_avengers_shield",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 10,
      category = "rotation",
      conditions = { specID = 66, spellName = "Avenger's Shield" },
      messages = {
        "Avenger's Shield. Captain Azeroth reporting.",
        "Shield throw deployed. Physics optional.",
        "Avenger's Shield. Boomerang of justice.",
        "Throwing my shield because I can.",
        "Shield toss. It comes back, trust me.",
        "If Midnight wants ranged, I have a shield.",
      },
    },
    {
      id = "paladin_shield_righteous",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 8,
      category = "defensive",
      conditions = { specID = 66, spellName = "Shield of the Righteous" },
      messages = {
        "Shield of the Righteous. Armored up.",
        "Righteous defense activated.",
        "Shield up. Good luck hitting me.",
        "The Light protects.",
        "Holy mitigation engaged.",
      },
    },
    {
      id = "paladin_guardian_kings",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      category = "cooldowns",
      conditions = { specID = 66, spellName = "Guardian of Ancient Kings" },
      messages = {
        "Guardian of Ancient Kings. Backup has arrived.",
        "Summoning my angelic bodyguard.",
        "Guardian online. I have divine backup.",
        "The Ancient Kings stand with me.",
        "Guardian summoned. Try hitting me now.",
        "If Midnight wants me, it will have to go through my guardian.",
      },
    },
    {
      id = "paladin_ardent_defender",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      category = "defensive",
      conditions = { specID = 66, spellName = "Ardent Defender" },
      messages = {
        "Ardent Defender. Death is not an option.",
        "Ardent Defender active. I refuse to die.",
        "Activating my 'nope' button.",
        "Ardent Defender up. Plot armor engaged.",
        "The Light denies death. Temporarily.",
      },
    },
    {
      id = "paladin_hammer_righteous",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 10,
      category = "rotation",
      conditions = { specID = 66, spellName = "Hammer of the Righteous" },
      messages = {
        "Hammer of the Righteous. Smiting evil.",
        "Righteous hammer deployed.",
        "Hammer time. Holy edition.",
        "Smiting with divine authority.",
        "If Midnight stands here, it gets hammered.",
      },
    },
    {
      id = "paladin_blessing_sacrifice",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      category = "utility",
      conditions = { specID = 66, spellName = "Blessing of Sacrifice" },
      messages = {
        "Blessing of Sacrifice on <target>. I'll take that hit.",
        "Protecting <target> with my life.",
        "Blessing of Sacrifice. Your pain is mine.",
        "Taking damage for <target>. That's what tanks do.",
        "The Light redirects harm through me.",
      },
    },

    -- ====================================================================
    -- RETRIBUTION PALADIN SPEC-SPECIFIC TRIGGERS (SpecID: 70)
    -- ====================================================================
    {
      id = "paladin_templar_verdict",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 12,
      category = "rotation",
      conditions = { specID = 70, spellName = "Templar's Verdict" },
      messages = {
        "Templar's Verdict. Judgement delivered.",
        "Verdict: guilty. Sentence: pain.",
        "Holy finisher deployed.",
        "The Light has ruled against you.",
        "Templar's justice served.",
        "If Midnight wanted mercy, wrong paladin.",
      },
    },
    {
      id = "paladin_divine_storm",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      category = "rotation",
      conditions = { specID = 70, spellName = "Divine Storm" },
      messages = {
        "Divine Storm. Holy AoE engaged.",
        "Spinning righteous fury.",
        "Storm of justice deployed.",
        "The Light whirls with wrath.",
        "Divine hurricane activated.",
      },
    },
    {
      id = "paladin_wake_of_ashes",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      category = "cooldowns",
      conditions = { specID = 70, spellName = "Wake of Ashes" },
      messages = {
        "Wake of Ashes. Holy power surge.",
        "Ashes of the fallen. Power for the righteous.",
        "Wake deployed. Holy generation engaged.",
        "From ashes, strength.",
        "The Light rises from destruction.",
      },
    },
    {
      id = "paladin_execution_sentence",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      category = "cooldowns",
      conditions = { specID = 70, spellName = "Execution Sentence" },
      messages = {
        "Execution Sentence. Countdown to justice.",
        "Sentence passed. Execution imminent.",
        "Divine judgement: delayed, devastating.",
        "The Light has issued a warrant.",
        "Execution protocol initiated.",
      },
    },
    {
      id = "paladin_crusader_strike",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      category = "rotation",
      conditions = { specID = 70, spellName = "Crusader Strike" },
      messages = {
        "Crusader Strike. Righteous impact.",
        "Striking with holy purpose.",
        "Crusade mode engaged.",
        "The Light hits hard.",
        "Holy power generated via violence.",
      },
    },

    -- ====================================================================
    -- HOLY PALADIN SPEC-SPECIFIC TRIGGERS (SpecID: 65)
    -- ====================================================================
    {
      id = "paladin_holy_shock",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 10,
      category = "utility",
      conditions = { specID = 65, spellName = "Holy Shock" },
      messages = {
        "Holy Shock. Healing or harming as needed.",
        "Shock therapy. Light edition.",
        "Holy versatility deployed.",
        "Shock delivered. The Light decides the effect.",
        "Emergency shock. HP or damage incoming.",
      },
    },
    {
      id = "paladin_light_of_dawn",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      category = "utility",
      conditions = { specID = 65, spellName = "Light of Dawn" },
      messages = {
        "Light of Dawn. AoE healing deployed.",
        "Dawn breaks. HP restored.",
        "The Light spreads. Everyone heals.",
        "Morning has come. Wounds mend.",
        "Dawn's radiance engaged.",
      },
    },
    {
      id = "paladin_beacon_of_light",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      category = "utility",
      conditions = { specID = 65, spellName = "Beacon of Light" },
      messages = {
        "Beacon of Light. Healing relay established.",
        "Beacon placed. Passive healing online.",
        "Light beacon deployed. You're covered.",
        "The Light watches over <target>.",
        "Beacon active. Healing transferred.",
      },
    },
    {
      id = "paladin_holy_prism",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 15,
      category = "utility",
      conditions = { specID = 65, spellName = "Holy Prism" },
      messages = {
        "Holy Prism. Light refracted.",
        "Prism deployed. Healing spreads.",
        "The Light divides and heals.",
        "Prism online. Radiant restoration.",
        "Refracted holiness engaged.",
      },
    },
    {
      id = "paladin_aura_mastery",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "cooldowns",
      conditions = { specID = 65, spellName = "Aura Mastery" },
      messages = {
        "Aura Mastery. Protective aura amplified.",
        "Mastery engaged. Group protection online.",
        "Aura maximized. The Light shields all.",
        "Protective field deployed.",
        "Mastery of Light activated.",
      },
    },
    {
      id = "paladin_avenging_crusader",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 45,
      category = "cooldowns",
      conditions = { specID = 65, spellName = "Avenging Crusader" },
      messages = {
        "Avenging Crusader. Healing through violence.",
        "Crusade mode. Damage heals.",
        "The Light justifies aggressive healing.",
        "Attacking to save lives. Paladin logic.",
        "Crusader online. Pain becomes HP.",
      },
    },
  },
})
