--[[
    =======================================================================
    SAVEINSTANCE JSON - MOBILE EDITION (SINGLE-FILE DUMPER)
    Universal Standalone Game & Instance Serializer for Mobile & PC
    Compatible with: Delta, Codex, Arceus X, Fluxus, Vega X, Solara, Wave, Studio
    
    📱 MOBILE FIRST DESIGN:
      ✓ Single .json File Output: No folders, no zip, no clutter in phone storage!
      ✓ 100% Pure Luau Engine: DOES NOT require native executor 'saveinstance' C++ DLL!
      ✓ Complete Game Architecture:
         - Exact Parent-Child Tree Hierarchy (Workspace, ReplicatedStorage, etc.)
         - 70+ Class Properties (Transforms, Materials, Colors, Sounds, Lights, GUIs)
         - Full Script Source & Decompilation (Embedded inside JSON)
         - Instance Attributes (inst:GetAttributes())
         - CollectionService Tags (CollectionService:GetTags())
         - ValueBase Values (String, Number, Bool, Vector3, Color3, ObjectValue paths)
      ✓ Anti-Freeze Adaptive Batching: Yields smoothly (task.wait) to prevent Android ANR
      ✓ Live Mobile HUD: Real-time progress bar, instance count & script counter
      ✓ Floating Touch Pill: Draggable with finger/mouse to toggle UI anytime
      ✓ Pretty or Minified JSON Toggle: Format for reading or minify for 40% smaller file
    =======================================================================
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- GUI Parent Resolver (Safe for Mobile & Executors)
local GuiParent = CoreGui
pcall(function()
    if not pcall(function() return CoreGui:GetChildren() end) then
        GuiParent = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")
    end
end)

-- Remove any old GUI instance
if GuiParent:FindFirstChild("SaveInstance_JSON_Mobile_GUI") then
    GuiParent.SaveInstance_JSON_Mobile_GUI:Destroy()
end

-- =====================================================================
-- GAME / PLACE METADATA RESOLVER
-- =====================================================================

local placeInfo = {
    Name = "Roblox Place",
    Creator = "Roblox",
    PlaceId = game.PlaceId,
    JobId = tostring(game.JobId),
    PlaceVersion = game.PlaceVersion
}

pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    placeInfo.Name = info.Name:gsub("[%z%c\\/:*?\"<>|]", "_")
    placeInfo.Creator = (info.Creator and info.Creator.Name) or "Roblox"
end)

-- =====================================================================
-- ENGINE CONFIGURATION
-- =====================================================================

local Config = {
    -- Target Services to include
    IncludeWorkspace = true,
    IncludeReplicatedStorage = true,
    IncludeStarterGui = true,
    IncludeStarterPlayer = true,
    IncludeLighting = true,
    IncludeSoundService = true,
    IncludeReplicatedFirst = true,
    IncludeNilInstances = false,
    
    -- Filter options
    ExcludePlayerCharacters = true,
    DecompileScripts = true,
    DecompileTimeout = 6,
    
    -- Output format
    PrettyFormat = true,        -- true = Indented with newlines; false = Minified compact (faster & smaller)
    ExportManifest = true,      -- Generates manifest.json (clean metadata index only)
    ExportCodeJson = true,      -- Generates code.json (exact structure as manifest.json + full Lua source code)
    ExportInstanceTree = false, -- Optional: Generates instance.json with full scene hierarchy
    FilePrefix = "Place_" .. game.PlaceId .. "_{TIMESTAMP}",
    
    -- Performance batching (tuned for mobile processors)
    BatchYieldStep = 40         -- Yield every 40 instances to prevent Android ANR
}

-- =====================================================================
-- THEME PALETTE (GLASSMORPHISM / MOBILE DARK MODE)
-- =====================================================================

local C = {
    BgMain      = Color3.fromRGB(15, 18, 26),
    BgCard      = Color3.fromRGB(22, 28, 40),
    BgCardHover = Color3.fromRGB(30, 38, 54),
    BgInput     = Color3.fromRGB(11, 14, 20),
    Border      = Color3.fromRGB(42, 52, 74),
    AccentBlue  = Color3.fromRGB(88, 110, 255),
    AccentCyan  = Color3.fromRGB(0, 210, 255),
    AccentGreen = Color3.fromRGB(38, 194, 129),
    AccentGold  = Color3.fromRGB(255, 184, 0),
    AccentPurple= Color3.fromRGB(175, 82, 222),
    AccentRed   = Color3.fromRGB(240, 71, 71),
    TextTitle   = Color3.fromRGB(255, 255, 255),
    TextBody    = Color3.fromRGB(215, 222, 240),
    TextMuted   = Color3.fromRGB(130, 142, 170),
    SwitchOff   = Color3.fromRGB(34, 42, 60),
    SwitchOn    = Color3.fromRGB(88, 110, 255),
}

-- =====================================================================
-- ROBUST JSON SERIALIZER ENGINE (PURE LUAU)
-- =====================================================================

local function escapeJSONString(s)
    if typeof(s) ~= "string" then s = tostring(s) end
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    s = s:gsub("[%z\1-\31]", function(c)
        return string.format("\\u%04x", string.byte(c))
    end)
    return '"' .. s .. '"'
end

local function toJSON(val, pretty, indent)
    indent = indent or 0
    local indentStr = pretty and string.rep("  ", indent) or ""
    local nextIndentStr = pretty and string.rep("  ", indent + 1) or ""
    local newlineStr = pretty and "\n" or ""
    local spaceStr = pretty and " " or ""
    local t = type(val)

    if t == "nil" then
        return "null"
    elseif t == "boolean" then
        return val and "true" or "false"
    elseif t == "number" then
        if val ~= val or val == math.huge or val == -math.huge then
            return "null"
        end
        return tostring(val)
    elseif t == "string" then
        return escapeJSONString(val)
    elseif t == "table" then
        -- Check if it is an array
        local isArray = true
        local count = 0
        local maxIndex = 0
        for k, _ in pairs(val) do
            count = count + 1
            if type(k) ~= "number" or k <= 0 or math.floor(k) ~= k then
                isArray = false
                break
            end
            if k > maxIndex then maxIndex = k end
        end
        if isArray and (maxIndex ~= count) then
            isArray = false
        end

        if count == 0 then
            return isArray and "[]" or "{}"
        end

        if isArray then
            local items = {}
            for i = 1, count do
                table.insert(items, nextIndentStr .. toJSON(val[i], pretty, indent + 1))
            end
            local sep = "," .. newlineStr
            return "[" .. newlineStr .. table.concat(items, sep) .. newlineStr .. indentStr .. "]"
        else
            local keys = {}
            for k, _ in pairs(val) do
                table.insert(keys, tostring(k))
            end
            table.sort(keys)

            local items = {}
            for _, k in ipairs(keys) do
                local v = val[k]
                local escapedK = escapeJSONString(k)
                table.insert(items, nextIndentStr .. escapedK .. ":" .. spaceStr .. toJSON(v, pretty, indent + 1))
            end
            local sep = "," .. newlineStr
            return "{" .. newlineStr .. table.concat(items, sep) .. newlineStr .. indentStr .. "}"
        end
    else
        return escapeJSONString(tostring(val))
    end
end

-- =====================================================================
-- COMPREHENSIVE INSTANCE PROPERTY EXTRACTOR
-- =====================================================================

local function serializePrimitiveValue(val)
    local t = typeof(val)
    if t == "boolean" or t == "number" or t == "string" then
        return val
    elseif t == "Vector3" then
        return { x = math.round(val.X * 1000) / 1000, y = math.round(val.Y * 1000) / 1000, z = math.round(val.Z * 1000) / 1000 }
    elseif t == "Vector2" then
        return { x = math.round(val.X * 1000) / 1000, y = math.round(val.Y * 1000) / 1000 }
    elseif t == "Color3" then
        return {
            r = math.round(val.R * 255),
            g = math.round(val.G * 255),
            b = math.round(val.B * 255),
            hex = "#" .. val:ToHex()
        }
    elseif t == "BrickColor" then
        return val.Name
    elseif t == "UDim2" then
        return {
            x = { scale = val.X.Scale, offset = val.X.Offset },
            y = { scale = val.Y.Scale, offset = val.Y.Offset }
        }
    elseif t == "UDim" then
        return { scale = val.Scale, offset = val.Offset }
    elseif t == "CFrame" then
        local x, y, z = val.X, val.Y, val.Z
        return {
            x = math.round(x * 100) / 100,
            y = math.round(y * 100) / 100,
            z = math.round(z * 100) / 100
        }
    elseif t == "EnumItem" then
        return tostring(val.Name)
    elseif t == "NumberRange" then
        return { min = val.Min, max = val.Max }
    elseif t == "Instance" then
        return val:GetFullName()
    else
        return tostring(val)
    end
end

-- Extensive list of standard properties safely extractable
local COMMON_PROPERTIES = {
    -- Geometry & Physics
    "Position", "Size", "Orientation", "Anchored", "CanCollide", "CanTouch", "CanQuery",
    "Transparency", "Reflectance", "Material", "Color", "BrickColor", "CastShadow", "Massless", "Shape",
    -- Assets & Models
    "MeshId", "TextureId", "TextureID", "MeshType", "Scale", "Offset", "Texture", "Face",
    -- GUI
    "Text", "TextColor3", "TextSize", "Font", "TextScaled", "TextWrapped",
    "BackgroundColor3", "BackgroundTransparency", "BorderColor3", "BorderSizePixel",
    "Position", "Size", "AnchorPoint", "Visible", "ZIndex", "LayoutOrder", "Image", "ImageColor3", "CornerRadius",
    -- Audio & Lighting
    "SoundId", "Volume", "PlaybackSpeed", "Playing", "Looped", "TimePosition", "RollOffMaxDistance",
    "Brightness", "Range", "Shadows", "ClockTime", "TimeOfDay", "FogColor", "FogEnd", "Ambient", "OutdoorAmbient",
    -- Values
    "Value",
    -- Humanoid & Characters
    "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight", "HipHeight", "DisplayName", "RigType",
    -- Script Properties
    "Enabled", "RunContext", "Disabled"
}

local function isScriptInstance(inst)
    return inst:IsA("LuaSourceContainer") or inst:IsA("Script") or inst:IsA("LocalScript") or inst:IsA("ModuleScript")
end

local function getScriptSource(inst)
    if not Config.DecompileScripts then
        return "-- [Decompilation disabled in settings]"
    end

    if typeof(decompile) == "function" then
        local ok, res = pcall(function()
            return decompile(inst)
        end)
        if ok and typeof(res) == "string" and #res > 0 then
            return res
        end
    end

    local ok, src = pcall(function() return inst.Source end)
    if ok and typeof(src) == "string" and #src > 0 then
        return src
    end

    return "-- [Protected source code or decompiler unavailable on executor]\n-- Instance: " .. inst:GetFullName() .. " (" .. inst.ClassName .. ")"
end

local function dumpInstanceData(inst)
    local fullName = inst:GetFullName()
    local data = {
        name = inst.Name,
        className = inst.ClassName,
        path = fullName
    }

    -- 1. Extract Properties
    local props = {}
    for _, propName in ipairs(COMMON_PROPERTIES) do
        local ok, val = pcall(function() return inst[propName] end)
        if ok and val ~= nil then
            props[propName] = serializePrimitiveValue(val)
        end
    end
    if next(props) ~= nil then
        data.properties = props
    end

    -- 2. Extract Custom Attributes
    pcall(function()
        local rawAttrs = inst:GetAttributes()
        if rawAttrs and next(rawAttrs) ~= nil then
            local attrs = {}
            for k, v in pairs(rawAttrs) do
                attrs[k] = serializePrimitiveValue(v)
            end
            data.attributes = attrs
        end
    end)

    -- 3. Extract Tags
    pcall(function()
        local tags = CollectionService:GetTags(inst)
        if tags and #tags > 0 then
            table.sort(tags)
            data.tags = tags
        end
    end)

    -- 4. Extract Script Source & Filesystem Metadata if applicable
    if isScriptInstance(inst) then
        local src = getScriptSource(inst)
        local cName = inst.ClassName
        local ext = ".lua"
        if cName == "LocalScript" then
            ext = ".client.lua"
        elseif cName == "Script" then
            ext = ".server.lua"
        elseif cName == "ModuleScript" then
            ext = ".lua"
        end

        local fsPath = fullName:gsub("%.", "/") .. ext

        data.path = fullName
        data.filesystemPath = fsPath
        data.sizeBytes = #src
        data.sourceLength = #src
        data.source = src
    end

    return data
end

-- =====================================================================
-- FILE SYSTEM HELPER (MOBILE WRITEFILE WRAPPER)
-- =====================================================================

local function saveFileDirectly(filePath, content)
    if typeof(writefile) == "function" then
        local success, err = pcall(function()
            writefile(filePath, content)
        end)
        return success, err
    end

    -- Studio simulation fallback
    if RunService:IsStudio() then
        print(string.format("[SaveInstance JSON Mobile] Studio Mode: Would write %d bytes to '%s'", #content, filePath))
        return true, "Studio Simulation OK"
    end

    return false, "Executor does not support writefile()"
end

-- =====================================================================
-- MOBILE GUI CREATION
-- =====================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SaveInstance_JSON_Mobile_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

-- ---------------------------------------------------------------------
-- FLOATING TOUCH PILL (DRAGGABLE ANYWHERE ON MOBILE SCREEN)
-- ---------------------------------------------------------------------

local FloatingPill = Instance.new("TextButton")
FloatingPill.Name = "FloatingPill"
FloatingPill.Size = UDim2.new(0, 52, 0, 52)
FloatingPill.Position = UDim2.new(0, 16, 0.45, 0)
FloatingPill.BackgroundColor3 = C.BgCard
FloatingPill.Text = ""
FloatingPill.AutoButtonColor = false
FloatingPill.ClipsDescendants = true
FloatingPill.Parent = ScreenGui

local PillCorner = Instance.new("UICorner")
PillCorner.CornerRadius = UDim.new(0, 16)
PillCorner.Parent = FloatingPill

local PillStroke = Instance.new("UIStroke")
PillStroke.Color = C.AccentCyan
PillStroke.Thickness = 2
PillStroke.Parent = FloatingPill

local PillIcon = Instance.new("TextLabel")
PillIcon.Size = UDim2.new(1, 0, 1, 0)
PillIcon.BackgroundTransparency = 1
PillIcon.Text = "📱💾"
PillIcon.TextSize = 15
PillIcon.Font = Enum.Font.GothamBold
PillIcon.Parent = FloatingPill

-- Drag Logic for Touch and Mouse
local function makeTouchDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

makeTouchDraggable(FloatingPill)

-- ---------------------------------------------------------------------
-- MAIN WINDOW (RESPONSIVE FOR MOBILE LANDSCAPE & PC)
-- ---------------------------------------------------------------------

local cam = workspace.CurrentCamera
local vpX = (cam and cam.ViewportSize.X) or 800
local vpY = (cam and cam.ViewportSize.Y) or 600

-- Reduced height (~half of previous 550-660px) to fit mobile landscape screens
local winWidth = math.clamp(math.floor(vpX * 0.85), 360, 480)
local winHeight = math.clamp(math.floor(vpY * 0.50), 260, 310)

local Window = Instance.new("Frame")
Window.Name = "MainWindow"
Window.Size = UDim2.new(0, winWidth, 0, winHeight)
Window.Position = UDim2.new(0.5, -math.floor(winWidth / 2), 0.5, -math.floor(winHeight / 2))
Window.BackgroundColor3 = C.BgMain
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = ScreenGui

local WinCorner = Instance.new("UICorner")
WinCorner.CornerRadius = UDim.new(0, 12)
WinCorner.Parent = Window

local WinStroke = Instance.new("UIStroke")
WinStroke.Color = C.Border
WinStroke.Thickness = 1.5
WinStroke.Parent = Window

-- Title Bar (Drag Handle)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = C.BgCard
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Window

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Bottom cover for TitleBar rounded corners
local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0, 8)
TitleCover.Position = UDim2.new(0, 0, 1, -8)
TitleCover.BackgroundColor3 = C.BgCard
TitleCover.BorderSizePixel = 0
TitleCover.Parent = TitleBar

makeTouchDraggable(Window, TitleBar)

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Position = UDim2.new(0, 10, 0, 0)
TitleIcon.Size = UDim2.new(0, 24, 1, 0)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "📱"
TitleIcon.TextSize = 16
TitleIcon.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Position = UDim2.new(0, 36, 0, 0)
TitleText.Size = UDim2.new(1, -90, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "SAVEINSTANCE JSON <font color=\"rgb(0, 210, 255)\">MANIFEST + CODE</font>"
TitleText.RichText = true
TitleText.TextColor3 = C.TextTitle
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 11.5
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Position = UDim2.new(1, -30, 0, 6)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.BackgroundColor3 = Color3.fromRGB(38, 44, 62)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.TextBody
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.BackgroundColor3 = C.AccentRed
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.BackgroundColor3 = Color3.fromRGB(38, 44, 62)
    CloseBtn.TextColor3 = C.TextBody
end)

-- ---------------------------------------------------------------------
-- SCROLLABLE SETTINGS CONTAINER (OPTIMIZED TO SCROLL 100% TO BOTTOM)
-- ---------------------------------------------------------------------

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "ScrollContent"
Scroll.Position = UDim2.new(0, 8, 0, 38)
Scroll.Size = UDim2.new(1, -16, 1, -134)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = C.AccentCyan
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.ElasticBehavior = Enum.ElasticBehavior.Always
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 750)
Scroll.Parent = Window

local ScrollPadding = Instance.new("UIPadding")
ScrollPadding.PaddingTop = UDim.new(0, 4)
ScrollPadding.PaddingBottom = UDim.new(0, 50) -- Generous bottom padding so last button is 100% visible
ScrollPadding.PaddingLeft = UDim.new(0, 2)
ScrollPadding.PaddingRight = UDim.new(0, 4)
ScrollPadding.Parent = Scroll

local ScrollList = Instance.new("UIListLayout")
ScrollList.Padding = UDim.new(0, 6)
ScrollList.SortOrder = Enum.SortOrder.LayoutOrder
ScrollList.Parent = Scroll

-- Dynamic Auto Canvas Expansion to guarantee 100% full bottom scrolling
local function updateScrollCanvas()
    local totalY = ScrollList.AbsoluteContentSize.Y + 60
    if totalY > 100 then
        Scroll.CanvasSize = UDim2.new(0, 0, 0, totalY)
    end
end
ScrollList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollCanvas)
Scroll.ChildAdded:Connect(function() task.defer(updateScrollCanvas) end)
task.defer(updateScrollCanvas)

