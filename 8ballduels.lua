-- ==============================================================================
-- 🎱 8 BALL DUELS (การดวล 8 ลูก) - LITE ASSISTANT
-- Features: Thin White/Black Guide & Bank Lines, Smart Snap Aim, Auto Shoot, Legend Bot Toggle
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- // คีย์ลัดหลัก (ตั้งค่าได้ที่นี่) //
local KEYS = {
    SnapAim  = Enum.KeyCode.E,     -- [E] ล็อกเป้ามุมที่ดีที่สุด
    Shoot    = Enum.KeyCode.R,     -- [R] ยิงลงหลุมทันที (คำนวณแรงอัตโนมัติ)
    AutoPlay = Enum.KeyCode.A,     -- [A] เปิด/ปิด บอทเล่นอัตโนมัติ (ตัวตึง Legend)
    ToggleUI = Enum.KeyCode.H,     -- [H] ซ่อน/แสดงหน้าต่าง UI
}

local SETTINGS = {
    LineThickness = 0.35,          -- เส้นบางกำลังดี
    GuideLength = 400,             -- ความยาวเส้นเล็ง
    MaxBounces = 2,                -- จำนวนครั้งที่ชิ่ง (1-2 ครั้ง)
    AutoPlayDelay = 0.6,           -- หน่วงเวลาก่อนบอทยิงในแต่ละเทิร์นปกติ (วินาที)
    NewMatchDelay = 2.5,           -- หน่วงเวลารอโหลด UI และจัดโต๊ะให้เสร็จเมื่อเริ่มแมตช์ใหม่ (วินาที)
}

local autoPlayEnabled = false
local disableAutoPlayOnMatchEnd = function() end
local killScript = function() end
local scriptConnections = {}
local screenGui = nil
local badge = nil
local iconBtn = nil
local lastMatchRef = nil

local function safeConnect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(scriptConnections, conn)
    return conn
end

-- // NOTIFICATION //
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "8 Ball Duels",
            Text = text or "",
            Duration = 2.5
        })
    end)
end

-- // GAME SPECIFIC MODULES //
-- ป้องกันการค้าง Yield ตลอดกาลหากรันผิด PlaceId หรือเกมยังโหลดไม่เสร็จ
local Libraries = ReplicatedStorage:WaitForChild("Libraries", 10)
if not Libraries then
    notify("8 Ball Duels ❌", "ยังไม่พบโมดูลเกม (หากอยู่ในล็อบบี้หลัก ให้กดจอยเข้าโต๊ะเล่นก่อน)")
    warn("❌ [Pool God Mode] Cannot load: ReplicatedStorage.Libraries not found. PlaceId: " .. tostring(game.PlaceId))
    return
end

local GameSpecific = Libraries:WaitForChild("GameSpecific", 5)
local PoolFolder = GameSpecific and GameSpecific:WaitForChild("Pool", 5)
if not PoolFolder then
    notify("8 Ball Duels ❌", "ยังไม่พบโฟลเดอร์ Pool (หากอยู่ในล็อบบี้หลัก ให้กดจอยเข้าโต๊ะเล่นก่อน)")
    warn("❌ [Pool God Mode] Cannot load: PoolFolder not found. PlaceId: " .. tostring(game.PlaceId))
    return
end

local function safeRequire(parent, name, timeout)
    if not parent then return nil end
    local child = parent:WaitForChild(name, timeout or 15)
    if not child then
        warn("⚠️ [Pool God Mode] Missing module: " .. tostring(name))
        return nil
    end
    local ok, mod = pcall(require, child)
    if not ok then
        warn("⚠️ [Pool God Mode] Error requiring " .. tostring(name) .. ": " .. tostring(mod))
        return nil
    end
    return mod
end

local PoolAI = safeRequire(PoolFolder, "PoolAI", 15)
local PoolPhysics = safeRequire(PoolFolder, "PoolPhysics", 15)
local PoolGeometry = safeRequire(PoolFolder, "PoolGeometry", 15)
local PoolConstants = safeRequire(PoolFolder, "PoolConstants", 15)
local PoolAimOverlay = safeRequire(PoolFolder, "PoolAimOverlay", 15)
local PoolInputController = safeRequire(PoolFolder, "PoolInputController", 15)
local PoolMatchClient = safeRequire(PoolFolder, "PoolMatchClient", 15)
local PoolRules = safeRequire(PoolFolder, "PoolRules", 15)
local PoolMatchReplica = safeRequire(PoolFolder, "PoolMatchReplica", 15)
local PoolViewController = safeRequire(PoolFolder, "PoolViewController", 15)

if not PoolGeometry or not PoolConstants or not PoolMatchClient then
    notify("8 Ball Duels ❌", "โหลดโมดูลเกมไม่ครบ กรุณาลองรันใหม่อีกครั้ง")
    warn("❌ [Pool God Mode] Critical modules failed to load.")
    return
end

local cushions = (PoolGeometry.GetCushions and PoolGeometry.GetCushions()) or {}
local pockets = (PoolGeometry.GetPockets and PoolGeometry.GetPockets()) or {}
local ballRadius = PoolConstants.BallRadius or 1.125
local ballDiameter = PoolConstants.BallDiameter or 2.25
local FrameWidth = PoolConstants.FrameWidth or 50
local FrameHeight = PoolConstants.FrameHeight or 100

-- // CLEAN PREVIOUS HEAVY UI //
pcall(function()
    if type(getgenv) == "function" and getgenv().PoolRayfield then
        pcall(function() getgenv().PoolRayfield:Destroy() end)
        getgenv().PoolRayfield = nil
    end
    for _, ch in ipairs(playerGui:GetChildren()) do
        if ch.Name == "Rayfield" or ch.Name:find("^Rayfield%-Old") then
            pcall(function() ch:Destroy() end)
        end
    end
end)

-- // CUSHION RAYCAST & REFLECTION ENGINE //
local function cushionToi(pos, dir, cushion, maxDist, radius)
    radius = radius or ballRadius
    local normal = cushion.Normal
    local vDotN = dir:Dot(normal)
    if vDotN >= -1e-6 then return nil end
    local distToPlane = (pos - cushion.A):Dot(normal)
    if distToPlane < -radius then return nil end
    local toi
    if distToPlane < radius then
        toi = 0
        local seg = cushion.B - cushion.A
        local segLen = seg.Magnitude
        local relPos = pos + dir * toi - cushion.A
        local proj = relPos:Dot(seg / segLen)
        if proj >= 0 and proj <= segLen then return toi end
        return nil
    end
    toi = (radius - distToPlane) / vDotN
    if toi >= 0 and toi <= maxDist then
        local seg = cushion.B - cushion.A
        local segLen = seg.Magnitude
        local relPos = pos + dir * toi - cushion.A
        local proj = relPos:Dot(seg / segLen)
        if proj >= 0 and proj <= segLen then return toi end
    end
    return nil
end

local function raycastCushions(pos, dir, maxDist, radius)
    local bestToi = maxDist or 500
    local bestCushion = nil
    for _, cushion in ipairs(cushions) do
        local toi = cushionToi(pos, dir, cushion, bestToi, radius)
        if toi and toi < bestToi and toi > 0.001 then
            bestToi = toi
            bestCushion = cushion
        end
    end
    if bestCushion then
        local hitPos = pos + dir * bestToi
        local normal = bestCushion.Normal
        local reflectDir = (dir - 2 * dir:Dot(normal) * normal).Unit
        return {
            distance = bestToi,
            hitPos = hitPos,
            reflectDir = reflectDir,
        }
    end
    return nil
end

local function checkPocketHit(p1, p2)
    local seg = p2 - p1
    local segLen = seg.Magnitude
    if segLen < 0.001 then return nil end
    local segDir = seg / segLen
    for _, pocket in ipairs(pockets) do
        local toMouth = pocket.MouthCentre - p1
        local proj = toMouth:Dot(segDir)
        if proj > 0 and proj < segLen then
            local perp = (toMouth - segDir * proj).Magnitude
            if perp <= (pocket.Mouth / 2) then
                return pocket, p1 + segDir * proj
            end
        end
    end
    return nil
end

-- // LIVE MATCH CLIENT TRACKER //
local activeMatchClient = (type(getgenv) == "function" and getgenv().ActivePoolMatch) or nil

if not rawget(PoolMatchClient, "_godHooked") then
    PoolMatchClient._godHooked = true
    local oldMatchClientNew = PoolMatchClient.new
    PoolMatchClient.new = function(...)
        local match = oldMatchClientNew(...)
        activeMatchClient = match
        if type(getgenv) == "function" then
            getgenv().ActivePoolMatch = match
        end
        return match
    end
end

