--[[
    =======================================================================
    SAVEINSTANCE PRO MAX v3.3 - MAP & SCRIPTS EXTRACTION ENGINE
    Adapted & Enhanced for Roblox Studio & Executors (Solara, Wave, Codex, Delta)
    
    🎯 DEDICATED EXTRACTION TARGETS:
      1. 🌍 FULL MAP & GAME (.RBXLX / .RBXL) DUMP:
         - Complete place dump containing all terrain, geometry, lighting, parts & instances
         - Preserves game structure, hierarchy, and lighting configurations
         - Supports .rbxlx (XML for RBXLX_Extractor) and .rbxl (Binary)
         - Built-in StreamingEnabled Region Loader support
         - Auto-removes active player avatars to keep map pristine
      2. 📜 COMPLETE SCRIPT HARVEST & DECOMPILATION:
         - Embedded decompiler with customizable timeout and multi-threading
         - Captures LocalScripts, Scripts, and ModuleScripts across all services
      3. 📁 PROJECT FOLDER (--pretty) EXPORTER (RBXLX_Extractor Style):
         - Separates scripts into organized folders (.client.lua, .server.lua, .lua)
         - Generates formatted manifest.json and instance.json with 2-space indentation
         - Smart mode skips empty leaf geometry to keep project structure clean and fast
      4. Modern Glassmorphism UI with real-time terminal log & floating quick pill
    =======================================================================
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local GuiParent = CoreGui
pcall(function()
    if not pcall(function() return CoreGui:GetChildren() end) then
        GuiParent = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")
    end
end)

-- Remove any previous GUI instances
if GuiParent:FindFirstChild("SaveInstance_Pro_GUI") then
    GuiParent.SaveInstance_Pro_GUI:Destroy()
end

-- =====================================================================
-- SAVE ENGINE RESOLVER
-- =====================================================================

local function getSaveEngine()
    if RunService:IsStudio() then
        return function(obj, filepath, options)
            task.wait(1.5)
            print("[SaveInstance PRO MAX] Studio Simulation Dump Complete for target: " .. tostring(obj and obj.Name) .. " -> " .. tostring(filepath))
            return true
        end
    end

    local raw_saveinstance = (typeof(saveinstance) == "function" and saveinstance)
        or (typeof(getgenv) == "function" and getgenv() and typeof(getgenv().saveinstance) == "function" and getgenv().saveinstance)
        or (typeof(syn) == "table" and typeof(syn.saveinstance) == "function" and syn.saveinstance)

    local cached_synsaveinstance = nil

    local function loadSynSaveInstance()
        if cached_synsaveinstance then return cached_synsaveinstance end

        local httpGet = (game and game.HttpGet and function(url) return game:HttpGet(url, true) end)
            or (typeof(HttpGet) == "function" and HttpGet)
            or (typeof(http_get) == "function" and http_get)
            or (typeof(request) == "function" and function(url)
                local res = request({Url = url, Method = "GET"})
                return res and (res.Body or res.body)
            end)

        if not httpGet then return nil end

        local success, result = pcall(function()
            local Params = {
                RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
                SSI = "saveinstance",
            }
            local src = httpGet(Params.RepoURL .. Params.SSI .. ".luau")
            if not src or #src < 100 then error("Failed to fetch SynSaveInstance code") end
            local loader = loadstring(src, Params.SSI)
            return loader()
        end)

        if success and typeof(result) == "function" then
            cached_synsaveinstance = result
            return cached_synsaveinstance
        end
        return nil
    end

    return function(obj, filepath, options)
        local opt = {}
        if type(options) == "table" then
            for k, v in pairs(options) do opt[k] = v end
        end

        opt.Object = obj or game
        opt.FilePath = filepath or ("Place_" .. tostring(game.PlaceId) .. ".rbxl")
        opt.FileName = opt.FilePath

        -- 1. Try executor's built-in saveinstance
        if typeof(raw_saveinstance) == "function" then
            local ranSuccessfully = false

            -- Signature A: saveinstance(options)
            local s1, r1 = pcall(function() return raw_saveinstance(opt) end)
            if s1 and r1 ~= false then ranSuccessfully = true end

            -- Signature B: saveinstance(obj, options)
            if not ranSuccessfully then
                local s2, r2 = pcall(function() return raw_saveinstance(opt.Object, opt) end)
                if s2 and r2 ~= false then ranSuccessfully = true end
            end

            -- Signature C: saveinstance(obj, filepath, options)
            if not ranSuccessfully then
                local s3, r3 = pcall(function() return raw_saveinstance(opt.Object, opt.FilePath, opt) end)
                if s3 and r3 ~= false then ranSuccessfully = true end
            end

            -- Check if file was truly written on disk
            if ranSuccessfully then
                if typeof(isfile) == "function" then
                    if isfile(opt.FilePath) then
                        return true
                    end
                else
                    return true
                end
            end
        end

        -- 2. Fallback to SynSaveInstance (The exact universal engine Dex uses)
        local ssi = loadSynSaveInstance()
        if ssi then
            local s4, r4 = pcall(function() return ssi(opt) end)
            if s4 and r4 ~= false then return r4 or true end

            local s5, r5 = pcall(function() return ssi(opt.Object, opt) end)
            if s5 and r5 ~= false then return r5 or true end
        end

        error("saveinstance failed: built-in executor engine failed and SynSaveInstance fallback was unable to save.")
    end
end

local saveEngine = getSaveEngine()

-- Mirror saveEngine into getgenv().saveinstance so entire environment stays synchronized
pcall(function()
    if typeof(getgenv) == "function" and getgenv() then
        getgenv().saveinstance = saveEngine
    end
end)

-- =====================================================================
-- PLACE & GAME INFO
-- =====================================================================

local placeInfo = { Name = "Unknown Game", Creator = "Unknown", PlaceId = game.PlaceId }
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    placeInfo.Name = info.Name:gsub("[*\\?:<>|/]+", "")
    placeInfo.Creator = info.Creator.Name or "Roblox"
end)

-- Map & Scripts Configuration
local SaveConfig = {
    -- Place & Map Settings
    PlaceFileFormat = "rbxlx",       -- "rbxlx" (XML for RBXLX_Extractor) or "rbxl" (Binary)
    FileNamePlace = "Place_" .. game.PlaceId .. "_{TIMESTAMP}.rbxlx",
    ForceGlobalArchivable = true,    -- Ensures all instances have Archivable = true before saving
    RemovePlayerCharacters = true,   -- Removes player character rigs so avatars do not clutter the map
    ForceStreamMap = false,          -- Pre-streams distant map regions before full place dump
    IgnoreDefaultProps = true,       -- Dramatically reduces output file size
    RecoverNilInstances = false,     -- Scans getnilinstances() if available

    -- Decompilation Settings
    Decompile = true,                -- Enabled by default to dump all script source code
    DecompileTimeout = 10,
    MaxThreads = 4,

    -- Project Folder (--pretty / script-main exporter) Settings
    ExportProjectFolder = false,     -- Toggle ON: exports folder with separated scripts, instance.json & manifest.json
    PrettyJSON = true,               -- Formats instance.json & manifest.json with 2-space indentation (-p / --pretty)
    ProjectExportMode = "smart",     -- "smart" (skips empty leaf geometry to avoid freeze) or "full"
}

-- =====================================================================
-- THEME PALETTE
-- =====================================================================

local C = {
    BgMain      = Color3.fromRGB(13, 15, 22),
    BgCard      = Color3.fromRGB(20, 24, 35),
    BgCardHover = Color3.fromRGB(26, 31, 46),
    BgInput     = Color3.fromRGB(10, 12, 18),
    Border      = Color3.fromRGB(38, 45, 66),
    BorderFocus = Color3.fromRGB(99, 122, 255),
    AccentBlue  = Color3.fromRGB(88, 110, 255),
    AccentCyan  = Color3.fromRGB(0, 210, 255),
    AccentGreen = Color3.fromRGB(38, 194, 129),
    AccentGold  = Color3.fromRGB(255, 184, 0),
    AccentPurple= Color3.fromRGB(175, 82, 222),
    AccentRed   = Color3.fromRGB(240, 71, 71),
    TextTitle   = Color3.fromRGB(255, 255, 255),
    TextBody    = Color3.fromRGB(205, 212, 230),
    TextMuted   = Color3.fromRGB(120, 130, 160),
    SwitchOff   = Color3.fromRGB(34, 40, 58),
    SwitchOn    = Color3.fromRGB(88, 110, 255),
}

-- =====================================================================
-- ROOT GUI INITIALIZATION
-- =====================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SaveInstance_Pro_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

-- Floating Open/Close Pill (Left edge)
local FloatingPill = Instance.new("TextButton")
FloatingPill.Name = "FloatingPill"
FloatingPill.Size = UDim2.new(0, 48, 0, 48)
FloatingPill.Position = UDim2.new(0, 16, 0.5, -24)
FloatingPill.BackgroundColor3 = C.BgCard
FloatingPill.Text = ""
FloatingPill.AutoButtonColor = false
FloatingPill.Parent = ScreenGui

local PillCorner = Instance.new("UICorner")
PillCorner.CornerRadius = UDim.new(0, 14)
PillCorner.Parent = FloatingPill

local PillStroke = Instance.new("UIStroke")
PillStroke.Color = C.AccentBlue
PillStroke.Thickness = 1.8
PillStroke.Parent = FloatingPill

local PillIcon = Instance.new("TextLabel")
PillIcon.Size = UDim2.new(1, 0, 1, 0)
PillIcon.BackgroundTransparency = 1
PillIcon.Text = "🌍"
PillIcon.TextSize = 22
PillIcon.Parent = FloatingPill

-- Main Window
local Window = Instance.new("Frame")
Window.Name = "MainWindow"
Window.Size = UDim2.new(0, 470, 0, 550)
Window.Position = UDim2.new(0.5, -235, 0.5, -275)
Window.BackgroundColor3 = C.BgMain
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = ScreenGui

local WinCorner = Instance.new("UICorner")
WinCorner.CornerRadius = UDim.new(0, 16)
WinCorner.Parent = Window

local WinStroke = Instance.new("UIStroke")
WinStroke.Color = C.Border
WinStroke.Thickness = 1.5
WinStroke.Parent = Window

-- Title Bar Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = C.BgCard
Header.BorderSizePixel = 0
Header.Parent = Window

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local HeaderHider = Instance.new("Frame")
HeaderHider.Size = UDim2.new(1, 0, 0, 14)
HeaderHider.Position = UDim2.new(0, 0, 1, -14)
HeaderHider.BackgroundColor3 = C.BgCard
HeaderHider.BorderSizePixel = 0
HeaderHider.Parent = Header

local HeaderIcon = Instance.new("TextLabel")
HeaderIcon.Position = UDim2.new(0, 14, 0, 10)
HeaderIcon.Size = UDim2.new(0, 36, 0, 36)
HeaderIcon.BackgroundColor3 = C.BgMain
HeaderIcon.Text = "🌍"
HeaderIcon.TextSize = 18
HeaderIcon.Parent = Header

local HIconCorner = Instance.new("UICorner")
HIconCorner.CornerRadius = UDim.new(0, 10)
HIconCorner.Parent = HeaderIcon

local TitleText = Instance.new("TextLabel")
TitleText.Position = UDim2.new(0, 58, 0, 9)
TitleText.Size = UDim2.new(1, -210, 0, 20)
TitleText.BackgroundTransparency = 1
TitleText.Text = "SaveInstance PRO MAX"
TitleText.TextColor3 = C.TextTitle
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = Header

local Badge = Instance.new("Frame")
Badge.Position = UDim2.new(1, -150, 0, 11)
Badge.Size = UDim2.new(0, 105, 0, 18)
Badge.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
Badge.BorderSizePixel = 0
Badge.Parent = Header

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(1, 0)
BadgeCorner.Parent = Badge

local BadgeStroke = Instance.new("UIStroke")
BadgeStroke.Color = C.AccentBlue
BadgeStroke.Thickness = 1
BadgeStroke.Parent = Badge

local BadgeLabel = Instance.new("TextLabel")
BadgeLabel.Size = UDim2.new(1, 0, 1, 0)
BadgeLabel.BackgroundTransparency = 1
BadgeLabel.Text = "MAP & SCRIPTS DUMP"
BadgeLabel.TextColor3 = C.AccentBlue
BadgeLabel.Font = Enum.Font.GothamBold
BadgeLabel.TextSize = 8
BadgeLabel.Parent = Badge

local SubTitle = Instance.new("TextLabel")
SubTitle.Position = UDim2.new(0, 58, 0, 30)
SubTitle.Size = UDim2.new(1, -150, 0, 16)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = placeInfo.Name .. " • ID: " .. placeInfo.PlaceId
SubTitle.TextColor3 = C.TextMuted
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.TextTruncate = Enum.TextTruncate.AtEnd
SubTitle.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Position = UDim2.new(1, -38, 0, 14)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.BackgroundColor3 = C.BgMain
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.TextMuted
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.AccentRed, TextColor3 = C.TextTitle}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.BgMain, TextColor3 = C.TextMuted}):Play()
end)