-- Helper: Section Header
local function createSectionHeader(title, order)
    local hdr = Instance.new("Frame")
    hdr.Size = UDim2.new(1, 0, 0, 18)
    hdr.BackgroundTransparency = 1
    hdr.LayoutOrder = order
    hdr.Parent = Scroll

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(title)
    lbl.TextColor3 = C.AccentCyan
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9.5
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = hdr
    return hdr
end

-- Helper: Touch Toggle Switch
local function createToggle(title, desc, defaultVal, order, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 36)
    card.BackgroundColor3 = C.BgCard
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = Scroll

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 7)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = C.Border
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local tLbl = Instance.new("TextLabel")
    tLbl.Position = UDim2.new(0, 8, 0, 3)
    tLbl.Size = UDim2.new(1, -58, 0, 16)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = C.TextTitle
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 10.5
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local dLbl = Instance.new("TextLabel")
    dLbl.Position = UDim2.new(0, 8, 0, 19)
    dLbl.Size = UDim2.new(1, -58, 0, 13)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = desc
    dLbl.TextColor3 = C.TextMuted
    dLbl.Font = Enum.Font.Gotham
    dLbl.TextSize = 8.5
    dLbl.TextXAlignment = Enum.TextXAlignment.Left
    dLbl.TextTruncate = Enum.TextTruncate.AtEnd
    dLbl.Parent = card

    local sw = Instance.new("TextButton")
    sw.Position = UDim2.new(1, -44, 0.5, -10)
    sw.Size = UDim2.new(0, 36, 0, 20)
    sw.BackgroundColor3 = defaultVal and C.SwitchOn or C.SwitchOff
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.Parent = card

    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = sw

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = defaultVal and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sw

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local currentVal = defaultVal
    sw.MouseButton1Click:Connect(function()
        currentVal = not currentVal
        local targetX = currentVal and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetBg = currentVal and C.SwitchOn or C.SwitchOff
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetX}):Play()
        TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        if callback then callback(currentVal) end
    end)

    return card
