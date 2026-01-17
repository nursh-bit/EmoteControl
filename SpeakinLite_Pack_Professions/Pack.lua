-- SpeakinLite - Professions Pack
-- Triggers for profession-related activities

if not SpeakinLite or type(SpeakinLite.RegisterPack) ~= "function" then
  return
end

SpeakinLite:RegisterPack({
  id = "professions",
  name = "Professions Pack",
  defaults = { category = "flavor", intensity = 1 },
  triggers = {
    -- Cooking Fire
    {
      id = "cooking_fire",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      channel = "EMOTE",
      conditions = { spellName = "Cooking Fire" },
      messages = {
        "sets up a cooking fire, ready to prepare a feast.",
        "lights a fire, culinary mastery incoming.",
        "prepares to cook, Gordon Ramsay style.",
        "starts a cooking fire, time to make something delicious.",
      },
    },
    
    -- Fishing
    {
      id = "fishing_cast",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      channel = "EMOTE",
      conditions = { spellName = "Fishing" },
      messages = {
        "casts their line, waiting patiently.",
        "settles in for some peaceful fishing.",
        "tries their luck at fishing.",
        "casts into the water, hoping for a big catch.",
      },
    },
    
    -- Archaeology Survey
    {
      id = "archaeology_survey",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 45,
      channel = "EMOTE",
      conditions = { spellName = "Survey" },
      messages = {
        "surveys the area for ancient artifacts.",
        "searches for archaeological treasures.",
        "investigates the ground, looking for history.",
        "uses their survey tools, seeking the past.",
      },
    },
    
    -- Herbalism gathering
    {
      id = "herb_gathering",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      channel = "EMOTE",
      conditions = { spellName = "Herb Gathering" },
      messages = {
        "carefully harvests herbs from the ground.",
        "gathers herbs with practiced hands.",
        "collects valuable herbs.",
        "picks herbs, adding to their collection.",
      },
    },
    
    -- Mining
    {
      id = "mining_ore",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      channel = "EMOTE",
      conditions = { spellName = "Mining" },
      messages = {
        "strikes the ore vein with their pickaxe.",
        "mines ore, seeking valuable minerals.",
        "extracts ore from the deposit.",
        "works the ore vein, pickaxe in hand.",
      },
    },
    
    -- Skinning
    {
      id = "skinning_beast",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 20,
      channel = "EMOTE",
      conditions = { spellName = "Skinning" },
      messages = {
        "skins the beast, salvaging its hide.",
        "carefully removes the creature's hide.",
        "harvests leather from the fallen beast.",
        "skins the corpse with practiced efficiency.",
      },
    },
    
    -- Engineering gadgets
    {
      id = "engineering_gadget",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      conditions = { spellName = "Nitro Boosts" },
      messages = {
        "Nitro Boosts! ZOOM!",
        "Activating rocket boots. Hold on!",
        "Nitro engaged. Speed is life.",
        "Rocket boots firing. Wheee!",
      },
    },
    
    -- Alchemy transmute
    {
      id = "alchemy_transmute",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      channel = "EMOTE",
      conditions = { spellName = "Transmute" },
      messages = {
        "transmutes materials through alchemical mastery.",
        "performs a transmutation, science and magic combined.",
        "transforms one substance into another.",
        "completes the transmutation ritual.",
      },
    },
    
    -- Enchanting
    {
      id = "enchanting_item",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      channel = "EMOTE",
      conditions = { spellName = "Enchant" },
      messages = {
        "enchants the item with magical power.",
        "imbues the equipment with arcane energy.",
        "applies an enchantment, magic flowing.",
        "enhances the item through enchantment.",
      },
    },
    
    -- Inscription
    {
      id = "inscription_glyph",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      channel = "EMOTE",
      conditions = { spellName = "Inscription" },
      messages = {
        "carefully inscribes mystical symbols.",
        "creates a glyph with precise strokes.",
        "works on their inscription, art and magic.",
        "inscribes runes with practiced skill.",
      },
    },
    
    -- Jewelcrafting
    {
      id = "jewelcrafting_gem",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      channel = "EMOTE",
      conditions = { spellName = "Jewelcrafting" },
      messages = {
        "cuts and polishes a precious gem.",
        "crafts jewelry with expert precision.",
        "works the gem, revealing its beauty.",
        "shapes the gemstone into perfection.",
      },
    },
    
    -- Leatherworking
    {
      id = "leatherworking_craft",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      channel = "EMOTE",
      conditions = { spellName = "Leatherworking" },
      messages = {
        "crafts leather armor with skill.",
        "works the leather into useful gear.",
        "creates leatherwork, sturdy and reliable.",
        "fashions leather into equipment.",
      },
    },
    
    -- Tailoring
    {
      id = "tailoring_craft",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      channel = "EMOTE",
      conditions = { spellName = "Tailoring" },
      messages = {
        "sews cloth into fine garments.",
        "tailors fabric with expert hands.",
        "creates cloth armor, thread and needle.",
        "weaves cloth into useful equipment.",
      },
    },
    
    -- Blacksmithing
    {
      id = "blacksmithing_craft",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 30,
      channel = "EMOTE",
      conditions = { spellName = "Blacksmithing" },
      messages = {
        "hammers metal at the forge.",
        "smiths equipment with fire and steel.",
        "forges metal into useful gear.",
        "works the anvil, sparks flying.",
      },
    },
    
    -- Soulwell (Warlock)
    {
      id = "soulwell",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      conditions = { class = "WARLOCK", spellName = "Create Soulwell" },
      messages = {
        "Soulwell deployed. Healthstones for everyone!",
        "Creating a Soulwell. Grab your stones.",
        "Soulwell up. Click it before we pull.",
        "Healthstones available. You're welcome.",
      },
    },
    
    -- Refreshment Table (Mage)
    {
      id = "refreshment_table",
      event = "UNIT_SPELLCAST_SUCCEEDED",
      cooldown = 60,
      conditions = { class = "MAGE", spellName = "Conjure Refreshment Table" },
      messages = {
        "Refreshment Table conjured. Eat up!",
        "Food and water available. Buffet's open.",
        "Conjured a feast. Help yourselves.",
        "Table's ready. Mage catering service.",
      },
    },
  },
})
