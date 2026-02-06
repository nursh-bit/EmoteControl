-- EmoteControl - Trigger Editor Interface
-- In-game UI for customizing trigger behavior on a per-trigger basis
-- Allows editing: enabled state, cooldown, channel, and message overrides

EmoteControl = EmoteControl or {}
if rawget(_G, "SpeakinLite") == nil then
  SpeakinLite = EmoteControl  -- Backward compatibility alias
end
local addon = EmoteControl

local frame
local selectedId

local function EnsureOverride(triggerId)
  local db = addon:GetDB()
  if type(db) ~= "table" then return nil end
  db.triggerOverrides = db.triggerOverrides or {}
  db.triggerOverrides[triggerId] = db.triggerOverrides[triggerId] or {}
  return db.triggerOverrides[triggerId]
end

local function GetOverride(triggerId)
  local db = addon:GetDB()
  if type(db) ~= "table" or type(db.triggerOverrides) ~= "table" then
    return nil
  end
  return db.triggerOverrides[triggerId]
end

local function GetAllTriggersFiltered(search)
  local list = {}
  local s = (type(search) == "string" and search:lower()) or ""

  for id, trig in pairs(addon.TriggerById or {}) do
    if type(id) == "string" and type(trig) == "table" then
      local hay = (id .. " " .. tostring(trig.packId or "") .. " " .. tostring(trig.category or "") .. " " .. tostring(trig._spellID or "") .. " " .. tostring((trig.conditions or {}).spellName or ""))
      if s == "" or hay:lower():find(s, 1, true) then
        table.insert(list, { id = id, trig = trig })
      end
    end
  end

  table.sort(list, function(a, b)
    return a.id < b.id
  end)

  return list
end

local function SplitLines(text)
  local lines = {}
  if type(text) ~= "string" then return lines end
  for line in text:gmatch("[^\r\n]+") do
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    if line ~= "" then
      table.insert(lines, line)
    end
  end
  return lines
end

local function JoinLines(lines)
  if type(lines) ~= "table" then return "" end
  return table.concat(lines, "\n")
end

local function PrettyLabel(trig)
  if type(trig) ~= "table" then return "" end
  local parts = {}
  if trig.packId then table.insert(parts, "[" .. trig.packId .. "]") end
  if trig.category then table.insert(parts, trig.category) end
  if trig._spellID then
    local name = addon:GetSpellName(trig._spellID)
    if name then table.insert(parts, name) else table.insert(parts, tostring(trig._spellID)) end
  end
  if trig.event then table.insert(parts, trig.event) end
  return table.concat(parts, " ")
end

local function MakeBackdrop(f)
  if not (f and f.SetBackdrop) then return end
  f:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  f:SetBackdropColor(0, 0, 0, 0.9)
end

local function CreateDropdown(parent, name, items, onChanged)
  local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
  dd.items = items
  dd.onChanged = onChanged

  UIDropDownMenu_Initialize(dd, function(self, level)
    for _, it in ipairs(self.items or {}) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = it.label
      info.value = it.value
      info.func = function()
        UIDropDownMenu_SetSelectedValue(self, it.value)
        if self.onChanged then self.onChanged(it.value) end
      end
      UIDropDownMenu_AddButton(info, level)
    end
  end)

  function dd:SetValue(v)
    UIDropDownMenu_SetSelectedValue(self, v)
    local found
    for _, it in ipairs(self.items or {}) do
      if it.value == v then found = it.label break end
    end
    UIDropDownMenu_SetText(self, found or tostring(v or ""))
  end

  return dd
end