local lastScanTimestamp = 0
local function getActiveMatch()
    local poolGameUI = playerGui:FindFirstChild("PoolGameUI")
    if poolGameUI and poolGameUI:GetAttribute("MatchActive") == false then
        activeMatchClient = nil
        if type(getgenv) == "function" then
            getgenv().ActivePoolMatch = nil
        end
        return nil
    end

    if not activeMatchClient and type(getgenv) == "function" and getgenv().ActivePoolMatch then
        activeMatchClient = getgenv().ActivePoolMatch
    end

    local liveRep = PoolMatchReplica.Get()
    if activeMatchClient then
        if liveRep and activeMatchClient.Replica and activeMatchClient.Replica ~= liveRep then
            activeMatchClient = nil -- Match เก่าหมดอายุ ให้เคลียร์ทิ้งทันที
            if type(getgenv) == "function" then
                getgenv().ActivePoolMatch = nil
            end
        elseif activeMatchClient.Input and activeMatchClient.Simulation and activeMatchClient.Rules then
            if activeMatchClient.Rules.Phase ~= "GameOver" then
                return activeMatchClient
            end
            activeMatchClient = nil
            if type(getgenv) == "function" then
                getgenv().ActivePoolMatch = nil
            end
        end
    end

    -- หากไม่มี Match ที่กำลังเล่นอยู่ หรืออยู่ในหน้า Lobby ให้ข้ามการค้นหา ไม่ต้องสแกน
    if not poolGameUI or poolGameUI:GetAttribute("MatchActive") ~= true then
        return nil
    end

    -- Throttled scan (แนวทาง B): ค้นหาไม่เกิน 1 ครั้งต่อ 5 วินาที และจำกัดการสแกน ป้องกัน Luau VM ค้าง 100%
    local now = os.clock()
    if now - lastScanTimestamp < 5 then
        return activeMatchClient
    end
    lastScanTimestamp = now

    -- ค้นหา Match สำรองกรณีรันสคริปต์กลางคัน (Safe Bounded Throttled Scan)
    pcall(function()
        if type(getgc) == "function" then
            local inputObj, rulesObj, simObj, clientMatch
            local count = 0
            for _, fn in ipairs(getgc()) do
                count = count + 1
                if count > 200 then break end -- ป้องกัน Unbounded Walk ล็อกจำนวนสูงสุดไม่เกิน 200 รายการ

                if type(fn) == "function" and islclosure(fn) then
                    local info = debug.getinfo(fn)
                    if info.source and (info.source:find("PoolGameUIHandler") or info.source:find("PoolMatchClient")) then
                        local okUv, uvs = pcall(debug.getupvalues, fn)
                        if okUv and uvs then
                            for _, v in pairs(uvs) do
                                if typeof(v) == "table" then
                                    if rawget(v, "Simulation") and rawget(v, "Rules") and rawget(v, "Input") then
                                        clientMatch = v
                                        break
                                    end
                                    if rawget(v, "AimLocked") ~= nil and rawget(v, "Simulation") ~= nil then
                                        inputObj = v
                                    end
                                    if rawget(v, "Phase") ~= nil and rawget(v, "Turn") ~= nil and rawget(v, "Groups") ~= nil then
                                        rulesObj = v
                                    end
                                    if rawget(v, "Balls") and rawget(v, "Settled") ~= nil then
                                        simObj = v
                                    end
                                end
                            end
                        end
                    end
                end
                if clientMatch or (inputObj and rulesObj) then break end
            end

            if clientMatch and (not liveRep or clientMatch.Replica == liveRep) then
                activeMatchClient = clientMatch
                if type(getgenv) == "function" then
                    getgenv().ActivePoolMatch = clientMatch
                end
            elseif inputObj and rulesObj and rulesObj.Phase ~= "GameOver" then
                activeMatchClient = {
                    Input = inputObj,
                    Simulation = inputObj.Simulation or simObj,
                    Rules = rulesObj,
                    Overlay = inputObj.Overlay,
                    View = inputObj.View,
                    Hud = inputObj.Hud,
                    Seat = 1,
                    IsBotMatch = true,
                }
                if type(getgenv) == "function" then
                    getgenv().ActivePoolMatch = activeMatchClient
                end
            end
        end
    end)

    return activeMatchClient
end

-- ระบุตำแหน่งที่นั่งของเรา (Seat 1 หรือ Seat 2) แม่นยำ 100% จาก Server Replica
local function getMySeat(match)
    if match and match.Seat and match.Seat > 0 then
        return match.Seat
    end
    local rep = (match and match.Replica) or PoolMatchReplica.Get()
    local pm = rep and rep.Data and rep.Data.poolMatch
    if pm and pm.Seats then
        for idx, s in ipairs(pm.Seats) do
            if s.UserId == localPlayer.UserId or s.Name == localPlayer.Name then
                return idx
            end
        end
    end
    return 1
end

-- ระบุกลุ่มลูกของเรา (Solid หรือ Stripe) แม่นยำ 100%
local function getMyGroup(match, seat)
    seat = seat or getMySeat(match)
    local rep = (match and match.Replica) or PoolMatchReplica.Get()
    local pm = rep and rep.Data and rep.Data.poolMatch
    if pm and pm.Seats and pm.Seats[seat] and pm.Seats[seat].Group then
        return pm.Seats[seat].Group
    end
    if match and match.Rules and match.Rules.Groups and match.Rules.Groups[seat] then
        return match.Rules.Groups[seat]
    end
    return nil -- โต๊ะเปิด ยังไม่ระบุกลุ่ม
end

-- ตรวจสอบอย่างแม่นยำ 100% ว่าใช่เทิร์นของเราจริงๆ หรือไม่ (อ้างอิงจาก Server Replicated State)
local function isMyTurn(match)
    if not match then return false end
    local mySeat = getMySeat(match)
    local rep = (match and match.Replica) or PoolMatchReplica.Get()
    local pm = rep and rep.Data and rep.Data.poolMatch
    if pm then
        if pm.Phase ~= "Playing" or pm.RulesPhase == "GameOver" then
            return false
        end
        return pm.Turn == mySeat
    end
    if match.Rules and match.Rules.Turn then
        if match.Rules.Phase == "GameOver" then
            return false
        end
        return match.Rules.Turn == mySeat
    end
    return false
end

-- ตรวจสอบทางกายภาพว่าลูกทั้ง 15 ลูกยังอยู่ในแร็กเก็ตสามเหลี่ยมเริ่มต้นหรือไม่ (Physics Ground Truth)
local function isRackIntact(simulation)
    if not simulation or not simulation.Balls then return false end
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    local count = 0

    for i = 1, 15 do
        local b = simulation.Balls[i]
        if not b then return false end
        -- ถ้ามีลูกใดลูกหนึ่งลงหลุมไปแล้ว แสดงว่าโต๊ะถูกยิงเปิดไปแล้ว 100%
        if b.Pocketed then
            return false
        end
        if b.Position then
            count = count + 1
            local px = b.Position.X
            local py = b.Position.Y
            if px < minX then minX = px end
            if px > maxX then maxX = px end
            if py < minY then minY = py end
            if py > maxY then maxY = py end
        end
    end

    if count < 15 then return false end

    -- ในแร็กเก็ตสามเหลี่ยมเริ่มต้น กองลูก 15 ลูกจะมีขนาดความกว้างไม่เกิน 18 และความสูงไม่เกิน 16
    -- ถ้าลูกแตกกระจายเกินกว่านี้ แสดงว่าโต๊ะถูกยิงเปิดไปแล้ว 100% (แม้ฝ่ายตรงข้ามจะเป็นคนยิงเปิดก็ตาม)
    local spanX = maxX - minX
    local spanY = maxY - minY
    if spanX > 18 or spanY > 16 then
        return false
    end

    return true
end

-- ตรวจสอบว่าโต๊ะอยู่ในสถานะลูกเปิดโต๊ะ (Break Shot) หรือไม่
local function isBreakShot(match)
    match = match or getActiveMatch()
    if not match then return false end

    -- 1. ตรวจสอบทางกายภาพของลูกบนโต๊ะ (แม่นยำที่สุด 100% ป้องกันกรณีฝ่ายตรงข้ามยิงเปิดแล้วระบบยังคิดว่าไม่ได้เปิด)
    if match.Simulation and match.Simulation.Balls then
        if not isRackIntact(match.Simulation) then
            return false
        end
    end

    -- 2. ตรวจสอบจาก Server Replica
    local rep = (match and match.Replica) or PoolMatchReplica.Get()
    local pm = rep and rep.Data and rep.Data.poolMatch
    if pm then
        -- หากจบเกมแล้ว ไม่ใช่ Break แน่นอน
        if pm.RulesPhase == "GameOver" or pm.Phase == "Finished" then
            return false
        end
        -- หากโต๊ะเปิดแล้ว หรือแบ่งกลุ่ม Solid/Stripe แล้ว ไม่ใช่ Break แน่นอน 100%
        if pm.RulesPhase == "Open" or pm.RulesPhase == "Assigned" then
            return false
        end
        -- หากมีการยิงไปแล้ว (ShotIndex > 0) แสดงว่าผ่านการเปิดโต๊ะไปแล้ว ไม่ใช่ Break
        if pm.ShotIndex and tonumber(pm.ShotIndex) and tonumber(pm.ShotIndex) > 0 then
            return false
        end
    end

    -- 3. ตรวจสอบจาก Rules Module
    local rules = match.Rules
    if rules then
        if rules.Phase == "GameOver" or rules.Phase == "Open" or rules.Phase == "Assigned" then
            return false
        end
    end

    -- 4. ตรวจสอบจาก AppliedShot (จำนวนช็อตที่ถูกยิงไปแล้วในแมตช์)
    if match.AppliedShot and tonumber(match.AppliedShot) and tonumber(match.AppliedShot) > 0 then
        return false
    end

    -- 5. หากลูกทั้ง 15 ลูกยังวางเรียงกันอยู่ในแร็กเก็ตสามเหลี่ยมสมบูรณ์ แสดงว่าเป็นลูกเปิดโต๊ะ
    if match.Simulation and match.Simulation.Balls and isRackIntact(match.Simulation) then
        return true
    end

    -- 6. Fallback: ถ้า Rules Phase ระบุชัดเจนว่าเป็น Break
    if rules and rules.Phase == "Break" then
        return true
    end
    if pm and (pm.RulesPhase == "Break" or pm.Phase == "Break") then
        return true
    end

    return false
end

