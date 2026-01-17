-- SpeakinLite - Options UI
-- Works with Interface Options (still supported) and provides shortcuts via /sl options, /sl packs, /sl editor.

SpeakinLite = SpeakinLite or {}
local addon = SpeakinLite

local function MakeTitle(parent, text)
  local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText(text)
  return title
end

local function MakePara(parent, anchor, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
  fs:SetWidth(560)
  fs:SetJustifyH("LEFT")
  fs:SetText(text)
  return fs
end

local function MakeSubTitle(parent, anchor, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -14)
  fs:SetText(text)
  return fs
end

local function MakeCheckbox(parent, name, anchor, label, tooltip)
  local cb = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
  cb.Text:SetText(label)
  if tooltip and tooltip ~= "" then
    cb.tooltipText = label
    cb.tooltipRequirement = tooltip
  end
  return cb
end

local function MakeSlider(parent, name, anchor, label, minVal, maxVal, step)
  local s = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
  s:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -18)
  s:SetMinMaxValues(minVal, maxVal)
  s:SetValueStep(step)
  s:SetObeyStepOnDrag(true)
  s:SetWidth(280)

  _G[name .. "Text"]:SetText(label)
  _G[name .. "Low"]:SetText(tostring(minVal))
  _G[name .. "High"]:SetText(tostring(maxVal))
  return s
end

local function MakeDropdown(parent, name, anchor, label, width)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -18)
  fs:SetText(label)

  local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
  dd:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", -16, -2)
  UIDropDownMenu_SetWidth(dd, width or 180)
  return dd, fs
end

local function SetDropdownText(dd, text)
  UIDropDownMenu_SetText(dd, text)
end