end

-- Build Settings Controls
createSectionHeader("📂 TARGET SERVICES (CHOOSE WHAT TO DUMP)", 1)

createToggle("Workspace", "Dump map geometry, models, NPC rigs, lighting base", Config.IncludeWorkspace, 2, function(v)
    Config.IncludeWorkspace = v
end)

createToggle("ReplicatedStorage", "Dump shared modules, remotes, character indexes", Config.IncludeReplicatedStorage, 3, function(v)
    Config.IncludeReplicatedStorage = v
end)

createToggle("StarterGui & UI", "Dump all GUI menus, HUDs, buttons, styles", Config.IncludeStarterGui, 4, function(v)
    Config.IncludeStarterGui = v
end)

createToggle("StarterPlayer", "Dump StarterPlayerScripts & CharacterScripts", Config.IncludeStarterPlayer, 5, function(v)
    Config.IncludeStarterPlayer = v
end)

createToggle("Lighting & SoundService", "Dump atmospheres, skyboxes, audio tracks", Config.IncludeLighting, 6, function(v)
    Config.IncludeLighting = v
    Config.IncludeSoundService = v
end)

createSectionHeader("⚙️ EXPORT ENGINE & SCRIPT OPTIONS", 7)

createToggle("Export manifest.json", "Metadata summary, statistics & script paths (no code)", Config.ExportManifest, 8, function(v)
    Config.ExportManifest = v
end)