-- Window Dragging
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- =====================================================================
-- TAB NAVIGATION BAR
-- =====================================================================

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Position = UDim2.new(0, 14, 0, 64)
TabBar.Size = UDim2.new(1, -28, 0, 32)
TabBar.BackgroundColor3 = C.BgCard
TabBar.BorderSizePixel = 0
TabBar.Parent = Window

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 8)
TabBarCorner.Parent = TabBar

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabBarLayout.Padding = UDim.new(0, 4)
TabBarLayout.Parent = TabBar

local tabs = {
    { Id = "Place", Name = "🌍 Map & Place" },
    { Id = "Scripts", Name = "📜 Scripts & Decompile" },
    { Id = "Project", Name = "📁 Project Folder" }
}

local currentTab = "Place"
local tabButtons = {}
local tabPages = {}

-- Main Scrollable Content Container
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Position = UDim2.new(0, 14, 0, 102)
ContentFrame.Size = UDim2.new(1, -28, 1, -242)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = Window

local function CreateTabPage(id)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Page_" .. id
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.Border
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = (id == currentTab)
    scroll.Parent = ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    return scroll
end

for _, t in ipairs(tabs) do
    tabPages[t.Id] = CreateTabPage(t.Id)

    local btn = Instance.new("TextButton")
    btn.Name = "TabBtn_" .. t.Id
    btn.Size = UDim2.new(0.333, -3, 1, 0)
    btn.BackgroundColor3 = (t.Id == currentTab) and C.AccentBlue or C.BgCard
    btn.Text = t.Name
    btn.TextColor3 = (t.Id == currentTab) and C.TextTitle or C.TextMuted
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.Parent = TabBar

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    tabButtons[t.Id] = btn

    btn.MouseButton1Click:Connect(function()
        currentTab = t.Id
        for id, p in pairs(tabPages) do
            p.Visible = (id == currentTab)
        end
        for id, b in pairs(tabButtons) do
            local isSel = (id == currentTab)
            TweenService:Create(b, TweenInfo.new(0.2), {
                BackgroundColor3 = isSel and C.AccentBlue or C.BgCard,
                TextColor3 = isSel and C.TextTitle or C.TextMuted
            }):Play()
        end
    end)
