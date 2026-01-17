-- SpeakinLite - Daily Activities Pack
-- Non-combat flavor triggers for everyday activities

SpeakinLite = SpeakinLite or {}
local addon = SpeakinLite

local pack = {
  name = "DailyActivities",
  version = "0.8.0",
  triggers = {
    -- ========================================
    -- Mount Summons
    -- ========================================
    {
      id = "mount_ground",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellName = "Summon Traveling Mount" },
      messages = {
        "summons their trusty mount.",
        "hops onto their mount with practiced ease.",
        "calls forth their mount.",
        "mounts up and prepares to ride.",
        "whistles for their loyal companion.",
      },
    },
    {
      id = "mount_flying",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellName = "Summon Flying Mount" },
      messages = {
        "takes to the skies!",
        "spreads their wings and prepares for flight.",
        "summons their flying mount with a flourish.",
        "prepares for aerial travel.",
        "calls down their winged companion.",
      },
    },

    -- ========================================
    -- Hunter Pets
    -- ========================================
    {
      id = "call_pet",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 883 }, -- Call Pet 1
      messages = {
        "whistles loudly, calling their faithful companion.",
        "summons their loyal beast.",
        "calls their pet to their side.",
        "beckons their animal companion.",
        "reunites with their trusted pet.",
      },
    },
    {
      id = "revive_pet",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "flavor",
      channel = "SAY",
      conditions = { spellID = 982 }, -- Revive Pet
      messages = {
        "It's okay, <pet>. I've got you.",
        "Come back to me, friend.",
        "Not losing you today!",
        "Rise, my companion!",
        "Welcome back, <pet>!",
      },
    },
    {
      id = "dismiss_pet",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 2641 }, -- Dismiss Pet
      messages = {
        "sends their pet away for now.",
        "dismisses their companion.",
        "bids farewell to their pet temporarily.",
        "releases their beast from service.",
      },
    },

    -- ========================================
    -- Warlock Pets
    -- ========================================
    {
      id = "summon_imp",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 688 },
      messages = {
        "summons an imp with a puff of fel energy.",
        "calls forth their impish servant.",
        "conjures an imp to do their bidding.",
        "beckons forth a cackling imp.",
      },
    },
    {
      id = "summon_voidwalker",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 697 },
      messages = {
        "tears open reality, summoning a voidwalker.",
        "calls a voidwalker from the shadows.",
        "conjures a hulking voidwalker guardian.",
        "rips a voidwalker from the void itself.",
      },
    },
    {
      id = "summon_succubus",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 712 },
      messages = {
        "summons a seductive succubus.",
        "calls forth a deadly succubus.",
        "conjures a charming yet dangerous ally.",
        "beckons a succubus from the nether.",
      },
    },
    {
      id = "summon_felhunter",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 691 },
      messages = {
        "summons a felhunter to devour magic.",
        "calls forth a mana-hungry felhunter.",
        "conjures a felhunter demon.",
        "releases a felhunter from the Twisting Nether.",
      },
    },

    -- ========================================
    -- Mage Summons
    -- ========================================
    {
      id = "conjure_refreshment",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 190336 },
      messages = {
        "conjures fresh food and water from thin air.",
        "creates magical refreshments with a wave.",
        "summons a feast of arcane sustenance.",
        "produces food and drink through magic.",
      },
    },
    {
      id = "summon_table",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      category = "flavor",
      channel = "SAY",
      conditions = { spellID = 43987 },
      messages = {
        "Table's up! Help yourselves!",
        "Conjured a feast for everyone!",
        "Food and drink ready!",
        "Refreshments for all!",
        "Banquet is served!",
      },
    },

    -- ========================================
    -- Other Activities
    -- ========================================
    {
      id = "check_mail",
      event = "MAIL_SHOW",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "checks their mailbox, hoping for a letter.",
        "opens the mailbox, expecting something important.",
        "rummages through the mail, looking for treasures.",
        "checks for new mail, a daily ritual.",
        "sorts through their correspondence.",
      },
    },
    {
      id = "open_bank",
      event = "BANKFRAME_OPENED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "accesses their bank vault.",
        "opens their personal storage.",
        "digs through their stashed belongings.",
        "checks their savings and stored items.",
        "visits the bank to manage their hoard.",
      },
    },
    {
      id = "talk_to_vendor",
      event = "MERCHANT_SHOW",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "browses the merchant's wares.",
        "examines the goods for sale.",
        "haggles with the vendor.",
        "looks for useful supplies.",
        "considers making a purchase.",
      },
    },
    {
      id = "start_fishing",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 10,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 131474 }, -- Fishing
      messages = {
        "casts their line, hoping for a bite.",
        "settles in for some peaceful fishing.",
        "patiently waits for a tug on the line.",
        "begins fishing, the water looks promising.",
        "drops a line into the water.",
      },
    },
    {
      id = "cooking",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 818 }, -- Basic Campfire
      messages = {
        "starts a fire and prepares to cook.",
        "sets up camp and lights a fire.",
        "creates a cozy campfire.",
        "kindles a fire for cooking.",
        "builds a campfire with practiced hands.",
      },
    },
    {
      id = "hearthstone",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      category = "flavor",
      channel = "EMOTE",
      conditions = { spellID = 8690 },
      messages = {
        "channels their hearthstone, preparing to teleport home.",
        "activates their hearthstone with a nostalgic sigh.",
        "uses their hearthstone to return home.",
        "begins the journey home via hearthstone.",
        "teleports back to their inn with magic.",
      },
    },
    {
      id = "flight_path",
      event = "TAXIMAP_OPENED",
      cooldown = 60,
      category = "flavor",
      channel = "EMOTE",
      messages = {
        "consults the flight master about travel routes.",
        "plans their next flight path.",
        "examines the available flight routes.",
        "considers where to fly next.",
        "speaks with the flight master.",
      },
    },
  },
}

addon:RegisterPack(pack)
