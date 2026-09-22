-- ==============================================================================
-- 🎱 8 BALL DUELS (การดวล 8 ลูก) - LITE ASSISTANT
-- Features: Thin White/Black Guide & Bank Lines, Smart Snap Aim, Auto Shoot, Legend Bot Toggle
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

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
    AutoPlayDelay = 0.6,           -- หน่วงเวลาก่อนบอทยิง (วินาที)
}

local autoPlayEnabled = false

-- // GAME SPECIFIC MODULES //
local Libraries = ReplicatedStorage:WaitForChild("Libraries")
local GameSpecific = Libraries:WaitForChild("GameSpecific")
local PoolFolder = GameSpecific:WaitForChild("Pool")

local PoolAI = require(PoolFolder:WaitForChild("PoolAI"))
local PoolPhysics = require(PoolFolder:WaitForChild("PoolPhysics"))
local PoolGeometry = require(PoolFolder:WaitForChild("PoolGeometry"))
local PoolConstants = require(PoolFolder:WaitForChild("PoolConstants"))
local PoolAimOverlay = require(PoolFolder:WaitForChild("PoolAimOverlay"))
local PoolInputController = require(PoolFolder:WaitForChild("PoolInputController"))
local PoolMatchClient = require(PoolFolder:WaitForChild("PoolMatchClient"))

local cushions = PoolGeometry.GetCushions()
local pockets = PoolGeometry.GetPockets()
local ballRadius = PoolConstants.BallRadius
local ballDiameter = PoolConstants.BallDiameter
local FrameWidth = PoolConstants.FrameWidth
local FrameHeight = PoolConstants.FrameHeight

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

-- // ACTIVE MATCH DETECTION //
local currentMatch = nil

local function getActiveMatch()
    if currentMatch and currentMatch.Input and currentMatch.Simulation and currentMatch.Overlay then
        return currentMatch
    end
    local inputObj, rulesObj, simObj, clientMatch
    pcall(function()
        for _, fn in ipairs(getgc()) do
            if type(fn) == "function" and islclosure(fn) then
                local info = debug.getinfo(fn)
                if info.source and (info.source:find("PoolGameUIHandler") or info.source:find("PoolMatchClient")) then
                    local okUv, uvs = pcall(debug.getupvalues, fn)
                    if okUv and uvs then
                        for _, v in pairs(uvs) do
                            if type(v) == "table" then
                                if v.Simulation and v.Overlay and v.ShotBindable then
                                    inputObj = v
                                end
                                if v.Turn ~= nil and v.Phase ~= nil and v.Groups ~= nil then
                                    rulesObj = v
                                end
                                if v.Balls and v.Settled ~= nil and v.Elapsed ~= nil then
                                    simObj = v
                                end
                                if v.Seat and v.Replica and v.Simulation then
                                    clientMatch = v
                                end
                            end
                        end
                    end
                end
            end
            if inputObj and rulesObj then break end
        end
    end)
    if inputObj then
        currentMatch = {
            Input = inputObj,
            Simulation = inputObj.Simulation or simObj,
            Overlay = inputObj.Overlay,
            Rules = rulesObj or { Turn = 1, Phase = "Assigned", Groups = {"Solid", "Stripe"} },
            Seat = (clientMatch and clientMatch.Seat) or (rulesObj and rulesObj.Turn) or 1
        }
        return currentMatch
    elseif clientMatch then
        currentMatch = clientMatch
        return clientMatch
    end
    return nil
end

local oldMatchClientNew = PoolMatchClient.new
PoolMatchClient.new = function(...)
    local match = oldMatchClientNew(...)
    currentMatch = match
    return match
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

local oldOverlayUpdate = PoolAimOverlay.Update
PoolAimOverlay.Update = function(self, p2, p3, p4, p5, p6, p7)
    p6 = SETTINGS.GuideLength
    self.GuidesEnabled = true
    
    local res = oldOverlayUpdate(self, p2, p3, p4, p5, p6, p7)
    local root = self.Root
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

    -- เส้นชิ่งลูกสี (สีดำ)
    local bankObj1 = getOrCreateLine(root, "LiteBankObj1", COLOR_BLACK, 50)
    local bankObj2 = getOrCreateLine(root, "LiteBankObj2", COLOR_BLACK, 50)
    local bankObj3 = getOrCreateLine(root, "LiteBankObj3", COLOR_BLACK, 50)
    -- เส้นชิ่งลูกขาว (สีขาว)
    local bankCue1 = getOrCreateLine(root, "LiteBankCue1", COLOR_WHITE, 50)
    local bankCue2 = getOrCreateLine(root, "LiteBankCue2", COLOR_WHITE, 50)
    local bankCue3 = getOrCreateLine(root, "LiteBankCue3", COLOR_WHITE, 50)
    local bankDeflect = getOrCreateLine(root, "LiteBankDeflect", COLOR_WHITE, 50)

    local function hideBanks()
        bankObj1.Visible = false
        bankObj2.Visible = false
        bankObj3.Visible = false
        bankCue1.Visible = false
        bankCue2.Visible = false
        bankCue3.Visible = false
        bankDeflect.Visible = false
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