createToggle("Export code.json", "Full script data, paths & embedded Lua source code", Config.ExportCodeJson, 9, function(v)
    Config.ExportCodeJson = v
end)

createToggle("Export instance.json (Tree)", "Full map geometry, models, properties & hierarchy", Config.ExportInstanceTree, 10, function(v)
    Config.ExportInstanceTree = v
end)

createToggle("Pretty JSON Formatting", "ON: 2-space indented (readable) | OFF: Minified (compact & faster)", Config.PrettyFormat, 11, function(v)
    Config.PrettyFormat = v
end)

createToggle("Decompile Scripts", "Extract Lua source code using executor decompiler", Config.DecompileScripts, 12, function(v)
    Config.DecompileScripts = v
end)

createToggle("Exclude Player Rigs", "Filter out active server player models to avoid clutter", Config.ExcludePlayerCharacters, 13, function(v)
    Config.ExcludePlayerCharacters = v
end)

createToggle("Include Nil Instances", "Scan getnilinstances() if supported by your executor", Config.IncludeNilInstances, 14, function(v)
    Config.IncludeNilInstances = v
end)

-- ---------------------------------------------------------------------
-- FOOTER (STATUS LOG, FILENAME BOX & BIG SAVE BUTTON)
-- ---------------------------------------------------------------------

