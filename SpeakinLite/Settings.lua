-- EmoteControl - Settings Panel (Retail 10.0+ Settings UI)
-- Provides advanced configuration options via the settings interface
-- Uses Settings.RegisterCanvasLayoutCategory for custom widget placement

EmoteControl = EmoteControl or {}
SpeakinLite = EmoteControl  -- Backward compatibility alias
local addon = EmoteControl

local panel

local wipe = wipe or function(t)
  if type(t) ~= "table" then return end
  for k in pairs(t) do t[k] = nil end
end

local function CreateLabel(parent, text, x, y, size)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  if size == "large" then
    fs:SetFontObject("GameFontNormalLarge")
  end
  fs:SetText(text)
  return fs
end

local function CreateCheckbox(parent, label, x, y, onClick)
  local cb = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  
  -- Handle different text field names in different WoW versions
  if cb.Text then
    cb.Text:SetText(label)
  elseif cb.text then
    cb.text:SetText(label)
  else
    -- Create text manually if template doesn't provide it
    local text = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    text:SetText(label)
    cb.Text = text
  end
  
  cb:SetScript("OnClick", function(self)
    if type(onClick) == "function" then
      onClick(self:GetChecked() and true or false)
    end
  end)
  return cb
end

local function CreateButton(parent, label, x, y, width, onClick)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  b:SetSize(width or 140, 22)
  b:SetText(label)
  b:SetScript("OnClick", function()
    if type(onClick) == "function" then onClick() end
  end)
  return b
end

local function CreateSlider(parent, label, x, y, minVal, maxVal, step)
  addon._sliderSeq = (addon._sliderSeq or 0) + 1
  local name = "EmoteControlOptionsSlider" .. tostring(addon._sliderSeq)
  local s = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
  s:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  s:SetMinMaxValues(minVal, maxVal)
  s:SetValueStep(step or 1)
  s:SetObeyStepOnDrag(true)
  s:SetWidth(240)
  local base = s:GetName()
  if base and _G[base .. "Text"] then _G[base .. "Text"]:SetText(label) end
  if base and _G[base .. "Low"] then _G[base .. "Low"]:SetText(tostring(minVal)) end
  if base and _G[base .. "High"] then _G[base .. "High"]:SetText(tostring(maxVal)) end
  s._label = label
  return s
end

local function SetSliderLabel(slider, value)
  if not slider then return end
  local base = slider:GetName()
  if base and _G[base .. "Text"] and slider._label then
    _G[base .. "Text"]:SetText(slider._label .. ": " .. tostring(value))
  end
end

-- Public API: open the Settings panel.
function addon:OpenSettings()
  if not (Settings and type(Settings.OpenToCategory) == "function") then
    addon:Print("The Settings API is not available in this client.")
    return false
  end

  -- Prefer opening by the category object when possible.
  local cat = addon._settingsCategory
  if cat then
    local ok = pcall(Settings.OpenToCategory, cat)
    if ok then return true end
    
    if cat.ID then
      ok = pcall(Settings.OpenToCategory, cat.ID)
      if ok then return true end
    end
    
    if type(cat.GetID) == "function" then
      ok = pcall(Settings.OpenToCategory, cat:GetID())
      if ok then return true end
    end
  end

  -- Fallback to any stored id.
  local id = addon._settingsCategoryId
  if id then
    local ok = pcall(Settings.OpenToCategory, id)
    if ok then return true end
  end

  return false
end

