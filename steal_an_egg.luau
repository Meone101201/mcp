local P, z, Y, X, o, M =
    game:GetService("Players"),
    game:GetService("ReplicatedStorage"),
    game:GetService("RunService"),
    game:GetService("TweenService"),
    game:GetService("ProximityPromptService"),
    game:GetService("UserInputService")
if _G._EggStealerSession then
    pcall(function()
        _G._EggStealerSession.running = false
        _G._EggStealerSession.alive = false
        _G._EggStealerSession.holdingForGuard = false
    end)
end
if _G._EggStealerGui then
    pcall(function()
        _G._EggStealerGui:Destroy()
    end)
end
_G._EggStealerRunning = false
local S = P.LocalPlayer
local W = S:WaitForChild("PlayerGui", 10)
pcall(function()
    local a = W:FindFirstChild("EggStealerUI")
    if a then
        a:Destroy()
    end
end)
pcall(function()
    o.PromptButtonHoldBegan:Connect(function(a)
        pcall(function()
            if typeof(fireproximityprompt) == "function" then
                fireproximityprompt(a)
            end
        end)
    end)
end)
if typeof(hookmetamethod) == "function" and not _G._EggStealerAntiRagdollHooked then
    _G._EggStealerAntiRagdollHooked = true
    local a
    a = hookmetamethod(
        game,
        "__newindex",
        newcclosure(function(b, c, d)
            if not checkcaller() and typeof(b) == "Instance" then
                if b:IsA("Motor6D") and (c == "Enabled" and d == false) then
                    return nil
                end
                if b:IsA("Humanoid") then
                    if (c == "PlatformStand" and d == true) or (c == "Sit" and d == true) then
                        return nil
                    end
                end
            end
            return a(b, c, d)
        end)
    )
end
local function n(a)
    local b = require
    local c, d = pcall(function()
        return b(a)
    end)
    return c and d or nil
end
local _e = (z:FindFirstChild("Client") and z.Client:FindFirstChild("EggState")) or z:FindFirstChild("EggState", true)
_e = _e and n(_e) or nil
local e = _e
local v = (
    z:FindFirstChild("Shared")
    and z.Shared:FindFirstChild("Util")
    and z.Shared.Util:FindFirstChild("AssetItems")
) or z:FindFirstChild("AssetItems", true)
v = v and n(v) or nil
local _t = (
    z:FindFirstChild("Shared")
    and z.Shared:FindFirstChild("Eggs")
    and z.Shared.Eggs:FindFirstChild("EggToolDisplay")
) or z:FindFirstChild("EggToolDisplay", true)
_t = _t and n(_t) or nil
local f = _t
local _p = (z:FindFirstChild("Client") and z.Client:FindFirstChild("PlotState")) or z:FindFirstChild("PlotState", true)
_p = _p and n(_p) or nil
local i = _p
local q = (z:FindFirstChild("Packages") and z.Packages:FindFirstChild("Networking")) or z:FindFirstChild("Network") or z
local function K(a, b)
    local c = q:FindFirstChild(a) or z:FindFirstChild(a)
    if c then
        return c
    end
    c = q:FindFirstChild(a, true) or z:FindFirstChild(a, true)
    if c then
        return c
    end
    if b then
        c = q:FindFirstChild(b, true) or z:FindFirstChild(b, true)
        if c then
            return c
        end
    end
    local d = string.match(a, "[^/]+$")
    if d then
        c = q:FindFirstChild(d, true) or z:FindFirstChild(d, true)
        if c then
            return c
        end
    end
    return nil
end
local C = K("RF/EggWorld/AskPlaceEgg", "AskPlaceEgg")
local D = K("RF/EggWorld/AskLiveSnapshot", "AskLiveSnapshot")
local k = K("RF/EggWorld/AskFieldEggCarry", "AskFieldEggCarry")
local y = K("RF/EggWorld/AskFieldEggSnapshot", "AskFieldEggSnapshot") or K("Eggs: RequestAreaEggSnapshot")
local A = K("RF/EggWorld/AskHatch", "AskHatch") or K("Eggs: RequestHatchEgg")
local p = K("RF/EggWorld/AskFinishHatch", "AskFinishHatch") or K("Eggs: RequestCompleteHatchEgg")
local T = K("RE/GuardPatrol/ForestStrike", "ForestStrike")
local B = K("RF/Treadmill/AskDoff", "AskDoff")
local _s = {
    running = false,
    alive = true,
    speed = 950,
    baseSpeed = 130,
    rampEndX = 620,
    fieldBoundX = 525,
    laneZ = -364.5,
    fieldLaneZ = -364.5,
    plotZ = nil,
    plotX = nil,
    plotId = nil,
    selected = {},
    selectedZones = {},
    selectedRarities = {},
    filterMode = "ZONE",
    stolenCount = 0,
    plotData = nil,
    swapped = false,
    holdingForGuard = false,
}
local l = _s
_G._EggStealerSession = _s
local u, r, V, O, m, b, c
local L = {
    "Forest",
    "Lake",
    "Desert",
    "Jungle",
    "Snow",
    "Volcano",
    "Abyss Ocean",
    "Prehistoric",
    "Cosmic",
    "Cherry Blossom",
    "Titan Temple",
    "Light Dark",
}
local Z = { "Divine", "Eternal", "Secret", "Cosmic", "Mythic", "Legendary", "Epic", "Rare" }
local x = "⏸ Ready"
local function _msg(a)
    x = tostring(a)
end
local G = {}
local function E(a)
    if not a then
        return false
    end
    local b = G[tostring(a)]
    return b and (os.clock() < b)
end
local function R(a, b)
    if not a then
        return
    end
    G[tostring(a)] = os.clock() + (b or 20)
end
local function U()
    G = {}
end
local function _h()
    local a = S.Character
    return a and a:FindFirstChild("HumanoidRootPart")
end
local function _j(a, b)
    b = b or 8
    local c = Instance.new("Part")
    c.Name = "SafetyFloorPad_AntiVoid"
    c.Size = Vector3.new(28, 1.5, 28)
    c.Position = a - Vector3.new(0, 3.2, 0)
    c.Anchored = true
    c.Transparency = 1
    c.CanCollide = true
    c.Parent = workspace
    task.delay(b, function()
        pcall(function()
            c:Destroy()
        end)
    end)
    return c
end
local function _d(a)
    a = a or S.Character
    if not a then
        return
    end
    for b, c in ipairs(a:GetDescendants()) do
        if c:IsA("BallSocketConstraint") or c:IsA("HingeConstraint") or c:IsA("NoCollisionConstraint") then
            pcall(function()
                c:Destroy()
            end)
        end
    end
    for b, c in ipairs(a:GetDescendants()) do
        if c:IsA("Motor6D") and (c.Part0 and c.Part1) then
            c.Enabled = true
            local d = "RigidJointWeld_" .. c.Name
            local e = c.Part1:FindFirstChild(d)
            if not e then
                local f = Instance.new("WeldConstraint")
                f.Name = d
                f.Part0 = c.Part0
                f.Part1 = c.Part1
                f.Parent = c.Part1
            end
        end
    end
    local b = a:FindFirstChildOfClass("Humanoid")
    if b then
        b:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        b:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        b:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        b:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        b:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        b.PlatformStand = false
        b.Sit = false
    end
    for c, d in ipairs(a:GetDescendants()) do
        if d:IsA("LocalScript") and (string.find(d.Name:lower(), "ragdoll") or string.find(d.Name:lower(), "fall")) then
            d.Disabled = true
        end
    end