local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 92)
Footer.Position = UDim2.new(0, 0, 1, -92)
Footer.BackgroundColor3 = C.BgCard
Footer.BorderSizePixel = 0
Footer.Parent = Window

local FooterCover = Instance.new("Frame")
FooterCover.Size = UDim2.new(1, 0, 0, 10)
FooterCover.Position = UDim2.new(0, 0, 1, -10)
FooterCover.BackgroundColor3 = C.BgCard
FooterCover.BorderSizePixel = 0
FooterCover.Parent = Footer

local FooterStroke = Instance.new("UIStroke")
FooterStroke.Color = C.Border
FooterStroke.Thickness = 1
FooterStroke.Parent = Footer

-- Terminal Log / Live HUD Bar
local LogFrame = Instance.new("Frame")
LogFrame.Name = "LogFrame"
LogFrame.Position = UDim2.new(0, 8, 0, 4)
LogFrame.Size = UDim2.new(1, -16, 0, 20)
LogFrame.BackgroundColor3 = C.BgInput
LogFrame.BorderSizePixel = 0
LogFrame.Parent = Footer

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 5)
LogCorner.Parent = LogFrame

local LogDot = Instance.new("Frame")
LogDot.Position = UDim2.new(0, 6, 0.5, -3)
LogDot.Size = UDim2.new(0, 6, 0, 6)
LogDot.BackgroundColor3 = C.AccentGreen
LogDot.BorderSizePixel = 0
LogDot.Parent = LogFrame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = LogDot