-- ตรวจสอบว่าลูกเบอร์นี้ถูกกติกาของฝั่งเราหรือไม่ (ป้องกันบอทหลงฝั่งหรือยิงลูกคู่แข่ง 100%)
local function isBallLegalForMe(match, ballNumber)
    if not match or not match.Rules or not match.Simulation then return false end
    if ballNumber == PoolConstants.CueBallNumber then return false end

    -- ในช่วงเปิดโต๊ะ (Break Phase): เล็งได้ทุกลูก
    if isBreakShot(match) then
        return true
    end

    local mySeat = getMySeat(match)
    local myGroup = getMyGroup(match, mySeat)
    local phase = match.Rules.Phase

    -- โต๊ะเปิด (Open Table): ยิงได้ทุกลูกยกเว้นลูกดำเบอร์ 8
    if not myGroup or phase == "Open" then
        return ballNumber ~= PoolConstants.EightBallNumber
    end

    -- โต๊ะกำหนดกลุ่มแล้ว (Assigned Table)
    local remaining = PoolRules.CountRemaining(match.Simulation, myGroup)
    if remaining == 0 then
        -- ยิงกลุ่มตัวเองหมดโต๊ะแล้ว: ต้องยิงลูกดำเบอร์ 8 เท่านั้น
        return ballNumber == PoolConstants.EightBallNumber
    end

    -- ยังยิงกลุ่มตัวเองไม่หมด: ห้ามยิงลูกดำเบอร์ 8 และต้องยิงเฉพาะกลุ่มของตัวเองเท่านั้น (ห้ามยิงลูกฝั่งตรงข้ามเด็ดขาด)
    if ballNumber == PoolConstants.EightBallNumber then
        return false
    end
    local ballGroup = (ballNumber < PoolConstants.EightBallNumber and "Solid") or "Stripe"
    return ballGroup == myGroup
end

-- // LINE DRAWING HELPERS //
local function getOrCreateLine(root, name, color, zIndex)
    local line = root:FindFirstChild(name)
    if not line then
        line = Instance.new("ImageLabel")
        line.Name = name
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BorderSizePixel = 0
        line.BackgroundColor3 = color
        line.ImageColor3 = color
        line.BackgroundTransparency = 0
        line.ImageTransparency = 1
        line.ZIndex = zIndex or 50
        line.Visible = false
        line.Parent = root
    else
        line.BackgroundColor3 = color
        line.ImageColor3 = color
    end
    return line
end

local function setLine(line, p1, p2, thickness)
    local delta = p2 - p1
    local mag = delta.Magnitude
    if mag < 0.001 then
        line.Visible = false
        return
    end
    local center = (p1 + p2) / 2
    line.Position = UDim2.fromScale(0.5 + center.X / FrameWidth, 0.5 - center.Y / FrameHeight)
    line.Size = UDim2.fromScale(mag / FrameWidth, (thickness or SETTINGS.LineThickness) / FrameHeight)
    line.Rotation = math.deg(math.atan2(-delta.Y, delta.X))
    line.Visible = true
end

-- // 1. GUIDELINE & CUSHION BOUNCE (เส้นสีขาว = ลูกขาว | เส้นสีดำ = ลูกสี) //
local COLOR_WHITE = Color3.new(1, 1, 1)    -- เส้นลูกขาว (สีขาว)
local COLOR_BLACK = Color3.new(0, 0, 0)    -- เส้นลูกสี (สีดำ)

local function hideAllOverlayLines(overlay)
    if overlay then
        overlay.GuidesEnabled = false
        if overlay.AimLine then overlay.AimLine.Visible = false end
        if overlay.CueLine then overlay.CueLine.Visible = false end
        if overlay.ObjectLine then overlay.ObjectLine.Visible = false end
        if overlay.Ghost then overlay.Ghost.Visible = false end
        if overlay.GhostBall then overlay.GhostBall.Visible = false end
    end
    local root = (overlay and overlay.Root) or playerGui:FindFirstChild("AimOverlay", true)
    if root then
        for _, ch in ipairs(root:GetChildren()) do
            if ch:IsA("GuiObject") and ch.Name ~= "CueStick" then
                ch.Visible = false
            end
        end
    end
end

local oldOverlayUpdate = PoolAimOverlay.Update
PoolAimOverlay.Update = function(self, p2, p3, p4, p5, p6, p7)
    local root = self.Root

    -- // ปิดการแสดงผลเส้นทั้งหมด 100% ขณะที่บอทเล่นอัตโนมัติ (ยกเว้นช่วงเปิดโต๊ะที่ผู้เล่นต้องเล็งยิงเอง) //
    if autoPlayEnabled then
        local match = activeMatchClient
        if match and not isBreakShot(match) then
            hideAllOverlayLines(self)
            return oldOverlayUpdate(self, p2, p3, p4, p5, p6, p7)
        end
    end

    -- เส้นชิ่งลูกสี (สีดำ)
    local bankObj1 = root and getOrCreateLine(root, "LiteBankObj1", COLOR_BLACK, 50)
    local bankObj2 = root and getOrCreateLine(root, "LiteBankObj2", COLOR_BLACK, 50)
    local bankObj3 = root and getOrCreateLine(root, "LiteBankObj3", COLOR_BLACK, 50)
    -- เส้นชิ่งลูกขาว (สีขาว)
    local bankCue1 = root and getOrCreateLine(root, "LiteBankCue1", COLOR_WHITE, 50)
    local bankCue2 = root and getOrCreateLine(root, "LiteBankCue2", COLOR_WHITE, 50)
    local bankCue3 = root and getOrCreateLine(root, "LiteBankCue3", COLOR_WHITE, 50)
    local bankDeflect = root and getOrCreateLine(root, "LiteBankDeflect", COLOR_WHITE, 50)

    local function hideBanks()
        if bankObj1 then bankObj1.Visible = false end
        if bankObj2 then bankObj2.Visible = false end
        if bankObj3 then bankObj3.Visible = false end
        if bankCue1 then bankCue1.Visible = false end
        if bankCue2 then bankCue2.Visible = false end
        if bankCue3 then bankCue3.Visible = false end
        if bankDeflect then bankDeflect.Visible = false end
    end

    p6 = SETTINGS.GuideLength
    self.GuidesEnabled = true
    
    local res = oldOverlayUpdate(self, p2, p3, p4, p5, p6, p7)
    if not root then return res end

    -- ล้างเส้นรุ่นเก่าถ้ามีตกค้าง
    local oldV2Lines = { "BankObjLine1", "BankObjLine2", "BankCueLine1", "BankCueLine2", "BankDeflectLine", "BankRailDot1", "BankRailDot2", "BankPocketDot" }
    for _, name in ipairs(oldV2Lines) do
        local el = root:FindFirstChild(name)
        if el then el:Destroy() end
    end

    local thick = SETTINGS.LineThickness

    -- ปรับสีเส้นเดิมให้เป็น ขาว / ดำ และเส้นบางพอดี
    if self.AimLine then
        self.AimLine.BackgroundColor3 = COLOR_WHITE
        self.AimLine.ImageColor3 = COLOR_WHITE
        if self.AimLine.Visible then
            self.AimLine.Size = UDim2.fromScale(self.AimLine.Size.X.Scale, thick / FrameHeight)
        end
    end
    if self.CueLine then
        self.CueLine.BackgroundColor3 = COLOR_WHITE
        self.CueLine.ImageColor3 = COLOR_WHITE
        if self.CueLine.Visible then
            self.CueLine.Size = UDim2.fromScale(self.CueLine.Size.X.Scale, thick / FrameHeight)
        end
    end
    if self.ObjectLine then
        self.ObjectLine.BackgroundColor3 = COLOR_BLACK
        self.ObjectLine.ImageColor3 = COLOR_BLACK
        if self.ObjectLine.Visible then
            self.ObjectLine.Size = UDim2.fromScale(self.ObjectLine.Size.X.Scale, thick / FrameHeight)
        end
    end

    if not self.GuidesEnabled or not root.Visible then
        hideBanks()
        return res
    end

    local maxLen = SETTINGS.GuideLength
    local maxBounces = SETTINGS.MaxBounces or 2

    -- กรณี A: เล็งโดนลูกเป้า (Object Ball) -> วิถีลูกสีเป็นเส้นสีดำ
    if p4 and p4.Kind == "Ball" and p4.ObjectDirection then
        bankCue1.Visible = false
        bankCue2.Visible = false
        bankCue3.Visible = false

        local startPos = p4.Ghost + p4.ObjectDirection * ballDiameter
        local hit1 = raycastCushions(startPos, p4.ObjectDirection, maxLen, ballRadius)
        if hit1 then
            local pock1, pockPos1 = checkPocketHit(startPos, hit1.hitPos)
            if pock1 then
                setLine(self.ObjectLine, startPos, pockPos1, thick)
                bankObj1.Visible = false
                bankObj2.Visible = false
                bankObj3.Visible = false
            else
                setLine(self.ObjectLine, startPos, hit1.hitPos, thick)
                if maxBounces >= 1 then
                    local remDist1 = math.max(maxLen - hit1.distance, 60)
                    local hit2 = (maxBounces >= 2) and raycastCushions(hit1.hitPos, hit1.reflectDir, remDist1, ballRadius)
                    if hit2 then
                        local pock2, pockPos2 = checkPocketHit(hit1.hitPos, hit2.hitPos)
                        if pock2 then
                            setLine(bankObj1, hit1.hitPos, pockPos2, thick)
                            bankObj2.Visible = false
                            bankObj3.Visible = false
                        else
                            setLine(bankObj1, hit1.hitPos, hit2.hitPos, thick)
                            local remDist2 = math.clamp(remDist1 - hit2.distance, 40, 150)
                            local hit3 = (maxBounces >= 3) and raycastCushions(hit2.hitPos, hit2.reflectDir, remDist2, ballRadius)
                            if hit3 then
                                local pock3, pockPos3 = checkPocketHit(hit2.hitPos, hit3.hitPos)
                                if pock3 then
                                    setLine(bankObj2, hit2.hitPos, pockPos3, thick)
                                    bankObj3.Visible = false
                                else
                                    setLine(bankObj2, hit2.hitPos, hit3.hitPos, thick)
                                    local remDist3 = math.clamp(remDist2 - hit3.distance, 30, 100)
                                    local end3 = hit3.hitPos + hit3.reflectDir * remDist3
                                    local pock4, pockPos4 = checkPocketHit(hit3.hitPos, end3)
                                    setLine(bankObj3, hit3.hitPos, pock4 and pockPos4 or end3, thick)
                                end
                            else
                                local end2 = hit2.hitPos + hit2.reflectDir * remDist2
                                local pock3, pockPos3 = checkPocketHit(hit2.hitPos, end2)
                                setLine(bankObj2, hit2.hitPos, pock3 and pockPos3 or end2, thick)
                                bankObj3.Visible = false
                            end
                        end
                    else
                        local end1 = hit1.hitPos + hit1.reflectDir * remDist1
                        local pock2, pockPos2 = checkPocketHit(hit1.hitPos, end1)
                        setLine(bankObj1, hit1.hitPos, pock2 and pockPos2 or end1, thick)
                        bankObj2.Visible = false
                        bankObj3.Visible = false
                    end
                else
                    bankObj1.Visible = false
                    bankObj2.Visible = false
                    bankObj3.Visible = false
                end
            end
        else
            bankObj1.Visible = false
            bankObj2.Visible = false
            bankObj3.Visible = false
        end

        -- ลูกขาวแฉลบไปชนขอบโต๊ะ (สีขาว)
        if maxBounces >= 1 and p4.CueDirection then
            local hitDef = raycastCushions(p4.Ghost, p4.CueDirection, maxLen * 0.4, ballRadius)
            if hitDef then
                local endDef = hitDef.hitPos + hitDef.reflectDir * 60
                setLine(bankDeflect, hitDef.hitPos, endDef, thick)
            else
                bankDeflect.Visible = false
            end
        else
            bankDeflect.Visible = false
        end

    -- กรณี B: เล็งลูกขาวเข้าหาขอบโต๊ะโดยตรง (Kick Shot) -> วิถีลูกขาวเป็นเส้นสีขาว
    elseif p4 and p4.Kind == "Cushion" then
        bankObj1.Visible = false
        bankObj2.Visible = false
        bankObj3.Visible = false
        bankDeflect.Visible = false

        if maxBounces >= 1 then
            local hit1 = raycastCushions(p2, p3, maxLen, ballRadius)
            if hit1 then
                local remDist1 = math.max(maxLen - hit1.distance, 80)
                local hit2 = (maxBounces >= 2) and raycastCushions(hit1.hitPos, hit1.reflectDir, remDist1, ballRadius)
                if hit2 then
                    local pock1, pockPos1 = checkPocketHit(hit1.hitPos, hit2.hitPos)
                    if pock1 then
                        setLine(bankCue1, hit1.hitPos, pockPos1, thick)
                        bankCue2.Visible = false
                        bankCue3.Visible = false
                    else
                        setLine(bankCue1, hit1.hitPos, hit2.hitPos, thick)
                        local remDist2 = math.clamp(remDist1 - hit2.distance, 40, 150)
                        local hit3 = (maxBounces >= 3) and raycastCushions(hit2.hitPos, hit2.reflectDir, remDist2, ballRadius)
                        if hit3 then
                            local pock2, pockPos2 = checkPocketHit(hit2.hitPos, hit3.hitPos)
                            if pock2 then
                                setLine(bankCue2, hit2.hitPos, pock2 and pockPos2, thick)
                                bankCue3.Visible = false
                            else
                                setLine(bankCue2, hit2.hitPos, hit3.hitPos, thick)
                                local remDist3 = math.clamp(remDist2 - hit3.distance, 30, 100)
                                local end3 = hit3.hitPos + hit3.reflectDir * remDist3
                                local pock3, pockPos3 = checkPocketHit(hit3.hitPos, end3)
                                setLine(bankCue3, hit3.hitPos, pock3 and pockPos3 or end3, thick)
                            end
                        else
                            local end2 = hit2.hitPos + hit2.reflectDir * remDist2
                            local pock2, pockPos2 = checkPocketHit(hit2.hitPos, end2)
                            setLine(bankCue2, hit2.hitPos, pock2 and pockPos2 or end2, thick)
                            bankCue3.Visible = false
                        end
                    end
                else
                    local end1 = hit1.hitPos + hit1.reflectDir * remDist1
                    local pock1, pockPos1 = checkPocketHit(hit1.hitPos, end1)
                    setLine(bankCue1, hit1.hitPos, pock1 and pockPos1 or end1, thick)
                    bankCue2.Visible = false
                    bankCue3.Visible = false
                end
            else
                bankCue1.Visible = false
                bankCue2.Visible = false
                bankCue3.Visible = false
            end
        else
            bankCue1.Visible = false
            bankCue2.Visible = false
            bankCue3.Visible = false
        end
    else
        hideBanks()
    end

    return res
