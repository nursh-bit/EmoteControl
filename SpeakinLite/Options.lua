-- EmoteControl - Options Interface
-- Provides both legacy Interface Options and modern settings UI
-- Shortcuts available via /sl options, /sl packs, /sl editor

EmoteControl = EmoteControl or {}
SpeakinLite = EmoteControl  -- Backward compatibility alias
local addon = EmoteControl

-- Helper function to create and configure font strings with common patterns
local function MakeFontString(parent, anchor, fontSize, spacing, width, justifyH, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", fontSize or "GameFontHighlight")
  fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -(spacing or 6))
  if width then fs:SetWidth(width) end
  if justifyH then fs:SetJustifyH(justifyH) end
  if text then fs:SetText(text) end
  return fs
end

local function MakeTitle(parent, text)
  local title = MakeFontString(parent, parent, "GameFontNormalLarge", 16, nil, nil, text)
  title:SetPoint("TOPLEFT", 16, -16)
  return title
end

local function MakePara(parent, anchor, text)
  return MakeFontString(parent, anchor, "GameFontHighlight", 6, 560, "LEFT", text)
end

local function MakeSubTitle(parent, anchor, text)
  return MakeFontString(parent, anchor, "GameFontNormal", 14, nil, nil, text)
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

  local title = MakeTitle(panel, "Emote Control")
  local desc = MakePara(panel, title, "Lightweight speech/announcement addon with modular phrase packs. Use /sl help for commands.")

  local cbEnabled = MakeCheckbox(panel, "EmoteControl_CB_Enabled", desc, "Enable Emote Control", "Master toggle.")

  local outputHeader = MakeSubTitle(panel, cbEnabled, "Output")
  local ddChannel = MakeDropdown(panel, "EmoteControl_DD_Channel", outputHeader, "Default channel", 200)
  local cbFallback = MakeCheckbox(panel, "EmoteControl_CB_Fallback", ddChannel, "If SAY/YELL blocked, use EMOTE instead", "Recommended On. EMOTE works everywhere!")

  local spamHeader = MakeSubTitle(panel, cbFallback, "Spam control")
  local sCooldown = MakeSlider(panel, "EmoteControl_SL_Cooldown", spamHeader, "Global cooldown (seconds)", 0, 60, 1)
  local sMaxPerMin = MakeSlider(panel, "EmoteControl_SL_MaxPerMin", sCooldown, "Max messages per minute", 0, 60, 1)
  local ddRotation = MakeDropdown(panel, "EmoteControl_DD_Rotation", sMaxPerMin, "Rotation protection", 200)

  local triggerHeader = MakeSubTitle(panel, ddRotation, "Triggers")
  local cbSpell = MakeCheckbox(panel, "EmoteControl_CB_Spell", triggerHeader, "Enable spell triggers", "Announce spell casts (UNIT_SPELLCAST_SUCCEEDED).")
  local cbNonSpell = MakeCheckbox(panel, "EmoteControl_CB_NonSpell", cbSpell, "Enable non-spell triggers", "Announce combat, zone, death, spec changes, etc.")
  local cbOnlyLearned = MakeCheckbox(panel, "EmoteControl_CB_Learned", cbNonSpell, "Only announce learned spells", "Recommended On. Extra safety for edge cases.")

  local eventHeader = MakeSubTitle(panel, cbOnlyLearned, "Event Toggles")
  local cbCombatLog = MakeCheckbox(panel, "EmoteControl_CB_CombatLog", eventHeader, "Enable combat log triggers", "Crits, dodges, parries, interrupts.")
  local cbLoot = MakeCheckbox(panel, "EmoteControl_CB_Loot", cbCombatLog, "Enable loot triggers", "Epic/legendary drops.")
  local cbAchievement = MakeCheckbox(panel, "EmoteControl_CB_Achievements", cbLoot, "Enable achievement triggers", "ACHIEVEMENT_EARNED.")
  local cbLevelUp = MakeCheckbox(panel, "EmoteControl_CB_LevelUp", cbAchievement, "Enable level-up triggers", "PLAYER_LEVEL_UP.")

  local setupHeader = MakeSubTitle(panel, cbLevelUp, "Quick Setup")
  local btnDefaults = CreateFrame("Button", "EmoteControl_Btn_Defaults", panel, "UIPanelButtonTemplate")
  btnDefaults:SetSize(200, 22)
  btnDefaults:SetPoint("TOPLEFT", setupHeader, "BOTTOMLEFT", 0, -10)
  btnDefaults:SetText("Apply Recommended Defaults")

  local catsHeader = MakeSubTitle(panel, btnDefaults, "Categories")
  local cbCatRotation = MakeCheckbox(panel, "EmoteControl_CB_CatRotation", catsHeader, "Rotation", "Spell rotation / frequent casts")
  local cbCatUtility = MakeCheckbox(panel, "EmoteControl_CB_CatUtility", cbCatRotation, "Utility", "Summons, teleports, helpers")
  local cbCatDef = MakeCheckbox(panel, "EmoteControl_CB_CatDef", cbCatUtility, "Defensive", "Shields, immunities, mitigations")
  local cbCatMove = MakeCheckbox(panel, "EmoteControl_CB_CatMove", cbCatDef, "Movement", "Dashes, blinks, speed")
  local cbCatCDs = MakeCheckbox(panel, "EmoteControl_CB_CatCDs", cbCatMove, "Cooldowns", "Big cooldown buttons")
  local cbCatFlavor = MakeCheckbox(panel, "EmoteControl_CB_CatFlavor", cbCatCDs, "Flavor", "Extra jokes / lore / vibes")

  local btnAnchor = cbCatFlavor
  local btnPacks = CreateFrame("Button", "EmoteControl_Btn_Packs", panel, "UIPanelButtonTemplate")
  btnPacks:SetSize(160, 22)
  btnPacks:SetPoint("TOPLEFT", btnAnchor, "BOTTOMLEFT", 0, -18)
  btnPacks:SetText("Open Packs")

  local btnEditor = CreateFrame("Button", "EmoteControl_Btn_Editor", panel, "UIPanelButtonTemplate")
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
    cbCombatLog:SetChecked(theDb.enableCombatLogTriggers ~= false)
    cbLoot:SetChecked(theDb.enableLootTriggers ~= false)
    cbAchievement:SetChecked(theDb.enableAchievementTriggers ~= false)
    cbLevelUp:SetChecked(theDb.enableLevelUpTriggers ~= false)

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

  cbCombatLog:SetScript("OnClick", function(self)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    theDb.enableCombatLogTriggers = self:GetChecked() and true or false
  end)

  cbLoot:SetScript("OnClick", function(self)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    theDb.enableLootTriggers = self:GetChecked() and true or false
  end)

  cbAchievement:SetScript("OnClick", function(self)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    theDb.enableAchievementTriggers = self:GetChecked() and true or false
  end)

  cbLevelUp:SetScript("OnClick", function(self)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    theDb.enableLevelUpTriggers = self:GetChecked() and true or false
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
    _G["EmoteControl_SL_CooldownText"]:SetText("Global cooldown (seconds): " .. v)
  end)

  sMaxPerMin:SetScript("OnValueChanged", function(self, value)
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    local v = addon:ClampNumber(tonumber(value) or 12, 0, 60)
    theDb.maxPerMinute = v
    _G["EmoteControl_SL_MaxPerMinText"]:SetText("Max messages per minute: " .. v)
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

  btnDefaults:SetScript("OnClick", function()
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    addon:ApplyRecommendedDefaults(theDb)
    Refresh()
    addon:Print("Applied recommended defaults.")
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
  panel.parent = "Emote Control"

  local title = MakeTitle(panel, "Emote Control Packs")
  local desc = MakePara(panel, title, "Enable or disable phrase packs. Changes apply immediately.")

  local searchLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  searchLabel:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -10)
  searchLabel:SetText("Filter")

  local searchBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
  searchBox:SetSize(200, 20)
  searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 10, 0)
  searchBox:SetAutoFocus(false)
  searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

  local checkboxes = {}

  local function Clear()
    for _, cb in ipairs(checkboxes) do
      cb:Hide()
      cb:SetParent(nil)
    end
    wipe(checkboxes)
  end

  local scroll = CreateFrame("ScrollFrame", "EmoteControl_PacksScroll", panel, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", searchLabel, "BOTTOMLEFT", 0, -10)
  scroll:SetPoint("BOTTOMRIGHT", -28, 10)

  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(1, 1)
  scroll:SetScrollChild(content)

  local function Refresh()
    local theDb = addon:GetDB(); if type(theDb) ~= "table" then return end
    if type(theDb.packEnabled) ~= "table" then theDb.packEnabled = {} end

    Clear()

    local filter = addon:SafeLower(searchBox:GetText() or "") or ""

    local sorted = {}
    if type(addon.GetPackDescriptors) == "function" then
      sorted = addon:GetPackDescriptors()
    else
      for id, pack in pairs(addon.Packs or {}) do
        table.insert(sorted, { id = id, name = (pack and pack.name) or id, loaded = true })
      end
      table.sort(sorted, function(a, b) return a.name < b.name end)
    end

    local y = -2
    for i, row in ipairs(sorted) do
      local label = row.name or row.id
      if row.id and row.id ~= label then
        label = label .. " (" .. row.id .. ")"
      end
      if row.loaded == false then
        label = label .. " (not loaded)"
      end
      if row.loadable == false then
        local reason = tostring(row.reason or "")
        if reason == "DISABLED" then
          label = label .. " (disabled in AddOns)"
        elseif reason ~= "" then
          label = label .. " (not loadable: " .. reason .. ")"
        else
          label = label .. " (not loadable)"
        end
      end

      local show = true
      if filter ~= "" and not addon:SafeLower(label):find(filter, 1, true) then
        show = false
      end

      if show then
        local cb = MakeCheckbox(content, "EmoteControl_PackCB_" .. i, content, label, "")
        cb:SetPoint("TOPLEFT", 0, y)
        local enabled = theDb.packEnabled[row.id] ~= false
        cb:SetChecked(enabled)
        if not enabled then
          local textWidget = cb.Text or cb.text
          if textWidget and textWidget.GetText and textWidget.SetText then
            textWidget:SetText(textWidget:GetText() .. " (disabled)")
          end
        end
        cb:SetScript("OnClick", function(self)
          if type(addon.SetPackEnabled) == "function" then
            addon:SetPackEnabled(row.id, self:GetChecked() and true or false, row.addonName)
          else
            theDb.packEnabled[row.id] = self:GetChecked() and true or false
            if type(addon.BuildTriggerIndex) == "function" then
              addon:BuildTriggerIndex()
            end
          end
        end)
        table.insert(checkboxes, cb)
        y = y - 28
      end
    end

    content:SetHeight(math.max(1, (-y) + 24))
  end

  panel:SetScript("OnShow", Refresh)
  searchBox:SetScript("OnTextChanged", Refresh)
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

  -- Legacy alias so users can still find "SpeakinLite" in options
  local legacyPanel = CreateFrame("Frame")
  legacyPanel.name = "SpeakinLite"
  legacyPanel:SetScript("OnShow", function()
    if InterfaceOptionsFrame_OpenToCategory then
      InterfaceOptionsFrame_OpenToCategory(mainPanel)
      InterfaceOptionsFrame_OpenToCategory(mainPanel)
    end
  end)
  pcall(InterfaceOptions_AddCategory, legacyPanel)
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
    local ok = pcall(Settings.OpenToCategory, "Emote Control")
    if ok then return end
    ok = pcall(Settings.OpenToCategory, "SpeakinLite")
    if ok then return end
  end

  addon:Print("Options UI not available. Use /sl help for commands or check Interface Options manually.")
end

function addon:OpenPacksPanel()
  if Settings and type(Settings.OpenToCategory) == "function" then
    local function TryOpen(target)
      if target == nil then return false end
      local ok = pcall(Settings.OpenToCategory, target)
      return ok == true
    end

    if addon._settingsPacksCategory and TryOpen(addon._settingsPacksCategory) then return end
    if addon._settingsPacksCategory and addon._settingsPacksCategory.ID and TryOpen(addon._settingsPacksCategory.ID) then return end
    if addon._settingsPacksCategory and type(addon._settingsPacksCategory.GetID) == "function" then
      if TryOpen(addon._settingsPacksCategory:GetID()) then return end
    end
    if TryOpen("Emote Control - Packs") then return end
    if TryOpen("Packs") then return end
    if type(addon.OpenSettings) == "function" then
      addon:OpenSettings()
      addon:Print("Packs panel not found; opened main settings instead.")
      return
    end
  end

  if interfaceOptionsReady and InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory(packsPanel)
    InterfaceOptionsFrame_OpenToCategory(packsPanel)
    return
  end

  addon:Print("Packs UI not available. Use /sl help for commands.")
end