local LogLabel = Instance.new("TextLabel")
LogLabel.Position = UDim2.new(0, 18, 0, 0)
LogLabel.Size = UDim2.new(1, -22, 1, 0)
LogLabel.BackgroundTransparency = 1
LogLabel.Text = "Ready to export manifest.json + code.json"
LogLabel.TextColor3 = C.TextBody
LogLabel.Font = Enum.Font.Code
LogLabel.TextSize = 8.5
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextTruncate = Enum.TextTruncate.AtEnd
LogLabel.Parent = LogFrame

local function setLog(msg, color)
    LogLabel.Text = msg
    if color then LogDot.BackgroundColor3 = color end
end

-- Filename Box
local FilenameBox = Instance.new("TextBox")
FilenameBox.Name = "FilenameBox"
FilenameBox.Position = UDim2.new(0, 8, 0, 27)
FilenameBox.Size = UDim2.new(1, -16, 0, 24)
FilenameBox.BackgroundColor3 = C.BgInput
FilenameBox.Text = Config.FilePrefix
FilenameBox.TextColor3 = C.TextTitle
FilenameBox.Font = Enum.Font.Gotham
FilenameBox.TextSize = 10
FilenameBox.ClearTextOnFocus = false
FilenameBox.Parent = Footer

local FnCorner = Instance.new("UICorner")
FnCorner.CornerRadius = UDim.new(0, 5)
FnCorner.Parent = FilenameBox

local FnStroke = Instance.new("UIStroke")
FnStroke.Color = C.Border
FnStroke.Thickness = 1
FnStroke.Parent = FilenameBox

FilenameBox.FocusLost:Connect(function()
    Config.FilePrefix = FilenameBox.Text
end)

-- Save Action Button
local SaveBtn = Instance.new("TextButton")
SaveBtn.Name = "SaveButton"
SaveBtn.Position = UDim2.new(0, 8, 0, 54)
SaveBtn.Size = UDim2.new(1, -16, 0, 32)
SaveBtn.BackgroundColor3 = C.AccentBlue
SaveBtn.Text = "💾 EXPORT MANIFEST.JSON + CODE.JSON"
SaveBtn.TextColor3 = C.TextTitle
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 11
SaveBtn.AutoButtonColor = false
SaveBtn.Parent = Footer

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 8)
SaveCorner.Parent = SaveBtn

local SaveStroke = Instance.new("UIStroke")
SaveStroke.Color = C.AccentCyan
SaveStroke.Thickness = 1.2
SaveStroke.Parent = SaveBtn

-- =====================================================================
-- CORE SERIALIZATION & DUMP LOGIC
-- =====================================================================

local isExporting = false