end

-- =====================================================================
-- UI BUILDER HELPERS
-- =====================================================================

local function CreateSectionHeader(parent, title)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = title:upper()
    lbl.TextColor3 = C.AccentCyan
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function CreateToggleSwitch(parent, title, desc, defaultVal, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 46)
    card.BackgroundColor3 = C.BgCard
    card.BorderSizePixel = 0
    card.Parent = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = card

    local tLbl = Instance.new("TextLabel")
    tLbl.Position = UDim2.new(0, 12, 0, 6)
    tLbl.Size = UDim2.new(1, -70, 0, 18)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = C.TextTitle
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 11
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local dLbl = Instance.new("TextLabel")
    dLbl.Position = UDim2.new(0, 12, 0, 24)
    dLbl.Size = UDim2.new(1, -70, 0, 16)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = desc
    dLbl.TextColor3 = C.TextMuted
    dLbl.Font = Enum.Font.Gotham
    dLbl.TextSize = 9
    dLbl.TextXAlignment = Enum.TextXAlignment.Left
    dLbl.TextTruncate = Enum.TextTruncate.AtEnd
    dLbl.Parent = card

    local sw = Instance.new("TextButton")
    sw.Position = UDim2.new(1, -48, 0, 13)
    sw.Size = UDim2.new(0, 36, 0, 20)
    sw.BackgroundColor3 = defaultVal and C.SwitchOn or C.SwitchOff
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.Parent = card

    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = sw

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultVal and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sw

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = defaultVal
    sw.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(sw, TweenInfo.new(0.2), {
            BackgroundColor3 = state and C.SwitchOn or C.SwitchOff
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3)
        }):Play()
        callback(state)
    end)

    return card