end

-- // GOD MODE AI PROFILE (Zero Artificial Error, Pure Vector2 Physics, Supreme Positioning) //
local GOD_LEVEL = {
    Id = "God",
    Name = "God Mode (Zero Error)",
    Rating = 9999,
    AimError = 0,               -- 0% Error: Laser mathematical contact point
    PowerError = 0,             -- 0% Error: Pure physics calculation
    MissAimChance = 0,          -- 0% Miss chance
    Candidates = 8,             -- สแกน 8 มุมที่ดีที่สุด (Legend ในเกมคือ 6) คำนวณลื่นไหลไม่ค้าง Thread
    PositionWeight = 0.85,      -- Supreme cue ball positioning for consecutive potting
    PlaysSafeties = true,
    ThinkTime = 0,
    FullPower = false,
}

-- พิกัดหลุมจริงของโต๊ะในเกม (2D Vector2 Table Space)
local FALLBACK_POCKETS = {
    { Id = "HeadBottom", MouthCentre = Vector2.new(-42.409, -20.409) },
    { Id = "HeadTop",    MouthCentre = Vector2.new(-42.409, 20.409) },
    { Id = "FootBottom", MouthCentre = Vector2.new(42.409, -20.409) },
    { Id = "FootTop",    MouthCentre = Vector2.new(42.409, 20.409) },
    { Id = "SideBottom", MouthCentre = Vector2.new(0, -22) },
    { Id = "SideTop",    MouthCentre = Vector2.new(0, 22) },
}