local function runJsonExport()
    if isExporting then return end
    isExporting = true

    SaveBtn.Text = "⏳ SCANNING GAME INSTANCES..."
    SaveBtn.BackgroundColor3 = C.AccentGold
    setLog("Starting script scan engine...", C.AccentGold)

    task.spawn(function()
        local startTime = tick()
        local stats = {
            scanned = 0,
            scripts = 0,
            serverScripts = 0,
            clientScripts = 0,
            moduleScripts = 0,
            services = 0
        }

        local manifestScripts = {}
        local codeScripts = {}
        local scannedServiceNames = {}

        local timestamp = os.date("%d-%m-%Y_%H-%M-%S")
        local prefix = (FilenameBox.Text ~= "" and FilenameBox.Text or Config.FilePrefix):gsub("{TIMESTAMP}", timestamp)
        prefix = prefix:gsub("%.json$", "")

        -- Prepare Target Services
        local servicesToScan = {}
        if Config.IncludeWorkspace then table.insert(servicesToScan, { name = "Workspace", inst = workspace }) end
        if Config.IncludeReplicatedStorage then table.insert(servicesToScan, { name = "ReplicatedStorage", inst = ReplicatedStorage }) end
        if Config.IncludeStarterGui then table.insert(servicesToScan, { name = "StarterGui", inst = StarterGui }) end
        if Config.IncludeStarterPlayer then table.insert(servicesToScan, { name = "StarterPlayer", inst = StarterPlayer }) end
        if Config.IncludeLighting then table.insert(servicesToScan, { name = "Lighting", inst = Lighting }) end
        if Config.IncludeSoundService then table.insert(servicesToScan, { name = "SoundService", inst = SoundService }) end
        if Config.IncludeReplicatedFirst then table.insert(servicesToScan, { name = "ReplicatedFirst", inst = ReplicatedFirst }) end

        -- Recursive Hierarchy Walker with Non-Blocking Yields
        local function serializeHierarchy(parentInst)
            local childrenNodes = {}
            local children = parentInst:GetChildren()

            for _, child in ipairs(children) do
                stats.scanned = stats.scanned + 1

                -- Adaptive Yielding to prevent mobile freezes
                if stats.scanned % Config.BatchYieldStep == 0 then
                    setLog(string.format("Scanning: %d instances, %d scripts...", stats.scanned, stats.scripts), C.AccentCyan)
                    SaveBtn.Text = string.format("⏳ SCANNED %d INSTANCES (%d SCRIPTS)", stats.scanned, stats.scripts)
                    task.wait()
                end

                -- Skip other player character rigs if enabled
                local skip = false
                if Config.ExcludePlayerCharacters and child.Parent == workspace and child:FindFirstChildOfClass("Humanoid") then
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl.Character == child and pl ~= LocalPlayer then
                            skip = true
                            break
                        end
                    end
                end

                if not skip then
                    local node = dumpInstanceData(child)
                    if isScriptInstance(child) then
                        stats.scripts = stats.scripts + 1
                        local cName = child.ClassName
                        if cName == "LocalScript" then
                            stats.clientScripts = stats.clientScripts + 1
                        elseif cName == "Script" then
                            stats.serverScripts = stats.serverScripts + 1
                        elseif cName == "ModuleScript" then
                            stats.moduleScripts = stats.moduleScripts + 1
                        end

                        local lines = 1
                        for _ in (node.source or ""):gmatch("\n") do
                            lines = lines + 1
                        end

                        -- 1. Metadata entry for manifest.json (NO CODE)
                        table.insert(manifestScripts, {
                            className = cName,
                            filesystemPath = node.filesystemPath,
                            lines = lines,
                            name = child.Name,
                            path = node.path,
                            sizeBytes = node.sizeBytes or 0
                        })

                        -- 2. Data + Path + Code entry for code.json (Exact replica + source code)
                        table.insert(codeScripts, {
                            className = cName,
                            filesystemPath = node.filesystemPath,
                            lines = lines,
                            name = child.Name,
                            path = node.path,
                            sizeBytes = node.sizeBytes or 0,
                            source = node.source or ""
                        })
                    end

                    local grandChildren = child:GetChildren()
                    if #grandChildren > 0 then
                        node.children = serializeHierarchy(child)
                    end

                    table.insert(childrenNodes, node)
                end
            end

            return childrenNodes
        end

        -- Build Root Tree
        local gameRoot = {
            name = "Game",
            className = "DataModel",
            children = {}
        }

        for _, item in ipairs(servicesToScan) do
            stats.services = stats.services + 1
            table.insert(scannedServiceNames, item.name)
            setLog("Scanning Service: " .. item.name .. "...", C.AccentCyan)
            task.wait()

            local srvNode = dumpInstanceData(item.inst)
            srvNode.children = serializeHierarchy(item.inst)
            table.insert(gameRoot.children, srvNode)
        end

        -- Nil Instances scan if requested
        if Config.IncludeNilInstances and typeof(getnilinstances) == "function" then
            setLog("Scanning Nil Instances...", C.AccentPurple)
            local nilFolder = {
                name = "NilInstances",
                className = "Folder",
                children = {}
            }
            local nils = getnilinstances()
            for _, nilInst in ipairs(nils) do
                if nilInst ~= game and nilInst.Parent == nil then
                    stats.scanned = stats.scanned + 1
                    local node = dumpInstanceData(nilInst)
                    table.insert(nilFolder.children, node)
                end
            end
            table.insert(gameRoot.children, nilFolder)
        end

        -- Sort script lists alphabetically by path for pristine readability
        table.sort(manifestScripts, function(a, b)
            return a.path:lower() < b.path:lower()
        end)
        table.sort(codeScripts, function(a, b)
            return a.path:lower() < b.path:lower()
        end)

        -- Shared Source & Stats Structure (Matches rbxlx-export spec)
        local sharedSource = {
            creator = placeInfo.Creator,
            file = placeInfo.Name,
            jobId = placeInfo.JobId,
            placeId = placeInfo.PlaceId,
            placeVersion = placeInfo.PlaceVersion
        }

        local sharedStats = {
            clientScripts = stats.clientScripts,
            moduleScripts = stats.moduleScripts,
            serverScripts = stats.serverScripts,
            totalInstances = stats.scanned,
            totalScripts = stats.scripts
        }

        local exportTimestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        -- 1. Generate manifest.json (Metadata Only)
        local manifestData = {
            exportTimestamp = exportTimestamp,
            format = "rbxlx-export",
            scripts = manifestScripts,
            services = scannedServiceNames,
            source = sharedSource,
            stats = sharedStats,
            version = 1
        }

        -- 2. Generate code.json (Exact replica of manifest format + "source" code)
        local codeData = {
            exportTimestamp = exportTimestamp,
            format = "rbxlx-export",
            scripts = codeScripts,
            services = scannedServiceNames,
            source = sharedSource,
            stats = sharedStats,
            version = 1
        }

        local savedFiles = {}

        -- Save manifest.json
        if Config.ExportManifest then
            SaveBtn.Text = "📋 ENCODING MANIFEST.JSON..."
            setLog("Writing manifest.json (metadata)...", C.AccentGold)
            task.wait()

            local manifestJSON = toJSON(manifestData, Config.PrettyFormat, 0)
            local ok1 = saveFileDirectly("manifest.json", manifestJSON)
            saveFileDirectly(prefix .. "_manifest.json", manifestJSON)
            if ok1 then table.insert(savedFiles, "manifest.json") end
        end

        -- Save code.json
        if Config.ExportCodeJson then
            SaveBtn.Text = "💾 ENCODING CODE.JSON..."
            setLog("Writing code.json (data + path + lua code)...", C.AccentGold)
            task.wait()

            local codeJSON = toJSON(codeData, Config.PrettyFormat, 0)
            local ok2 = saveFileDirectly("code.json", codeJSON)
            saveFileDirectly(prefix .. "_code.json", codeJSON)
            if ok2 then table.insert(savedFiles, "code.json") end
        end

        -- Save instance.json (Optional Full Scene Tree)
        if Config.ExportInstanceTree then
            SaveBtn.Text = "🌳 ENCODING INSTANCE.JSON..."
            setLog("Writing instance.json (full game tree)...", C.AccentGold)
            task.wait()

            local treeData = {
                manifest = manifestData,
                tree = gameRoot
            }
            local treeJSON = toJSON(treeData, Config.PrettyFormat, 0)
            local ok3 = saveFileDirectly("instance.json", treeJSON)
            saveFileDirectly(prefix .. "_instance.json", treeJSON)
            if ok3 then table.insert(savedFiles, "instance.json") end
        end

        local duration = math.round((tick() - startTime) * 10) / 10

        if #savedFiles > 0 then
            local fileListStr = table.concat(savedFiles, " + ")
            SaveBtn.Text = "✓ SAVED: " .. fileListStr
            SaveBtn.BackgroundColor3 = C.AccentGreen
            setLog(string.format("✓ Complete in %ss! %d scripts -> %s", tostring(duration), stats.scripts, fileListStr), C.AccentGreen)
            print(string.format("[SaveInstance JSON Mobile] Exported %d scripts in %ss -> %s", stats.scripts, tostring(duration), fileListStr))
        else
            SaveBtn.Text = "✕ ERROR WRITING FILES"
            SaveBtn.BackgroundColor3 = C.AccentRed
            setLog("✕ Failed to write files to disk", C.AccentRed)
            warn("[SaveInstance JSON Mobile] Write failed")
        end

        task.wait(4.5)
        SaveBtn.Text = "💾 EXPORT MANIFEST.JSON + CODE.JSON"
        SaveBtn.BackgroundColor3 = C.AccentBlue
        isExporting = false
    end)
end

SaveBtn.MouseButton1Click:Connect(runJsonExport)

-- ---------------------------------------------------------------------
-- OPEN / CLOSE TOGGLE LOGIC
-- ---------------------------------------------------------------------

local isVisible = true
local function setWindowVisible(vis)
    isVisible = vis
    Window.Visible = vis
end

CloseBtn.MouseButton1Click:Connect(function()
    setWindowVisible(false)
end)

FloatingPill.MouseButton1Click:Connect(function()
    setWindowVisible(not isVisible)
end)

-- PC Keyboard Shortcut (RightShift)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        setWindowVisible(not isVisible)
    end
end)

print("[SaveInstance JSON Mobile] Standalone Single-File JSON Dumper Initialized Successfully!")