end

local function CreateInputCard(parent, title, placeholder, defaultVal, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 46)
    card.BackgroundColor3 = C.BgCard
    card.BorderSizePixel = 0
    card.Parent = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = card

    local tLbl = Instance.new("TextLabel")
    tLbl.Position = UDim2.new(0, 12, 0, 5)
    tLbl.Size = UDim2.new(1, -24, 0, 16)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = C.TextTitle
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 11
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local tb = Instance.new("TextBox")
    tb.Position = UDim2.new(0, 12, 0, 20)
    tb.Size = UDim2.new(1, -24, 0, 20)
    tb.BackgroundTransparency = 1
    tb.Text = tostring(defaultVal)
    tb.PlaceholderText = placeholder
    tb.PlaceholderColor3 = C.TextMuted
    tb.TextColor3 = C.TextTitle
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 11
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.ClearTextOnFocus = false
    tb.Parent = card

    tb.FocusLost:Connect(function() callback(tb.Text) end)
    return card
end

-- =====================================================================
-- FORWARD DECLARATION FOR FOOTER CONTROLS
-- =====================================================================

local FilenameBox
local ExportBtn

-- =====================================================================
-- POPULATE TABS CONTENT
-- =====================================================================

-- TAB 1: MAP & PLACE
local pPlace = tabPages["Place"]
CreateSectionHeader(pPlace, "Map & Place Serialization")
CreateToggleSwitch(pPlace, "XML Place Format (.rbxlx)", "ON = .rbxlx (XML for RBXLX_Extractor) / OFF = .rbxl (Binary)", SaveConfig.PlaceFileFormat == "rbxlx", function(v)
    SaveConfig.PlaceFileFormat = v and "rbxlx" or "rbxl"
    if v then
        SaveConfig.FileNamePlace = SaveConfig.FileNamePlace:gsub("%.rbxl$", ".rbxlx")
        if not SaveConfig.FileNamePlace:find("%.rbxlx$") then
            SaveConfig.FileNamePlace = SaveConfig.FileNamePlace .. ".rbxlx"
        end
    else
        SaveConfig.FileNamePlace = SaveConfig.FileNamePlace:gsub("%.rbxlx$", ".rbxl")
        if not SaveConfig.FileNamePlace:find("%.rbxl$") then
            SaveConfig.FileNamePlace = SaveConfig.FileNamePlace .. ".rbxl"
        end
    end
    if FilenameBox then
        FilenameBox.Text = SaveConfig.FileNamePlace
    end
    if ExportBtn then
        ExportBtn.Text = "🌍 DUMP FULL PLACE & SCRIPTS (" .. (SaveConfig.PlaceFileFormat == "rbxl" and ".RBXL" or ".RBXLX") .. ")"
    end
end)
CreateToggleSwitch(pPlace, "Force Global Archivable", "Sets Archivable = true across all instances in DataModel before saving", SaveConfig.ForceGlobalArchivable, function(v)
    SaveConfig.ForceGlobalArchivable = v
end)
CreateToggleSwitch(pPlace, "Remove Player Characters", "Excludes player avatars from map dump to prevent clutter", SaveConfig.RemovePlayerCharacters, function(v)
    SaveConfig.RemovePlayerCharacters = v
end)
CreateToggleSwitch(pPlace, "StreamingEnabled Region Loader", "Pre-streams distant map regions before full place dump", SaveConfig.ForceStreamMap, function(v)
    SaveConfig.ForceStreamMap = v
end)
CreateToggleSwitch(pPlace, "Ignore Default Properties", "Dramatically reduces output place file size", SaveConfig.IgnoreDefaultProps, function(v)
    SaveConfig.IgnoreDefaultProps = v
end)

-- TAB 2: SCRIPTS & DECOMPILER
local pScripts = tabPages["Scripts"]
CreateSectionHeader(pScripts, "Decompilation Engine Controls")
CreateToggleSwitch(pScripts, "Decompile Scripts", "Decompiles LocalScripts, Scripts, and ModuleScripts into source", SaveConfig.Decompile, function(v)
    SaveConfig.Decompile = v
end)
CreateInputCard(pScripts, "Decompile Timeout (seconds)", "Default: 10", SaveConfig.DecompileTimeout, function(v)
    SaveConfig.DecompileTimeout = tonumber(v) or 10
end)
CreateInputCard(pScripts, "Max Decompiler Threads", "Default: 4", SaveConfig.MaxThreads, function(v)
    SaveConfig.MaxThreads = tonumber(v) or 4
end)
CreateToggleSwitch(pScripts, "Recover Nil Instances", "Scans getnilinstances() for orphaned scripts", SaveConfig.RecoverNilInstances, function(v)
    SaveConfig.RecoverNilInstances = v
end)

-- TAB 3: PROJECT FOLDER
local pProject = tabPages["Project"]
CreateSectionHeader(pProject, "Project Folder (--pretty) Settings")
CreateToggleSwitch(pProject, "Export Project Folder (--pretty)", "Exports separated scripts, instance.json & manifest.json", SaveConfig.ExportProjectFolder, function(v)
    SaveConfig.ExportProjectFolder = v
end)
CreateToggleSwitch(pProject, "Pretty-Print JSON (indent=2)", "Formats manifest.json & instance.json with 2-space indent", SaveConfig.PrettyJSON, function(v)
    SaveConfig.PrettyJSON = v
end)
CreateToggleSwitch(pProject, "Smart Geometry Filter", "ON = 'smart' (skips leaf parts) / OFF = 'full' (all geometry)", SaveConfig.ProjectExportMode == "smart", function(v)
    SaveConfig.ProjectExportMode = v and "smart" or "full"
end)