-- // 2. SMART SNAP AIM (คำนวณมุมที่ดีที่สุดด้วย Legend AI) //
local function calculateBestShot(simulation, rules, seat)
    if not simulation or not rules then return nil end
    local levelData = PoolAI.GetLevel("Legend")
    local aiInstance = { Level = levelData, Random = Random.new() }
    setmetatable(aiInstance, PoolAI)
    local ok, plan = pcall(function()
        return PoolAI.Plan(aiInstance, simulation, rules, seat or (rules and rules.Turn) or 1)
    end)
    if ok and plan and plan.Choice then
        return plan.Choice
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
    local match = getActiveMatch()
    if not match or not match.Input or not match.Simulation or not match.Rules then
        if not silent then notify("8 Ball Duels", "⚠️ ไม่พบโต๊ะที่กำลังเล่นอยู่") end
        return false
    end
    local choice = calculateBestShot(match.Simulation, match.Rules, match.Seat)
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
        local pct = math.floor((choice.Quality or 0.8) * 100)
        notify("🎯 Target Locked!", string.format("เล็งลูก: #%s | หลุม: %s (%d%%)", tostring(targetNum), tostring(pocketName), pct))
    end
    return true, choice
end

-- // 3. AUTO SHOOT (กดยิงทันที คำนวณความแรงอัตโนมัติ) //
local function executeShoot()
    local match = getActiveMatch()
    if not match or not match.Input then return false end
    local ok, choice = executeSnapAim(true)
    if ok and choice then
        pcall(function()
            local power = math.clamp(choice.Power or 0.7, 0.2, 1)
            PoolInputController.SetPower(match.Input, power)
        end)
        task.wait(0.12)
        pcall(function()
            local spin = (match.Input.Hud and match.Input.Hud.Spin) or Vector2.zero
            local power = math.clamp(choice.Power or 0.7, 0.2, 1)
            if match.Input.ShotBindable then
                match.Input.ShotBindable:Fire(choice.Direction, power, spin)
            end
        end)
        task.wait(0.1)
        -- คืนค่าไม้และปลดล็อกทันทีหลังยิง ไม่ให้ไม้ค้างในเพสยิง
        resetAimState(match)
        notify("🎱 Potted!", "ยิงเรียบร้อยแล้ว!")
        return true
    end
    return false
end

-- // 4. AUTO PLAY TOGGLE (บอทตัวตึง Legend เล่นให้อัตโนมัติ) //
local updateHudBadge = function() end

local function toggleAutoPlay()
    autoPlayEnabled = not autoPlayEnabled
    notify("บอทเล่นอัตโนมัติ 🤖", autoPlayEnabled and "🟢 เปิดใช้งาน (ตัวตึง Legend)" or "🔴 ปิดการทำงาน (คืนการควบคุมไม้)")
    updateHudBadge()
    if not autoPlayEnabled then
        -- เมื่อปิดออโต้ ให้คืนการควบคุมไม้ทันที ปลดล็อกและรีเซ็ตเพสยิง
        resetAimState()
    end
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if autoPlayEnabled then
            local match = getActiveMatch()
            if match and match.Input and match.Rules then
                local isMyTurn = false
                if match.Input.State == "Aiming" and not match.Input.Muted then
                    isMyTurn = true
                elseif match.Seat and (match.Rules.Turn == match.Seat) then
                    isMyTurn = true
                end
                if isMyTurn and match.Simulation and match.Simulation.Settled then
                    task.wait(SETTINGS.AutoPlayDelay)
                    executeShoot()
                    task.wait(3.0)
                end
            end
        end
    end
end)

-- // KEYBIND & INPUT LISTENER //
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    -- เมื่อคลิกเมาส์บนโต๊ะขณะไม่ได้เปิดออโต้ ให้ปลดล็อก Aim เพื่อให้ขยับไม้ไปเล็งลูกอื่นได้ทันที
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
        if not autoPlayEnabled then
            local match = getActiveMatch()
            if match and match.Input and match.Input.AimLocked then
                match.Input.AimLocked = false
            end
        end
    end
    if input.KeyCode == KEYS.SnapAim then
        executeSnapAim(false)
    elseif input.KeyCode == KEYS.Shoot then
        executeShoot()
    elseif input.KeyCode == KEYS.AutoPlay then
        toggleAutoPlay()
    elseif input.KeyCode == KEYS.ToggleUI then
        if screenGui then
            if not screenGui.Enabled then
                screenGui.Enabled = true
                badge.Position = UDim2.new(0.5, 0, 0.5, 0) -- เปิดกลับมาตรงกลางจอเสมอ
                badge.Visible = true
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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PoolLiteHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local badge = Instance.new("Frame")
badge.Name = "Badge"
badge.AnchorPoint = Vector2.new(0.5, 0.5)
badge.Position = UDim2.new(0.5, 0, 0.5, 0)      -- เริ่มต้นอยู่กึ่งกลางจอ 100%
badge.Size = UDim2.new(0, 500, 0, 280)          -- ขยายขนาดใหญ่พิเศษ ชัดเจน สบายตา
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
local iconBtn = Instance.new("TextButton")
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
iconBtn.MouseButton1Click:Connect(function()
    badge.Position = UDim2.new(0.5, 0, 0.5, 0) -- หน้าต่างอยู่กลางจอเสมอ 100%
    iconBtn.Visible = false
    badge.Visible = true
end)