local function BuildMainPanel()
  local panel = CreateFrame("Frame")
  panel.name = "Emote Control"

  local title = MakeTitle(panel, "SpeakinLite")
  local desc = MakePara(panel, title, "Lightweight speech/announcement addon with modular phrase packs. Use /sl help for commands.")

  local cbEnabled = MakeCheckbox(panel, "SpeakinLite_CB_Enabled", desc, "Enable SpeakinLite", "Master toggle.")

  local outputHeader = MakeSubTitle(panel, cbEnabled, "Output")
  local ddChannel = MakeDropdown(panel, "SpeakinLite_DD_Channel", outputHeader, "Default channel", 200)
  local cbFallback = MakeCheckbox(panel, "SpeakinLite_CB_Fallback", ddChannel, "If SAY/YELL blocked, use EMOTE instead", "Recommended On. EMOTE works everywhere!")

  local spamHeader = MakeSubTitle(panel, cbFallback, "Spam control")
  local sCooldown = MakeSlider(panel, "SpeakinLite_SL_Cooldown", spamHeader, "Global cooldown (seconds)", 0, 60, 1)
  local sMaxPerMin = MakeSlider(panel, "SpeakinLite_SL_MaxPerMin", sCooldown, "Max messages per minute", 0, 60, 1)
  local ddRotation = MakeDropdown(panel, "SpeakinLite_DD_Rotation", sMaxPerMin, "Rotation protection", 200)

  local triggerHeader = MakeSubTitle(panel, ddRotation, "Triggers")
  local cbSpell = MakeCheckbox(panel, "SpeakinLite_CB_Spell", triggerHeader, "Enable spell triggers", "Announce spell casts (UNIT_SPELLCAST_SUCCEEDED).")
  local cbNonSpell = MakeCheckbox(panel, "SpeakinLite_CB_NonSpell", cbSpell, "Enable non-spell triggers", "Announce combat, zone, death, spec changes, etc.")
  local cbOnlyLearned = MakeCheckbox(panel, "SpeakinLite_CB_Learned", cbNonSpell, "Only announce learned spells", "Recommended On. Extra safety for edge cases.")

  local catsHeader = MakeSubTitle(panel, cbOnlyLearned, "Categories")
  local cbCatRotation = MakeCheckbox(panel, "SpeakinLite_CB_CatRotation", catsHeader, "Rotation", "Spell rotation / frequent casts")
  local cbCatUtility = MakeCheckbox(panel, "SpeakinLite_CB_CatUtility", cbCatRotation, "Utility", "Summons, teleports, helpers")
  local cbCatDef = MakeCheckbox(panel, "SpeakinLite_CB_CatDef", cbCatUtility, "Defensive", "Shields, immunities, mitigations")
  local cbCatMove = MakeCheckbox(panel, "SpeakinLite_CB_CatMove", cbCatDef, "Movement", "Dashes, blinks, speed")
  local cbCatCDs = MakeCheckbox(panel, "SpeakinLite_CB_CatCDs", cbCatMove, "Cooldowns", "Big cooldown buttons")
  local cbCatFlavor = MakeCheckbox(panel, "SpeakinLite_CB_CatFlavor", cbCatCDs, "Flavor", "Extra jokes / lore / vibes")

  local btnAnchor = cbCatFlavor
  local btnPacks = CreateFrame("Button", "SpeakinLite_Btn_Packs", panel, "UIPanelButtonTemplate")
  btnPacks:SetSize(160, 22)
  btnPacks:SetPoint("TOPLEFT", btnAnchor, "BOTTOMLEFT", 0, -18)
  btnPacks:SetText("Open Packs")

  local btnEditor = CreateFrame("Button", "SpeakinLite_Btn_Editor", panel, "UIPanelButtonTemplate")
  btnEditor:SetSize(160, 22)
  btnEditor:SetPoint("LEFT", btnPacks, "RIGHT", 10, 0)
  btnEditor:SetText("Open Trigger Editor")

  local warn = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
  warn:SetPoint("TOPLEFT", btnPacks, "BOTTOMLEFT", 0, -10)
  warn:SetWidth(560)
  warn:SetJustifyH("LEFT")
  warn:SetText("Tip: SAY / EMOTE is restricted in some situations. Self output is always safe.")

  local function Refresh()
    local theDb = addon:GetDB()
    if type(theDb) ~= "table" then return end

    cbEnabled:SetChecked(theDb.enabled ~= false)
    cbFallback:SetChecked(theDb.fallbackToSelf ~= false)
    cbSpell:SetChecked(theDb.enableSpellTriggers ~= false)
    cbNonSpell:SetChecked(theDb.enableNonSpellTriggers ~= false)
    cbOnlyLearned:SetChecked(theDb.onlyLearnedSpells ~= false)

    sCooldown:SetValue(addon:ClampNumber(tonumber(theDb.globalCooldown) or 6, 0, 60))
    sMaxPerMin:SetValue(addon:ClampNumber(tonumber(theDb.maxPerMinute) or 12, 0, 60))

    local ch = (type(theDb.channel) == "string" and theDb.channel) or "SELF"
    SetDropdownText(ddChannel, ch)

    local rot = (type(theDb.rotationProtection) == "string" and theDb.rotationProtection) or "MEDIUM"
    SetDropdownText(ddRotation, rot)

    theDb.categoriesEnabled = theDb.categoriesEnabled or {}
    cbCatRotation:SetChecked(theDb.categoriesEnabled.rotation ~= false)
    cbCatUtility:SetChecked(theDb.categoriesEnabled.utility ~= false)
    cbCatDef:SetChecked(theDb.categoriesEnabled.defensive ~= false)
    cbCatMove:SetChecked(theDb.categoriesEnabled.movement ~= false)
    cbCatCDs:SetChecked(theDb.categoriesEnabled.cooldowns ~= false)
    cbCatFlavor:SetChecked(theDb.categoriesEnabled.flavor ~= false)
  end

  panel:SetScript("OnShow", Refresh)

  cbEnabled:SetScript("OnClick", function(self)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    theDb.enabled = self:GetChecked() and true or false
  end)

  cbFallback:SetScript("OnClick", function(self)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    theDb.fallbackToSelf = self:GetChecked() and true or false
  end)

  cbSpell:SetScript("OnClick", function(self)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    theDb.enableSpellTriggers = self:GetChecked() and true or false
  end)

  cbNonSpell:SetScript("OnClick", function(self)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    theDb.enableNonSpellTriggers = self:GetChecked() and true or false
  end)

  cbOnlyLearned:SetScript("OnClick", function(self)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    theDb.onlyLearnedSpells = self:GetChecked() and true or false
  end)

  local function CatSetter(key)
    return function(self)
      local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
      theDb.categoriesEnabled = theDb.categoriesEnabled or {}
      theDb.categoriesEnabled[key] = self:GetChecked() and true or false
    end
  end

  cbCatRotation:SetScript("OnClick", CatSetter("rotation"))
  cbCatUtility:SetScript("OnClick", CatSetter("utility"))
  cbCatDef:SetScript("OnClick", CatSetter("defensive"))
  cbCatMove:SetScript("OnClick", CatSetter("movement"))
  cbCatCDs:SetScript("OnClick", CatSetter("cooldowns"))
  cbCatFlavor:SetScript("OnClick", CatSetter("flavor"))

  sCooldown:SetScript("OnValueChanged", function(self, value)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    local v = addon:ClampNumber(tonumber(value) or 6, 0, 60)
    theDb.globalCooldown = v
    _G["SpeakinLite_SL_CooldownText"]:SetText("Global cooldown (seconds): " .. v)
  end)

  sMaxPerMin:SetScript("OnValueChanged", function(self, value)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    local v = addon:ClampNumber(tonumber(value) or 12, 0, 60)
    theDb.maxPerMinute = v
    _G["SpeakinLite_SL_MaxPerMinText"]:SetText("Max messages per minute: " .. v)
  end)

  UIDropDownMenu_Initialize(ddChannel, function(self, level)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end

    local function Add(text, value)
      local info = UIDropDownMenu_CreateInfo()
      info.text = text
      info.value = value
      info.func = function()
        theDb.channel = value
        SetDropdownText(ddChannel, value)
      end
      UIDropDownMenu_AddButton(info)
    end

    Add("Self", "SELF")
    Add("Party", "PARTY")
    Add("Raid", "RAID")
    Add("Instance", "INSTANCE")
    Add("Say", "SAY")
    Add("Yell", "YELL")
    Add("Emote", "EMOTE")
  end)

  UIDropDownMenu_Initialize(ddRotation, function(self, level)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end

    local function Add(text, value, hint)
      local info = UIDropDownMenu_CreateInfo()
      info.text = text
      info.value = value
      info.func = function()
        theDb.rotationProtection = value
        SetDropdownText(ddRotation, value)
      end
      if hint then
        info.tooltipTitle = text
        info.tooltipText = hint
      end
      UIDropDownMenu_AddButton(info)
    end

    Add("Off", "OFF", "No extra floor beyond per-trigger cooldown.")
    Add("Low", "LOW", "More quiet. Forces spell triggers to at least 12s cooldown.")
    Add("Medium", "MEDIUM", "Default. Forces spell triggers to at least 6s cooldown.")
    Add("High", "HIGH", "More chatty. Forces spell triggers to at least 2s cooldown.")
  end)

  btnPacks:SetScript("OnClick", function()
    if type(addon.OpenPacksPanel) == "function" then
      addon:OpenPacksPanel()
    end
  end)

  btnEditor:SetScript("OnClick", function()
    if type(addon.OpenEditor) == "function" then
      addon:OpenEditor()
    end
  end)

  return panel