-- // 2. SMART SNAP AIM (คำนวณมุมที่ดีที่สุดด้วย God Mode AI - ถูกต้องตามฝั่ง 100% ระบบ Vector2) //
local function calculateBestShot(match)
    match = match or getActiveMatch()
    if not match or not match.Simulation or not match.Rules then return nil end
    local simulation = match.Simulation
    local rules = match.Rules
    local mySeat = getMySeat(match)
    local myGroup = getMyGroup(match, mySeat)

    -- // 0. BREAK SHOT (ลูกเปิดโต๊ะ): บังคับให้ผู้เล่นเป็นคนเล็งและยิงเปิดโต๊ะเอง ไม่คำนวณบอท
    if isBreakShot(match) then
        return nil
    end

    -- สร้าง planRules โดยบังคับ Turn ให้เป็น mySeat ของเราเสมอ และใส่ Group ให้ถูกต้อง
    local isOpenTable = (not myGroup) or (rules.Phase == "Open")
    local planRules = {
        Phase = rules.Phase,
        Turn = mySeat,
        Groups = {},  -- เริ่มว่างเสมอ แล้วค่อยใส่ group ที่รู้แน่ๆ เท่านั้น
        BallInHand = rules.BallInHand,
        BehindHeadString = rules.BehindHeadString,
        ShotCount = rules.ShotCount or 0,
        Rules = rules.Rules,
    }
    -- ใส่ Groups เฉพาะเมื่อโต๊ะมีการกำหนดกลุ่มแล้ว (ไม่ใช่ Open Table)
    -- ถ้าใส่ Groups ผิดช่วง Open PoolAI จะ confused และอาจ return nil
    if not isOpenTable and rules.Groups then
        for k, v in pairs(rules.Groups) do
            planRules.Groups[k] = v
        end
    end
    if myGroup and not planRules.Groups[mySeat] then
        planRules.Groups[mySeat] = myGroup
    end

    local aiInstance = {
        Level = GOD_LEVEL,
        Random = Random.new(0),
    }
    setmetatable(aiInstance, PoolAI)

    local ok, plan = pcall(function()
        return PoolAI.Plan(aiInstance, simulation, planRules, mySeat)
    end)

    -- 1. ตรวจสอบ Choice แรกจาก PoolAI.Plan ว่าถูกต้องตามกติกาฝั่งเราหรือไม่
    if ok and plan and plan.Choice and plan.Choice.Target then
        if isBallLegalForMe(match, plan.Choice.Target) then
            return plan.Choice
        end
    end

    -- 2. หาก Choice แรกไม่ตรงกลุ่ม ให้ค้นหา Candidate อื่นที่ถูกกลุ่มและมีคะแนนสูงสุด
    if ok and plan and plan.Candidates then
        local bestCand = nil
        local bestScore = -math.huge
        for _, cand in ipairs(plan.Candidates) do
            if cand and cand.Target and isBallLegalForMe(match, cand.Target) then
                local score = cand.Score or cand.Quality or 0
                if score > bestScore then
                    bestScore = score
                    bestCand = cand
                end
            end
        end
        if bestCand then
            return bestCand
        end
    end

    -- 3. OPEN TABLE SMART SCAN (Vector2 Pure Math):
    -- เมื่อโต๊ะยังเปิดอยู่และ PoolAI ยังไม่ได้ช็อต ให้สแกนคำนวณหามุมตัด (Cut Quality) ที่ดีที่สุดเข้า 6 หลุมด้วยตัวเอง
    if isOpenTable then
        local cueBall = simulation.Balls[PoolConstants.CueBallNumber]
        if cueBall and cueBall.Position then
            local pocketList = (#pockets > 0 and pockets) or FALLBACK_POCKETS
            local bestChoice = nil
            local bestScore = -math.huge
            local diameter = PoolConstants.BallDiameter or (ballRadius * 2)

            for i = 1, 15 do
                if i == PoolConstants.EightBallNumber then continue end
                local b = simulation.Balls[i]
                if b and not b.Pocketed and b.Position then
                    for _, pock in ipairs(pocketList) do
                        local pockPos = pock.MouthCentre
                        local toPock = pockPos - b.Position
                        local pockDist = toPock.Magnitude
                        if pockDist > 0.001 then
                            local pockDir = toPock / pockDist
                            local ghostPos = b.Position - pockDir * diameter
                            local toGhost = ghostPos - cueBall.Position
                            local cueDist = toGhost.Magnitude
                            if cueDist > 0.001 then
                                local aimDir = toGhost / cueDist
                                local cutQuality = aimDir:Dot(pockDir)
                                -- ต้องมีมุมตัดมากกว่า 0.12 (มุมเปิด ไม่ยิงย้อนศร)
                                if cutQuality > 0.12 then
                                    local score = (cutQuality * 150) - (pockDist * 1.5) - (cueDist * 0.8)
                                    if score > bestScore then
                                        bestScore = score
                                        local totalDist = cueDist + pockDist
                                        local power = math.clamp(0.35 + totalDist / 120, 0.38, 0.88)
                                        bestChoice = {
                                            Target = b.Number or i,
                                            Pocket = pock.Id or "Pocket",
                                            Direction = aimDir, -- Vector2
                                            Power = power,
                                            Quality = cutQuality,
                                            Score = score,
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if bestChoice then
                return bestChoice
            end
        end
    end

    -- 4. FALLBACK SAFETY SHOT: ในกรณีที่โดนสนุ๊กเกอร์หรือไม่มีทางยิงชัดเจน
    local fbOk, fbDir, fbPwr = pcall(function()
        return PoolAI.FallbackShot(simulation, planRules)
    end)
    if fbOk and fbDir and typeof(fbDir) == "Vector2" then
        return {
            Target = "Safety",
            Pocket = "Cushion",
            Direction = fbDir,
            Power = fbPwr or 0.45,
            Quality = 0.5,
            Score = 0,
        }
    end

    return nil
end

local function resetAimState(match)
    match = match or getActiveMatch()
    if not match or not match.Input then return end
    pcall(function()
        if PoolInputController.ReleaseAim then
            PoolInputController.ReleaseAim(match.Input)
        end
        match.Input.AimLocked = false
        match.Input.ChargeLocked = false
        match.Input.Muted = false
        match.Input.BallHeld = false
        match.Input.Dragging = false
        match.Input.DragFrom = nil
        match.Input.DragAngle = nil
        match.Input.AimAnchor = nil
        PoolInputController.SetPower(match.Input, 0)
        if match.Input.State == "Charging" then
            PoolInputController.SetState(match.Input, "Aiming")
        end
    end)
end

local function executeSnapAim(silent)
    -- ถ้าเปิดบอทเล่นอัตโนมัติ [A] อยู่ และเป็นการกดจากผู้เล่น (not silent): ป้องกันการทำงานซ้อนกัน
    if autoPlayEnabled and not silent then
        notify("8 Ball Duels 🎱", "⚠️ กำลังใช้งานบอท [A] อยู่ (ไม่สามารถใช้ [E] ล็อกเป้าซ้ำได้)")
        return false
    end

    local match = getActiveMatch()
    if not match or not match.Input or not match.Simulation or not match.Rules then
        if not silent then notify("8 Ball Duels", "⚠️ ไม่พบโต๊ะที่กำลังเล่นอยู่") end
        return false
    end

    -- [บอท E]: ลูกเปิดโต๊ะไม่อนุญาตให้ล็อกเป้า แจ้งเตือนให้ผู้ใช้ยิงเปิดโต๊ะเอง
    if isBreakShot(match) then
        if not silent then
            notify("8 Ball Duels 🎱", "⚠️ ผู้ใช้ต้องยิงเปิดโต๊ะ")
        end
        return false
    end

    local choice = calculateBestShot(match)
    if not choice or not choice.Direction then
        if not silent then notify("8 Ball Duels", "⚠️ ไม่พบมุมยิงที่ชัดเจน") end
        return false
    end
    pcall(function()
        PoolInputController.SetAimDirection(match.Input, choice.Direction)
        -- ไม้จะไม่เข้าเพสยิง (ไม่ดึงไม้ถอยหลัง) จนกว่าจะกดคำสั่งยิงจริง
    end)
    if not silent then
        local targetNum = choice.Target or "?"
        local pocketName = choice.Pocket or "?"
        local pct = math.floor((choice.Quality or 0.95) * 100)
        notify("🎯 God Mode Locked!", string.format("เล็งลูก: #%s | หลุม: %s (%d%%)", tostring(targetNum), tostring(pocketName), pct))
    end
    return true, choice
end

-- // 3. AUTO SHOOT (กดยิงทันที คำนวณความแรงอัตโนมัติ) //
local function executeShoot(silent)
    -- ถ้าเปิดบอทเล่นอัตโนมัติ [A] อยู่ และเป็นการกดจากผู้เล่น (not silent): แจ้งเตือนว่าบอทควบคุมอยู่
    if autoPlayEnabled and not silent then
        notify("8 Ball Duels 🎱", "⚠️ กำลังใช้งานบอท [A] อยู่ (บอทยิงให้อัตโนมัติ)")
        return false
    end

    local match = getActiveMatch()
    if not match or not match.Input then return false end

    -- หากเป็นลูกเปิดโต๊ะ (Break Shot) บังคับให้ผู้เล่นเป็นคนเล็งและยิงเปิดโต๊ะเอง
    if isBreakShot(match) then
        if not silent then
            notify("8 Ball Duels 🎱", "⚠️ ผู้ใช้ต้องยิงเปิดโต๊ะ")
        end
        return false
    end

    local ok, choice = executeSnapAim(true)
    if ok and choice then
        pcall(function()
            local power = math.clamp(choice.Power or 0.7, 0.15, 1)
            PoolInputController.SetPower(match.Input, power)
        end)
        task.wait(0.08)
        pcall(function()
            local spin = (match.Input.Hud and match.Input.Hud.Spin) or Vector2.zero
            local power = math.clamp(choice.Power or 0.7, 0.15, 1)
            if match.Input.ShotBindable then
                match.Input.ShotBindable:Fire(choice.Direction, power, spin)
            end
        end)
        -- ปลดล็อกการควบคุมไม้เฉพาะเมื่อไม่ได้เปิดบอทอัตโนมัติ (ถ้าเปิดบอทอยู่ ให้บอทคุม 100%)
        if not autoPlayEnabled then
            pcall(function()
                match.Input.AimLocked = false
                match.Input.ChargeLocked = false
                match.Input.Muted = false
            end)
        end
        if not silent then
            notify("🎱 Potted!", "ยิงเรียบร้อยแล้ว!")
        end
        return true
    end
    return false
end

-- // 4. AUTO PLAY TOGGLE (บอท God Mode เล่นให้อัตโนมัติ ปิดเส้นเพื่อประสิทธิภาพสูงสุด) //
local updateHudBadge = function() end

local function toggleAutoPlay()
    autoPlayEnabled = not autoPlayEnabled
    notify("บอทเล่นอัตโนมัติ 🤖", autoPlayEnabled and "🟢 เปิดใช้งาน (ระดับ God Mode - ปิดเส้นลดโหลด)" or "🔴 ปิดการทำงาน (คืนการควบคุมไม้ & เปิดเส้น)")
    updateHudBadge()
    local match = getActiveMatch()
    if autoPlayEnabled then
        hideAllOverlayLines(match and match.Overlay)
    else
        resetAimState()
        if match and match.Overlay then
            match.Overlay.GuidesEnabled = true
        end
    end
end

-- ปิดบอท [A] อัตโนมัติเมื่อจบแมตช์ เพื่อให้ผู้เล่นต้องเปิดเองใหม่ในแมตช์ถัดไป
disableAutoPlayOnMatchEnd = function()
    if autoPlayEnabled then
        autoPlayEnabled = false
        pcall(function()
            updateHudBadge()
            resetAimState()
            local match = getActiveMatch()
            if match and match.Overlay then
                match.Overlay.GuidesEnabled = true
            end
        end)
        notify("บอทเล่นอัตโนมัติ 🤖", "🏁 แมตช์จบแล้ว - ปิดบอท [A] อัตโนมัติ (เปิดใหม่ในแมตช์ถัดไป)")
    end
end

-- // ระบบทำลายสคริปต์ (Kill Clean) คืนทรัพยากร 100% ป้องกัน VM ค้างหรือแล็ก //
local scriptKilled = false
killScript = function(reason)
    if scriptKilled then return end
    scriptKilled = true

    -- 1. ยกเลิกลูป Background Tasks ทั้งหมดทันที
    _G.PoolGodModeInstance = (_G.PoolGodModeInstance or 0) + 1

    -- 2. ปลดการล็อก Aim/Shoot คืนการควบคุมให้ผู้เล่นและเกม 100%
    pcall(function()
        local match = getActiveMatch()
        if match and match.Input then
            match.Input.AimLocked = false
            match.Input.ChargeLocked = false
            match.Input.Muted = false
        end
        if match and match.Overlay then
            match.Overlay.GuidesEnabled = true
        end
        resetAimState()
    end)

    -- 3. ตัด Event Listeners ทั้งหมดที่สคริปต์สร้างไว้
    for _, conn in ipairs(scriptConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(scriptConnections)

    -- 4. ทำลายหน้าต่าง GUI (PoolLiteHUD) และไอคอนทั้งหมด
    pcall(function()
        if screenGui then
            screenGui:Destroy()
            screenGui = nil
        end
        local hud = playerGui:FindFirstChild("PoolLiteHUD")
        if hud then hud:Destroy() end
    end)

    -- 5. ล้าง Global Environment และ Cache ทั้งหมด
    pcall(function()
        if type(getgenv) == "function" then
            getgenv().ActivePoolMatch = nil
            getgenv().PoolGodModeRunning = false
            getgenv().PoolGodBot = nil
        end
    end)
    activeMatchClient = nil
    autoPlayEnabled = false
    lastMatchRef = nil

    local msg = reason or "จบการทำงานและ Kill สคริปต์เรียบร้อย 100%"
    notify("🎱 Pool God Mode", msg)
    warn("🛑 [Pool God Mode] KILLED: " .. tostring(msg))
end

-- // 5. REJOIN SERVER (เชื่อมต่อเข้าเซิร์ฟเวอร์ใหม่ ปลอดภัย 100%) //
local function executeRejoin()
    notify("🎱 Rejoin Server", "กำลังเชื่อมต่อเข้าเซิร์ฟเวอร์ใหม่...")
    task.spawn(function()
        local ok = pcall(function()
            if #Players:GetPlayers() > 1 and (game.JobId and game.JobId ~= "") then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
            else
                TeleportService:Teleport(game.PlaceId, localPlayer)
            end
        end)
        if not ok then
            task.wait(0.5)
            pcall(function()
                TeleportService:Teleport(game.PlaceId, localPlayer)
            end)
        end
    end)
end

pcall(function()
    safeConnect(TeleportService.TeleportInitFailed, function(player, teleportResult, errorMessage)
        task.wait(0.5)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, localPlayer)
        end)
    end)
end)

_G.PoolGodBot = {
    Toggle = toggleAutoPlay,
    SnapAim = executeSnapAim,
    Shoot = executeShoot,
    Rejoin = executeRejoin,
    GetState = function() return autoPlayEnabled end,
}
if type(getgenv) == "function" then
    getgenv().PoolGodBot = _G.PoolGodBot
end


local matchReadyTimestamp = 0

-- ตรวจสอบว่า UI ของเกม โต๊ะ และแร็กเก็ตลูก โหลดเสร็จสมบูรณ์ 100% แล้วหรือยังก่อนเริ่มยิง
local function isMatchFullyReady(match)
    if not match then return false end

    -- 1. ต้องเปิดหน้าจอเกม PoolGameUI แล้ว (ไม่ใช่หน้าล็อบบี้หรือเมนู)
    local poolGameUI = playerGui:FindFirstChild("PoolGameUI")
    if not poolGameUI or not poolGameUI.Enabled then
        matchReadyTimestamp = os.clock()
        return false
    end

    -- 2. จอ Transition (ม่านปิด-เปิดเปลี่ยนฉาก) ต้องปิดลงสนิทแล้ว
    local transitionUI = playerGui:FindFirstChild("TransitionUI")
    if transitionUI and transitionUI.Enabled then
        matchReadyTimestamp = os.clock()
        return false
    end

    -- 3. ตรวจสอบสถานะการจัดลูกในแร็กเก็ต (ถ้าแอนิเมชันจัดลูกยังไม่เสร็จ ให้รอ)
    if match.RackRevealed == false then
        matchReadyTimestamp = os.clock()
        return false
    end

    -- 4. ตรวจจับแมตช์ใหม่ (เมื่อเริ่มเกมใหม่ ให้เริ่มนับเวลาหน่วง NewMatchDelay)
    local matchId = match.Replica or PoolMatchReplica.Get() or match.Rules or match.Simulation
    if matchId and matchId ~= lastMatchRef then
        lastMatchRef = matchId
        matchReadyTimestamp = os.clock()
        return false
    end

    -- 5. หากเป็นช็อตแรกของแมตช์ ให้หน่วงเวลาตาม NewMatchDelay เพื่อรอให้ UI และกล้องจัดเข้าที่
    local isFirstShot = isBreakShot(match)
    local requiredDelay = isFirstShot and (SETTINGS.NewMatchDelay or 2.5) or (SETTINGS.AutoPlayDelay or 0.6)

    if os.clock() - matchReadyTimestamp < requiredDelay then
        return false
    end

    -- 6. ตรวจสอบสถานะ Input ของเกม
    if match.Input and (match.Input.State == "GameOver" or match.Input.State == "Simulating") then
        return false
    end

    return true
end

local breakNoticeSent = false

_G.PoolGodModeInstance = (_G.PoolGodModeInstance or 0) + 1
local currentInstance = _G.PoolGodModeInstance

task.spawn(function()
    while _G.PoolGodModeInstance == currentInstance do
        task.wait(0.25)
        local match = getActiveMatch()

        -- บันทึกว่าแมตช์ได้เริ่มเล่นแล้วจริง (ป้องกันการ Kill ตอนอยู่ในล็อบบี้หรือรอห้อง)
        if match and match.Input and match.Rules then
            local rep = match.Replica or PoolMatchReplica.Get()
            local pm = rep and rep.Data and rep.Data.poolMatch
            local phase = (pm and pm.Phase) or match.Rules.Phase
            if phase == "Playing" or phase == "Open" or phase == "Assigned" then
                if not lastMatchRef then
                    lastMatchRef = match.Replica or match.Rules or match.Simulation or match
                end
            end
        end

        -- ตรวจสอบการสิ้นสุดแมตช์ (GameOver / Match Finished / หลุดออกจากห้อง)
        local isOver = false
        if lastMatchRef ~= nil then
            if match then
                local rep = match.Replica or PoolMatchReplica.Get()
                local pm = rep and rep.Data and rep.Data.poolMatch
                if (pm and (pm.RulesPhase == "GameOver" or pm.Phase == "Finished"))
                   or (match.Rules and match.Rules.Phase == "GameOver")
                   or (match.Input and match.Input.State == "GameOver") then
                    isOver = true
                end
            else
                isOver = true
            end
        end

        if isOver then
            lastMatchRef = nil
            activeMatchClient = nil
            if type(getgenv) == "function" then
                getgenv().ActivePoolMatch = nil
            end
            disableAutoPlayOnMatchEnd()
            pcall(function()
                if match and match.Input then
                    match.Input.AimLocked = false
                    match.Input.ChargeLocked = false
                    match.Input.Muted = false
                end
                if match and match.Overlay then
                    match.Overlay.GuidesEnabled = true
                end
                resetAimState()
            end)
            notify("8 Ball Duels 🎱", "🏁 แมตช์จบแล้ว - สคริปต์เข้าสู่โหมด Standby รอแมตช์ถัดไป...")
            task.wait(2)
        end

        if autoPlayEnabled then
            if match and match.Input and match.Rules and match.Simulation then
                -- ถ้าเป็นลูกเปิดโต๊ะ (Break Shot): บังคับให้ผู้เล่นยิงเปิดโต๊ะเอง ไม่ยิงอัตโนมัติ
                if isBreakShot(match) then
                    -- คืนการควบคุมให้ผู้เล่น 100% เพื่อเล็งและยิงเปิดโต๊ะเอง
                    pcall(function()
                        match.Input.AimLocked = false
                        match.Input.ChargeLocked = false
                        match.Input.Muted = false
                    end)
                    if isMyTurn(match) and not breakNoticeSent then
                        breakNoticeSent = true
                        notify("บอทเล่นอัตโนมัติ 🤖", "⚠️ ผู้ใช้ต้องยิงเปิดโต๊ะเอง (บอท A จะเริ่มเล่นอัตโนมัติหลังเปิดโต๊ะ)")
                    end
                else
                    breakNoticeSent = false
                    hideAllOverlayLines()

                    -- เข้าสู่โหมด God Mode หลังเปิดโต๊ะ: ปิดการควบคุมของผู้เล่น 100% เพื่อให้บอทควบคุมทั้งหมด
                    pcall(function()
                        match.Input.AimLocked = true
                        match.Input.ChargeLocked = true
                        match.Input.Muted = true
                    end)

                    -- ตรวจสอบว่าแมตช์ โต๊ะ และ UI โหลดเสร็จสมบูรณ์ และเป็นเทิร์นของเราจริงที่ลูกหยุดนิ่งสนิทแล้ว
                    if isMatchFullyReady(match) and isMyTurn(match) and match.Simulation.Settled and match.Input.State ~= "Simulating" then
                        -- จัดการวางลูกขาวอัตโนมัติ (Ball-in-Hand / Free Ball Placement) สำหรับลูกปกติ
                        if match.Input.State == "BallInHand" or (match.Input.CanPlaceCueBall and match.Input.BallHeld) then
                            local mySeat = getMySeat(match)
                            local myGroup = getMyGroup(match, mySeat)
                            local planRules = {
                                Phase = match.Rules.Phase,
                                Turn = mySeat,
                                Groups = match.Rules.Groups or {},
                                Rules = match.Rules.Rules,
                            }
                            if myGroup and not planRules.Groups[mySeat] then
                                planRules.Groups[mySeat] = myGroup
                            end
                            local aiInstance = { Level = GOD_LEVEL, Random = Random.new(0) }
                            setmetatable(aiInstance, PoolAI)
                            local okSpot, bestSpot = pcall(function()
                                return PoolAI.PlaceCueBall(aiInstance, match.Simulation, planRules)
                            end)
                            if okSpot and bestSpot and typeof(bestSpot) == "Vector2" then
                                local cueBall = match.Simulation.Balls[PoolConstants.CueBallNumber]
                                if cueBall then
                                    cueBall.Position = bestSpot
                                    if match.View then
                                        pcall(function()
                                            PoolViewController.SetBall(match.View, PoolConstants.CueBallNumber, bestSpot)
                                        end)
                                    end
                                    match.Input.Dragging = false
                                    match.Input.BallHeld = false
                                    pcall(function()
                                        PoolInputController.SetState(match.Input, "Aiming")
                                    end)
                                    task.wait(0.3)
                                end
                            end
                        end

                        task.wait(SETTINGS.AutoPlayDelay)
                        -- ตรวจสอบซ้ำอีกครั้งหลังดีเลย์ เพื่อป้องกันยิงตอนเปลี่ยนเทิร์นหรือหมดเวลา
                        if autoPlayEnabled and isMatchFullyReady(match) and isMyTurn(match) and match.Simulation.Settled and match.Input.State ~= "Simulating" then
                            executeShoot(true)
                            task.wait(1.5)
                        end
                    end
                end
            end
        end
    end
end)



-- // KEYBIND & INPUT LISTENER //
safeConnect(UserInputService.InputBegan, function(input, gpe)
    if gpe then return end
    -- เมื่อคลิกเมาส์บนโต๊ะขณะไม่ได้เปิดออโต้ ให้ปลดล็อก Aim เพื่อให้ขยับไม้ไปเล็งลูกอื่นได้ทันที
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
        if not autoPlayEnabled and activeMatchClient and activeMatchClient.Input and activeMatchClient.Input.AimLocked then
            activeMatchClient.Input.AimLocked = false
        end
    end
    if input.KeyCode == KEYS.SnapAim then
        executeSnapAim(false)
    elseif input.KeyCode == KEYS.Shoot then
        executeShoot(false)
    elseif input.KeyCode == KEYS.AutoPlay then
        toggleAutoPlay()
    elseif input.KeyCode == KEYS.ToggleUI then
        if screenGui then
            if not screenGui.Enabled then
                screenGui.Enabled = true
                if badge then
                    badge.Position = UDim2.new(0.5, 0, 0.5, 0) -- เปิดกลับมาตรงกลางจอเสมอ
                    badge.Visible = true
                end
                if iconBtn then iconBtn.Visible = false end
            else
                screenGui.Enabled = false
            end
        end
    end
end)

-- // SLEEK CENTERED HUD WINDOW //
local oldHud = playerGui:FindFirstChild("PoolLiteHUD")
if oldHud then oldHud:Destroy() end

screenGui = Instance.new("ScreenGui")
screenGui.Name = "PoolLiteHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 2147483647
screenGui.Parent = playerGui

badge = Instance.new("Frame")
badge.Name = "Badge"
badge.AnchorPoint = Vector2.new(0.5, 0.5)
badge.Position = UDim2.new(0.5, 0, 0.5, 0)      -- เริ่มต้นอยู่กึ่งกลางจอ 100%
badge.Size = UDim2.new(0, 500, 0, 330)          -- ขยายขนาดใหญ่พิเศษ ชัดเจน สบายตา
badge.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
badge.BorderSizePixel = 0
badge.Active = true
badge.Draggable = true                         -- คลิกค้างแล้วลากย้ายตำแหน่งได้อิสระ
badge.ClipsDescendants = true
badge.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = badge

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(55, 65, 88)
stroke.Thickness = 1.8
stroke.Parent = badge

-- // FLOATING ICON BUTTON (เมื่อย่อหน้าต่างเป็นไอคอนลูกบอล 🎱) //
iconBtn = Instance.new("TextButton")
iconBtn.Name = "FloatIconBtn"
iconBtn.AnchorPoint = Vector2.new(0.5, 0.5)
iconBtn.Position = UDim2.new(0.92, 0, 0.35, 0)  -- ตำแหน่งไอคอนเริ่มต้น (ลากย้ายไปไว้ที่ไหนก็ได้)
iconBtn.Size = UDim2.new(0, 56, 0, 56)
iconBtn.BackgroundColor3 = Color3.fromRGB(18, 21, 30)
iconBtn.BorderSizePixel = 0
iconBtn.Text = "🎱"
iconBtn.TextSize = 28
iconBtn.Visible = false
iconBtn.Active = true
iconBtn.Draggable = true
iconBtn.Parent = screenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = iconBtn

local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(80, 140, 240)
iconStroke.Thickness = 2.5
iconStroke.Parent = iconBtn

local iconDot = Instance.new("Frame")
iconDot.Name = "BotDot"
iconDot.Size = UDim2.new(0, 13, 0, 13)
iconDot.Position = UDim2.new(1, -14, 0, 1)
iconDot.BackgroundColor3 = Color3.fromRGB(50, 255, 120)
iconDot.BorderSizePixel = 0
iconDot.Visible = false
iconDot.Parent = iconBtn

local iconDotCorner = Instance.new("UICorner")
iconDotCorner.CornerRadius = UDim.new(1, 0)
iconDotCorner.Parent = iconDot

-- เมื่อคลิกไอคอน จะเปิดหน้าต่างกลับมาตรงกลางจอเสมอ
safeConnect(iconBtn.MouseButton1Click, function()
    badge.Position = UDim2.new(0.5, 0, 0.5, 0) -- หน้าต่างอยู่กลางจอเสมอ 100%
    iconBtn.Visible = false
    badge.Visible = true
end)

-- // HEADER //
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "🎱 8 BALL DUELS | GOD MODE"
titleLabel.TextColor3 = Color3.fromRGB(245, 248, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Size = UDim2.new(1, -200, 0, 26)
titleLabel.Position = UDim2.new(0, 18, 0, 12)
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = badge

local subHint = Instance.new("TextLabel")
subHint.Text = "คลิกลากย้ายได้ • [X] ปิดสคริปต์ • [—] ย่อลูกบอล"
subHint.TextColor3 = Color3.fromRGB(135, 148, 172)
subHint.TextSize = 13
subHint.Font = Enum.Font.Gotham
subHint.Size = UDim2.new(1, -200, 0, 18)
subHint.Position = UDim2.new(0, 18, 0, 36)
subHint.BackgroundTransparency = 1
subHint.TextXAlignment = Enum.TextXAlignment.Left
subHint.Parent = badge

-- ปุ่มปิด/ทำลายสคริปต์ [X]
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -44, 0, 13)
closeBtn.BackgroundColor3 = Color3.fromRGB(48, 22, 26)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
closeBtn.Text = "X"
closeBtn.Parent = badge

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = Color3.fromRGB(110, 40, 50)
closeStroke.Thickness = 1
closeStroke.Parent = closeBtn

safeConnect(closeBtn.MouseButton1Click, function()
    killScript("ผู้ใช้กดปุ่ม [X] ปิดและทำลายสคริปต์ (Manual Kill)")
end)

-- ปุ่มย่อเป็นไอคอน [—]
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinBtn"
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -82, 0, 13)
minBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
minBtn.BorderSizePixel = 0
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.TextColor3 = Color3.fromRGB(200, 215, 245)
minBtn.Text = "—"
minBtn.Parent = badge

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