end
local function _g(a)
    a = a or S.Character
    if not a then
        return
    end
    for b, c in ipairs(a:GetDescendants()) do
        if c:IsA("WeldConstraint") and c.Name:find("RigidJointWeld_") then
            pcall(function()
                c:Destroy()
            end)
        end
        if c:IsA("BasePart") then
            c.CanTouch = true
            c.CanCollide = true
        end
    end
    local b = a:FindFirstChildOfClass("Humanoid")
    if b then
        b.PlatformStand = false
        b.Sit = false
        b.AutoRotate = true
        pcall(function()
            b:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end
local function _m(a)
    a = a or S.Character
    if not a then
        return
    end
    local b = a:FindFirstChildOfClass("Humanoid")
    if b then
        b:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if b.Health < 100 then
            b.Health = 100
        end
    end
    for c, d in ipairs(a:GetDescendants()) do
        if d:IsA("BasePart") then
            d.CanTouch = false
            d.CanCollide = false
        end
    end
    _d(a)
end
local function _w()
    local a = S.Character
    local b = a and a:FindFirstChildOfClass("Humanoid")
    if not a or not b then
        return false
    end
    pcall(function()
        b.BreakJointsOnDeath = false
        local c = b:Clone()
        c.Parent = a
        b:Destroy()
        local d = c:FindFirstChildOfClass("Animator")
        if not d then
            d = Instance.new("Animator")
            d.Parent = c
        end
        workspace.CurrentCamera.CameraSubject = c
        local e = a:FindFirstChild("Animate")
        if e and e:IsA("LocalScript") then
            e.Disabled = true
            task.defer(function()
                task.wait(0.05)
                e.Disabled = false
            end)
        end
        c:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        c:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        c:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        c:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        c:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        c.JumpPower = math.max(50, c.JumpPower)
        c.JumpHeight = math.max(7.2, c.JumpHeight)
        c:ChangeState(Enum.HumanoidStateType.Running)
    end)
    _s.swapped = true
    _m(a)
    _d(a)
    return true
end
local function F(a)
    if not a or not a:IsA("Tool") then
        return false
    end
    if _t and _t.IsEggTool then
        local b, c = pcall(_t.IsEggTool, a)
        if b and c == true then
            return true
        end
    end
    if
        a:GetAttribute("Personality") ~= nil
        or a:GetAttribute("EyeColor") ~= nil
        or a:GetAttribute("Gender") ~= nil
        or a:GetAttribute("Weight") ~= nil
    then
        return false
    end
    local b = a.Name:lower()
    if
        b:find("sword")
        or b:find("radar")
        or b:find("basket")
        or b:find("punch")
        or b:find("bat")
        or b:find("trap")
        or a:GetAttribute("ItemType") == "Gear"
    then
        return false
    end
    if
        a:GetAttribute("ItemType") == "AssetEgg"
        or a:GetAttribute("ItemType") == "Egg"
        or a:GetAttribute("EggUid") ~= nil
        or b:find("egg")
        or a:GetAttribute("AssetCategory") ~= nil
        or a:GetAttribute("UID") ~= nil
    then
        return true
    end
    return false
end
local function N()
    local a = S.Character
    local b = a and a:FindFirstChildOfClass("Humanoid")
    local c = S:FindFirstChild("Backpack")
    if b then
        pcall(function()
            b:UnequipTools()
        end)
    end
    if a and c then
        for d, e in ipairs(a:GetChildren()) do
            if e:IsA("Tool") then
                pcall(function()
                    e.Parent = c
                end)
            end
        end
    end
end
local function I(a)
    if not _s.holdingForGuard then
        local b = S.Character
        if b then
            for c, d in ipairs(b:GetChildren()) do
                if F(d) then
                    N()
                    break
                end
            end
        end
        return false, nil
    end
    local b = S.Character
    if b then
        for c, d in ipairs(b:GetChildren()) do
            if F(d) then
                local e = d:GetAttribute("UID") or d:GetAttribute("EggUid")
                if not a or e == a or tostring(e) == tostring(a) or d.Name == tostring(a) then
                    return true, d
                end
            end
        end
    end
    local c = _h()
    if c and c.Position.X <= (_s.fieldBoundX + 15) then
        return false, nil
    end
    if _e and _e.ReadFieldEggs then
        local ok, res = pcall(_e.ReadFieldEggs)
        if ok and type(res) == "table" then
            local f = res.Records or res
            if type(f) == "table" then
                for g, h in pairs(f) do
                    local i = (type(h) == "table" and (h.Uid or g)) or g
                    if not a or i == a or tostring(i) == tostring(a) then
                        local j = type(h) == "table" and (h.CarrierUserId or h.Carrier)
                        if j == S.UserId or tostring(j) == tostring(S.UserId) then
                            return true, nil
                        end
                    end
                end
            end
        end
    end
    return false, nil
end
local function J(a)
    local b, c = I(a)
    if b then
        return true, c, "Character"
    end
    local d = S:FindFirstChild("Backpack")
    if d then
        for e, f in ipairs(d:GetChildren()) do
            if F(f) then
                local g = f:GetAttribute("UID") or f:GetAttribute("EggUid")
                if not a or g == a or tostring(g) == tostring(a) or f.Name == tostring(a) then
                    return true, f, "Backpack"
                end
            end
        end
    end
    if a and _e and _e.ReadFieldEggs then
        local ok, f = pcall(_e.ReadFieldEggs)
        if ok and type(f) == "table" then
            local g = f.Records or f
            if type(g) == "table" then
                for h, i in pairs(g) do
                    local j = (type(i) == "table" and (i.Uid or h)) or h
                    if tostring(j) == tostring(a) then
                        local k = type(i) == "table" and (i.CarrierUserId or i.Carrier)
                        if k == S.UserId or tostring(k) == tostring(S.UserId) then
                            return true, nil, "EggState"
                        end
                    end
                end
            end
        end
    end
    return false, nil, nil
end
local function Q()
    local a = 0
    local b = S.Character
    local c = S:FindFirstChild("Backpack")
    if b then
        for d, e in ipairs(b:GetChildren()) do
            if F(e) then
                a = a + 1
            end
        end
    end
    if c then
        for d, e in ipairs(c:GetChildren()) do
            if F(e) then
                a = a + 1
            end
        end
    end
    return a
end
local function a0(a)
    if not a then
        return
    end
    _d(a)
    for b, c in ipairs(a:GetDescendants()) do
        if c:IsA("Motor6D") then
            c:GetPropertyChangedSignal("Enabled"):Connect(function()
                if not c.Enabled then
                    c.Enabled = true
                end
            end)
        end
    end
    a.DescendantAdded:Connect(function(b)
        if b:IsA("BallSocketConstraint") or b:IsA("HingeConstraint") or b:IsA("NoCollisionConstraint") then
            task.defer(function()
                pcall(function()
                    b:Destroy()
                end)
                _d(a)
            end)
        elseif
            b:IsA("LocalScript") and (string.find(b.Name:lower(), "ragdoll") or string.find(b.Name:lower(), "fall"))
        then
            b.Disabled = true
        end
    end)
    a.ChildAdded:Connect(function(b)
        if b:IsA("Tool") and _s.running and not _s.holdingForGuard then
            task.defer(N)
        end
    end)
end
local function a1()
    _w()
    _m()
    if S.Character then
        a0(S.Character)
    end
end
a1()
S.CharacterAdded:Connect(function()
    task.wait(0.5)
    _s.swapped = false
    a1()
end)
local function a2()
    pcall(function()
        local a = workspace:FindFirstChild("Plots")
        if not a then
            return
        end
        local b = _s.plotData and _s.plotData.plot
        for c, d in ipairs(a:GetChildren()) do
            if d ~= b then
                local e = d:FindFirstChild("TreadmillBottom")
                if e and e:IsA("BasePart") then
                    e.CanTouch = false
                    e.CanCollide = false
                end
                local f = d:FindFirstChild("TreadmillUpgrade")
                if f then
                    for g, h in ipairs(f:GetDescendants()) do
                        if h:IsA("BasePart") then
                            h.CanTouch = false
                            h.CanCollide = false
                        end
                    end
                end
            end
        end
    end)
end
local function a3()
    if B then
        task.spawn(function()
            pcall(function()
                B:InvokeServer()
            end)
        end)
    end
    local a = S.Character
    local b = a and a:FindFirstChildOfClass("Humanoid")
    local c = _h()
    if b then
        pcall(function()
            for d, e in ipairs(b:GetPlayingAnimationTracks()) do
                local f = e.Animation
                local g = f and f.AnimationId or ""
                if g:find("10921259953") or e.Name:lower():find("treadmill") or e.Name:lower():find("run") then
                    e:Stop(0)
                end
            end
            b.PlatformStand = false
            b.Sit = false
            b:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
    if c then
        c.AssemblyLinearVelocity = Vector3.zero
        c.AssemblyAngularVelocity = Vector3.zero
    end
end
local function a4()
    local a = {}
    local b = workspace:FindFirstChild("__DEBRIS")
    if b then
        for c, d in ipairs(b:GetChildren()) do
            local e = d:FindFirstChild("Hitbox")
            if e and e:IsA("BasePart") then
                table.insert(a, e)
            elseif d:IsA("BasePart") and d.Name:lower():find("hitbox") then
                table.insert(a, d)
            end
        end
    end
    local c = workspace:FindFirstChild("BossArenaTeleport")
    if c then
        local d = c:FindFirstChild("Hitbox") or c:FindFirstChildWhichIsA("BasePart") or (c:IsA("BasePart") and c)
        if d and d:IsA("BasePart") then
            table.insert(a, d)
        end
    end
    return a
end
local function a5(a)
    if not a then
        return false, "NoUid"
    end
    local b = tostring(a)
    if _e and _e.ReadFieldEggs then
        local c, d = pcall(_e.ReadFieldEggs)
        if c and d and d.Records then
            for e, f in pairs(d.Records) do
                if type(f) == "table" and (tostring(f.Uid) == b or tostring(e) == b) then
                    local g = f.State
                    local h = f.CarrierUserId or f.Carrier
                    if g == "Carried" or g == 2 or (h and h ~= 0) then
                        if h and (h == S.UserId or tostring(h) == tostring(S.UserId)) then
                            return true, "CarriedBySelf"
                        else
                            return false, "CarriedByOther"
                        end
                    end
                    if g == "Slot" or g == "Dropped" or g == "GuardCarried" or g == 1 or g == nil then
                        return true, "Available"
                    end
                    return true, "Available"
                end
            end
            local e = workspace:FindFirstChild("AreaEggSlotsClient")
            if e then
                for f, g in ipairs(e:GetChildren()) do
                    if g.Name == b or g:GetAttribute("UID") == b or g:GetAttribute("Uid") == b then
                        return true, "Available"
                    end
                end
            end
            return false, "NotOnField"
        end
    end
    local c = workspace:FindFirstChild("AreaEggSlotsClient")
    if c then
        for d, e in ipairs(c:GetChildren()) do
            if e.Name == b or e:GetAttribute("UID") == b or e:GetAttribute("Uid") == b then
                return true, "Available"
            end
        end
        return false, "NotOnField"
    end
    return true, "Available"
end
local function a6(a, b, c)
    local d = S.Character
    local e = _h()
    local f = d and d:FindFirstChildOfClass("Humanoid")
    if not e then
        return false
    end
    if f then
        f.AutoRotate = false
    end
    b = b or 18
    local g = os.clock() + b
    local h = math.max(100, _s.speed)
    local i = _s.baseSpeed
    local j = _s.fieldLaneZ or -364.5
    local k = _s.rampEndX
    local l = _s.fieldBoundX
    _m(d)
    _j(a, 14)
    e.AssemblyLinearVelocity = Vector3.zero
    e.AssemblyAngularVelocity = Vector3.zero
    pcall(function()
        S:RequestStreamAroundAsync(a)
    end)
    local m = 0
    while _s.running and _s.alive and (_G._EggStealerSession == _s) and (os.clock() < g) do
        local n = e.Position
        local o = (a - n).Magnitude
        local p = (Vector2.new(n.X, n.Z) - Vector2.new(a.X, a.Z)).Magnitude
        local q = math.abs(n.Y - a.Y)
        if o <= 5 or (p <= 3.5 and q <= 5) then
            break
        end
        if c and (os.clock() - m > 0.4) then
            m = os.clock()
            local r, s = a5(c)
            if not r and s ~= "CarriedBySelf" then
                if f then
                    f.AutoRotate = true
                    f.PlatformStand = false
                end
                return false, "TakenOrGone"
            end
        end
        local r = Y.Heartbeat:Wait()
        if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
            break
        end
        n = e.Position
        local s = h
        if n.X <= k and n.X > l then
            local t = math.clamp((n.X - l) / (k - l), 0, 1)
            s = i + ((h - i) * t)
        elseif n.X <= l then
            s = i
        end
        local t = a.Z
        if n.X >= l and a.X >= l then
            if math.abs(n.X - a.X) > 40 then
                t = j
            else
                t = a.Z
            end
        elseif n.X < l and a.X >= l then
            local u = _s.plotX or 410
            local v = _s.plotZ or j
            local w = math.clamp((n.X - u) / math.max(1, l - u), 0, 1)
            t = v + ((j - v) * w)
        else
            t = a.Z
        end
        local u = math.sign(a.X - n.X)
        local v = u * math.min(math.abs(a.X - n.X), s * r)
        local w = n.X + v
        local x = (p <= 25) and a.Y or math.clamp(a.Y, 68, 72)
        local y = math.sign(x - n.Y)
        local z = (p <= 25) and 1.2 or 0.5
        local A1 = y * math.min(math.abs(x - n.Y), (s * r) * z)
        local B1 = n.Y + A1
        local C1 = math.sign(t - n.Z)
        local D1 = C1 * math.min(math.abs(t - n.Z), s * r)
        local E1 = n.Z + D1
        if p > 25 then
            local F1 = a4()
            for G1, H1 in ipairs(F1) do
                local I1 = H1.Position
                local J1 = (Vector3.new(w, B1, E1) - I1).Magnitude
                local K1 = math.abs(w - I1.X)
                local L1 = math.abs(E1 - I1.Z)
                if J1 < 22 or (K1 < 18 and L1 < 14) then
                    local M1 = I1.Y + 16
                    if B1 < M1 then
                        B1 = math.min(B1 + (s * r * 1.5), M1)
                    end
                    break
                end
            end
        end
        local F1 = Vector3.new(w, B1, E1)
        local G1 = (F1 - n).Magnitude > 0.05 and (F1 - n).Unit or e.CFrame.LookVector
        e.CFrame = CFrame.lookAt(F1, F1 + G1)
        e.AssemblyLinearVelocity = Vector3.zero
        e.AssemblyAngularVelocity = Vector3.zero
        if not _s.holdingForGuard then
            N()
        end
    end
    if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
        if f then
            f.AutoRotate = true
            f.PlatformStand = false
        end
        return false
    end
    e.CFrame = CFrame.new(a)
    e.AssemblyLinearVelocity = Vector3.zero
    e.AssemblyAngularVelocity = Vector3.zero
    if f then
        f.AutoRotate = true
        f.PlatformStand = false
    end
    return true
end
local function a7()
    local a = S.Character
    local b = _h()
    local c = a and a:FindFirstChildOfClass("Humanoid")
    if not b then
        return false
    end
    if c then
        c.AutoRotate = false
    end
    local d = math.max(100, _s.speed)
    local e = _s.baseSpeed
    local f = -364.5
    local g = _s.rampEndX
    local h = _s.fieldBoundX
    local i = Vector3.new(h - 10, 70, f)
    _m(a)
    _j(Vector3.new(h, 70, f), 20)
    N()
    b.AssemblyLinearVelocity = Vector3.zero
    b.AssemblyAngularVelocity = Vector3.zero
    if c then
        c.PlatformStand = true
    end
    local j = os.clock() + 18
    while _s.running and _s.alive and (_G._EggStealerSession == _s) and (os.clock() < j) do
        local k = b.Position
        local l = (i - k).Magnitude
        if k.X <= (h + 10) or l <= 6 then
            N()
            break
        end
        N()
        local m = Y.Heartbeat:Wait()
        if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
            break
        end
        k = b.Position
        local n = d
        if k.X <= g and k.X > h then
            local o = math.clamp((k.X - h) / (g - h), 0, 1)
            n = e + ((d - e) * o)
        elseif k.X <= h then
            n = e
        end
        local o = math.sign(i.X - k.X)
        local p = o * math.min(math.abs(i.X - k.X), n * m)
        local q = k.X + p
        local r = math.sign(i.Y - k.Y)
        local s = r * math.min(math.abs(i.Y - k.Y), (n * m) * 0.5)
        local t = k.Y + s
        local u = math.sign(f - k.Z)
        local v = u * math.min(math.abs(f - k.Z), n * m)
        local w = k.Z + v
        local x = a4()
        for y, z in ipairs(x) do
            local A1 = z.Position
            local B1 = (Vector3.new(q, t, w) - A1).Magnitude
            local C1 = math.abs(q - A1.X)
            local D1 = math.abs(w - A1.Z)
            if B1 < 22 or (C1 < 18 and D1 < 14) then
                local E1 = A1.Y + 16
                if t < E1 then
                    t = math.min(t + (n * m * 1.5), E1)
                end
                break
            end
        end
        local y = Vector3.new(q, t, w)
        local z = (y - k).Magnitude > 0.05 and (y - k).Unit or b.CFrame.LookVector
        b.CFrame = CFrame.lookAt(y, y + z)
        b.AssemblyLinearVelocity = Vector3.zero
        b.AssemblyAngularVelocity = Vector3.zero
        _msg(string.format("🏠 Returning (%.0f st | X: %.0f | V: %.0f)", l, k.X, n))
    end
    if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
        if c then
            c.AutoRotate = true
        end
        return false
    end
    b.CFrame = CFrame.new(h, math.max(68, b.Position.Y), f)
    b.AssemblyLinearVelocity = Vector3.zero
    b.AssemblyAngularVelocity = Vector3.zero
    if c then
        c.AutoRotate = true
    end
    N()
    _msg("🎉 Safe Line Reached!")
    return true
end
local function a8()
    if _s.plotData and _s.plotData.plot and _s.plotData.plot.Parent and _s.plotData.pen and _s.plotData.pen.Parent then
        return _s.plotData.plot, _s.plotData.pen, _s.plotData.origin
    end
    local a = workspace:FindFirstChild("Plots")
    if not a then
        return nil, nil, nil
    end
    local b, c, d, e = nil, nil, nil, nil
    if _p and _p.ResolvePlot then
        local f, g = pcall(function()
            return _p.ResolvePlot(S)
        end)
        if f and type(g) == "table" and g.PlotFolder and g.PetArea then
            b = g.PlotFolder
            c = g.PetArea
            d = g.CenterPoint or c
            e = g.Slot or tonumber(b.Name)
        end
    end
    if not b and _e and _e.ReadOwnedEggs then
        local f, g = pcall(_e.ReadOwnedEggs)
        if f and type(g) == "table" then
            for h, i in pairs(g) do
                if
                    type(i) == "table" and (i.OwnerUserId == S.UserId or tostring(i.OwnerUserId) == tostring(S.UserId))
                then
                    local j = a:FindFirstChild(tostring(h))
                    if j then
                        b = j
                        e = tostring(h)
                        break
                    end
                end
            end
        end
    end
    if not b then
        for f, g in ipairs(a:GetChildren()) do
            local h = g:FindFirstChild("PlotSign", true)
            if h then
                local i = h:FindFirstChild("PlayerName", true)
                if i and i:IsA("TextLabel") and (i.Text == S.Name or i.Text == S.DisplayName) then
                    b = g
                    e = g.Name
                    break
                end
            end
        end
    end
    if not b then
        for f, g in ipairs(a:GetChildren()) do
            local h = g:GetAttribute("Owner") or g:GetAttribute("OwnerUserId") or g:GetAttribute("OwnerName")
            if h == S.UserId or tostring(h) == tostring(S.UserId) or h == S.Name then
                b = g
                e = g.Name
                break
            end
        end
    end
    if not b then
        local f = _h()
        if f and f.Position.X <= (_s.fieldBoundX + 15) then
            local g, h = nil, math.huge
            for i, j in ipairs(a:GetChildren()) do
                local k = j.PrimaryPart
                    or j:FindFirstChildWhichIsA("BasePart")
                    or (j:FindFirstChild("ToUpdate") and j.ToUpdate:FindFirstChild("PetArea"))
                if k then
                    local l = (f.Position - k.Position).Magnitude
                    if l < h then
                        h = l
                        g = j
                    end
                end
            end
            if g then
                b = g
                e = g.Name
            end
        end
    end
    if not b then
        b = a:FindFirstChild("1") or a:GetChildren()[1]
    end
    if not b then
        return nil, nil, nil
    end
    if not c then
        c = b:FindFirstChild("PetArea")
            or (b:FindFirstChild("ToUpdate") and b.ToUpdate:FindFirstChild("PetArea"))
            or b:FindFirstChildWhichIsA("BasePart")
            or b.PrimaryPart
    end
    if not d then
        d = b:FindFirstChild("CenterPoint") or c or b.PrimaryPart
    end
    _s.plotId = tostring(e or b.Name)
    if c then
        _s.plotZ = c.Position.Z
        _s.plotX = c.Position.X
    end
    _s.fieldLaneZ = -364.5
    _s.laneZ = -364.5
    _s.plotData = { plot = b, pen = c, origin = d }
    return b, c, d
end
if _p and _p.LocalPlotChanged then
    pcall(function()
        _p.LocalPlotChanged:Connect(function()
            _s.plotData = nil
            a8()
            if u then
                pcall(u)
            end
        end)
    end)
end
local function a9()
    local a, b, c = a8()
    if b then
        return b.Position + Vector3.new(0, 3.5, 0)
    end
    if c then
        return c.Position + Vector3.new(0, 3.5, 0)
    end
    return Vector3.new(464.7, 71.7, -304)
end
local function b0()
    local a, b = 0, 10
    if _e and _e.ReadOwnedEggs then
        local c, d = pcall(_e.ReadOwnedEggs)
        if c and type(d) == "table" then
            for e, f in pairs(d) do
                if
                    type(f) == "table" and (f.OwnerUserId == S.UserId or tostring(f.OwnerUserId) == tostring(S.UserId))
                then
                    for g, h in pairs(f.Records or {}) do
                        if h.Placement then
                            a = a + 1
                        end
                    end
                end
            end
        end
    end
    return a, b
end
local function b1(a, b)
    local c = ""
    local d = a.AssetCategory or (b and b.Name) or ""
    if b then
        c = tostring(b:GetAttribute("Rarity") or b:GetAttribute("RarityTier") or b:GetAttribute("Tier") or "")
        if d == "" or d == "Egg" then
            d = b:GetAttribute("Category") or b:GetAttribute("AssetCategory") or b.Name
        end
    end
    if c == "" then
        c = tostring(a.Rarity or "")
    end
    local e = c:lower()
    if e:find("divine") then
        return "Divine", 6
    end
    if e:find("eternal") then
        return "Eternal", 5
    end
    if e:find("secret") then
        return "Secret", 4
    end
    if e:find("cosmic") then
        return "Cosmic", 3
    end
    if e:find("mythic") then
        return "Mythic", 2
    end
    if e:find("legendary") then
        return "Legendary", 1
    end
    if e:find("epic") then
        return "Epic", 0.5
    end
    if e:find("rare") then
        return "Rare", 0.3
    end
    if e:find("uncommon") then
        return "Uncommon", 0.1
    end
    if e:find("common") then
        return "Common", 0
    end
    local f = string.lower(string.format("%s %s %s", d, tostring(a.Uid or ""), tostring(a.Name or "")))
    if
        f:find("nightflame")
        or f:find("unicorn")
        or f:find("shatteredcolossus")
        or f:find("kitsune")
        or f:find("elmaja")
        or f:find("el maja")
    then
        return "Divine", 6
    end
    if
        f:find("gorillaking")
        or f:find("gorilla king")
        or f:find("lunardragon")
        or f:find("lunar dragon")
        or f:find("onitiger")
        or f:find("oni tiger")
        or f:find("mosasaurus")
    then
        return "Eternal", 5
    end
    if
        f:find("mutantshark")
        or f:find("skeleton")
        or f:find("stag")
        or f:find("cosmicdragon")
        or f:find("trex")
        or f:find("t-rex")
        or f:find("tralaledon")
        or f:find("kraken")
    then
        return "Secret", 4
    end
    if
        f:find("saturnita")
        or f:find("mantaris")
        or f:find("rhinotaur")
        or f:find("snowyowl")
        or f:find("koi")
        or f:find("triceratops")
        or f:find("bronto")
        or f:find("whaleshark")
        or f:find("beluga")
    then
        return "Cosmic", 3
    end
    if
        f:find("bladehide")
        or f:find("redpanda")
        or f:find("cosmicgorilla")
        or f:find("ankylosaurus")
        or f:find("orca")
    then
        return "Mythic", 2
    end
    if
        f:find("spideron")
        or f:find("crustacia")
        or f:find("salamander")
        or f:find("pterodactyl")
        or f:find("shark")
    then
        return "Legendary", 1
    end
    if f:find("crane") or f:find("centapede") or f:find("swordfish") then
        return "Epic", 0.5
    end
    if f:find("dodo") or f:find("parrotfish") then
        return "Rare", 0.3
    end
    return "Common", 0
end
local function b2(a, b)
    local c = a.AreaId
        or (a.PhysicalModel and (a.PhysicalModel:GetAttribute("AreaId") or a.PhysicalModel:GetAttribute("Area")))
    if c and c ~= "" and c ~= "Unknown" then
        return tostring(c)
    end
    if b then
        local d = b.X
        if d > 4400 then
            return "Light Dark"
        end
        if d > 4000 then
            return "Titan Temple"
        end
        if d > 3600 then
            return "Cherry Blossom"
        end
        if d > 3200 then
            return "Cosmic"
        end
        if d > 2800 then
            return "Prehistoric"
        end
        if d > 2400 then
            return "Abyss Ocean"
        end
        if d > 2000 then
            return "Volcano"
        end
        if d > 1600 then
            return "Snow"
        end
        if d > 1200 then
            return "Jungle"
        end
        if d > 900 then
            return "Desert"
        end
        if d > 650 then
            return "Lake"
        end
        return "Forest"
    end
    return "Forest"
end
local function b3()
    local a, b = {}, {}
    if _e and _e.ReadFieldEggs then
        local c, d = pcall(_e.ReadFieldEggs)
        if c and d and d.Records then
            for e, f in pairs(d.Records) do
                if type(f) == "table" then
                    local g = tostring(f.Uid or e)
                    local h = f.State
                    local i = f.CarrierUserId or f.Carrier
                    local j = (h == "Slot" or h == "Dropped" or h == "GuardCarried" or h == 1 or h == nil)
                        and (i == nil or i == 0)
                    if j and not b[g] then
                        b[g] = true
                        f.Uid = g
                        table.insert(a, f)
                    end
                end
            end
        end
    end
    if #a == 0 then
        local c = nil
        if y then
            pcall(function()
                c = y:InvokeServer()
            end)
        end
        if not c and D then
            pcall(function()
                c = D:InvokeServer()
            end)
        end
        if c then
            local d = c.Records or c
            if type(d) == "table" then
                for e, f in pairs(d) do
                    if type(f) == "table" then
                        local g = tostring(f.Uid or e)
                        local h = f.State
                        local i = f.CarrierUserId or f.Carrier
                        local j = (h == "Slot" or h == "Dropped" or h == "GuardCarried" or h == 1 or h == nil)
                            and (i == nil or i == 0)
                        if j and not b[g] then
                            b[g] = true
                            f.Uid = g
                            table.insert(a, f)
                        end
                    end
                end
            end
        end
    end
    local c = workspace:FindFirstChild("AreaEggSlotsClient")
    if c then
        for d, e in ipairs(a) do
            if not e.PhysicalModel and e.BoundsCFrame then
                for f, g in ipairs(c:GetChildren()) do
                    if
                        g.Name == tostring(e.Uid)
                        or ((g:GetPivot().Position - e.BoundsCFrame.Position).Magnitude <= 12)
                    then
                        e.PhysicalModel = g
                        break
                    end
                end
            end
        end
    end
    for d, e in ipairs(a) do
        local f = (e.BoundsCFrame and e.BoundsCFrame.Position)
            or (e.PhysicalModel and e.PhysicalModel:GetPivot().Position)
            or Vector3.zero
        e.ResolvedPos = f
        e.ResolvedRarity, e.RarityRank = b1(e, e.PhysicalModel)
        e.ResolvedZone = b2(e, f)
        e.DisplayName = e.AssetCategory or e.PhysicalModel and e.PhysicalModel.Name or tostring(e.Uid)
    end
    return a
end
local function b4(a, b)
    if b then
        pcall(function()
            for c, d in ipairs(b:GetDescendants()) do
                pcall(function()
                    if d:IsA("ProximityPrompt") then
                        d.RequiresLineOfSight = false
                        d.HoldDuration = 0
                        if typeof(fireproximityprompt) == "function" then
                            fireproximityprompt(d)
                        end
                    end
                end)
            end
        end)
    end
    local c = workspace:FindFirstChild("AreaEggSlotsClient")
    if c and a then
        pcall(function()
            for d, e in ipairs(c:GetChildren()) do
                local f = e:FindFirstChildWhichIsA("BasePart") or e.PrimaryPart
                if f and ((f.Position - a).Magnitude <= 18) then
                    for g, h in ipairs(e:GetDescendants()) do
                        pcall(function()
                            if h:IsA("ProximityPrompt") then
                                h.RequiresLineOfSight = false
                                h.HoldDuration = 0
                                if typeof(fireproximityprompt) == "function" then
                                    fireproximityprompt(h)
                                end
                            end
                        end)
                    end
                end
            end
        end)
    end
end
local function b5(a, b, c)
    local d = S.Character
    local e = _h()
    local f = d and d:FindFirstChildOfClass("Humanoid")
    if not e or not f then
        return false
    end
    local g = b.Position
    _j(g, 16)
    e.AssemblyLinearVelocity = Vector3.zero
    e.AssemblyAngularVelocity = Vector3.zero
    _d(d)
    _m(d)
    pcall(function()
        S:RequestStreamAroundAsync(g)
    end)
    _s.holdingForGuard = true
    local h = workspace:FindFirstChild("AreaEggSlotsClient")
    if not c and h then
        for i, j in ipairs(h:GetChildren()) do
            local k = j:FindFirstChildWhichIsA("BasePart") or j.PrimaryPart
            if k and (k.Position - g).Magnitude <= 16 then
                c = j
                break
            end
        end
    end
    if c then
        pcall(function()
            for i, j in ipairs(c:GetDescendants()) do
                if
                    j:IsA("BasePart")
                    and j.Transparency > 0.8
                    and j.Name ~= "Hitbox"
                    and j.Name ~= "Root"
                    and not j.Name:find("Pad")
                then
                    j.Transparency = 0
                end
            end
        end)
    end
    _msg("[1/4] Securing...")
    local l = os.clock() + 3.5
    local m = 0
    while not I(a) and (os.clock() < l) and _s.running and _s.alive and (_G._EggStealerSession == _s) do
        d:PivotTo(b * CFrame.new(0, 0.4, 0))
        b4(g, c)
        if os.clock() - m > 0.4 then
            m = os.clock()
            local n, o = a5(a)
            if not n and o == "CarriedByOther" then
                break
            end
        end
        if k then
            task.spawn(function()
                pcall(function()
                    if k:IsA("RemoteFunction") then
                        k:InvokeServer({ Uid = a })
                        k:InvokeServer(a)
                    else
                        k:FireServer({ Uid = a })
                        k:FireServer(a)
                    end
                end)
            end)
        end
        Y.Heartbeat:Wait()
    end
    if not I(a) then
        _msg("❌ Lift Failed")
        _s.holdingForGuard = false
        _g(d)
        return false
    end
    _msg("[2/4] Waiting Guard Strike...")
    local n = os.clock() + 4.5
    local o = false
    while I(a) and (os.clock() < n) and _s.running and _s.alive and (_G._EggStealerSession == _s) do
        d:PivotTo(b * CFrame.new(0, 0.4, 0))
        _j(g, 14)
        if T and not o then
            task.spawn(function()
                pcall(function()
                    if T:IsA("RemoteFunction") then
                        T:InvokeServer()
                    else
                        T:FireServer()
                    end
                end)
            end)
            o = true
        end
        Y.Heartbeat:Wait()
    end
    _msg("[3/4] Re-grabbing...")
    local p = os.clock() + 3.0
    while not I(a) and (os.clock() < p) and _s.running and _s.alive and (_G._EggStealerSession == _s) do
        d:PivotTo(b * CFrame.new(0, 0.4, 0))
        b4(g, c)
        if k then
            task.spawn(function()
                pcall(function()
                    if k:IsA("RemoteFunction") then
                        k:InvokeServer({ Uid = a })
                        k:InvokeServer(a)
                    else
                        k:FireServer({ Uid = a })
                        k:FireServer(a)
                    end
                end)
            end)
        end
        Y.Heartbeat:Wait()
    end
    local q = I(a) or J(a)
    if not q then
        task.wait(0.12)
        q = I(a) or J(a)
    end
    _s.holdingForGuard = false
    _g(d)
    if q then
        N()
        _msg("✅ Secured! Flying home...")
        return true
    else
        _msg("❌ Re-grab Failed")
        return false
    end
end
local function b6()
    if not (A and p) then
        return 0
    end
    local a = {}
    if _e and _e.ReadOwnedEggs then
        local b = nil
        pcall(function()
            b = _e.ReadOwnedEggs()
        end)
        if type(b) == "table" then
            for c, d in pairs(b) do
                if
                    type(d) == "table" and (d.OwnerUserId == S.UserId or tostring(d.OwnerUserId) == tostring(S.UserId))
                then
                    for e, f in pairs(d.Records or {}) do
                        if f.Placement then
                            local g = false
                            if _e and _e.IsReadyToHatch then
                                local h, i = pcall(_e.IsReadyToHatch, e)
                                if h and i == true then
                                    g = true
                                end
                            end
                            if not g and _e and _e.IsLocalEggReady then
                                local h, i = pcall(_e.IsLocalEggReady, e)
                                if h and i == true then
                                    g = true
                                end
                            end
                            if g then
                                table.insert(a, e)
                            end
                        end
                    end
                end
            end
        end
    end
    local b = 0
    for c, d in ipairs(a) do
        if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
            break
        end
        pcall(function()
            A:InvokeServer(d)
        end)
        task.wait(0.08)
        pcall(function()
            p:InvokeServer(d)
        end)
        b = b + 1
        task.wait(0.05)
    end
    return b
end
local function b7(a, b)
    local c = a.Size
    local d = math.max(4, c.X / 2 - 5)
    local e = math.max(4, c.Z / 2 - 5)
    for f = 1, 60 do
        local g = math.random(-math.floor(d), math.floor(d))
        local h = math.random(-math.floor(e), math.floor(e))
        local i = a.CFrame * CFrame.new(g, c.Y / 2 + 1, h)
        local j = true
        for k, l in ipairs(b) do
            if (l - i.Position).Magnitude < 5.5 then
                j = false
                break
            end
        end
        if j then
            return i
        end
    end
    return a.CFrame * CFrame.new(math.random(-8, 8), c.Y / 2 + 1, math.random(-8, 8))
end
local function b8(a)
    local b, c, d = a8()
    if not c or not C then
        return 0
    end
    N()
    local occ = {}
    local f = {}
    local g = nil
    if _e and _e.ReadOwnedEggs then
        pcall(function()
            g = _e.ReadOwnedEggs()
        end)
    end
    if not g and D then
        pcall(function()
            g = D:InvokeServer()
        end)
    end
    if type(g) == "table" then
        for h, i in pairs(g) do
            if type(i) == "table" and (i.OwnerUserId == S.UserId or tostring(i.OwnerUserId) == tostring(S.UserId)) then
                for j, k in pairs(i.Records or {}) do
                    if k.Placement and k.Placement.LocalCFrame then
                        local l = k.Placement.LocalCFrame
                        local m = (typeof(l) == "CFrame" and (c.CFrame * l).Position)
                            or (typeof(l) == "Vector3" and (c.CFrame * CFrame.new(l)).Position)
                            or (type(l) == "table" and l.x and (c.CFrame * CFrame.new(l.x, l.y or 1, l.z or 0)).Position)
                            or nil
                        if m then
                            table.insert(occ, m)
                        end
                    elseif not k.Placement then
                        table.insert(f, j)
                    end
                end
            end
        end
    end
    local h = 0
    for i, j in ipairs(f) do
        local k = b7(c, occ)
        if k then
            local l = c.CFrame:ToObjectSpace(k)
            local m, n = pcall(function()
                return C:InvokeServer({ Uid = j, LocalCFrame = l })
            end)
            if m and n ~= false then
                h = h + 1
                table.insert(occ, k.Position)
            end
        end
    end
    local function o()
        local p = {}
        local q = {}
        local function r(s)
            if not F(s) then
                return
            end
            local t = s:GetAttribute("UID") or s:GetAttribute("EggUid") or s.Name
            if t then
                local u = tostring(t)
                if not q[u] then
                    q[u] = true
                    table.insert(p, { uid = u, tool = s })
                end
            end
        end
        local s = S.Character
        local t = S:FindFirstChild("Backpack")
        if s then
            for u, v in ipairs(s:GetChildren()) do
                r(v)
            end
        end
        if t then
            for u, v in ipairs(t:GetChildren()) do
                r(v)
            end
        end
        return p
    end
    local p = o()
    if #p == 0 and h == 0 then
        task.wait(0.1)
        p = o()
    end
    if #p > 0 then
        for q, r in ipairs(p) do
            if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
                break
            end
            local s = b7(c, occ)
            if s then
                local t = c.CFrame:ToObjectSpace(s)
                local u, v = pcall(function()
                    return C:InvokeServer({ Uid = r.uid, LocalCFrame = t })
                end)
                if u and v ~= false then
                    h = h + 1
                    table.insert(occ, s.Position)
                end
                task.wait(0.04)
            end
        end
    end
    if a and h == 0 then
        local q = tostring(a)
        local r = b7(c, occ)
        if r then
            local s = c.CFrame:ToObjectSpace(r)
            local t, u = pcall(function()
                return C:InvokeServer({ Uid = q, LocalCFrame = s })
            end)
            if t and u ~= false then
                h = h + 1
                table.insert(occ, r.Position)
            end
        end
    end
    N()
    return h
end
local function b9(a)
    local b, c, d = a8()
    if not c or not C then
        return false, 0
    end
    local e = a9()
    local f = S.Character
    local g = _h()
    local h = f and f:FindFirstChildOfClass("Humanoid")
    if not g then
        return false, 0
    end
    if h then
        h.AutoRotate = false
        h.PlatformStand = true
    end
    if g.Position.X > (_s.fieldBoundX + 10) then
        a7()
        g = _h()
        if not g then
            return false, 0
        end
    end
    local i = c.Position.Z
    local j = -364.5
    if math.abs(i - j) > 25 and g.Position.X > 495 then
        local k = Vector3.new(505, 70, i)
        local l = os.clock() + 1.2
        while _s.running and _s.alive and (_G._EggStealerSession == _s) and (os.clock() < l) do
            local m = g.Position
            if (k - m).Magnitude <= 8 then
                break
            end
            local n = Y.Heartbeat:Wait()
            local o = math.max(600, _s.speed) * n
            local p = (k - m).Unit
            local q = m + (p * math.min((k - m).Magnitude, o))
            g.CFrame = CFrame.lookAt(q, q + p)
            g.AssemblyLinearVelocity = Vector3.zero
            g.AssemblyAngularVelocity = Vector3.zero
        end
    end
    local k = (e - g.Position).Magnitude
    if k > 6 then
        _msg(string.format("📦 Base Plot #%s...", tostring(_s.plotId or "?")))
        local l = os.clock() + 2.0
        local m = math.max(600, _s.speed)
        while _s.running and _s.alive and (_G._EggStealerSession == _s) and (os.clock() < l) do
            local n = g.Position
            local o = (e - n).Magnitude
            if o <= 5 then
                break
            end
            local p = Y.Heartbeat:Wait()
            if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
                break
            end
            local q = m * p
            local r = (e - n).Unit
            local s = n + (r * math.min(o, q))
            g.CFrame = CFrame.lookAt(s, s + r)
            g.AssemblyLinearVelocity = Vector3.zero
            g.AssemblyAngularVelocity = Vector3.zero
        end
    end
    if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
        if h then
            h.AutoRotate = true
            h.PlatformStand = false
        end
        return false, 0
    end
    g.CFrame = CFrame.new(e)
    g.AssemblyLinearVelocity = Vector3.zero
    g.AssemblyAngularVelocity = Vector3.zero
    if h then
        h.AutoRotate = true
        h.PlatformStand = false
    end
    _j(e, 10)
    N()
    local l = b6()
    if l > 0 then
        _msg(string.format("🐣 Hatched %d", l))
        task.wait(0.1)
    end
    _msg("📥 Placing...")
    local m = 0
    local n = os.clock() + 3.0
    while (Q() > 0 or m == 0) and (os.clock() < n) and _s.running and _s.alive and (_G._EggStealerSession == _s) do
        local o = b8(a)
        m = m + (o or 0)
        if Q() == 0 then
            break
        end
        b6()
        task.wait(0.1)
    end
    task.spawn(b6)
    task.wait(0.3)
    if m > 0 then
        _s.stolenCount = (_s.stolenCount or 0) + m
    end
    return true, m
end
local function c0()
    local a = _h()
    if not a or a.Position.X > 535 then
        return
    end
    local b, c = a8()
    local d = c and c.Position.Z or -364.5
    local e = -364.5
    if a.Position.X < 495 and math.abs(d - e) > 25 then
        a6(Vector3.new(505, 70, d), 2.5)
    end
    a6(Vector3.new(538, 70, e), 2.5)
end
local function c1()
    if not _s.swapped then
        _w()
    end
    _m()
    a2()
    a3()
    while _s.running and _s.alive and (_G._EggStealerSession == _s) do
        task.wait(0.1)
        if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
            break
        end
        local a = _h()
        if not a then
            task.wait(1)
            continue
        end
        if Q() > 0 then
            _msg("📥 Offloading...")
            b9()
            task.wait(0.2)
        end
        local b = false
        for c, d in pairs(_s.selectedZones) do
            if d == true then
                b = true
                break
            end
        end
        if not b then
            for c, d in pairs(_s.selectedRarities) do
                if d == true then
                    b = true
                    break
                end
            end
        end
        if not b then
            for c, d in pairs(_s.selected) do
                if d == true then
                    b = true
                    break
                end
            end
        end
        if not b then
            _msg("🏁 Done")
            b("🏁 Done")
            break
        end
        local c = b3()
        pcall(function()
            local g = a9()
            local h = table.clone(c)
            table.sort(h, function(i, j)
                return (g - i.ResolvedPos).Magnitude < (g - j.ResolvedPos).Magnitude
            end)
            V(h)
        end)
        local d = {}
        for g, h in ipairs(c) do
            local i = tostring(h.Uid)
            local j = h.ResolvedZone and (_s.selectedZones[h.ResolvedZone] == true)
            local k = h.ResolvedRarity and (_s.selectedRarities[h.ResolvedRarity] == true)
            local l = j or k
            local m = (_s.selected[i] == false)
            local n = (_s.selected[i] == true)
            local o = (l and not m) or n
            if o and not E(i) then
                local p = h.ResolvedPos
                if p and p.X > 530 then
                    local q = (a.Position - p).Magnitude
                    table.insert(d, { egg = h, pos = p, dist = q })
                end
            end
        end
        if #d == 0 then
            _msg("🔍 Waiting...")
            task.wait(2.0)
            continue
        end
        table.sort(d, function(g, h)
            return g.dist < h.dist
        end)
        local e = nil
        for g, h in ipairs(d) do
            local i = tostring(h.egg.Uid)
            local j, k = a5(i)
            local l = (not h.egg.PhysicalModel) or (h.egg.PhysicalModel.Parent ~= nil)
            if j and k ~= "CarriedByOther" and k ~= "NotOnField" and l then
                e = h
                break
            else
                R(i, 25)
                _msg("⚠️ Skipped: Taken")
            end
        end
        if not e then
            _msg("🔍 Waiting...")
            task.wait(1.5)
            continue
        end
        local f = e
        local g = tostring(f.egg.Uid)
        local h = f.egg.BoundsCFrame or CFrame.new(f.pos)
        _msg(string.format("🚀 %s [%s]", f.egg.DisplayName, f.egg.ResolvedZone or "Zone"))
        if a.Position.X <= 535 then
            c0()
        end
        if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
            break
        end
        local i, j = a6(f.pos + Vector3.new(0, 1.2, 0), 16, g)
        if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
            break
        end
        if not i then
            R(g, 20)
            _msg("⚠️ Skipped unreachable")
            task.wait(0.2)
            continue
        end
        local k = b5(g, h, f.egg.PhysicalModel)
        if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
            break
        end
        if not k and (I(g) or J(g)) then
            k = true
        end
        if not k then
            R(g, 25)
            _msg("⚠️ Missed (CD 25s)")
            task.wait(0.5)
            continue
        end
        N()
        _msg("🏠 Returning...")
        a7()
        if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
            break
        end
        local l = _h()
        if l and (l.Position.X > (_s.fieldBoundX + 10)) then
            a7()
        end
        if not _s.running or not _s.alive or (_G._EggStealerSession ~= _s) then
            break
        end
        local m, n = b9(g)
        if (n or 0) > 0 then
            R(g, 180)
            _s.selected[g] = false
            if r then
                r(g, false)
            end
            _msg(string.format("🎉 Placed (+%d)", n))
        else
            R(g, 20)
            _msg("⚠️ Offload fail")
        end
        task.wait(0.2)
    end
end
local c2 = {
    BG = Color3.fromRGB(12, 14, 22),
    Panel = Color3.fromRGB(18, 21, 34),
    Header = Color3.fromRGB(22, 26, 42),
    Accent = Color3.fromRGB(0, 210, 160),
    Red = Color3.fromRGB(255, 75, 75),
    Gold = Color3.fromRGB(251, 191, 36),
    Text = Color3.fromRGB(235, 240, 255),
    Sub = Color3.fromRGB(120, 130, 160),
    Border = Color3.fromRGB(35, 42, 65),
    Row1 = Color3.fromRGB(16, 19, 30),
    Row2 = Color3.fromRGB(20, 24, 38),
    Check = Color3.fromRGB(0, 200, 130),
}
local c3 = {
    Divine = Color3.fromRGB(244, 63, 94),
    Eternal = Color3.fromRGB(217, 70, 239),
    Secret = Color3.fromRGB(249, 115, 22),
    Cosmic = Color3.fromRGB(6, 182, 212),
    Mythic = Color3.fromRGB(139, 92, 246),
    Legendary = Color3.fromRGB(251, 191, 36),
    Epic = Color3.fromRGB(168, 85, 247),
    Rare = Color3.fromRGB(59, 130, 246),
    Uncommon = Color3.fromRGB(34, 197, 94),
    Common = Color3.fromRGB(148, 163, 184),
}
local function c4(a)
    return c3[a] or c2.Sub
end
local function c5(a, b, c)
    local d = Instance.new(a)
    if a == "TextLabel" or a == "TextButton" or a == "TextBox" then
        pcall(function()
            d.AutoLocalize = false
        end)
    end
    for e, f in pairs(b) do
        d[e] = f
    end
    if c then
        d.Parent = c
    end
    return d
end
local function c6(a, b)
    return c5("UICorner", { CornerRadius = UDim.new(0, a) }, b)
end
local function c7(a, b, c)
    return c5("UIStroke", { Color = a, Thickness = b }, c)
end
pcall(function()
    local a = W:FindFirstChild("EggStealerUI")
    if a then
        a:Destroy()
    end
end)
local c8 = c5(
    "ScreenGui",
    { Name = "EggStealerUI", Parent = W, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }
)
_G._EggStealerGui = c8
local c9 = c5("TextButton", {
    Name = "EggStealer_FloatToggle",
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(1, -72, 0.35, 0),
    BackgroundColor3 = Color3.fromRGB(16, 22, 34),
    Text = "🥚",
    Font = Enum.Font.GothamBold,
    TextSize = 24,
    TextColor3 = c2.Accent,
    BorderSizePixel = 0,
    ZIndex = 100,
    AutoButtonColor = false,
}, c8)
c6(25, c9)
c7(Color3.fromRGB(0, 230, 160), 2, c9)
local d0 = c5("TextLabel", {
    Text = "PRO",
    Font = Enum.Font.GothamBold,
    TextSize = 8.5,
    TextColor3 = Color3.fromRGB(8, 18, 12),
    BackgroundColor3 = Color3.fromRGB(0, 220, 155),
    Size = UDim2.new(0, 28, 0, 13),
    Position = UDim2.new(0.5, -14, 1, -11),
    BorderSizePixel = 0,
    ZIndex = 101,
}, c9)
c6(6, d0)
local d1 = c5("Frame", {
    Size = UDim2.new(0, 530, 0, 670),
    Position = UDim2.new(0.5, -265, 0.5, -335),
    BackgroundColor3 = c2.BG,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, c8)
c6(14, d1)
c7(c2.Border, 1.5, d1)
local d2, d3, d4, d5 = false, nil, nil, false
c9.InputBegan:Connect(function(a)
    if a.UserInputType == Enum.UserInputType.MouseButton1 or a.UserInputType == Enum.UserInputType.Touch then
        d2 = true
        d3 = a.Position
        d4 = c9.Position
        d5 = false
        a.Changed:Connect(function()
            if a.UserInputState == Enum.UserInputState.End then
                d2 = false
                if not d5 then
                    d1.Visible = not d1.Visible
                end
            end
        end)
    end
end)
c9.InputChanged:Connect(function(a)
    if (a.UserInputType == Enum.UserInputType.MouseMovement or a.UserInputType == Enum.UserInputType.Touch) and d2 then
        local b = a.Position - d3
        if math.abs(b.X) > 4 or math.abs(b.Y) > 4 then
            d5 = true
        end
        c9.Position = UDim2.new(d4.X.Scale, d4.X.Offset + b.X, d4.Y.Scale, d4.Y.Offset + b.Y)
    end
end)
local d6, d7, d8 = false, nil, nil
d1.InputBegan:Connect(function(a)
    if a.UserInputType == Enum.UserInputType.MouseButton1 or a.UserInputType == Enum.UserInputType.Touch then
        d6 = true
        d7 = a.Position
        d8 = d1.Position
        a.Changed:Connect(function()
            if a.UserInputState == Enum.UserInputState.End then
                d6 = false
            end
        end)
    end
end)
d1.InputChanged:Connect(function(a)
    if (a.UserInputType == Enum.UserInputType.MouseMovement or a.UserInputType == Enum.UserInputType.Touch) and d6 then
        local b = a.Position - d7
        d1.Position = UDim2.new(d8.X.Scale, d8.X.Offset + b.X, d8.Y.Scale, d8.Y.Offset + b.Y)
    end
end)
M.InputBegan:Connect(function(a, b)
    if not b and (a.KeyCode == Enum.KeyCode.RightShift or a.KeyCode == Enum.KeyCode.LeftControl) then
        d1.Visible = not d1.Visible
    end
end)
local e0 = c5("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = c2.Header, BorderSizePixel = 0 }, d1)
c6(14, e0)
c5("Frame", {
    Size = UDim2.new(1, 0, 0.5, 0),
    Position = UDim2.new(0, 0, 0.5, 0),
    BackgroundColor3 = c2.Header,
    BorderSizePixel = 0,
}, e0)
c5("TextLabel", {
    Text = "🥚  EggStealer Pro",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = c2.Text,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 160, 1, 0),
    Position = UDim2.new(0, 14, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, e0)
c5("TextLabel", {
    Text = "[RShift / Ctrl to Toggle]",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = c2.Sub,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 160, 1, 0),
    Position = UDim2.new(0, 165, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, e0)
local e1 = c5("TextButton", {
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = c2.Sub,
    BackgroundColor3 = Color3.fromRGB(35, 40, 60),
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(1, -66, 0.5, -13),
    BorderSizePixel = 0,
}, e0)
c6(6, e1)
e1.MouseButton1Click:Connect(function()
    d1.Visible = not d1.Visible
end)
local e2 = c5("TextButton", {
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = c2.Sub,
    BackgroundColor3 = Color3.fromRGB(35, 40, 60),
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(1, -34, 0.5, -13),
    BorderSizePixel = 0,
}, e0)
c6(6, e2)
e2.MouseButton1Click:Connect(function()
    if b then
        b("Close")
    end
    _s.alive = false
    _G._EggStealerRunning = false
    if _G._EggStealerSession == _s then
        _G._EggStealerSession = nil
    end
    pcall(function()
        c8:Destroy()
    end)
end)
local e3 = c5("Frame", {
    Size = UDim2.new(1, -24, 0, 32),
    Position = UDim2.new(0, 12, 0, 48),
    BackgroundColor3 = c2.Panel,
    BorderSizePixel = 0,
}, d1)
c6(8, e3)
c7(c2.Border, 1, e3)
local e4 = c5("Frame", {
    Size = UDim2.new(0, 116, 1, -8),
    Position = UDim2.new(0, 6, 0, 4),
    BackgroundColor3 = Color3.fromRGB(22, 26, 40),
    BorderSizePixel = 0,
}, e3)
c6(6, e4)
c5("TextLabel", {
    Text = "⚡ Spd:",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = c2.Sub,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 42, 1, 0),
    Position = UDim2.new(0, 5, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, e4)
local e5 = c5("TextBox", {
    Text = tostring(_s.speed),
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = c2.Accent,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 36, 1, 0),
    Position = UDim2.new(0, 48, 0, 0),
    ClearTextOnFocus = false,
}, e4)
c5("TextLabel", {
    Text = "st/s",
    Font = Enum.Font.Gotham,
    TextSize = 9.5,
    TextColor3 = c2.Sub,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 26, 1, 0),
    Position = UDim2.new(0, 85, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, e4)
e5.FocusLost:Connect(function()
    local a = tonumber(e5.Text)
    if a then
        _s.speed = math.clamp(a, 100, 1100)
    end
    e5.Text = tostring(_s.speed)
end)
local e6 = c5("TextLabel", {
    Text = "🏡 Plot: #...",
    Font = Enum.Font.GothamBold,
    TextSize = 10.5,
    TextColor3 = Color3.fromRGB(120, 200, 255),
    BackgroundColor3 = Color3.fromRGB(18, 30, 48),
    Size = UDim2.new(0, 110, 1, -8),
    Position = UDim2.new(0, 128, 0, 4),
    BorderSizePixel = 0,
}, e3)
c6(6, e6)
c7(Color3.fromRGB(35, 85, 145), 1, e6)
u = function()
    if not _s.plotId then
        a8()
    end
    if e6 and e6.Parent then
        e6.Text = string.format("🏡 Plot: #%s", tostring(_s.plotId or "?"))
    end
end
u()
local e7 = c5("TextLabel", {
    Text = "🥚 Stolen: 0",
    Font = Enum.Font.GothamBold,
    TextSize = 10.5,
    TextColor3 = c2.Accent,
    BackgroundColor3 = Color3.fromRGB(15, 38, 30),
    Size = UDim2.new(0, 114, 1, -8),
    Position = UDim2.new(0, 244, 0, 4),
    BorderSizePixel = 0,
}, e3)
c6(6, e7)
c7(Color3.fromRGB(0, 140, 95), 1, e7)
local e8 = c5("TextLabel", {
    Text = "🧺 Pen: 0/10",
    Font = Enum.Font.GothamBold,
    TextSize = 10.5,
    TextColor3 = c2.Accent,
    BackgroundColor3 = Color3.fromRGB(22, 26, 40),
    Size = UDim2.new(1, -370, 1, -8),
    Position = UDim2.new(0, 364, 0, 4),
    BorderSizePixel = 0,
}, e3)
c6(6, e8)
local e9 = c7(c2.Border, 1, e8)
local function f0()
    local a, b = b0()
    e8.Text = string.format("🧺 Pen: %d/%d", a, b)
    if a >= b then
        e8.TextColor3 = c2.Red
        e9.Color = c2.Red
    elseif a >= 8 then
        e8.TextColor3 = c2.Gold
        e9.Color = c2.Gold
    else
        e8.TextColor3 = c2.Accent
        e9.Color = Color3.fromRGB(0, 140, 95)
    end
end
f0()
local f1 = c5("Frame", {
    Size = UDim2.new(1, -24, 0, 120),
    Position = UDim2.new(0, 12, 0, 84),
    BackgroundColor3 = c2.Panel,
    BorderSizePixel = 0,
}, d1)
c6(8, f1)
c7(c2.Border, 1, f1)
local f2 = c5("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1 }, f1)
local f3 = c5("TextButton", {
    Text = "📍 By Zone (12)",
    Font = Enum.Font.GothamBold,
    TextSize = 10.5,
    TextColor3 = Color3.fromRGB(0, 235, 165),
    BackgroundColor3 = Color3.fromRGB(0, 70, 52),
    Size = UDim2.new(0, 120, 0, 22),
    Position = UDim2.new(0, 6, 0, 2),
    BorderSizePixel = 0,
}, f2)
c6(5, f3)
local f4 = c5("TextButton", {
    Text = "⭐ By Rarity (8)",
    Font = Enum.Font.GothamBold,
    TextSize = 10.5,
    TextColor3 = Color3.fromRGB(150, 160, 185),
    BackgroundColor3 = Color3.fromRGB(22, 26, 40),
    Size = UDim2.new(0, 120, 0, 22),
    Position = UDim2.new(0, 132, 0, 2),
    BorderSizePixel = 0,
}, f2)
c6(5, f4)
local f5 = c5("TextButton", {
    Text = "[+ All]",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = c2.Accent,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 50, 1, 0),
    Position = UDim2.new(1, -112, 0, 0),
}, f2)
local f6 = c5("TextButton", {
    Text = "[✕ Clear]",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = c2.Red,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 52, 1, 0),
    Position = UDim2.new(1, -58, 0, 0),
}, f2)
local f7 = c5(
    "Frame",
    { Size = UDim2.new(1, -16, 0, 86), Position = UDim2.new(0, 8, 0, 28), BackgroundTransparency = 1, Visible = true },
    f1
)
c5(
    "UIGridLayout",
    { CellSize = UDim2.new(0, 118, 0, 24), CellPadding = UDim2.new(0, 6, 0, 4), SortOrder = Enum.SortOrder.LayoutOrder },
    f7
)
local f8 = c5(
    "Frame",
    { Size = UDim2.new(1, -16, 0, 86), Position = UDim2.new(0, 8, 0, 28), BackgroundTransparency = 1, Visible = false },
    f1
)
c5(
    "UIGridLayout",
    { CellSize = UDim2.new(0, 118, 0, 36), CellPadding = UDim2.new(0, 6, 0, 6), SortOrder = Enum.SortOrder.LayoutOrder },
    f8
)
local f9, g0 = {}, {}
local g1 = {}
local function g2(a)
    local b = f9[a]
    if not b then
        return
    end
    local c = (_s.selectedZones[a] == true)
    b.BackgroundColor3 = c and Color3.fromRGB(0, 70, 52) or Color3.fromRGB(22, 26, 40)
    b.TextColor3 = c and Color3.fromRGB(0, 235, 165) or Color3.fromRGB(150, 160, 185)
    local d = b:FindFirstChildOfClass("UIStroke")
    if d then
        d.Color = c and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(38, 44, 68)
    end
end
local function g3(a)
    local b = g0[a]
    if not b then
        return
    end
    local c = (_s.selectedRarities[a] == true)
    local d = c3[a] or c2.Accent
    b.BackgroundColor3 = c and Color3.fromRGB(45, 30, 60) or Color3.fromRGB(22, 26, 40)
    b.TextColor3 = c and d or Color3.fromRGB(150, 160, 185)
    local e = b:FindFirstChildOfClass("UIStroke")
    if e then
        e.Color = c and d or Color3.fromRGB(38, 44, 68)
        e.Thickness = c and 1.5 or 1
    end
end
local function g4()
    for a, b in ipairs(L) do
        g2(b)
    end
end
local function g5()
    for a, b in ipairs(Z) do
        g3(b)
    end
end
local function g6()
    local a = (_s.filterMode == "ZONE")
    f3.BackgroundColor3 = a and Color3.fromRGB(0, 70, 52) or Color3.fromRGB(22, 26, 40)
    f3.TextColor3 = a and Color3.fromRGB(0, 235, 165) or Color3.fromRGB(150, 160, 185)
    f4.BackgroundColor3 = not a and Color3.fromRGB(50, 25, 75) or Color3.fromRGB(22, 26, 40)
    f4.TextColor3 = not a and Color3.fromRGB(217, 70, 239) or Color3.fromRGB(150, 160, 185)
    f7.Visible = a
    f8.Visible = not a
end
f3.MouseButton1Click:Connect(function()
    _s.filterMode = "ZONE"
    g6()
end)
f4.MouseButton1Click:Connect(function()
    _s.filterMode = "RARITY"
    g6()
end)
for cr, cs in ipairs(L) do
    local a = c5("TextButton", {
        Text = cs,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(150, 160, 185),
        BackgroundColor3 = Color3.fromRGB(22, 26, 40),
        BorderSizePixel = 0,
        LayoutOrder = cr,
    }, f7)
    c6(5, a)
    c7(Color3.fromRGB(38, 44, 68), 1, a)
    f9[cs] = a
    a.MouseButton1Click:Connect(function()
        if next(_s.selectedRarities) ~= nil then
            _s.selectedRarities = {}
            g5()
        end
        _s.selectedZones[cs] = not (_s.selectedZones[cs] == true)
        g2(cs)
        if O and g1 then
            O(g1)
        end
    end)
end
for cr, cs in ipairs(Z) do
    local a = c5("TextButton", {
        Text = cs,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(150, 160, 185),
        BackgroundColor3 = Color3.fromRGB(22, 26, 40),
        BorderSizePixel = 0,
        LayoutOrder = cr,
    }, f8)
    c6(6, a)
    c7(Color3.fromRGB(38, 44, 68), 1, a)
    g0[cs] = a
    a.MouseButton1Click:Connect(function()
        if next(_s.selectedZones) ~= nil then
            _s.selectedZones = {}
            g4()
        end
        _s.selectedRarities[cs] = not (_s.selectedRarities[cs] == true)
        g3(cs)
        if O and g1 then
            O(g1)
        end
    end)
end
f5.MouseButton1Click:Connect(function()
    if _s.filterMode == "ZONE" then
        _s.selectedRarities = {}
        g5()
        for a, b in ipairs(L) do
            _s.selectedZones[b] = true
        end
        g4()
    else
        _s.selectedZones = {}
        g4()
        for a, b in ipairs(Z) do
            _s.selectedRarities[b] = true
        end
        g5()
    end
    if O and g1 then
        O(g1)
    end
end)
f6.MouseButton1Click:Connect(function()
    if _s.filterMode == "ZONE" then
        _s.selectedZones = {}
        g4()
    else
        _s.selectedRarities = {}
        g5()
    end
    _s.selected = {}
    if O and g1 then
        O(g1)
    end
end)
local ct = c5("Frame", {
    Size = UDim2.new(1, -24, 0, 22),
    Position = UDim2.new(0, 12, 0, 208),
    BackgroundColor3 = c2.Header,
    BorderSizePixel = 0,
}, d1)
c6(5, ct)
local function g7(a, b, c)
    c5("TextLabel", {
        Text = a,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = c2.Sub,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, c, 1, 0),
        Position = UDim2.new(0, b, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, ct)
end
g7("☑", 8, 20)
g7("Egg Name", 34, 150)
g7("Rarity", 190, 84)
g7("Zone", 280, 84)
g7("Distance", 370, 90)
local cv = c5("ScrollingFrame", {
    Size = UDim2.new(1, -24, 0, 378),
    Position = UDim2.new(0, 12, 0, 234),
    BackgroundColor3 = c2.Panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = c2.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, d1)
c6(8, cv)
c7(c2.Border, 1, cv)
c5("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) }, cv)
local cw = c5("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    Position = UDim2.new(0, 0, 1, -50),
    BackgroundColor3 = c2.Header,
    BorderSizePixel = 0,
}, d1)
c5("Frame", { Size = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = c2.Header, BorderSizePixel = 0 }, cw)
local cx = c5("TextLabel", {
    Text = "⏸ Ready",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = c2.Sub,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -210, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, cw)
local cy = c5("TextButton", {
    Text = "🔄",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = c2.Text,
    BackgroundColor3 = Color3.fromRGB(30, 38, 62),
    Size = UDim2.new(0, 34, 0, 32),
    Position = UDim2.new(1, -200, 0.5, -16),
    BorderSizePixel = 0,
}, cw)
c6(8, cy)
local cz = c5("TextButton", {
    Text = "All",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = c2.Text,
    BackgroundColor3 = Color3.fromRGB(30, 38, 62),
    Size = UDim2.new(0, 38, 0, 32),
    Position = UDim2.new(1, -160, 0.5, -16),
    BorderSizePixel = 0,
}, cw)
c6(8, cz)
local g8 = c5("TextButton", {
    Text = "▶ START",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(8, 18, 12),
    BackgroundColor3 = c2.Accent,
    Size = UDim2.new(0, 96, 0, 36),
    Position = UDim2.new(1, -106, 0.5, -18),
    BorderSizePixel = 0,
}, cw)
c6(10, g8)
local g9, h0 = {}, {}
r = function(a, b)
    local c = tostring(a)
    local d = h0[c]
    if d and d.chk then
        d.chk.Text = b and "☑" or "☐"
        d.chk.TextColor3 = b and c2.Check or c2.Sub
    elseif g9[c] then
        for e, f in ipairs(g9[c]:GetChildren()) do
            if f:IsA("TextButton") then
                f.Text = b and "☑" or "☐"
                f.TextColor3 = b and c2.Check or c2.Sub
                break
            end
        end
    end
end
local function h1(a, b, c)
    local d = tostring(a.Uid)
    local e = a.DisplayName
    local f = a.ResolvedRarity
    local g = a.ResolvedZone
    local h = a.ResolvedPos
    local i = c or a9()
    local j = math.floor((i - h).Magnitude)
    local k = b % 2 == 0 and c2.Row1 or c2.Row2
    local l = g and (_s.selectedZones[g] == true)
    local m = f and (_s.selectedRarities[f] == true)
    local n = l or m
    local o = (_s.selected[d] == false)
    local p = (_s.selected[d] == true)
    local q = (n and not o) or p
    local r =
        c5("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = k, BorderSizePixel = 0, LayoutOrder = b }, cv)
    local s = c5("TextButton", {
        Text = q and "☑" or "☐",
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = q and c2.Check or c2.Sub,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
    }, r)
    c5("TextLabel", {
        Text = e,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = c2.Text,
        BackgroundTransparency = 1,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, r)
    c5("TextLabel", {
        Text = f,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = c4(f),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 84, 1, 0),
        Position = UDim2.new(0, 190, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, r)
    c5("TextLabel", {
        Text = g,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = c2.Sub,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 84, 1, 0),
        Position = UDim2.new(0, 280, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, r)
    local t = j < 150 and c2.Accent or (j < 400 and c2.Gold or c2.Sub)
    local u = c5("TextLabel", {
        Text = tostring(j) .. " st",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = t,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(0, 370, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, r)
    s.MouseButton1Click:Connect(function()
        local v = g and (_s.selectedZones[g] == true)
        local w = f and (_s.selectedRarities[f] == true)
        local x = v or w
        local y = (_s.selected[d] == true) or (x and _s.selected[d] ~= false)
        if y then
            _s.selected[d] = false
        else
            _s.selected[d] = true
        end
        local z = (_s.selected[d] == true) or (x and _s.selected[d] ~= false)
        s.Text = z and "☑" or "☐"
        s.TextColor3 = z and c2.Check or c2.Sub
    end)
    g9[d] = r
    h0[d] = { row = r, chk = s, distLbl = u, egg = a }
    return r
end
V = function(a)
    local b = a9()
    local c = {}
    for d, e in ipairs(a) do
        c[tostring(e.Uid)] = e
    end
    for d, e in pairs(g9) do
        if not c[d] then
            pcall(function()
                e:Destroy()
            end)
            g9[d] = nil
            h0[d] = nil
            _s.selected[d] = nil
        end
    end
    for d, e in ipairs(a) do
        local f = tostring(e.Uid)
        local g = h0[f]
        local h = math.floor((b - e.ResolvedPos).Magnitude)
        local i = h < 150 and c2.Accent or (h < 400 and c2.Gold or c2.Sub)
        local j = d % 2 == 0 and c2.Row1 or c2.Row2
        if g and g.row and g.row.Parent then
            g.row.LayoutOrder = d
            g.row.BackgroundColor3 = j
            g.distLbl.Text = tostring(h) .. " st"
            g.distLbl.TextColor3 = i
            local k = e.ResolvedZone
            local l = e.ResolvedRarity
            local m = k and (_s.selectedZones[k] == true)
            local n = l and (_s.selectedRarities[l] == true)
            local o = m or n
            local p = (_s.selected[f] == false)
            local q = (_s.selected[f] == true)
            local r = (o and not p) or q
            g.chk.Text = r and "☑" or "☐"
            g.chk.TextColor3 = r and c2.Check or c2.Sub
        else
            h1(e, d, b)
        end
    end
    g1 = a
end
O = function(a)
    V(a)
end
m = function()
    task.spawn(function()
        local a = b3()
        local b = a9()
        table.sort(a, function(c, d)
            return (b - c.ResolvedPos).Magnitude < (b - d.ResolvedPos).Magnitude
        end)
        V(a)
        f0()
        if not _s.running then
            _msg(string.format("📋 Found %d Eggs", #a))
        end
    end)
end
cy.MouseButton1Click:Connect(function()
    U()
    m()
end)
cz.MouseButton1Click:Connect(function()
    local a = false
    for b, c in ipairs(L) do
        if _s.selectedZones[c] == true then
            a = true
            break
        end
    end
    if not a then
        for b, c in ipairs(Z) do
            if _s.selectedRarities[c] == true then
                a = true
                break
            end
        end
    end
    if not a then
        for b in pairs(g9) do
            if _s.selected[b] == true then
                a = true
                break
            end
        end
    end
    local b = not a
    cz.Text = b and "None" or "All"
    if b then
        U()
    end
    if _s.filterMode == "ZONE" then
        for c, d in ipairs(L) do
            _s.selectedZones[d] = b
        end
        g4()
    else
        for c, d in ipairs(Z) do
            _s.selectedRarities[d] = b
        end
        g5()
    end
    for c in pairs(g9) do
        _s.selected[c] = b
    end
    if g1 then
        V(g1)
    end
end)
task.spawn(function()
    while c8.Parent and _s.alive do
        task.wait(1.5)
        pcall(function()
            if u then
                u()
            end
            if e7 and e7.Parent then
                e7.Text = string.format("🥚 Stolen: %d", _s.stolenCount or 0)
            end
            if e8 and e8.Parent then
                f0()
            end
        end)
        pcall(function()
            local a = b3()
            local b = a9()
            table.sort(a, function(c, d)
                return (b - c.ResolvedPos).Magnitude < (b - d.ResolvedPos).Magnitude
            end)
            V(a)
        end)
    end
end)
task.spawn(function()
    local a = ""
    while _s.alive and c8.Parent do
        if a ~= x then
            a = x
            pcall(function()
                if cx and cx.Parent then
                    cx.Text = x
                end
            end)
        end
        task.wait(0.1)
    end
end)
b = function(a)
    _s.running = false
    _s.holdingForGuard = false
    _msg(a or "⏸ Idle")
    pcall(function()
        g8.Text = "▶ START"
        g8.BackgroundColor3 = c2.Accent
        g8.TextColor3 = Color3.fromRGB(8, 18, 12)
        cx.TextColor3 = c2.Sub
    end)
    local b = S.Character
    if b then
        local c = b:FindFirstChild("HumanoidRootPart")
        if c then
            c.AssemblyLinearVelocity = Vector3.zero
            c.AssemblyAngularVelocity = Vector3.zero
        end
        _g(b)
    end
end
c = function()
    if _s.running then
        return
    end
    local a = false
    for b, c in pairs(_s.selectedZones) do
        if c == true then
            a = true
            break
        end
    end
    if not a then
        for b, c in pairs(_s.selectedRarities) do
            if c == true then
                a = true
                break
            end
        end
    end
    if not a then
        for b, c in pairs(_s.selected) do
            if c == true then
                a = true
                break
            end
        end
    end
    if not a then
        _msg("⚠️ Select filter first")
        return
    end
    U()
    _s.running = true
    pcall(function()
        g8.Text = "⏹ STOP"
        g8.BackgroundColor3 = c2.Red
        g8.TextColor3 = c2.Text
        cx.TextColor3 = c2.Accent
    end)
    _msg("🚀 Running...")
    task.spawn(function()
        c1()
        if not _s.running then
            b("⏸ Idle")
        end
    end)
end
g8.MouseButton1Click:Connect(function()
    if _s.running then
        b("⏸ Stopped")
    else
        c()
    end
end)
d1.Size = UDim2.new(0, 0, 0, 0)
X:Create(d1, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 530, 0, 670) })
    :Play()
task.delay(0.3, m)
