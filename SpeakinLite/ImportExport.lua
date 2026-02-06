-- EmoteControl - Import/Export System
-- Enables sharing and importing trigger configurations between players
-- Uses Base64 encoding for compact configuration strings

EmoteControl = EmoteControl or {}
if rawget(_G, "SpeakinLite") == nil then
  SpeakinLite = EmoteControl  -- Backward compatibility alias
end
local addon = EmoteControl

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
  if type(data) ~= "string" then return nil, "Invalid base64 input" end
  if data:find("[^" .. b64chars .. "=%s]") then
    return nil, "Invalid base64 alphabet"
  end
  data = data:gsub("%s+", "")
  if data == "" then return "", nil end
  if (#data % 4) ~= 0 then
    return nil, "Invalid base64 length"
  end
  
  local result = {}
  for i = 1, #data, 4 do
    local chunk = data:sub(i, i + 3)
    local s1, s2, s3, s4 = chunk:sub(1, 1), chunk:sub(2, 2), chunk:sub(3, 3), chunk:sub(4, 4)
    if s1 == "" or s2 == "" or s3 == "" or s4 == "" then
      return nil, "Invalid base64 chunk"
    end

    local c1 = b64lookup[s1]
    local c2 = b64lookup[s2]
    local c3 = (s3 == "=") and 0 or b64lookup[s3]
    local c4 = (s4 == "=") and 0 or b64lookup[s4]
    if c1 == nil or c2 == nil or c3 == nil or c4 == nil then
      return nil, "Invalid base64 alphabet"
    end
    
    local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4
    local a = math.floor(n / 65536) % 256
    local b = math.floor(n / 256) % 256
    local c = n % 256
    
    table.insert(result, string.char(a))
    if s3 ~= "=" then
      table.insert(result, string.char(b))
    end
    if s4 ~= "=" then
      table.insert(result, string.char(c))
    end
  end
  
  return table.concat(result), nil
end

-- Minimal JSON encoder/decoder (safe for WoW; no loadstring)
local function JsonEscape(s)
  return s:gsub("[\\\"\b\f\n\r\t]", function(c)
    if c == "\\" then return "\\\\"
    elseif c == "\"" then return "\\\""
    elseif c == "\b" then return "\\b"
    elseif c == "\f" then return "\\f"
    elseif c == "\n" then return "\\n"
    elseif c == "\r" then return "\\r"
    elseif c == "\t" then return "\\t"
    end
  end)
end

local function IsArrayTable(t)
  local max = 0
  for k, _ in pairs(t) do
    if type(k) ~= "number" or k <= 0 or k % 1 ~= 0 then
      return false
    end
    if k > max then max = k end
  end
  for i = 1, max do
    if t[i] == nil then return false end
  end
  return true, max
end

local function JsonEncodeValue(v, depth)
  depth = depth or 0
  if depth > 20 then return "null" end

  local t = type(v)
  if t == "nil" then return "null" end
  if t == "boolean" then return v and "true" or "false" end
  if t == "number" then return tostring(v) end
  if t == "string" then return "\"" .. JsonEscape(v) .. "\"" end
  if t ~= "table" then return "null" end

  local isArray, max = IsArrayTable(v)
  if isArray then
    local parts = {"["}
    for i = 1, max do
      if i > 1 then table.insert(parts, ",") end
      table.insert(parts, JsonEncodeValue(v[i], depth + 1))
    end
    table.insert(parts, "]")
    return table.concat(parts)
  end

  local parts = {"{"}
  local keys = {}
  for k, _ in pairs(v) do
    if type(k) == "string" then
      table.insert(keys, k)
    end
  end
  table.sort(keys)
  for idx, k in ipairs(keys) do
    if idx > 1 then table.insert(parts, ",") end
    table.insert(parts, "\"" .. JsonEscape(k) .. "\":" .. JsonEncodeValue(v[k], depth + 1))
  end
  table.insert(parts, "}")
  return table.concat(parts)
end

local function JsonDecode(str)
  if type(str) ~= "string" or str == "" then return nil, "Empty input" end

  local i = 1
  local len = #str

  local function skip()
    while i <= len do
      local c = str:sub(i, i)
      if c == " " or c == "\n" or c == "\r" or c == "\t" then
        i = i + 1
      else
        break
      end
    end
  end

  local function parseString()
    i = i + 1 -- skip opening quote
    local out = {}
    while i <= len do
      local c = str:sub(i, i)
      if c == "\"" then
        i = i + 1
        return table.concat(out)
      elseif c == "\\" then
        local n = str:sub(i + 1, i + 1)
        if n == "\"" or n == "\\" or n == "/" then
          table.insert(out, n)
          i = i + 2
        elseif n == "b" then table.insert(out, "\b"); i = i + 2
        elseif n == "f" then table.insert(out, "\f"); i = i + 2
        elseif n == "n" then table.insert(out, "\n"); i = i + 2
        elseif n == "r" then table.insert(out, "\r"); i = i + 2
        elseif n == "t" then table.insert(out, "\t"); i = i + 2
        elseif n == "u" then
          local hex = str:sub(i + 2, i + 5)
          if #hex ~= 4 or not hex:match("^[0-9a-fA-F]+$") then
            return nil, "Invalid unicode escape"
          end
          local code = tonumber(hex, 16) or 0
          if code <= 255 then
            table.insert(out, string.char(code))
          else
            return nil, "Unicode escape out of range"
          end
          i = i + 6
        else
          return nil, "Invalid escape"
        end
      else
        table.insert(out, c)
        i = i + 1
      end
    end
    return nil, "Unterminated string"
  end

  local function parseNumber()
    local s, e = str:find("%-?%d+%.?%d*[eE]?[%+%-]?%d*", i)
    if not s then return nil, "Invalid number" end
    local num = tonumber(str:sub(s, e))
    i = e + 1
    return num
  end

  local parseValue

  local function parseArray()
    i = i + 1 -- skip [
    local arr = {}
    skip()
    if str:sub(i, i) == "]" then
      i = i + 1
      return arr
    end
    while i <= len do
      local v, err = parseValue()
      if err then return nil, err end
      table.insert(arr, v)
      skip()
      local c = str:sub(i, i)
      if c == "," then
        i = i + 1
        skip()
      elseif c == "]" then
        i = i + 1
        return arr
      else
        return nil, "Expected , or ]"
      end
    end
    return nil, "Unterminated array"
  end

  local function parseObject()
    i = i + 1 -- skip {
    local obj = {}
    skip()
    if str:sub(i, i) == "}" then
      i = i + 1
      return obj
    end
    while i <= len do
      if str:sub(i, i) ~= "\"" then
        return nil, "Expected string key"
      end
      local key, err = parseString()
      if err then return nil, err end
      skip()
      if str:sub(i, i) ~= ":" then return nil, "Expected :" end
      i = i + 1
      skip()
      local val, err2 = parseValue()
      if err2 then return nil, err2 end
      obj[key] = val
      skip()
      local c = str:sub(i, i)
      if c == "," then
        i = i + 1
        skip()
      elseif c == "}" then
        i = i + 1
        return obj
      else
        return nil, "Expected , or }"
      end
    end
    return nil, "Unterminated object"
  end

  parseValue = function()
    skip()
    local c = str:sub(i, i)
    if c == "\"" then return parseString() end
    if c == "{" then return parseObject() end
    if c == "[" then return parseArray() end
    if c == "t" and str:sub(i, i + 3) == "true" then i = i + 4; return true end
    if c == "f" and str:sub(i, i + 4) == "false" then i = i + 5; return false end
    if c == "n" and str:sub(i, i + 3) == "null" then i = i + 4; return nil end
    if c:match("[%-%d]") then return parseNumber() end
    return nil, "Unexpected character"
  end

  local result, err = parseValue()
  if err then return nil, err end
  skip()
  if i <= len then return nil, "Trailing data" end
  return result
end

-- Serialize a table to a string (JSON)
local function SerializeTable(tbl)
  return JsonEncodeValue(tbl, 0)
end

-- Deserialize a string to a table (JSON)
local function DeserializeTable(str)
  return JsonDecode(str)
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
  local serialized, decodeErr = Base64Decode(encoded)
  if not serialized then
    return false, "Invalid Base64 data: " .. tostring(decodeErr)
  end
  local data, err = DeserializeTable(serialized)
  
  if not data then
    return false, "Failed to decode: " .. tostring(err)
  end
  
  if data.type ~= "trigger" then
    return false, "Invalid data type: " .. tostring(data.type)
  end

  if type(data.id) ~= "string" or data.id == "" then
    return false, "Invalid trigger id"
  end

  if type(data.data) ~= "table" then
    return false, "Invalid trigger data"
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
  local serialized, decodeErr = Base64Decode(encoded)
  if not serialized then
    return false, "Invalid Base64 data: " .. tostring(decodeErr)
  end
  local data, err = DeserializeTable(serialized)
  
  if not data then
    return false, "Failed to decode: " .. tostring(err)
  end
  
  if data.type ~= "triggers" then
    return false, "Invalid data type: " .. tostring(data.type)
  end

  if type(data.data) ~= "table" then
    return false, "Invalid trigger data"
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
      if not db.triggerOverrides[id] and type(override) == "table" then
        db.triggerOverrides[id] = override
        count = count + 1
      end
    end
  else
    -- Replace mode: overwrite all
    db.triggerOverrides = {}
    for id, override in pairs(data.data) do
      if type(override) == "table" then
        db.triggerOverrides[id] = override
        count = count + 1
      end
    end
  end
  
  return true, "Imported " .. count .. " trigger(s)"
end

-- UI for import/export
function addon:OpenImportExportUI()
  local frame = addon._importExportFrame
  
  if not frame then
    frame = CreateFrame("Frame", "EmoteControlImportExportFrame", UIParent, "BasicFrameTemplateWithInset")
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
    frame.title:SetText("Emote Control - Import/Export")
    
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