local minStroke = Instance.new("UIStroke")
minStroke.Color = Color3.fromRGB(60, 72, 95)
minStroke.Thickness = 1
minStroke.Parent = minBtn

safeConnect(minBtn.MouseButton1Click, function()
    badge.Visible = false
    iconBtn.Visible = true
    notify("🎱 Pool Lite", "ย่อเป็นไอคอนแล้ว (คลิกที่ลูกบอล 🎱 เพื่อเปิดหน้าต่างกลางจอ)")
end)

-- ปุ่มดึงกลับกึ่งกลางจอ [🎯]
local centerBtn = Instance.new("TextButton")
centerBtn.Name = "CenterBtn"
centerBtn.Size = UDim2.new(0, 32, 0, 32)
centerBtn.Position = UDim2.new(1, -120, 0, 13)
centerBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
centerBtn.BorderSizePixel = 0
centerBtn.Font = Enum.Font.GothamBold
centerBtn.TextSize = 16
centerBtn.TextColor3 = Color3.fromRGB(200, 215, 245)
centerBtn.Text = "🎯"
centerBtn.Parent = badge

local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(0, 8)
centerCorner.Parent = centerBtn

local centerStroke = Instance.new("UIStroke")
centerStroke.Color = Color3.fromRGB(60, 72, 95)
centerStroke.Thickness = 1
centerStroke.Parent = centerBtn

