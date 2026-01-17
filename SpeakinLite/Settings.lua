-- SpeakinLite - Settings Panel (Retail 10.0+ Settings UI)
-- Uses Settings.RegisterCanvasLayoutCategory so we can place our own widgets.

SpeakinLite = SpeakinLite or {}
local addon = SpeakinLite

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
  local name = "SpeakinLiteOptionsSlider" .. tostring(addon._sliderSeq)
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
  return s
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
  CreateLabel(panel, "SpeakinLite", 16, -16, "large")
  CreateLabel(panel, "Lightweight spell + event announcer. Packs add triggers and phrases.", 16, -40)

  local y = -72

  -- Master toggles
  local cbEnabled
  cbEnabled = CreateCheckbox(panel, "Enable SpeakinLite", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enabled = v
    SpeakinLiteDB = db
  end)

  y = y - 28
  local cbSpell = CreateCheckbox(panel, "Enable spell triggers", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enableSpellTriggers = v
    SpeakinLiteDB = db
  end)

  y = y - 28
  local cbNonSpell = CreateCheckbox(panel, "Enable non-spell triggers (login, death, etc.)", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.enableNonSpellTriggers = v
    SpeakinLiteDB = db
  end)

  y = y - 28
  local cbKnown = CreateCheckbox(panel, "Only announce spells you actually know", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.onlyLearnedSpells = v
    SpeakinLiteDB = db
  end)

  y = y - 28
  local cbFallback = CreateCheckbox(panel, "If SAY/YELL blocked outdoors, use EMOTE instead", 16, y, function(v)
    local db = addon:GetDB() or {}
    db.fallbackToSelf = v
    SpeakinLiteDB = db
  end)

  -- Channel selection (simple radio group)
  y = y - 44
  CreateLabel(panel, "Output Channel", 16, y)
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
    SpeakinLiteDB = db
    for _, r in ipairs(radio) do
      r:SetChecked(r._value == v)
    end
  end

  for i, ch in ipairs(channels) do
    local r = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
    r:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y)
    
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
  local slider = CreateSlider(panel, "Global cooldown (seconds)", 16, y, 0, 60, 1)
  slider:SetScript("OnValueChanged", function(self, value)
    local db = addon:GetDB() or {}
    db.globalCooldown = math.floor(value + 0.5)
    SpeakinLiteDB = db
  end)

  y = y - 60

  -- Packs
  CreateLabel(panel, "Packs", 16, y)
  CreateLabel(panel, "Enable or disable packs, then click Rebuild Trigger Index.", 16, y - 18)
  y = y - 44

  local packChecks = {}
  local function RebuildPackList()
    for _, w in ipairs(packChecks) do
      w:Hide()
    end
    wipe(packChecks)

    local db = addon:GetDB() or {}
    db.packEnabled = db.packEnabled or {}
    SpeakinLiteDB = db

    local ids = {}
    for id, _ in pairs(addon.Packs or {}) do
      table.insert(ids, id)
    end
    table.sort(ids)

    local py = y
    for _, id in ipairs(ids) do
      local label = id
      local cb = CreateCheckbox(panel, label, 16, py, function(v)
        local db2 = addon:GetDB() or {}
        db2.packEnabled = db2.packEnabled or {}
        db2.packEnabled[id] = v
        SpeakinLiteDB = db2
      end)
      table.insert(packChecks, cb)
      py = py - 24
    end
  end

  local rebuildBtn = CreateButton(panel, "Rebuild Trigger Index", 300, y, 180, function()
    if type(addon.RebuildAndRegister) == "function" then
      addon:RebuildAndRegister()
      addon:Print("Rebuilt triggers.")
    end
  end)

  local testBtn = CreateButton(panel, "Test output", 300, y - 28, 180, function()
    if type(addon.Output) == "function" then
      addon:Output("Testing SpeakinLite output from settings panel.")
    end
  end)

  -- Refresh handler
  panel:SetScript("OnShow", function()
    local db = addon:GetDB() or {}
    if cbEnabled then cbEnabled:SetChecked(db.enabled and true or false) end
    cbSpell:SetChecked(db.enableSpellTriggers ~= false)
    cbNonSpell:SetChecked(db.enableNonSpellTriggers ~= false)
    cbKnown:SetChecked(db.onlyLearnedSpells ~= false)
    cbFallback:SetChecked(db.fallbackToSelf ~= false)
    SetChannel((type(db.channel) == "string" and string.upper(db.channel)) or "SELF")
    slider:SetValue(tonumber(db.globalCooldown) or 6)

    RebuildPackList()
    for _, cb in ipairs(packChecks) do
      local id
      if cb.Text then
        id = cb.Text:GetText()
      elseif cb.text then
        id = cb.text:GetText()
      end
      if id then
        local enabled = addon:IsPackEnabled(id)
        cb:SetChecked(enabled)
      end
    end
  end)
end