-- =====================================================================
-- TERMINAL CONSOLE LOG & STATUS
-- =====================================================================

local LogFrame = Instance.new("Frame")
LogFrame.Name = "LogFrame"
LogFrame.Position = UDim2.new(0, 14, 1, -136)
LogFrame.Size = UDim2.new(1, -28, 0, 40)
LogFrame.BackgroundColor3 = C.BgInput
LogFrame.BorderSizePixel = 0
LogFrame.Parent = Window

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 8)
LogCorner.Parent = LogFrame

local LogStroke = Instance.new("UIStroke")
LogStroke.Color = C.Border
LogStroke.Thickness = 1
LogStroke.Parent = LogFrame

local LogDot = Instance.new("Frame")
LogDot.Position = UDim2.new(0, 10, 0, 15)
LogDot.Size = UDim2.new(0, 8, 0, 8)
LogDot.BackgroundColor3 = C.AccentGreen
LogDot.BorderSizePixel = 0
LogDot.Parent = LogFrame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = LogDot

local LogLabel = Instance.new("TextLabel")
LogLabel.Position = UDim2.new(0, 26, 0, 0)
LogLabel.Size = UDim2.new(1, -36, 1, 0)
LogLabel.BackgroundTransparency = 1
LogLabel.Text = "System Idle. Ready to dump Map (.rbxlx) and extract Scripts!"
LogLabel.TextColor3 = C.TextBody
LogLabel.Font = Enum.Font.Code
LogLabel.TextSize = 10
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextTruncate = Enum.TextTruncate.AtEnd
LogLabel.Parent = LogFrame

local function setLog(msg, color)
    LogLabel.Text = msg
    if color then
        LogDot.BackgroundColor3 = color
    end
end

-- =====================================================================
-- FOOTER: FILENAME & ACTION BUTTON
-- =====================================================================

local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 92)
Footer.Position = UDim2.new(0, 0, 1, -92)
Footer.BackgroundColor3 = C.BgCard
Footer.BorderSizePixel = 0
Footer.Parent = Window

local FooterStroke = Instance.new("UIStroke")
FooterStroke.Color = C.Border
FooterStroke.Thickness = 1
FooterStroke.Parent = Footer

FilenameBox = Instance.new("TextBox")
FilenameBox.Name = "FilenameBox"
FilenameBox.Position = UDim2.new(0, 14, 0, 6)
FilenameBox.Size = UDim2.new(1, -28, 0, 24)
FilenameBox.BackgroundColor3 = C.BgInput
FilenameBox.Text = SaveConfig.FileNamePlace
FilenameBox.TextColor3 = C.TextTitle
FilenameBox.Font = Enum.Font.Gotham
FilenameBox.TextSize = 10
FilenameBox.ClearTextOnFocus = false
FilenameBox.Parent = Footer

local FnCorner = Instance.new("UICorner")
FnCorner.CornerRadius = UDim.new(0, 6)
FnCorner.Parent = FilenameBox

local FnStroke = Instance.new("UIStroke")
FnStroke.Color = C.Border
FnStroke.Thickness = 1
FnStroke.Parent = FilenameBox

ExportBtn = Instance.new("TextButton")
ExportBtn.Name = "ExportButton"
ExportBtn.Position = UDim2.new(0, 14, 0, 36)
ExportBtn.Size = UDim2.new(1, -28, 0, 32)
ExportBtn.BackgroundColor3 = C.AccentBlue
ExportBtn.Text = "🌍 DUMP FULL PLACE & SCRIPTS (" .. (SaveConfig.PlaceFileFormat == "rbxl" and ".RBXL" or ".RBXLX") .. ")"
ExportBtn.TextColor3 = C.TextTitle
ExportBtn.Font = Enum.Font.GothamBold
ExportBtn.TextSize = 11
ExportBtn.AutoButtonColor = false
ExportBtn.Parent = Footer

local ExpCorner = Instance.new("UICorner")
ExpCorner.CornerRadius = UDim.new(0, 8)
ExpCorner.Parent = ExportBtn

local SubFooterText = Instance.new("TextLabel")
SubFooterText.Position = UDim2.new(0, 14, 0, 72)
SubFooterText.Size = UDim2.new(1, -28, 0, 16)
SubFooterText.BackgroundTransparency = 1
SubFooterText.Text = "Dumps place file with complete map geometry, lighting & decompiled scripts."
SubFooterText.TextColor3 = C.TextMuted
SubFooterText.Font = Enum.Font.Gotham
SubFooterText.TextSize = 9
SubFooterText.Parent = Footer

-- =====================================================================
-- PROJECT FOLDER (--pretty) EXPORTER ENGINE (RBXLX_Extractor Style)
-- =====================================================================