safeConnect(centerBtn.MouseButton1Click, function()
    badge.Position = UDim2.new(0.5, 0, 0.5, 0)
    notify("🎱 Pool Lite", "ย้ายหน้าต่างกลับมาตรงกลางจอเรียบร้อยแล้ว")
end)

-- ปุ่มรีจอยเซิร์ฟเวอร์ด่วนบนหัวหน้าต่าง [🔄]
local rejoinTopBtn = Instance.new("TextButton")
rejoinTopBtn.Name = "RejoinTopBtn"
rejoinTopBtn.Size = UDim2.new(0, 32, 0, 32)
rejoinTopBtn.Position = UDim2.new(1, -158, 0, 13)
rejoinTopBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
rejoinTopBtn.BorderSizePixel = 0
rejoinTopBtn.Font = Enum.Font.GothamBold
rejoinTopBtn.TextSize = 16
rejoinTopBtn.TextColor3 = Color3.fromRGB(200, 215, 245)
rejoinTopBtn.Text = "🔄"
rejoinTopBtn.Parent = badge

local rejoinTopCorner = Instance.new("UICorner")
rejoinTopCorner.CornerRadius = UDim.new(0, 8)
rejoinTopCorner.Parent = rejoinTopBtn

local rejoinTopStroke = Instance.new("UIStroke")
rejoinTopStroke.Color = Color3.fromRGB(60, 72, 95)
rejoinTopStroke.Thickness = 1
rejoinTopStroke.Parent = rejoinTopBtn

safeConnect(rejoinTopBtn.MouseButton1Click, function()
    executeRejoin()
end)

-- // BODY CONTAINER //
local bodyFrame = Instance.new("Frame")
bodyFrame.Name = "BodyFrame"
bodyFrame.BackgroundTransparency = 1
bodyFrame.Size = UDim2.new(1, 0, 1, -60)
bodyFrame.Position = UDim2.new(0, 0, 0, 60)
bodyFrame.Parent = badge

-- ปุ่มกด [E] ล็อกเป้า (คลิกเมาส์ หรือกด E)
local snapBtn = Instance.new("TextButton")
snapBtn.Name = "SnapBtn"
snapBtn.Size = UDim2.new(0.5, -24, 0, 50)
snapBtn.Position = UDim2.new(0, 18, 0, 4)
snapBtn.BackgroundColor3 = Color3.fromRGB(26, 34, 48)
snapBtn.BorderSizePixel = 0
snapBtn.Font = Enum.Font.GothamBold
snapBtn.TextSize = 16
snapBtn.TextColor3 = Color3.fromRGB(220, 235, 255)
snapBtn.Text = "🎯 [E] ล็อกเป้า God Mode"
snapBtn.Parent = bodyFrame