function addon:CreateSettingsPanel()
  if panel then return end
  if not (Settings and type(Settings.RegisterCanvasLayoutCategory) == "function" and type(Settings.RegisterAddOnCategory) == "function") then
    -- Retail 10.0+ expected. If missing, we just skip UI.
    return
  end

  panel = CreateFrame("Frame")
  panel.name = "Emote Control"

  local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -8)
  scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -28, 8)

  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(1, 1)
  scroll:SetScrollChild(content)

  -- Register category
  local ok, category = pcall(Settings.RegisterCanvasLayoutCategory, panel, "Emote Control")
  if not ok or not category then
    addon:Print("Failed to create Settings panel. Using legacy Options.")
    panel = nil
    return
  end
  
  pcall(Settings.RegisterAddOnCategory, category)
  addon._settingsCategory = category
  addon._settingsCategoryId = category.ID or (type(category.GetID) == "function" and category:GetID())

  -- Title
  CreateLabel(content, "Emote Control", 16, -16, "large")
  CreateLabel(content, "Lightweight spell + event announcer. Packs add triggers and phrases.", 16, -40)
  CreateLabel(content, "Quick access: Editor and Builder are the fastest way to customize triggers.", 16, -58)

  local y = -86

  -- Master toggles
  local cbEnabled
  cbEnabled = CreateCheckbox(content, "Enable Emote Control", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enabled = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
  end)

  y = y - 28
  local cbSpell = CreateCheckbox(content, "Enable spell triggers", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enableSpellTriggers = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
  end)

  y = y - 28
  local cbNonSpell = CreateCheckbox(content, "Enable non-spell triggers (login, death, etc.)", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enableNonSpellTriggers = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
  end)

  y = y - 28
  local cbCombatLog = CreateCheckbox(content, "Enable combat log triggers (crits, dodges, interrupts)", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enableCombatLogTriggers = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
  end)

  y = y - 28
  local cbLoot = CreateCheckbox(content, "Enable loot triggers (epic/legendary drops)", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enableLootTriggers = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
  end)

  y = y - 28
  local cbAchievement = CreateCheckbox(content, "Enable achievement triggers", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enableAchievementTriggers = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
  end)

  y = y - 28
  local cbLevelUp = CreateCheckbox(content, "Enable level-up triggers", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enableLevelUpTriggers = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
  end)

  y = y - 32
  CreateLabel(content, "Quick Setup", 16, y)
  y = y - 22
  local setupBtn = CreateButton(content, "Apply Recommended Defaults", 16, y, 220, function()
    local db = addon:GetDB() or {}
    addon:ApplyRecommendedDefaults(db)
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
    if panel and panel:GetScript("OnShow") then
      panel:GetScript("OnShow")(panel)
    end
    addon:Print("Applied recommended defaults.")
  end)

  y = y - 40
  local cbKnown = CreateCheckbox(content, "Only announce spells you actually know", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.onlyLearnedSpells = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
  end)

  y = y - 28
  local cbFallback = CreateCheckbox(content, "If SAY/YELL blocked outdoors, use EMOTE instead", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.fallbackToSelf = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
  end)

  -- Channel selection (simple radio group)
  y = y - 44
  CreateLabel(content, "Output Channel", 16, y)
  y = y - 22

  local channels = {
    { label = "Self (local chat frame)", value = "SELF" },
    { label = "Party", value = "PARTY" },
    { label = "Raid", value = "RAID" },
    { label = "Instance", value = "INSTANCE" },
    { label = "Say (may be blocked outdoors)", value = "SAY" },
    { label = "Emote (works everywhere!)", value = "EMOTE" },
  }

  local radio = {}
  local function SetChannel(v)
    local db = addon:GetDB() or {}
    db.channel = v
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
    for _, r in ipairs(radio) do
      r:SetChecked(r._value == v)
    end
  end

  for i, ch in ipairs(channels) do
    local r = CreateFrame("CheckButton", nil, content, "UIRadioButtonTemplate")
    r:SetPoint("TOPLEFT", content, "TOPLEFT", 20, y)
    
    -- Handle different text field names in different WoW versions
    if r.Text then
      r.Text:SetText(ch.label)
    elseif r.text then
      r.text:SetText(ch.label)
    else
      -- Create text manually if template doesn't provide it
      local text = r:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
      text:SetPoint("LEFT", r, "RIGHT", 0, 1)
      text:SetText(ch.label)
      r.Text = text
    end
    
    r._value = ch.value
    r:SetScript("OnClick", function() SetChannel(ch.value) end)
    table.insert(radio, r)
    y = y - 20
  end

  y = y - 12

  -- Cooldown slider
  local slider = CreateSlider(content, "Global cooldown (seconds)", 16, y, 0, 60, 1)
  slider:SetScript("OnValueChanged", function(self, value)
    local db = addon:GetDB() or {}
    db.globalCooldown = math.floor(value + 0.5)
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB
    SetSliderLabel(self, db.globalCooldown)
  end)

  y = y - 60

  -- Packs
  CreateLabel(content, "Packs", 16, y)
  CreateLabel(content, "Manage packs in the Packs submenu.", 16, y - 18)
  y = y - 44

  local packsBtn = CreateButton(content, "Open Packs", 16, y, 160, function()
    if type(addon.OpenPacksPanel) == "function" then
      addon:OpenPacksPanel()
    end
  end)

  local rebuildBtn = CreateButton(content, "Rebuild Trigger Index", 300, y, 180, function()
    if type(addon.RebuildAndRegister) == "function" then
      addon:RebuildAndRegister()
      addon:Print("Rebuilt triggers.")
    end
  end)

  local testBtn = CreateButton(content, "Test output", 300, y - 28, 180, function()
    if type(addon.Output) == "function" then
      addon:Output("Testing Emote Control output from settings panel.")
    end
  end)

  local editorBtn = CreateButton(content, "Open Trigger Editor", 16, y - 28, 180, function()
    if type(addon.OpenEditor) == "function" then
      addon:OpenEditor()
    else
      addon:Print("Editor UI not available.")
    end
  end)

  local builderBtn = CreateButton(content, "Open Trigger Builder", 16, y - 56, 180, function()
    if type(addon.OpenTriggerBuilder) == "function" then
      addon:OpenTriggerBuilder()
    else
      addon:Print("Trigger Builder UI not available.")
    end
  end)

  local importExportBtn = CreateButton(content, "Import / Export", 300, y - 56, 180, function()
    if type(addon.OpenImportExportUI) == "function" then
      addon:OpenImportExportUI()
    else
      addon:Print("Import/Export UI not available.")
    end
  end)

  -- Refresh handler
  panel:SetScript("OnShow", function()
    local db = addon:GetDB() or {}
    if cbEnabled then cbEnabled:SetChecked(db.enabled and true or false) end
    cbSpell:SetChecked(db.enableSpellTriggers ~= false)
    cbNonSpell:SetChecked(db.enableNonSpellTriggers ~= false)
    cbCombatLog:SetChecked(db.enableCombatLogTriggers ~= false)
    cbLoot:SetChecked(db.enableLootTriggers ~= false)
    cbAchievement:SetChecked(db.enableAchievementTriggers ~= false)
    cbLevelUp:SetChecked(db.enableLevelUpTriggers ~= false)
    cbKnown:SetChecked(db.onlyLearnedSpells ~= false)
    cbFallback:SetChecked(db.fallbackToSelf ~= false)
    SetChannel((type(db.channel) == "string" and string.upper(db.channel)) or "SELF")
    slider:SetValue(tonumber(db.globalCooldown) or 6)
    SetSliderLabel(slider, tonumber(db.globalCooldown) or 6)

  end)

  content:SetHeight(math.max(1, (-y) + 120))