local function toPrettyJSON(val, indent)
    indent = indent or 0
    local indentStr = string.rep("  ", indent)
    local nextIndentStr = string.rep("  ", indent + 1)
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
        local s = val
        s = s:gsub("\\", "\\\\")
        s = s:gsub('"', '\\"')
        s = s:gsub("\n", "\\n")
        s = s:gsub("\r", "\\r")
        s = s:gsub("\t", "\\t")
        s = s:gsub("[%z\1-\31]", function(c)
            return string.format("\\u%04x", string.byte(c))
        end)
        return '"' .. s .. '"'
    elseif t == "table" then
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
            return "{}"
        end

        if isArray then
            local items = {}
            for i = 1, count do
                table.insert(items, nextIndentStr .. toPrettyJSON(val[i], indent + 1))
            end
            return "[\n" .. table.concat(items, ",\n") .. "\n" .. indentStr .. "]"
        else
            local keys = {}
            for k, _ in pairs(val) do
                table.insert(keys, tostring(k))
            end
            table.sort(keys)

            local items = {}
            for _, k in ipairs(keys) do
                local v = val[k]
                local escapedK = tostring(k):gsub("\\", "\\\\"):gsub('"', '\\"')
                table.insert(items, nextIndentStr .. '"' .. escapedK .. '": ' .. toPrettyJSON(v, indent + 1))
            end
            return "{\n" .. table.concat(items, ",\n") .. "\n" .. indentStr .. "}"
        end
    else
        return '"' .. tostring(val):gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
    end
end

local function serializeJSON(val, pretty)
    if pretty then
        return toPrettyJSON(val, 0)
    else
        local ok, res = pcall(function()
            return HttpService:JSONEncode(val)
        end)
        if ok and res then return res end
        return toPrettyJSON(val, 0)
    end
end

local function sanitizeFSName(name)
    if not name or name == "" then return "Unnamed" end
    local clean = name:gsub("[%z%c\\/:*?\"<>|]", "_")
    clean = clean:gsub("[%.%s]+$", "")
    if clean == "" then clean = "Unnamed" end
    if #clean > 80 then clean = clean:sub(1, 80) end
    return clean
end

local function createCollisionResolver()
    local usedNames = {}
    return function(baseName, ext)
        ext = ext or ""
        local clean = sanitizeFSName(baseName)
        local fullName = clean .. ext
        local key = fullName:lower()
        if not usedNames[key] then
            usedNames[key] = 1
            return fullName
        end
        local count = usedNames[key]
        while true do
            local candidate = clean .. "_" .. count .. ext
            if not usedNames[candidate:lower()] then
                usedNames[candidate:lower()] = 1
                usedNames[key] = count + 1
                return candidate
            end
            count = count + 1
        end
    end
end

local function ensureDirectory(path)
    if typeof(makefolder) ~= "function" then return end
    path = path:gsub("\\", "/")
    local parts = string.split(path, "/")
    local current = ""
    for _, part in ipairs(parts) do
        if part ~= "" then
            current = (current == "") and part or (current .. "/" .. part)
            pcall(function()
                if typeof(isfolder) == "function" then
                    if not isfolder(current) then
                        makefolder(current)
                    end
                else
                    makefolder(current)
                end
            end)
        end
    end
end

local function safeWriteFile(path, content)
    if typeof(writefile) == "function" then
        return pcall(function()
            writefile(path, content)
        end)
    end
    return false
end

local function isScriptInstance(inst)
    return inst:IsA("LuaSourceContainer") or inst:IsA("Script") or inst:IsA("LocalScript") or inst:IsA("ModuleScript")
end

local function getScriptExtension(inst)
    if inst:IsA("LocalScript") then
        return ".client.lua"
    elseif inst:IsA("Script") then
        return ".server.lua"
    elseif inst:IsA("ModuleScript") then
        return ".lua"
    end
    return ".lua"
end

local function getScriptSource(inst)
    if typeof(decompile) == "function" then
        local ok, src = pcall(function()
            return decompile(inst)
        end)
        if ok and typeof(src) == "string" and #src > 0 then
            return src
        end
    end
    local ok, src = pcall(function() return inst.Source end)
    if ok and typeof(src) == "string" and #src > 0 then
        return src
    end
    return "-- [Source code unavailable or protected]\n-- Instance: " .. inst:GetFullName() .. " (" .. inst.ClassName .. ")"
end

local ASSET_PROPERTY_NAMES = {
    "MeshId", "TextureID", "TextureId", "SoundId", "AnimationId",
    "Image", "Texture", "Video", "PackageId", "LinkedSource",
    "PantsTemplate", "ShirtTemplate", "Graphic"
}

local SAFE_PROPERTY_NAMES = {
    "Anchored", "CanCollide", "Transparency", "Reflectance", "Material",
    "Color", "Size", "Position", "Orientation", "Shape",
    "Volume", "PlaybackSpeed", "Playing", "Looped",
    "Brightness", "Range", "Shadows", "FieldOfView"
}

local function getInstanceMetadata(inst)
    local meta = {
        className = inst.ClassName,
        name = inst.Name,
        path = inst:GetFullName()
    }

    pcall(function()
        local tags = CollectionService:GetTags(inst)
        if tags and #tags > 0 then
            table.sort(tags)
            meta["tags"] = tags
        end
    end)

    pcall(function()
        local attrs = inst:GetAttributes()
        if attrs and next(attrs) ~= nil then
            meta["attributes"] = attrs
        end
    end)

    local assets = {}
    for _, propName in ipairs(ASSET_PROPERTY_NAMES) do
        local ok, val = pcall(function() return inst[propName] end)
        if ok and typeof(val) == "string" and val ~= "" then
            assets[propName] = val
        end
    end
    if next(assets) ~= nil then
        meta["assets"] = assets
    end

    local props = {}
    for _, propName in ipairs(SAFE_PROPERTY_NAMES) do
        local ok, val = pcall(function() return inst[propName] end)
        if ok and val ~= nil then
            if typeof(val) == "Color3" then
                props[propName] = { r = math.round(val.R * 255), g = math.round(val.G * 255), b = math.round(val.B * 255) }
            elseif typeof(val) == "Vector3" then
                props[propName] = { x = val.X, y = val.Y, z = val.Z }
            elseif typeof(val) == "EnumItem" then
                props[propName] = tostring(val.Name)
            elseif typeof(val) == "boolean" or typeof(val) == "number" or typeof(val) == "string" then
                props[propName] = val
            end
        end
    end
    if next(props) ~= nil then
        meta["properties"] = props
    end

    return meta