local snapCorner = Instance.new("UICorner")
snapCorner.CornerRadius = UDim.new(0, 8)
snapCorner.Parent = snapBtn

local snapStroke = Instance.new("UIStroke")
snapStroke.Color = Color3.fromRGB(50, 75, 115)
snapStroke.Thickness = 1.2
snapStroke.Parent = snapBtn

safeConnect(snapBtn.MouseButton1Click, function()
    executeSnapAim(false)
end)

-- ปุ่มกด [R] กดยิง (คลิกเมาส์ หรือกด R)
local shootBtn = Instance.new("TextButton")
shootBtn.Name = "ShootBtn"
shootBtn.Size = UDim2.new(0.5, -24, 0, 50)
shootBtn.Position = UDim2.new(0.5, 6, 0, 4)
shootBtn.BackgroundColor3 = Color3.fromRGB(38, 33, 20)
shootBtn.BorderSizePixel = 0
shootBtn.Font = Enum.Font.GothamBold
shootBtn.TextSize = 16
shootBtn.TextColor3 = Color3.fromRGB(255, 215, 80)
shootBtn.Text = "⚡ [R] กดยิงลงหลุม"
shootBtn.Parent = bodyFrame

local shootCorner = Instance.new("UICorner")
shootCorner.CornerRadius = UDim.new(0, 8)
shootCorner.Parent = shootBtn

local shootStroke = Instance.new("UIStroke")
shootStroke.Color = Color3.fromRGB(110, 85, 30)
shootStroke.Thickness = 1.2
shootStroke.Parent = shootBtn

safeConnect(shootBtn.MouseButton1Click, function()
    executeShoot(false)
end)

-- ปุ่มเปิด/ปิด บอทเล่นอัตโนมัติ [A]
local autoBtn = Instance.new("TextButton")
autoBtn.Name = "AutoBtn"
autoBtn.Size = UDim2.new(1, -36, 0, 52)
autoBtn.Position = UDim2.new(0, 18, 0, 60)
autoBtn.BackgroundColor3 = Color3.fromRGB(28, 22, 25)
autoBtn.BorderSizePixel = 0
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 16
autoBtn.TextColor3 = Color3.fromRGB(255, 95, 95)
autoBtn.Text = "🤖 [A] บอทเล่นอัตโนมัติ: ปิด (OFF)"
autoBtn.Parent = bodyFrame

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 8)
autoCorner.Parent = autoBtn

local autoStroke = Instance.new("UIStroke")
autoStroke.Color = Color3.fromRGB(90, 45, 52)
autoStroke.Thickness = 1.2
autoStroke.Parent = autoBtn

updateHudBadge = function()
    if autoPlayEnabled then
        autoBtn.BackgroundColor3 = Color3.fromRGB(16, 38, 26)
        autoBtn.TextColor3 = Color3.fromRGB(60, 255, 140)
        autoStroke.Color = Color3.fromRGB(35, 160, 80)
        autoBtn.Text = "⚡ [A] บอทเล่นอัตโนมัติ: เปิด (ON - ระดับ God Mode)"
        iconDot.Visible = true
        iconStroke.Color = Color3.fromRGB(40, 180, 90)
    else
        autoBtn.BackgroundColor3 = Color3.fromRGB(28, 22, 25)
        autoBtn.TextColor3 = Color3.fromRGB(255, 95, 95)
        autoStroke.Color = Color3.fromRGB(90, 45, 52)
        autoBtn.Text = "🤖 [A] บอทเล่นอัตโนมัติ: ปิด (OFF)"
        iconDot.Visible = false
        iconStroke.Color = Color3.fromRGB(65, 80, 115)
    end
end

safeConnect(autoBtn.MouseButton1Click, function()
    toggleAutoPlay()
end)

-- // แถบเลือกจำนวนเส้นชิ่ง (0, 1, 2, 3 ชิ่ง) //
local bounceRow = Instance.new("Frame")
bounceRow.Name = "BounceRow"
bounceRow.Size = UDim2.new(1, -36, 0, 44)
bounceRow.Position = UDim2.new(0, 18, 0, 118)
bounceRow.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
bounceRow.BorderSizePixel = 0
bounceRow.Parent = bodyFrame

local bounceRowCorner = Instance.new("UICorner")
bounceRowCorner.CornerRadius = UDim.new(0, 8)
bounceRowCorner.Parent = bounceRow

local bounceRowStroke = Instance.new("UIStroke")
bounceRowStroke.Color = Color3.fromRGB(45, 54, 74)
bounceRowStroke.Thickness = 1
bounceRowStroke.Parent = bounceRow

local bounceLabel = Instance.new("TextLabel")
bounceLabel.Text = "🎱 แสดงเส้นชิ่ง:"
bounceLabel.TextColor3 = Color3.fromRGB(225, 235, 250)
bounceLabel.TextSize = 14
bounceLabel.Font = Enum.Font.GothamBold
bounceLabel.Size = UDim2.new(0, 120, 1, 0)
bounceLabel.Position = UDim2.new(0, 12, 0, 0)
bounceLabel.BackgroundTransparency = 1
bounceLabel.TextXAlignment = Enum.TextXAlignment.Left
bounceLabel.Parent = bounceRow

local bounceBtns = {}
local bounceOptions = {
    { val = 0, text = "ปิด (0)" },
    { val = 1, text = "1 ชิ่ง" },
    { val = 2, text = "2 ชิ่ง" },
    { val = 3, text = "3 ชิ่ง" }
}

local function updateBounceUI()
    for val, btn in pairs(bounceBtns) do
        local isSelected = (SETTINGS.MaxBounces == val)
        local bStroke = btn:FindFirstChild("UIStroke")
        if isSelected then
            btn.BackgroundColor3 = Color3.fromRGB(35, 75, 135)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            if bStroke then
                bStroke.Color = Color3.fromRGB(80, 150, 255)
                bStroke.Thickness = 1.5
            end
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
            btn.TextColor3 = Color3.fromRGB(145, 155, 175)
            btn.Font = Enum.Font.GothamMedium
            if bStroke then
                bStroke.Color = Color3.fromRGB(45, 52, 70)
                bStroke.Thickness = 1
            end
        end
    end
end

for i, opt in ipairs(bounceOptions) do
    local bBtn = Instance.new("TextButton")
    bBtn.Name = "BounceBtn_" .. opt.val
    bBtn.Size = UDim2.new(0, 74, 0, 32)
    bBtn.Position = UDim2.new(0, 132 + (i - 1) * 80, 0, 6)
    bBtn.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
    bBtn.BorderSizePixel = 0
    bBtn.Text = opt.text
    bBtn.TextSize = 13
    bBtn.TextColor3 = Color3.fromRGB(145, 155, 175)
    bBtn.Font = Enum.Font.GothamMedium
    bBtn.Parent = bounceRow

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = bBtn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(45, 52, 70)
    bStroke.Thickness = 1
    bStroke.Parent = bBtn

    safeConnect(bBtn.MouseButton1Click, function()
        SETTINGS.MaxBounces = opt.val
        updateBounceUI()
        notify("🎱 เส้นชิ่ง", "ตั้งค่าแสดงเส้นชิ่ง: " .. opt.text)
    end)

    bounceBtns[opt.val] = bBtn
end

updateBounceUI()

-- ปุ่มกดรีจอยเซิร์ฟเวอร์ [🔄 Rejoin Server]
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Name = "RejoinBtn"
rejoinBtn.Size = UDim2.new(1, -36, 0, 42)
rejoinBtn.Position = UDim2.new(0, 18, 0, 170)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(20, 27, 40)
rejoinBtn.BorderSizePixel = 0
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.TextSize = 15
rejoinBtn.TextColor3 = Color3.fromRGB(150, 200, 255)
rejoinBtn.Text = "🔄 รีจอยเซิร์ฟเวอร์ (Rejoin Server)"
rejoinBtn.Parent = bodyFrame

local rejoinCorner = Instance.new("UICorner")
rejoinCorner.CornerRadius = UDim.new(0, 8)
rejoinCorner.Parent = rejoinBtn

local rejoinStroke = Instance.new("UIStroke")
rejoinStroke.Color = Color3.fromRGB(45, 65, 100)
rejoinStroke.Thickness = 1.2
rejoinStroke.Parent = rejoinBtn

safeConnect(rejoinBtn.MouseButton1Click, function()
    executeRejoin()
end)

-- คำอธิบายสัญลักษณ์เส้น
local legendLabel = Instance.new("TextLabel")
legendLabel.Text = "⚪ เส้นขาว: ลูกขาว | ⚫ เส้นดำ: ลูกสี (ปิดการแสดงเส้นอัตโนมัติเมื่อบอททำงาน)"
legendLabel.TextColor3 = Color3.fromRGB(165, 175, 195)
legendLabel.TextSize = 13
legendLabel.Font = Enum.Font.GothamMedium
legendLabel.Size = UDim2.new(1, -36, 0, 30)
legendLabel.Position = UDim2.new(0, 18, 0, 220)
legendLabel.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
legendLabel.BorderSizePixel = 0
legendLabel.TextXAlignment = Enum.TextXAlignment.Center
legendLabel.Parent = bodyFrame

local legCorner = Instance.new("UICorner")
legCorner.CornerRadius = UDim.new(0, 6)
legCorner.Parent = legendLabel

notify("⚡ Pool God Mode พร้อมใช้งาน", "หน้าต่างอยู่กลางจอ | [E] ล็อกเป้า | [R] ยิง | [A] บอท God Mode | [H] ซ่อน")
warn("🎱 [Pool God Mode] Loaded! Zero-Error Auto Play, Auto Ball-in-Hand, Apex Break & Line Disabling Active.")
