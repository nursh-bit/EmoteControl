-- SpeakinLite - Import/Export System
-- Allows users to share trigger configurations

SpeakinLite = SpeakinLite or {}
local addon = SpeakinLite

-- Base64 encoding/decoding (simple implementation)
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local b64lookup = {}
for i = 1, #b64chars do
  b64lookup[b64chars:sub(i,i)] = i - 1
end

local function Base64Encode(data)
  if type(data) ~= "string" then return "" end
  local result = {}
  local padding = ""
  
  for i = 1, #data, 3 do
    local a, b, c = data:byte(i, i+2)
    b = b or 0
    c = c or 0
    
    local n = a * 65536 + b * 256 + c
    local c1 = math.floor(n / 262144) % 64
    local c2 = math.floor(n / 4096) % 64
    local c3 = math.floor(n / 64) % 64
    local c4 = n % 64
    
    table.insert(result, b64chars:sub(c1+1, c1+1))
    table.insert(result, b64chars:sub(c2+1, c2+1))
    table.insert(result, b64chars:sub(c3+1, c3+1))
    table.insert(result, b64chars:sub(c4+1, c4+1))
  end
  
  local remainder = #data % 3
  if remainder == 1 then
    result[#result] = '='
    result[#result-1] = '='
  elseif remainder == 2 then
    result[#result] = '='
  end
  
  return table.concat(result)
end

local function Base64Decode(data)
  if type(data) ~= "string" then return "" end
  data = data:gsub("[^" .. b64chars .. "=]", "")
  
  local result = {}
  for i = 1, #data, 4 do
    local c1, c2, c3, c4 = data:sub(i, i+3):byte(1, 4)
    c1 = b64lookup[string.char(c1)] or 0
    c2 = b64lookup[string.char(c2)] or 0
    c3 = b64lookup[string.char(c3 or 61)] or 0
    c4 = b64lookup[string.char(c4 or 61)] or 0
    
    local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4
    local a = math.floor(n / 65536) % 256
    local b = math.floor(n / 256) % 256
    local c = n % 256
    
    table.insert(result, string.char(a))
    if data:sub(i+2, i+2) ~= '=' then
      table.insert(result, string.char(b))
    end
    if data:sub(i+3, i+3) ~= '=' then
      table.insert(result, string.char(c))
    end
  end
  
  return table.concat(result)
end

-- Serialize a table to a string
local function SerializeTable(tbl, depth)
  depth = depth or 0
  if depth > 10 then return "nil" end -- Prevent infinite recursion
  
  if type(tbl) ~= "table" then
    if type(tbl) == "string" then
      return string.format("%q", tbl)
    else
      return tostring(tbl)
    end
  end
  
  local parts = {"{"}
  for k, v in pairs(tbl) do
    local key
    if type(k) == "string" and k:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
      key = k
    else
      key = "[" .. SerializeTable(k, depth + 1) .. "]"
    end
    table.insert(parts, key .. "=" .. SerializeTable(v, depth + 1) .. ",")
  end
  table.insert(parts, "}")
  return table.concat(parts)
end

-- Deserialize a string to a table (safe load)
local function DeserializeTable(str)
  if type(str) ~= "string" or str == "" then return nil end
  
  -- Create a safe environment
  local env = {
    math = math,
    string = string,
    table = table,
  }
  
  local func, err = loadstring("return " .. str)
  if not func then
    return nil, "Parse error: " .. tostring(err)
  end
  
  setfenv(func, env)
  local ok, result = pcall(func)
  if not ok then
    return nil, "Execution error: " .. tostring(result)
  end
  
  return result
end

-- Export trigger override
function addon:ExportTrigger(triggerId)
  local db = addon:GetDB()
  if not db or type(db.triggerOverrides) ~= "table" then
    return nil, "No database found"
  end
  
  local override = db.triggerOverrides[triggerId]
  if not override then
    return nil, "Trigger not found: " .. tostring(triggerId)
  end
  
  local data = {
    version = addon.VERSION,
    type = "trigger",
    id = triggerId,
    data = override,
  }
  
  local serialized = SerializeTable(data)
  local encoded = Base64Encode(serialized)
  return "SL1:" .. encoded
end

-- Import trigger override
function addon:ImportTrigger(importString)
  if type(importString) ~= "string" then
    return false, "Invalid import string"
  end
  
  -- Check prefix
  if not importString:match("^SL1:") then
    return false, "Invalid format (missing SL1: prefix)"
  end
  
  local encoded = importString:sub(5)
  local serialized = Base64Decode(encoded)
  local data, err = DeserializeTable(serialized)
  
  if not data then
    return false, "Failed to decode: " .. tostring(err)
  end
  
  if data.type ~= "trigger" then
    return false, "Invalid data type: " .. tostring(data.type)
  end
  
  local db = addon:GetDB()
  if not db then
    return false, "No database found"
  end
  
  if type(db.triggerOverrides) ~= "table" then
    db.triggerOverrides = {}
  end
  
  -- Import the trigger
  db.triggerOverrides[data.id] = data.data
  
  return true, "Imported trigger: " .. tostring(data.id)
end

-- Export all trigger overrides
function addon:ExportAllTriggers()
  local db = addon:GetDB()
  if not db or type(db.triggerOverrides) ~= "table" then
    return nil, "No overrides to export"
  end
  
  local count = 0
  for _ in pairs(db.triggerOverrides) do count = count + 1 end
  
  if count == 0 then
    return nil, "No overrides to export"
  end
  
  local data = {
    version = addon.VERSION,
    type = "triggers",
    data = db.triggerOverrides,
  }
  
  local serialized = SerializeTable(data)
  local encoded = Base64Encode(serialized)
  return "SL1:" .. encoded
end

-- Import all trigger overrides
function addon:ImportAllTriggers(importString, merge)
  if type(importString) ~= "string" then
    return false, "Invalid import string"
  end
  
  if not importString:match("^SL1:") then
    return false, "Invalid format (missing SL1: prefix)"
  end
  
  local encoded = importString:sub(5)
  local serialized = Base64Decode(encoded)
  local data, err = DeserializeTable(serialized)
  
  if not data then
    return false, "Failed to decode: " .. tostring(err)
  end
  
  if data.type ~= "triggers" then
    return false, "Invalid data type: " .. tostring(data.type)
  end
  
  local db = addon:GetDB()
  if not db then
    return false, "No database found"
  end
  
  if type(db.triggerOverrides) ~= "table" then
    db.triggerOverrides = {}
  end
  
  local count = 0
  if merge then
    -- Merge mode: only add new triggers
    for id, override in pairs(data.data) do
      if not db.triggerOverrides[id] then
        db.triggerOverrides[id] = override
        count = count + 1
      end
    end
  else
    -- Replace mode: overwrite all
    db.triggerOverrides = data.data
    for _ in pairs(data.data) do count = count + 1 end
  end
  
  return true, "Imported " .. count .. " trigger(s)"
end

-- UI for import/export
function addon:OpenImportExportUI()
  local frame = addon._importExportFrame
  
  if not frame then
    frame = CreateFrame("Frame", "SpeakinLiteImportExportFrame", UIParent, "BasicFrameTemplateWithInset")
    addon._importExportFrame = frame
    
    frame:SetSize(600, 400)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -5)
    frame.title:SetText("SpeakinLite - Import/Export")
    
    -- Export section
    local exportLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    exportLabel:SetPoint("TOPLEFT", 20, -30)
    exportLabel:SetText("Export (copy this string):")
    
    local exportBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    exportBox:SetPoint("TOPLEFT", exportLabel, "BOTTOMLEFT", 5, -5)
    exportBox:SetSize(540, 20)
    exportBox:SetAutoFocus(false)
    exportBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    frame.exportBox = exportBox
    
    local exportBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    exportBtn:SetPoint("TOPLEFT", exportBox, "BOTTOMLEFT", -5, -5)
    exportBtn:SetSize(120, 22)
    exportBtn:SetText("Generate Export")
    exportBtn:SetScript("OnClick", function()
      local str, err = addon:ExportAllTriggers()
      if str then
        exportBox:SetText(str)
        exportBox:HighlightText()
        exportBox:SetFocus()
        addon:Print("Export string generated. Press Ctrl+C to copy.")
      else
        addon:Print("Export failed: " .. tostring(err))
      end
    end)
    
    -- Import section
    local importLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    importLabel:SetPoint("TOPLEFT", exportBtn, "BOTTOMLEFT", 5, -20)
    importLabel:SetText("Import (paste string here):")
    
    local importBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    importBox:SetPoint("TOPLEFT", importLabel, "BOTTOMLEFT", 5, -5)
    importBox:SetSize(540, 20)
    importBox:SetAutoFocus(false)
    importBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    frame.importBox = importBox
    
    local importBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    importBtn:SetPoint("TOPLEFT", importBox, "BOTTOMLEFT", -5, -5)
    importBtn:SetSize(120, 22)
    importBtn:SetText("Import (Replace)")
    importBtn:SetScript("OnClick", function()
      local str = importBox:GetText()
      local ok, msg = addon:ImportAllTriggers(str, false)
      if ok then
        addon:Print(msg)
        addon:RebuildAndRegister()
      else
        addon:Print("Import failed: " .. tostring(msg))
      end
    end)
    
    local mergeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    mergeBtn:SetPoint("LEFT", importBtn, "RIGHT", 5, 0)
    mergeBtn:SetSize(120, 22)
    mergeBtn:SetText("Import (Merge)")
    mergeBtn:SetScript("OnClick", function()
      local str = importBox:GetText()
      local ok, msg = addon:ImportAllTriggers(str, true)
      if ok then
        addon:Print(msg)
        addon:RebuildAndRegister()
      else
        addon:Print("Import failed: " .. tostring(msg))
      end
    end)
    
    -- Help text
    local helpText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    helpText:SetPoint("TOPLEFT", importBtn, "BOTTOMLEFT", 5, -15)
    helpText:SetWidth(540)
    helpText:SetJustifyH("LEFT")
    helpText:SetText("Export: Generates a shareable string of all your custom trigger overrides.\n\nImport (Replace): Replaces all your current overrides with the imported ones.\n\nImport (Merge): Adds imported overrides without removing your existing ones.")
    
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetPoint("BOTTOM", 0, 10)
    closeBtn:SetSize(100, 22)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
  end
  
  frame:Show()
end