end

local function BuildPacksPanel()
  local panel = CreateFrame("Frame")
  panel.name = "Packs"
  panel.parent = "SpeakinLite"

  local title = MakeTitle(panel, "SpeakinLite Packs")
  local desc = MakePara(panel, title, "Enable or disable phrase packs. Changes apply immediately.")

  local checkboxes = {}

  local function Clear()
    for _, cb in ipairs(checkboxes) do
      cb:Hide()
      cb:SetParent(nil)
    end
    wipe(checkboxes)
  end

  local function Refresh()
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    if type(theDb.packEnabled) ~= "table" then theDb.packEnabled = {} end

    Clear()

    local sorted = {}
    for id, pack in pairs(addon.Packs or {}) do
      table.insert(sorted, { id = id, name = (pack and pack.name) or id })
    end
    table.sort(sorted, function(a, b) return a.name < b.name end)

    local anchor = desc
    for i, row in ipairs(sorted) do
      local cb = MakeCheckbox(panel, "SpeakinLite_PackCB_" .. i, anchor, row.name .. " (" .. row.id .. ")", "")
      cb:SetChecked(theDb.packEnabled[row.id] ~= false)
      cb:SetScript("OnClick", function(self)
        theDb.packEnabled[row.id] = self:GetChecked() and true or false
        if type(addon.BuildTriggerIndex) == "function" then
          addon:BuildTriggerIndex()
        end
      end)
      anchor = cb
      table.insert(checkboxes, cb)
    end
  end

  panel:SetScript("OnShow", Refresh)
  return panel
end

local mainPanel = BuildMainPanel()
local packsPanel = BuildPacksPanel()

local function TryLoadInterfaceOptions()
  if InterfaceOptions_AddCategory and InterfaceOptionsFrame_OpenToCategory then
    return true
  end

  if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
    pcall(C_AddOns.LoadAddOn, "Blizzard_InterfaceOptions")
  end
  if type(LoadAddOn) == "function" then
    pcall(LoadAddOn, "Blizzard_InterfaceOptions")
  end

  return (InterfaceOptions_AddCategory and InterfaceOptionsFrame_OpenToCategory) and true or false
end

local interfaceOptionsReady = TryLoadInterfaceOptions()

if interfaceOptionsReady then
  pcall(InterfaceOptions_AddCategory, mainPanel)
  pcall(InterfaceOptions_AddCategory, packsPanel)
end

function addon:OpenOptions()
  -- Retail 10.0+ uses the Settings UI; prefer it when available.
  if Settings and type(Settings.OpenToCategory) == "function" and type(addon.OpenSettings) == "function" then
    local opened = addon:OpenSettings()
    if opened then return end
    -- If Settings panel failed, fall through to legacy UI
  end

  -- Try legacy Interface Options
  if interfaceOptionsReady and InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory(mainPanel)
    InterfaceOptionsFrame_OpenToCategory(mainPanel)
    return
  end

  -- Last resort: try directly opening settings
  if Settings then
    local ok = pcall(Settings.OpenToCategory, "SpeakinLite")
    if ok then return end
  end

  addon:Print("Options UI not available. Use /sl help for commands or check Interface Options manually.")
end

function addon:OpenPacksPanel()
  if Settings and type(Settings.OpenToCategory) == "function" and type(addon.OpenSettings) == "function" then
    addon:OpenSettings()
    return
  end

  if interfaceOptionsReady and InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory(packsPanel)
    InterfaceOptionsFrame_OpenToCategory(packsPanel)
    return
  end

  addon:Print("Packs UI not available. Use /sl help for commands.")
end