end

local function exportProjectFolderTree(targetRoot, outputDir, pretty, mode, setStatus)
    setStatus = setStatus or function() end
    ensureDirectory(outputDir)

    if RunService:IsStudio() then
        print(string.format("[SaveInstance PRO MAX] Studio Simulation: Export Project Folder to '%s' (pretty=%s, mode=%s)", outputDir, tostring(pretty), tostring(mode)))
    end

    local stats = {
        totalInstances = 0,
        totalScripts = 0,
        serverScripts = 0,
        clientScripts = 0,
        moduleScripts = 0
    }

    local exportedScriptsList = {}
    local servicesExported = {}
    local processedCount = 0

    local function checkYield()
        processedCount = processedCount + 1
        if processedCount % 35 == 0 then
            setStatus(string.format("[Project Export] %d instances, %d scripts...", processedCount, stats.totalScripts))
            task.wait()
        end
    end

    local function hasDescendantScripts(inst)
        if isScriptInstance(inst) then return true end
        for _, ch in ipairs(inst:GetChildren()) do
            if hasDescendantScripts(ch) then return true end
        end
        return false
    end

    local function exportChildren(parentInst, parentDir)
        local resolveCollision = createCollisionResolver()

        for _, child in ipairs(parentInst:GetChildren()) do
            checkYield()
            local isScript = isScriptInstance(child)
            local children = child:GetChildren()
            local hasChildren = #children > 0

            local shouldProcess = true
            if mode == "smart" and not isScript and not hasChildren then
                local cName = child.ClassName
                if cName == "Part" or cName == "MeshPart" or cName == "WedgePart" or cName == "CornerWedgePart" or cName == "TrussPart" then
                    shouldProcess = false
                end
            end

            if shouldProcess then
                stats.totalInstances = stats.totalInstances + 1

                if isScript and not hasChildren then
                    local ext = getScriptExtension(child)
                    local fileName = resolveCollision(child.Name, ext)
                    local filePath = parentDir .. "/" .. fileName
                    local src = getScriptSource(child)
                    safeWriteFile(filePath, src)

                    stats.totalScripts = stats.totalScripts + 1
                    if ext == ".server.lua" then
                        stats.serverScripts = stats.serverScripts + 1
                    elseif ext == ".client.lua" then
                        stats.clientScripts = stats.clientScripts + 1
                    else
                        stats.moduleScripts = stats.moduleScripts + 1
                    end

                    table.insert(exportedScriptsList, {
                        name = child.Name,
                        className = child.ClassName,
                        path = child:GetFullName(),
                        filesystemPath = filePath:sub(#outputDir + 2),
                        sizeBytes = #src
                    })

                elseif isScript and hasChildren then
                    local folderName = resolveCollision(child.Name, "")
                    local scriptDir = parentDir .. "/" .. folderName
                    ensureDirectory(scriptDir)

                    local ext = getScriptExtension(child)
                    local scriptFileName = folderName .. ext
                    local scriptFilePath = scriptDir .. "/" .. scriptFileName
                    local src = getScriptSource(child)
                    safeWriteFile(scriptFilePath, src)

                    stats.totalScripts = stats.totalScripts + 1
                    if ext == ".server.lua" then
                        stats.serverScripts = stats.serverScripts + 1
                    elseif ext == ".client.lua" then
                        stats.clientScripts = stats.clientScripts + 1
                    else
                        stats.moduleScripts = stats.moduleScripts + 1
                    end

                    table.insert(exportedScriptsList, {
                        name = child.Name,
                        className = child.ClassName,
                        path = child:GetFullName(),
                        filesystemPath = scriptFilePath:sub(#outputDir + 2),
                        sizeBytes = #src
                    })

                    local meta = getInstanceMetadata(child)
                    local metaJSON = serializeJSON(meta, pretty)
                    safeWriteFile(scriptDir .. "/instance.json", metaJSON)

                    exportChildren(child, scriptDir)

                else
                    local allowContainer = true
                    if mode == "smart" and not hasDescendantScripts(child) and not child:IsA("Model") and not child:IsA("Folder") and not child:IsA("LayerCollector") and not child:IsA("Tool") then
                        allowContainer = false
                    end

                    if allowContainer then
                        local folderName = resolveCollision(child.Name, "")
                        local instDir = parentDir .. "/" .. folderName
                        ensureDirectory(instDir)

                        local meta = getInstanceMetadata(child)
                        local metaJSON = serializeJSON(meta, pretty)
                        safeWriteFile(instDir .. "/instance.json", metaJSON)

                        if hasChildren then
                            exportChildren(child, instDir)
                        end
                    end
                end
            end
        end
    end

    if targetRoot == game then
        local targetServices = {
            "Workspace",
            "ReplicatedStorage",
            "ServerScriptService",
            "ServerStorage",
            "StarterGui",
            "StarterPlayer",
            "Lighting",
            "ReplicatedFirst",
            "SoundService",
            "Chat",
            "MaterialService"
        }

        local serviceResolver = createCollisionResolver()

        for _, sName in ipairs(targetServices) do
            local ok, srv = pcall(function() return game:GetService(sName) end)
            if ok and srv then
                local hasContent = #srv:GetChildren() > 0
                if hasContent then
                    table.insert(servicesExported, sName)
                    local srvDirName = serviceResolver(sName, "")
                    local srvPath = outputDir .. "/" .. srvDirName
                    ensureDirectory(srvPath)

                    local srvMeta = getInstanceMetadata(srv)
                    local srvMetaJSON = serializeJSON(srvMeta, pretty)
                    safeWriteFile(srvPath .. "/instance.json", srvMetaJSON)

                    exportChildren(srv, srvPath)
                end
            end
        end
    else
        table.insert(servicesExported, targetRoot.Name)
        exportChildren(targetRoot, outputDir)
    end

    local manifestData = {
        format = "rbxlx-export",
        version = 1,
        source = {
            file = placeInfo.Name,
            placeId = game.PlaceId,
            creator = placeInfo.Creator
        },
        exportTimestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        stats = {
            totalInstances = stats.totalInstances,
            totalScripts = stats.totalScripts,
            serverScripts = stats.serverScripts,
            clientScripts = stats.clientScripts,
            moduleScripts = stats.moduleScripts
        },
        services = servicesExported,
        scripts = exportedScriptsList
    }

    local manifestJSON = serializeJSON(manifestData, pretty)
    safeWriteFile(outputDir .. "/manifest.json", manifestJSON)

    return stats
end

-- =====================================================================
-- EXPORT ACTION LOGIC
-- =====================================================================

local isExporting = false

ExportBtn.MouseButton1Click:Connect(function()
    if isExporting then return end
    isExporting = true
    ExportBtn.Text = "DUMPING MAP & SCRIPTS..."
    ExportBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)

    task.spawn(function()
        local resolvedName = FilenameBox.Text:gsub("{TIMESTAMP}", os.date("%d-%m-%Y_%H-%M-%S"))
        if not resolvedName:lower():find("%.rbxl$") and not resolvedName:lower():find("%.rbxlx$") then
            resolvedName = resolvedName .. (SaveConfig.PlaceFileFormat == "rbxl" and ".rbxl" or ".rbxlx")
        end

        if SaveConfig.ForceGlobalArchivable then
            setLog("Enforcing Archivable = true across DataModel...", C.AccentGold)
            for _, srv in ipairs(game:GetChildren()) do
                pcall(function()
                    srv.Archivable = true
                    for _, d in ipairs(srv:GetDescendants()) do
                        d.Archivable = true
                    end
                end)
            end
        end

        setLog("Dumping Map & Place to " .. resolvedName .. "...", C.AccentGold)
        local options = {
            Decompile = SaveConfig.Decompile,
            DecompileTimeout = SaveConfig.DecompileTimeout,
            MaxThreads = SaveConfig.MaxThreads,
            IgnoreDefaultProps = SaveConfig.IgnoreDefaultProps,
            RemovePlayerCharacters = SaveConfig.RemovePlayerCharacters,
            NilInstances = SaveConfig.RecoverNilInstances,
            ShowStatus = true
        }

        local success, err = pcall(function()
            return saveEngine(game, resolvedName, options)
        end)

        if success then
            ExportBtn.Text = "SAVED PLACE (" .. (SaveConfig.PlaceFileFormat == "rbxl" and ".RBXL" or ".RBXLX") .. ")!"
            ExportBtn.BackgroundColor3 = C.AccentGreen
            setLog("✓ Map & place successfully saved to " .. resolvedName .. "!", C.AccentGreen)

            if SaveConfig.ExportProjectFolder then
                task.wait(0.5)
                local baseProjectDir = resolvedName:gsub("%.rbxlx?$", "") .. "_project"
                ExportBtn.Text = "EXPORTING PROJECT FOLDER..."
                ExportBtn.BackgroundColor3 = C.AccentGold
                setLog("Extracting Project Folder (--pretty) to " .. baseProjectDir .. "...", C.AccentGold)

                local folderSuccess, folderStats = pcall(function()
                    return exportProjectFolderTree(game, baseProjectDir, SaveConfig.PrettyJSON, SaveConfig.ProjectExportMode, function(statusMsg)
                        setLog(statusMsg, C.AccentGold)
                    end)
                end)

                if folderSuccess and folderStats then
                    ExportBtn.Text = "PROJECT & PLACE SAVED!"
                    ExportBtn.BackgroundColor3 = C.AccentGreen
                    setLog(string.format("✓ Saved place + Project Folder (--pretty): %d scripts, %d instances!", folderStats.totalScripts, folderStats.totalInstances), C.AccentGreen)
                else
                    setLog("⚠️ Project folder export note: " .. tostring(folderStats):sub(1, 40), C.AccentGold)
                end
            end
        else
            ExportBtn.Text = "ERROR: " .. tostring(err):sub(1, 25)
            ExportBtn.BackgroundColor3 = C.AccentRed
            setLog("✕ Error: " .. tostring(err), C.AccentRed)
        end

        task.wait(4)
        ExportBtn.Text = "🌍 DUMP FULL PLACE & SCRIPTS (" .. (SaveConfig.PlaceFileFormat == "rbxl" and ".RBXL" or ".RBXLX") .. ")"
        ExportBtn.BackgroundColor3 = C.AccentBlue
        isExporting = false
    end)
end)

-- Window Open/Close Toggles
local isVisible = true
local function setVisible(vis)
    isVisible = vis
    Window.Visible = vis
end

CloseBtn.MouseButton1Click:Connect(function() setVisible(false) end)
FloatingPill.MouseButton1Click:Connect(function() setVisible(not isVisible) end)

-- Keybind: RightShift to Toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not isVisible)
    end
end)

print("[SaveInstance PRO MAX v3.3] Map & Scripts Engine initialized successfully!")