end

local packsPanel

function addon:CreatePacksSettingsPanel()
  if packsPanel then return end
  if not (Settings and type(Settings.RegisterCanvasLayoutCategory) == "function" and type(Settings.RegisterAddOnCategory) == "function") then
    return
  end

  packsPanel = CreateFrame("Frame")
  packsPanel.name = "Packs"

  local ok, category
  if type(Settings.RegisterCanvasLayoutSubcategory) == "function" and addon._settingsCategory then
    ok, category = pcall(Settings.RegisterCanvasLayoutSubcategory, addon._settingsCategory, packsPanel, "Packs")
  end

  if not ok or not category then
    ok, category = pcall(Settings.RegisterCanvasLayoutCategory, packsPanel, "Emote Control - Packs")
    if ok and category then
      pcall(Settings.RegisterAddOnCategory, category)
    else
      packsPanel = nil
      return
    end
  end

  addon._settingsPacksCategory = category
  addon._settingsPacksCategoryId = category.ID or (type(category.GetID) == "function" and category:GetID())

  CreateLabel(packsPanel, "Emote Control - Packs", 16, -16, "large")
  CreateLabel(packsPanel, "Enable or disable packs. Packs not loaded will load when enabled.", 16, -40)

  local searchLabel = CreateLabel(packsPanel, "Filter", 16, -64)
  local searchBox = CreateFrame("EditBox", nil, packsPanel, "InputBoxTemplate")
  searchBox:SetSize(220, 20)
  searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 10, 0)
  searchBox:SetAutoFocus(false)
  searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

  local scroll = CreateFrame("ScrollFrame", nil, packsPanel, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", packsPanel, "TOPLEFT", 16, -92)
  scroll:SetPoint("BOTTOMRIGHT", packsPanel, "BOTTOMRIGHT", -30, 16)

  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(1, 1)
  scroll:SetScrollChild(content)

  local checkboxes = {}
  local function Clear()
    for _, cb in ipairs(checkboxes) do
      cb:Hide()
      cb:SetParent(nil)
    end
    wipe(checkboxes)
  end

  local function Refresh()
    local db = addon:GetDB() or {}
    db.packEnabled = db.packEnabled or {}
    EmoteControlDB = db
    SpeakinLiteDB = EmoteControlDB

    Clear()

    local filter = addon:SafeLower(searchBox:GetText() or "") or ""

    local list = {}
    if type(addon.GetPackDescriptors) == "function" then
      list = addon:GetPackDescriptors()
    else
      for id, _ in pairs(addon.Packs or {}) do
        table.insert(list, { id = id, name = id, loaded = true })
      end
      table.sort(list, function(a, b) return a.id < b.id end)
    end

    local y = -6
    for _, entry in ipairs(list) do
      local label = entry.name or entry.id
      if entry.id and entry.id ~= label then
        label = label .. " (" .. entry.id .. ")"
      end
      if entry.loaded == false then
        label = label .. " (not loaded)"
      end
      if entry.loadable == false then
        local reason = entry.reason and (" " .. tostring(entry.reason)) or ""
        label = label .. " (not loadable" .. reason .. ")"
      end

      local show = true
      if filter ~= "" and not addon:SafeLower(label):find(filter, 1, true) then
        show = false
      end

      if show then
        local cb = CreateCheckbox(content, label, 0, y, function(v)
          if type(addon.SetPackEnabled) == "function" then
            addon:SetPackEnabled(entry.id, v, entry.addonName)
          else
            local db2 = addon:GetDB() or {}
            db2.packEnabled = db2.packEnabled or {}
            db2.packEnabled[entry.id] = v
            EmoteControlDB = db2
            SpeakinLiteDB = EmoteControlDB
          end
        end)
        cb:SetChecked(db.packEnabled[entry.id] ~= false)
        table.insert(checkboxes, cb)
        y = y - 24
      end
    end

    content:SetHeight(math.max(1, (-y) + 24))
  end

  packsPanel:SetScript("OnShow", Refresh)
  searchBox:SetScript("OnTextChanged", Refresh)
end