-- // HEADER //
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "🎱 8 BALL DUELS | PRO LITE"
titleLabel.TextColor3 = Color3.fromRGB(245, 248, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Size = UDim2.new(1, -150, 0, 26)
titleLabel.Position = UDim2.new(0, 18, 0, 12)
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = badge

local subHint = Instance.new("TextLabel")
subHint.Text = "คลิกลากย้ายได้ • กด [H] เพื่อซ่อน/แสดงหน้าต่าง"
subHint.TextColor3 = Color3.fromRGB(135, 148, 172)
subHint.TextSize = 13
subHint.Font = Enum.Font.Gotham
subHint.Size = UDim2.new(1, -150, 0, 18)
subHint.Position = UDim2.new(0, 18, 0, 36)
subHint.BackgroundTransparency = 1
subHint.TextXAlignment = Enum.TextXAlignment.Left
subHint.Parent = badge

-- ปุ่มดึงกลับกึ่งกลางจอ [🎯]
local centerBtn = Instance.new("TextButton")
centerBtn.Name = "CenterBtn"
centerBtn.Size = UDim2.new(0, 34, 0, 34)
centerBtn.Position = UDim2.new(1, -92, 0, 12)
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

centerBtn.MouseButton1Click:Connect(function()
    badge.Position = UDim2.new(0.5, 0, 0.5, 0)
    notify("🎱 Pool Lite", "ย้ายหน้าต่างกลับมาตรงกลางจอเรียบร้อยแล้ว")
end)

-- ปุ่มย่อเป็นไอคอน [—]
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinBtn"
minBtn.Size = UDim2.new(0, 34, 0, 34)
minBtn.Position = UDim2.new(1, -48, 0, 12)
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

minBtn.MouseButton1Click:Connect(function()
    badge.Visible = false
    iconBtn.Visible = true
    notify("🎱 Pool Lite", "ย่อเป็นไอคอนแล้ว (คลิกที่ลูกบอล 🎱 เพื่อเปิดหน้าต่างกลางจอ)")
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
snapBtn.Text = "🎯 [E] ล็อกเป้าดีที่สุด"
snapBtn.Parent = bodyFrame

local snapCorner = Instance.new("UICorner")
snapCorner.CornerRadius = UDim.new(0, 8)
snapCorner.Parent = snapBtn

local snapStroke = Instance.new("UIStroke")
snapStroke.Color = Color3.fromRGB(50, 75, 115)
snapStroke.Thickness = 1.2
snapStroke.Parent = snapBtn

snapBtn.MouseButton1Click:Connect(function()
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

shootBtn.MouseButton1Click:Connect(function()
    executeShoot()
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
        autoBtn.Text = "🏆 [A] บอทเล่นอัตโนมัติ: เปิด (ON - ตัวตึง Legend)"
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

autoBtn.MouseButton1Click:Connect(function()
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

    bBtn.MouseButton1Click:Connect(function()
        SETTINGS.MaxBounces = opt.val
        updateBounceUI()
        notify("🎱 เส้นชิ่ง", "ตั้งค่าแสดงเส้นชิ่ง: " .. opt.text)
    end)

    bounceBtns[opt.val] = bBtn
end

updateBounceUI()

-- คำอธิบายสัญลักษณ์เส้น
local legendLabel = Instance.new("TextLabel")
legendLabel.Text = "⚪ เส้นขาว: ลูกขาว   |   ⚫ เส้นดำ: ลูกสี (คำนวณเส้นชิ่งอัตโนมัติ)"
legendLabel.TextColor3 = Color3.fromRGB(165, 175, 195)
legendLabel.TextSize = 13
legendLabel.Font = Enum.Font.GothamMedium
legendLabel.Size = UDim2.new(1, -36, 0, 30)
legendLabel.Position = UDim2.new(0, 18, 0, 170)
legendLabel.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
legendLabel.BorderSizePixel = 0
legendLabel.TextXAlignment = Enum.TextXAlignment.Center
legendLabel.Parent = bodyFrame

local legCorner = Instance.new("UICorner")
legCorner.CornerRadius = UDim.new(0, 6)
legCorner.Parent = legendLabel

notify("🎱 Pool Lite พร้อมใช้งาน", "หน้าต่างอยู่กลางจอ | [E] เล็ง | [R] ยิง | [A] บอท | [H] ซ่อน")
warn("🎱 [Pool Lite] Large Centered UI Loaded! Keys: E (Aim), R (Shoot), A (Auto-Play), H (Toggle UI)")