local function RefreshDetails()
  if not frame then return end
  local trig = selectedId and addon.TriggerById and addon.TriggerById[selectedId]
  if not trig then
    frame.detailsTitle:SetText("Select a trigger")
    frame.enabled:SetChecked(false)
    frame.cooldown:SetText("")
    frame.channelDD:SetValue("")
    frame.messagesBox:SetText("")
    return
  end

  frame.detailsTitle:SetText(selectedId .. "\n" .. PrettyLabel(trig))

  local ov = GetOverride(selectedId) or {}
  frame.enabled:SetChecked(ov.enabled ~= false)
  frame.cooldown:SetText(tostring(ov.cooldown or ""))
  frame.channelDD:SetValue(ov.channel or "")

  local msgs = (ov.messages and #ov.messages > 0) and ov.messages or trig.messages or {}
  frame.messagesBox:SetText(JoinLines(msgs))
end

local function BuildList()
  if not frame then return end

  local items = GetAllTriggersFiltered(frame.searchBox:GetText())
  frame._items = items

  FauxScrollFrame_Update(frame.scroll, #items, 14, 16)

  local offset = FauxScrollFrame_GetOffset(frame.scroll)
  for i = 1, 14 do
    local row = frame.rows[i]
    local idx = offset + i
    local item = items[idx]

    if item then
      row:Show()
      row.id = item.id
      row.text:SetText(item.id)
      row.sub:SetText(PrettyLabel(item.trig))
      if selectedId == item.id then
        row.highlight:Show()
        row.bg:SetColorTexture(0.15, 0.2, 0.3, 0.8)
      else
        row.highlight:Hide()
        row.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
      end
    else
      row:Hide()
    end
  end

  -- Auto-select the first visible row if the current selection is not visible
  local selectedVisible = false
  if selectedId then
    for i = 1, 14 do
      local item = items[offset + i]
      if item and item.id == selectedId then
        selectedVisible = true
        break
      end
    end
  end

  if not selectedVisible then
    local first = items[offset + 1]
    if first then
      selectedId = first.id
      RefreshDetails()
    end
  end
end

function addon:OpenEditor()
  if frame and frame:IsShown() then
    frame:Hide()
    return
  end

  if not frame then
    frame = CreateFrame("Frame", "EmoteControlEditorFrame", UIParent, "BackdropTemplate")
    frame:SetSize(840, 520)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    MakeBackdrop(frame)

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -12)
    title:SetText("Emote Control - Trigger Editor")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local searchLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    searchLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    searchLabel:SetText("Search")

    local searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    searchBox:SetSize(260, 20)
    searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 10, 0)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function()
      BuildList()
    end)
    frame.searchBox = searchBox

    local leftPane = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    leftPane:SetPoint("TOPLEFT", searchLabel, "BOTTOMLEFT", 0, -10)
    leftPane:SetSize(380, 420)
    MakeBackdrop(leftPane)

    -- Draggable divider between panes
    local divider = CreateFrame("Frame", nil, frame)
    divider:SetSize(8, 420)
    divider:SetPoint("TOPLEFT", leftPane, "TOPRIGHT", -4, 0)
    divider:SetCursor("SIZEWE")
    divider:EnableMouse(true)

    local dividerTex = divider:CreateTexture(nil, "ARTWORK")
    dividerTex:SetAllPoints()
    dividerTex:SetColorTexture(0.3, 0.3, 0.3, 0.6)

    local dividerLine = divider:CreateTexture(nil, "ARTWORK")
    dividerLine:SetSize(1, 420)
    dividerLine:SetPoint("CENTER", divider, "CENTER", 0, 0)
    dividerLine:SetColorTexture(0.6, 0.6, 0.6, 1)

    divider:SetScript("OnMouseDown", function(self, button)
      if button == "LeftButton" then
        self._dragging = true
        self._startX = GetCursorPosition()
        self._startLeftWidth = leftPane:GetWidth()
        self:SetScript("OnUpdate", function(this)
          local currentX = GetCursorPosition()
          local delta = currentX - this._startX
          local newWidth = math.max(280, math.min(480, this._startLeftWidth + delta))
          leftPane:SetSize(newWidth, 420)
        end)
      end
    end)

    divider:SetScript("OnMouseUp", function(self, button)
      self._dragging = false
      self:SetScript("OnUpdate", nil)
    end)

    local scroll = CreateFrame("ScrollFrame", "EmoteControlEditorScroll", leftPane, "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, -6)
    scroll:SetPoint("BOTTOMRIGHT", -28, 6)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
      FauxScrollFrame_OnVerticalScroll(self, offset, 16, BuildList)
    end)
    frame.scroll = scroll

    frame.rows = {}
    for i = 1, 14 do
      local row = CreateFrame("Button", nil, leftPane)
      row:SetSize(350, 24)
      row:SetPoint("TOPLEFT", 4, -6 - (i - 1) * 28)

      -- Background: darker when not selected, lighter on hover
      local bg = row:CreateTexture(nil, "BACKGROUND")
      bg:SetAllPoints()
      bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
      row.bg = bg

      -- Highlight bar on left edge for selected state
      local highlight = row:CreateTexture(nil, "ARTWORK")
      highlight:SetSize(3, 24)
      highlight:SetPoint("LEFT", row, "LEFT", 0, 0)
      highlight:SetColorTexture(0.2, 0.6, 1.0, 0.8)
      highlight:Hide()
      row.highlight = highlight

      local text = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
      text:SetPoint("TOPLEFT", 10, -2)
      text:SetText("")
      text:SetTextColor(1, 1, 1, 1)
      row.text = text

      local sub = row:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
      sub:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -1)
      sub:SetText("")
      sub:SetTextColor(0.8, 0.8, 0.8, 0.7)
      row.sub = sub

      row:SetScript("OnClick", function(self)
        selectedId = self.id
        RefreshDetails()
        BuildList()
      end)

      row:SetScript("OnEnter", function(self)
        if selectedId ~= self.id then
          bg:SetColorTexture(0.15, 0.15, 0.15, 0.7)
        end
      end)

      row:SetScript("OnLeave", function(self)
        if selectedId ~= self.id then
          bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        end
      end)

      frame.rows[i] = row
    end

    local rightPane = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    rightPane:SetPoint("TOPLEFT", divider, "TOPRIGHT", 4, 0)
    rightPane:SetPoint("BOTTOMRIGHT", -16, 16)
    MakeBackdrop(rightPane)

    local detailsTitle = rightPane:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    detailsTitle:SetPoint("TOPLEFT", 10, -10)
    detailsTitle:SetWidth(400)
    detailsTitle:SetJustifyH("LEFT")
    detailsTitle:SetText("Select a trigger")
    frame.detailsTitle = detailsTitle

    local enabled = CreateFrame("CheckButton", nil, rightPane, "UICheckButtonTemplate")
    enabled:SetPoint("TOPLEFT", detailsTitle, "BOTTOMLEFT", -2, -10)
    enabled.Text:SetText("Enabled")
    frame.enabled = enabled

    local cdLabel = rightPane:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cdLabel:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 2, -10)
    cdLabel:SetText("Cooldown override (seconds)")

    local cooldown = CreateFrame("EditBox", nil, rightPane, "InputBoxTemplate")
    cooldown:SetSize(80, 20)
    cooldown:SetPoint("LEFT", cdLabel, "RIGHT", 10, 0)
    cooldown:SetAutoFocus(false)
    cooldown:SetNumeric(true)
    frame.cooldown = cooldown

    local chLabel = rightPane:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    chLabel:SetPoint("TOPLEFT", cdLabel, "BOTTOMLEFT", 0, -14)
    chLabel:SetText("Channel override")

    local channelDD = CreateDropdown(rightPane, "EmoteControlEditorChannelDD", {
      { label = "(use global)", value = "" },
      { label = "Self", value = "SELF" },
      { label = "Auto", value = "AUTO" },
      { label = "Party", value = "PARTY" },
      { label = "Raid", value = "RAID" },
      { label = "Instance", value = "INSTANCE" },
      { label = "Say", value = "SAY" },
      { label = "Yell", value = "YELL" },
      { label = "Emote", value = "EMOTE" },
    }, function(v)
      -- handled on save
    end)
    channelDD:SetPoint("TOPLEFT", chLabel, "BOTTOMLEFT", -16, -4)
    channelDD:SetValue("")
    frame.channelDD = channelDD

    local msgLabel = rightPane:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    msgLabel:SetPoint("TOPLEFT", channelDD, "BOTTOMLEFT", 16, -12)
    msgLabel:SetText("Phrases (one per line)")

    local boxFrame = CreateFrame("Frame", nil, rightPane, "BackdropTemplate")
    boxFrame:SetPoint("TOPLEFT", msgLabel, "BOTTOMLEFT", 0, -6)
    boxFrame:SetPoint("BOTTOMRIGHT", -10, 54)
    MakeBackdrop(boxFrame)

    local scrollMsg = CreateFrame("ScrollFrame", "EmoteControlEditorMsgScroll", boxFrame, "UIPanelScrollFrameTemplate")
    scrollMsg:SetPoint("TOPLEFT", 6, -6)
    scrollMsg:SetPoint("BOTTOMRIGHT", -26, 6)

    local edit = CreateFrame("EditBox", nil, scrollMsg)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(360)
    edit:SetText("")
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scrollMsg:SetScrollChild(edit)
    frame.messagesBox = edit

    local save = CreateFrame("Button", nil, rightPane, "UIPanelButtonTemplate")
    save:SetSize(120, 22)
    save:SetPoint("BOTTOMLEFT", 10, 16)
    save:SetText("Save")
    save:SetScript("OnClick", function()
      if not selectedId then return end
      local trig = addon.TriggerById and addon.TriggerById[selectedId]
      if not trig then return end

      local ov = EnsureOverride(selectedId)
      if not ov then return end

      ov.enabled = enabled:GetChecked() and true or false

      local cd = tonumber(cooldown:GetText())
      if cd and cd > 0 then
        ov.cooldown = cd
      else
        ov.cooldown = nil
      end

      local ch = UIDropDownMenu_GetSelectedValue(channelDD)
      ch = addon:NormalizeChannel(ch) or ch
      if type(ch) == "string" and ch ~= "" then
        ov.channel = string.upper(ch)
      else
        ov.channel = nil
      end

      local lines = SplitLines(edit:GetText())
      if #lines > 0 then
        ov.messages = lines
      else
        ov.messages = nil
      end

      addon:Print("Saved override for " .. selectedId)
      RefreshDetails()
    end)

    local reset = CreateFrame("Button", nil, rightPane, "UIPanelButtonTemplate")
    reset:SetSize(120, 22)
    reset:SetPoint("LEFT", save, "RIGHT", 10, 0)
    reset:SetText("Reset")
    reset:SetScript("OnClick", function()
      local db = addon:GetDB()
      if not (selectedId and type(db) == "table" and type(db.triggerOverrides) == "table") then return end
      db.triggerOverrides[selectedId] = nil
      RefreshDetails()
    end)

    local hint = rightPane:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    hint:SetPoint("BOTTOMLEFT", reset, "TOPLEFT", 0, 10)
    hint:SetWidth(400)
    hint:SetJustifyH("LEFT")
    hint:SetText("Tokens: <player> <player-full> <realm> <faction> <class> <className> <spec> <specID> <role> <level> <ilvl> <race>\n<zone> <subzone> <mapID> <continent> <instance> <instance-type> <instanceName> <instanceDifficulty> <instance-difficulty-id>\n<instance-mapid> <instance-lfgid> <in-instance>\n<target> <target-full> <target-realm> <target-class> <target-race> <target-level> <target-health> <target-health%> <target-dead>\n<health%> <power%> <combo> <guild> <achievement> <item> <itemlink> <quality>\n<group-size> <party-size> <group-type> <is-raid> <is-party> <affixes> <affix-1> <affix-2> <affix-3> <affix-4>\n<keystone-level> <keystone-mapid> <time> <date> <weekday>\n<pick:a|b|c>  |  <rng:1-100>")

    frame:SetScript("OnShow", function()
      BuildList()
      RefreshDetails()
    end)
  end

  frame:Show()
  BuildList()
  RefreshDetails()
end
