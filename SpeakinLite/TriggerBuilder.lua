-- EmoteControl - Trigger Builder Interface
-- Visual UI for creating and editing custom triggers without Lua code
-- Simplifies trigger creation with form-based configuration

EmoteControl = EmoteControl or {}
if rawget(_G, "SpeakinLite") == nil then
  SpeakinLite = EmoteControl  -- Backward compatibility alias
end
local addon = EmoteControl

local builderFrame = nil
local currentTrigger = nil

-- Trigger template
local function NewTrigger()
  return {
    id = "custom_" .. tostring(time()) .. "_" .. tostring(math.random(1000, 9999)),
    event = "UNIT_SPELLCAST_SUCCEEDED",
    cooldown = 10,
    category = "general",
    channel = "SAY",
    conditions = {},
    messages = {"New message here"},
  }
end

-- Create the main builder frame
function addon:CreateTriggerBuilder()
  if builderFrame then
    builderFrame:Show()
    return
  end

  local frame = CreateFrame("Frame", "EmoteControlTriggerBuilder", UIParent, "BasicFrameTemplateWithInset")
  frame:SetSize(600, 560)
  frame:SetPoint("CENTER")
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:SetFrameStrata("DIALOG")
  
  frame.title = frame:CreateFontString(nil, "OVERLAY")
  frame.title:SetFontObject("GameFontHighlight")
  frame.title:SetPoint("TOP", frame, "TOP", 0, -5)
  frame.title:SetText("Emote Control - Trigger Builder")

  local yOffset = -30

  -- Event Selection
  local eventLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  eventLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  eventLabel:SetText("Event:")

  local eventDropdown = CreateFrame("Frame", "EmoteControlBuilderEventDropdown", frame, "UIDropDownMenuTemplate")
  eventDropdown:SetPoint("TOPLEFT", eventLabel, "TOPRIGHT", -15, 7)
  
  local eventOptions = {
    "UNIT_SPELLCAST_SUCCEEDED",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "ACHIEVEMENT_EARNED",
    "PLAYER_LEVEL_UP",
    "PLAYER_DEAD",
    "PLAYER_ALIVE",
    "COMBAT_CRITICAL_HIT",
    "COMBAT_DODGED",
    "COMBAT_PARRIED",
    "COMBAT_INTERRUPTED",
  }
  
  UIDropDownMenu_SetWidth(eventDropdown, 200)
  UIDropDownMenu_SetText(eventDropdown, "Select Event")
  UIDropDownMenu_Initialize(eventDropdown, function(self, level)
    for _, evt in ipairs(eventOptions) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = evt
      info.value = evt
      info.func = function()
        if currentTrigger then
          currentTrigger.event = evt
          UIDropDownMenu_SetText(eventDropdown, evt)
        end
      end
      UIDropDownMenu_AddButton(info)
    end
  end)

  yOffset = yOffset - 40

  -- Cooldown
  local cdLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  cdLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  cdLabel:SetText("Cooldown (sec):")

  local cdBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
  cdBox:SetSize(60, 30)
  cdBox:SetPoint("TOPLEFT", cdLabel, "TOPRIGHT", 10, 5)
  cdBox:SetAutoFocus(false)
  cdBox:SetText("10")
  cdBox:SetScript("OnTextChanged", function(self)
    if currentTrigger then
      currentTrigger.cooldown = tonumber(self:GetText()) or 10
    end
  end)

  yOffset = yOffset - 40

  -- Channel
  local channelLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  channelLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  channelLabel:SetText("Channel:")

  local channelDropdown = CreateFrame("Frame", "EmoteControlBuilderChannelDropdown", frame, "UIDropDownMenuTemplate")
  channelDropdown:SetPoint("TOPLEFT", channelLabel, "TOPRIGHT", -15, 7)
  
  local channelOptions = {"SAY", "YELL", "EMOTE", "PARTY", "RAID", "INSTANCE", "SELF", "AUTO"}
  
  UIDropDownMenu_SetWidth(channelDropdown, 120)
  UIDropDownMenu_SetText(channelDropdown, "SAY")
  UIDropDownMenu_Initialize(channelDropdown, function(self, level)
    for _, ch in ipairs(channelOptions) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = ch
      info.value = ch
      info.func = function()
        if currentTrigger then
          currentTrigger.channel = ch
          UIDropDownMenu_SetText(channelDropdown, ch)
        end
      end
      UIDropDownMenu_AddButton(info)
    end
  end)

  yOffset = yOffset - 50

  -- Messages
  local msgLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  msgLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  msgLabel:SetText("Messages (one per line):")

  yOffset = yOffset - 25

  local msgScrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
  msgScrollFrame:SetSize(540, 150)
  msgScrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)

  local msgEditBox = CreateFrame("EditBox", nil, msgScrollFrame)
  msgEditBox:SetSize(520, 150)
  msgEditBox:SetMultiLine(true)
  msgEditBox:SetAutoFocus(false)
  msgEditBox:SetFontObject("ChatFontNormal")
  msgEditBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)
  msgEditBox:SetScript("OnTextChanged", function(self)
    if currentTrigger then
      local text = self:GetText()
      local messages = {}
      for line in text:gmatch("[^\r\n]+") do
        if line and line ~= "" then
          table.insert(messages, line)
        end
      end
      currentTrigger.messages = messages
    end
  end)

  msgScrollFrame:SetScrollChild(msgEditBox)

  yOffset = yOffset - 170

  -- Spell Name Condition (for UNIT_SPELLCAST_SUCCEEDED)
  local spellLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  spellLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  spellLabel:SetText("Spell Name (optional):")

  local spellBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
  spellBox:SetSize(200, 30)
  spellBox:SetPoint("TOPLEFT", spellLabel, "TOPRIGHT", 10, 5)
  spellBox:SetAutoFocus(false)
  spellBox:SetScript("OnTextChanged", function(self)
    if currentTrigger then
      local spellName = self:GetText()
      if spellName and spellName ~= "" then
        currentTrigger.conditions.spellName = spellName
      else
        currentTrigger.conditions.spellName = nil
      end
    end
  end)

  yOffset = yOffset - 50

  -- Conditions
  local condLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  condLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  condLabel:SetText("Conditions")

  yOffset = yOffset - 30

  local chanceLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  chanceLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  chanceLabel:SetText("Random chance (%)")

  local chanceBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
  chanceBox:SetSize(60, 24)
  chanceBox:SetPoint("TOPLEFT", chanceLabel, "TOPRIGHT", 10, 4)
  chanceBox:SetAutoFocus(false)
  chanceBox:SetNumeric(true)
  chanceBox:SetScript("OnTextChanged", function(self)
    if currentTrigger then
      local v = tonumber(self:GetText())
      if v and v > 0 then
        currentTrigger.conditions.randomChance = addon:ClampNumber(v, 1, 100) / 100
      else
        currentTrigger.conditions.randomChance = nil
      end
    end
  end)

  yOffset = yOffset - 30

  local cbInCombat = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
  cbInCombat:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  cbInCombat.Text:SetText("In combat")
  cbInCombat:SetScript("OnClick", function(self)
    if currentTrigger then
      currentTrigger.conditions.inCombat = self:GetChecked() and true or nil
    end
  end)

  yOffset = yOffset - 26

  local cbInGroup = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
  cbInGroup:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  cbInGroup.Text:SetText("In group or raid")
  cbInGroup:SetScript("OnClick", function(self)
    if currentTrigger then
      currentTrigger.conditions.inGroup = self:GetChecked() and true or nil
    end
  end)

  yOffset = yOffset - 26

  local hbLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  hbLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  hbLabel:SetText("Health below (%)")

  local hbBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
  hbBox:SetSize(60, 24)
  hbBox:SetPoint("TOPLEFT", hbLabel, "TOPRIGHT", 10, 4)
  hbBox:SetAutoFocus(false)
  hbBox:SetNumeric(true)
  hbBox:SetScript("OnTextChanged", function(self)
    if currentTrigger then
      local v = tonumber(self:GetText())
      if v and v > 0 then
        currentTrigger.conditions.healthBelow = addon:ClampNumber(v, 1, 100)
      else
        currentTrigger.conditions.healthBelow = nil
      end
    end
  end)

  yOffset = yOffset - 30

  local haLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  haLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  haLabel:SetText("Health above (%)")

  local haBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
  haBox:SetSize(60, 24)
  haBox:SetPoint("TOPLEFT", haLabel, "TOPRIGHT", 10, 4)
  haBox:SetAutoFocus(false)
  haBox:SetNumeric(true)
  haBox:SetScript("OnTextChanged", function(self)
    if currentTrigger then
      local v = tonumber(self:GetText())
      if v and v > 0 then
        currentTrigger.conditions.healthAbove = addon:ClampNumber(v, 1, 100)
      else
        currentTrigger.conditions.healthAbove = nil
      end
    end
  end)

  yOffset = yOffset - 30

  local cbTarget = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
  cbTarget:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
  cbTarget.Text:SetText("Requires target")
  cbTarget:SetScript("OnClick", function(self)
    if currentTrigger then
      currentTrigger.conditions.requiresTarget = self:GetChecked() and true or nil
    end
  end)

  local targetTypeDropdown = CreateFrame("Frame", "EmoteControlBuilderTargetTypeDropdown", frame, "UIDropDownMenuTemplate")
  targetTypeDropdown:SetPoint("TOPLEFT", cbTarget, "TOPRIGHT", -10, 2)
  UIDropDownMenu_SetWidth(targetTypeDropdown, 110)
  UIDropDownMenu_SetText(targetTypeDropdown, "Target type")
  UIDropDownMenu_Initialize(targetTypeDropdown, function(self, level)
    local options = {
      { label = "Any", value = "" },
      { label = "Enemy", value = "enemy" },
      { label = "Friendly", value = "friendly" },
    }
    for _, opt in ipairs(options) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = opt.label
      info.value = opt.value
      info.func = function()
        if currentTrigger then
          if opt.value == "" then
            currentTrigger.conditions.targetType = nil
          else
            currentTrigger.conditions.targetType = opt.value
          end
          UIDropDownMenu_SetText(targetTypeDropdown, opt.label)
        end
      end
      UIDropDownMenu_AddButton(info)
    end
  end)

  yOffset = yOffset - 50

  -- Buttons
  local saveBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  saveBtn:SetSize(120, 30)
  saveBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 15)
  saveBtn:SetText("Save Trigger")
  saveBtn:SetScript("OnClick", function()
    if currentTrigger then
      addon:SaveCustomTrigger(currentTrigger)
      addon:Print("Custom trigger saved: " .. currentTrigger.id)
    end
  end)

  local newBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  newBtn:SetSize(120, 30)
  newBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
  newBtn:SetText("New Trigger")
  newBtn:SetScript("OnClick", function()
    currentTrigger = NewTrigger()
    msgEditBox:SetText("")
    spellBox:SetText("")
    cdBox:SetText("10")
    UIDropDownMenu_SetText(eventDropdown, "UNIT_SPELLCAST_SUCCEEDED")
    UIDropDownMenu_SetText(channelDropdown, "SAY")
    addon:Print("New trigger created.")
  end)

  local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  closeBtn:SetSize(120, 30)
  closeBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 15)
  closeBtn:SetText("Close")
  closeBtn:SetScript("OnClick", function()
    frame:Hide()
  end)

  -- Store references
  frame.msgEditBox = msgEditBox
  frame.spellBox = spellBox
  frame.cdBox = cdBox
  frame.eventDropdown = eventDropdown
  frame.channelDropdown = channelDropdown

  builderFrame = frame
  
  -- Initialize with a new trigger
  currentTrigger = NewTrigger()
  
  frame:Hide()
end

function addon:SaveCustomTrigger(trigger)
  if not trigger or not trigger.id then return end
  
  local db = addon:GetDB()
  if not db then return end
  
  -- Store in custom triggers table
  db.customTriggers = db.customTriggers or {}
  db.customTriggers[trigger.id] = trigger
  
  -- Register it immediately
  addon:RegisterCustomTrigger(trigger)
  addon:RebuildAndRegister()
end

function addon:RegisterCustomTrigger(trigger)
  -- Create a custom pack for this trigger
  local packId = "custom:" .. tostring(trigger.id)
  local pack = {
    id = packId,
    name = "Custom_" .. trigger.id,
    triggers = {trigger}
  }
  addon:RegisterPack(pack)
end

function addon:LoadCustomTriggers()
  local db = addon:GetDB()
  if not db or type(db.customTriggers) ~= "table" then return end
  
  for _, trigger in pairs(db.customTriggers) do
    addon:RegisterCustomTrigger(trigger)
  end
end

function addon:OpenTriggerBuilder()
  if not builderFrame then
    addon:CreateTriggerBuilder()
  end
  if builderFrame and type(builderFrame.Show) == "function" then
    builderFrame:Show()
  end
end
