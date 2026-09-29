local fn, v, v2, defaultTab, Players, RunService, ReplicatedStorage, CoreGui, UserInputService, localPlayer
local networking, fn2, tbl, v3, fn3, fn4, tbl2, fn5, fn6, tbl3
local tbl4, fn7, tbl5, v4, v5, espSection, tbl6, color, sequence, palettes

do
	local CollectionService, ProximityPromptService, v6, v7, tbl7, tbl8, tbl9

	do
		fn = function(arg)
			local genv = typeof(getgenv) == "function" and getgenv() or _G

			if type(genv.ChilliDebugPrint) == "function" then
				pcall(genv.ChilliDebugPrint, arg)
			end
		end

		task.spawn(pcall, function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/refs/heads/main/DiscordLink"))()
		end)

		local function fn8()
			local response = nil

			local function fn9()
				if type(response) == "string" and #response > 0 then
					return response
				end
				response = game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli%20Library")
				return response
			end

			local function fn10()
				local chilliHubSaeCleanup = (typeof(getgenv) == "function" and getgenv() or _G).ChilliHubSaeCleanup

				if type(chilliHubSaeCleanup) == "function" then
					pcall(chilliHubSaeCleanup)
				end

				local tbl10 = { game:GetService("CoreGui") }

				if typeof(gethui) == "function" then
					local ok, result = pcall(gethui)

					if ok and typeof(result) == "Instance" then
						table.insert(tbl10, result)
					end
				end

				local tbl11 = {
					Settings = true,
					ChilliLeftCenter = true,
					ChilliLibrarySettings = true,
					ChilliLibraryLauncher = true,
				}

				local n = 0

				for _, v8 in ipairs(tbl10) do
					for _, child in ipairs(v8:GetChildren()) do
						if child:IsA("ScreenGui") and (child:GetAttribute("ChilliLibraryOwned") == true or tbl11[child.Name]) then
							pcall(function()
								child:Destroy()
							end)

							n += 1
						end
					end
				end

				if n > 0 then
					fn("cleared " .. n .. " leftover Chilli UI screens")
				end
			end

			local function fn11()
				local v8 = fn9()
				local chunk, v9 = loadstring(v8)
				assert(chunk, v9)
				local v10 = chunk()
				assert(type(v10) == "function", "Chilli Library bootstrap is invalid.")
				local v11 = table.create(45)
				local n = 1

				for i = 1, 90, 2 do
					v11[n] = string.char(bit32.bxor(tonumber(string.sub("306908100841206d474f00185f26635b2101387507010810127d7d477a473b6f435a0916573165562900226c00", i, i + 1), 16), string.byte("s9K!2vQ#", (n - 1) % 8 + 1)))
					n += 1
				end

				return v10(table.concat(v11))
			end

			local chilliLibraryFailedToLoad = "unknown"

			for i = 1, 6 do
				task.wait()
				pcall(fn10)
				local ok, result = pcall(fn11)
				if ok and type(result) == "table" then
					return result
				end
				chilliLibraryFailedToLoad = tostring(result)

				if type(chilliLibraryFailedToLoad) == "string" and string.find(chilliLibraryFailedToLoad, "HttpGet", 1, true) then
					response = nil
				end

				fn("library load attempt " .. i .. " failed: " .. chilliLibraryFailedToLoad)
				task.wait(1 + i * 0.5)
			end

			error("Chilli Library failed to load: " .. chilliLibraryFailedToLoad, 0)
		end

		v = fn8()
		assert(type(v) == "table" and type(v.CreateWindow) == "function" and type(v.Finalize) == "function", "Chilli Library returned an invalid API.")

		v.ManualQuickDefaults = {
			PinnedFeatures = { "Player > Movement > Speed Boost", "Player > Movement > Boost Speed" },
			Keybinds = { ["Player > Movement > Speed Boost"] = "Q" },
			PinGroups = {},
			LeftCenterHidden = true,
		}

		v2 = v:CreateWindow({ Name = "Chilli Hub - Steal An Egg", DefaultTab = "Farm" })
		defaultTab = v2:GetDefaultTab()
		Players = game:GetService("Players")
		RunService = game:GetService("RunService")
		ReplicatedStorage = game:GetService("ReplicatedStorage")
		CoreGui = game:GetService("CoreGui")
		UserInputService = game:GetService("UserInputService")
		CollectionService = game:GetService("CollectionService")
		game:GetService("LocalizationService")
		ProximityPromptService = game:GetService("ProximityPromptService")
		localPlayer = Players.LocalPlayer
		networking = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Networking")

		fn2 = function(arg)
			local ok, result = pcall(function()
				return require(arg())
			end)

			return ok and result or nil
		end

		tbl = {
			EggState = fn2(function()
				return ReplicatedStorage.Client.EggState
			end),
			AreaEggs = fn2(function()
				return ReplicatedStorage.Shared.Types.AreaEggs
			end),
			ToolGameplayGuard = fn2(function()
				return ReplicatedStorage.Client.ToolGameplayGuard
			end),
			Assets = fn2(function()
				return ReplicatedStorage.Data.Assets
			end),
			Guards = fn2(function()
				return ReplicatedStorage.Data.Guards
			end),
			EggRecords = fn2(function()
				return ReplicatedStorage.Shared.Util.EggRecords
			end),
			Mutations = fn2(function()
				return ReplicatedStorage.Shared.Modules.Mutations
			end),
			Save = fn2(function()
				return ReplicatedStorage.Shared.Save
			end),
			FuseKernel = fn2(function()
				return ReplicatedStorage.Shared.Util.FuseKernel
			end),
			AreaEggCycle = fn2(function()
				return ReplicatedStorage.Shared.Util.AreaEggCycle
			end),
			AreaEggResetWall = fn2(function()
				return ReplicatedStorage.Client.AreaEggResetWall
			end),
			AreaEggResetCycle = fn2(function()
				return ReplicatedStorage.Data.AreaEggResetCycle
			end),
			Gears = fn2(function()
				return ReplicatedStorage.Data.Gears
			end),
			Areas = fn2(function()
				return ReplicatedStorage.Data.Areas
			end),
			LimitedEgg = fn2(function()
				return ReplicatedStorage.Data.LimitedEgg
			end),
			BrainrotEgg = fn2(function()
				return ReplicatedStorage.Data.BrainrotEgg
			end),
			MonsterEgg = fn2(function()
				return ReplicatedStorage.Data.MonsterEgg
			end),
		}

		local save = tbl.Save

		if type(save) == "table" and (type(save.Get) ~= "function" or type(save.FieldSignal) ~= "function") then
			tbl.Save = setmetatable({
				Get = type(save.Get) == "function" and save.Get or save.Peek,
				FieldSignal = type(save.FieldSignal) == "function" and save.FieldSignal or save.Watch,
			}, { __index = save })
		end

		local function fn9()
			if typeof(gethui) == "function" then
				local ok, result = pcall(gethui)
				if ok and typeof(result) == "Instance" then
					return result
				end
			end

			return CoreGui
		end

		v3 = fn9()

		do
			local v8 = Random.new()
			local str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

			fn3 = function()
				local v9 = v8:NextInteger(12, 20)
				local v10 = table.create(v9)

				for i = 1, v9 do
					local v11 = v8:NextInteger(1, #str)
					v10[i] = string.sub("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", v11, v11)
				end

				return table.concat(v10)
			end
		end

		do
			local tbl10 = {}

			fn4 = function(arg)
				table.insert(tbl10, arg)
			end

			tbl2 = {}

			fn5 = function(arg, arg2)
				local n = 1000
				local n2 = 3
				local n3 = 12

				local function fn10(arg3)
					if arg3 <= 0 then
						return 0
					end
					local n4 = 10 ^ (math.floor(math.log10(arg3)) - 2)
					return math.floor(arg3 / n4 + 0.5) * n4
				end

				local function fn11(arg3)
					local n4 = math.clamp(tonumber(arg3) or 0, 0, 1000)
					if n4 <= 0 then
						return 0
					end
					return fn10(10 ^ (n2 + (n3 - n2) * n4 / n))
				end

				local function fn12(arg3)
					local n4 = tonumber(arg3) or 0
					if n4 <= 0 then
						return 0
					end
					local n5 = n3 - n2
					return math.clamp(math.floor((math.log10(n4) - n2) / n5 * n * 100 + 0.5) / 100, 0, 1000)
				end

				local function fn13(arg3)
					local str = string.format(arg3 >= 100 and "%.0f" or arg3 >= 10 and "%.1f" or "%.2f", arg3)

					if string.find(str, ".", 1, true) then
						str = string.gsub(string.gsub(str, "0+$", ""), "%.$", "")
					end

					return str
				end

				local function fn14(arg3)
					local v8 = fn11(arg3)
					if v8 <= 0 then
						return "Off"
					end

					if v8 < 1000000 then
						return fn13(v8 / 1000) .. " K/s"
					end

					if v8 < 1e9 then
						return fn13(v8 / 1000000) .. " M/s"
					end
					return fn13(v8 / 1e9) .. " B/s"
				end

				local function fn15(arg3)
					local v8 = fn11(arg3)
					if v8 <= 0 then
						return "0"
					end

					if v8 < 1000000 then
						return fn13(v8 / 1000) .. "k"
					end
					return (string.gsub(string.gsub(string.format("%.3f", v8 / 1000000), "0+$", ""), "%.$", ""))
				end

				local tbl11 = { k = 1000, m = 1000000, b = 1e9, t = 1e12 }

				local function fn16(arg3)
					local v8 = string.gsub(string.lower(string.gsub(tostring(arg3 or ""), "[%s,/]", "")), "s$", "")
					if v8 == "" or v8 == "off" then
						return 0
					end
					local v9, v10 = string.match(v8, "^([%d%.]+)([kmbt]?)$")
					local num = tonumber(v9)
					if not num then
						return nil
					end
					return fn12(num * (tbl11[v10] or 1000000))
				end

				local v8 = arg:CreateSlider({
					Name = arg2.Name,
					Note = arg2.Note,
					SubOf = arg2.SubOf,
					Min = 0,
					Max = n,
					Default = fn12(arg2.Default or 0),
					AllowDecimals = true,
					Increment = 0.01,
					ValueFormat = fn14,
					ValueParse = fn16,
					Callback = function(arg3)
						if type(arg2.OnRaw) == "function" then
							arg2.OnRaw(fn11(arg3))
						end
					end,
				})

				local value = type(v8) == "table" and rawget(v8, "Instance") or nil

				if typeof(value) == "Instance" then
					for _, descendant in ipairs(value:GetDescendants()) do
						if descendant:IsA("TextBox") then
							local connection = descendant.Focused:Connect(function()
								task.defer(function()
									if descendant:IsFocused() then
										local ok, result = pcall(v8.Get, v8)
										descendant.Text = fn15(ok and result or 0)
										descendant.CursorPosition = #descendant.Text + 1
										descendant.SelectionStart = 1
									end
								end)
							end)

							fn4(function()
								pcall(function()
									connection:Disconnect()
								end)
							end)
						end
					end
				end

				if type(arg2.Legacy) == "string" and type(arg2.SectionName) == "string" then
					table.insert(tbl2, { Handle = v8, Name = arg2.Name, Legacy = arg2.Legacy, Section = arg2.SectionName, StepOf = fn12 })
				end

				return v8
			end

			local text = "All"

			fn6 = function(arg)
				if type(arg) ~= "table" then
					return arg
				end
				local value = rawget(arg, "Instance")
				if typeof(value) ~= "Instance" then
					return arg
				end
				local flag = false

				local function fn10(arg2)
					if flag then
						return
					end

					if arg2.Text == "None" then
						flag = true
						arg2.Text = text
						flag = false
					end
				end

				local function fn11(descendant)
					if not descendant:IsA("TextLabel") or descendant.Name ~= "Value" then
						return
					end
					fn10(descendant)

					local connection = descendant:GetPropertyChangedSignal("Text"):Connect(function()
						fn10(descendant)
					end)

					fn4(function()
						pcall(function()
							connection:Disconnect()
						end)
					end)
				end

				for _, descendant in ipairs(value:GetDescendants()) do
					fn11(descendant)
				end

				local connection = value.DescendantAdded:Connect(fn11)

				fn4(function()
					pcall(function()
						connection:Disconnect()
					end)
				end)

				return arg
			end

			local genv = typeof(getgenv) == "function" and getgenv() or _G
			local chilliHubSaeCleanup = genv.ChilliHubSaeCleanup

			if type(chilliHubSaeCleanup) == "function" then
				pcall(chilliHubSaeCleanup)
			end

			genv.ChilliHubSaeCleanup = function()
				for i = #tbl10, 1, -1 do
					pcall(tbl10[i])
				end

				table.clear(tbl10)
			end
		end

		do
			local n = 0
			local fn10 = nil

			fn10 = function(arg, arg2)
				local n2 = arg2 or 0

				if type(arg) == "table" then
					if n2 > 3 then
						return
					end
					local n3 = 0

					for k, v8 in pairs(arg) do
						n3 += 1

						if not (n3 > 20) then
							fn10(k, n2 + 1)
							fn10(v8, n2 + 1)
							continue
						end

						break
					end
				elseif typeof(arg) == "Instance" then
					pcall(arg.GetFullName, arg)
				else
					n += #tostring(arg)
				end
			end

			local tbl10 = {}

			local function fn11(arg)
				tbl10[#tbl10 + 1] = arg
			end

			local function fn12()
				for _, v8 in ipairs(tbl10) do
					pcall(function()
						v8:Disconnect()
					end)
				end

				table.clear(tbl10)
			end

			local function chilliToolKeeper()
				fn12()

				for _, v8 in ipairs({
					"RE/GearSatchel/Lost",
					"RE/GearSatchel/Gained",
					"RE/RigSync/ProbeSatchel",
					"RE/RigSync/SeedSatchel",
					"RE/RigSync/CorrectionBegan",
					"RE/RigSync/Refresh",
					"RE/ToolTrigger/Trigger",
					"RE/BatSwing/Trigger",
				}) do
					local v9 = networking:FindFirstChild(v8)

					if v9 and v9:IsA("RemoteEvent") then
						fn11(v9.OnClientEvent:Connect(function(...)
							fn10({ ... })
						end))
					end
				end

				local function fn13(arg)
					if not arg then
						return
					end

					fn11(arg.ChildRemoved:Connect(function(child)
						if child:IsA("Tool") then
							fn10({ child.Name, child.Parent })
						end
					end))

					fn11(arg.ChildAdded:Connect(function(child)
						if child:IsA("Tool") then
							fn10({ child.Name })
						end
					end))
				end

				fn13(localPlayer:FindFirstChildOfClass("Backpack"))

				fn11(localPlayer.ChildAdded:Connect(function(child)
					if child:IsA("Backpack") then
						fn13(child)
					end
				end))

				task.spawn(function()
					pcall(function()
						local v8 = tbl.Save.Get()
						fn10({ v8.GearInventory, v8.Inventory }, 2)
					end)

					if type(getgc) == "function" then
						pcall(function()
							for _, v8 in ipairs(getgc(false)) do
								if type(v8) == "function" and islclosure(v8) then
									pcall(debug.info, v8, "n")
								end
							end
						end)
					end
				end)
			end
			;(typeof(getgenv) == "function" and getgenv() or _G).ChilliToolKeeper = chilliToolKeeper
			task.defer(chilliToolKeeper)
			fn4(fn12)
		end

		do
			local n = 0.35
			local n2 = 5
			local tbl10 = {}
			local flag = true

			tbl3 = {
				Add = function(arg)
					local tbl11 = { Run = arg, Gap = n, Idle = n2, Repeat = false, Hold = 0 }
					table.insert(tbl10, tbl11)
					return tbl11
				end,
				Wake = function()
					flag = true
				end,
				Backoff = function(arg, arg2)
					if arg then
						arg.Hold = tonumber(arg2) or 6
					end
				end,
			}

			local connection = RunService.Heartbeat:Connect(function(deltaTime)
				local v8 = flag
				flag = false

				for _, v9 in ipairs(tbl10) do
					v9.Gap = v9.Gap + deltaTime
					v9.Idle = v9.Idle + deltaTime

					if v9.Hold > 0 then
						v9.Hold = v9.Hold - deltaTime
					else
						local flag2 = v9.Gap >= n
						local repeat_

						if flag2 then
							repeat_ = v8 or v9.Repeat or v9.Idle >= n2
						else
							repeat_ = flag2
						end

						if repeat_ then
							v9.Gap = 0
							v9.Idle = 0
							local ok, result = pcall(v9.Run, v9)
							v9.Repeat = ok and result == true
						end
					end
				end
			end)

			fn4(function()
				connection:Disconnect()
			end)
		end

		v6 = defaultTab:CreateSection({ Name = "Dr Scramble Lab & Mech", Expanded = false })
		local v8
		v8 = defaultTab:CreateSection({ Name = "Auto Steal", Expanded = true })
		local v9
		v9 = defaultTab:CreateSection({ Name = "Auto Place Egg", Expanded = false })
		local v10
		v10 = defaultTab:CreateSection({ Name = "Auto Treadmill", Expanded = false })
		local v11
		v11 = defaultTab:CreateSection({ Name = "Auto Hatch & Equip", Expanded = false })
		local v12
		v12 = defaultTab:CreateSection({ Name = "Auto Sell", Expanded = false })
		local v13
		v13 = defaultTab:CreateSection({ Name = "Auto Fuse Machine", Expanded = false })
		v7 = defaultTab:CreateSection({ Name = "Auto Favorite", Expanded = false })
		tbl7 = { Paused = false }

		do
			local n = 0.5
			local v14 = nil
			local tbl10 = nil
			local tbl11 = {}
			local flag = false
			local n2 = 0

			local function fn10()
				for i = #tbl11, 1, -1 do
					local v15 = tbl11[i]

					if v15 and v15.Connected then
						v15:Disconnect()
					end

					tbl11[i] = nil
				end
			end

			local function fn11()
				fn10()
				local v15 = v14
				local v16 = tbl10
				v14 = nil
				tbl10 = nil
				if not v15 or not v15.Parent or not v16 then
					return
				end

				pcall(function()
					v15.BreakJointsOnDeath = v16.BreakJointsOnDeath
					v15.RequiresNeck = v16.RequiresNeck
					v15:SetStateEnabled(Enum.HumanoidStateType.Dead, v16.DeadEnabled)
				end)
			end

			local function fn12(arg)
				if not arg or not arg.Parent then
					return false
				end

				return pcall(function()
					arg.BreakJointsOnDeath = false
					arg.RequiresNeck = false
					arg:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				end) and arg.BreakJointsOnDeath == false and arg.RequiresNeck == false and arg:GetStateEnabled(Enum.HumanoidStateType.Dead) == false
			end

			local function fn13(arg)
				if tbl7.Paused or arg ~= v14 or not arg or not arg.Parent or flag then
					return false
				end
				local maxHealth = arg.MaxHealth
				if maxHealth <= 0 then
					return false
				end

				if maxHealth == math.huge or arg.Health >= maxHealth then
					return true
				end
				flag = true

				local ok = pcall(function()
					arg.Health = maxHealth
				end)

				flag = false
				return ok and arg.Health >= maxHealth
			end

			local function fn14(arg)
				if arg == v14 and arg and arg.Parent then
					return true
				end
				fn11()
				if not arg or not arg:IsA("Humanoid") or not arg.Parent then
					return false
				end
				v14 = arg

				tbl10 = {
					BreakJointsOnDeath = arg.BreakJointsOnDeath,
					RequiresNeck = arg.RequiresNeck,
					DeadEnabled = arg:GetStateEnabled(Enum.HumanoidStateType.Dead),
				}

				if not fn12(arg) then
					fn11()
					return false
				end
				fn13(arg)

				tbl11[#tbl11 + 1] = arg.HealthChanged:Connect(function()
					fn13(arg)
				end)

				tbl11[#tbl11 + 1] = arg:GetPropertyChangedSignal("MaxHealth"):Connect(function()
					fn13(arg)
				end)

				tbl11[#tbl11 + 1] = arg.StateChanged:Connect(function(old, new)
					if new == Enum.HumanoidStateType.Dead and not tbl7.Paused then
						fn12(arg)
						fn13(arg)
					end
				end)

				n2 = os.clock()
				return true
			end

			local function fn15()
				local character = localPlayer.Character
				return character and character:FindFirstChildOfClass("Humanoid") or nil
			end

			local connection = localPlayer.CharacterAdded:Connect(function()
				task.defer(function()
					fn14(fn15())
				end)
			end)

			local connection2 = RunService.Heartbeat:Connect(function()
				local now = os.clock()
				if tbl7.Paused or now - n2 < n then
					return
				end
				n2 = now
				local v15 = fn15()
				if v15 ~= v14 then
					fn14(v15)
					return
				end

				if v15 then
					fn12(v15)
					fn13(v15)
				end
			end)

			task.defer(function()
				fn14(fn15())
			end)

			fn4(function()
				if connection then
					connection:Disconnect()
				end

				if connection2 then
					connection2:Disconnect()
				end

				fn11()
			end)
		end

		local tbl10 = { "bat", "katana", "axe", "staff", "club", "hammer", "sword", "blade" }

		tbl4 = {
			Steal = { Active = false, LastFinishedAt = 0, Carrying = false },
			SafeCarry = {
				Enabled = true,
				SkipUnsafe = false,
				WaitGuard = false,
				SameSpeedBigEggs = false,
				Blocked = {},
				StretchSeconds = 6,
				BeatGuard = false,
				SlowUntil = 0,
				SlowFactor = 0.3,
				LineDrop = false,
				LineGap = 12,
				LineWait = 15,
				DirectBudget = 450,
				DirectMargin = 0.3,
				CrossNow = false,
				CrossSpeed = 231,
				PickupSpeed = 154,
				HopRatio = 1.515,
				CrossRatio = 1,
				PickupRatio = 0.667,
				FarFromLine = 150,
				DropDelay = 0.19,
				LineApproach = 0.97,
				ReJump = true,
				ShakeTime = 0,
				SnapPickup = false,
				Hops = true,
				HopStep = 350,
				HopGap = 0.1,
				HopLift = 42,
				HopStop = 48,
				GetUp = true,
				ShakeInside = 1,
				CarryScale = 1,
				EasyRatio = 1.3,
				LastSkip = nil,
				Category = nil,
				PlanOk = true,
				LightMult = 0.96,
				Height = 70,
				ClimbShare = 0.5,
				Approach = "Run",
				RunSpeed = 1,
				RunWait = 0,
				RunAnimate = true,
				RunHeight = 50,
				SnapLimit = 90,
				StraightRun = true,
				RunStyle = "Velocity",
				CarryStyle = "Velocity",
				SpeedJitter = 0.08,
				Wobble = 0,
				LaneOffset = 0,
				JumpsPerMinute = 0,
				PausesPerMinute = 0,
				ReactMin = 0.2,
				ReactMax = 0.6,
				CarryReact = 0,
				SpeedRatio = 1.5,
				ExcessSeconds = 5.5,
				GuardMargin = 4,
				GuardRatio = 1.06,
				MinRatio = 1.1,
				BaseWait = 6.5,
				FreeJump = 1500,
				WaitRate = 0.9,
				RecoverTries = math.huge,
				GuessMult = 0.93,
				CarryRatio = 0.9,
				Mult = 1,
				Seen = {},
				JumpDistance = 0,
				JumpAt = 0,
				LastDelivered = 0,
				LastFailed = 0,
				Handle = nil,
			},
			Movement = {
				Owner = nil,
				PlaceWanted = false,
				StealFirst = false,
				MutationWanted = false,
				FracturedWanted = false,
			},
			AntiGuard = {
				Enabled = false,
				Busy = false,
				BusySince = 0,
				HitArms = 0,
				Handle = nil,
				Render = nil,
			},
			IsBatTool = function(arg)
				if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
					return false
				end

				if arg:GetAttribute("IsBat") == true then
					return true
				end
				local attribute = arg:GetAttribute("GearName")

				if type(attribute) == "string" then
					local gears = tbl.Gears
					local directory = type(gears) == "table" and gears.Directory or nil
					local flag = type(directory) == "table" and directory[attribute] or nil
					return type(flag) == "table" and flag.BatControllerData ~= nil
				end

				if arg:GetAttribute("ItemType") ~= nil then
					return false
				end
				local v14 = string.lower(arg.Name)

				for _, v15 in ipairs(tbl10) do
					if string.find(v14, v15, 1, true) then
						return true
					end
				end

				return false
			end,
			FindBat = function()
				local character = localPlayer.Character
				local tool = character and character:FindFirstChildWhichIsA("Tool")
				if tbl4.IsBatTool(tool) then
					return tool
				end
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")

				if backpack then
					for _, child in ipairs(backpack:GetChildren()) do
						if tbl4.IsBatTool(child) then
							return child
						end
					end
				end

				if character then
					for _, child in ipairs(character:GetChildren()) do
						if tbl4.IsBatTool(child) then
							return child
						end
					end
				end

				return nil
			end,
			IsNight = function()
				local areaEggCycle = tbl.AreaEggCycle
				if type(areaEggCycle) ~= "table" or type(areaEggCycle.IsNightPhase) ~= "function" then
					return false
				end
				local ok, result = pcall(areaEggCycle.IsNightPhase, workspace:GetServerTimeNow())
				return ok and result == true
			end,
			WallSealed = function()
				local areaEggResetWall = tbl.AreaEggResetWall
				if type(areaEggResetWall) ~= "table" or type(areaEggResetWall.IsSealed) ~= "function" then
					return false
				end
				local ok, result = pcall(areaEggResetWall.IsSealed)
				return ok and result == true
			end,
			WallOpenDelay = function()
				local areaEggResetCycle = tbl.AreaEggResetCycle
				if type(areaEggResetCycle) ~= "table" then
					return 5
				end
				return (tonumber(areaEggResetCycle.WallCountdownDelayAfterDayStartsSeconds) or 2) + (tonumber(areaEggResetCycle.WallCountdownSeconds) or 3)
			end,
			ClaimMovement = function(owner)
				local movement = tbl4.Movement
				if movement.Owner == nil or movement.Owner == owner or movement.Owner == "treadmill" and owner ~= "treadmill" or movement.Owner == "scramble" and owner == "steal" then
					movement.Owner = owner
					return true
				end
				return false
			end,
			ReleaseMovement = function(arg)
				if tbl4.Movement.Owner == arg then
					tbl4.Movement.Owner = nil
				end
			end,
		}

		do
			local shieldMethods = { "Humanoid Swap", "Disable Monitor" }
			tbl4.ShieldMethods = shieldMethods
			local v14 = shieldMethods[1]
			local tbl11 = {}
			local tbl12 = {}
			local connection = nil
			local n = 0
			local tbl13 = { Original = nil, Clone = nil, Links = {} }
			local connection2 = nil
			local tbl14 = {}

			local function fn10()
				for _, v15 in ipairs(tbl14) do
					task.defer(function()
						pcall(v15)
					end)
				end
			end

			tbl4.OnHumanoidChanged = function(arg)
				table.insert(tbl14, arg)
				local tbl15

				tbl15 = {
					Connected = true,
					Disconnect = function()
						tbl15.Connected = false
						local v15 = table.find(tbl14, arg)

						if v15 then
							table.remove(tbl14, v15)
						end
					end,
				}

				return tbl15
			end

			local function fn11(humanoid)
				pcall(function()
					local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
					local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")

					if playerModule then
						local controls = require(playerModule):GetControls()

						if type(controls) == "table" then
							controls.humanoid = humanoid
						end
					end
				end)
			end

			local function fn12(arg)
				local animate = arg and arg:FindFirstChild("Animate")

				if animate and animate:IsA("LocalScript") then
					task.spawn(function()
						animate.Enabled = false
						task.wait()
						animate.Enabled = true
					end)
				end
			end

			local function fn13()
				for _, link in ipairs(tbl13.Links) do
					pcall(function()
						link:Disconnect()
					end)
				end

				table.clear(tbl13.Links)
			end

			tbl4.UndoSwap = function()
				fn13()
				local character = localPlayer.Character
				local original = tbl13.Original
				local clone = tbl13.Clone
				local v15 = tbl13
				tbl13.Original = nil
				v15.Clone = nil

				if original and clone and character and original.Parent == nil and clone.Parent == character then
					original.Parent = character
					workspace.CurrentCamera.CameraSubject = original
					fn11(original)

					pcall(function()
						clone:Destroy()
					end)

					fn12(character)
					fn10()
				end
			end

			local tbl15 = {
				[Enum.HumanoidStateType.Running] = true,
				[Enum.HumanoidStateType.RunningNoPhysics] = true,
				[Enum.HumanoidStateType.Landed] = true,
			}

			tbl4.Grounded = function(arg)
				if not arg then
					local character = localPlayer.Character
					arg = character and character:FindFirstChildOfClass("Humanoid")
				end

				if not arg or arg.Health <= 0 or arg.FloorMaterial == Enum.Material.Air then
					return false
				end
				return tbl15[arg:GetState()] == true
			end

			tbl4.ShieldPaused = false

			tbl4.WalkSpeed = function()
				local character = localPlayer.Character
				character = character and character:FindFirstChildOfClass("Humanoid")
				character = character and character.WalkSpeed or 16
				local original = tbl13.Original

				if original and original.Health > 0 then
					character = math.min(character, original.WalkSpeed)
				end

				local ok, result = pcall(function()
					local leaderstats = localPlayer:FindFirstChild("leaderstats")
					leaderstats = leaderstats and leaderstats:FindFirstChild("Speed")
					local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
					return leaderstats and TreadmillUtil.SpeedPowerToWalkSpeed(leaderstats.Value) or nil
				end)

				local n2

				if ok and tonumber(result) and result > 0 then
					n2 = math.min(character, result)
				else
					n2 = character
				end

				return n2
			end

			local function fn14()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then
					return
				end

				if tbl13.Clone and tbl13.Clone.Parent == character then
					return
				end

				if not tbl4.Grounded(humanoid) then
					return
				end
				local clone = humanoid:Clone()
				humanoid.Parent = nil
				clone.Parent = character
				workspace.CurrentCamera.CameraSubject = clone
				fn11(clone)
				fn12(character)
				local v15 = tbl13
				tbl13.Original = humanoid
				v15.Clone = clone
				fn10()

				table.insert(tbl13.Links, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if clone.Parent ~= nil then
						clone.WalkSpeed = humanoid.WalkSpeed
					end
				end))

				local animator = humanoid:FindFirstChildOfClass("Animator")
				local animator2 = clone:FindFirstChildOfClass("Animator")

				if animator and animator2 then
					table.insert(tbl13.Links, animator.AnimationPlayed:Connect(function(arg)
						local animation = arg.Animation
						if not animation or clone.Parent == nil then
							return
						end

						local ok, result = pcall(function()
							return animator2:LoadAnimation(animation)
						end)

						if not ok or not result then
							return
						end

						pcall(function()
							result.Priority = arg.Priority
							result.Looped = arg.Looped
							local speed = arg.Speed
							result:Play(0.05, math.max(arg.WeightTarget, 0.01), speed)
						end)

						local connection3 = nil

						connection3 = arg.Stopped:Connect(function()
							connection3:Disconnect()

							pcall(function()
								result:Stop(0.1)
							end)
						end)
					end))
				end

				table.insert(tbl13.Links, clone.Died:Connect(function()
					fn13()
					local v16 = tbl13
					tbl13.Original = nil
					v16.Clone = nil
					local character2 = localPlayer.Character

					if character2 and humanoid.Parent == nil then
						humanoid.Parent = character2
						workspace.CurrentCamera.CameraSubject = humanoid
						fn11(humanoid)
						fn10()
					end

					pcall(function()
						clone:Destroy()
					end)

					humanoid.Health = 0
				end))
			end

			local function fn15()
				if type(getconnections) ~= "function" then
					return
				end

				for _, v15 in ipairs({ RunService.Heartbeat, RunService.PreSimulation, RunService.PostSimulation }) do
					local ok, result = pcall(getconnections, v15)

					if ok and type(result) == "table" then
						for _, v16 in ipairs(result) do
							local ok2, result2 = pcall(function()
								return v16.Function
							end)

							local flag = ok2 and type(result2) == "function"
							local flag2 = false
							local result3 = nil

							if flag then
								flag2, result3 = pcall(debug.info, result2, "s")
							end

							if flag2 and string.find(tostring(result3), "UGI", 1, true) then
								local ok3, result4 = pcall(function()
									return v16.Enabled
								end)

								if not ok3 or result4 ~= false then
									if pcall(function()
										v16:Disable()
									end) then
										table.insert(tbl12, v16)
									end
								end
							end
						end
					end
				end
			end

			local function fn16()
				if connection then
					connection:Disconnect()
					connection = nil
				end

				if connection2 then
					connection2:Disconnect()
					connection2 = nil
				end

				for _, v15 in ipairs(tbl12) do
					pcall(function()
						v15:Enable()
					end)
				end

				table.clear(tbl12)
			end

			local function fn17()
				if tbl4.ShieldPaused then
					return
				end

				if v14 == shieldMethods[1] then
					fn14()
				else
					fn15()
				end
			end

			local function fn18()
				fn17()
				n = 0

				connection = RunService.Heartbeat:Connect(function(deltaTime)
					n += deltaTime
					local character = localPlayer.Character
					local flag = v14 == shieldMethods[1]

					if flag then
						flag = not (tbl13.Clone and character and tbl13.Clone.Parent == character)
					end

					if (flag and 0.25 or 3) <= n then
						n = 0
						fn17()
					end
				end)

				connection2 = localPlayer.CharacterAdded:Connect(function(character)
					fn13()
					local v15 = tbl13
					tbl13.Original = nil
					v15.Clone = nil
					if v14 ~= shieldMethods[1] then
						return
					end

					task.spawn(function()
						character:WaitForChild("Humanoid", 10)
						task.wait(1)

						if connection and localPlayer.Character == character then
							fn17()
						end
					end)
				end)
			end

			tbl4.Swapped = function()
				if v14 ~= shieldMethods[1] then
					return true
				end
				local character = localPlayer.Character
				return tbl13.Clone ~= nil and character ~= nil and tbl13.Clone.Parent == character
			end

			tbl4.Shield = function(arg, arg2)
				tbl11[arg] = arg2 == true or nil
				if next(tbl11) == nil then
					fn16()
					return
				end

				if connection then
					return
				end
				fn18()
			end

			tbl4.SetShieldMethod = function(arg)
				if not table.find(shieldMethods, arg) or arg == v14 then
					return
				end
				local flag = connection ~= nil
				fn16()
				v14 = arg

				if flag and next(tbl11) ~= nil then
					fn18()
				end
			end

			fn4(fn16)
		end

		tbl4.Shield("load", true)

		tbl4.Toggle = function(arg, arg2)
			if type(arg) ~= "table" then
				return arg2 == true
			end

			local ok, result = pcall(function()
				local controller = arg._controller
				return type(controller) == "table" and type(controller.GetValue) == "function" and controller.GetValue()
			end)

			if ok and type(result) == "boolean" then
				return result
			end

			for _, v14 in ipairs({ "Get", "GetValue" }) do
				local ok2, result2 = pcall(function()
					return arg[v14]
				end)

				if ok2 and type(result2) == "function" then
					local ok3, result3 = pcall(result2, arg)
					if ok3 and type(result3) == "boolean" then
						return result3
					end
				end
			end

			return arg2 == true
		end

		tbl4.Root = function()
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			return humanoidRootPart and humanoidRootPart:IsDescendantOf(workspace) and humanoidRootPart or nil
		end

		tbl4.PlacedPoints = function()
			local placedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
			local tbl11 = {}
			if not placedEggRenders then
				return tbl11
			end
			local str = tostring(localPlayer.UserId)

			for _, child in ipairs(placedEggRenders:GetChildren()) do
				if string.find(child.Name, str, 1, true) then
					local ok, result = pcall(function()
						return child:IsA("Model") and child:GetPivot() or child.CFrame
					end)

					if ok then
						table.insert(tbl11, result.Position)
					end
				end
			end

			return tbl11
		end

		tbl4.OwnPlot = function()
			local plots = workspace:FindFirstChild("Plots")
			if not plots then
				return nil
			end

			for _, child in ipairs(plots:GetChildren()) do
				local plotSign = child:FindFirstChild("PlotSign")
				plotSign = plotSign and plotSign:FindFirstChild("PlayerPlotSign")
				plotSign = plotSign and plotSign:FindFirstChild("Frame")
				plotSign = plotSign and plotSign:FindFirstChild("PlayerName")

				if plotSign and plotSign:IsA("TextLabel") then
					local v14 = string.lower(plotSign.Text)
					if v14 == string.lower(localPlayer.Name) or v14 == string.lower(localPlayer.DisplayName) then
						return child
					end
				end
			end

			return nil
		end

		local function fn10()
			local v14 = tbl4.PlacedPoints()
			if #v14 == 0 then
				return nil
			end
			local vector = Vector3.zero

			for _, v15 in ipairs(v14) do
				vector += v15
			end

			return vector / #v14
		end

		tbl4.PenAnchor = function()
			local v14 = fn10()
			if v14 then
				return v14
			end
			local v15 = tbl4.OwnPlot()
			if not v15 then
				return nil
			end
			local toUpdate = v15:FindFirstChild("ToUpdate")
			local starterPen = toUpdate and toUpdate:FindFirstChild("StarterPen") or v15:FindFirstChild("CenterPoint")
			if not starterPen then
				return nil
			end

			local ok, result = pcall(function()
				return starterPen:IsA("Model") and starterPen:GetPivot() or starterPen.CFrame
			end)

			return ok and result.Position or nil
		end

		tbl4.Plot = function()
			local v14 = tbl4.OwnPlot()
			if v14 then
				return v14
			end
			local plots = workspace:FindFirstChild("Plots")
			local v15 = fn10()
			if not plots or not v15 then
				return nil
			end
			local huge = math.huge
			local v16 = nil

			for _, child in ipairs(plots:GetChildren()) do
				local ok, result, result2 = pcall(function()
					return child:GetBoundingBox()
				end)

				if ok and result and result2 then
					local v17 = result:PointToObjectSpace(v15)
					local n = result2.X / 2
					local flag = math.abs(v17.X) <= n

					if flag then
						local n2 = result2.Z / 2
						flag = math.abs(v17.Z) <= n2
					end

					if flag then
						return child
					end
					local magnitude = (result.Position - v15).Magnitude

					if magnitude < huge then
						v16 = child
						huge = magnitude
					end
				end
			end

			if v16 and huge <= 60 then
				return v16
			end
			return nil
		end

		tbl4.Belt = function()
			local v14 = tbl4.Plot()
			if not v14 then
				return nil
			end
			local treadmillBottom = v14:FindFirstChild("TreadmillBottom")
			if treadmillBottom and treadmillBottom:IsA("BasePart") then
				return treadmillBottom
			end
			local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
			clientTreadmillRenders = clientTreadmillRenders and clientTreadmillRenders:FindFirstChild("TreadmillRender_" .. v14.Name)
			local boundingBoxPart = clientTreadmillRenders and (clientTreadmillRenders:FindFirstChild("BoundingBoxPart") or clientTreadmillRenders:IsA("Model") and clientTreadmillRenders.PrimaryPart or clientTreadmillRenders:FindFirstChildWhichIsA("BasePart"))
			if boundingBoxPart then
				return boundingBoxPart
			end
			local treadmillUpgrade = v14:FindFirstChild("TreadmillUpgrade")
			return treadmillUpgrade and treadmillUpgrade:FindFirstChildWhichIsA("BasePart") or nil
		end

		tbl4.DistanceTo = function(arg)
			local v14 = tbl4.Root()
			if not v14 or not arg then
				return math.huge
			end
			return (v14.Position - arg).Magnitude
		end

		do
			local tbl11 = {}
			local n = 0

			local function fn11()
				local v14 = tbl4.Plot()
				if not v14 then
					return {}
				end
				local tbl12 = {}

				for _, v15 in ipairs({ "TreadmillBottom", "TreadmillUpgrade" }) do
					local v16 = v14:FindFirstChild(v15)

					if v16 then
						if v16:IsA("BasePart") then
							table.insert(tbl12, v16)
						else
							for _, descendant in ipairs(v16:GetDescendants()) do
								if descendant:IsA("BasePart") then
									table.insert(tbl12, descendant)
								end
							end
						end
					end
				end

				local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
				clientTreadmillRenders = clientTreadmillRenders and clientTreadmillRenders:FindFirstChild("TreadmillRender_" .. v14.Name)

				if clientTreadmillRenders then
					for _, descendant in ipairs(clientTreadmillRenders:GetDescendants()) do
						if descendant:IsA("BasePart") then
							table.insert(tbl12, descendant)
						end
					end
				end

				return tbl12
			end

			local function fn12()
				for _, v14 in ipairs(fn11()) do
					if not tbl11[v14] then
						tbl11[v14] = {
							CFrame = v14.CFrame,
							CanTouch = v14.CanTouch,
							CanCollide = v14.CanCollide,
							Transparency = v14.Transparency,
						}

						pcall(function()
							v14.CanTouch = false
							v14.CanCollide = false
							v14.Transparency = 1
							v14.CFrame = v14.CFrame - Vector3.new(0, 120, 0)
						end)
					end
				end
			end

			local function fn13()
				for k, v14 in pairs(tbl11) do
					if k and k.Parent then
						pcall(function()
							k.CFrame = v14.CFrame
							k.CanTouch = v14.CanTouch
							k.CanCollide = v14.CanCollide
							k.Transparency = v14.Transparency
						end)
					end
				end

				table.clear(tbl11)
			end

			tbl4.HoldBelt = function()
				n += 1
				fn12()
			end

			tbl4.ReleaseBelt = function()
				n = math.max(0, n - 1)

				if n == 0 then
					fn13()
				end
			end

			tbl4.BeltHeld = function()
				return n > 0
			end

			tbl4.RefreshBeltHide = function()
				if n > 0 then
					fn12()
				end
			end

			fn4(function()
				n = 0
				fn13()
			end)

			tbl4.LeaveBelt = function()
				local rfTreadmillAskDoff = networking:FindFirstChild("RF/Treadmill/AskDoff")

				if rfTreadmillAskDoff and rfTreadmillAskDoff:IsA("RemoteFunction") then
					pcall(rfTreadmillAskDoff.InvokeServer, rfTreadmillAskDoff)
				end
			end

			tbl4.Treadmill = { Riding = false }

			tbl4.ResetBelt = function()
				n = 0
				fn13()
			end

			tbl4.OnBelt = function()
				local v14 = tbl4.Belt()
				if not v14 or tbl11[v14] then
					return false
				end
				local v15 = tbl4.Root()
				if not v15 then
					return false
				end
				local v16 = v14.CFrame:PointToObjectSpace(v15.Position)
				local n2 = v14.Size.X / 2 + 2
				local flag = math.abs(v16.X) <= n2

				if flag then
					local n3 = v14.Size.Z / 2 + 2
					flag = math.abs(v16.Z) <= n3
				end

				return flag and v16.Y >= -2 and v16.Y <= v14.Size.Y / 2 + 8
			end
		end

		tbl4.ExitBelt = function()
			tbl4.Treadmill.Riding = false
			tbl4.LeaveBelt()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				pcall(function()
					humanoid.Jump = true
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end

			task.wait(0.35)
		end

		tbl4.Flying = false
		tbl4.Driving = 0

		tbl4.BeginFlight = function()
			tbl4.Flying = true
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.PlatformStand = true

				pcall(function()
					humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
				end)
			end

			return tbl4.Root() ~= nil
		end

		tbl4.SetFlightVelocity = function(assemblyLinearVelocity)
			local v14 = tbl4.Root()

			if v14 then
				v14.AssemblyLinearVelocity = assemblyLinearVelocity
				v14.AssemblyAngularVelocity = Vector3.zero
			end
		end

		tbl4.EndFlight = function()
			tbl4.Flying = false
			local v14 = tbl4.Root()

			if v14 then
				pcall(function()
					v14.AssemblyLinearVelocity = Vector3.zero
					v14.AssemblyAngularVelocity = Vector3.zero
				end)
			end

			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.PlatformStand = false
			end
		end

		do
			local tbl11 = {
				Enum.HumanoidStateType.FallingDown,
				Enum.HumanoidStateType.Ragdoll,
				Enum.HumanoidStateType.Physics,
				Enum.HumanoidStateType.Seated,
				Enum.HumanoidStateType.PlatformStanding,
			}

			local tbl12 = {}
			local flag = false

			tbl4.GodMode = function(arg)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not character or not humanoid then
					return
				end

				if arg then
					flag = true

					for _, v14 in ipairs(tbl11) do
						pcall(function()
							humanoid:SetStateEnabled(v14, false)
						end)
					end

					pcall(function()
						humanoid.BreakJointsOnDeath = false
					end)

					for _, descendant in ipairs(character:GetDescendants()) do
						if descendant:IsA("BasePart") and tbl12[descendant] == nil then
							tbl12[descendant] = descendant.CanCollide

							pcall(function()
								descendant.CanCollide = false
							end)
						end
					end
				elseif flag then
					flag = false

					for _, v14 in ipairs(tbl11) do
						pcall(function()
							humanoid:SetStateEnabled(v14, true)
						end)
					end

					for k, v14 in pairs(tbl12) do
						if k and k.Parent then
							pcall(function()
								k.CanCollide = v14
							end)
						end
					end

					table.clear(tbl12)
				end
			end
		end

		tbl4.GodTick = function()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health < humanoid.MaxHealth then
				pcall(function()
					humanoid.Health = humanoid.MaxHealth
				end)
			end
		end

		tbl4.StopWalking = function()
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoidRootPart then
				pcall(function()
					humanoid:MoveTo(humanoidRootPart.Position)
					humanoid:Move(Vector3.zero, false)
				end)
			end
		end

		local function fn11(arg, arg2, arg3, arg4)
			local n = tonumber(arg2) or 6
			local n2 = tonumber(arg3) or 10
			local n3 = 0
			local flag = nil
			local n4 = 0
			local n5 = 0

			while n3 < n2 do
				if type(arg4) == "function" and arg4() then
					tbl4.StopWalking()
					return false
				end
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				character = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not character or character.Health <= 0 then
					return false
				end

				if (humanoidRootPart.Position - arg).Magnitude <= n then
					tbl4.StopWalking()
					return true
				end
				flag = flag and (humanoidRootPart.Position - flag).Magnitude < 1

				if flag then
					n4 += 0.2
				else
					n4 = 0
				end

				flag = humanoidRootPart.Position
				n5 = math.max(0, n5 - 0.2)

				if n4 >= 0.8 and n5 <= 0 then
					tbl4.LeaveBelt()

					pcall(function()
						character.Jump = true
					end)

					n4 = 0
					n5 = 1.5
				end

				character:MoveTo(arg)
				n3 += task.wait(0.2)
			end

			tbl4.StopWalking()
			return tbl4.DistanceTo(arg) <= n
		end

		tbl4.WalkTo = function(arg, arg2, arg3, arg4)
			tbl4.Driving = tbl4.Driving + 1
			local ok, result = pcall(fn11, arg, arg2, arg3, arg4)
			tbl4.Driving = math.max(0, tbl4.Driving - 1)
			return ok and result == true
		end

		local tbl11 = {
			Boss = "Fractured",
			GreatBloom = "Spirit Bloom",
			Sakura = "Bloom",
			Monstrous = "Parasite",
		}

		task.spawn(function()
			local mutations = tbl.Mutations

			local ok, result = pcall(function()
				return mutations.All()
			end)

			if ok and type(result) == "table" then
				for k, v14 in pairs(result) do
					local id = type(v14) == "table" and (v14.Id or k) or nil
					local label = type(v14) == "table" and v14.Label or nil

					if id ~= nil and type(label) == "string" and label ~= "" then
						tbl11[tostring(id)] = label
					end
				end
			end
		end)

		fn7 = function(arg)
			return tbl11[tostring(arg)] or tostring(arg)
		end

		local tbl12, n, tbl13, tbl14, tbl15, tbl16, flag, tbl17, n2, n3
		local n4, fn12

		do
			local tbl18 = {
				"Forest",
				"Desert",
				"Snow",
				"Lake",
				"Jungle",
				"Volcano",
				"Prehistoric",
				"Cosmic",
				"Abyss Ocean",
				"Cherry Blossom",
				"Light Dark",
				"Titan Temple",
			}

			local tbl19 = {}

			for _, v14 in ipairs(tbl18) do
				tbl19[v14] = true
			end

			task.spawn(function()
				local eggState = tbl.EggState

				local ok, result = pcall(function()
					return eggState.ReadFieldEggs()
				end)

				if ok and type(result) == "table" and type(result.Records) == "table" then
					for _, record in pairs(result.Records) do
						local areaId = type(record) == "table" and record.AreaId or nil

						if type(areaId) == "string" and not tbl19[areaId] then
							tbl19[areaId] = true
							table.insert(tbl18, areaId)
						end
					end
				end
			end)

			tbl8 = { "Any" }
			tbl9 = { Any = 0 }
			local tbl20 = {}
			local directory = tbl.Assets and tbl.Assets.Directory

			if type(directory) == "table" then
				for _, v14 in pairs(directory) do
					local rarity = type(v14) == "table" and v14.Rarity or nil
					local flag2 = type(rarity) == "table"

					if flag2 then
						flag2 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					local v15 = flag2 or nil

					if v15 then
						local str = tbl20[v15]

						if not str then
							str = tostring(rarity.DisplayName or rarity._id or v15)
						end

						tbl20[v15] = str
					end
				end
			end

			if next(tbl20) == nil then
				tbl20 = {
					"Common",
					"Uncommon",
					"Rare",
					"Epic",
					"Legendary",
					"Mythic",
					"Cosmic",
					"Secret",
					"Eternal",
					"Divine",
				}
			end

			local tbl21 = {}

			for k in pairs(tbl20) do
				table.insert(tbl21, k)
			end

			table.sort(tbl21)

			for _, v14 in ipairs(tbl21) do
				table.insert(tbl8, tbl20[v14])
				tbl9[tbl20[v14]] = v14
			end

			tbl5 = { "Best Rarity", "Biggest Weight", "Best Mutation", "Highest Value", "Lowest Value" }
			tbl12 = {}
			n = 0
			tbl13 = {}
			tbl14 = {}
			tbl15 = {}
			tbl16 = {}
			tbl4.Steal.RiftPriority = false
			tbl4.Steal.RiftNeeds = {}
			flag = false
			tbl17 = {}
			n2 = 0
			v4 = tbl5[4]
			n3 = 27.4
			n4 = 400
			fn12 = nil

			v5 = v8:CreateToggle({
				Name = "Auto Steal",
				Default = false,
				Callback = function()
					if fn12 then
						fn12()
					end
				end,
			})

			for _, v14 in ipairs(tbl18) do
				tbl12[v14] = true
			end

			fn6(v8:CreateMultiDropdown({
				Name = "Target Areas",
				Options = tbl18,
				Default = tbl18,
				Callback = function(arg)
					local tbl22 = {}

					if type(arg) == "table" then
						for k, v14 in pairs(arg) do
							if v14 == true and type(k) == "string" then
								tbl22[k] = true
							elseif type(v14) == "string" then
								tbl22[v14] = true
							end
						end
					end

					if next(tbl22) == nil then
						for _, v14 in ipairs(tbl18) do
							tbl22[v14] = true
						end
					end

					tbl12 = tbl22
				end,
			}))
		end

		v8:CreateDropdown({
			Name = "Min Rarity",
			Note = "Steal eggs of the chosen rarity and every rarity above it",
			Options = tbl8,
			Default = tbl8[1],
			Callback = function(arg)
				n = tbl9[arg] or 0
			end,
		})

		fn5(v8, {
			Name = "Min Steal Value",
			Note = "Skip eggs worth less than this. Drag or type 250k, 50m, 1.5b",
			Legacy = "Min Value To Steal",
			SectionName = "Auto Steal",
			OnRaw = function(arg)
				n2 = arg
			end,
		})

		do
			local tbl18 = {}
			local tbl19 = {}
			local directory = tbl.Assets and tbl.Assets.Directory
			local tbl20 = {}

			if type(directory) == "table" then
				for k, v14 in pairs(directory) do
					local rarity = type(v14) == "table" and v14.Rarity or nil
					local rarity2 = type(rarity) == "table"

					if rarity2 then
						rarity2 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					rarity2 = rarity2 or nil

					if rarity2 then
						local insert = table.insert
						local tbl21 = { Category = tostring(k) }
						local v15 = tostring
						k = v14.DisplayName or k
						tbl21.Name = v15(k)
						tbl21.Rarity = rarity2
						tbl21.RarityName = tostring(rarity.DisplayName or rarity._id or rarity2)
						insert(tbl20, tbl21)
					end
				end
			end

			table.sort(tbl20, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity > arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v14 in ipairs(tbl20) do
				local str = string.format("%s [%s]", v14.Name, v14.RarityName)

				if tbl19[str] then
					str = string.format("%s [%s] (%s)", v14.Name, v14.RarityName, v14.Category)
				end

				table.insert(tbl18, str)
				tbl19[str] = v14.Category
			end

			fn6(v8:CreateMultiDropdown({
				Name = "Target Specific Eggs",
				Note = "Only steal these eggs (empty = all)",
				Options = tbl18,
				Default = {},
				Callback = function(arg)
					local tbl21 = {}

					if type(arg) == "table" then
						for k, v14 in pairs(arg) do
							k = v14 == true and type(k) == "string" and k

							if k then
								v14 = k
							else
								v14 = type(v14) == "string" and v14
							end

							v14 = v14 or nil

							if v14 and tbl19[v14] then
								tbl21[tbl19[v14]] = true
							end
						end
					end

					tbl13 = tbl21
				end,
			}))
		end

		do
			local n5 = 30
			local v14 = nil
			local flag2 = false
			local n6 = 0

			local function fn13()
				local tbl18 = {}
				local save2 = tbl.Save

				if type(save2) == "table" and type(save2.Get) == "function" then
					local ok, result = pcall(save2.Get)

					if ok and type(result) == "table" then
						local v15 = pairs
						local inventory = result.Inventory or {}

						for _, v16 in v15(inventory) do
							if type(v16) == "table" and v16.Category ~= nil then
								tbl18[tostring(v16.Category)] = true
							end
						end

						local v16 = pairs
						local eggInventory = result.EggInventory or {}

						for _, v17 in v16(eggInventory) do
							if type(v17) == "table" and v17.AssetCategory ~= nil then
								tbl18[tostring(v17.AssetCategory)] = true
							end
						end
					end
				end

				return tbl18
			end

			local function fn14()
				local rfScrambleTradeInAskState = networking:FindFirstChild("RF/ScrambleTradeIn/AskState")
				if not rfScrambleTradeInAskState or not rfScrambleTradeInAskState:IsA("RemoteFunction") then
					return
				end
				local ok, result = pcall(rfScrambleTradeInAskState.InvokeServer, rfScrambleTradeInAskState)
				if not ok or type(result) ~= "table" or type(result.Requirements) ~= "table" then
					return
				end
				local v15 = fn13()
				local riftNeeds = {}

				for _, requirement in pairs(result.Requirements) do
					if not v15[tostring(requirement)] then
						riftNeeds[tostring(requirement)] = true
					end
				end

				tbl4.Steal.RiftNeeds = riftNeeds
			end

			tbl3.Add(function()
				if not tbl4.Steal.RiftPriority or flag2 or os.clock() < n6 then
					return false
				end
				flag2 = true
				n6 = os.clock() + n5

				task.spawn(function()
					pcall(fn14)
					flag2 = false
				end)

				return false
			end)

			local function fn15()
				local riftNeeds = tbl4.Steal.RiftNeeds
				if not tbl4.Steal.RiftPriority or next(riftNeeds) == nil then
					return
				end
				local v15 = fn13()
				local flag3 = false

				for k in pairs(riftNeeds) do
					if v15[k] then
						riftNeeds[k] = nil
						flag3 = true
					end
				end

				if flag3 then
					tbl3.Wake()
				end
			end

			local save2 = tbl.Save

			if type(save2) == "table" and type(save2.FieldSignal) == "function" then
				for _, v15 in ipairs({ "EggInventory", "Inventory" }) do
					local ok, result = pcall(save2.FieldSignal, v15)

					if ok and type(result) == "table" and type(result.Connect) == "function" then
						local ok2, result2 = pcall(result.Connect, result, function()
							task.defer(fn15)
						end)

						if ok2 and result2 then
							fn4(function()
								pcall(function()
									result2:Disconnect()
								end)
							end)
						end
					end
				end
			end

			v14 = v8:CreateToggle({
				Name = "Steal Missing Lab Eggs",
				Default = false,
				Callback = function()
					tbl4.Steal.RiftPriority = tbl4.Toggle(v14, false) == true
					n6 = 0

					if not tbl4.Steal.RiftPriority then
						tbl4.Steal.RiftNeeds = {}
					end

					tbl3.Wake()
				end,
			})
		end

		do
			local n5 = 5
			local n6 = 5
			local n7 = 60
			local v14 = nil
			local n8 = 0
			local n9 = 0
			local flag2 = false
			local tbl18 = {}

			local function fn13()
				local save2 = tbl.Save

				if type(save2) == "table" and type(save2.Get) == "function" then
					local ok, result = pcall(save2.Get)
					if ok and type(result) == "table" then
						return result
					end
				end

				return nil
			end

			local function fn14()
				local v15 = fn13()
				local directory = tbl.Areas and tbl.Areas.Directory
				local directory2 = tbl.Assets and tbl.Assets.Directory
				if not v15 or type(directory) ~= "table" or type(directory2) ~= "table" then
					return
				end
				local index = type(v15.Index) == "table" and v15.Index or {}
				local tbl19 = {}
				local v16 = pairs
				local inventory = v15.Inventory or {}

				for _, v17 in v16(inventory) do
					if type(v17) == "table" and v17.Category ~= nil then
						tbl19[tostring(v17.Category)] = true
					end
				end

				local v17 = pairs
				local eggInventory = v15.EggInventory or {}

				for _, v18 in v17(eggInventory) do
					if type(v18) == "table" and v18.AssetCategory ~= nil then
						tbl19[tostring(v18.AssetCategory)] = true
					end
				end

				local tbl20 = {}

				for _, v18 in pairs(directory) do
					local flag3 = type(v18) == "table" and type(v18.Rarity) == "table"

					if flag3 then
						flag3 = tonumber(v18.Rarity.RarityNumber or v18.Rarity.Rank)
					end

					flag3 = flag3 or 0
					local v19 = pairs
					local dropTable = type(v18) == "table" and v18.DropTable or {}

					for _, v20 in v19(dropTable) do
						local flag4 = type(v20) == "table" and v20[1] or nil
						local n10 = type(v20) == "table" and tonumber(v20[2]) or 0
						local flag5 = flag4 ~= nil and directory2[flag4] or nil

						if type(flag5) == "table" and n10 > 0 and flag5.DontRoll ~= true then
							local str = tostring(flag4)

							if index[flag4] ~= true and not tbl19[str] and (tbl20[str] == nil or flag3 > tbl20[str]) then
								tbl20[str] = flag3
							end
						end
					end
				end

				tbl17 = tbl20
			end

			local function fn15(arg, ...)
				local v15 = networking:FindFirstChild(arg)
				if not v15 or not v15:IsA("RemoteFunction") then
					return false
				end
				local ok, result = pcall(v15.InvokeServer, v15, ...)
				return ok and result ~= false
			end

			local function fn16(arg, arg2)
				local tbl19 = {}
				if type(arg) ~= "table" then
					return tbl19
				end

				for _, v15 in ipairs(arg2) do
					local flag3 = arg

					for _, v16 in ipairs(v15) do
						flag3 = type(flag3) == "table" and flag3[v16] or nil
					end

					local v16 = ipairs
					local tbl20 = type(flag3) == "table" and flag3 or {}

					for _, v17 in v16(tbl20) do
						if type(v17) == "table" and v17.AssetId ~= nil then
							table.insert(tbl19, v17.AssetId)
						end
					end
				end

				return tbl19
			end

			local tbl19 = {
				{
					Id = "LimitedEgg",
					Gear = "GravityDisruptor",
					Module = "LimitedEgg",
					Lists = { { "Entries" }, { "MechaReroll", "Entries" } },
				},
				{
					Id = "BrainrotEgg",
					Gear = "BeeLauncher",
					Module = "BrainrotEgg",
					Lists = { { "Entries" } },
				},
				{
					Id = "MonsterEgg",
					Gear = "BeeLauncher",
					Module = "MonsterEgg",
					Lists = { { "Entries" }, { "MechaEntries" } },
				},
			}

			local function fn17()
				local v15 = fn13()
				if not v15 then
					return
				end
				local index = type(v15.Index) == "table" and v15.Index or {}
				local indexClaimedCategories = type(v15.IndexClaimedCategories) == "table" and v15.IndexClaimedCategories or {}

				for k, v16 in pairs(index) do
					if v16 == true and indexClaimedCategories[k] ~= true then
						fn15("RF/Codex/AskRedeemAll")
						break
					end
				end

				local gearInventory = type(v15.GearInventory) == "table" and v15.GearInventory or {}

				for _, v16 in ipairs(tbl19) do
					local flag3 = (tonumber(gearInventory[v16.Gear]) or 0) <= 0

					if flag3 then
						flag3 = os.clock() >= (tbl18[v16.Id] or 0)
					end

					if flag3 then
						local v17 = fn16(tbl[v16.Module], v16.Lists)
						local flag4 = #v17 > 0

						for _, v18 in ipairs(v17) do
							if index[v18] ~= true then
								flag4 = false
								break
							end
						end

						if flag4 then
							tbl18[v16.Id] = os.clock() + n7
							fn15("RF/Codex/AskRedeemLimitedEgg", v16.Id)
						end
					end
				end
			end

			tbl3.Add(function()
				local now = os.clock()

				if flag and now >= n8 then
					n8 = now + n5
					pcall(fn14)
				end

				if not flag2 and now >= n9 and tbl4.Toggle(tbl4.IndexClaimHandle, false) then
					flag2 = true
					n9 = now + n6

					task.spawn(function()
						pcall(fn17)
						flag2 = false
					end)
				end

				return false
			end)

			v14 = v8:CreateToggle({
				Name = "Steal Missing Index Eggs",
				Note = "Also steal eggs missing from your index, highest area first",
				Default = false,
				Callback = function()
					flag = tbl4.Toggle(v14, false) == true
					n8 = 0

					if not flag then
						tbl17 = {}
					end

					tbl3.Wake()
				end,
			})

			tbl4.IndexClaimRestart = function()
				n9 = 0
				tbl3.Wake()
			end
		end

		tbl4.Steal.PriorityHandle = v8:CreateDropdown({
			Name = "Steal Priority",
			Options = tbl5,
			Default = tbl5[4],
			Callback = function(arg)
				if table.find(tbl5, arg) then
					v4 = arg

					if type(tbl4.ResortSteal) == "function" then
						tbl4.ResortSteal()
					end
				end
			end,
		})

		tbl4.SafeCarry.InstantHandle = v8:CreateToggle({
			Name = "Instant Steal",
			Note = "Delivers the egg to the safe zone in a few seconds, needs enough Speed",
			Default = false,
			Callback = function(arg)
				if type(arg) ~= "boolean" then
					arg = tbl4.Toggle(tbl4.SafeCarry.InstantHandle, false)
				end

				tbl4.SafeCarry.LineDrop = arg ~= false
				tbl4.SafeCarry.SpeedJitter = tbl4.SafeCarry.LineDrop and 0 or 0.08

				if tbl4.StealPanelSync then
					pcall(tbl4.StealPanelSync)
				end
			end,
		})

		tbl4.SafeCarry.RunHandle = v8:CreateSlider({
			Name = "Tween Speed",
			Note = "Over 100% may glitch",
			Min = 50,
			Max = 120,
			Default = 100,
			Increment = 1,
			Unit = "%",
			Callback = function(arg)
				tbl4.SafeCarry.RunSpeed = math.clamp(tonumber(arg) or 100, 50, 120) / 100
			end,
		})

		v8:CreateSlider({
			Name = "Carry Speed",
			Min = 80,
			Max = 120,
			Default = 100,
			Increment = 1,
			Unit = "%",
			Callback = function(arg)
				tbl4.SafeCarry.CarryScale = math.clamp(tonumber(arg) or 100, 80, 120) / 100
			end,
		})

		tbl4.AntiGuard.Handle = v2:CreateState({ Name = "Anti Guard Enabled", Default = false })

		pcall(function()
			tbl4.AntiGuard.Enabled = tbl4.AntiGuard.Handle:Get() == true
		end)

		pcall(function()
			tbl4.AntiGuard.Handle:Subscribe(function(arg)
				if type(arg) ~= "boolean" then
					arg = tbl4.AntiGuard.Handle:Get()
				end

				tbl4.AntiGuard.Enabled = arg == true

				if tbl4.StealPanelSync then
					pcall(tbl4.StealPanelSync)
				end

				if tbl4.AntiGuard.Render and tbl4.UiDefer then
					tbl4.UiDefer(function()
						pcall(tbl4.AntiGuard.Render, false)
					end)
				end
			end)
		end)

		tbl4.AntiGuard.PanelHandle = v8:CreateToggle({
			Name = "Anti Guard Panel",
			Default = true,
			Callback = function(panelShown)
				if type(panelShown) ~= "boolean" then
					panelShown = tbl4.Toggle(tbl4.AntiGuard.PanelHandle, true)
				end

				tbl4.AntiGuard.PanelShown = panelShown

				if tbl4.AntiGuard.ShowPanel then
					pcall(tbl4.AntiGuard.ShowPanel, panelShown)
				end
			end,
		})

		local v14
		v14 = nil
		local v15
		v15 = nil
		local v16
		v16 = nil
		local str
		str = "None"
		local str2
		str2 = "Idle"
		local flag2
		flag2 = false
		local n5
		n5 = 0
		local tbl18
		tbl18 = {}
		local n6
		n6 = 20
		local uid
		uid = nil
		local fn13

		fn13 = function(arg)
			return arg ~= n5 or not tbl4.Toggle(v14, false)
		end

		local fn14

		do
			local tbl19 = {}

			local function fn15(arg)
				if type(arg) ~= "number" or tbl19[arg] then
					return
				end
				tbl19[arg] = true

				task.delay(math.max(0, arg - workspace:GetServerTimeNow()) + 0.05, function()
					tbl19[arg] = nil
					tbl3.Wake()
				end)
			end

			local n7 = 0

			fn14 = function()
				local areaEggCycle = tbl.AreaEggCycle
				if type(areaEggCycle) ~= "table" then
					return nil
				end

				local ok, result, result2, result3, result4 = pcall(function()
					local serverTimeNow = workspace:GetServerTimeNow()
					local nextResetTime = areaEggCycle.NextResetTime
					return serverTimeNow, areaEggCycle.IsNightPhase(serverTimeNow), areaEggCycle.NextNightTime(serverTimeNow), nextResetTime(serverTimeNow)
				end)

				if not ok or type(result4) ~= "number" then
					return nil
				end

				if result2 == true then
					n7 = result4 + tbl4.WallOpenDelay()
					fn15(n7)
					return n7, "night", result
				end

				if tbl4.WallSealed() then
					fn15(result + 0.3)
					return math.max(n7, result), "wall", result
				end

				if type(result3) == "number" and result3 > result then
					fn15(result3)
				end

				return nil
			end
		end

		do
			local areaEggResetWall = tbl.AreaEggResetWall
			local changed = type(areaEggResetWall) == "table" and areaEggResetWall.Changed or nil

			if changed and type(changed.Connect) == "function" then
				local ok, result = pcall(function()
					return changed:Connect(function()
						tbl3.Wake()
					end)
				end)

				if ok and result then
					fn4(function()
						pcall(function()
							result:Disconnect()
						end)
					end)
				end
			end
		end

		local n7
		n7 = 8
		local v17
		v17 = nil
		local n8
		n8 = 0
		local fn15, fn16, fn17

		local function fn18(arg)
			local tbl19 = {}
			local str3 = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
			local eggState = tbl.EggState

			if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
				task.spawn(function()
					local ok, result = pcall(eggState.ReadFieldEggs)

					if ok and type(result) == "table" and type(result.Records) == "table" then
						for _, record in pairs(result.Records) do
							local flag3 = type(record) == "table" and type(record.Uid) == "string"

							if flag3 then
								flag3 = not (arg and string.sub(record.Uid, 1, #str3) == str3)
							end

							if flag3 then
								tbl19[record.Uid] = true
							end
						end
					end
				end)
			end

			return tbl19
		end

		fn15 = function()
			if v17 == nil then
				return false
			end

			if tbl4.IsNight() then
				return true
			end

			if n8 == math.huge then
				n8 = os.clock() + n7
			end

			return false
		end

		fn16 = function()
			if v17 and n8 == math.huge then
				return
			end
			v17 = fn18(true)
			n8 = math.huge
			table.clear(tbl14)
			table.clear(tbl16)
			table.clear(tbl15)
			table.clear(tbl18)
			uid = nil
		end

		fn17 = function()
			if not v17 then
				return false
			end

			if os.clock() >= n8 then
				v17 = nil
				return false
			end
			local v18 = fn18()
			if next(v18) == nil then
				return true
			end
			local flag3 = false
			local flag4 = false

			for k in pairs(v18) do
				if v17[k] then
					flag3 = true
				else
					flag4 = true
				end
			end

			if not flag3 then
				v17 = nil
				return false
			end
			return not flag4
		end

		local fn19

		do
			local function fn20(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				local flag3 = type(directory) == "table" and directory[tostring(arg)] or nil
				local rarity = type(flag3) == "table" and type(flag3.Rarity) == "table" and flag3.Rarity or nil
				local tbl19 = {}

				if rarity then
					rarity = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				tbl19.RarityNumber = rarity or 0
				tbl19.EarningRate = type(flag3) == "table" and tonumber(flag3.EarningRate) or 0
				return tbl19
			end

			local function fn21(arg)
				local mutations = tbl.Mutations

				if type(mutations) == "table" and type(mutations.EarningsFor) == "function" then
					local ok, result = pcall(mutations.EarningsFor, type(arg) == "table" and arg or {})
					if ok and type(result) == "number" then
						return result
					end
				end

				return 1
			end

			local function fn22(arg, arg2)
				local eggRecords = tbl.EggRecords

				if type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function" then
					local ok, result = pcall(eggRecords.WeightKgForScale, arg, arg2)
					if ok and type(result) == "number" then
						return result
					end
				end

				return 0
			end

			fn19 = function(arg, arg2)
				local records = nil
				local eggState = tbl.EggState

				if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
					task.spawn(function()
						local ok, result = pcall(eggState.ReadFieldEggs)

						if ok and type(result) == "table" and type(result.Records) == "table" and next(result.Records) ~= nil then
							records = result.Records
						end
					end)
				end

				if not records then
					local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
					if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
						return {}
					end
					local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
					records = ok and type(result) == "table" and result.Records or nil
				end

				if type(records) ~= "table" then
					return {}
				end
				local tbl19 = {}
				local tbl20 = {}

				for _, record in pairs(records) do
					local uid2 = type(record) == "table" and record.Uid or nil

					if uid2 and record.State ~= "Claimed" then
						tbl20[uid2] = true
					end

					local flag3 = record.State == "Carried" and arg2 == true and arg ~= true and not (tbl4.Steal.Carrying and uid2 == tbl4.Steal.CarryUid)
					local flag4

					if uid2 then
						flag4 = record.State == "Slot" or record.State == "Dropped" or flag3
					else
						flag4 = uid2
					end

					local v18 = uid2 and tbl14[uid2] or nil
					local flag5 = uid2 and tbl15[uid2] == true or false
					local flag6 = arg ~= true and flag and uid2 and tbl17[tostring(record.AssetCategory)] or nil
					local flag7 = arg ~= true and tbl4.Steal.RiftPriority == true and uid2 ~= nil and tbl4.Steal.RiftNeeds[tostring(record.AssetCategory)] == true
					local flag8 = arg == true or v18 ~= nil or flag5 or flag7 or flag6 ~= nil or tbl12[tostring(record.AreaId)] == true
					local flag9 = arg ~= true and v18 == nil and tbl16[uid2] == true
					local flag10 = v17 ~= nil and v17[uid2] == true
					flag4 = flag4 and typeof(record.BottomCFrame) == "CFrame"
					local flag11

					if flag4 then
						flag11 = (tbl18[uid2] or 0) <= os.clock()
					else
						flag11 = flag4
					end

					if flag11 and flag8 and not flag9 and not flag10 then
						local v19 = fn20(record.AssetCategory)
						local str3 = tostring(record.AssetCategory)
						local flag12 = v19.RarityNumber >= n
						local flag13 = next(tbl13) == nil or tbl13[str3] == true
						local n9 = tonumber(record.AssetScale) or 1
						local v20 = fn21(record.Mutations)
						local n10 = n9 > 5 and (n9 / 5) ^ 1.2 * 19.637875755794113 or n9 ^ 1.85
						local flag14 = n2 <= 0 or v19.EarningRate * n10 * v20 >= n2
						flag14 = flag12 and flag13 and flag14
						local flag15 = flag7 and not flag14 and not flag5 and v18 == nil and flag6 == nil
						local lastSkip = arg ~= true and tbl4.SafeCarry.Unsafe({ Uid = uid2, Category = str3 })

						if lastSkip then
							tbl14[uid2] = nil
							tbl15[uid2] = nil
							tbl4.SafeCarry.LastSkip = lastSkip
						elseif arg == true or v18 or flag5 or flag7 or flag6 ~= nil or flag14 then
							table.insert(tbl19, {
								Uid = uid2,
								Category = str3,
								Scale = n9,
								State = record.State,
								Rarity = v19.RarityNumber,
								Weight = fn22(record.AssetCategory, n9),
								Mutation = v20,
								Value = v19.EarningRate * n10 * v20,
								CFrame = record.BottomCFrame,
								AreaId = tostring(record.AreaId),
								Rift = arg ~= true and flag7,
								RiftOnly = arg ~= true and flag15,
								Index = flag6,
								Forced = arg ~= true and v18 and v18.At or nil,
								Priority = arg ~= true and flag5,
							})
						end
					end
				end

				if next(tbl20) ~= nil then
					for k in pairs(tbl14) do
						if not tbl20[k] then
							tbl14[k] = nil
						end
					end

					for k in pairs(tbl15) do
						if not tbl20[k] then
							tbl15[k] = nil
						end
					end

					for k in pairs(tbl16) do
						if not tbl20[k] then
							tbl16[k] = nil
						end
					end
				end

				table.sort(tbl19, function(arg3, arg4)
					if arg3.Forced ~= nil ~= arg4.Forced ~= nil then
						return arg3.Forced ~= nil
					end

					if arg3.Forced and arg4.Forced and arg3.Forced ~= arg4.Forced then
						return arg3.Forced < arg4.Forced
					end

					if arg3.Priority ~= arg4.Priority then
						return arg3.Priority == true
					end

					if arg3.RiftOnly ~= arg4.RiftOnly then
						return arg4.RiftOnly == true
					end

					if arg3.Index ~= nil ~= arg4.Index ~= nil then
						return arg3.Index ~= nil
					end

					if arg3.Index and arg4.Index and arg3.Index ~= arg4.Index then
						return arg3.Index > arg4.Index
					end

					if v4 == tbl5[2] and arg3.Weight ~= arg4.Weight then
						return arg3.Weight > arg4.Weight
					end

					if v4 == tbl5[3] and arg3.Mutation ~= arg4.Mutation then
						return arg3.Mutation > arg4.Mutation
					end

					if v4 == tbl5[4] and arg3.Value ~= arg4.Value then
						return arg3.Value > arg4.Value
					end

					if v4 == tbl5[5] and arg3.Value ~= arg4.Value then
						return arg3.Value < arg4.Value
					end

					if arg3.Rarity ~= arg4.Rarity then
						return arg3.Rarity > arg4.Rarity
					end

					if arg3.Value ~= arg4.Value then
						return arg3.Value > arg4.Value
					end
					return tostring(arg3.Uid) < tostring(arg4.Uid)
				end)

				return tbl19
			end
		end

		local n9
		n9 = 6
		local fn20, fn21, fn22, fn23, fn24

		do
			local v18 = nil
			local connection = nil

			fn20 = function(arg, arg2, arg3, arg4, arg5)
				local n10 = arg2 - arg.Position
				local magnitude = n10.Magnitude
				local n11 = math.max(arg4, 0.0041666666666666666)
				local vector = Vector3.zero

				if magnitude > 0.01 then
					vector = n10.Unit * math.min(arg3, magnitude / n11)
				end

				local assemblyLinearVelocity = vector + Vector3.new(0, workspace.Gravity * n11 * 0.5, 0)

				if magnitude > 2 then
					if not arg5.mark then
						arg5.mark = magnitude
						arg5.clock = 0
					end

					arg5.clock = arg5.clock + arg4

					if arg5.clock >= 0.4 then
						if arg5.mark - magnitude < arg3 * 0.1 then
							pcall(function()
								arg.CFrame = arg.CFrame + n10.Unit * math.min(magnitude, arg3 * n11)
							end)
						end

						arg5.mark = magnitude
						arg5.clock = 0
					end
				else
					arg5.mark = nil
				end

				pcall(function()
					arg.AssemblyLinearVelocity = assemblyLinearVelocity
					arg.AssemblyAngularVelocity = Vector3.zero
				end)

				return magnitude <= 0.5
			end

			fn21 = function()
				local v19 = tbl4.Root()

				if v19 then
					pcall(function()
						v19.AssemblyLinearVelocity = Vector3.zero
						v19.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end

			local connection2 = nil
			local tbl19 = {}

			fn22 = function()
				v18 = nil

				if connection then
					connection:Disconnect()
					connection = nil
				end

				if connection2 then
					connection2:Disconnect()
					connection2 = nil
				end
			end

			fn23 = function()
				local num = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
				return num ~= nil and num > workspace:GetServerTimeNow()
			end

			local flag3 = false

			local function fn25()
				if flag3 then
					return true
				end
				return true
			end

			fn24 = function(arg, arg2)
				v18 = arg
				flag3 = arg2 == true
				if connection or not arg then
					return
				end
				tbl19 = {}

				connection = RunService.Heartbeat:Connect(function()
					if not v18 or fn25() or fn23() or tbl4.AntiGuard.Busy then
						return
					end
					local v19 = tbl4.Root()
					if not v19 then
						return
					end

					pcall(function()
						local rotation = v19.CFrame.Rotation
						v19.CFrame = CFrame.new(v18) * rotation
						v19.AssemblyLinearVelocity = Vector3.zero
						v19.AssemblyAngularVelocity = Vector3.zero
					end)
				end)

				connection2 = RunService.PreSimulation:Connect(function(deltaTime)
					if not v18 or not fn25() or fn23() or tbl4.AntiGuard.Busy then
						return
					end
					local v19 = tbl4.Root()

					if v19 then
						fn20(v19, v18, 400, deltaTime, tbl19)
					end
				end)
			end
		end

		fn4(fn22)
		local fn25

		fn25 = function()
			fn22()
			tbl4.EndFlight()
			tbl4.GodMode(false)
			local character = localPlayer.Character
			character = character and character:FindFirstChildOfClass("Humanoid")

			if character then
				character.PlatformStand = false
			end
		end

		local n10, fn26, fn27

		do
			local n11 = 1.5
			n10 = 0.6

			local function fn28(arg, arg2)
				local x = arg2.X
				return (Vector3.new(arg.X, 0, arg.Z) - Vector3.new(x, 0, arg2.Z)).Magnitude
			end

			local function fn29(arg)
				local ok, result = pcall(function()
					return arg:GetPivot().Position
				end)

				return ok and result or nil
			end

			fn26 = function(arg, arg2, arg3)
				local v18 = fn28(arg.Position, arg3)
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

				if areaEggSlotsClient then
					for _, child in ipairs(areaEggSlotsClient:GetChildren()) do
						if child:IsA("Model") and child.Name ~= arg2 then
							local v19 = fn29(child)
							if v19 and fn28(v19, arg.Position) + n11 < v18 then
								return false
							end
						end
					end
				end

				for _, child in ipairs(workspace:GetChildren()) do
					if child:IsA("Model") and child.Name ~= arg2 and #child.Name == 32 and child:FindFirstChild("Hitbox") then
						local v19 = fn29(child)
						if v19 and fn28(v19, arg.Position) + n11 < v18 then
							return false
						end
					end
				end

				return true
			end

			tbl4.Steal.WrongEgg = function(carryUid)
				local steal = tbl4.Steal
				if type(carryUid) ~= "string" or not steal.Carrying or steal.CarryUid == carryUid then
					return false
				end
				local eggState = tbl.EggState

				if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
					pcall(eggState.DropFieldEgg, "PlayerRequest")
				end

				local n12 = 0

				while steal.Carrying and n12 < 1 do
					n12 += RunService.Heartbeat:Wait()
				end

				steal.Carrying = false
				steal.CarryUid = carryUid
				return true
			end

			fn27 = function(arg, arg2, arg3)
				local n12 = arg3 or 14
				local v18 = nil
				local v19 = nil

				for _, child in ipairs(workspace:GetChildren()) do
					if child.Name == "SmartPromptPart" and child:IsA("BasePart") then
						local carryAreaEgg = child:FindFirstChild("CarryAreaEgg")

						if carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") then
							local v20 = fn28(child.Position, arg2)

							if v20 < n12 then
								n12 = v20
								v18 = carryAreaEgg
								v19 = child
							end
						end
					end
				end

				if not v18 or not v19 then
					return nil
				end

				if type(arg) == "string" and not fn26(v19, arg, arg2) then
					return nil
				end
				return v18, v19
			end
		end

		local fn28

		fn28 = function(arg)
			local eggState = tbl.EggState

			if type(arg) == "string" and type(eggState) == "table" and type(eggState.CarryFieldEgg) == "function" then
				pcall(eggState.CarryFieldEgg, arg)
			end
		end

		local fn29

		do
			local function fn30()
				local carryUid = tbl4.Steal.CarryUid
				return type(carryUid) == "string" and carryUid or nil
			end

			local function fn31(arg)
				local v18 = fn30()
				if not v18 or type(arg) ~= "string" then
					return true
				end
				return v18 == arg
			end

			local function fn32(arg)
				if type(arg) ~= "string" then
					return false
				end
				local v18 = fn19(false, true)
				if #v18 == 0 then
					return true
				end

				for _, v19 in ipairs(v18) do
					if v19.Uid == arg then
						return true
					end
				end

				return false
			end

			local function fn33(arg)
				local eggState = tbl.EggState

				if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
					pcall(eggState.DropFieldEgg, "PlayerRequest")
				end

				local n11 = 0

				while tbl4.Steal.Carrying and n11 < 1 and not fn13(arg) do
					n11 += RunService.Heartbeat:Wait()
				end
			end

			fn29 = function(arg, arg2)
				local n11 = 0

				while not tbl4.Steal.Carrying and n11 < n10 and not fn13(arg2) do
					n11 += RunService.Heartbeat:Wait()
				end

				if not tbl4.Steal.Carrying then
					str2 = "The egg never reached the hand"
					return false
				end

				if fn31(arg) then
					return true
				end
				local v18 = fn30()
				if fn32(v18) then
					str2 = "Holding another egg that still matches, delivering it"
					return true
				end
				str2 = "Wrong egg in hand, dropping it"
				fn33(arg2)
				return false
			end
		end

		local fn30

		fn30 = function(arg, arg2)
			local eggState = tbl.EggState
			local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
			if not position then
				return false
			end
			local n11 = 0
			local huge = math.huge
			local n12 = 0

			while n11 < 1.5 do
				if fn13(arg2) then
					return false
				end

				if tbl4.Steal.Carrying and not tbl4.Steal.WrongEgg(arg.Uid) then
					return true
				end

				if huge >= 0.06 then
					local v18 = fn27(arg.Uid, position)

					if v18 then
						pcall(function()
							v18.HoldDuration = 0
						end)

						n12 = 0

						if typeof(fireproximityprompt) == "function" then
							pcall(fireproximityprompt, v18)
						end
					else
						n12 += 1
						if n12 >= 4 then
							return false
						end

						if type(eggState) == "table" and type(eggState.CarryFieldEgg) == "function" then
							pcall(eggState.CarryFieldEgg, arg.Uid)
						end
					end

					huge = 0
				end

				local result = RunService.Heartbeat:Wait()
				n11 += result
				huge += result
			end

			return tbl4.Steal.Carrying == true
		end

		local fn31

		local v18 = fn2(function()
			return ReplicatedStorage.Shared.Modules.Ragdoll
		end)

		fn31 = function()
			local character = localPlayer.Character

			if type(v18) == "table" and type(v18.IsRagdolled) == "function" then
				local ok, result = pcall(v18.IsRagdolled, character)
				if ok and result == true then
					return true
				end
			end

			local num = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
			if num and num > workspace:GetServerTimeNow() then
				return true
			end
			character = character and character:FindFirstChildOfClass("Humanoid")
			if character then
				local state = character:GetState()
				return state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown
			end
			return false
		end

		local fn32, n11, n12, fn33, stealHome, fn34, fn35

		do
			local function fn36(arg, arg2)
				if tbl4.Steal.Carrying then
					return true
				end
				local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
				if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
					return false
				end
				local n13 = 0

				while n13 < 1 do
					if fn13(arg2) or tbl4.Steal.Carrying then
						return tbl4.Steal.Carrying == true
					end
					local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
					ok = ok and type(result) == "table" and result.Records or nil

					if type(ok) == "table" then
						local flag3 = false

						for _, v19 in pairs(ok) do
							if type(v19) == "table" and v19.Uid == arg and (v19.State == "Slot" or v19.State == "Dropped") then
								flag3 = true
								break
							end
						end

						if not flag3 then
							return tbl4.Steal.Carrying == true
						end
					end

					n13 += task.wait(0.3)
				end

				return tbl4.Steal.Carrying == true
			end

			local function fn37(arg)
				local v19 = tbl4.Root()
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not v19 or not position then
					return math.huge
				end
				return (v19.Position - position).Magnitude
			end

			fn32 = function(arg)
				local huge = math.huge
				local v19 = nil

				for _, v20 in ipairs(arg) do
					local v21 = fn37(v20)

					if v21 < huge then
						huge = v21
						v19 = v20
					end
				end

				return v19, huge
			end

			n11 = 20
			n12 = 90
			local n13 = 6

			fn33 = function(arg, arg2, arg3, arg4, arg5, arg6)
				fn22()
				local v19 = tbl4.Root()
				if not v19 then
					return false
				end
				local character = localPlayer.Character
				local position = v19.Position
				local tbl19 = {}
				local position2 = nil
				local flag3 = nil
				local str3 = nil
				local n14 = 0

				local function fn38()
					if arg4 ~= nil then
						return true
					end
					return true
				end

				local function fn39(arg7)
					n14 += arg7
					if fn13(arg2) then
						flag3 = false
						return nil
					end

					if arg3 and not tbl4.Steal.Carrying then
						flag3 = false
						str3 = "dropped"
						return nil
					end

					if arg6 then
						local v20 = arg6()

						if v20 then
							flag3 = false
							str3 = v20
							return nil
						end
					end

					local v20 = tbl4.Root()

					if not v20 or n14 >= 25 or localPlayer.Character ~= character then
						flag3 = false
						str3 = "respawned"
						return nil
					end

					return v20
				end

				local connection = RunService.Heartbeat:Connect(function(deltaTime)
					if flag3 ~= nil or fn38() or tbl4.AntiGuard.Busy then
						return
					end
					local v20 = fn39(deltaTime)
					if not v20 then
						return
					end

					if n9 < (v20.Position - position).Magnitude then
						if arg5 then
							flag3 = false
							str3 = "displaced"
							return
						end

						position = v20.Position
					end

					local n15 = (arg4 or 400) * (os.clock() < (tbl4.SafeCarry.SlowUntil or 0) and tbl4.SafeCarry.SlowFactor or 1)
					local n16

					if tbl4.SafeCarry.Enabled and tbl4.SafeCarry.Pace then
						n16 = math.min(n15, tbl4.SafeCarry.Pace())
					else
						n16 = n15
					end

					local n17 = arg - position
					local n18 = n16 * deltaTime
					local flag4 = n17.Magnitude <= math.max(n18, 0.05)
					position = flag4 and arg or position + n17.Unit * n18
					local vector = Vector3.new(n17.X, 0, n17.Z)
					local cframe = vector.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector.Unit) or v20.CFrame.Rotation

					pcall(function()
						v20.CFrame = CFrame.new(position) * cframe
						v20.AssemblyLinearVelocity = Vector3.zero
						v20.AssemblyAngularVelocity = Vector3.zero
					end)

					if flag4 then
						flag3 = true
					end
				end)

				local connection2 = RunService.PreSimulation:Connect(function(deltaTime)
					if flag3 ~= nil or not fn38() or tbl4.AntiGuard.Busy then
						return
					end
					local v20 = fn39(deltaTime)
					if not v20 then
						return
					end
					local n15 = (arg4 or 400) * (os.clock() < (tbl4.SafeCarry.SlowUntil or 0) and tbl4.SafeCarry.SlowFactor or 1)
					local n16

					if tbl4.SafeCarry.Enabled and tbl4.SafeCarry.Pace then
						n16 = math.min(n15, tbl4.SafeCarry.Pace())
					else
						n16 = n15
					end

					if arg5 and position2 and (v20.Position - position2).Magnitude > n9 + n16 * deltaTime then
						flag3 = false
						str3 = "displaced"
						return
					end

					if fn20(v20, arg, n16, deltaTime, tbl19) then
						flag3 = true
					end

					position2 = v20.Position
					position = v20.Position
				end)

				while flag3 == nil do
					RunService.Heartbeat:Wait()
				end

				connection:Disconnect()
				connection2:Disconnect()

				if fn38() and not flag3 then
					fn21()
				end

				if flag3 then
					fn24(arg, arg4 ~= nil)
				end

				return flag3, str3
			end

			local tbl19 = {
				{
					Path = { "GearGiver_Slap", "Podium" },
					Offset = Vector3.new(-16.415, 21.072, -6.106),
				},
				{
					Path = { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
					Offset = Vector3.new(-26.776, 1.75, 18.665),
				},
				{
					Path = { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
					Offset = Vector3.new(-26.776, 1.75, 18.665),
				},
			}

			stealHome = function()
				for _, v19 in ipairs(tbl19) do
					local v20 = workspace

					for _, v21 in ipairs(v19.Path) do
						v20 = v20 and v20:FindFirstChild(v21) or nil
					end

					if v20 and v20:IsA("BasePart") then
						return v20.CFrame:PointToWorldSpace(v19.Offset)
					end
				end

				return Vector3.new(528.7, 70.57, -364.11)
			end

			tbl4.StealHome = stealHome

			tbl4.InsideBase = function(arg)
				if not arg then
					arg = tbl4.Root()
					arg = arg and arg.Position
				end

				if arg == nil then
					return false
				end
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				local areas = world and world:FindFirstChild("Areas")
				areas = areas and areas:FindFirstChild("SeparationLine")
				return arg.X < (areas and areas:IsA("BasePart") and areas.Position.X or 552)
			end

			local function fn38(arg)
				if tbl4.AntiGuard.Busy then
					return false
				end
				local character = localPlayer.Character
				local v19 = tbl4.Root()
				if not character or not v19 then
					return false
				end
				local rotation = v19.CFrame.Rotation
				local cFrame = CFrame.new(arg) * rotation

				pcall(function()
					character:PivotTo(cFrame)
				end)

				if (v19.Position - arg).Magnitude > 3 then
					pcall(function()
						v19.CFrame = cFrame
					end)
				end

				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") then
						pcall(function()
							descendant.AssemblyLinearVelocity = Vector3.zero
							descendant.AssemblyAngularVelocity = Vector3.zero
						end)
					end
				end

				return true
			end

			local function fn39(arg)
				if tbl4.AntiGuard.Busy then
					return
				end
				local character = localPlayer.Character
				local v19 = tbl4.Root()
				if not character or not v19 or not arg then
					return
				end

				if (v19.Position - arg).Magnitude > 6 then
					fn38(arg)
					return
				end

				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant ~= v19 and (descendant.Position - v19.Position).Magnitude > 12 then
						pcall(function()
							descendant.CFrame = v19.CFrame
							descendant.AssemblyLinearVelocity = Vector3.zero
						end)
					end
				end
			end

			local function fn40(arg, arg2)
				local n14 = 0

				while true do
					if not (n14 < n13) then
						return not fn13(arg)
					else
						if fn13(arg) then
							break
						end
						local character = localPlayer.Character
						local flag3 = fn31()

						if not flag3 and character then
							for _, descendant in ipairs(character:GetDescendants()) do
								if descendant:IsA("Constraint") and string.find(descendant.Name, "RagdollConstraint", 1, true) then
									flag3 = true
									break
								end
							end
						end

						if not flag3 then
							return not fn13(arg)
						end
						fn39(arg2)
						n14 += RunService.Heartbeat:Wait()
					end
				end

				return false
			end

			local function fn41(arg)
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("GuardAreas")
				local areaId = world and arg and arg.AreaId and world:FindFirstChild(arg.AreaId)
				return areaId and areaId:FindFirstChild("Guard") or nil
			end

			fn34 = function(arg)
				local v19 = fn41(arg)
				return v19 ~= nil and v19:GetAttribute("GuardState") == "Sleeping"
			end

			local n14 = 3

			fn35 = function(arg)
				local v19 = fn41(arg)
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not v19 or not position then
					return nil, nil
				end

				local ok, result = pcall(function()
					return v19:GetPivot().Position
				end)

				if not ok then
					return nil, nil
				end
				local vector = Vector3.new(position.X - result.X, 0, position.Z - result.Z)
				if vector.Magnitude < 0.1 then
					return nil, nil
				end
				local n15 = result + vector.Unit * n14
				return Vector3.new(n15.X, position.Y + 3, n15.Z), result
			end

			local function fn42(arg, arg2)
				local tbl20 = { Landed = false, Destination = arg2 }
				local antiGuard = tbl4.AntiGuard
				antiGuard.HitArms = antiGuard.HitArms + 1
				tbl4.AntiGuard.HitArmedAt = os.clock()

				tbl20.Link = localPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
					if tbl20.Landed or fn13(arg) then
						return
					end
					local num = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
					if not num or num <= workspace:GetServerTimeNow() then
						return
					end
					local v19 = tbl4.Root()
					if not v19 then
						return
					end
					tbl20.Landed = true
					fn22()
					tbl4.SafeCarry.JumpDistance = (tbl20.Destination - v19.Position).Magnitude
					tbl4.SafeCarry.JumpAt = os.clock()

					pcall(function()
						v19.CFrame = CFrame.new(tbl20.Destination)
						v19.AssemblyLinearVelocity = Vector3.zero
					end)
				end)

				tbl20.Stop = function()
					if tbl20.Link then
						tbl20.Link:Disconnect()
						tbl20.Link = nil
						tbl4.AntiGuard.HitArms = math.max(0, tbl4.AntiGuard.HitArms - 1)
					end
				end

				return tbl20
			end

			local function fn43(arg, arg2, arg3)
				local character = localPlayer.Character
				character = character and character:FindFirstChildOfClass("Humanoid")

				if character then
					character.PlatformStand = false
				end

				local n15 = 0
				local v19 = nil

				while not arg2.Landed and n15 < n11 do
					if fn13(arg) then
						break
					end

					if arg3 then
						arg3(arg2)
					end

					if not tbl4.Steal.Carrying then
						v19 = v19 or n15
						if n15 - v19 > 1 then
							break
						end
					end

					n15 += RunService.Heartbeat:Wait()
				end

				arg2.Stop()
				return arg2.Landed
			end

			local n15 = 20

			local function fn44(arg, arg2, arg3, arg4)
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not position then
					return false
				end
				local n16 = 0
				local huge = math.huge

				while n16 < arg3 do
					if fn13(arg2) then
						return false
					end

					if tbl4.Steal.Carrying and not tbl4.Steal.WrongEgg(arg.Uid) then
						return true
					end

					if huge >= 0.1 then
						local v19 = fn27(arg.Uid, position)

						if v19 then
							pcall(function()
								v19.HoldDuration = 0
							end)

							if typeof(fireproximityprompt) == "function" then
								pcall(fireproximityprompt, v19)
							end
						else
							fn28(arg.Uid)
						end

						huge = 0
					end

					if arg4 then
						fn39(arg4)
					end

					local result = RunService.Heartbeat:Wait()
					n16 += result
					huge += result
				end

				return tbl4.Steal.Carrying == true
			end

			local function fn45(arg, arg2, arg3, arg4)
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not position then
					return false
				end
				local n16 = position + Vector3.new(0, 3, 0)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid and character:FindFirstChildWhichIsA("Tool") then
					pcall(function()
						humanoid:UnequipTools()
					end)
				end

				if arg3 then
					fn24(n16, true)
					str2 = "Waiting to stand up"
					if not fn40(arg2, n16) then
						return false
					end

					if tbl4.SafeCarry.Enabled and arg4 == nil and tbl4.SafeCarry.Settle then
						if not tbl4.SafeCarry.Settle(arg2, arg) then
							return false
						end
					end
				else
					str2 = "Jumping to the egg"
					local v19 = tbl4.Root()

					if v19 and (n16 - v19.Position).Magnitude <= n12 then
						pcall(function()
							local rotation = v19.CFrame.Rotation
							v19.CFrame = CFrame.new(n16) * rotation
							v19.AssemblyLinearVelocity = Vector3.zero
							v19.AssemblyAngularVelocity = Vector3.zero
						end)
					elseif not fn33(n16, arg2, nil, 400) then
						return false
					end
				end

				if fn13(arg2) then
					return false
				end
				local flag3 = arg4 and typeof(arg4.CFrame) == "CFrame"
				local v19 = nil

				if flag3 then
					v19 = fn42(arg2, arg4.CFrame.Position + Vector3.new(0, 3, 0))
				end

				local str3 = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
				local flag4 = type(arg.Uid) == "string" and string.sub(arg.Uid, 1, #str3) == str3 and string.match(arg.Uid, "_([%w ]+:Slot_%d+)$") or nil
				arg4 = arg4 and flag4
				local flag5 = false

				if arg4 then
					local eggState = tbl.EggState

					if type(eggState) == "table" and type(eggState.CarryFieldEgg) == "function" then
						str2 = "Taking the starter egg"

						task.spawn(function()
							pcall(eggState.CarryFieldEgg, arg.Uid, flag4)
						end)

						local n17 = 0

						while not tbl4.Steal.Carrying and n17 < 0.8 do
							if fn13(arg2) then
								return false
							end
							n17 += RunService.Heartbeat:Wait()
						end

						flag5 = tbl4.Steal.Carrying == true
					end
				end

				if not flag5 then
					str2 = "Taking the egg"
					flag5 = fn30(arg, arg2)

					if not flag5 and not fn13(arg2) then
						fn33(n16, arg2, nil, 400)
						flag5 = fn30(arg, arg2)
					end
				end

				if not flag5 and not fn36(arg.Uid, arg2) then
					if v19 then
						v19.Stop()
					end

					tbl18[arg.Uid] = os.clock() + n6
					str2 = "That egg would not come free"
					return false
				end

				if v19 then
					local reGuardPatrolForestStrike = networking:FindFirstChild("RE/GuardPatrol/ForestStrike")
					local v20 = fn41(arg) or fn41({ AreaId = "Forest" })
					local humanoidRootPart = v20 and v20:FindFirstChild("HumanoidRootPart")

					if reGuardPatrolForestStrike and reGuardPatrolForestStrike:IsA("RemoteEvent") and humanoidRootPart then
						str2 = "Calling the guard strike"

						pcall(function()
							reGuardPatrolForestStrike:FireServer({ EggUid = arg.Uid, GuardCFrame = humanoidRootPart.CFrame })
						end)
					end
				end

				tbl4.Steal.LastFinishedAt = os.clock()
				return true, v19
			end

			local huge = math.huge
			local huge2 = math.huge

			local function fn46(arg, arg2, arg3)
				local v19 = nil
				local v20 = nil

				for _, child in ipairs(workspace:GetChildren()) do
					if child.Name == "SmartPromptPart" and child:IsA("BasePart") then
						local carryAreaEgg = child:FindFirstChild("CarryAreaEgg")

						if carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") then
							local magnitude = (child.Position - arg).Magnitude

							if magnitude < arg2 then
								arg2 = magnitude
								v19 = carryAreaEgg
								v20 = child
							end
						end
					end
				end

				if v19 and v20 and type(arg3) == "string" and not fn26(v20, arg3, arg) then
					return nil
				end
				return v19, v20
			end

			local function fn47(arg)
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				local v19 = workspace:FindFirstChild(arg) or areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(arg)
				if not v19 then
					return nil
				end

				local ok, result = pcall(function()
					return v19:GetPivot().Position
				end)

				return ok and result or nil
			end

			local function fn48(arg)
				local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
				if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
					return nil
				end
				local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
				local records = ok and type(result) == "table" and result.Records or nil
				if type(records) ~= "table" then
					return nil
				end

				for _, record in pairs(records) do
					if type(record) == "table" and record.Uid == arg and typeof(record.BottomCFrame) == "CFrame" then
						return record.BottomCFrame.Position, true
					end
				end

				return nil, true
			end

			local function fn49(arg)
				local v19 = workspace:FindFirstChild(arg)
				if not v19 then
					return false
				end

				for _, descendant in ipairs(v19:GetDescendants()) do
					if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("RigidConstraint") then
						local ok, result, result2 = pcall(function()
							return descendant.Part0, descendant.Part1
						end)

						if ok then
							for _, v20 in ipairs({ result, result2 }) do
								if typeof(v20) == "Instance" and not v20:IsDescendantOf(v19) then
									local model = v20:FindFirstAncestorOfClass("Model")
									if model and model ~= localPlayer.Character and Players:GetPlayerFromCharacter(model) then
										return true
									end
								end
							end
						end
					end
				end

				return false
			end

			local function fn50(arg, arg2)
				local state = 1
				local v19, carryUid, n16, vector, connection, n17, n18, huge3, v20, v21, n19, huge4, flag3, v22, v23, v24, v25, now, flag4, n20, flag5, v26

				while true do
					if state == 1 then
						v19 = arg
						carryUid = arg2

						if carryUid then
							state = 3
						else
							state = 2
						end
					elseif state == 2 then
						carryUid = tbl4.Steal.CarryUid
						state = 3
					elseif state == 3 then
						if type(carryUid) ~= "string" then
							state = 50
						else
							state = 4
						end
					elseif state == 4 then
						fn22()
						str2 = "Following the egg"
						n16 = nil
						vector = Vector3.zero

						connection = RunService.PreSimulation:Connect(function(deltaTime)
							local v27 = tbl4.Root()
							if not v27 or not n16 or tbl4.Steal.Carrying or fn13(v19) then
								return
							end

							if fn23() then
								if not tbl4.SafeCarry.Enabled and (v27.Position - n16).Magnitude > 2 then
									fn38(n16)
								end

								return
							end

							local n21 = math.max(deltaTime, 0.0041666666666666666)
							local n22 = vector + (n16 - v27.Position) / math.max(0.08, n21)
							local enabled = tbl4.SafeCarry.Enabled and tbl4.SafeCarry.Pace() or n4 + vector.Magnitude

							if n22.Magnitude > enabled then
								n22 = n22.Unit * enabled
							end

							local assemblyLinearVelocity = n22 + Vector3.new(0, workspace.Gravity * n21 * 0.5, 0)

							pcall(function()
								v27.AssemblyLinearVelocity = assemblyLinearVelocity
								v27.AssemblyAngularVelocity = Vector3.zero
							end)
						end)

						n17 = 0
						n18 = 0
						huge3 = math.huge
						v20 = nil
						v21 = nil
						n19 = 0
						huge4 = math.huge
						state = 5
					elseif state == 5 then
						flag3 = false

						if not (n17 < huge2) then
							state = 47
						else
							state = 6
						end
					elseif state == 6 then
						if fn13(v19) then
							state = 47
						else
							state = 7
						end
					elseif state == 7 then
						if tbl4.Steal.Carrying then
							state = 8
						else
							state = 11
						end
					elseif state == 8 then
						if tbl4.Steal.WrongEgg(carryUid) then
							state = 10
						else
							state = 9
						end
					elseif state == 9 then
						flag3 = true
						state = 47
					elseif state == 10 then
						str2 = "Picked up the wrong egg, dropped it"
						state = 11
					elseif state == 11 then
						v22 = tbl4.Root()

						if not v22 then
							state = 47
						else
							state = 12
						end
					elseif state == 12 then
						v23 = fn47(carryUid)

						if v23 then
							state = 21
						else
							state = 13
						end
					elseif state == 13 then
						if huge3 >= 0.5 then
							state = 14
						else
							state = 22
						end
					elseif state == 14 then
						v24, v25 = fn48(carryUid)

						if v24 then
							state = 20
						else
							state = 15
						end
					elseif state == 15 then
						huge3 = 0

						if v25 then
							state = 17
						else
							state = 16
						end
					elseif state == 16 then
						v23 = v24
						state = 22
					elseif state == 17 then
						n18 += 1

						if not (n18 >= 4) then
							state = 19
						else
							state = 18
						end
					elseif state == 18 then
						str2 = "The egg is gone"
						state = 47
					elseif state == 19 then
						v23 = v24
						state = 22
					elseif state == 20 then
						n18 = 0
						huge3 = 0
						v23 = v24
						state = 22
					elseif state == 21 then
						n18 = 0
						state = 22
					elseif state == 22 then
						if v23 then
							state = 23
						else
							state = 32
						end
					elseif state == 23 then
						now = os.clock()

						if v20 then
							state = 25
						else
							state = 24
						end
					elseif state == 24 then
						flag4 = v20
						state = 26
					elseif state == 25 then
						flag4 = v21
						state = 26
					elseif state == 26 then
						if flag4 then
							state = 27
						else
							state = 28
						end
					elseif state == 27 then
						flag4 = now > v21
						state = 28
					elseif state == 28 then
						if flag4 then
							state = 29
						else
							state = 31
						end
					elseif state == 29 then
						n20 = (v23 - v20) / math.max(now - v21, 0.0041666666666666666)

						if not (n20.Magnitude < 3000) then
							state = 31
						else
							state = 30
						end
					elseif state == 30 then
						vector = vector:Lerp(n20, 0.3)
						state = 31
					elseif state == 31 then
						n16 = v23 + Vector3.new(0, 3, 0)
						v20 = v23
						v21 = now
						state = 32
					elseif state == 32 then
						if not (n19 >= 0.4) then
							state = 36
						else
							state = 33
						end
					elseif state == 33 then
						if fn49(carryUid) then
							state = 35
						else
							state = 34
						end
					elseif state == 34 then
						str2 = "Egg dropped, taking it back"
						n19 = 0
						state = 36
					elseif state == 35 then
						str2 = "Another player has the egg, following it until it drops"
						n19 = 0
						state = 36
					elseif state == 36 then
						if n16 then
							state = 38
						else
							state = 37
						end
					elseif state == 37 then
						flag5 = n16
						state = 39
					elseif state == 38 then
						flag5 = (n16 - v22.Position).Magnitude <= n15
						state = 39
					elseif state == 39 then
						if flag5 then
							state = 40
						else
							state = 41
						end
					elseif state == 40 then
						flag5 = huge4 >= 0.1
						state = 41
					elseif state == 41 then
						if flag5 then
							state = 42
						else
							state = 46
						end
					elseif state == 42 then
						v26 = fn46(n16 - Vector3.new(0, 3, 0), 6, carryUid)

						if v26 then
							state = 44
						else
							state = 43
						end
					elseif state == 43 then
						task.spawn(fn28, carryUid)
						huge4 = 0
						state = 46
					elseif state == 44 then
						pcall(function()
							v26.HoldDuration = 0
						end)

						huge4 = 0

						if typeof(fireproximityprompt) ~= "function" then
							state = 46
						else
							state = 45
						end
					elseif state == 45 then
						pcall(fireproximityprompt, v26)
						state = 46
					elseif state == 46 then
						local result = RunService.Heartbeat:Wait()
						n17 += result
						huge4 += result
						huge3 += result
						n19 += result
						state = 5
					elseif state == 47 then
						connection:Disconnect()
						fn21()

						if flag3 then
							state = 49
						else
							state = 48
						end
					elseif state == 48 then
						flag3 = tbl4.Steal.Carrying == true
						state = 49
					elseif state == 49 then
						return flag3
					elseif state == 50 then
						return false
					end
				end
			end

			local function fn51(arg, arg2)
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not position then
					return false
				end

				if tbl4.InsideBase() and not tbl4.InsideBase(position) then
					local v19 = stealHome()

					if v19 then
						str2 = "Leaving the base through the safe zone"
						if not fn33(v19 + Vector3.new(0, 3, 0), arg2, nil, 400) then
							return false
						end
					end
				end

				str2 = "Flying to the egg"
				if not fn33(position + Vector3.new(0, 3, 0), arg2, nil, 400) then
					return false
				end
				str2 = "Taking the egg"
				local v19 = fn44(arg, arg2, 0.6, nil)

				if not v19 and not fn13(arg2) then
					v19 = fn30(arg, arg2)
				end

				if not v19 and not fn36(arg.Uid, arg2) then
					tbl18[arg.Uid] = os.clock() + n6
					return false
				end
				tbl4.Steal.LastFinishedAt = os.clock()
				return true
			end

			local tbl20 = { Uid = nil, Freed = nil, Token = nil }
			local n16 = 3

			local function fn52()
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("GuardAreas")
				local v19 = tbl4.Root()
				if not world or not v19 then
					return nil
				end
				local str3 = tostring(localPlayer.UserId)
				local carryAreaId = tbl4.Steal.CarryAreaId and fn41({ AreaId = tostring(tbl4.Steal.CarryAreaId) }) or nil
				local huge3 = math.huge
				local v20 = nil

				for _, child in ipairs(world:GetChildren()) do
					local guard = child:FindFirstChild("Guard")

					if guard then
						if tostring(guard:GetAttribute("TargetPlayer")) == str3 or tostring(guard:GetAttribute("WakeTargetPlayer")) == str3 then
							return guard
						end

						local ok, result = pcall(function()
							return guard:GetPivot().Position
						end)

						if ok then
							local magnitude = (result - v19.Position).Magnitude

							if magnitude < huge3 then
								v20 = guard
								huge3 = magnitude
							end
						end
					end
				end

				return carryAreaId or v20
			end

			local function fn53(arg, arg2, arg3)
				local v19 = fn52()
				if not v19 then
					return false
				end
				local v20 = fn42(arg, arg3 + Vector3.new(0, 3, 0))
				local n17 = 0

				while true do
					if not v20.Landed and n17 < n11 and not fn13(arg) then
						local ok, result = pcall(function()
							return v19:GetPivot().Position
						end)

						local v21 = tbl4.Root()

						if not (not ok or not v21) then
							if n14 + 5 < (result - v21.Position).Magnitude then
								local vector = Vector3.new(v21.Position.X - result.X, 0, v21.Position.Z - result.Z)
								local n18 = result + (vector.Magnitude > 0.1 and vector.Unit * n14 or Vector3.zero)

								fn33(Vector3.new(n18.X, result.Y + 3, n18.Z), arg, nil, 400, true, function()
									if v20.Landed then
										return "hit"
									end
									return nil
								end)
							end

							n17 += RunService.Heartbeat:Wait()
							continue
						end
					end

					break
				end

				v20.Stop()
				if not v20.Landed then
					return false
				end
				return fn50(arg, arg2)
			end

			tbl4.SafeCarry.Dangers = {}
			tbl4.SafeCarry.DangerAt = 0

			tbl4.SafeCarry.RefreshDangers = function()
				local safeCarry = tbl4.SafeCarry
				local dangerAt = safeCarry.DangerAt
				if os.clock() - dangerAt < 1 then
					return safeCarry.Dangers
				end
				safeCarry.DangerAt = os.clock()
				local dangers = {}

				local function fn54(arg)
					local ok, result, result2 = pcall(function()
						if arg:IsA("Model") then
							return arg:GetBoundingBox()
						end

						if arg:IsA("BasePart") then
							return arg.CFrame, arg.Size
						end
					end)

					if ok and result and result2 then
						local abs = math.abs
						local z = result2.Z
						local n17 = Vector3.new(math.abs(result2.X), 0, abs(z)) * 0.5
						local v19 = (result - result.Position):VectorToWorldSpace(n17)
						local x = n17.X
						local z2 = n17.Z
						local n18 = math.max(math.abs(v19.X), x, z2)
						local x2 = n17.X
						local z3 = n17.Z
						local n19 = math.max(math.abs(v19.Z), x2, z3)

						table.insert(dangers, {
							MinX = result.Position.X - n18,
							MaxX = result.Position.X + n18,
							MinZ = result.Position.Z - n19,
							MaxZ = result.Position.Z + n19,
							Name = arg.Name,
						})
					end
				end

				local function fn55(arg)
					if arg == "ScrambleLocalVisuals" or arg == "DrScrambleEvent" then
						return false
					end
					local v19 = string.lower(arg)
					return string.find(v19, "portal", 1, true) or string.find(v19, "teleport", 1, true) or string.find(v19, "mech", 1, true) or string.find(v19, "arena", 1, true) or string.find(v19, "scramble", 1, true)
				end

				for _, child in ipairs(workspace:GetChildren()) do
					if (child:IsA("Model") or child:IsA("BasePart") or child:IsA("Folder")) and fn55(child.Name) then
						if child:IsA("Folder") then
							for _, child2 in ipairs(child:GetChildren()) do
								fn54(child2)
							end
						else
							fn54(child)
						end
					end
				end

				local world = workspace:FindFirstChild("World")
				world = world and world:FindFirstChild("Build")

				if world then
					for _, child in ipairs(world:GetChildren()) do
						if fn55(child.Name) then
							for _, child2 in ipairs(child:GetChildren()) do
								fn54(child2)
							end
						end
					end
				end

				safeCarry.Dangers = dangers
				return dangers
			end

			tbl4.SafeCarry.Avoid = function(arg, arg2)
				for _, v19 in ipairs(tbl4.SafeCarry.RefreshDangers()) do
					local n17 = v19.MinX - 12
					local n18 = v19.MaxX + 12
					local n19 = v19.MinZ - 12
					local n20 = v19.MaxZ + 12
					local v20, v21, v22 = ipairs({ { arg.X, arg2.X - arg.X, n17, n18 }, { arg.Z, arg2.Z - arg.Z, n19, n20 } })
					local flag3 = true
					local n21 = 0
					local n22 = 1

					for _, v23 in v20, v21, v22 do
						local v24 = v23[1]
						local v25 = v23[2]
						local v26 = v23[3]
						local v27 = v23[4]

						if math.abs(v25) < 1e-06 then
							if v24 < v26 or v24 > v27 then
								flag3 = false
							end
						else
							local n23 = (v26 - v24) / v25
							local n24 = (v27 - v24) / v25
							local v28, v29

							if n23 > n24 then
								v28 = n24
								v29 = n23
							else
								v28 = n23
								v29 = n24
							end

							local n25 = math.max(n21, v28)
							local n26 = math.min(n22, v29)

							if n25 > n26 then
								flag3 = false
								n21 = n25
								n22 = n26
							else
								n21 = n25
								n22 = n26
							end
						end
					end

					if flag3 and not (arg.X >= n17 and arg.X <= n18 and arg.Z >= n19 and arg.Z <= n20) then
						local n23 = n19 - 2
						local n24 = n20 + 2
						local flag4 = math.abs(arg.Z - n23) <= math.abs(arg.Z - n24) and n23 or n24

						if flag4 < -440 or flag4 > -290 then
							flag4 = flag4 == n23 and n24 or n23
						end

						local flag5 = math.abs(arg.X - n17) <= math.abs(arg.X - n18) and n17 or n18

						if math.abs(arg.Z - flag4) < 3 then
							flag5 = math.abs(arg2.X - n17) <= math.abs(arg2.X - n18) and n17 or n18
						end

						return Vector3.new(flag5, arg2.Y, flag4), v19.Name
					end
				end

				return arg2, nil
			end

			tbl4.SafeCarry.NewHuman = function(arg)
				local safeCarry = tbl4.SafeCarry
				local laneOffset = safeCarry.LaneOffset
				local tbl21

				tbl21 = {
					Clock = 0,
					Factor = 1,
					Target = 1,
					NextShift = 0,
					Phase = math.random() * 3.1415926535897931 * 2,
					Period = 2 + math.random() * 2.5,
					PauseUntil = 0,
					Lane = (math.random() * 2 - 1) * laneOffset,
					Step = function(arg2, arg3, arg4)
						tbl21.Clock = tbl21.Clock + arg2

						if tbl21.NextShift <= tbl21.Clock then
							tbl21.NextShift = tbl21.Clock + 0.5 + math.random()
							local n17 = math.max(safeCarry.SpeedJitter, 0)

							if arg then
								tbl21.Target = 1 - math.random() * n17
							else
								tbl21.Target = 1 + (math.random() * 2 - 1) * n17
							end
						end

						tbl21.Factor = tbl21.Factor + (tbl21.Target - tbl21.Factor) * math.min(arg2 * 3, 1)
						local wobble = safeCarry.Wobble
						local n17 = math.sin(tbl21.Clock * 2 * 3.1415926535897931 / tbl21.Period + tbl21.Phase) * wobble
						arg4 = arg4 and arg3 and safeCarry.JumpsPerMinute > 0

						if arg4 then
							local n18 = safeCarry.JumpsPerMinute / 60 * arg2
							arg4 = math.random() < n18
						end

						if arg4 then
							pcall(function()
								arg3.Jump = true
							end)
						end

						local flag3 = false

						if not arg then
							if tbl21.Clock < tbl21.PauseUntil then
								flag3 = true
							else
								local flag4 = safeCarry.PausesPerMinute > 0

								if flag4 then
									local n18 = safeCarry.PausesPerMinute / 60 * arg2
									flag4 = math.random() < n18
								end

								if flag4 then
									tbl21.PauseUntil = tbl21.Clock + 0.3 + math.random() * 0.9
									flag3 = true
								end
							end
						end

						return tbl21.Factor, tbl21.Lane + n17, flag3
					end,
				}

				return tbl21
			end

			tbl4.SafeCarry.React = function(arg, arg2)
				local n17 = math.max(0, math.min(arg, arg2))
				local n18 = math.max(arg, arg2, 0)
				return n17 + math.random() * (n18 - n17)
			end

			tbl4.SafeCarry.RunTo = function(arg, arg2)
				local safeCarry = tbl4.SafeCarry
				local position = typeof(arg.CFrame) == "CFrame" and arg.CFrame.Position or nil
				if not position then
					return false
				end
				fn22()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.PlatformStand = false

					if character:FindFirstChildWhichIsA("Tool") then
						pcall(function()
							humanoid:UnequipTools()
						end)
					end
				end

				local v19 = safeCarry.NewHuman(false)
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("SeparationLine")
				local x = world and world:IsA("BasePart") and world.Position.X or 552
				local v20 = stealHome()
				local v21 = tbl4.Root()
				local str3 = "field"
				local z = v21 and v21.Position.Z or position.Z

				if v21 and v20 and v21.Position.X < x - 2 then
					local z2 = v20.Z

					if (Vector3.new(v21.Position.X, 0, v21.Position.Z) - Vector3.new(v20.X, 0, v20.Z)).Magnitude > 20 then
						str3 = "safe"
					end

					z = z2
				end

				local n17 = math.clamp(z + v19.Lane, -425, -300)
				local n18 = position.Y + 3

				local function fn54(arg3)
					local v22 = tbl4.Root()
					local character2 = localPlayer.Character
					local flag3 = not v22 or not character2 or math.abs(v22.Position.Y - arg3) < 1

					if not flag3 then
						local snapLimit = safeCarry.SnapLimit
						flag3 = math.abs(v22.Position.Y - arg3) > snapLimit
					end

					if flag3 then
						return false
					end

					pcall(function()
						local rotation = v22.CFrame.Rotation
						character2:PivotTo(CFrame.new(Vector3.new(v22.Position.X, arg3, v22.Position.Z)) * rotation)
						v22.AssemblyLinearVelocity = Vector3.new(v22.AssemblyLinearVelocity.X, 0, v22.AssemblyLinearVelocity.Z)
					end)

					return true
				end

				local function fn55()
					if safeCarry.RunHeight <= 0.5 then
						return
					end
					fn54(n18 + safeCarry.RunHeight)
				end

				if str3 == "field" then
					fn55()
				end

				local now = os.clock()
				local now2 = os.clock()
				local now3 = os.clock()
				local position2 = v21 and v21.Position or nil

				local function fn56(arg3, arg4, arg5, arg6)
					local vector = Vector3.new(arg4.X - arg3.Position.X, 0, arg4.Z - arg3.Position.Z)
					local magnitude = vector.Magnitude
					local unit = magnitude > 0.01 and vector.Unit or Vector3.zero

					if safeCarry.RunHeight > 0.5 and str3 == "field" and not arg6 then
						local runSpeed = safeCarry.RunSpeed
						local n19 = math.max(tbl4.WalkSpeed() * runSpeed * arg5, 8)
						local n20 = math.clamp(safeCarry.ClimbShare, 0.1, 0.9)
						local magnitude2 = Vector3.new(position.X - arg3.Position.X, 0, position.Z - arg3.Position.Z).Magnitude

						if magnitude2 <= 3 then
							if fn54(n18) then
								return
							end
						end

						local n21 = magnitude2 <= 3 and n18 or n18 + safeCarry.RunHeight
						if math.abs(n21 - arg3.Position.Y) > 2 and fn54(n21) then
							return
						end
						local n22 = math.clamp((n21 - arg3.Position.Y) / 0.12, -n19 * n20, n19 * n20)
						local n23 = unit * math.min(math.sqrt(math.max(n19 * n19 - n22 * n22, 0)), magnitude / 0.05)

						pcall(function()
							arg3.AssemblyLinearVelocity = Vector3.new(n23.X, n22, n23.Z)
						end)

						return
					end

					pcall(function()
						if arg6 or magnitude <= 0.01 then
							if humanoid then
								if safeCarry.RunStyle == "Walk" then
									humanoid:MoveTo(arg3.Position)
								end

								humanoid:Move(Vector3.zero, false)
							end

							if safeCarry.RunStyle ~= "Walk" then
								arg3.AssemblyLinearVelocity = Vector3.new(0, arg3.AssemblyLinearVelocity.Y, 0)
							end
						elseif safeCarry.RunStyle == "Walk" then
							if humanoid then
								humanoid:MoveTo(arg3.Position + unit * math.min(magnitude, 30))
							end
						else
							local runSpeed = safeCarry.RunSpeed
							local n19 = unit * math.min(math.max(tbl4.WalkSpeed() * runSpeed * arg5, 8), magnitude / 0.05)
							arg3.AssemblyLinearVelocity = Vector3.new(n19.X, arg3.AssemblyLinearVelocity.Y, n19.Z)

							if safeCarry.RunAnimate and humanoid then
								humanoid:Move(unit, false)
							end
						end
					end)
				end

				while os.clock() - now < 240 do
					if fn13(arg2) then
						return false
					end
					local v22 = tbl4.Root()
					if not v22 then
						return false
					end
					local now4 = os.clock()
					local n19 = math.max(now4 - now2, 0.0041666666666666666)
					local vector = Vector3.new(position.X - v22.Position.X, 0, position.Z - v22.Position.Z)
					if str3 == "field" and vector.Magnitude <= 2.5 and (safeCarry.RunHeight <= 0.5 or v22.Position.Y - n18 < 4) then
						break
					end
					local v23, v24, flag3 = v19.Step(n19, humanoid, humanoid and humanoid.FloorMaterial ~= Enum.Material.Air)

					if vector.Magnitude <= 15 then
						flag3 = false
					end

					local vector2 = position

					if str3 == "safe" and v20 then
						if (Vector3.new(v20.X, 0, v20.Z) - Vector3.new(v22.Position.X, 0, v22.Position.Z)).Magnitude <= 6 then
							str3 = "field"
							fn55()
						end

						str2 = "Walking out to the safe zone"
						vector2 = v20
					else
						if not safeCarry.StraightRun and safeCarry.RunHeight <= 0.5 and math.abs(position.X - v22.Position.X) > 25 then
							vector2 = Vector3.new(position.X, position.Y, math.clamp(n17 + v24, -425, -300))
						end

						str2 = string.format("Running to the egg, %d studs left", math.floor(vector.Magnitude + 0.5))
					end

					local v25, v26 = safeCarry.Avoid(v22.Position, vector2)

					if v26 then
						str2 = "Walking around " .. tostring(v26)
					end

					fn56(v22, v25, v23, flag3)

					if now4 - now3 >= 1.5 then
						if not flag3 and position2 and (v22.Position - position2).Magnitude < 3 and humanoid then
							pcall(function()
								humanoid.Jump = true
							end)
						end

						position2 = v22.Position
						now3 = now4
					end

					RunService.Heartbeat:Wait()
					now2 = now4
				end

				local v22 = tbl4.Root()

				if v22 then
					fn56(v22, v22.Position, 1, true)
				end

				local vector = nil

				if v22 then
					local vector2 = Vector3.new(v22.Position.X - position.X, 0, v22.Position.Z - position.Z)
					local vector3 = vector2.Magnitude > 0.1 and vector2.Unit * 2 or Vector3.zero
					vector = Vector3.new(position.X + vector3.X, v22.Position.Y, position.Z + vector3.Z)
				end

				local connection = RunService.Heartbeat:Connect(function()
					local v23 = tbl4.Root()
					if not v23 or not vector or tbl4.Steal.Carrying or tbl4.AntiGuard.Busy then
						return
					end
					local vector2 = Vector3.new(vector.X - v23.Position.X, 0, vector.Z - v23.Position.Z)

					pcall(function()
						if vector2.Magnitude > 1.5 then
							local rotation = v23.CFrame.Rotation
							v23.CFrame = CFrame.new(vector.X, v23.Position.Y, vector.Z) * rotation
						end

						v23.AssemblyLinearVelocity = Vector3.new(0, math.min(v23.AssemblyLinearVelocity.Y, 0), 0)
					end)
				end)

				local function fn57(arg3)
					connection:Disconnect()
					return arg3
				end

				local v23 = fn41(arg)
				local now4 = os.clock()
				local v24 = safeCarry.React(safeCarry.ReactMin, safeCarry.ReactMax)

				while true do
					if fn13(arg2) then
						return (fn57(false))
					else
						local n19 = os.clock() - now4
						local n20 = safeCarry.RunWait + v24
						local flag3 = not safeCarry.WaitGuard or not v23 or v23:GetAttribute("GuardState") == "Sleeping"
						if n19 >= n20 and (flag3 or n19 >= n20 + 15) then
							break
						end
						str2 = n19 < n20 and string.format("Waiting before the grab, %.1fs", n20 - n19) or "Waiting for the guard to sleep"
						RunService.Heartbeat:Wait()
					end
				end

				str2 = "Taking the egg"
				local v25 = fn44(arg, arg2, 0.8, nil)

				if not v25 and not fn13(arg2) then
					v25 = fn30(arg, arg2)
				end

				fn57()
				if not v25 then
					return false
				end
				tbl4.Steal.LastFinishedAt = os.clock()
				return true
			end

			tbl4.SafeCarry.Pace = function()
				local n17 = tonumber(tbl4.SafeCarry.RunSpeed) or 1
				return math.max(tbl4.WalkSpeed() * n17, 16)
			end

			tbl4.SafeCarry.Plan = function(arg, arg2, arg3)
				local safeCarry = tbl4.SafeCarry
				local character = localPlayer.Character

				if character then
					character:FindFirstChildOfClass("Humanoid")
				end

				local v19 = tbl4.WalkSpeed()
				arg3 = arg3 or safeCarry.Mult or 1

				if safeCarry.SameSpeedBigEggs then
					arg3 = math.max(arg3, safeCarry.LightMult)
				end

				local n17 = v19 * safeCarry.CarryRatio * arg3
				local n18 = n17 * safeCarry.SpeedRatio
				local n19 = safeCarry.ExcessSeconds * n17
				local n20

				if arg2 and arg2 > n19 then
					n20 = math.min(n18, n17 * arg2 / (arg2 - n19))
				else
					n20 = n18
				end

				local guards = tbl.Guards
				local flag3 = type(guards) == "table" and type(guards.Directory) == "table" and guards.Directory[tostring(arg)] or nil
				local n21 = type(flag3) == "table" and tonumber(flag3.WalkSpeed) or 0
				if not safeCarry.BeatGuard then
					return math.max(math.min(n17 * safeCarry.EasyRatio, n20), n17), true, n17, n20, n21
				end
				local n22 = math.max(n21 + safeCarry.GuardMargin, n17 * safeCarry.MinRatio)
				local n23 = math.max(n22, n21 * safeCarry.GuardRatio)

				if n20 < n22 then
					local n24 = n17 * safeCarry.SpeedRatio
					local n25 = safeCarry.StretchSeconds * n17
					local n26

					if arg2 and arg2 > n25 then
						n26 = math.min(n24, n17 * arg2 / (arg2 - n25))
					else
						n26 = n24
					end

					local n27 = n21 + math.max(safeCarry.GuardMargin, 1)
					if n27 <= n26 then
						return n27, true, n17, n26, n21
					end
				end

				return math.max(math.min(n23, n20), n17), n22 <= n20, n17, n20, n21
			end

			tbl4.SafeCarry.Unsafe = function(arg)
				local safeCarry = tbl4.SafeCarry
				if not safeCarry.Enabled or type(arg) ~= "table" or not arg.Uid or not safeCarry.Blocked[arg.Uid] then
					return nil
				end
				return string.format("the guard caught you with this %s before, skipping it", tostring(arg.Category))
			end

			tbl4.SafeCarry.Settle = function(arg, arg2)
				local safeCarry = tbl4.SafeCarry
				local character = localPlayer.Character

				if character then
					character:FindFirstChildOfClass("Humanoid")
				end

				math.max(tbl4.WalkSpeed() * safeCarry.CarryRatio * (safeCarry.Seen[tostring(arg2.Category)] or safeCarry.GuessMult) * safeCarry.WaitRate, 1)
				local baseWait = safeCarry.BaseWait
				local v19 = fn41(arg2)

				while true do
					if fn13(arg) then
						return false
					else
						local n17 = os.clock() - (safeCarry.JumpAt or 0)
						local flag3 = not safeCarry.WaitGuard or not v19 or v19:GetAttribute("GuardState") == "Sleeping"
						if n17 >= baseWait and (flag3 or n17 >= baseWait + 15) then
							break
						end

						if n17 < baseWait then
							str2 = string.format("Letting the jump settle, %.1fs", baseWait - n17)
						else
							str2 = "Waiting for the guard to sleep"
						end

						RunService.Heartbeat:Wait()
					end
				end

				return true
			end

			tbl4.MonitorAction = tbl4.MonitorAction or function(arg)
				local ok, result = pcall(debug.getconstants, arg)
				if not ok or type(result) ~= "table" then
					return false
				end

				for _, v19 in pairs(result) do
					local flag3 = type(v19) == "string"

					if flag3 then
						flag3 = v19 == "Relocate" or v19 == "SetWalkSpeed" or v19 == "BeginRagdoll" or v19 == "EndRagdoll" or v19 == "BeginImpulse"
					end

					if flag3 then
						return true
					end
				end

				return false
			end

			tbl4.SafeCarry.LineDropHome = function(arg)
				local safeCarry = tbl4.SafeCarry
				local steal = tbl4.Steal
				local carryUid = steal.CarryUid
				local v19 = stealHome()
				local v20 = tbl4.Root()
				if type(carryUid) ~= "string" or not v19 or not v20 then
					return false
				end
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("SeparationLine")
				local x = world and world:IsA("BasePart") and world.Position.X or 552.2
				local y = world and world:IsA("BasePart") and world.Position.Y or 67.67
				local tbl21 = {}

				pcall(function()
					for _, v21 in ipairs({ RunService.Heartbeat, RunService.PreSimulation, RunService.PostSimulation }) do
						for _, v22 in ipairs(getconnections(v21)) do
							local ok, result = pcall(function()
								return v22.Function
							end)

							if ok and type(result) == "function" then
								local ok2, result2 = pcall(debug.info, result, "s")

								if ok2 and string.find(tostring(result2), "UGI", 1, true) and not tbl4.MonitorAction(result) then
									local ok3, result3 = pcall(function()
										return v22.Enabled
									end)

									if not ok3 or result3 ~= false then
										if pcall(function()
											v22:Disable()
										end) then
											table.insert(tbl21, v22)
										end
									end
								end
							end
						end
					end
				end)

				local flag3 = false
				local connection = nil

				pcall(function()
					connection = networking["RE/RigSync/Refresh"].OnClientEvent:Connect(function(arg2)
						if type(arg2) == "table" and arg2.Action == "Relocate" then
							flag3 = true
						end
					end)
				end)

				local currentCamera = workspace.CurrentCamera
				local tbl22 = nil

				local function fn54()
					if tbl22 or not currentCamera then
						return
					end
					tbl22 = { Type = currentCamera.CameraType, CFrame = currentCamera.CFrame }

					pcall(function()
						currentCamera.CameraType = Enum.CameraType.Scriptable
						currentCamera.CFrame = tbl22.CFrame
					end)
				end

				local function fn55()
					if not tbl22 or not currentCamera then
						return
					end
					local v21 = tbl22
					tbl22 = nil

					pcall(function()
						currentCamera.CameraType = v21.Type
					end)
				end

				local function fn56()
					fn55()

					if connection then
						connection:Disconnect()
						connection = nil
					end

					for _, v21 in ipairs(tbl21) do
						pcall(function()
							v21:Enable()
						end)
					end

					table.clear(tbl21)
				end

				local now = os.clock()

				local function fn57(arg2, arg3, arg4, arg5)
					local n17 = 0

					while n17 < arg4 and not fn13(arg) do
						local v21 = tbl4.Root()
						if not v21 then
							return false
						end

						if arg5 and arg5() then
							return true
						end
						local vector = Vector3.new(arg2.X - v21.Position.X, 0, arg2.Z - v21.Position.Z)
						if vector.Magnitude < 2.5 then
							return true
						end
						local n18 = vector.Unit * math.min(arg3, vector.Magnitude / 0.05)

						pcall(function()
							v21.AssemblyLinearVelocity = Vector3.new(n18.X, v21.AssemblyLinearVelocity.Y, n18.Z)
						end)

						n17 += RunService.Heartbeat:Wait()
					end

					return false
				end

				fn22()
				local n17 = math.clamp(v20.Position.Z, -425, -300)
				local vector = Vector3.new(x + (safeCarry.Hops and safeCarry.HopStop or safeCarry.LineGap), y + 3.35, n17)

				local function fn58()
					local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")

					local ok, result = pcall(function()
						return rfEggWorldAskFieldEggSnapshot:InvokeServer()
					end)

					local records = ok and type(result) == "table" and result.Records or nil

					if type(records) == "table" then
						for _, record in pairs(records) do
							if type(record) == "table" and record.Uid == carryUid then
								return record
							end
						end
					end

					return nil
				end

				local magnitude = Vector3.new(v20.Position.X - x, 0, v20.Position.Z - n17).Magnitude
				local max = math.max
				local carryRatio = safeCarry.CarryRatio
				local v21 = max(tbl4.WalkSpeed() * carryRatio * (tonumber(safeCarry.Mult) or safeCarry.LightMult), 1)
				local directMargin = safeCarry.DirectMargin
				local n18 = math.max(0, (magnitude - safeCarry.DirectBudget) / v21) + directMargin

				if safeCarry.CrossNow then
					n18 = safeCarry.DirectMargin
				end

				local function fn59()
					local v22 = tbl4.Root()
					if not v22 then
						return
					end

					pcall(function()
						v22.CFrame = CFrame.new(vector) * CFrame.Angles(0, 1.5707963267948966, 0)
						v22.AssemblyLinearVelocity = Vector3.zero
						v22.AssemblyAngularVelocity = Vector3.zero
					end)
				end

				fn54()

				if safeCarry.Hops then
					local v22 = tbl4.Root()

					if v22 then
						local n19 = v22.Position.Y + safeCarry.HopLift
						local x2 = v22.Position.X
						local hopRatio = safeCarry.HopRatio
						local n20 = math.max(tbl4.WalkSpeed() * hopRatio, 40)

						while x2 - n20 > vector.X and steal.Carrying and not fn13(arg) do
							x2 -= n20
							str2 = string.format("Line Drop: hopping home, X %d", math.floor(x2))
							local n21 = 0

							while n21 < safeCarry.HopGap do
								local v23 = tbl4.Root()

								if v23 then
									pcall(function()
										v23.CFrame = CFrame.new(x2, n19, n17) * CFrame.Angles(0, 1.5707963267948966, 0)
										v23.AssemblyLinearVelocity = Vector3.zero
										v23.AssemblyAngularVelocity = Vector3.zero
									end)
								end

								n21 += RunService.Heartbeat:Wait()
							end
						end
					end
				end

				str2 = "Line Drop: landing next to the line"
				fn59()

				if safeCarry.Hops and steal.Carrying then
					local n19 = 0

					while n19 < safeCarry.DropDelay and steal.Carrying and not fn13(arg) do
						n19 += RunService.Heartbeat:Wait()
					end

					if steal.Carrying then
						str2 = "Line Drop: dropping the egg next to the line"
						local eggState = tbl.EggState

						if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
							pcall(eggState.DropFieldEgg, "PlayerRequest")
						end

						local n20 = 0

						while steal.Carrying and n20 < 1 and not fn13(arg) do
							n20 += RunService.Heartbeat:Wait()
						end
					end
				end

				fn55()

				if safeCarry.ShakeTime > 0 then
					local vector2 = Vector3.new(x - safeCarry.ShakeInside, vector.Y, n17)
					local flag4 = false
					local n19 = 0

					while n19 < safeCarry.ShakeTime and steal.Carrying and not fn13(arg) do
						str2 = "Line Drop: shaking at the line"
						flag4 = not flag4
						local v22 = tbl4.Root()

						if v22 then
							pcall(function()
								v22.CFrame = CFrame.new(flag4 and vector2 or vector) * CFrame.Angles(0, 1.5707963267948966, 0)
								v22.AssemblyLinearVelocity = Vector3.zero
							end)
						end

						n19 += RunService.Heartbeat:Wait()
					end

					fn59()
				end

				local flag4 = n18 < safeCarry.LineWait
				local n19 = 0
				local n20 = 1

				while true do
					local flag5 = steal.Carrying and n19 < safeCarry.LineWait

					if flag5 then
						flag5 = not (flag4 and n19 >= n18)
					end

					if flag5 and not fn13(arg) then
						if flag4 then
							str2 = string.format("Line Drop: stepping over the line in %.1fs", math.max(n18 - n19, 0))
						else
							str2 = string.format("Line Drop: crossing needs %.1fs, waiting for the guard, %.0fs left", n18, safeCarry.LineWait - n19)
						end

						if flag3 and safeCarry.ReJump and n20 < 40 and not fn31() then
							flag3 = false
							n20 += 1
							str2 = "Line Drop: pulled back, jumping to the line again"
							fn59()
						end

						n19 += RunService.Heartbeat:Wait()
						continue
					end

					break
				end

				if steal.Carrying and flag4 and n19 >= n18 and not fn13(arg) then
					str2 = "Line Drop: stepping over the line"
					local crossRatio = safeCarry.CrossRatio

					fn57(v19, tbl4.WalkSpeed() * crossRatio, 6, function()
						return safeCarry.LastDelivered >= now or not steal.Carrying
					end)

					local n21 = 0

					while n21 < 1.5 and safeCarry.LastDelivered < now and steal.Carrying and not fn13(arg) do
						n21 += RunService.Heartbeat:Wait()
					end

					if safeCarry.LastDelivered >= now then
						fn56()
						return true
					end
				end

				if steal.Carrying then
					fn56()
					str2 = "Line Drop: the guard never came, dropping the egg"
					local eggState = tbl.EggState

					if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
						pcall(eggState.DropFieldEgg, "PlayerRequest")
					end

					return false
				end

				if safeCarry.GetUp then
					task.spawn(function()
						local n21 = 0

						while n21 < 1.5 do
							local character = localPlayer.Character
							local humanoid = character and character:FindFirstChildOfClass("Humanoid")

							if humanoid then
								pcall(function()
									humanoid.PlatformStand = false
									local state = humanoid:GetState()

									if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
										humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
									end
								end)
							end

							n21 += RunService.Heartbeat:Wait()
						end
					end)
				end

				local n21 = 0

				while not safeCarry.SnapPickup and not safeCarry.GetUp and fn31() and n21 < 6 and not fn13(arg) do
					str2 = "Line Drop: egg is down at the line, getting up"
					n21 += RunService.Heartbeat:Wait()
				end

				local n22 = 0

				while not fn13(arg) and n22 < 4 do
					n22 += 1
					local v22 = fn48(carryUid)

					if not v22 then
						fn56()
						str2 = "Line Drop: the egg is gone"
						return false
					end

					local v23 = fn58()

					if v23 and v23.State == "Slot" then
						fn56()
						str2 = "Line Drop: the egg went back to its nest"
						return false
					end

					str2 = "Line Drop: picking the egg up at the line"
					local n23

					if safeCarry.SnapPickup then
						local v24 = tbl4.Root()

						if v24 then
							pcall(function()
								v24.CFrame = CFrame.new(v22 + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 1.5707963267948966, 0)
								v24.AssemblyLinearVelocity = Vector3.zero
							end)
						end

						n23 = 5
					else
						local pickupRatio = safeCarry.PickupRatio
						fn57(v22, tbl4.WalkSpeed() * pickupRatio, 5)
						n23 = 2.5
					end

					local n24 = 0

					while not steal.Carrying and n24 < n23 and not fn13(arg) do
						task.spawn(fn28, carryUid)

						if safeCarry.SnapPickup then
							local v24 = tbl4.Root()

							if v24 and Vector3.new(v24.Position.X - v22.X, 0, v24.Position.Z - v22.Z).Magnitude > 6 then
								pcall(function()
									v24.CFrame = CFrame.new(v22 + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 1.5707963267948966, 0)
								end)
							end
						end

						n24 += task.wait(0.15)
					end

					if steal.Carrying and not steal.WrongEgg(carryUid) then
						break
					end
				end

				if not steal.Carrying then
					fn56()
					str2 = "Line Drop: could not pick the egg up again"
					return false
				end

				local v22 = tbl4.Root()

				if v22 and v22.Position.X - x > safeCarry.FarFromLine then
					fn56()
					str2 = "Line Drop: egg ended up far from the line, carrying it home safely"
					return tbl4.SafeCarry.Home(arg)
				end

				str2 = "Line Drop: stepping over the line"
				local crossRatio = safeCarry.CrossRatio

				fn57(v19, tbl4.WalkSpeed() * crossRatio, 6, function()
					return safeCarry.LastDelivered >= now or not steal.Carrying
				end)

				local v23 = tbl4.Root()

				if v23 then
					pcall(function()
						v23.AssemblyLinearVelocity = Vector3.new(0, v23.AssemblyLinearVelocity.Y, 0)
					end)
				end

				local n23 = 0

				while n23 < 2 and safeCarry.LastDelivered < now and steal.Carrying and not fn13(arg) do
					n23 += RunService.Heartbeat:Wait()
				end

				fn56()
				return safeCarry.LastDelivered >= now
			end

			tbl4.SafeCarry.Home = function(arg)
				local safeCarry = tbl4.SafeCarry
				local v19 = stealHome()
				local v20 = tbl4.Root()
				if not v19 or not v20 then
					return false
				end
				fn22()
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("SeparationLine")
				local n17 = (world and world:IsA("BasePart") and world.Position.X or 552) - 7
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.PlatformStand = false
				end

				local now = os.clock()
				local n18 = 0

				local function fn54()
					local v21 = tbl4.Root()
					if not v21 then
						return
					end
					local v22, v23, v24, v25, v26 = safeCarry.Plan(tbl4.Steal.CarryAreaId, (Vector3.new(v21.Position.X, 0, v21.Position.Z) - Vector3.new(v19.X, 0, v19.Z)).Magnitude + math.max(0, safeCarry.Height) * 2, safeCarry.Mult)
					local n19 = v22 * safeCarry.CarryScale
					n18 = n19
					safeCarry.PlanOk = v23
					safeCarry.FloorSpeed = safeCarry.BeatGuard and math.min(v26 + math.max(safeCarry.GuardMargin, 1), v25) or 0
					str2 = string.format("Carrying home at %d (carry %d, guard %d, max %d)%s", math.floor(n19 + 0.5), math.floor(v24 + 0.5), math.floor(v26 + 0.5), math.floor(v25 + 0.5), v23 and "" or ", guard is faster, going at your max safe speed")
				end

				local function fn55()
					local n19 = math.max(0, safeCarry.Height)
					local v21 = tbl4.Root()
					local character2 = localPlayer.Character
					if n19 <= 0.5 or not v21 or not character2 then
						return
					end
					local n20 = v19.Y + n19
					if n20 - 2 <= v21.Position.Y then
						return
					end
					local rotation = v21.CFrame.Rotation
					local n21 = CFrame.new(Vector3.new(v21.Position.X, n20, v21.Position.Z)) * rotation

					pcall(function()
						character2:PivotTo(n21)
						v21.AssemblyLinearVelocity = Vector3.zero
						v21.AssemblyAngularVelocity = Vector3.zero
					end)
				end

				fn54()
				local v21 = safeCarry.NewHuman(true)
				local v22 = tbl4.Root()
				local n19 = math.clamp((v22 and v22.Position.Z or v19.Z) + v21.Lane, -425, -300)
				local now2 = os.clock()

				if safeCarry.CarryReact > 0 then
					local n20 = os.clock() + safeCarry.React(0, safeCarry.CarryReact)

					while os.clock() < n20 and not fn13(arg) do
						RunService.Heartbeat:Wait()
					end
				end

				local n20 = 0

				if safeCarry.CarryStyle ~= "Walk" then
					fn55()
				end

				while not fn13(arg) do
					local v23 = tbl4.Root()
					if not v23 then
						return false
					end

					if not tbl4.Steal.Carrying then
						if now <= safeCarry.LastDelivered then
							return true
						end
						task.wait(0.1)
						if now <= safeCarry.LastDelivered then
							return true
						end

						if now <= safeCarry.LastFailed then
							str2 = "Delivery was rewound, too fast for your speed"
							return false
						end

						if not safeCarry.PlanOk and tbl4.Steal.CarryUid then
							safeCarry.Blocked[tbl4.Steal.CarryUid] = true
							str2 = string.format("The guard caught you with %s, it is faster than your max safe speed, skipping this egg", tostring(safeCarry.Category))
							return false
						end

						n20 += 1
						if safeCarry.RecoverTries < n20 then
							str2 = "The egg is gone"
							return false
						end
						str2 = "Egg dropped, taking it back"
						if not fn50(arg) then
							str2 = "Could not take the egg back"
							return false
						end
						local n21 = 0

						while fn31() and n21 < 4 and not fn13(arg) do
							n21 += RunService.Heartbeat:Wait()
						end

						local n22 = math.min(now, os.clock())
						fn54()

						if safeCarry.CarryStyle ~= "Walk" then
							fn55()
						end

						v23 = tbl4.Root()
						if not v23 then
							return false
						end
						now = n22
					end

					local now3 = os.clock()
					local n21 = math.max(now3 - now2, 0.0041666666666666666)
					local flag3 = safeCarry.CarryStyle == "Walk"
					local n22 = flag3 and 0 or math.max(0, safeCarry.Height)
					local v24, v25 = v21.Step(n21, n22 <= 0.5 and humanoid or nil, humanoid and humanoid.FloorMaterial ~= Enum.Material.Air)
					local n23 = math.clamp(n19 + v25, -425, -300)
					local vector = v23.Position.X > n17 + 2 and Vector3.new(n17, v23.Position.Y, n23) or v19
					local v26, v27 = safeCarry.Avoid(v23.Position, vector)

					if not v27 then
						v26 = vector
					end

					local vector2 = Vector3.new(v26.X - v23.Position.X, 0, v26.Z - v23.Position.Z)
					if vector2.Magnitude < 2 and v26 == v19 then
						break
					end
					local n24 = math.max(n18 * v24, safeCarry.FloorSpeed or 0)

					if os.clock() < (safeCarry.SlowUntil or 0) then
						n24 *= safeCarry.SlowFactor
					end

					if flag3 then
						pcall(function()
							if humanoid and vector2.Magnitude > 0.01 then
								humanoid:MoveTo(v23.Position + vector2.Unit * math.min(vector2.Magnitude, 30))
							end
						end)
					elseif n22 > 0.5 then
						local n25 = math.clamp(safeCarry.ClimbShare, 0.1, 0.9)
						local y = v19.Y
						local n26 = math.max(0, v23.Position.X - n17)
						local n27 = n22 * math.sqrt(1 - n25 * n25) / n25
						local n28 = y + n22

						if v26 == v19 or n26 <= n27 then
							n28 = y + n22 * math.clamp((v26 == v19 and 0 or n26) / math.max(n27, 1), 0, 1)
						end

						local n29 = math.clamp((n28 - v23.Position.Y) / 0.12, -n24 * n25, n24 * n25)
						local v28 = math.sqrt(math.max(n24 * n24 - n29 * n29, 0))
						local vector3 = vector2.Magnitude > 0.01 and vector2.Unit * math.min(v28, vector2.Magnitude / 0.05) or Vector3.zero

						pcall(function()
							v23.AssemblyLinearVelocity = Vector3.new(vector3.X, n29, vector3.Z)
						end)
					else
						local vector3 = vector2.Magnitude > 0.01 and vector2.Unit * math.min(n24, vector2.Magnitude / 0.05) or Vector3.zero

						pcall(function()
							v23.AssemblyLinearVelocity = Vector3.new(vector3.X, v23.AssemblyLinearVelocity.Y, vector3.Z)

							if safeCarry.RunAnimate and humanoid and vector2.Magnitude > 0.01 then
								humanoid:Move(vector2.Unit, false)
							end
						end)
					end

					RunService.Heartbeat:Wait()
					now2 = now3
				end

				if humanoid then
					pcall(function()
						local v23 = tbl4.Root()

						if safeCarry.CarryStyle == "Walk" and v23 then
							humanoid:MoveTo(v23.Position)
						end

						humanoid:Move(Vector3.zero, false)
					end)
				end

				local n21 = 0

				while n21 < 2 and not fn13(arg) do
					if safeCarry.LastDelivered >= now then
						return true
					end

					if now <= safeCarry.LastFailed then
						str2 = "Delivery was rewound, too fast for your speed"
						return false
					end

					if not tbl4.Steal.Carrying then
						break
					end
					n21 += RunService.Heartbeat:Wait()
				end

				if tbl4.Steal.Carrying then
					task.wait(0.2)
					local eggState = tbl.EggState

					if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
						pcall(eggState.DropFieldEgg, "PlayerRequest")
					end
				end

				return safeCarry.LastDelivered >= now
			end

			local function fn54(arg)
				local antiGuard = tbl4.AntiGuard

				if antiGuard.Enabled and not tbl4.SafeCarry.LineDrop then
					local n17 = 0

					while not antiGuard.Busy and n17 < 1 and not fn13(arg) do
						str2 = "Waiting for Anti Guard to start"
						n17 += RunService.Heartbeat:Wait()
					end

					local busy = antiGuard.Busy
					local n18 = 0

					while antiGuard.Busy and n18 < 30 and not fn13(arg) do
						str2 = "Anti Guard is slipping past the guard"
						n18 += RunService.Heartbeat:Wait()
					end

					if busy then
						local n19 = 0
						local n20 = 0

						while n19 < 10 and not fn13(arg) do
							local v19 = fn31()
							local ok, result = pcall(tbl4.Steal.HeldByMe)
							ok = ok and result == true
							local flag3 = not v19
							if flag3 and not ok then
								break
							end

							if flag3 and ok and not antiGuard.Busy then
								n20 += RunService.Heartbeat:Wait()
								if not (n20 >= 0.3) then
									continue
								end
								break
							end

							str2 = v19 and "The guard hit you, waiting until you can move" or "Waiting for Anti Guard to finish"
							n19 += RunService.Heartbeat:Wait()
							n20 = 0
						end

						local ok, result = pcall(tbl4.Steal.HeldByMe)

						if ok and not result then
							tbl4.Steal.Carrying = false
						end

						local safeCarry = tbl4.SafeCarry
						local v19 = stealHome()
						local n21 = v19 and safeCarry.Enabled and safeCarry.CarryStyle ~= "Walk" and safeCarry.Height > 0.5 and v19.Y + safeCarry.Height or nil
						local n22 = 0

						while n22 < 0.8 and tbl4.Steal.Carrying and not fn13(arg) do
							str2 = n22 < 0.6 and "Anti Guard done, rising up" or "Anti Guard done, getting ready"
							local v20 = tbl4.Root()

							if v20 and n21 then
								local n23 = n21 - v20.Position.Y
								local n24 = n22 < 0.6 and math.clamp(n23 / math.max(0.6 - n22, 0.1), -120, 120) or math.clamp(n23 / 0.2, -30, 30)

								pcall(function()
									v20.AssemblyLinearVelocity = Vector3.new(0, n24, 0)
								end)
							end

							n22 += RunService.Heartbeat:Wait()
						end

						local ok2, result2 = pcall(tbl4.Steal.HeldByMe)

						if ok2 and not result2 then
							tbl4.Steal.Carrying = false
						else
							tbl4.SafeCarry.SlowUntil = os.clock() + 2
						end
					end
				end

				local n17 = 0

				while not tbl4.Steal.Carrying and n17 < n10 and not fn13(arg) do
					str2 = "Checking the egg in hand"
					n17 += RunService.Heartbeat:Wait()
				end

				if not tbl4.Steal.Carrying then
					str2 = "The egg is gone, staying to look for it"
					if not fn50(arg) then
						str2 = "The egg is gone"
						return false
					end
				end

				if tbl4.SafeCarry.LineDrop then
					return tbl4.SafeCarry.LineDropHome(arg)
				end

				if tbl4.SafeCarry.Enabled then
					return tbl4.SafeCarry.Home(arg)
				end
				local v19 = stealHome()
				local v20 = tbl4.Root()
				if not v19 or not v20 then
					return false
				end
				local n18 = math.max(v20.Position.Y, v19.Y) + n3

				local function fn55()
					if tbl20.Uid and tbl20.Freed and tbl4.Steal.Carrying then
						return "priority"
					end
					return nil
				end

				local flag3 = true
				local n19 = 0

				while true do
					local v21 = tbl4.Root()

					if not v21 then
						return false
					else
						str2 = "Flying home"
						local position = v21.Position
						local n20 = math.max(n18, position.Y)
						local v22, v23 = fn33(Vector3.new(position.X + (v19.X - position.X) * 0.25, position.Y + (n20 - position.Y) * 0.7, position.Z + (v19.Z - position.Z) * 0.25), arg, flag3, nil, nil, fn55)

						if v22 then
							v22, v23 = fn33(Vector3.new(v19.X, n20, v19.Z), arg, flag3, nil, nil, fn55)
						end

						if v22 then
							v22, v23 = fn33(v19, arg, flag3, nil, nil, fn55)
						end

						if v22 then
							local character = localPlayer.Character
							character = character and character:FindFirstChildOfClass("Humanoid")

							if character then
								character.PlatformStand = false
							end

							task.wait(0.2)
							if not tbl4.Steal.Carrying then
								str2 = "Arrived without the egg"
								return false
							end
							local eggState = tbl.EggState

							if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
								pcall(eggState.DropFieldEgg, "PlayerRequest")
							end

							return true
						end

						if v23 == "priority" then
							local uid2 = tbl20.Uid
							local freed = tbl20.Freed
							local v24 = tbl20
							tbl20.Uid = nil
							v24.Freed = nil
							local v25 = tbl4.Root()
							if not v25 or not uid2 or not freed then
								return false
							end

							if (freed - v25.Position).Magnitude <= n4 * n16 then
								str2 = "Best egg fell nearby, swapping eggs"
								local eggState = tbl.EggState

								if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
									pcall(eggState.DropFieldEgg, "PlayerRequest")
								end

								local n21 = 0

								while tbl4.Steal.Carrying and n21 < 1 do
									n21 += RunService.Heartbeat:Wait()
								end

								if not fn50(arg, uid2) then
									return false
								end
							else
								str2 = "Best egg fell far away, riding a guard hit to it"
								if not fn53(arg, uid2, freed) then
									return false
								end
							end

							local v26 = tbl4.Root()
							n19 = 0

							if v26 then
								n18 = math.max(v26.Position.Y, v19.Y) + n3
							end

							continue
						end

						if v23 == "dropped" and n19 < huge then
							n19 += 1
							if not fn50(arg) then
								return false
							end
							continue
						end

						break
					end
				end

				return false
			end

			local function fn55(arg)
				local n17 = tonumber(arg) or 0
				local tbl21 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local n18 = 1

				while math.abs(n17) >= 1000 and n18 < #tbl21 do
					n17 /= 1000
					n18 += 1
				end

				return string.format(n18 == 1 and "%.0f%s" or "%.2f%s", n17, tbl21[n18])
			end

			local function fn56(arg)
				if not arg then
					return "None"
				end
				local format = string.format
				local str3 = tostring(arg.Category)
				local n17 = tonumber(arg.Scale) or 0
				local v19 = tostring
				local areaId = arg.AreaId
				local v20 = format("%s  %.2fx  |  value %s  |  %s", str3, n17, fn55(arg.Value), v19(areaId))
				local str4

				if arg.State == "Dropped" then
					str4 = v20 .. "  |  dropped"
				elseif arg.State == "Carried" then
					str4 = v20 .. "  |  carried by a player"
				else
					str4 = v20
				end

				return str4
			end

			local flag3 = false
			local n17 = 0.5
			local n18 = 0.6
			local n19 = 0
			local n20 = 0

			local function fn57()
				local v19 = n5
				tbl4.Steal.Active = true
				tbl4.Steal.Carrying = tbl4.Steal.Carrying == true

				if not tbl4.Steal.Carrying then
					tbl4.Steal.CarryUid = nil
				end

				local v20 = fn19(false, true)
				local v21 = nil
				local v22 = nil
				local lastSkip = nil

				for _, v23 in ipairs(v20) do
					if v23.State == "Carried" then
						v22 = v22 or v23
					else
						local v24 = tbl4.SafeCarry.Unsafe(v23)

						if v24 then
							lastSkip = lastSkip or v24
						else
							v21 = v23
							break
						end
					end
				end

				local tbl21 = { v21 }
				uid = v21 and v21.Uid or nil
				tbl4.Steal.Wanted = v21 ~= nil
				str = fn56(v21)

				if v22 then
					str ..= "  |  watching " .. tostring(v22.Category)
				end

				if not v21 then
					tbl4.Steal.Active = false
					lastSkip = lastSkip or tbl4.SafeCarry.LastSkip
					tbl4.SafeCarry.LastSkip = nil
					str2 = v22 and "Best egg is carried, waiting for it" or lastSkip and "Skipped: " .. lastSkip or "No egg matches"
					return false
				end

				if not tbl4.ClaimMovement("steal") then
					tbl4.Steal.Active = false
					str2 = "Waiting for Auto Place"
					return false
				end

				if tbl4.Treadmill.Riding or tbl4.OnBelt() then
					tbl4.ExitBelt()
				end

				flag3 = true
				tbl4.HoldBelt()

				local function fn58(arg)
					str2 = arg
					local v23 = fn51(v21, v19)
					local flag4 = false
					local str3 = nil

					if v23 then
						if fn29(v21.Uid, v19) then
							flag4 = fn54(v19)
							str3 = nil
						else
							str3 = str2
						end
					end

					fn25()
					tbl4.Steal.Active = false
					tbl4.Steal.LastFinishedAt = os.clock()
					str3 = flag4 and "Delivered" or str3
					local str4

					if str3 then
						str4 = str3
					else
						str4 = v23 and "Run ended" or "That egg would not come free"
					end

					str2 = str4
					return true
				end

				local v23 = tbl4.Root()
				local position = typeof(v21.CFrame) == "CFrame" and v21.CFrame.Position or nil

				if v23 and position then
					local flag4 = (position - v23.Position).Magnitude <= n15
					local areaId = v21.AreaId
					local flag5 = localPlayer:GetAttribute("AreaId") == areaId
					if flag4 or flag5 then
						return (fn58("Target is right here, taking it"))
					end
				end

				if tbl4.SafeCarry.Enabled and tbl4.SafeCarry.Approach == "Run" then
					local v24 = tbl4.SafeCarry.RunTo(v21, v19)
					local flag4, v25

					if v24 then
						if fn29(v21.Uid, v19) then
							flag4 = fn54(v19)
							v25 = nil
						else
							v25 = str2
							flag4 = false
						end
					else
						tbl18[v21.Uid] = os.clock() + n6
						v25 = nil
						flag4 = false
					end

					fn25()
					tbl4.Steal.Active = false
					tbl4.Steal.LastFinishedAt = os.clock()
					str2 = flag4 and "Delivered" or v25 or v24 and "Run ended" or "That egg would not come free"
					return true
				end

				local v24 = fn19(true)
				local str3 = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
				local tbl22 = {}

				for _, v25 in ipairs(v24) do
					if fn34(v25) or type(v25.Uid) == "string" and string.sub(v25.Uid, 1, #str3) == str3 then
						table.insert(tbl22, v25)
					end
				end

				if #tbl22 ~= 0 then
					v24 = tbl22
				end

				local v25, v26 = fn32(v24)

				if not v25 then
					tbl4.Steal.Active = false
					str2 = "No egg matches"
					return false
				end

				if v25.Uid == v21.Uid then
					return (fn58("Target is the closest egg, taking it"))
				end
				local v27, v28 = fn35(v25)
				local v29

				if v28 and v23 then
					local v30, v31, v32 = ipairs(v24)
					local huge3 = math.huge
					v29 = v25

					for _, v33 in v30, v31, v32 do
						local position2 = typeof(v33.CFrame) == "CFrame" and v33.CFrame.Position or nil

						if v33.Uid ~= v21.Uid and v33.AreaId == v25.AreaId and position2 then
							local magnitude = (position2 - v23.Position).Magnitude

							if n12 < (position2 - v28).Magnitude then
								magnitude += n12
							end

							if magnitude < huge3 then
								huge3 = magnitude
								v29 = v33
							end
						end
					end
				else
					v29 = v25
				end

				str2 = string.format("Sleeping guard egg %d studs away", math.floor(v26 + 0.5))

				if not v29 then
					tbl4.Steal.Active = false
					str2 = "No egg matches"
					return false
				end

				local v30, v31 = fn45(v29, v19, false, tbl21[1])
				if not v30 then
					tbl4.Steal.Active = false
					return false
				end
				local uid2 = nil
				local uid3 = v21.Uid
				local n21 = 0

				while true do
					if v31 and not fn13(v19) then
						str2 = "Holding for the guard hit"

						if fn43(v19, v31, function(arg)
							if not uid2 and tbl20.Uid and tbl20.Freed then
								uid2 = tbl20.Uid
								arg.Destination = tbl20.Freed + Vector3.new(0, 3, 0)
								local v32 = tbl20
								tbl20.Uid = nil
								v32.Freed = nil
								str2 = "Best egg fell, jumping to it instead"
							end
						end) then
							n21 += 1

							if uid2 then
								uid3 = uid2
								fn50(v19, uid2)
								break
							else
								local v32 = tbl21[n21]
								local v33
								v33, v31 = fn45(v32, v19, true, tbl21[n21 + 1])

								if v33 then
									if v32 and type(v32.Uid) == "string" then
										uid3 = v32.Uid
									end

									continue
								end
							end
						end
					end

					break
				end

				if not fn29(uid3, v19) then
					local v32 = str2
					fn25()
					tbl4.Steal.Active = false
					tbl4.Steal.LastFinishedAt = os.clock()
					str2 = v32
					return true
				end

				local v32 = fn54(v19)
				fn25()
				tbl4.Steal.Active = false
				tbl4.Steal.LastFinishedAt = os.clock()
				str2 = v32 and "Delivered" or "Run ended"
				return true
			end

			local eggState = tbl.EggState

			if type(eggState) == "table" then
				for _, v19 in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "SnapshotRefreshed" }) do
					local v20 = eggState[v19]

					if type(v20) == "table" and type(v20.Connect) == "function" then
						local ok, result = pcall(v20.Connect, v20, function()
							tbl3.Wake()
						end)

						if ok and result then
							fn4(function()
								pcall(function()
									result:Disconnect()
								end)
							end)
						end
					end
				end
			end

			tbl3.Add(function()
				local flag4 = nil

				if v15 then
					flag4 = type(v15.Set) == "function"
				end

				if flag4 then
					pcall(v15.Set, nil, str2)
				end

				local flag5 = nil

				if v16 then
					flag5 = type(v16.Set) == "function"
				end

				if flag5 then
					pcall(v16.Set, nil, str)
				end

				if not tbl4.Toggle(v14, false) then
					return false
				end
				local v19, v20, v21 = fn14()

				if v19 then
					if v20 == "night" then
						fn16()
					end

					tbl4.Movement.StealFirst = true
					tbl4.Steal.Wanted = false

					if flag2 then
						n5 += 1
						tbl4.Steal.Active = false
						fn25()
						tbl4.StopWalking()
					end

					local n21 = math.max(0, math.ceil(v19 - v21))

					if v20 == "wall" then
						str2 = string.format("Field wall up, %ds", n21)
					else
						str2 = string.format("Night, going again in %ds", n21)
					end

					return false
				end

				if v17 and n8 == math.huge then
					n8 = os.clock() + n7
				end

				if flag2 then
					return true
				end

				if fn17() then
					str2 = "Night over, waiting for the field to reset"
					tbl3.Wake()
					return false
				end

				local stealFirst = tbl4.Movement.StealFirst
				local owner = tbl4.Movement.Owner
				local flag6 = tbl4.Movement.PlaceWanted and not stealFirst

				if not flag6 then
					flag6 = owner ~= nil and owner ~= "steal" and owner ~= "treadmill" and owner ~= "scramble"
				end

				if flag6 then
					if os.clock() >= n19 then
						n19 = os.clock() + n17
						local ok, result = pcall(fn19, false, false)
						ok = ok and type(result) == "table" and result[1] ~= nil
						tbl4.Steal.Wanted = ok

						if ok then
							tbl4.Movement.StealFirst = true
						end
					end

					if tbl4.Steal.Wanted then
						local v22 = tostring
						owner = owner or "Auto Place"
						str2 = "Egg found, waiting for " .. v22(owner) .. " to stop"
					else
						str2 = "Waiting for " .. tostring(owner or "Auto Place")
					end

					return true
				end

				if os.clock() < n20 then
					return true
				end
				tbl4.Movement.StealFirst = false
				flag2 = true

				task.spawn(function()
					local ok = pcall(fn57)

					if flag3 then
						flag3 = false
						tbl4.ReleaseBelt()
					end

					if not ok then
						fn25()
						tbl4.Steal.Active = false
					end

					local v22 = uid
					uid = nil
					local v23 = v22 and tbl14[v22]

					if v23 and v23.Once then
						tbl14[v22] = nil
					end

					local v24 = tbl20
					local v25 = tbl20
					tbl20.Uid = nil
					v24.Freed = nil
					v25.Token = nil

					if str2 == "Delivered" and not tbl4.IsNight() then
						tbl4.Movement.StealFirst = true
					end

					if not tbl4.Steal.Wanted then
						n20 = os.clock() + n18
					end

					tbl4.ReleaseMovement("steal")
					flag2 = false
					tbl3.Wake()
				end)

				return true
			end)
		end

		v14 = v5

		fn12 = function()
			n5 += 1
			table.clear(tbl18)
			tbl4.Steal.Active = false
			tbl4.Steal.Wanted = false
			local v19 = tbl4.Toggle(v14, false)
			tbl4.Shield("steal", v19)

			if not v19 then
				tbl4.Movement.StealFirst = false
				table.clear(tbl14)
				table.clear(tbl15)
				table.clear(tbl16)
			end

			fn25()
			tbl4.StopWalking()
			tbl3.Wake()
		end

		do
			local function fn36()
				n5 += 1
				tbl4.Steal.Active = false
				fn25()
				tbl4.StopWalking()
			end

			local function fn37()
				if tbl4.Toggle(v14, false) then
					return true
				end

				if v14 and type(v14.Set) == "function" then
					pcall(v14.Set, v14, true)
				end

				return false
			end

			tbl4.CancelSteal = function(arg)
				if type(arg) ~= "string" then
					return
				end
				tbl14[arg] = nil
				tbl15[arg] = nil
				tbl16[arg] = true

				if flag2 and uid == arg then
					fn36()
				end

				tbl3.Wake()
			end

			tbl4.StealQueue = function()
				local tbl19 = {}

				for k in pairs(tbl14) do
					table.insert(tbl19, k)
				end

				table.sort(tbl19, function(arg, arg2)
					local at = tbl14[arg].At
					local at2 = tbl14[arg2].At
					if at ~= at2 then
						return at < at2
					end
					return arg < arg2
				end)

				return tbl19
			end

			tbl4.PrioritizeSteal = function(arg)
				if type(arg) ~= "string" or fn15() then
					return
				end
				local n13 = 0

				for _, v19 in pairs(tbl14) do
					if v19.At < n13 then
						n13 = v19.At
					end
				end

				tbl14[arg] = { At = n13 - 1, Once = false }
				tbl16[arg] = nil
				tbl18[arg] = nil

				if fn37() and flag2 and not tbl4.Steal.Carrying and uid ~= arg then
					fn36()
				end

				tbl3.Wake()
			end

			tbl4.MoveInPlan = function(arg, arg2)
				if type(arg) ~= "string" or arg2 ~= -1 and arg2 ~= 1 or fn15() then
					return
				end
				local v19 = tbl4.StealPlan()
				local v20 = table.find(v19, arg)
				local n13 = v20 and v20 + arg2
				if not n13 or n13 < 1 or n13 > #v19 then
					return
				end
				table.remove(v19, v20)
				table.insert(v19, n13, arg)
				local n14 = math.max(v20, n13)

				for i, v21 in ipairs(v19) do
					if i <= n14 or tbl14[v21] then
						local v22 = tbl14[v21]

						if v22 then
							v22.At = i
						else
							tbl14[v21] = { At = i, Once = false }
						end

						tbl16[v21] = nil
					end
				end

				if flag2 and not tbl4.Steal.Carrying and uid and v19[1] ~= uid then
					fn36()
				end

				tbl3.Wake()
			end

			tbl4.StealPlan = function()
				if not tbl4.Toggle(v14, false) or tbl4.IsNight() then
					return {}, nil
				end
				local tbl19 = {}

				if uid then
					table.insert(tbl19, uid)
				end

				local ok, result = pcall(fn19, false, true)

				if ok and type(result) == "table" then
					for _, v19 in ipairs(result) do
						if v19.Uid ~= uid then
							table.insert(tbl19, v19.Uid)
						end
					end
				end

				return tbl19, uid
			end

			tbl4.SetPriority = function(arg, arg2)
				if arg2 then
					tbl4.PrioritizeSteal(arg)
				else
					tbl4.CancelSteal(arg)
				end
			end

			tbl4.ResortSteal = function()
				if flag2 and not tbl4.Steal.Carrying and uid and not tbl14[uid] then
					local ok, result = pcall(fn19, false, true)

					if ok and type(result) == "table" then
						local v19 = nil

						for _, v20 in ipairs(result) do
							if v20.State ~= "Carried" then
								v19 = v20
								break
							else
								v19 = nil
							end
						end

						if not v19 or v19.Uid ~= uid then
							fn36()
						end
					end
				end

				tbl3.Wake()
			end

			tbl4.StealNow = function(arg, arg2)
				if type(arg) ~= "string" or fn15() then
					return
				end

				if not tbl14[arg] then
					local n13 = 0

					for _, v19 in pairs(tbl14) do
						if n13 < v19.At then
							n13 = v19.At
						end
					end

					tbl14[arg] = { At = n13 + 1, Once = arg2 == true }
				end

				tbl16[arg] = nil
				tbl18[arg] = nil
				local flag3 = fn37() and flag2 and not tbl4.Steal.Carrying and uid ~= arg

				if flag3 then
					flag3 = not (uid and tbl14[uid])
				end

				if flag3 then
					fn36()
				end

				tbl3.Wake()
			end
		end

		fn4(function()
			tbl4.GodMode(false)
			tbl4.ReleaseMovement("steal")
			fn25()
		end)

		tbl4.UiQueue = {}

		tbl4.UiDefer = function(arg)
			table.insert(tbl4.UiQueue, arg)
		end

		tbl4.Notify = function(arg, arg2)
			if type(v) == "table" and type(v.Notify) == "function" then
				pcall(v.Notify, arg, arg2, 5)
			end
		end

		local connection = RunService.Heartbeat:Connect(function()
			local uiQueue = tbl4.UiQueue
			if #uiQueue == 0 then
				return
			end
			tbl4.UiQueue = {}

			for _, v19 in ipairs(uiQueue) do
				pcall(v19)
			end
		end)

		fn4(function()
			pcall(function()
				connection:Disconnect()
			end)
		end)

		tbl4.Rift = { Requirements = {}, At = 0, Busy = false, Next = 0, Handles = {}, Restart = {} }

		tbl4.RiftOn = function(arg)
			local v19 = tbl4.Rift.Handles[arg]
			return v19 ~= nil and tbl4.Toggle(v19, false) == true
		end

		do
			local n13 = 8

			local function fn36(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				local flag3 = type(directory) == "table" and directory[tostring(arg)] or nil
				return type(flag3) == "table" and flag3 or nil
			end

			tbl4.EggRarity = function(arg)
				local rarity = fn36(arg.AssetCategory)
				rarity = rarity and rarity.Rarity or nil
				local flag3 = type(rarity) == "table"

				if flag3 then
					flag3 = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				return flag3 or 0
			end

			tbl4.EggIncome = function(arg)
				local n14 = fn36(arg.AssetCategory)
				n14 = n14 and tonumber(n14.EarningRate) or 0
				local n15 = tonumber(arg.AssetScale) or 0
				if n15 <= 0 then
					return 0
				end
				local n16 = n15 > 5 and (n15 / 5) ^ 1.2 * 19.637875755794113 or n15 ^ 1.85
				local mutations = tbl.Mutations
				local flag3 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n17 = 1

				if flag3 then
					local ok
					ok, n17 = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
					local flag4 = ok and type(n17) == "number"
					local n18 = 1

					if not flag4 then
						n17 = n18
					end
				end

				return n14 * n16 * n17
			end

			tbl4.RiftShortfall = function()
				local tbl19 = {}

				for _, requirement in ipairs(tbl4.Rift.Requirements) do
					tbl19[requirement] = (tbl19[requirement] or 0) + 1
				end

				if next(tbl19) == nil then
					return tbl19
				end
				local save2 = tbl.Save
				local flag3 = type(save2) == "table" and type(save2.Get) == "function"
				local result = nil

				if flag3 then
					local ok
					ok, result = pcall(save2.Get)
					result = ok and type(result) == "table" and result or nil
				end

				if not result then
					return {}
				end
				local tbl20 = {}
				local v19 = pairs
				local equippedAssets = result.EquippedAssets or {}

				for _, equippedAsset in v19(equippedAssets) do
					tbl20[equippedAsset] = true
				end

				local v20 = pairs
				local inventory = result.Inventory or {}

				for k, v21 in v20(inventory) do
					local str3 = type(v21) == "table" and tostring(v21.Category) or nil
					local flag4

					if str3 then
						flag4 = (tbl19[str3] or 0) > 0
					else
						flag4 = str3
					end

					flag4 = flag4 and v21.InFuse ~= true and v21.IsFavorite ~= true and not tbl20[k]

					if flag4 then
						tbl19[str3] = tbl19[str3] - 1
					end
				end

				for k, v21 in pairs(tbl19) do
					if v21 <= 0 then
						tbl19[k] = nil
					end
				end

				return tbl19
			end

			local function fn37()
				for k in pairs(tbl4.Rift.Handles) do
					if tbl4.RiftOn(k) then
						return true
					end
				end

				return false
			end

			tbl3.Add(function()
				local rift = tbl4.Rift
				local busy = rift.Busy

				if not busy then
					local next_ = rift.Next
					busy = os.clock() < next_
				end

				if busy or not fn37() then
					return false
				end
				rift.Busy = true
				rift.Next = os.clock() + n13

				task.spawn(function()
					local rfScrambleTradeInAskState = networking:FindFirstChild("RF/ScrambleTradeIn/AskState")

					if rfScrambleTradeInAskState and rfScrambleTradeInAskState:IsA("RemoteFunction") then
						local ok, result = pcall(rfScrambleTradeInAskState.InvokeServer, rfScrambleTradeInAskState)

						if ok and type(result) == "table" then
							local requirements = {}

							if result.Unlocked == true and type(result.Requirements) == "table" then
								for _, requirement in ipairs(result.Requirements) do
									table.insert(requirements, tostring(requirement))
								end
							end

							rift.Requirements = requirements
							rift.At = os.clock()
						end
					end

					rift.Busy = false
					tbl3.Wake()
				end)

				return false
			end)
		end

		local tbl19
		tbl19 = { "Always", "Steal Idle", "After Steal", "Night Only" }
		local tbl20
		tbl20 = { "Biggest Size", "Highest Value", "Smallest Size", "Backpack Order" }
		local v19
		v19 = tbl19[1]
		local v20
		v20 = tbl20[2]
		local tbl21
		tbl21 = {}
		local tbl22
		tbl22 = {}
		local n13
		n13 = 0

		do
			local function fn36()
				if type(tbl4.PlaceEggRefresh) == "function" then
					tbl4.PlaceEggRefresh()
				end
			end

			local function fn37(arg)
				local tbl23 = {}

				if type(arg) == "table" then
					for k, v21 in pairs(arg) do
						k = v21 == true and type(k) == "string" and k or type(v21) == "string" and v21 or nil

						if k then
							table.insert(tbl23, k)
						end
					end
				end

				return tbl23
			end

			tbl4.PlaceEggStatusRow = v9:CreateText({ Name = "Pen Status", Text = "Pen status unknown" })

			tbl4.PlaceEggHandle = v9:CreateToggle({
				Name = "Auto Place Egg",
				Default = false,
				Callback = function()
					if type(tbl4.PlaceEggRestart) == "function" then
						tbl4.PlaceEggRestart()
					end
				end,
			})

			local placeEggHandle = tbl4.PlaceEggHandle

			v9:CreateDropdown({
				Name = "Place Egg Rule",
				Options = tbl19,
				Default = tbl19[1],
				SubOf = placeEggHandle,
				Callback = function(arg)
					if table.find(tbl19, arg) then
						v19 = arg
					end
				end,
			})

			v9:CreateDropdown({
				Name = "Place Egg Order",
				Options = tbl20,
				Default = tbl20[2],
				SubOf = placeEggHandle,
				Callback = function(arg)
					if table.find(tbl20, arg) then
						v20 = arg
					end
				end,
			})

			local tbl23 = {}

			for i = 2, #tbl8 do
				table.insert(tbl23, tbl8[i])
			end

			if #tbl23 > 0 then
				fn6(v9:CreateMultiDropdown({
					Name = "Place Rarities",
					Note = "Only place eggs of the picked rarities (empty = all)",
					Options = tbl23,
					Default = {},
					SubOf = placeEggHandle,
					Callback = function(arg)
						local tbl24 = {}

						for _, v21 in ipairs(fn37(arg)) do
							local v22 = tbl9[v21]

							if v22 and v22 > 0 then
								tbl24[v22] = true
							end
						end

						tbl21 = tbl24
						fn36()
					end,
				}))
			end

			local tbl24 = {}
			local tbl25 = {}
			local directory = tbl.Assets and tbl.Assets.Directory
			local tbl26 = {}

			if type(directory) == "table" then
				for k, v21 in pairs(directory) do
					local rarity = type(v21) == "table" and v21.Rarity or nil
					local rarity2 = type(rarity) == "table"

					if rarity2 then
						rarity2 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					rarity2 = rarity2 or nil

					if rarity2 then
						local insert = table.insert
						local tbl27 = { Category = tostring(k) }
						local v22 = tostring
						k = v21.DisplayName or k
						tbl27.Name = v22(k)
						tbl27.Rarity = rarity2
						tbl27.RarityName = tostring(rarity.DisplayName or rarity._id or rarity2)
						insert(tbl26, tbl27)
					end
				end
			end

			table.sort(tbl26, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity > arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v21 in ipairs(tbl26) do
				local str3 = string.format("%s [%s]", v21.Name, v21.RarityName)

				if tbl25[str3] then
					str3 = string.format("%s [%s] (%s)", v21.Name, v21.RarityName, v21.Category)
				end

				table.insert(tbl24, str3)
				tbl25[str3] = v21.Category
			end

			if #tbl24 > 0 then
				fn6(v9:CreateMultiDropdown({
					Name = "Place Specific Eggs",
					Note = "Only place these eggs (empty = all)",
					Options = tbl24,
					Default = {},
					SubOf = placeEggHandle,
					Callback = function(arg)
						local tbl27 = {}

						for _, v21 in ipairs(fn37(arg)) do
							if tbl25[v21] then
								tbl27[tbl25[v21]] = true
							end
						end

						tbl22 = tbl27
						fn36()
					end,
				}))
			end

			local tbl27 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local n14 = 0
			local str3 = "M/s"

			local function fn38(arg, arg2)
				if arg ~= nil then
					n14 = math.max(0, math.floor(tonumber(arg) or n14))
				end

				if arg2 ~= nil then
					str3 = tostring(arg2)
				end

				n13 = n14 * (tbl27[str3] or tbl27["M/s"]).Mult
			end

			fn5(v9, {
				Name = "Min Place Value",
				Note = "Skip eggs worth less than this (0 = off)",
				SubOf = placeEggHandle,
				Legacy = "Place Min Value",
				SectionName = "Auto Place Egg",
				OnRaw = function(arg)
					fn38(math.floor(arg / 1000), "K/s")
				end,
			})
		end

		do
			local n14 = 5
			local n15 = 26
			local n16 = 6
			local n17 = 8
			local n18 = 0
			local n19 = 30
			local n20 = 12
			local placeEggHandle = nil
			local placeEggStatusRow = nil
			local str3 = "Pen status unknown"
			local flag3 = false
			local tbl23 = {}
			local n21 = 0
			local v21 = nil
			local n22 = 30

			local function fn36(arg, arg2)
				local v22 = networking:FindFirstChild(arg)
				if not v22 or not v22:IsA("RemoteFunction") then
					return false, nil
				end
				return pcall(v22.InvokeServer, v22, arg2)
			end

			local function fn37(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				local flag4 = type(directory) == "table" and directory[tostring(arg.AssetCategory)] or nil
				return type(flag4) == "table" and flag4 or nil
			end

			local function fn38(arg)
				local rarity = fn37(arg)
				rarity = rarity and rarity.Rarity or nil
				local flag4 = type(rarity) == "table"
				local num

				if flag4 then
					num = tonumber(rarity.RarityNumber or rarity.Rank)
				else
					num = flag4
				end

				return num or 0
			end

			local function fn39(arg)
				local n23 = fn37(arg)
				n23 = n23 and tonumber(n23.EarningRate) or 0
				local n24 = tonumber(arg.AssetScale) or 0
				if n24 <= 0 then
					return 0
				end
				local n25 = n24 > 5 and (n24 / 5) ^ 1.2 * 19.637875755794113 or n24 ^ 1.85
				local mutations = tbl.Mutations
				local flag4 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n26 = 1

				if flag4 then
					local ok
					ok, n26 = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
					ok = ok and type(n26) == "number"
					local n27 = 1

					if not ok then
						n26 = n27
					end
				end

				return n23 * n25 * n26
			end

			local function fn40()
				local tbl24 = {}
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")
				if not backpack then
					return tbl24
				end
				local n23 = 0

				for _, child in ipairs(backpack:GetChildren()) do
					local attribute = child:GetAttribute("UID")

					if type(attribute) == "string" then
						n23 += 1
						tbl24[attribute] = n23
					end
				end

				return tbl24
			end

			local function fn41()
				local eggState = tbl.EggState
				if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return {}
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return {}
				end
				local v22 = fn40()
				local tbl24 = {}

				if tbl4.RiftOn("Place") then
					tbl24 = tbl4.RiftShortfall()

					for _, v23 in pairs(result) do
						if type(v23) == "table" and v23.Placement ~= nil then
							local str4 = tostring(v23.AssetCategory)

							if (tbl24[str4] or 0) > 0 then
								tbl24[str4] = tbl24[str4] - 1
							end
						end
					end
				end

				local tbl25 = {}

				for k, v23 in pairs(result) do
					if type(v23) == "table" and v23.Placement == nil and not tbl23[k] then
						local v24 = fn39(v23)
						local str4 = tostring(v23.AssetCategory)
						local flag4 = next(tbl21) == nil or tbl21[fn38(v23)] == true
						local flag5 = next(tbl22) == nil or tbl22[str4] == true
						local flag6 = n13 <= 0 or v24 >= n13
						local flag7 = (tbl24[str4] or 0) > 0

						if flag7 then
							tbl24[str4] = tbl24[str4] - 1
						end

						if flag7 then
							flag6 = flag7
						else
							flag6 = flag4 and flag5 and flag6
						end

						if flag6 then
							table.insert(tbl25, {
								Uid = k,
								Scale = tonumber(v23.AssetScale) or 0,
								Income = v24,
								Slot = v22[k] or math.huge,
								Rift = flag7,
							})
						end
					end
				end

				table.sort(tbl25, function(arg, arg2)
					if arg.Rift ~= arg2.Rift then
						return arg.Rift
					end

					if v20 == tbl20[2] and arg.Income ~= arg2.Income then
						return arg.Income > arg2.Income
					end

					if v20 == tbl20[3] and arg.Scale ~= arg2.Scale then
						return arg.Scale < arg2.Scale
					end

					if v20 == tbl20[4] and arg.Slot ~= arg2.Slot then
						return arg.Slot < arg2.Slot
					end
					return arg.Scale > arg2.Scale
				end)

				return tbl25
			end

			local function fn42(arg)
				if arg == 0 then
					return false
				end
				local steal = tbl4.Steal
				if v19 == tbl19[2] then
					return not steal.Active and not steal.Carrying
				end

				if v19 == tbl19[3] then
					local flag4 = steal.LastFinishedAt > 0

					if flag4 then
						local lastFinishedAt = steal.LastFinishedAt
						flag4 = os.clock() - lastFinishedAt <= n20
					end

					return flag4
				end

				if v19 == tbl19[4] then
					return tbl4.IsNight()
				end
				return true
			end

			local function fn43()
				local eggState = tbl.EggState
				local flag4 = type(eggState) == "table" and type(eggState.ReadOwnerEggs) == "function"
				local n23 = 0

				if flag4 then
					local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)

					if ok and type(result) == "table" then
						for _, v22 in pairs(result) do
							if type(v22) == "table" and v22.Placement ~= nil then
								n23 += 1
							end
						end
					end
				end

				local save2 = tbl.Save
				local flag5 = type(save2) == "table" and type(save2.Get) == "function"
				local result = nil

				if flag5 then
					local ok
					ok, result = pcall(save2.Get)
					result = ok and type(result) == "table" and result or nil
				end

				local flag6 = result and type(result.EquippedAssets) == "table"
				local n24 = 0

				if flag6 then
					for k in pairs(result.EquippedAssets) do
						n24 += 1
					end
				end

				local v22 = fn2(function()
					return ReplicatedStorage.Data.Bases
				end)

				local flag7 = type(v22) == "table" and type(v22.GetAssetEquipCapacity) == "function"
				local ok = nil

				if flag7 then
					local result2
					ok, result2 = pcall(v22.GetAssetEquipCapacity, result and tonumber(result.BaseUpgradeLevel) or 0)
					ok = ok and tonumber(result2) or nil
				end

				if not ok then
					local rfPenRosterAskWearLimit = networking:FindFirstChild("RF/PenRoster/AskWearLimit")

					if rfPenRosterAskWearLimit and rfPenRosterAskWearLimit:IsA("RemoteFunction") then
						local result2
						ok, result2 = pcall(rfPenRosterAskWearLimit.InvokeServer, rfPenRosterAskWearLimit)
						ok = ok and tonumber(result2) or nil
					end
				end

				ok = ok or 0
				return ok - n23 - n24, ok, n23, n24
			end

			local n23 = -0.5
			local n24 = -24

			local function fn44()
				local eggState = tbl.EggState
				local tbl24 = {}
				if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return tbl24
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return tbl24
				end

				for _, v22 in pairs(result) do
					local placement = type(v22) == "table" and v22.Placement or nil
					local localCFrame = type(placement) == "table" and placement.LocalCFrame or nil

					if typeof(localCFrame) == "CFrame" then
						table.insert(tbl24, Vector2.new(localCFrame.Position.X, localCFrame.Position.Z))
					end
				end

				return tbl24
			end

			local v22 = Random.new()

			local function fn45(arg)
				local tbl24 = {}

				for i = n24, 8, 4 do
					for i2 = 4, 30, 4 do
						local vector2 = Vector2.new(i, i2)
						local flag4 = true

						for _, v23 in ipairs(arg) do
							if (v23 - vector2).Magnitude < n14 then
								flag4 = false
								break
							end
						end

						if flag4 then
							table.insert(tbl24, CFrame.new(i, n23, i2))
						end
					end
				end

				for i = #tbl24, 2, -1 do
					local v23 = v22:NextInteger(1, i)
					local v24 = tbl24[i]
					tbl24[i] = tbl24[v23]
					tbl24[v23] = v24
				end

				return tbl24
			end

			local function fn46()
				local v23, v24, v25, v26 = fn43()
				local eggState = tbl.EggState
				local flag4 = type(eggState) == "table" and type(eggState.ReadOwnerEggs) == "function"
				local n25 = 0

				if flag4 then
					local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)

					if ok and type(result) == "table" then
						for _, v27 in pairs(result) do
							if type(v27) == "table" and v27.Placement == nil then
								n25 += 1
							end
						end
					end
				end

				str3 = string.format("Eggs placed %d/%d  -  %d/%d pets equipped, %d in bag", v25, 30, v26, v24, n25)
				return v23, v25
			end

			local function fn47(arg, arg2)
				local v23 = tbl4.Root()
				if not v23 then
					return false
				end
				local position = v23.Position
				local n25 = (arg - position).Magnitude / math.max(400, 1) + 3
				local flag4 = nil
				local n26 = 0

				local connection2 = RunService.Heartbeat:Connect(function(deltaTime)
					if flag4 ~= nil or tbl4.AntiGuard.Busy then
						return
					end
					n26 += deltaTime
					local v24 = tbl4.Root()
					if not v24 or arg2() or n26 > n25 then
						flag4 = false
						return
					end

					if (v24.Position - position).Magnitude > 6 then
						position = v24.Position
					end

					local n27 = arg - position
					local n28 = n4 * deltaTime
					local flag5 = n27.Magnitude <= math.max(n28, 0.05)
					position = flag5 and arg or position + n27.Unit * n28
					local vector = Vector3.new(n27.X, 0, n27.Z)
					local cframe = vector.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector.Unit) or v24.CFrame.Rotation

					pcall(function()
						v24.CFrame = CFrame.new(position) * cframe
						v24.AssemblyLinearVelocity = Vector3.zero
						v24.AssemblyAngularVelocity = Vector3.zero
					end)

					if flag5 then
						flag4 = true
					end
				end)

				while flag4 == nil do
					RunService.Heartbeat:Wait()
				end

				connection2:Disconnect()
				return flag4
			end

			local function fn48()
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("SeparationLine")
				return world and world:IsA("BasePart") and world.Position.X or 552
			end

			local fn49 = nil

			local function fn50(arg)
				local v23 = tbl4.Root()
				if not v23 or type(tbl4.StealHome) ~= "function" then
					return nil
				end
				local v24 = fn48()
				if v23.Position.X < v24 == arg.X < v24 then
					return nil
				end
				local ok, result = pcall(tbl4.StealHome)
				if not ok or typeof(result) ~= "Vector3" then
					return nil
				end

				if (result - arg).Magnitude <= 12 or (v23.Position - result).Magnitude <= 12 then
					return nil
				end
				return result
			end

			fn49 = function(arg, arg2, arg3, arg4)
				local v23 = tbl4.Root()
				if not v23 then
					return false
				end

				if not arg4 then
					local v24 = fn50(arg)
					if v24 and not fn49(v24, arg2, arg3, true) then
						return false
					end

					if arg2 and arg2() then
						return false
					end
					v23 = tbl4.Root()
					if not v23 then
						return false
					end
				end

				tbl4.Shield(arg3 or "place", true)
				tbl4.Driving = tbl4.Driving + 1
				task.wait(0.2)
				local n25 = arg + Vector3.new(0, 3, 0)
				local n26 = math.max(v23.Position.Y, n25.Y) + n22

				local ok, result = pcall(function()
					return fn47(Vector3.new(v23.Position.X, n26, v23.Position.Z), arg2) and fn47(Vector3.new(n25.X, n26, n25.Z), arg2) and fn47(n25, arg2)
				end)

				ok = ok and result == true
				tbl4.Driving = math.max(0, tbl4.Driving - 1)
				tbl4.Shield(arg3 or "place", false)
				return ok
			end

			tbl4.FlyTo = function(arg, arg2, arg3)
				return fn49(arg, arg2, arg3 or "fly")
			end

			local function fn51()
				local eggState = tbl.EggState
				if type(eggState) ~= "table" or type(eggState.PlantEgg) ~= "function" then
					return false
				end
				local v23 = fn41()
				if not fn42(#v23) then
					return false
				end
				fn46()
				local v24, v25, v26 = fn43()
				local n25 = n19 - (tonumber(v26) or 0)
				if n25 <= 0 then
					return false
				end
				local v27 = tbl4.PenAnchor()
				if not v27 then
					return false
				end
				tbl4.Movement.PlaceWanted = true
				if not tbl4.ClaimMovement("place") then
					return "waiting"
				end
				local v28 = n21

				local function fn52()
					if v28 ~= n21 or not tbl4.Toggle(placeEggHandle, false) then
						return true
					end

					if tbl4.IsNight() then
						return false
					end
					return v19 == tbl19[4] or tbl4.Movement.StealFirst
				end

				if tbl4.Treadmill.Riding or tbl4.OnBelt() then
					tbl4.ExitBelt()
				end

				local function fn53()
					tbl4.HoldBelt()
					local ok, result = pcall(fn49, v27, fn52)
					tbl4.ReleaseBelt()
					return ok and result and true or false
				end

				if n15 < tbl4.DistanceTo(v27) then
					str3 = "Flying to the pen"

					if not fn53() then
						tbl4.LeaveBelt()
						n18 = os.clock() + n16
						return false
					end
				end

				tbl4.LeaveBelt()
				if fn52() then
					return false
				end

				local function fn54()
					if tbl4.DistanceTo(v27) <= n15 then
						return true
					end

					if fn52() then
						return false
					end
					str3 = "Pen out of reach, flying back"
					return fn53() and tbl4.DistanceTo(v27) <= n15
				end

				if not fn54() then
					str3 = "Could not reach the pen, trying again soon"
					n18 = os.clock() + n16
					return false
				end

				local v29 = fn44()
				local n26 = 0
				local n27 = 0

				for _, v30 in ipairs(v23) do
					if not (n26 >= n25 or fn52()) then
						if not fn54() then
							str3 = "Pen out of reach, stopping this pass"
							break
						else
							local ok, result = pcall(eggState.WearEggTool, v30.Uid)

							if ok and result ~= false then
								task.wait(0.15)
								local n28 = 0
								local flag4 = false

								for _, v31 in ipairs(fn45(v29)) do
									if not (fn52() or n28 >= n17) then
										n28 += 1
										local AskPlaceEgg, v32 = fn36("RF/EggWorld/AskPlaceEgg", { Uid = v30.Uid, LocalCFrame = v31 })

										if AskPlaceEgg and v32 ~= false then
											table.insert(v29, Vector2.new(v31.Position.X, v31.Position.Z))
											n26 += 1
											flag4 = true
											break
										else
											continue
										end
									end

									break
								end

								if flag4 then
									n27 = 0
									continue
								else
									tbl23[v30.Uid] = true
									n27 += 1
									if not (n27 >= 2) then
										continue
									end
								end
							else
								tbl23[v30.Uid] = true
								continue
							end
						end
					end

					break
				end

				if type(eggState.DoffEggTool) == "function" then
					pcall(eggState.DoffEggTool)
				end

				if n26 == 0 then
					n18 = os.clock() + n16
				end

				return n26 > 0
			end

			tbl3.Add(function()
				local v23, v24 = fn46()

				if placeEggStatusRow and type(placeEggStatusRow.Set) == "function" then
					pcall(placeEggStatusRow.Set, placeEggStatusRow, str3)
				end

				local num = tonumber(v24)
				local flag4 = num ~= nil and v21 ~= nil and num < v21

				if num then
					v21 = num
				end

				if flag4 then
					table.clear(tbl23)
				end

				if not tbl4.Toggle(placeEggHandle, false) then
					tbl4.Movement.PlaceWanted = false
					tbl4.ReleaseMovement("place")
					return false
				end

				if flag3 then
					return false
				end

				if os.clock() < n18 then
					tbl4.Movement.PlaceWanted = false
					return false
				end

				if tbl4.Movement.StealFirst and not tbl4.IsNight() then
					tbl4.Movement.PlaceWanted = false
					return false
				end
				flag3 = true

				task.spawn(function()
					local ok, result = pcall(fn51)

					if not (ok and result == "waiting") then
						tbl4.Movement.PlaceWanted = false
					end

					tbl4.ReleaseMovement("place")
					flag3 = false
					tbl3.Wake()
				end)

				return false
			end)

			placeEggHandle = tbl4.PlaceEggHandle
			placeEggStatusRow = tbl4.PlaceEggStatusRow

			tbl4.PlaceEggRestart = function()
				table.clear(tbl23)
				n21 += 1
				tbl4.StopWalking()
				tbl3.Wake()
			end

			tbl4.PlaceEggRefresh = function()
				table.clear(tbl23)
				tbl3.Wake()
			end

			tbl4.Rift.Restart.Place = function()
				table.clear(tbl23)
				tbl3.Wake()
			end
		end

		local save2 = tbl.Save

		if type(save2) == "table" and type(save2.FieldSignal) == "function" then
			for _, v21 in ipairs({ "EggInventory", "EquippedAssets", "BaseUpgradeLevel" }) do
				local ok, result = pcall(save2.FieldSignal, v21)

				if ok and type(result) == "table" and type(result.Connect) == "function" then
					local ok2, result2 = pcall(result.Connect, result, function()
						tbl3.Wake()
					end)

					if ok2 and result2 then
						fn4(function()
							pcall(function()
								result2:Disconnect()
							end)
						end)
					end
				end
			end
		end

		tbl4.Steal.HeldByMe = function()
			local carryUid = tbl4.Steal.CarryUid
			local character = localPlayer.Character
			if type(carryUid) ~= "string" or not character then
				return false
			end
			local v21 = workspace:FindFirstChild(carryUid)
			if not v21 then
				return false
			end

			for _, descendant in ipairs(v21:GetDescendants()) do
				if descendant:IsA("WeldConstraint") or descendant:IsA("JointInstance") then
					local ok, result, result2 = pcall(function()
						return descendant.Part0, descendant.Part1
					end)

					if ok and (result and result:IsDescendantOf(character) or result2 and result2:IsDescendantOf(character)) then
						return true
					end
				end
			end

			return false
		end

		do
			local n14 = 0

			local connection2 = RunService.Heartbeat:Connect(function(deltaTime)
				n14 += deltaTime
				if n14 < 0.2 then
					return
				end
				n14 = 0
				local steal = tbl4.Steal

				if not steal.Carrying then
					if steal.GuessedDrop then
						local ok, result = pcall(steal.HeldByMe)

						if ok and result then
							steal.GuessedDrop = false
							steal.Carrying = true
							steal.HeldSeenAt = os.clock()
						end
					end

					return
				end

				local ok, result = pcall(steal.HeldByMe)
				if not ok or result then
					steal.HeldSeenAt = os.clock()
					return
				end

				if os.clock() - (steal.HeldSeenAt or 0) > 0.8 then
					steal.Carrying = false
					steal.GuessedDrop = true
					steal.LastFinishedAt = os.clock()
					tbl3.Wake()
				end
			end)

			fn4(function()
				pcall(function()
					connection2:Disconnect()
				end)
			end)
		end

		do
			local eggState = tbl.EggState
			local carryChanged = type(eggState) == "table" and eggState.CarryChanged or nil

			if type(carryChanged) == "table" and type(carryChanged.Connect) == "function" then
				local ok, result = pcall(carryChanged.Connect, carryChanged, function(arg)
					local carrying = type(arg) == "table" and arg.IsCarrying == true

					if tbl4.Steal.Carrying and not carrying then
						tbl4.Steal.LastFinishedAt = os.clock()
					end

					tbl4.Steal.GuessedDrop = false

					if carrying then
						tbl4.Steal.HeldSeenAt = os.clock()
					end

					if carrying and type(arg.Uid) == "string" then
						tbl4.Steal.CarryUid = arg.Uid
						tbl4.Steal.CarryAreaId = arg.AreaId
						local mult = tonumber(arg.SpeedMultiplier)

						if mult and mult > 0 then
							tbl4.SafeCarry.Mult = mult
							tbl4.SafeCarry.Category = arg.AssetCategory

							if arg.AssetCategory ~= nil then
								local str3 = tostring(arg.AssetCategory)
								tbl4.SafeCarry.Seen[str3] = math.min(tbl4.SafeCarry.Seen[str3] or mult, mult)
							end
						end
					end

					tbl4.Steal.Carrying = carrying
					tbl3.Wake()
				end)

				if ok and result then
					fn4(function()
						pcall(function()
							result:Disconnect()
						end)
					end)
				end
			end
		end

		pcall(function()
			local reEggWorldFieldEggRedeemVerdict = networking:FindFirstChild("RE/EggWorld/FieldEggRedeemVerdict")
			local reAlertsRaise = networking:FindFirstChild("RE/Alerts/Raise")

			if reEggWorldFieldEggRedeemVerdict and reEggWorldFieldEggRedeemVerdict:IsA("RemoteEvent") then
				local connection2 = reEggWorldFieldEggRedeemVerdict.OnClientEvent:Connect(function()
					tbl4.SafeCarry.LastDelivered = os.clock()
				end)

				fn4(function()
					connection2:Disconnect()
				end)
			end

			if reAlertsRaise and reAlertsRaise:IsA("RemoteEvent") then
				local connection2 = reAlertsRaise.OnClientEvent:Connect(function(arg)
					if type(arg) == "table" and type(arg.Text) == "string" and string.find(arg.Text, "Delivery failed", 1, true) then
						tbl4.SafeCarry.LastFailed = os.clock()
					end
				end)

				fn4(function()
					connection2:Disconnect()
				end)
			end
		end)

		do
			local n14 = 10
			local n15 = 1
			local n16 = 5

			local function fn36(arg)
				local v21 = networking:FindFirstChild(arg)
				if not v21 or not v21:IsA("RemoteFunction") then
					return false, nil, nil
				end
				local ok, result, result2 = pcall(v21.InvokeServer, v21)
				return ok, result, result2
			end

			local n17 = 0
			local flag3 = false

			local function fn37(arg, arg2, arg3)
				if arg and arg2 ~= false then
					n17 = 0
					flag3 = false
					return true
				end

				if arg and tostring(arg3) == "Already using treadmill" then
					n17 = 0
					flag3 = false
					return true
				end

				if arg and tostring(arg3) == "Not grounded" and tbl4.Grounded() then
					n17 += 1

					if n17 >= 2 then
						n17 = 0

						if not flag3 then
							flag3 = true
							pcall(tbl4.UndoSwap)
						elseif type(tbl4.RequestRespawn) == "function" then
							flag3 = false
							tbl4.RequestRespawn()
						end
					end
				end

				return false
			end

			local v21 = nil
			local v22 = nil
			local flag4 = false
			local n18 = 0
			local flag5 = false
			local treadmill = tbl4.Treadmill

			local function fn38()
				return tbl4.Toggle(v21, false)
			end

			local function fn39()
				local movement = tbl4.Movement
				return movement.PlaceWanted or movement.ScrambleWanted or movement.MutationWanted or movement.FracturedWanted or movement.Owner ~= nil and movement.Owner ~= "treadmill" or tbl4.Steal.Active or tbl4.Steal.Carrying
			end

			local function fn40()
				local v23 = n18
				if fn39() or not tbl4.ClaimMovement("treadmill") then
					return false
				end

				local function fn41()
					return v23 ~= n18 or not fn38() or tbl4.Movement.Owner ~= "treadmill" or fn39()
				end

				if tbl4.BeltHeld() then
					tbl4.ResetBelt()
				end

				local v24 = tbl4.Belt()
				if not v24 then
					return false
				end
				local n19 = v24.Position + Vector3.new(0, v24.Size.Y / 2, 0)

				if tbl4.DistanceTo(n19 + Vector3.new(0, 2, 0)) > n14 then
					if type(tbl4.FlyTo) ~= "function" or not tbl4.FlyTo(n19, fn41, "treadmill") then
						return false
					end
				end

				if fn41() then
					return false
				end
				treadmill.Riding = fn37(fn36("RF/Treadmill/AskWearStill"))
				return treadmill.Riding
			end

			tbl3.Add(function()
				if not fn38() then
					if treadmill.Riding and not flag4 then
						flag4 = true

						task.spawn(function()
							pcall(tbl4.ExitBelt)
							flag4 = false
							tbl3.Wake()
						end)
					end

					return false
				end

				if flag4 or fn39() then
					return false
				end

				if treadmill.Riding and tbl4.Toggle(v22, true) and tbl4.OnBelt() then
					if os.clock() >= (treadmill.NextCheck or 0) and not tbl4.Flying and tbl4.Grounded() then
						treadmill.NextCheck = os.clock() + n16
						flag4 = true

						task.spawn(function()
							local ok, result = pcall(function()
								return fn37(fn36("RF/Treadmill/AskWearStill"))
							end)

							treadmill.Riding = ok and result == true

							if not treadmill.Riding then
								treadmill.NextTry = 0
							end

							flag4 = false
							tbl3.Wake()
						end)
					end

					return false
				end

				if os.clock() < (treadmill.NextTry or 0) then
					return false
				end
				treadmill.NextCheck = 0
				treadmill.NextTry = os.clock() + (treadmill.LastFailed and 3 or 4)
				flag4 = true

				task.spawn(function()
					local ok, result = pcall(fn40)
					treadmill.LastFailed = not (ok and result == true)
					tbl4.ReleaseMovement("treadmill")
					flag4 = false
					tbl3.Wake()
				end)

				return false
			end)

			task.spawn(function()
				while not flag5 do
					task.wait(3)

					if not fn38() and not fn39() and not tbl4.Flying and tbl4.OnBelt() and tbl4.Grounded() then
						fn37(fn36("RF/Treadmill/AskWearStill"))
					end
				end
			end)

			task.spawn(function()
				local n19 = 0

				while not flag5 do
					local v23 = task.wait(0.25)

					if not fn38() or not treadmill.Riding or fn39() then
						n19 = 0
					elseif tbl4.OnBelt() then
						n19 = 0
					else
						n19 += v23

						if n19 >= 1.5 then
							treadmill.Riding = false
							treadmill.NextTry = 0
							tbl3.Wake()
							n19 = 0
						end
					end
				end
			end)

			task.spawn(function()
				local n19 = 0
				local n20 = 0
				local position = nil

				while not flag5 do
					local v23 = task.wait(0.25)
					n19 = math.max(0, n19 - v23)
					local flag6 = treadmill.Riding and fn38() and not fn39()
					local v24 = tbl4.Root()
					local character = localPlayer.Character
					character = character and character:FindFirstChildOfClass("Humanoid")

					if flag6 or not (tbl4.Flying or tbl4.Movement.Owner ~= nil or tbl4.Movement.PlaceWanted or character ~= nil and character.MoveDirection.Magnitude > 0.1) or not v24 or not tbl4.OnBelt() then
						position = v24 and v24.Position
						n20 = 0
						position = position or nil
					else
						local vector = Vector3.new(v24.Position.X, 0, v24.Position.Z)
						position = position and (vector - Vector3.new(position.X, 0, position.Z)).Magnitude < 0.5

						if position then
							n20 += v23
						else
							n20 = 0
						end

						position = v24.Position

						if n20 >= n15 and n19 <= 0 then
							pcall(tbl4.ExitBelt)
							n19 = 1.5
							n20 = 0
						end
					end
				end
			end)

			fn4(function()
				flag5 = true
				treadmill.Riding = false
			end)

			v21 = v10:CreateToggle({
				Name = "Auto Treadmill",
				Default = false,
				Callback = function()
					n18 += 1
					tbl4.StopWalking()
					tbl3.Wake()
				end,
			})

			v22 = v10:CreateToggle({ Name = "Stay On Treadmill", Default = true })
		end

		do
			local n14 = 4
			local n15 = 10
			local v21 = nil
			local flag3 = false
			local n16 = 0
			local tbl23 = {}
			local tbl24 = { MinRarity = 0, MinIncome = 0, Eggs = {} }

			local function fn36(arg, arg2)
				local v22 = networking:FindFirstChild(arg)
				if not v22 or not v22:IsA("RemoteFunction") then
					return false, nil
				end
				return pcall(v22.InvokeServer, v22, arg2)
			end

			local function fn37(arg)
				local flag4 = tbl24.MinRarity > 0

				if flag4 then
					local minRarity = tbl24.MinRarity
					flag4 = tbl4.EggRarity(arg) < minRarity
				end

				if flag4 then
					return false
				end
				local flag5 = tbl24.MinIncome > 0

				if flag5 then
					local minIncome = tbl24.MinIncome
					flag5 = tbl4.EggIncome(arg) < minIncome
				end

				if flag5 then
					return false
				end

				if next(tbl24.Eggs) ~= nil and tbl24.Eggs[tostring(arg.AssetCategory)] ~= true then
					return false
				end
				return true
			end

			local function fn38()
				local eggState = tbl.EggState
				if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return {}
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return {}
				end
				local flag4 = tbl4.Toggle(v21, false) == true
				local Hatch = tbl4.RiftOn("Hatch") and tbl4.RiftShortfall() or {}
				local tbl25 = {}
				local tbl26 = {}

				for k, v22 in pairs(result) do
					local flag5 = type(v22) == "table" and v22.Placement ~= nil

					if flag5 then
						flag5 = (tbl23[k] or 0) <= os.clock()
					end

					if flag5 then
						local ok2, result2 = pcall(eggState.IsReadyToHatch, k)

						if ok2 and result2 == true then
							local str3 = tostring(v22.AssetCategory)

							if (Hatch[str3] or 0) > 0 then
								Hatch[str3] = Hatch[str3] - 1
								table.insert(tbl25, k)
							elseif flag4 and fn37(v22) then
								table.insert(tbl26, k)
							end
						end
					end
				end

				for _, v22 in ipairs(tbl26) do
					table.insert(tbl25, v22)
				end

				return tbl25
			end

			local function fn39()
				return tbl4.Toggle(v21, false) or tbl4.RiftOn("Hatch")
			end

			local function fn40()
				local v22 = n16
				local v23 = fn38()
				local n17 = 0

				for _, v24 in ipairs(v23) do
					if not (n17 >= n14 or v22 ~= n16 or not fn39()) then
						local AskHatch, v25 = fn36("RF/EggWorld/AskHatch", v24)

						if AskHatch and v25 ~= false then
							task.wait(0.35)
							fn36("RF/EggWorld/AskFinishHatch", v24)
							n17 += 1
							tbl23[v24] = nil
						else
							tbl23[v24] = os.clock() + n15
						end

						task.wait(0.2)
						continue
					end

					break
				end

				return n17 > 0
			end

			tbl3.Add(function()
				if not fn39() or flag3 then
					return false
				end
				flag3 = true

				task.spawn(function()
					pcall(fn40)
					flag3 = false
				end)

				return false
			end)

			local function hatch()
				n16 += 1
				table.clear(tbl23)
				tbl3.Wake()
			end

			v21 = v11:CreateToggle({ Name = "Auto Hatch", Default = false, Callback = hatch })

			v11:CreateDropdown({
				Name = "Hatch Min Rarity",
				Note = "Hatch eggs of the chosen rarity and every rarity above it",
				Options = tbl8,
				Default = tbl8[1],
				SubOf = v21,
				Callback = function(arg)
					tbl24.MinRarity = tbl9[arg] or 0
					hatch()
				end,
			})

			local tbl25 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local tbl26 = { Slider = nil, Value = 0, Unit = "M/s" }

			local function fn41(arg, arg2)
				if arg ~= nil then
					tbl26.Value = math.max(0, math.floor(tonumber(arg) or tbl26.Value))
				end

				if arg2 ~= nil then
					tbl26.Unit = tostring(arg2)
				end

				tbl24.MinIncome = tbl26.Value * (tbl25[tbl26.Unit] or tbl25["M/s"]).Mult
				hatch()
			end

			tbl26.Slider = fn5(v11, {
				Name = "Min Hatch Value",
				Note = "Skip eggs worth less than this (0 = off)",
				SubOf = v21,
				Legacy = "Hatch Min Value",
				SectionName = "Auto Hatch & Equip",
				OnRaw = function(arg)
					fn41(math.floor(arg / 1000), "K/s")
				end,
			})

			local tbl27 = {}
			local tbl28 = {}
			local directory = tbl.Assets and tbl.Assets.Directory
			local n17 = 0

			while (type(directory) ~= "table" or next(directory) == nil) and n17 < 2 do
				n17 += task.wait(0.1)

				if type(tbl.Assets) ~= "table" then
					tbl.Assets = fn2(function()
						return ReplicatedStorage.Data.Assets
					end)
				end

				directory = tbl.Assets and tbl.Assets.Directory
			end

			local tbl29 = {}

			if type(directory) == "table" then
				for k, v22 in pairs(directory) do
					local rarity = type(v22) == "table" and v22.Rarity or nil
					local flag4 = type(rarity) == "table"

					if flag4 then
						flag4 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					flag4 = flag4 or nil

					if flag4 then
						table.insert(tbl29, {
							Category = tostring(k),
							Name = tostring(v22.DisplayName or k),
							Rarity = flag4,
							RarityName = tostring(rarity.DisplayName or rarity._id or flag4),
						})
					end
				end
			end

			table.sort(tbl29, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity > arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v22 in ipairs(tbl29) do
				local str3 = string.format("%s [%s]", v22.Name, v22.RarityName)

				if tbl28[str3] then
					str3 = string.format("%s [%s] (%s)", v22.Name, v22.RarityName, v22.Category)
				end

				table.insert(tbl27, str3)
				tbl28[str3] = v22.Category
			end

			if #tbl27 > 0 then
				fn6(v11:CreateMultiDropdown({
					Name = "Hatch Specific Eggs",
					Note = "Only hatch these eggs (empty = all)",
					Options = tbl27,
					Default = {},
					SubOf = v21,
					Callback = function(arg)
						local eggs = {}

						if type(arg) == "table" then
							for k, v22 in pairs(arg) do
								k = v22 == true and type(k) == "string" and k or type(v22) == "string" and v22 or nil

								if k and tbl28[k] then
									eggs[tbl28[k]] = true
								end
							end
						end

						tbl24.Eggs = eggs
						hatch()
					end,
				}))
			end

			tbl4.Rift.Restart.Hatch = hatch
		end

		do
			local n14 = 5
			local n15 = 30
			local v21 = nil
			local flag3 = false
			local n16 = 0
			local tbl23 = {}
			local n17 = 0
			local flag4 = true
			local v22 = nil
			local n18 = -math.huge

			local function fn36(arg)
				local v23 = fn2(function()
					return ReplicatedStorage.Data.Bases
				end)

				if type(v23) == "table" and type(v23.GetAssetEquipCapacity) == "function" then
					local ok, result = pcall(v23.GetAssetEquipCapacity, arg and tonumber(arg.BaseUpgradeLevel) or 0)
					if ok and tonumber(result) then
						return math.floor(tonumber(result))
					end
				end

				if v22 and os.clock() - n18 < n15 then
					return v22
				end
				local rfPenRosterAskWearLimit = networking:FindFirstChild("RF/PenRoster/AskWearLimit")

				if rfPenRosterAskWearLimit and rfPenRosterAskWearLimit:IsA("RemoteFunction") then
					local ok, result = pcall(rfPenRosterAskWearLimit.InvokeServer, rfPenRosterAskWearLimit)

					if ok and tonumber(result) then
						local n19 = math.floor(tonumber(result))
						local now = os.clock()
						v22 = n19
						n18 = now
						return v22
					end
				end

				local v24 = v22
				local n19

				if v22 then
					n19 = v24
				else
					n19 = 0
				end

				return n19
			end

			local function fn37(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				local flag5 = type(directory) == "table" and directory[tostring(arg.Category)] or nil
				local n19 = type(flag5) == "table" and tonumber(flag5.EarningRate) or 0
				local n20 = tonumber(arg.Scale) or 0
				if n19 <= 0 or n20 <= 0 then
					return 0
				end
				local n21 = n20 > 5 and (n20 / 5) ^ 1.2 * 19.637875755794113 or n20 ^ 1.85
				local mutations = tbl.Mutations
				local flag6 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n22 = 1

				if flag6 then
					local ok, result = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
					ok = ok and type(result) == "number"
					local n23 = 1

					if ok then
						n22 = result
					else
						n22 = n23
					end
				end

				return n19 * n21 * n22
			end

			local function fn38()
				local save3 = tbl.Save
				local result

				if type(save3) == "table" and type(save3.Get) == "function" then
					local ok
					ok, result = pcall(save3.Get)
					result = ok and type(result) == "table" and result or nil
				end

				if not result then
					return nil
				end
				local tbl24 = {}
				local tbl25 = {}
				local v23 = pairs
				local equippedAssets = result.EquippedAssets or {}

				for _, equippedAsset in v23(equippedAssets) do
					if type(equippedAsset) == "string" then
						tbl24[equippedAsset] = true
						table.insert(tbl25, equippedAsset)
					end
				end

				local tbl26 = {}
				local v24 = pairs
				local inventory = result.Inventory or {}

				for k, v25 in v24(inventory) do
					if type(v25) == "table" and v25.InFuse ~= true then
						table.insert(tbl26, { Uid = k, Income = fn37(v25), Equipped = tbl24[k] == true })
					end
				end

				table.sort(tbl26, function(arg, arg2)
					if arg.Income ~= arg2.Income then
						return arg.Income > arg2.Income
					end
					return tostring(arg.Uid) < tostring(arg2.Uid)
				end)

				return tbl26, tbl24, #tbl25, result
			end

			local function fn39(arg, arg2)
				local tbl24 = {}
				local flag5 = false

				for i, v23 in ipairs(arg) do
					if not (arg2 < i) then
						if not v23.Equipped then
							table.insert(tbl24, v23.Uid)

							if not tbl23[v23.Uid] then
								flag5 = true
							end
						end

						continue
					end

					break
				end

				return tbl24, flag5
			end

			tbl3.Add(function()
				if not tbl4.Toggle(v21, false) then
					return false
				end
				local v23, v24, v25, v26 = fn38()

				if v23 then
					local v27 = fn36(v26)
					local v28, v29 = fn39(v23, v27)

					if (v29 or flag4) and not flag3 and os.clock() >= n17 then
						for _, v30 in ipairs(v28) do
							tbl23[v30] = true
						end

						flag4 = false
						flag3 = true
						n17 = os.clock() + n14
						local v30 = n16

						task.spawn(function()
							local rfHaulFetchWearBestStatus = networking:FindFirstChild("RF/Haul/FetchWearBestStatus")
							local isRemoteFunction = rfHaulFetchWearBestStatus and rfHaulFetchWearBestStatus:IsA("RemoteFunction")
							local flag5 = true

							if isRemoteFunction then
								local ok, result = pcall(rfHaulFetchWearBestStatus.InvokeServer, rfHaulFetchWearBestStatus)
								flag5 = ok and result ~= false and result ~= nil
							end

							local rfHaulWearBest = networking:FindFirstChild("RF/Haul/WearBest")

							if flag5 and v30 == n16 and rfHaulWearBest and rfHaulWearBest:IsA("RemoteFunction") then
								pcall(rfHaulWearBest.InvokeServer, rfHaulWearBest)
							end

							flag3 = false
							tbl3.Wake()
						end)
					end
				end

				return false
			end)

			v21 = v11:CreateToggle({
				Name = "Auto Equip Best",
				Note = "Equip Best when a better pet appears",
				Default = false,
				Callback = function()
					n16 += 1
					table.clear(tbl23)
					n17 = 0
					flag4 = true
					tbl3.Wake()
				end,
			})

			local save3 = tbl.Save

			if type(save3) == "table" and type(save3.FieldSignal) == "function" then
				for _, v23 in ipairs({ "Inventory", "EquippedAssets" }) do
					local ok, result = pcall(save3.FieldSignal, v23)

					if ok and type(result) == "table" and type(result.Connect) == "function" then
						local ok2, result2 = pcall(result.Connect, result, function()
							flag4 = true
							tbl3.Wake()
						end)

						if ok2 and result2 then
							fn4(function()
								pcall(function()
									result2:Disconnect()
								end)
							end)
						end
					end
				end
			end
		end

		local n14
		n14 = 3
		local tbl23, tbl24, tbl25, tbl26, tbl27

		do
			local n15 = 50
			tbl23 = { "Rarity Only", "Value Only", "Rarity And Value", "Rarity Or Value" }

			local v21 = fn2(function()
				return ReplicatedStorage.Shared.Util.AssetItems
			end)

			tbl24 = {}
			tbl25 = {}
			tbl26 = {}
			tbl27 = {}
			local directory = tbl.Assets and tbl.Assets.Directory
			local tbl28 = {}
			local tbl29 = {}

			if type(directory) == "table" then
				for k, v22 in pairs(directory) do
					local rarity = type(v22) == "table" and v22.Rarity or nil
					local flag3 = type(rarity) == "table"

					if flag3 then
						flag3 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					flag3 = flag3 or nil

					if flag3 then
						local str3 = tostring(rarity.DisplayName or rarity._id or flag3)
						tbl28[flag3] = tbl28[flag3] or str3

						table.insert(tbl29, {
							Category = tostring(k),
							Name = tostring(v22.DisplayName or k),
							Rarity = flag3,
							RarityName = str3,
						})
					end
				end
			end

			local tbl30 = {}

			for k in pairs(tbl28) do
				table.insert(tbl30, k)
			end

			table.sort(tbl30)

			for _, v22 in ipairs(tbl30) do
				local str3 = string.format("%d - %s", v22, tbl28[v22])
				table.insert(tbl24, str3)
				tbl25[str3] = v22
			end

			table.sort(tbl29, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity < arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v22 in ipairs(tbl29) do
				local str3 = string.format("%s [%s]", v22.Name, v22.RarityName)

				if tbl27[str3] then
					str3 = string.format("%s [%s] (%s)", v22.Name, v22.RarityName, v22.Category)
				end

				table.insert(tbl26, str3)
				tbl27[str3] = v22.Category
			end

			local function fn36(arg)
				for _, v22 in ipairs(tbl24) do
					if tbl25[v22] == arg then
						return v22
					end
				end

				return tbl24[1]
			end

			local v22 = nil
			local v23 = nil
			local v24 = nil
			local v25 = nil
			local v26 = tbl23[1]
			local n16 = 3
			local n17 = 0
			local flag3 = true
			local tbl31 = {}
			local v27 = tbl23[1]
			local n18 = 3
			local n19 = 0
			local flag4 = true
			local tbl32 = {}
			local flag5 = false
			local n20 = 0

			local function fn37(arg)
				local n21 = tonumber(arg) or 0
				local tbl33 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local n22 = 1

				while math.abs(n21) >= 1000 and n22 < #tbl33 do
					n21 /= 1000
					n22 += 1
				end

				return string.format(n22 == 1 and "$%.0f%s" or "$%.2f%s", n21, tbl33[n22])
			end

			local function fn38(arg, arg2)
				local tbl33 = {}

				if type(arg) == "table" then
					for k, v28 in pairs(arg) do
						k = v28 == true and type(k) == "string" and k or type(v28) == "string" and v28 or nil

						if k then
							tbl33[arg2 and arg2[k] or k] = true
						end
					end
				end

				return tbl33
			end

			local function fn39(arg)
				local directory2 = tbl.Assets and tbl.Assets.Directory
				local flag6 = type(directory2) == "table" and directory2[tostring(arg)] or nil
				local rarity = type(flag6) == "table" and flag6.Rarity or nil
				local flag7 = type(rarity) == "table"

				if flag7 then
					flag7 = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				return flag7 or math.huge
			end

			local function fn40(arg)
				local directory2 = tbl.Assets and tbl.Assets.Directory
				local flag6 = type(directory2) == "table" and directory2[tostring(arg.Category)] or nil
				local n21 = type(flag6) == "table" and tonumber(flag6.EarningRate) or 0
				local n22 = tonumber(arg.Scale) or 0
				if n21 <= 0 or n22 <= 0 then
					return 0
				end
				local n23 = n22 > 5 and (n22 / 5) ^ 1.2 * 19.637875755794113 or n22 ^ 1.85
				local mutations = tbl.Mutations
				local flag7 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n24 = 1

				if flag7 then
					local ok, result = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})

					if ok and type(result) == "number" then
						n24 = result
					end
				end

				return n21 * n23 * n24
			end

			local function fn41(arg)
				return type(arg) == "table" and next(arg) ~= nil
			end

			local function fn42()
				local save3 = tbl.Save
				if type(save3) ~= "table" or type(save3.Get) ~= "function" then
					return nil
				end
				local ok, result = pcall(save3.Get)
				return ok and type(result) == "table" and result or nil
			end

			local function fn43()
				local v28 = fn42()
				local tbl33 = {}
				if not v28 then
					return tbl33, 0
				end
				local tbl34 = {}
				local v29 = pairs
				local equippedAssets = v28.EquippedAssets or {}

				for _, equippedAsset in v29(equippedAssets) do
					tbl34[equippedAsset] = true
				end

				local v30 = pairs
				local inventory = v28.Inventory or {}
				local n21 = 0

				for k, v31 in v30(inventory) do
					local flag6 = type(v31) == "table" and v31.InFuse ~= true and v31.IsFavorite ~= true and not tbl34[k] and not tbl31[tostring(v31.Category)]

					if flag6 then
						flag6 = not (flag3 and fn41(v31.Mutations))
					end

					if flag6 then
						local v32 = fn40(v31)
						local flag7 = fn39(v31.Category) <= n16
						local flag8 = n17 > 0 and v32 < n17

						if v26 ~= tbl23[2] then
							if v26 == tbl23[3] then
								flag8 = flag7 and flag8
							elseif v26 == tbl23[4] then
								flag8 = flag7 or flag8
							else
								flag8 = flag7
							end
						end

						if flag8 then
							table.insert(tbl33, k)
							local flag9 = type(v21) == "table" and type(v21.SalePrice) == "function"
							local flag10 = false
							local result = nil

							if flag9 then
								flag10, result = pcall(v21.SalePrice, v31)
							end

							n21 += flag10 and tonumber(result) or v32 * 100
						end
					end
				end

				return tbl33, n21
			end

			local function fn44()
				local tbl33 = {}
				local eggState = tbl.EggState
				if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
					return tbl33, 0
				end
				local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if not ok or type(result) ~= "table" then
					return tbl33, 0
				end
				local character = localPlayer.Character
				character = character and character:FindFirstChildWhichIsA("Tool")
				character = character and character:GetAttribute("UID") or nil
				local eggRecords = tbl.EggRecords
				local v28, v29, v30 = pairs(result)
				local n21 = 0

				for k, v31 in v28, v29, v30 do
					local flag6 = type(v31) == "table" and v31.Placement == nil and k ~= character and not tbl32[tostring(v31.AssetCategory)]

					if flag6 then
						flag6 = not (flag4 and fn41(v31.Mutations))
					end

					if flag6 then
						local v32 = fn40({ Category = v31.AssetCategory, Scale = v31.AssetScale, Mutations = v31.Mutations })
						local flag7 = fn39(v31.AssetCategory) <= n18
						local flag8 = n19 > 0 and v32 < n19

						if v27 ~= tbl23[2] then
							if v27 == tbl23[3] then
								flag8 = flag7 and flag8
							elseif v27 ~= tbl23[4] then
								flag8 = flag7
							else
								flag8 = flag7 or flag8
							end
						end

						if flag8 then
							table.insert(tbl33, k)

							if type(eggRecords) == "table" and type(eggRecords.SellPrice) == "function" then
								local ok2, result2 = pcall(eggRecords.SellPrice, v31)
								n21 += ok2 and tonumber(result2) or 0
							end
						end
					end
				end

				return tbl33, n21
			end

			local function fn45(arg, arg2)
				local rePetSatchelSellSelection = networking:FindFirstChild("RE/PetSatchel/SellSelection")
				if not rePetSatchelSellSelection or not rePetSatchelSellSelection:IsA("RemoteEvent") then
					return false
				end
				local n21 = math.max(#arg, #arg2)
				local n22 = 1

				while n22 <= n21 do
					local tbl33 = {}
					local tbl34 = {}

					for i = n22, n22 + n15 - 1 do
						if arg[i] then
							table.insert(tbl33, arg[i])
						end

						if arg2[i] then
							table.insert(tbl34, arg2[i])
						end
					end

					pcall(rePetSatchelSellSelection.FireServer, rePetSatchelSellSelection, { Eggs = tbl34, Assets = tbl33 })
					n22 += n15

					if n22 <= n21 then
						task.wait(0.3)
					end
				end

				return true
			end

			local function fn46(arg, arg2)
				local flag6 = flag5

				if not flag5 then
					flag6 = #arg == 0 and #arg2 == 0
				end

				if flag6 then
					return
				end
				flag5 = true
				n20 = os.clock() + n14

				task.spawn(function()
					pcall(fn45, arg, arg2)
					flag5 = false
					tbl3.Wake()
				end)
			end

			tbl3.Add(function()
				local v28 = tbl4.Toggle(v22, false)
				local v29 = tbl4.Toggle(v23, false)
				local v30, v31 = fn43()
				local v32, v33 = fn44()

				if v24 and type(v24.Set) == "function" then
					pcall(v24.Set, v24, string.format("Pet matches  -  %d pets for %s", #v30, fn37(v31)))
				end

				if v25 and type(v25.Set) == "function" then
					pcall(v25.Set, v25, string.format("Egg matches  -  %d eggs for %s", #v32, fn37(v33)))
				end

				local v34 = flag5
				local flag6

				if flag5 then
					flag6 = v34
				else
					flag6 = os.clock() < n20
				end

				local flag7

				if flag6 then
					flag7 = flag6
				else
					flag7 = not (v28 or v29)
				end

				if flag7 then
					return false
				end
				fn46(v28 and v30 or {}, v29 and v32 or {})
				return false
			end)

			v24 = v12:CreateText({ Name = "Pet Sell Preview", Text = "Pet matches  -  0 pets" })

			v22 = v12:CreateToggle({
				Name = "Auto Sell Pet",
				Default = false,
				Callback = function()
					tbl3.Wake()
				end,
			})

			v12:CreateButton({
				Name = "Sell Pets Now",
				ButtonText = "Sell",
				ConfirmText = "Sold!",
				SubOf = v22,
				Callback = function()
					fn46(fn43(), {})
				end,
			})

			v12:CreateDropdown({
				Name = "Sell Pet Rule",
				Note = "Which checks must pass to sell",
				Options = tbl23,
				Default = tbl23[1],
				SubOf = v22,
				Callback = function(arg)
					if table.find(tbl23, arg) then
						v26 = arg
						tbl3.Wake()
					end
				end,
			})

			v12:CreateDropdown({
				Name = "Pet Max Rarity",
				Note = "Sell pets at or below this rarity",
				Options = tbl24,
				Default = fn36(3),
				SubOf = v22,
				Callback = function(arg)
					n16 = tbl25[arg] or n16
					tbl3.Wake()
				end,
			})

			local tbl33 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local function fn47(arg, arg2, arg3, arg4)
				local n21 = 0
				local str3 = "M/s"

				local function fn48(arg5, arg6)
					if arg5 ~= nil then
						n21 = math.max(0, math.floor(tonumber(arg5) or n21))
					end

					if arg6 ~= nil then
						str3 = tostring(arg6)
					end

					arg4(n21 * (tbl33[str3] or tbl33["M/s"]).Mult)
					tbl3.Wake()
				end

				return (fn5(v12, {
					Name = arg == "Pet Value Threshold" and "Pet Sell Value" or arg == "Egg Value Threshold" and "Egg Sell Value" or arg,
					Note = arg2,
					SubOf = arg3,
					Legacy = arg,
					SectionName = "Auto Sell",
					OnRaw = function(arg5)
						fn48(math.floor(arg5 / 1000), "K/s")
					end,
				}))
			end

			fn47("Pet Value Threshold", "Sell pets worth less than this (0 = off)", v22, function(arg)
				n17 = arg
			end)

			local v28 = nil

			v28 = v12:CreateToggle({
				Name = "Keep Mutated Pets",
				Note = "Never sell mutated pets",
				Default = true,
				SubOf = v22,
				Callback = function()
					flag3 = tbl4.Toggle(v28, true)
					tbl3.Wake()
				end,
			})

			fn6(v12:CreateMultiDropdown({
				Name = "Blacklist Sell Pets",
				Note = "These pets are never sold",
				Options = tbl26,
				Default = {},
				SubOf = v22,
				Callback = function(arg)
					tbl31 = fn38(arg, tbl27)
					tbl3.Wake()
				end,
			}))

			v25 = v12:CreateText({ Name = "Egg Sell Preview", Text = "Egg matches  -  0 eggs" })

			v23 = v12:CreateToggle({
				Name = "Auto Sell Egg",
				Note = "Sell bag eggs matching the rules below",
				Default = false,
				Callback = function()
					tbl3.Wake()
				end,
			})

			v12:CreateButton({
				Name = "Sell Eggs Now",
				Note = "Sell matching eggs once",
				ButtonText = "Sell",
				ConfirmText = "Sold!",
				SubOf = v23,
				Callback = function()
					local v29 = fn44()
					fn46({}, v29)
				end,
			})

			v12:CreateDropdown({
				Name = "Sell Egg Rule",
				Note = "Which checks must pass to sell",
				Options = tbl23,
				Default = tbl23[1],
				SubOf = v23,
				Callback = function(arg)
					if table.find(tbl23, arg) then
						v27 = arg
						tbl3.Wake()
					end
				end,
			})

			v12:CreateDropdown({
				Name = "Egg Max Rarity",
				Note = "Sell eggs at or below this rarity",
				Options = tbl24,
				Default = fn36(3),
				SubOf = v23,
				Callback = function(arg)
					n18 = tbl25[arg] or n18
					tbl3.Wake()
				end,
			})

			fn47("Egg Value Threshold", "Sell eggs worth less than this (0 = off)", v23, function(arg)
				n19 = arg
			end)

			local v29 = nil

			v29 = v12:CreateToggle({
				Name = "Keep Mutated Eggs",
				Note = "Never sell mutated eggs",
				Default = true,
				SubOf = v23,
				Callback = function()
					flag4 = tbl4.Toggle(v29, true)
					tbl3.Wake()
				end,
			})

			fn6(v12:CreateMultiDropdown({
				Name = "Blacklist Sell Eggs",
				Note = "These eggs are never sold",
				Options = tbl26,
				Default = {},
				SubOf = v23,
				Callback = function(arg)
					tbl32 = fn38(arg, tbl27)
					tbl3.Wake()
				end,
			}))
		end

		local save3 = tbl.Save

		if type(save3) == "table" and type(save3.FieldSignal) == "function" then
			for _, v21 in ipairs({ "Inventory", "EggInventory", "EquippedAssets" }) do
				local ok, result = pcall(save3.FieldSignal, v21)

				if ok and type(result) == "table" and type(result.Connect) == "function" then
					local ok2, result2 = pcall(result.Connect, result, function()
						tbl3.Wake()
					end)

					if ok2 and result2 then
						fn4(function()
							pcall(function()
								result2:Disconnect()
							end)
						end)
					end
				end
			end
		end

		local n15
		n15 = 2
		local n16
		n16 = 3
		local n17
		n17 = 20
		local tbl28
		tbl28 = { "Lowest Rarity First", "Highest Rarity First", "Most Copies First", "Lowest Value First" }
		local tbl29
		tbl29 = { "Lowest To Highest", "Highest To Lowest" }
		local tbl30
		tbl30 = {}
		local tbl31
		tbl31 = {}
		local tbl32
		tbl32 = {}
		local tbl33
		tbl33 = {}

		do
			local directory = tbl.Assets and tbl.Assets.Directory
			local tbl34 = {}
			local tbl35 = {}

			if type(directory) == "table" then
				for k, v21 in pairs(directory) do
					local rarity = type(v21) == "table" and v21.Rarity or nil
					local flag3 = type(rarity) == "table"

					if flag3 then
						flag3 = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					local v22 = flag3 or nil

					if v22 then
						local rarityName = tostring(rarity.DisplayName or rarity._id or v22)
						tbl34[v22] = tbl34[v22] or rarityName
						local insert = table.insert
						local tbl36 = { Category = tostring(k) }
						local v23 = tostring
						k = v21.DisplayName or k
						tbl36.Name = v23(k)
						tbl36.Rarity = v22
						tbl36.RarityName = rarityName
						insert(tbl35, tbl36)
					end
				end
			end

			local tbl36 = {}

			for k in pairs(tbl34) do
				table.insert(tbl36, k)
			end

			table.sort(tbl36)

			for _, v21 in ipairs(tbl36) do
				local str3 = string.format("%d - %s", v21, tbl34[v21])
				table.insert(tbl30, str3)
				tbl31[str3] = v21
			end

			table.sort(tbl35, function(arg, arg2)
				if arg.Rarity ~= arg2.Rarity then
					return arg.Rarity < arg2.Rarity
				end
				return arg.Name < arg2.Name
			end)

			for _, v21 in ipairs(tbl35) do
				local str3 = string.format("%s [%s]", v21.Name, v21.RarityName)

				if tbl33[str3] then
					str3 = string.format("%s [%s] (%s)", v21.Name, v21.RarityName, v21.Category)
				end

				table.insert(tbl32, str3)
				tbl33[str3] = v21.Category
			end
		end

		do
			local function fn36(arg)
				for _, v21 in ipairs(tbl30) do
					if tbl31[v21] == arg then
						return v21
					end
				end

				return tbl30[#tbl30]
			end

			local v21 = nil
			local v22 = nil
			local v23 = tbl28[1]
			local v24 = tbl29[1]
			local n18 = 6
			local tbl34 = {}
			local flag3 = true
			local flag4 = true
			local flag5 = false
			local n19 = 0
			local n20 = 0
			local n21 = 0
			local tbl35 = {}

			local function fn37(arg, arg2)
				local v25 = networking:FindFirstChild(arg)
				if not v25 or not v25:IsA("RemoteFunction") then
					return false, nil
				end

				if arg2 == nil then
					return pcall(v25.InvokeServer, v25)
				end
				return pcall(v25.InvokeServer, v25, arg2)
			end

			local function fn38()
				local save4 = tbl.Save
				if type(save4) ~= "table" or type(save4.Get) ~= "function" then
					return nil
				end
				local ok, result = pcall(save4.Get)
				return ok and type(result) == "table" and result or nil
			end

			local function fn39(arg)
				local directory = tbl.Assets and tbl.Assets.Directory
				return type(directory) == "table" and directory[tostring(arg)] or nil
			end

			local function fn40(arg)
				local v25 = fn39(arg)
				local rarity = type(v25) == "table" and v25.Rarity or nil
				local flag6 = type(rarity) == "table"

				if flag6 then
					flag6 = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				return flag6 or math.huge
			end

			local function fn41(arg)
				local v25 = fn39(arg)
				return tostring(type(v25) == "table" and v25.DisplayName or arg)
			end

			local function fn42(arg)
				local v25 = fn39(arg.Category)
				local n22 = type(v25) == "table" and tonumber(v25.EarningRate) or 0
				local n23 = tonumber(arg.Scale) or 0
				if n22 <= 0 or n23 <= 0 then
					return 0
				end
				local n24 = n23 > 5 and (n23 / 5) ^ 1.2 * 19.637875755794113 or n23 ^ 1.85
				local mutations = tbl.Mutations
				local flag6 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local n25 = 1

				if flag6 then
					local ok
					ok, n25 = pcall(mutations.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
					local flag7 = ok and type(n25) == "number"
					local n26 = 1

					if not flag7 then
						n25 = n26
					end
				end

				return n22 * n24 * n25
			end

			local function fn43(arg)
				return type(arg) == "table" and next(arg) ~= nil
			end

			local function fn44(arg)
				local n22 = tonumber(arg) or 0
				local tbl36 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local n23 = 1

				while math.abs(n22) >= 1000 and n23 < #tbl36 do
					n22 /= 1000
					n23 += 1
				end

				return string.format(n23 == 1 and "$%.0f%s" or "$%.2f%s", n22, tbl36[n23])
			end

			local function fn45(arg)
				local fuseKernel = tbl.FuseKernel
				if type(fuseKernel) ~= "table" or type(fuseKernel.PriceFor) ~= "function" then
					return nil
				end
				local ok, result = pcall(fuseKernel.PriceFor, arg)
				return ok and tonumber(result) or nil
			end

			local function fn46(arg, arg2, arg3)
				local flag6 = type(arg2) == "table" and arg2.IsFavorite ~= true and not arg3[arg] and fn40(arg2.Category) <= n18 and (next(tbl34) == nil or tbl34[tostring(arg2.Category)] == true)
				local flag7

				if flag6 then
					flag7 = not (flag3 and fn43(arg2.Mutations))
				else
					flag7 = flag6
				end

				if flag7 then
					flag7 = (tbl35[arg] or 0) <= os.clock()
				end

				return flag7
			end

			local function fn47(arg)
				local inventory = type(arg.Inventory) == "table" and arg.Inventory or {}
				local tbl36 = {}
				local v25 = pairs
				local equippedAssets = arg.EquippedAssets or {}

				for _, equippedAsset in v25(equippedAssets) do
					tbl36[equippedAsset] = true
				end

				local tbl37 = {}
				local tbl38 = {}

				for i = 1, 3 do
					local flag6 = type(arg.FusionSlots) == "table" and arg.FusionSlots[i] or nil

					if flag6 ~= nil and type(inventory[flag6]) == "table" then
						table.insert(tbl37, flag6)
						tbl38[flag6] = true
					end
				end

				local tbl39 = {}

				for k, v26 in pairs(inventory) do
					if not tbl38[k] and type(v26) == "table" and v26.InFuse ~= true and fn46(k, v26, tbl36) then
						local str3 = tostring(v26.Category)
						tbl39[str3] = tbl39[str3] or {}
						table.insert(tbl39[str3], { Uid = k, Item = v26, Income = fn42(v26) })
					end
				end

				local function fn48(arg2)
					table.sort(arg2, function(arg3, arg4)
						if arg3.Income ~= arg4.Income then
							if v24 == tbl29[2] then
								return arg3.Income > arg4.Income
							end
							return arg3.Income < arg4.Income
						end

						return tostring(arg3.Uid) < tostring(arg4.Uid)
					end)
				end

				if #tbl37 > 0 then
					local str3 = tostring(inventory[tbl37[1]].Category)
					local flag6 = true

					for _, v26 in ipairs(tbl37) do
						local v27 = inventory[v26]

						if tostring(v27.Category) ~= str3 or not fn46(v26, v27, tbl36) then
							flag6 = false
						end
					end

					local tbl40 = tbl39[str3] or {}

					if flag6 and #tbl37 + #tbl40 >= 3 then
						fn48(tbl40)
						local tbl41 = { Category = str3, Load = {}, Items = {} }

						for _, v26 in ipairs(tbl37) do
							table.insert(tbl41.Items, inventory[v26])
						end

						for i = 1, 3 - #tbl37 do
							table.insert(tbl41.Load, tbl40[i].Uid)
							table.insert(tbl41.Items, tbl40[i].Item)
						end

						return tbl41
					end

					if flag4 then
						return { Category = str3, Eject = tbl37 }
					end
					return nil, "Machine holds pets that cannot finish a fuse"
				end

				local v26 = nil
				local v27 = nil

				for k, v28 in pairs(tbl39) do
					if #v28 >= 3 then
						local v29 = fn40(k)
						local n22 = 0

						for _, v30 in ipairs(v28) do
							n22 += v30.Income
						end

						local tbl40

						if v23 == tbl28[2] then
							tbl40 = { -v29, -#v28 }
						elseif v23 == tbl28[3] then
							tbl40 = { -#v28, v29 }
						elseif v23 == tbl28[4] then
							tbl40 = { n22 / #v28, v29 }
						else
							tbl40 = { v29, -#v28 }
						end

						local flag6 = v26 == nil or tbl40[1] < v26[1]
						local flag7

						if flag6 then
							flag7 = flag6
						else
							local flag8 = tbl40[1] == v26[1]

							if flag8 then
								local flag9 = tbl40[2] < v26[2]

								if flag9 then
									flag7 = flag9
								else
									flag7 = tbl40[2] == v26[2] and k < v27
								end
							else
								flag7 = flag8
							end
						end

						if flag7 then
							v26 = tbl40
							v27 = k
						end
					end
				end

				if not v27 then
					return nil, "No three matching pets"
				end
				local v28 = tbl39[v27]
				fn48(v28)
				local tbl40 = { Category = v27, Load = {}, Items = {} }

				for i = 1, 3 do
					table.insert(tbl40.Load, v28[i].Uid)
					table.insert(tbl40.Items, v28[i].Item)
				end

				return tbl40
			end

			local function fn48(arg)
				local v25 = fn38()
				if not v25 then
					return
				end

				if v25.FusionLocked == true then
					if type(v25.FusionEggReward) == "table" and os.clock() >= n21 then
						n21 = os.clock() + n16
						fn37("RF/Fusery/FinishReveal")
					end

					return
				end

				local v26 = fn47(v25)
				if not v26 then
					return
				end

				if v26.Eject then
					for _, v27 in ipairs(v26.Eject) do
						if arg ~= n19 then
							return
						end
						fn37("RF/Fusery/EjectPet", v27)
						task.wait(0.35)
					end

					return
				end

				local v27 = fn45(v26.Items)
				local num = tonumber(v25.Money)
				if v27 and num and num < v27 then
					return
				end

				for _, v28 in ipairs(v26.Load) do
					if arg ~= n19 then
						return
					end
					local LoadPet, v29 = fn37("RF/Fusery/LoadPet", v28)
					if not LoadPet or v29 == false then
						tbl35[v28] = os.clock() + n17
						return
					end
					task.wait(0.35)
				end

				if arg ~= n19 then
					return
				end
				local BeginFuse, v28 = fn37("RF/Fusery/BeginFuse")

				if BeginFuse and v28 ~= false then
					n21 = os.clock() + n16
				end
			end

			local function fn49(arg)
				if not arg then
					return "Fuse status unknown"
				end

				if arg.FusionLocked == true then
					return "Machine is fusing, waiting for the egg"
				end
				local v25, v26 = fn47(arg)
				if not v25 then
					return v26 or "No three matching pets"
				end

				if v25.Eject then
					return string.format("Would eject %d %s that cannot finish a fuse", #v25.Eject, fn41(v25.Category))
				end
				local v27 = fn45(v25.Items)
				local num = tonumber(arg.Money)
				local str3 = v27 and num and num < v27 and "  (not enough money)" or ""
				return string.format("Next fuse  -  3 %s for %s%s", fn41(v25.Category), v27 and fn44(v27) or "?", str3)
			end

			tbl3.Add(function()
				local v25 = fn38()

				if v22 and type(v22.Set) == "function" then
					pcall(v22.Set, v22, fn49(v25))
				end

				if not tbl4.Toggle(v21, false) or flag5 or os.clock() < n20 then
					return false
				end
				flag5 = true
				n20 = os.clock() + n15
				local v26 = n19

				task.spawn(function()
					pcall(fn48, v26)
					flag5 = false
					tbl3.Wake()
				end)

				return false
			end)

			v22 = v13:CreateText({ Name = "Fuse Preview", Text = "Fuse status unknown" })

			v21 = v13:CreateToggle({
				Name = "Auto Fuse Machine",
				Note = "Fuse 3 same pets into an egg, nonstop",
				Default = false,
				Callback = function()
					n19 += 1
					table.clear(tbl35)
					n20 = 0
					tbl3.Wake()
				end,
			})

			v13:CreateDropdown({
				Name = "Fuse Priority Mode",
				Options = tbl28,
				Default = tbl28[1],
				SubOf = v21,
				Callback = function(arg)
					if table.find(tbl28, arg) then
						v23 = arg
						tbl3.Wake()
					end
				end,
			})

			v13:CreateDropdown({
				Name = "Pets To Use",
				Options = tbl29,
				Default = tbl29[1],
				SubOf = v21,
				Callback = function(arg)
					if table.find(tbl29, arg) then
						v24 = arg
						tbl3.Wake()
					end
				end,
			})

			v13:CreateDropdown({
				Name = "Max Rarity to Fuse",
				Options = tbl30,
				Default = fn36(6),
				SubOf = v21,
				Callback = function(arg)
					n18 = tbl31[arg] or n18
					tbl3.Wake()
				end,
			})

			fn6(v13:CreateMultiDropdown({
				Name = "Specific Species to Fuse",
				Note = "Only fuse these species (empty = all)",
				Options = tbl32,
				Default = {},
				SubOf = v21,
				Callback = function(arg)
					local tbl36 = {}

					if type(arg) == "table" then
						for k, v25 in pairs(arg) do
							k = v25 == true and type(k) == "string" and k

							if k then
								v25 = k
							else
								v25 = type(v25) == "string" and v25
							end

							v25 = v25 or nil

							if v25 and tbl33[v25] then
								tbl36[tbl33[v25]] = true
							end
						end
					end

					tbl34 = tbl36
					tbl3.Wake()
				end,
			}))

			local v25 = nil

			v25 = v13:CreateToggle({
				Name = "Skip Mutated Pets",
				Default = true,
				SubOf = v21,
				Callback = function()
					flag3 = tbl4.Toggle(v25, true)
					tbl3.Wake()
				end,
			})

			local v26 = nil

			v26 = v13:CreateToggle({
				Name = "Eject Incomplete Slots",
				Note = "Take out pets that can't make a set",
				Default = true,
				SubOf = v21,
				Callback = function()
					flag4 = tbl4.Toggle(v26, true)
					tbl3.Wake()
				end,
			})
		end

		local save4 = tbl.Save

		if type(save4) == "table" and type(save4.FieldSignal) == "function" then
			for _, v21 in ipairs({
				"Inventory",
				"EquippedAssets",
				"FusionSlots",
				"FusionLocked",
				"FusionEggReward",
				"Money",
			}) do
				local ok, result = pcall(save4.FieldSignal, v21)

				if ok and type(result) == "table" and type(result.Connect) == "function" then
					local ok2, result2 = pcall(result.Connect, result, function()
						tbl3.Wake()
					end)

					if ok2 and result2 then
						fn4(function()
							pcall(function()
								result2:Disconnect()
							end)
						end)
					end
				end
			end
		end
	end

	do
		local n = 2
		local n2 = 25
		local n3 = 4
		local tbl10 = { "Match Any", "Match All" }
		local tbl11 = { "Golden", "Silver", "Rainbow", "Boss", "Monstrous", "Sakura", "GreatBloom" }
		local str = "Any Mutation"
		local tbl12 = { "Off" }
		local tbl13 = {}
		local tbl14 = {}
		local tbl15 = {}
		local tbl16 = { "Any Mutation" }
		local tbl17 = {}
		local directory = tbl.Assets and tbl.Assets.Directory
		local tbl18 = {}
		local tbl19 = {}

		if type(directory) == "table" then
			for k, v8 in pairs(directory) do
				local rarity = type(v8) == "table" and v8.Rarity or nil
				local flag = type(rarity) == "table"

				if flag then
					flag = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				local v9 = flag or nil

				if v9 then
					local rarityName = tostring(rarity.DisplayName or rarity._id or v9)
					tbl18[v9] = tbl18[v9] or rarityName
					local insert = table.insert
					local tbl20 = { Category = tostring(k) }
					local v10 = tostring
					k = v8.DisplayName or k
					tbl20.Name = v10(k)
					tbl20.Rarity = v9
					tbl20.RarityName = rarityName
					insert(tbl19, tbl20)
				end
			end
		end

		local tbl20 = {}

		for k in pairs(tbl18) do
			table.insert(tbl20, k)
		end

		table.sort(tbl20)

		for _, v8 in ipairs(tbl20) do
			local str2 = string.format("%d - %s", v8, tbl18[v8])
			table.insert(tbl12, str2)
			tbl13[str2] = v8
		end

		table.sort(tbl19, function(arg, arg2)
			if arg.Rarity ~= arg2.Rarity then
				return arg.Rarity < arg2.Rarity
			end
			return arg.Name < arg2.Name
		end)

		for _, v8 in ipairs(tbl19) do
			local str2 = string.format("%s [%s]", v8.Name, v8.RarityName)

			if tbl15[str2] then
				str2 = string.format("%s [%s] (%s)", v8.Name, v8.RarityName, v8.Category)
			end

			table.insert(tbl14, str2)
			tbl15[str2] = v8.Category
		end

		local tbl21 = {}
		local mutations = tbl.Mutations

		if type(mutations) == "table" and type(mutations.IdSet) == "table" then
			for k in pairs(mutations.IdSet) do
				table.insert(tbl21, tostring(k))
			end
		end

		if #tbl21 == 0 then
			tbl21 = table.clone(tbl11)
		end

		table.sort(tbl21, function(arg, arg2)
			return fn7(arg) < fn7(arg2)
		end)

		for _, v8 in ipairs(tbl21) do
			local v9 = fn7(v8)
			table.insert(tbl16, v9)
			tbl17[v9] = v8
		end

		local v8 = nil
		local v9 = nil
		local v10 = nil
		local v11 = nil
		local v12 = tbl10[2]
		local v13 = nil
		local flag = false
		local tbl22 = {}
		local n4 = 0
		local tbl23 = {}
		local flag2 = false
		local n5 = 0
		local tbl24 = {}

		local function fn8()
			local save = tbl.Save
			if type(save) ~= "table" or type(save.Get) ~= "function" then
				return nil
			end
			local ok, result = pcall(save.Get)
			return ok and type(result) == "table" and result or nil
		end

		local function fn9(arg)
			local directory2 = tbl.Assets and tbl.Assets.Directory
			return type(directory2) == "table" and directory2[tostring(arg)] or nil
		end

		local function fn10(arg)
			local v14 = fn9(arg)
			local rarity = type(v14) == "table" and v14.Rarity or nil
			local flag3 = type(rarity) == "table"

			if flag3 then
				flag3 = tonumber(rarity.RarityNumber or rarity.Rank)
			end

			return flag3 or 0
		end

		local function fn11(arg)
			local v14 = fn9(arg.Category)
			local n6 = type(v14) == "table" and tonumber(v14.EarningRate) or 0
			local n7 = tonumber(arg.Scale) or 0
			if n6 <= 0 or n7 <= 0 then
				return 0
			end
			local n8 = n7 > 5 and (n7 / 5) ^ 1.2 * 19.637875755794113 or n7 ^ 1.85
			local mutations2 = tbl.Mutations
			local flag3 = type(mutations2) == "table" and type(mutations2.EarningsFor) == "function"
			local n9 = 1

			if flag3 then
				local ok
				ok, n9 = pcall(mutations2.EarningsFor, type(arg.Mutations) == "table" and arg.Mutations or {})
				ok = ok and type(n9) == "number"
				local n10 = 1

				if not ok then
					n9 = n10
				end
			end

			return n6 * n8 * n9
		end

		local function fn12(arg)
			local tbl25 = {}

			if type(arg.Mutations) == "table" then
				for k, mutation in pairs(arg.Mutations) do
					if type(mutation) == "string" then
						tbl25[mutation] = true
					elseif mutation == true and type(k) == "string" then
						tbl25[k] = true
					end
				end
			end

			if type(arg.BaseMutation) == "string" and arg.BaseMutation ~= "" then
				tbl25[arg.BaseMutation] = true
			end

			return tbl25
		end

		local function fn13(arg)
			if tbl23[tostring(arg.Category)] then
				return true
			end
			local n6 = 0
			local n7 = 0

			if v13 then
				n7 = 1

				if fn10(arg.Category) >= v13 then
					n6 = 1
				end
			end

			if flag or next(tbl22) ~= nil then
				n7 += 1
				local v14 = fn12(arg)

				if flag and next(v14) ~= nil then
					n6 += 1
				else
					local flag3 = false

					for k in pairs(v14) do
						if tbl22[k] then
							flag3 = true
							break
						end
					end

					if flag3 then
						n6 += 1
					end
				end
			end

			if n4 > 0 then
				n7 += 1

				if n4 <= fn11(arg) then
					n6 += 1
				end
			end

			if n7 == 0 then
				return false
			end

			if v12 == tbl10[2] then
				return n6 == n7
			end
			return n6 > 0
		end

		local function fn14(arg)
			return (tbl24[arg] or 0) > os.clock()
		end

		local function fn15(arg)
			local tbl25 = {}
			local v14, v15, v16 = pairs(arg.Inventory or {})
			local n6 = 0

			for k, v17 in v14, v15, v16 do
				if type(v17) == "table" and fn13(v17) then
					n6 += 1

					if v17.IsFavorite ~= true and not fn14(k) then
						table.insert(tbl25, k)
					end
				end
			end

			return tbl25, n6
		end

		local function fn16(arg, arg2, arg3)
			local tbl25 = {}
			local inventory = arg.Inventory or {}
			local v14 = pairs
			local equippedAssets = arg.EquippedAssets or {}

			for _, equippedAsset in v14(equippedAssets) do
				local v15 = inventory[equippedAsset]

				if type(v15) == "table" and not fn14(equippedAsset) then
					if arg2 then
						if v15.IsFavorite ~= true then
							table.insert(tbl25, equippedAsset)
						end
					else
						local flag3 = v15.IsFavorite == true

						if flag3 then
							flag3 = not (arg3 and fn13(v15))
						end

						if flag3 then
							table.insert(tbl25, equippedAsset)
						end
					end
				end
			end

			return tbl25
		end

		local function fn17(arg, arg2)
			local rePetSatchelWriteFavourite = networking:FindFirstChild("RE/PetSatchel/WriteFavourite")
			if not rePetSatchelWriteFavourite or not rePetSatchelWriteFavourite:IsA("RemoteEvent") then
				return
			end

			for i, v14 in ipairs(arg) do
				if not (n2 < i) then
					tbl24[v14] = os.clock() + n3
					pcall(rePetSatchelWriteFavourite.FireServer, rePetSatchelWriteFavourite, v14, arg2)
					task.wait(0.12)
					continue
				end

				break
			end
		end

		local function fn18(arg, arg2)
			if flag2 or #arg == 0 then
				return false
			end
			flag2 = true
			n5 = os.clock() + n

			task.spawn(function()
				pcall(fn17, arg, arg2)
				flag2 = false
				tbl3.Wake()
			end)

			return true
		end

		tbl3.Add(function()
			local v14 = fn8()
			if not v14 then
				return false
			end
			local v15 = tbl4.Toggle(v8, false)
			local v16, v17 = fn15(v14)

			if v11 and type(v11.Set) == "function" then
				local v18 = pairs
				local inventory = v14.Inventory or {}
				local n6 = 0

				for _, v19 in v18(inventory) do
					if type(v19) == "table" and v19.IsFavorite == true then
						n6 += 1
					end
				end

				pcall(v11.Set, v11, string.format("Favorite matches  -  %d pets, %d to mark  |  %d favorited", v17, #v16, n6))
			end

			local v18 = flag2
			local flag3

			if flag2 then
				flag3 = v18
			else
				flag3 = os.clock() < n5
			end

			if flag3 then
				return false
			end

			if v15 and fn18(v16, true) then
				return false
			end

			if tbl4.Toggle(v9, false) then
				if fn18(fn16(v14, true, false), true) then
					return false
				end
			elseif tbl4.Toggle(v10, false) then
				fn18(fn16(v14, false, v15), false)
			end

			return false
		end)

		v11 = v7:CreateText({ Name = "Favorite Preview", Text = "Favorite matches  -  0 pets" })

		v8 = v7:CreateToggle({
			Name = "Auto Favorite Pet",
			Note = "Favorite pets matching the rules below",
			Default = false,
			Callback = function()
				table.clear(tbl24)
				tbl3.Wake()
			end,
		})

		v7:CreateButton({
			Name = "Favorite Pets Now",
			Note = "Favorite matching pets once",
			ButtonText = "Favorite",
			ConfirmText = "Done!",
			SubOf = v8,
			Callback = function()
				local v14 = fn8()

				if v14 then
					fn18(fn15(v14), true)
				end
			end,
		})

		v7:CreateDropdown({
			Name = "Favorite Rule",
			Note = "Pass any check or all checks",
			Options = tbl10,
			Default = tbl10[2],
			SubOf = v8,
			Callback = function(arg)
				if table.find(tbl10, arg) then
					v12 = arg
					tbl3.Wake()
				end
			end,
		})

		v7:CreateDropdown({
			Name = "Favorite Min Rarity",
			Note = "Favorite pets of the chosen rarity and every rarity above it (Off = skip)",
			Options = tbl12,
			Default = "Off",
			SubOf = v8,
			Callback = function(arg)
				v13 = tbl13[arg]
				tbl3.Wake()
			end,
		})

		fn6(v7:CreateMultiDropdown({
			Name = "Favorite Mutations",
			Note = "Mutation check (empty = skip)",
			Options = tbl16,
			Default = {},
			SubOf = v8,
			Callback = function(arg)
				local tbl25 = {}
				local flag3 = false

				if type(arg) == "table" then
					for k, v14 in pairs(arg) do
						k = v14 == true and type(k) == "string" and k

						if k then
							v14 = k
						else
							v14 = type(v14) == "string" and v14
						end

						local v15 = v14 or nil

						if v15 == str then
							flag3 = true
						elseif v15 then
							tbl25[tbl17[v15] or v15] = true
						end
					end
				end

				flag = flag3
				tbl22 = tbl25
				tbl3.Wake()
			end,
		}))

		local tbl25 = {
			["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
			["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
			["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
		}

		local n6 = 0
		local str2 = "M/s"

		local function fn19(arg, arg2)
			if arg ~= nil then
				n6 = math.max(0, math.floor(tonumber(arg) or n6))
			end

			if arg2 ~= nil then
				str2 = tostring(arg2)
			end

			n4 = n6 * (tbl25[str2] or tbl25["M/s"]).Mult
			tbl3.Wake()
		end

		fn5(v7, {
			Name = "Min Favorite Value",
			Note = "Value check (0 = skip)",
			SubOf = v8,
			Legacy = "Favorite Min Value",
			SectionName = "Auto Favorite",
			OnRaw = function(arg)
				fn19(math.floor(arg / 1000), "K/s")
			end,
		})

		fn6(v7:CreateMultiDropdown({
			Name = "Always Favorite Species",
			Note = "Always favorite these species",
			Options = tbl14,
			Default = {},
			SubOf = v8,
			Callback = function(arg)
				local tbl26 = {}

				if type(arg) == "table" then
					for k, v14 in pairs(arg) do
						k = v14 == true and type(k) == "string" and k or type(v14) == "string" and v14
						local v15 = k or nil

						if v15 and tbl15[v15] then
							tbl26[tbl15[v15]] = true
						end
					end
				end

				tbl23 = tbl26
				tbl3.Wake()
			end,
		}))

		v9 = v7:CreateToggle({
			Name = "Auto Favorite Equipped",
			Note = "Keep equipped pets favorited",
			Default = false,
			Callback = function()
				tbl3.Wake()
			end,
		})

		v10 = v7:CreateToggle({
			Name = "Auto Unfavorite Equipped",
			Note = "Unfavorite equipped pets not in the rules",
			Default = false,
			Callback = function()
				tbl3.Wake()
			end,
		})

		v7:CreateButton({
			Name = "Favorite Equipped Now",
			Note = "Favorite all equipped pets once",
			ButtonText = "Favorite",
			ConfirmText = "Done!",
			Callback = function()
				local v14 = fn8()

				if v14 then
					fn18(fn16(v14, true, false), true)
				end
			end,
		})

		v7:CreateButton({
			Name = "Unfavorite Equipped Now",
			Note = "Unfavorite all equipped pets once",
			ButtonText = "Unfavorite",
			ConfirmText = "Done!",
			Callback = function()
				local v14 = fn8()

				if v14 then
					fn18(fn16(v14, false, false), false)
				end
			end,
		})
	end

	local save = tbl.Save

	if type(save) == "table" and type(save.FieldSignal) == "function" then
		for _, v8 in ipairs({ "Inventory", "EquippedAssets" }) do
			local ok, result = pcall(save.FieldSignal, v8)

			if ok and type(result) == "table" and type(result.Connect) == "function" then
				local ok2, result2 = pcall(result.Connect, result, function()
					tbl3.Wake()
				end)

				if ok2 and result2 then
					fn4(function()
						pcall(function()
							result2:Disconnect()
						end)
					end)
				end
			end
		end
	end

	tbl4.MechBoot = function(arg)
		local ok, result = pcall(function()
			return require(ReplicatedStorage.Shared.Util.ScrambleBossHazards)
		end)

		local mech = {
			Handle = nil,
			Row = nil,
			Status = "Idle",
			Shown = nil,
			Busy = false,
			Generation = 0,
			Hazards = {},
			TravelSpeed = 250,
			Radius = 18,
			SwingGap = 0.12,
			Dodge = true,
			TryBall = true,
			Leave = true,
			BaitSpeed = 225,
			Interval = 1800,
			Run = nil,
			SwapTools = true,
			SwapIndex = 1,
			SwapSince = 0,
			MainHold = 0.3,
			SecondHold = 0.4,
			LastSwing = 0,
			Links = {},
		}

		tbl4.Mech = mech

		local function fn8()
			return tbl4.Toggle(mech.Handle, false) == true
		end

		local function fn9()
			return workspace:FindFirstChild("ScrambleArena")
		end

		local function fn10()
			return workspace:FindFirstChild("ScrambleArenaPortal")
		end

		local function fn11()
			return localPlayer:GetAttribute("InScrambleArena") == true
		end

		mech.StealFirst = function()
			local steal = tbl4.Steal
			local movement = tbl4.Movement
			if movement.PlaceWanted == true then
				return "Auto Place Egg goes first"
			end

			if movement.MutationWanted == true then
				return "Scrambled Mutation goes first"
			end
			local flag = tbl4.Toggle(v5, false) == true and steal ~= nil
			local flag2

			if flag then
				flag2 = steal.Wanted == true or steal.Carrying == true or steal.Active == true
			else
				flag2 = flag
			end

			if flag2 then
				return "Auto Steal goes first"
			end
			return nil
		end

		pcall(function()
			local scheduleIntervalSeconds = require(ReplicatedStorage.Shared.Flags.ScrambleBossFlags).ScheduleIntervalSeconds
			local interval = type(scheduleIntervalSeconds) == "table" and tonumber(scheduleIntervalSeconds.Value) or nil

			if interval and interval > 0 then
				mech.Interval = interval
			end
		end)

		mech.Clock = function(arg2)
			local n = math.max(0, math.floor(arg2 + 0.5))
			return string.format("%d:%02d", math.floor(n / 60), n % 60)
		end

		mech.Timer = function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local scrambleArena = workspace:FindFirstChild("ScrambleArena")
			local n = scrambleArena and tonumber(scrambleArena:GetAttribute("SpawnsAt")) or 0

			if workspace:FindFirstChild("ScrambleArenaPortal") then
				if serverTimeNow < n then
					return "Mech portal is open  |  boss spawns in " .. mech.Clock(n - serverTimeNow)
				end
				return "Mech portal is open now"
			end

			local interval = mech.Interval
			return "Next Mech portal in " .. mech.Clock(math.ceil(serverTimeNow / interval) * interval - serverTimeNow)
		end

		local function fn12(arg2)
			if not arg2 then
				return nil
			end
			local hitbox = arg2:FindFirstChild("Hitbox", true)
			if hitbox and hitbox:IsA("BasePart") then
				return hitbox
			end

			for _, descendant in ipairs(arg2:GetDescendants()) do
				if descendant:IsA("TouchTransmitter") and descendant.Parent and descendant.Parent:IsA("BasePart") then
					return descendant.Parent
				end
			end

			return nil
		end

		local function fn13(arg2)
			local v8 = tbl4.Root()
			if not v8 or not arg2 or type(firetouchinterest) ~= "function" then
				return
			end

			pcall(function()
				firetouchinterest(v8, arg2, 0)
				task.wait(0.05)
				firetouchinterest(v8, arg2, 1)
			end)
		end

		local function fn14(arg2, arg3)
			if not mech.Dodge or not ok or type(result) ~= "table" or type(result.Contains) ~= "function" then
				return false
			end

			for k, hazard in pairs(mech.Hazards) do
				local n = tonumber(hazard.At) or 0
				local n2 = tonumber(hazard.Warn) or 0
				if arg3 > n + (tonumber(hazard.Duration) or 0.5) + 1.5 then
					mech.Hazards[k] = nil
					continue
				end

				if arg3 >= n - n2 - 0.1 then
					local ok2, result2 = pcall(result.Contains, hazard, arg2, arg3)
					if ok2 and result2 then
						return true
					end
				end
			end

			return false
		end

		local function fn15()
			local character = localPlayer.Character
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			for _, v8 in ipairs({ character, backpack }) do
				if v8 then
					for _, child in ipairs(v8:GetChildren()) do
						if child:IsA("Tool") and tostring(child:GetAttribute("ItemType")) == "Gear" then
							if string.find(string.lower(tostring(child:GetAttribute("GearName") or "")), "scrambler", 1, true) then
								return child
							end
						end
					end
				end
			end

			return nil
		end

		local function fn16()
			local lastSwing = mech.LastSwing
			if os.clock() - lastSwing < mech.SwingGap then
				return
			end
			mech.LastSwing = os.clock()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local flag = type(tbl4.FindBat) == "function" and tbl4.FindBat() or nil
			local swapTools = mech.SwapTools and fn15() or nil
			local flag2

			if flag and swapTools and flag ~= swapTools then
				local secondHold = mech.SwapIndex == 2 and mech.SecondHold or mech.MainHold
				local swapSince = mech.SwapSince

				if secondHold <= os.clock() - swapSince then
					mech.SwapIndex = mech.SwapIndex == 2 and 1 or 2
					mech.SwapSince = os.clock()
				end

				flag2 = mech.SwapIndex == 2 and swapTools or flag
			else
				flag2 = flag or swapTools
			end

			if not flag2 or not humanoid then
				return
			end

			if flag2.Parent ~= character then
				pcall(function()
					humanoid:EquipTool(flag2)
				end)
			end

			pcall(function()
				flag2:Activate()
			end)
		end

		local function fn17(arg2, arg3)
			local character = localPlayer.Character
			local v8 = tbl4.Root()
			if not character or not v8 then
				return
			end

			if (v8.Position - arg2).Magnitude > 3 then
				pcall(function()
					character:PivotTo(CFrame.lookAt(arg2, Vector3.new(arg3.X, arg2.Y, arg3.Z)))
					v8.AssemblyLinearVelocity = Vector3.zero
				end)
			end
		end

		local function fn18(arg2)
			local mech2 = arg2:FindFirstChild("Mech")
			local hitbox = mech2 and mech2:FindFirstChild("Hitbox")
			if hitbox and hitbox:IsA("BasePart") then
				return hitbox.Position, mech2
			end

			for _, child in ipairs(arg2:GetChildren()) do
				if child:IsA("Model") and child.Name ~= "Ball" and child.Name ~= "LeaveTeleport" and child.Name ~= "Structure" then
					local hitbox2 = child:FindFirstChild("Hitbox")
					if hitbox2 and hitbox2:IsA("BasePart") then
						return hitbox2.Position, child
					end
				end
			end

			return nil, nil
		end

		local function fn19(arg2, arg3)
			local ball = arg2:FindFirstChild("Ball")
			if not ball then
				return false
			end
			local position = ball:GetBoundingBox().Position
			local n = (tonumber(arg2:GetAttribute("FloorY")) or position.Y) + 3
			local n2 = tonumber(arg2:GetAttribute("CoreStage")) or 0

			if arg2:GetAttribute("BallStunned") == true then
				mech.Run = nil
				local vector = Vector3.new(arg3.Position.X - position.X, 0, arg3.Position.Z - position.Z)
				local unit = vector.Magnitude > 1 and vector.Unit or Vector3.new(1, 0, 0)
				fn17(Vector3.new(position.X, n, position.Z) + unit * 10, position)
				fn16()
				mech.Status = string.format("Smashing the core  |  stage %d / 3  |  core %s", n2, tostring(arg2:GetAttribute("CoreHealth") or "?"))
				return true
			end

			local str = tostring(arg2:GetAttribute("BallTarget"))
			local attribute = arg2:GetAttribute("BallCoil")

			if not mech.Run and str == tostring(localPlayer.UserId) and type(attribute) == "string" and attribute ~= "" then
				local coils = arg2:FindFirstChild("Coils")
				coils = coils and coils:FindFirstChild(attribute)
				coils = coils and coils:GetAttribute("Home")

				if typeof(coils) == "Vector3" then
					local vector = Vector3.new(coils.X - position.X, 0, coils.Z - position.Z)

					if vector.Magnitude > 1 then
						local n3 = vector.Unit * 40
						mech.Run = { Goal = Vector3.new(coils.X, n, coils.Z) + n3, Until = os.clock() + 8, Coil = attribute }
					end
				end
			end

			if mech.Run then
				local vector = Vector3.new(mech.Run.Goal.X - arg3.Position.X, 0, mech.Run.Goal.Z - arg3.Position.Z)
				local flag = vector.Magnitude < 4

				if not flag then
					local until_ = mech.Run.Until
					flag = os.clock() > until_
				end

				if flag then
					mech.Run = nil

					pcall(function()
						arg3.AssemblyLinearVelocity = Vector3.new(0, arg3.AssemblyLinearVelocity.Y, 0)
					end)
				else
					local n3 = vector.Unit * mech.BaitSpeed

					pcall(function()
						arg3.AssemblyLinearVelocity = Vector3.new(n3.X, arg3.AssemblyLinearVelocity.Y, n3.Z)
					end)

					mech.Status = string.format("Baiting the ball into %s  |  stage %d / 3", mech.Run.Coil, n2)
				end

				return true
			end

			local vector = Vector3.new(arg3.Position.X - position.X, 0, arg3.Position.Z - position.Z)

			if vector.Magnitude > 18 or vector.Magnitude < 6 then
				local vector2 = vector.Magnitude < 1 and Vector3.new(1, 0, 0) or vector.Unit
				fn17(Vector3.new(position.X, n, position.Z) + vector2 * 12, position)
			end

			mech.Status = string.format("Ball phase, waiting for it to lock on  |  stage %d / 3", n2)
			return true
		end

		local function fn20(arg2, arg3)
			local scrambleHuman = arg2:FindFirstChild("ScrambleHuman")
			if not scrambleHuman then
				return false
			end
			local humanoidRootPart = scrambleHuman:FindFirstChild("HumanoidRootPart") or scrambleHuman.PrimaryPart or scrambleHuman:FindFirstChildWhichIsA("BasePart")
			local position = humanoidRootPart and humanoidRootPart.Position or scrambleHuman:GetPivot().Position
			humanoidRootPart = humanoidRootPart and humanoidRootPart.AssemblyLinearVelocity or Vector3.zero
			local n = position + Vector3.new(humanoidRootPart.X, 0, humanoidRootPart.Z) * 0.15
			local vector = Vector3.new(arg3.Position.X - n.X, 0, arg3.Position.Z - n.Z)
			local vector2 = vector.Magnitude > 1 and vector.Unit * 5 or Vector3.zero
			local n2 = Vector3.new(n.X, arg3.Position.Y, n.Z) + vector2
			local character = localPlayer.Character

			pcall(function()
				character:PivotTo(CFrame.lookAt(n2, Vector3.new(position.X, n2.Y, position.Z)))
			end)

			fn16()
			mech.Status = string.format("Chasing Dr Scramble  |  hits %s / %s", tostring(arg2:GetAttribute("HumanHits") or 0), tostring(arg2:GetAttribute("HumanNeeded") or 3))
			return true
		end

		local function fn21()
			local v8 = fn9()
			local v9 = tbl4.Root()
			local character = localPlayer.Character
			character = character and character:FindFirstChildOfClass("Humanoid")
			if not v8 or not v9 then
				return
			end
			local str = tostring(v8:GetAttribute("Phase"))
			local n = tonumber(v8:GetAttribute("Health")) or 0
			local n2 = tonumber(v8:GetAttribute("MaxHealth")) or 0

			if tostring(v8:GetAttribute("GrabVictim")) == tostring(localPlayer.UserId) and character then
				character.Jump = true
				fn16()
				mech.Status = "Grabbed, breaking free"
				return
			end

			if str == "Ball" and mech.TryBall and fn19(v8, v9) then
				return
			end

			if str == "Human" and fn20(v8, v9) then
				return
			end
			local v10, flag = fn18(v8)

			if not v10 then
				local n3 = (tonumber(v8:GetAttribute("SpawnsAt")) or 0) - workspace:GetServerTimeNow()
				mech.Status = n3 > 0 and "In the arena  |  boss spawns in " .. mech.Clock(n3) or string.format("Phase %s, waiting for the boss", str)
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local n3 = (tonumber(v8:GetAttribute("FloorY")) or v10.Y) + 3
			local v11 = nil
			local v12 = nil

			for i = 0, 15 do
				local n4 = i / 16 * 3.1415926535897931 * 2
				local radius = mech.Radius
				local z = v10.Z
				local radius2 = mech.Radius
				local vector = Vector3.new(v10.X + math.cos(n4) * radius, n3, z + math.sin(n4) * radius2)
				local magnitude = (vector - v9.Position).Magnitude

				if fn14(vector, serverTimeNow) or fn14(vector, serverTimeNow + 0.4) then
					magnitude += 10000
				end

				if not v11 or magnitude < v11 then
					v11 = magnitude
					v12 = vector
				end
			end

			if v12 then
				fn17(v12, v10)
			end

			fn16()
			flag = flag and flag:GetAttribute("Overheated") == true
			mech.Status = string.format("Fighting %s  |  boss %d / %d%s", str, math.floor(n + 0.5), math.floor(n2 + 0.5), flag and "  |  OVERHEAT" or "")
		end

		local function fn22()
			local v8 = fn9()
			local v9 = fn12(v8 and v8:FindFirstChild("LeaveTeleport"))
			if not v9 then
				return
			end
			local character = localPlayer.Character

			pcall(function()
				character:PivotTo(CFrame.new(v9.Position + Vector3.new(0, 3, 0)))
			end)

			task.wait(0.2)
			fn13(v9)
		end

		local function fn23(arg2)
			local v8 = fn10()
			local v9 = fn12(v8)
			if not v8 or not v9 then
				return false
			end
			local flag = type(tbl4.StealHome) == "function" and tbl4.StealHome() or nil

			if flag and tbl4.InsideBase() then
				local flag2 = mech.Respawned == true
				local n = flag + Vector3.new(0, 3, 0)
				local travelSpeed = flag2 and math.min(mech.TravelSpeed, 300) or mech.TravelSpeed
				local now = os.clock()
				local exitTo = nil

				while true do
					if not (os.clock() - now < 20) then
						exitTo = 1
						break
					else
						if arg2 ~= mech.Generation or not fn8() or fn11() or mech.StealFirst() then
							exitTo = 2
							break
						else
							local v10 = tbl4.Root()

							if v10 then
								local n2 = n - v10.Position

								if n2.Magnitude <= 4 then
									exitTo = 1
									break
								else
									mech.Status = flag2 and "Respawned, going out through the safe zone" or "Leaving the base through the safe zone"
									local magnitude = n2.Magnitude
									local n3 = math.min(travelSpeed * RunService.Heartbeat:Wait(), magnitude)

									pcall(function()
										local rotation = v10.CFrame.Rotation
										v10.CFrame = CFrame.new(v10.Position + n2.Unit * n3) * rotation
										v10.AssemblyLinearVelocity = Vector3.zero
									end)

									continue
								end
							end
						end

						break
					end
				end

				if exitTo ~= 1 then
					if exitTo == 2 then
						return false
					end
					return false
				end

				if flag2 then
					mech.Status = "Respawned, resting in the safe zone"
					local n2 = 0

					while n2 < 0.75 do
						local v10 = tbl4.Root()

						if v10 then
							pcall(function()
								v10.AssemblyLinearVelocity = Vector3.zero
							end)
						end

						n2 += RunService.Heartbeat:Wait()
					end
				end
			end

			mech.Respawned = false
			local position = v9.Position
			local now = os.clock()
			local exitTo2 = nil
			local v10

			while true do
				if not (os.clock() - now < 60) then
					exitTo2 = 1
					break
				else
					if arg2 ~= mech.Generation or not fn8() or fn11() or mech.StealFirst() then
						exitTo2 = 1
						break
					else
						v10 = tbl4.Root()

						if not v10 then
							exitTo2 = 2
							break
						else
							local vector = Vector3.new(position.X - v10.Position.X, 0, position.Z - v10.Position.Z)

							if not (vector.Magnitude <= 14) then
								local n = vector.Unit * math.min(mech.TravelSpeed, vector.Magnitude / 0.05)
								mech.Status = string.format("Going to the Mech portal, %d studs", math.floor(vector.Magnitude + 0.5))

								pcall(function()
									v10.AssemblyLinearVelocity = Vector3.new(n.X, v10.AssemblyLinearVelocity.Y, n.Z)
								end)

								RunService.Heartbeat:Wait()
								continue
							end
						end
					end

					break
				end
			end

			if exitTo2 ~= 1 then
				if exitTo2 == 2 then
					return false
				end

				pcall(function()
					v10.AssemblyLinearVelocity = Vector3.zero
				end)

				fn13(v9)
				task.wait(0.4)

				if not fn11() then
					pcall(function()
						local rfScrambleBossEnterArena = networking:FindFirstChild("RF/ScrambleBoss/EnterArena")

						if rfScrambleBossEnterArena then
							rfScrambleBossEnterArena:InvokeServer()
						end
					end)
				end
			end

			local now2 = os.clock()

			while not fn11() and os.clock() - now2 < 5 do
				task.wait(0.1)
			end

			return fn11()
		end

		local function fn24()
			mech.Busy = true
			mech.Generation = mech.Generation + 1
			local generation = mech.Generation
			tbl4.Shield("mech", true)

			pcall(function()
				if tbl4.Treadmill and tbl4.Treadmill.Riding or type(tbl4.OnBelt) == "function" and tbl4.OnBelt() then
					tbl4.ExitBelt()
				end
			end)

			if not fn11() and not mech.StealFirst() then
				pcall(fn23, generation)
			end

			while generation == mech.Generation and fn8() and fn11() and not mech.StealFirst() do
				local str = fn9()
				str = str and tostring(str:GetAttribute("Phase")) or ""

				if str == "Defeated" or str == "Final" or str == "Ended" or str == "Won" then
					mech.Status = "Dr Scramble defeated, going back home"
					mech.DefeatedAt = mech.DefeatedAt or os.clock()
					local leave = mech.Leave

					if leave then
						local defeatedAt = mech.DefeatedAt
						leave = os.clock() - defeatedAt > 15
					end

					if leave then
						pcall(fn22)
						task.wait(2)
					else
						task.wait(0.3)
					end
				else
					pcall(fn21)
					RunService.Heartbeat:Wait()
				end
			end

			if fn11() and mech.StealFirst() then
				mech.Status = tostring(mech.StealFirst()) .. ", leaving the arena"
				pcall(fn22)
				local n = 0

				while fn11() and n < 5 do
					n += task.wait(0.2)
				end
			end

			mech.DefeatedAt = nil
			mech.Run = nil
			tbl4.Shield("mech", false)
			tbl4.ReleaseMovement("mech")
			mech.Busy = false
			tbl3.Wake()
		end

		pcall(function()
			local reScrambleBossHazard = networking:FindFirstChild("RE/ScrambleBoss/Hazard")

			if reScrambleBossHazard and reScrambleBossHazard:IsA("RemoteEvent") then
				table.insert(mech.Links, reScrambleBossHazard.OnClientEvent:Connect(function(arg2)
					if type(arg2) == "table" then
						mech.Hazards[arg2.Id or #mech.Hazards + 1] = arg2
					end
				end))
			end
		end)

		table.insert(mech.Links, localPlayer.CharacterAdded:Connect(function()
			mech.Respawned = true
		end))

		mech.Row = arg:CreateText({ Name = "Mech Status", Text = "Idle" })

		mech.Handle = arg:CreateToggle({
			Name = "Auto Mech Boss",
			Default = false,
			Callback = function()
				if not fn8() then
					mech.Generation = mech.Generation + 1
				end

				tbl3.Wake()
			end,
		})

		for _, v8 in ipairs({
			{ "Mech Tween Speed", 100, 1000, 250, 10, "studs/s", "TravelSpeed" },
			{ "Main Weapon Hold", 0, 1.5, 0.3, 0.01, "s", "MainHold" },
			{ "Scrambler Hold", 0, 1.5, 0.4, 0.01, "s", "SecondHold" },
		}) do
			arg:CreateSlider({
				Name = v8[1],
				Min = v8[2],
				Max = v8[3],
				Default = v8[4],
				Increment = v8[5],
				Unit = v8[6],
				SubOf = mech.Handle,
				Callback = function(arg2)
					mech[v8[7]] = math.clamp(tonumber(arg2) or v8[4], v8[2], v8[3])
				end,
			})
		end

		for _, v8 in ipairs({
			{ "Swap Two Weapons", "SwapTools" },
			{ "Dodge Attacks", "Dodge" },
			{ "Ball And Core Phase", "TryBall" },
			{ "Leave After Fight", "Leave" },
		}) do
			arg:CreateToggle({
				Name = v8[1],
				Default = true,
				SubOf = mech.Handle,
				Callback = function(arg2)
					mech[v8[2]] = arg2 ~= false
				end,
			})
		end

		tbl3.Add(function()
			local row = mech.Row

			if not fn8() then
				mech.Status = "Off  |  " .. mech.Timer()
			elseif not mech.Busy then
				if fn11() then
					mech.Status = "In the arena"
				else
					mech.Status = mech.Timer()
				end
			end

			if row and mech.Shown ~= mech.Status and type(row.Set) == "function" then
				mech.Shown = mech.Status
				pcall(row.Set, row, mech.Status)
			end

			local invisibilityHandle = tbl4.InvisibilityHandle
			local flag = invisibilityHandle ~= nil and tbl4.Toggle(invisibilityHandle, false)

			if fn8() and (mech.Busy or fn11() or fn10()) then
				mech.InvisResumeAt = nil

				if not tbl4.InvisMech then
					tbl4.InvisMech = true

					if flag then
						tbl4.Notify("Invisibility", "Invisibility is paused for the Mech boss and comes back after it.")
					end
				end
			elseif tbl4.InvisMech and not mech.Busy then
				mech.InvisResumeAt = mech.InvisResumeAt or os.clock() + 5

				if mech.InvisResumeAt <= os.clock() then
					mech.InvisResumeAt = nil
					tbl4.InvisMech = false

					if flag then
						tbl4.Notify("Invisibility", "The Mech boss is over, Invisibility is back on.")
					end
				end
			end

			if not fn8() or mech.Busy then
				return true
			end

			if fn11() or fn10() then
				local v8 = mech.StealFirst()
				if v8 then
					mech.Status = v8 .. "  |  " .. mech.Timer()
					return true
				end
				local character = localPlayer.Character
				if character and character:GetAttribute("InvisApplied") == true then
					mech.Status = "Leaving Invisibility for the boss"
					return true
				end

				if not tbl4.ClaimMovement("mech") then
					mech.Status = "Waiting for " .. tostring(tbl4.Movement.Owner or "movement")
					return true
				end
				task.spawn(fn24)
				return true
			end

			return true
		end)

		fn4(function()
			tbl4.InvisMech = false
			mech.Generation = mech.Generation + 1

			for _, link in ipairs(mech.Links) do
				pcall(function()
					link:Disconnect()
				end)
			end

			pcall(tbl4.Shield, "mech", false)
			pcall(tbl4.ReleaseMovement, "mech")
		end)
	end

	tbl4.MechBoot(v6)

	do
		local n = 5
		local n2 = 5
		local v8 = nil
		local v9 = nil
		local flag = false
		local n3 = 0
		local n4 = 0
		local n5 = 0
		local v10 = nil
		local n6 = 0
		local str = ""
		local flag2 = false

		local function fn8(arg, arg2)
			local v11 = networking:FindFirstChild(arg)
			if not v11 or not v11:IsA("RemoteFunction") then
				return false, nil, nil
			end

			if arg2 == nil then
				return pcall(v11.InvokeServer, v11)
			end
			return pcall(v11.InvokeServer, v11, arg2)
		end

		local function fn9()
			local save2 = tbl.Save
			if type(save2) ~= "table" or type(save2.Get) ~= "function" then
				return nil
			end
			local ok, result = pcall(save2.Get)
			return ok and type(result) == "table" and result or nil
		end

		local function fn10(arg)
			local directory = tbl.Assets and tbl.Assets.Directory
			local flag3 = type(directory) == "table" and directory[tostring(arg)] or nil
			return tostring(type(flag3) == "table" and flag3.DisplayName or arg)
		end

		local function fn11(arg)
			if not arg and type(v10) == "table" and os.clock() < n5 then
				return v10
			end
			n5 = os.clock() + n2
			local AskState, v11 = fn8("RF/ScrambleTradeIn/AskState")

			if AskState and type(v11) == "table" then
				v10 = v11
				n6 = os.clock()
			end

			return v10
		end

		local function fn12(arg, arg2)
			local requirements = type(arg) == "table" and arg.Requirements or nil
			if type(requirements) ~= "table" or #requirements == 0 then
				return nil, "No active recipe"
			end
			local tbl10 = {}

			if type(arg2.EquippedAssets) == "table" then
				for _, equippedAsset in pairs(arg2.EquippedAssets) do
					tbl10[equippedAsset] = true
				end
			end

			local tbl11 = {}

			for _, requirement in ipairs(requirements) do
				tbl11[tostring(requirement)] = {}
			end

			local v11 = pairs
			local inventory = arg2.Inventory or {}

			for k, v12 in v11(inventory) do
				local flag3 = type(v12) == "table" and tbl11[tostring(v12.Category)] or nil

				if flag3 and v12.InFuse ~= true and v12.IsFavorite ~= true and not tbl10[k] then
					local flag4 = type(v12.Mutations) == "table" and next(v12.Mutations) ~= nil
					table.insert(flag3, { Uid = k, Scale = tonumber(v12.Scale) or 0, Mutated = flag4 })
				end
			end

			for _, v12 in pairs(tbl11) do
				table.sort(v12, function(arg3, arg4)
					if arg3.Mutated ~= arg4.Mutated then
						return arg4.Mutated
					end
					return arg3.Scale < arg4.Scale
				end)
			end

			local tbl12 = {}
			local tbl13 = {}

			for _, requirement in ipairs(requirements) do
				local tbl14 = tbl11[tostring(requirement)]
				local v12 = ipairs
				tbl14 = tbl14 or {}
				local v13 = nil

				for _, v14 in v12(tbl14) do
					if not tbl13[v14.Uid] then
						v13 = v14
						break
					else
						v13 = nil
					end
				end

				if not v13 then
					return nil, "Missing " .. fn10(requirement)
				end
				tbl13[v13.Uid] = true
				table.insert(tbl12, v13.Uid)
			end

			return tbl12
		end

		local function fn13()
			local v11 = v10
			if type(v11) ~= "table" then
				return "Lab status unknown"
			end

			if v11.Unlocked ~= true then
				return "Lab is locked on this account"
			end
			local tbl10 = {}
			local v12 = ipairs
			local requirements = v11.Requirements or {}

			for _, requirement in v12(requirements) do
				table.insert(tbl10, fn10(requirement))
			end

			local n7 = (tonumber(v11.SecondsUntilRotation) or 0) - os.clock() - n6

			if n7 < 0 then
				n7 = 0
			end

			local str2 = string.format("%s  -  needs %s  -  pity %s/%s  -  free rerolls %s  -  rotates in %d:%02d", tostring(v11.BannerDisplayName or v11.BannerId or "Lab"), #tbl10 > 0 and table.concat(tbl10, ", ") or "unknown", tostring(v11.PityCount or 0), tostring(v11.PityThreshold or 0), tostring(v11.FreeRefreshesRemaining or 0), math.floor(n7 / 60), math.floor(n7 % 60))

			if str ~= "" then
				str2 ..= "  -  " .. str
			end

			return str2
		end

		local function fn14(arg)
			local v11 = fn11(true)
			if type(v11) ~= "table" or v11.Unlocked ~= true then
				return
			end

			if v11.PendingReward ~= nil and v11.PendingReward ~= false then
				local AskFinishReveal, v12 = fn8("RF/ScrambleTradeIn/AskFinishReveal")
				str = AskFinishReveal and v12 ~= false and "Reward claimed" or "Reward claim failed"
				n5 = 0
				return
			end

			local v12 = fn9()
			if not v12 then
				return
			end
			local v13, v14 = fn12(v11, v12)

			if not v13 then
				str = v14 or "Recipe not ready"
				local flag3 = arg == n3 and tbl4.Toggle(v9, false)

				if flag3 then
					flag3 = (tonumber(v11.FreeRefreshesRemaining) or 0) > 0
				end

				if flag3 then
					local AskRefresh, v15, v16 = fn8("RF/ScrambleTradeIn/AskRefresh")

					if AskRefresh and v15 ~= false then
						str = "Recipe rerolled"
					else
						str = tostring(v16 or "Reroll rejected")
					end

					n5 = 0
				end

				return
			end

			if not tbl4.Toggle(v8, false) then
				str = "Ready to trade in"
				return
			end

			if arg ~= n3 then
				return
			end
			local AskTradeIn, v15, v16 = fn8("RF/ScrambleTradeIn/AskTradeIn", v13)

			if AskTradeIn and v15 ~= false then
				str = "Trade-in sent"
			else
				str = tostring(v16 or "Trade rejected")
			end

			n5 = 0
		end

		local v11 = v6:CreateText({ Name = "Lab Status", Text = "Loading Lab data..." })

		v8 = v6:CreateToggle({
			Name = "Auto Lab Trade-In",
			Default = false,
			Callback = function()
				n3 += 1
				str = ""
				n4 = 0
				n5 = 0
				tbl3.Wake()
			end,
		})

		v9 = v6:CreateToggle({
			Name = "Auto Reroll Lab Recipe",
			Default = false,
			Callback = function()
				n3 += 1
				str = ""
				n4 = 0
				n5 = 0
				tbl3.Wake()
			end,
		})

		for _, v12 in ipairs({
			{ Key = "Place", Name = "Place Lab Recipe Eggs" },
			{ Key = "Hatch", Name = "Hatch Lab Recipe Eggs" },
		}) do
			local key = v12.Key

			tbl4.Rift.Handles[key] = v6:CreateToggle({
				Name = v12.Name,
				Default = false,
				Callback = function()
					tbl4.Rift.Next = 0
					local v13 = tbl4.Rift.Restart[key]

					if type(v13) == "function" then
						v13()
					end

					tbl3.Wake()
				end,
			})
		end

		tbl3.Add(function()
			local v12 = tbl4.Toggle(v8, false)
			local v13 = tbl4.Toggle(v9, false)
			local n7 = (v12 or v13) and 5 or 30

			if not flag2 and (v10 == nil or n5 == 0 or os.clock() - n6 >= n7) then
				flag2 = true

				task.spawn(function()
					pcall(fn11, true)
					flag2 = false
				end)
			end

			if v11 and type(v11.Set) == "function" then
				pcall(v11.Set, v11, fn13())
			end

			local flag3 = flag

			if not flag then
				flag3 = not (v12 or v13)
			end

			if flag3 or os.clock() < n4 then
				return false
			end
			flag = true
			n4 = os.clock() + n
			local v14 = n3

			task.spawn(function()
				pcall(fn14, v14)
				flag = false
				tbl3.Wake()
			end)

			return false
		end)
	end

	local n
	n = 6
	local n2
	n2 = 1.5
	local n3
	n3 = 400
	local tbl10, tbl11, tbl12, tbl13, n4, snapshot, n5, flag, n6, n7
	local str, str2, tbl14, n8, flag2, tbl15, tbl16, flag3, n9, v8
	local fn8, fn9, fn10, fn11, fn12, fn13, fn14, fn15, fn16, fn17
	local fn18, fn19, fn20, fn21, fn22, fn23, fn24, fn25, fn26, fn27
	local fn28, fn29, fn30, fn31

	do
		local vector = Vector3.new(2120, -120, -355)
		tbl10 = { "LostPart1", "LostPart2" }

		tbl11 = {
			{ Label = "Experiment #001", Id = "LimitedTimeExperimentPet" },
			{ Label = "Nibbles #013", Id = "Nibbles013" },
			{ Label = "Scrambled Mutation", Id = "MutationConsumable" },
			{ Label = "2x Cash Booster", Id = "CashBooster" },
			{ Label = "1.25x Speed", Id = "SpeedBoost" },
			{ Label = "2x Treadmill Booster", Id = "TreadmillBooster" },
		}

		local tbl17 = {}

		for _, v9 in ipairs(tbl11) do
			tbl17[#tbl17 + 1] = v9.Label
		end

		tbl12 = {}
		tbl13 = {}
		n4 = 0
		local tbl18 = { ["Experiment #001"] = true, ["Nibbles #013"] = true, ["Scrambled Mutation"] = true }
		snapshot = nil
		n5 = -math.huge
		flag = false
		n6 = 0
		n7 = 0
		str = ""
		str2 = ""
		tbl14 = { Tool = nil, EquipAt = 0 }
		n8 = 16
		flag2 = false
		tbl15 = { Index = 1, Since = 0, Tool = nil }
		tbl16 = { Latch = false, Ended = false }
		flag3 = false
		n9 = 0
		v8 = nil

		local function fn32()
			local packages = ReplicatedStorage:FindFirstChild("Packages")
			packages = packages and packages:FindFirstChild("Networking")
			packages = packages and packages:FindFirstChild("RF/Scramble/Request")
			if packages and packages:IsA("RemoteFunction") then
				return packages
			end
			return nil
		end

		fn8 = function(arg, ...)
			local v9 = fn32()
			if not v9 then
				return nil
			end
			local v10 = table.pack(...)

			local ok, result = pcall(function()
				return v9:InvokeServer(arg, table.unpack(v10, 1, v10.n))
			end)

			if not ok or type(result) ~= "table" then
				return nil
			end

			if type(result.Snapshot) == "table" then
				snapshot = result.Snapshot
				n5 = os.clock()
			elseif arg == "Snapshot" and type(result.State) == "table" then
				snapshot = result
				n5 = os.clock()
			end

			return result
		end

		fn9 = function(arg)
			if arg or snapshot == nil or os.clock() - n5 >= n then
				fn8("Snapshot")
			end

			return snapshot
		end

		fn10 = function()
			local v9 = snapshot
			return type(v9) == "table" and type(v9.State) == "table" and v9.State or nil
		end

		fn11 = function()
			local v9 = snapshot
			if type(v9) ~= "table" or v9.Enabled == false or type(v9.State) ~= "table" then
				return false
			end
			local num = tonumber(v9.EventEndsAt)
			return num == nil or workspace:GetServerTimeNow() < num
		end

		fn12 = function()
			local v9 = snapshot
			local window = type(v9) == "table" and v9.Window or nil
			if type(window) ~= "table" then
				return false, nil
			end
			local serverTimeNow = workspace:GetServerTimeNow()
			local num = tonumber(window.StartsAt)
			local num2 = tonumber(window.EndsAt)
			local flag4 = window.Active == true
			local flag5

			if flag4 then
				flag5 = flag4
			else
				flag5 = num and num2 and serverTimeNow >= num and serverTimeNow < num2
			end

			if flag5 then
				return true, num2 and math.max(0, num2 - serverTimeNow) or nil
			end
			local num3 = tonumber(window.NextAt)
			return false, num3 and math.max(0, num3 - serverTimeNow) or nil
		end

		fn13 = function(arg, arg2)
			local lostParts = type(arg) == "table" and arg.LostParts or nil
			if type(lostParts) ~= "table" then
				return false
			end

			if lostParts[arg2] then
				return true
			end

			for _, lostPart in pairs(lostParts) do
				if lostPart == arg2 then
					return true
				end
			end

			return false
		end

		fn14 = function(arg)
			local n10 = 0

			for _, v9 in ipairs(tbl10) do
				if fn13(arg, v9) then
					n10 += 1
				end
			end

			return n10
		end

		local function fn33(arg)
			local n10 = math.max(0, math.floor(tonumber(arg) or 0))
			if n10 >= 3600 then
				return string.format("%dh %dm", n10 // 3600, n10 % 3600 // 60)
			end
			return string.format("%dm %ds", n10 // 60, n10 % 60)
		end

		fn15 = function()
			local v9 = fn10()
			if not v9 then
				return "Dr Scramble event is not running"
			end

			if not fn11() then
				return "Dr Scramble event has ended"
			end
			local v10, v11 = fn12()
			local str3

			if v10 then
				str3 = "Outbreak live " .. fn33(v11 or 0)
			else
				str3 = v10
			end

			str3 = str3 or v11 and "Outbreak in " .. fn33(v11) or "Outbreak soon"
			local str4 = v9.Completed == true and "Vault claimed"

			if not str4 then
				str4 = string.format("Lost %d/2  Drone %d/3", fn14(v9), math.min(3, tonumber(v9.DroneParts) or 0))
			end

			if v10 then
				local n10 = 0

				for _, v12 in pairs(tbl12) do
					if (tonumber(v12.Health) or 0) > 0 then
						n10 += 1
					end
				end

				str3 ..= string.format("  %d drones", n10)
			end

			local str5 = string.format("Samples %d  -  %s  -  %s", tonumber(v9.Samples) or 0, str4, str3)

			if str2 ~= "" and tbl4.Toggle(nil, false) then
				str5 ..= "  -  " .. str2
			end

			if str ~= "" then
				str5 ..= "  -  " .. str
			end

			return str5
		end

		fn16 = function()
			return tbl4.Root()
		end

		fn17 = function(arg, arg2, arg3, arg4)
			local n10 = arg4 or 400
			local v9 = fn16()
			if not v9 then
				return false
			end
			arg3 = arg3 or 1
			if (v9.Position - arg).Magnitude <= arg3 then
				return true
			end
			tbl4.Shield("scramble", true)
			local n11 = os.clock() + 6

			while not tbl4.Swapped() and os.clock() < n11 and not arg2() do
				str = "Waiting for the character to settle"
				RunService.Heartbeat:Wait()
			end

			local v10 = fn16() or v9
			local character = localPlayer.Character
			tbl4.Driving = tbl4.Driving + 1
			local position = v10.Position
			local flag4 = nil
			local n12 = (arg - position).Magnitude / n10 + 3
			local n13 = 0

			local connection = RunService.Heartbeat:Connect(function(deltaTime)
				if flag4 ~= nil or tbl4.AntiGuard.Busy then
					return
				end
				n13 += deltaTime
				local v11 = fn16()
				if not v11 or arg2() or n13 > n12 or localPlayer.Character ~= character then
					flag4 = false
					return
				end

				if (v11.Position - position).Magnitude > 8 then
					position = v11.Position
				end

				local n14 = arg - position
				local n15 = n10 * deltaTime
				local flag5 = n14.Magnitude <= math.max(n15, arg3)
				position = flag5 and arg or position + n14.Unit * n15
				local vector2 = Vector3.new(n14.X, 0, n14.Z)
				local cframe = vector2.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector2.Unit) or v11.CFrame.Rotation

				pcall(function()
					v11.CFrame = CFrame.new(position) * cframe
					v11.AssemblyLinearVelocity = Vector3.zero
					v11.AssemblyAngularVelocity = Vector3.zero
				end)

				if flag5 then
					flag4 = true
				end
			end)

			while flag4 == nil do
				RunService.Heartbeat:Wait()
			end

			connection:Disconnect()
			tbl4.Driving = math.max(0, tbl4.Driving - 1)
			tbl4.Shield("scramble", false)
			return flag4
		end

		fn18 = function(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("ProximityPrompt") then
				return false
			end

			local ok = pcall(function()
				arg:InputHoldBegin()
				local n10 = tonumber(type(tbl4.PromptHold) == "function" and tbl4.PromptHold(arg) or arg.HoldDuration) or 0

				if n10 > 0 then
					task.wait(n10 + 0.2)
				end

				arg:InputHoldEnd()
			end)

			if not ok and type(fireproximityprompt) == "function" then
				ok = pcall(fireproximityprompt, arg)
			end

			return ok
		end

		local function fn34()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			local secretZones = world and world:FindFirstChild("SecretZones")
			return secretZones and secretZones:FindFirstChild("Cave") or nil
		end

		fn19 = function(arg)
			local v9 = fn34()
			local teleporter = v9 and v9:FindFirstChild("Teleporter")
			teleporter = teleporter and teleporter:FindFirstChild(arg)
			teleporter = teleporter and teleporter:FindFirstChild("SecretZonePrompt", true)
			return teleporter and teleporter:IsA("ProximityPrompt") and teleporter or nil
		end

		fn20 = function(arg, arg2)
			arg = arg and arg.Parent
			if arg and arg:IsA("Attachment") then
				return arg.WorldPosition
			end

			if arg and arg:IsA("BasePart") then
				return arg.Position
			end
			return arg2
		end

		fn21 = function()
			local v9 = fn16()
			if not v9 then
				return false
			end
			local position = v9.Position
			local vector2 = Vector3.new(position.X - vector.X, 0, position.Z - vector.Z)
			return position.Y < -60 and vector2.Magnitude < 160
		end

		local function fn35()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Areas")
			world = world and world:FindFirstChild("SeparationLine")
			return world and world:IsA("BasePart") and world.Position.X or 552
		end

		fn22 = function(arg)
			if not arg then
				arg = fn16()
				arg = arg and arg.Position
			end

			return arg ~= nil and arg.X < fn35()
		end

		local connection = localPlayer.CharacterAdded:Connect(function()
			tbl4.ScrambleRespawned = true
			tbl14.Tool = nil
			tbl14.EquipAt = 0
		end)

		fn4(function()
			pcall(function()
				connection:Disconnect()
			end)
		end)

		fn23 = function(arg, arg2)
			if not fn22() then
				tbl4.ScrambleRespawned = false
				return true
			end

			if arg2 and fn22(arg2) then
				return true
			end

			local function fn36()
				str = "Respawned, resting in the safe zone"
				local n10 = os.clock() + 0.75

				while os.clock() < n10 do
					if arg() then
						return false
					end
					task.wait(0.1)
				end

				tbl4.ScrambleRespawned = false
				return true
			end

			local flag4 = type(tbl4.StealHome) == "function" and tbl4.StealHome() or nil
			if not flag4 then
				tbl4.ScrambleRespawned = false
				return true
			end
			local flag5 = tbl4.ScrambleRespawned == true

			if tbl4.DistanceTo(flag4) <= 12 then
				if flag5 then
					return (fn36())
				end
				return true
			end

			str = flag5 and "Respawned, easing out through the safe zone" or "Leaving the base through the safe zone"
			local v9 = fn17
			local v10 = v9(flag4 + Vector3.new(0, 3, 0), arg, 3, flag5 and math.min(400, 300) or nil)
			if v10 and flag5 then
				return (fn36())
			end
			return v10
		end

		local function fn36(arg, arg2, arg3)
			local v9 = fn16()
			if not v9 then
				return false
			end
			tbl4.Shield("scramblefly", true)
			local position = v9.Position
			local flag4 = true

			if Vector3.new(arg.X - position.X, 0, arg.Z - position.Z).Magnitude > 250 then
				local n10 = math.max(position.Y, arg.Y, 98)
				flag4 = fn17(Vector3.new(position.X, n10, position.Z), arg2, 2) and fn17(Vector3.new(arg.X, n10, arg.Z), arg2, 2)
			end

			flag4 = flag4 and fn17(arg, arg2, math.min(arg3, 2))
			tbl4.Shield("scramblefly", false)
			return flag4
		end

		local function fn37()
			local flag4 = type(tbl4.StealHome) == "function" and tbl4.StealHome() or nil
			return flag4 and flag4 + Vector3.new(0, 3, 0) or nil
		end

		fn24 = function(arg, arg2, arg3)
			local n10 = arg3 or 6
			if tbl4.DistanceTo(arg) <= n10 then
				return true
			end
			local v9 = fn22()
			local v10 = fn22(arg)

			if v9 and not v10 then
				if not fn23(arg2, arg) then
					return false
				end
			elseif v10 and not v9 then
				local v11 = fn37()

				if v11 and (v11 - arg).Magnitude > 12 and tbl4.DistanceTo(v11) > 12 then
					str = "Coming back through the safe zone"
					if not fn36(v11, arg2, 3) then
						return false
					end
				end
			end

			return fn36(arg, arg2, n10)
		end

		fn25 = function(arg)
			if fn22() or arg() or tbl4.IsNight() or tbl4.WallSealed() then
				return
			end
			local v9 = fn37()

			if v9 then
				str = "Coming back through the safe zone"
				fn24(v9, arg, 4)
			end
		end

		local function fn38(arg)
			if fn21() then
				return true
			end
			local Entry = fn19("Entry")
			local v9 = fn20(Entry, Vector3.new(2125.7, 73.1, -295.4))
			str = "Flying to the Secret Cave"
			if not fn24(v9, arg, 6) then
				return false
			end

			for i = 1, 4 do
				if arg() then
					return false
				end
				str = "Entering the Secret Cave"
				fn18(Entry or fn19("Entry"))
				local n10 = os.clock() + 1.5

				while os.clock() < n10 and not fn21() do
					RunService.Heartbeat:Wait()
				end

				if fn21() then
					return true
				end
			end

			str = "Cave door missed, flying in"
			local quest = type(snapshot) == "table" and snapshot.Quest or nil
			local position = type(quest) == "table" and type(quest.EscapedExperiment) == "table" and quest.EscapedExperiment.Position or nil

			if typeof(position) == "Vector3" then
				pcall(tbl4.FlyTo, position, arg, "scramble")
			end

			return fn21()
		end

		local function fn39(arg)
			local quest = type(snapshot) == "table" and snapshot.Quest or nil
			local flag4 = type(quest) == "table" and quest[arg] or nil
			local position = type(flag4) == "table" and flag4.Position or nil
			if typeof(position) == "Vector3" then
				return position
			end
			local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
			drScrambleEvent = drScrambleEvent and drScrambleEvent:FindFirstChild(arg)
			if drScrambleEvent and drScrambleEvent:IsA("Model") then
				return drScrambleEvent:GetPivot().Position
			end
			return nil
		end

		local function fn40(arg)
			local v9 = snapshot
			local interactions = type(v9) == "table" and v9.Interactions or nil
			return math.max(4, (type(interactions) == "table" and tonumber(interactions[arg]) or 12) - 4)
		end

		fn26 = function(arg)
			local v9 = fn10()
			if not v9 or v9.Discovered == true then
				return true
			end
			local EscapedExperiment = fn39("EscapedExperiment")
			if not EscapedExperiment or not fn38(arg) then
				return false
			end
			str = "Talking to the Escaped Experiment"
			if not fn17(EscapedExperiment, arg, fn40("NpcRadius")) then
				return false
			end
			local Discover = fn8("Discover")
			fn9(true)
			return Discover ~= nil and fn10() ~= nil and fn10().Discovered == true
		end

		fn27 = function(arg)
			local v9 = fn10()
			local flag4 = not v9 or v9.Completed == true
			local flag5

			if flag4 then
				flag5 = flag4
			else
				local n10 = #tbl10
				flag5 = fn14(v9) >= n10
			end

			if flag5 then
				return
			end

			if v9.Discovered ~= true and not fn26(arg) then
				return
			end

			for _, v10 in ipairs(tbl10) do
				if arg() then
					return
				end

				if not fn13(fn10(), v10) then
					local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
					local hitbox = drScrambleEvent and drScrambleEvent:FindFirstChild(v10)
					hitbox = hitbox and hitbox:FindFirstChild("Hitbox", true)
					local claimLostPart = hitbox and hitbox:FindFirstChild("ClaimLostPart", true)
					local position = hitbox and hitbox:IsA("BasePart") and hitbox.Position or fn39(v10)

					if position then
						str = "Flying to " .. (v10 == "LostPart1" and "Lost Part 1" or "Lost Part 2")

						if fn24(position + Vector3.new(0, 2, 0), arg, 3) then
							str = "Collecting the lost part"
							local n10 = position + Vector3.new(0, 2.5, 0)
							local character = localPlayer.Character
							tbl4.Shield("scramble", true)
							tbl4.Driving = tbl4.Driving + 1

							local connection2 = RunService.Heartbeat:Connect(function()
								local v11 = tbl4.Root()
								if not v11 or v11.Parent ~= character or tbl4.AntiGuard.Busy or tbl4.Movement.Owner ~= "scramble" then
									return
								end

								pcall(function()
									local rotation = v11.CFrame.Rotation
									v11.CFrame = CFrame.new(n10) * rotation
									v11.AssemblyLinearVelocity = Vector3.zero
									v11.AssemblyAngularVelocity = Vector3.zero
								end)
							end)

							for i = 1, 4 do
								if not arg() then
									claimLostPart = claimLostPart or hitbox and hitbox:FindFirstChild("ClaimLostPart", true)
									fn18(claimLostPart)
									task.wait(0.6)
									fn9(true)
									if not fn13(fn10(), v10) then
										continue
									end
								end

								break
							end

							connection2:Disconnect()
							tbl4.Driving = math.max(0, tbl4.Driving - 1)
							tbl4.Shield("scramble", false)
							if arg() then
								return
							end
							continue
						end
					end
				end
			end
		end

		fn28 = function(arg)
			local v9 = fn10()
			if not v9 or v9.Completed == true then
				return
			end
			local num = tonumber(v9.TotalParts)

			if not num then
				num = fn14(v9) + (tonumber(v9.DroneParts) or 0)
			end

			if num < 5 then
				return
			end
			local ExperimentVault = fn39("ExperimentVault")
			if not ExperimentVault or not fn38(arg) then
				return
			end
			str = "Opening the Experiment Vault"
			if not fn17(ExperimentVault, arg, fn40("VaultRadius")) then
				return
			end
			fn8("Vault")
			fn9(true)
			local v10 = fn10()

			if v10 and v10.Completed == true then
				str = "Vault opened, The Scrambler unlocked"
			end
		end

		fn29 = function()
			local function fn41(arg)
				if not arg or not arg:IsA("Tool") then
					return false
				end

				if tostring(arg:GetAttribute("ItemType")) ~= "MutationConsumable" then
					return false
				end
				local attribute = arg:GetAttribute("MutationId") or arg:GetAttribute("MutationTemplate")
				if attribute ~= nil then
					return tostring(attribute) == "Scrambled"
				end
				return string.find(string.lower(arg.Name), "scrambled", 1, true) ~= nil
			end

			local character = localPlayer.Character

			if character then
				for _, child in ipairs(character:GetChildren()) do
					if fn41(child) then
						return child, true
					end
				end
			end

			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			if backpack then
				for _, child in ipairs(backpack:GetChildren()) do
					if fn41(child) then
						return child, false
					end
				end
			end

			return nil, false
		end

		fn30 = function(arg, arg2)
			local shopPurchases = type(arg) == "table" and arg.ShopPurchases or nil
			local flag4 = type(shopPurchases) == "table" and shopPurchases[arg2.Id] or nil
			if type(flag4) ~= "table" then
				return 0
			end
			local shopPeriod = type(snapshot) == "table" and snapshot.ShopPeriod or nil
			if flag4.Period ~= nil and shopPeriod ~= nil and flag4.Period ~= shopPeriod then
				return 0
			end
			return tonumber(flag4.Count) or 0
		end

		fn31 = function(arg)
			local v9 = fn9(true)
			if type(v9) ~= "table" or type(v9.Shop) ~= "table" then
				return
			end

			for _, v10 in ipairs(tbl11) do
				if arg() then
					return
				end

				if tbl18[v10.Label] == true then
					for i = 1, 10 do
						local v11 = snapshot
						local v12 = fn10()
						local v13, v14, v15 = ipairs(type(v11) == "table" and v11.Shop or {})
						local v16 = nil

						for _, v17 in v13, v14, v15 do
							if type(v17) == "table" and v17.Id == v10.Id then
								v16 = v17
							end
						end

						if not (not v16 or not v12 or arg()) then
							local num = tonumber(v16.PurchaseLimit)

							if not (num and fn30(v12, v16) >= num) then
								if not ((tonumber(v12.Samples) or 0) - (tonumber(v16.Price) or math.huge) < n4) then
									local Shop = fn8("Shop", v16.Id, { Quote = v16.Quote, Sequence = tonumber(v12.ShopSequence) or 0 })

									if not (type(Shop) ~= "table" or Shop.Ok ~= true) then
										str = "Bought " .. v10.Label
										task.wait(0.4)
										continue
									end
								end
							end
						end

						break
					end
				end
			end
		end
	end

	local n10, n11, n12, tbl17, tbl18, v9, n13, n14, fn32, v10
	local fn33, fn34, fn35, fn36

	do
		local n15 = 98
		n10 = 12
		n11 = 20
		n12 = 3

		tbl17 = {
			Vector3.new(2000, 90, -360),
			Vector3.new(2700, 90, -370),
			Vector3.new(3400, 90, -365),
			Vector3.new(4100, 90, -360),
			Vector3.new(4800, 90, -370),
			Vector3.new(5500, 90, -360),
			Vector3.new(5900, 90, -365),
		}

		tbl18 = {}
		local tbl19 = { Link = nil, Goal = nil, Look = nil, Character = nil }
		local userId = localPlayer.UserId
		local tbl20 = {}

		for _, v11 in ipairs({
			{ Label = "Scrap Drone", Tier = "ScrapDrone" },
			{ Label = "Reactor Drone", Tier = "ReactorDrone" },
			{ Label = "Augmented Drone", Tier = "AugmentedDrone" },
		}) do
			tbl20[#tbl20 + 1] = v11.Label
		end

		local tbl21 = { ScrapDrone = true, ReactorDrone = true, AugmentedDrone = true }
		local v11 = ({ "Nearest", "Rare First", "Most HP First" })[1]
		v9 = ({ "Tween", "Teleport" })[1]
		n13 = 110
		n14 = 1.5
		local n16 = 0
		local n17 = -math.huge

		local function fn37(arg)
			local num = type(arg) == "table" and tonumber(arg.OwnerUserId) or nil
			return num == nil or num == userId
		end

		local function fn38(arg)
			if typeof(arg) == "CFrame" then
				return arg.Position
			end

			if typeof(arg) == "Vector3" then
				return arg
			end
			return nil
		end

		local function fn39(arg, arg2)
			local v12 = networking:FindFirstChild(arg)
			if not v12 or not v12:IsA("RemoteEvent") then
				return
			end

			local connection = v12.OnClientEvent:Connect(function(...)
				pcall(arg2, ...)
			end)

			fn4(function()
				pcall(function()
					connection:Disconnect()
				end)
			end)
		end

		fn39("RE/Scramble/Drones", function(arg)
			if type(arg) ~= "table" then
				return
			end
			local v12 = pairs
			local upserts = type(arg.Upserts) == "table" and arg.Upserts or {}

			for _, upsert in v12(upserts) do
				if type(upsert) == "table" and upsert.Id ~= nil and fn37(upsert) then
					local id = tostring(upsert.Id)
					local attributes = type(upsert.Attributes) == "table" and upsert.Attributes or {}
					local tbl22 = tbl12[id] or {}
					tbl22.Id = id
					tbl22.Position = fn38(upsert.CFrame) or tbl22.Position
					tbl22.Health = tonumber(upsert.Health) or tbl22.Health or 1
					tbl22.Tier = tostring(attributes.ScrambleTier or tbl22.Tier or "")
					tbl22.Area = tostring(attributes.ScrambleArea or tbl22.Area or "")
					tbl22.Seen = os.clock()
					tbl12[id] = tbl22
				end
			end

			local v13 = pairs
			local removed = type(arg.Removed) == "table" and arg.Removed or {}

			for k, v14 in v13(removed) do
				tbl12[tostring(type(v14) == "string" and v14 or k)] = nil
			end
		end)

		fn39("RE/Scramble/Effect", function(arg, arg2, arg3)
			if arg ~= "Hit" or type(arg3) ~= "table" or arg3.DroneId == nil then
				return
			end
			local v12 = tbl12[tostring(arg3.DroneId)]
			if not v12 then
				return
			end
			v12.Position = fn38(arg2) or v12.Position
			v12.Health = (tonumber(v12.Health) or 1) - (tonumber(arg3.Amount) or 1)

			if type(arg3.Motion) == "string" and string.find(arg3.Motion, "\"Death\"", 1, true) then
				v12.Health = 0
			end

			if v12.Health <= 0 then
				tbl12[v12.Id] = nil
			end
		end)

		fn39("RE/Scramble/Drops", function(arg)
			local v12 = pairs
			local tbl22 = type(arg) == "table" and arg or {}

			for _, v13 in v12(tbl22) do
				if type(v13) == "table" and v13.Id ~= nil and fn37(v13) then
					local v14 = fn38(v13.Position) or fn38(v13.Origin)

					if v14 then
						tbl13[tostring(v13.Id)] = {
							Position = v14,
							Radius = tonumber(v13.Radius) or 6,
							ExpiresAt = tonumber(v13.ExpiresAt),
							Kind = v13.Kind,
						}
					end
				end
			end
		end)

		fn39("RE/Scramble/State", function(arg)
			if type(arg) ~= "table" then
				return
			end

			if arg.Patch == true and type(snapshot) == "table" then
				for k, v12 in pairs(arg) do
					if k ~= "Patch" then
						snapshot[k] = v12
					end
				end
			elseif type(arg.State) == "table" then
				snapshot = arg
			end

			n5 = os.clock()
		end)

		fn39("RE/Scramble/RemoveDrops", function(arg)
			local v12 = pairs
			local tbl22 = type(arg) == "table" and arg or {}

			for k, v13 in v12(tbl22) do
				local v14 = tbl13
				local v15 = tostring
				v13 = type(v13) == "string" and v13 or k
				v14[v15(v13)] = nil
			end
		end)

		local function fn40(arg)
			local scrambleLocalVisuals = workspace:FindFirstChild("ScrambleLocalVisuals")
			return scrambleLocalVisuals and scrambleLocalVisuals:FindFirstChild("PersonalDrone_" .. arg) or nil
		end

		local v12 = nil
		local n18 = 0

		local function fn41()
			if v12 and next(v12) ~= nil then
				return v12
			end
			v12 = nil
			if os.clock() < n18 or type(getgc) ~= "function" or not fn12() then
				return nil
			end
			n18 = os.clock() + 15

			for _, v13 in ipairs(getgc(false)) do
				if type(v13) == "function" and islclosure(v13) then
					local ok, result = pcall(debug.info, v13, "s")

					if ok and type(result) == "string" and string.find(result, "PersonalDrones", 1, true) then
						local ok2, result2 = pcall(debug.getupvalues, v13)

						if ok2 and type(result2) == "table" then
							for _, v14 in pairs(result2) do
								if type(v14) == "table" then
									local key, v15 = next(v14)
									if type(v15) == "table" and v15.OwnerUserId ~= nil and v15.CFrame ~= nil then
										v12 = v14
										return v14
									end
								end
							end

							continue
						end
					end
				end
			end

			return nil
		end

		local function fn42()
			local v13 = fn41()
			if not v13 then
				return
			end

			for k, v14 in pairs(v13) do
				if type(v14) == "table" and fn37(v14) then
					local str3 = tostring(v14.Id or k)
					local attributes = type(v14.Attributes) == "table" and v14.Attributes or {}
					local tbl22 = tbl12[str3]
					local num = tonumber(v14.Health)

					if not tbl22 then
						tbl22 = { Id = str3, Health = num or 1 }
						tbl12[str3] = tbl22
					elseif num then
						tbl22.Health = math.min(num, tonumber(tbl22.Health) or num)
					end

					tbl22.Position = fn38(v14.CFrame) or tbl22.Position
					tbl22.Tier = tostring(attributes.ScrambleTier or tbl22.Tier or "")
					tbl22.Area = tostring(attributes.ScrambleArea or tbl22.Area or "")

					if attributes.DroneState == "Death" then
						tbl22.Health = 0
					end
				end
			end

			for k in pairs(tbl12) do
				if v13[k] == nil then
					tbl12[k] = nil
				end
			end
		end

		local function fn43()
			pcall(fn42)
			local scrambleLocalVisuals = workspace:FindFirstChild("ScrambleLocalVisuals")
			if not scrambleLocalVisuals then
				return
			end

			for _, child in ipairs(scrambleLocalVisuals:GetChildren()) do
				local attribute = child:GetAttribute("ScrambleDroneId")

				if child:IsA("Model") and attribute ~= nil and string.sub(child.Name, 1, 14) == "PersonalDrone_" then
					local str3 = tostring(attribute)

					if child:GetAttribute("DroneState") == "Death" then
						tbl12[str3] = nil
					elseif not tbl12[str3] then
						local ok, result = pcall(child.GetPivot, child)

						tbl12[str3] = {
							Id = str3,
							Position = ok and result.Position or nil,
							Health = tonumber(child:GetAttribute("Health")) or 1,
							Tier = tostring(child:GetAttribute("ScrambleTier") or ""),
							Area = tostring(child:GetAttribute("ScrambleArea") or ""),
							Seen = os.clock(),
						}
					end
				end
			end
		end

		local function fn44(arg)
			local v13 = fn40(arg.Id)
			local hitbox = v13 and v13:FindFirstChild("Hitbox")
			if hitbox and hitbox:IsA("BasePart") then
				return hitbox.Position
			end

			if v13 and v13.PrimaryPart then
				return v13.PrimaryPart.Position
			end
			return arg.Position
		end

		local function fn45()
			local tbl22 = {}
			local now = os.clock()

			for k, v13 in pairs(tbl12) do
				local flag4 = v13.Tier == nil or v13.Tier == "" or tbl21[v13.Tier] == true

				if flag4 then
					flag4 = (tonumber(v13.Health) or 0) > 0
				end

				flag4 = flag4 and v13.Position
				local flag5

				if flag4 then
					flag5 = (tbl18[k] or 0) <= now
				else
					flag5 = flag4
				end

				if flag5 then
					tbl22[#tbl22 + 1] = v13
				end
			end

			return tbl22
		end

		local function fn46()
			local v13 = fn16()
			if not v13 then
				return nil
			end
			local huge = math.huge
			local v14 = nil

			for _, v15 in ipairs(fn45()) do
				local magnitude = ((fn44(v15) or v15.Position) - v13.Position).Magnitude
				local v16 = v11
				local n19

				if v16 == "Rare First" then
					if v15.Tier == "AugmentedDrone" then
						n19 = magnitude - 200000
					elseif v15.Tier ~= "ReactorDrone" then
						n19 = magnitude
					else
						n19 = magnitude - 100000
					end
				elseif v16 == "Most HP First" then
					n19 = magnitude - (tonumber(v15.Health) or 0) * 100000
				else
					n19 = magnitude
				end

				if n19 < huge then
					huge = n19
					v14 = v15
				end
			end

			return v14
		end

		local function fn47()
			local v13 = fn16()
			if not v13 then
				return nil, nil
			end
			local serverTimeNow = workspace:GetServerTimeNow()
			local huge = math.huge
			local v14 = nil
			local v15 = nil

			for k, v16 in pairs(tbl13) do
				if v16.ExpiresAt and v16.ExpiresAt < serverTimeNow then
					tbl13[k] = nil
				else
					local magnitude = (v16.Position - v13.Position).Magnitude
					local n19

					if v16.Kind == "Part" then
						n19 = magnitude - 100000
					else
						n19 = magnitude
					end

					if n19 < huge then
						huge = n19
						v14 = k
						v15 = v16
					end
				end
			end

			return v14, v15
		end

		fn32 = function()
			if not tbl19.Link then
				if tbl19.SwapWait then
					tbl19.SwapWait = nil
					tbl4.Shield("scramble", false)
				end

				return
			end

			tbl19.Link:Disconnect()
			local v13 = tbl19
			local v14 = tbl19
			local v15 = tbl19
			tbl19.Link = nil
			v13.Goal = nil
			v14.Look = nil
			v15.Character = nil
			local v16 = tbl19
			local v17 = tbl19
			local v18 = tbl19
			local v19 = tbl19
			tbl19.Track = nil
			v16.Dir = nil
			v17.Last = nil
			v18.LastAt = nil
			v19.Vel = nil
			tbl4.Driving = math.max(0, tbl4.Driving - 1)
			tbl4.Shield("scramble", false)
		end

		fn4(fn32)

		local function fn48(goal, look, track)
			if track ~= tbl19.Track then
				local v13 = tbl19
				local v14 = tbl19
				tbl19.Last = nil
				v13.LastAt = nil
				v14.Vel = nil
			end

			local v13 = tbl19
			local v14 = tbl19
			tbl19.Goal = goal
			v13.Look = look
			v14.Track = track
			local character = localPlayer.Character

			if tbl19.Link and tbl19.Character ~= character then
				fn32()
				local v15 = tbl19
				local v16 = tbl19
				tbl19.Goal = goal
				v15.Look = look
				v16.Track = track
			end

			if tbl19.Link or not character then
				return
			end

			if not tbl4.Swapped() then
				tbl4.Shield("scramble", true)
				tbl19.SwapWait = tbl19.SwapWait or os.clock() + 6
				local swapWait = tbl19.SwapWait
				if os.clock() < swapWait then
					str = "Waiting for the character to settle"
					return
				end
			end

			if tbl19.SwapWait then
				tbl19.SwapWait = nil
			else
				tbl4.Shield("scramble", true)
			end

			tbl19.Character = character
			tbl4.Driving = tbl4.Driving + 1

			tbl19.Link = RunService.Heartbeat:Connect(function(deltaTime)
				local v15 = tbl4.Root()
				local goal2 = tbl19.Goal
				if not v15 or not goal2 or v15.Parent ~= tbl19.Character or tbl4.AntiGuard.Busy or tbl4.Movement.Owner ~= "scramble" then
					return
				end
				local position = v15.Position

				if tbl19.Track then
					local ok, last = pcall(tbl19.Track)

					if ok and typeof(last) == "Vector3" then
						local now = os.clock()

						if not tbl19.Last or not tbl19.LastAt then
							local v16 = tbl19
							tbl19.Last = last
							v16.LastAt = now
						elseif (last - tbl19.Last).Magnitude > 0.01 then
							local n19 = math.max(now - tbl19.LastAt, 0.0041666666666666666)
							local n20 = (last - tbl19.Last) / n19

							if n20.Magnitude < 400 then
								local n21 = math.clamp(n19 * 12, 0.2, 0.8)
								tbl19.Vel = tbl19.Vel and tbl19.Vel:Lerp(n20, n21) or n20
							end

							local v16 = tbl19
							tbl19.Last = last
							v16.LastAt = now
						elseif now - tbl19.LastAt > 0.25 and tbl19.Vel then
							tbl19.Vel = tbl19.Vel:Lerp(Vector3.zero, math.clamp(deltaTime * 6, 0, 1))
						end

						local vel = tbl19.Vel or Vector3.zero
						local look2 = tbl19.Last + vel * (math.clamp(now - tbl19.LastAt, 0, 0.25) + 0.1)
						local vector = Vector3.new(position.X - look2.X, 0, position.Z - look2.Z)

						if vector.Magnitude > 0.5 then
							local unit = vector.Unit
							local n19 = math.clamp(deltaTime * 5, 0, 1)
							local dir = tbl19.Dir and tbl19.Dir:Lerp(unit, n19) or unit
							tbl19.Dir = dir.Magnitude > 0.01 and dir.Unit or unit
						end

						goal2 = look2 + (tbl19.Dir or Vector3.new(0, 0, 1)) * n8 + Vector3.new(0, -1, 0)
						local v16 = tbl19
						tbl19.Goal = goal2
						v16.Look = look2

						if (goal2 - position).Magnitude <= 40 then
							local n19 = math.max(deltaTime, 0.0041666666666666666)
							local n20 = vel + (goal2 - position) / math.max(0.1, n19)
							local n21 = math.max(400, vel.Magnitude + 80)

							if n21 < n20.Magnitude then
								n20 = n20.Unit * n21
							end

							local assemblyLinearVelocity = n20 + Vector3.new(0, workspace.Gravity * n19 * 0.5, 0)
							local vector2 = Vector3.new(look2.X - position.X, 0, look2.Z - position.Z)

							pcall(function()
								if vector2.Magnitude > 0.05 then
									v15.CFrame = CFrame.lookAt(position, position + vector2.Unit)
								end

								v15.AssemblyLinearVelocity = assemblyLinearVelocity
								v15.AssemblyAngularVelocity = Vector3.zero
							end)

							return
						end
					end
				end

				local vector

				if Vector3.new(goal2.X - position.X, 0, goal2.Z - position.Z).Magnitude > 250 then
					local n19 = math.max(n15, goal2.Y)
					vector = position.Y < n19 - 2 and Vector3.new(position.X, n19, position.Z) or Vector3.new(goal2.X, n19, goal2.Z)
				else
					vector = goal2
				end

				local n19 = vector - position
				local n20 = n3 * deltaTime
				vector = n19.Magnitude <= n20 and vector or position + n19.Unit * n20
				local look2 = tbl19.Look or goal2
				local vector2 = Vector3.new(look2.X - vector.X, 0, look2.Z - vector.Z)
				local cframe = vector2.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector2.Unit) or v15.CFrame.Rotation

				pcall(function()
					v15.CFrame = CFrame.new(vector) * cframe
					v15.AssemblyLinearVelocity = Vector3.zero
					v15.AssemblyAngularVelocity = Vector3.zero
				end)
			end)
		end

		local function fn49(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
				return false
			end
			local attribute = arg:GetAttribute("GearName")
			local gears = tbl.Gears
			local directory = type(gears) == "table" and gears.Directory or nil
			local flag4 = type(attribute) == "string" and type(directory) == "table" and directory[attribute] or nil
			return type(flag4) == "table" and (flag4.ToolController == "Slap" or flag4.SlapPower ~= nil)
		end

		local function fn50(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
				return false
			end

			if tostring(arg:GetAttribute("ItemType")) ~= "Gear" then
				return false
			end
			local str3 = tostring(arg:GetAttribute("GearName") or "")
			if str3 == "" then
				return false
			end
			return string.find(string.lower(str3), "scrambler", 1, true) ~= nil
		end

		local function fn51()
			return localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack")
		end

		local function fn52()
			local v13 = tbl4.FindBat()
			if v13 then
				return v13
			end
			local v14, v15 = fn51()

			for _, v16 in ipairs({ v14, v15 }) do
				if v16 then
					for _, child in ipairs(v16:GetChildren()) do
						if fn49(child) or fn50(child) then
							return child
						end
					end
				end
			end

			return nil
		end

		tbl14.Valid = function(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
				return false
			end
			return tbl4.IsBatTool(arg) or fn49(arg) or fn50(arg)
		end

		tbl14.Owned = function(arg)
			if typeof(arg) ~= "Instance" or not arg:IsA("Tool") then
				return false
			end
			local v13, v14 = fn51()
			local parent = arg.Parent
			local flag4 = parent ~= nil
			local flag5

			if flag4 then
				flag5 = parent == v13 or parent == v14
			else
				flag5 = flag4
			end

			return flag5
		end

		tbl14.Name = function(arg)
			if fn50(arg) then
				return "The Scrambler"
			end
			return tostring(arg:GetAttribute("GearName") or arg.Name)
		end

		tbl14.Put = function(arg, arg2, parent)
			local equipAt = tbl14.EquipAt
			if os.clock() - equipAt < 0.4 then
				return false
			end
			tbl14.EquipAt = os.clock()

			pcall(function()
				arg2:EquipTool(arg)
			end)

			if arg.Parent ~= parent then
				pcall(function()
					arg.Parent = parent
				end)
			end

			return arg.Parent == parent
		end

		local function fn53()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			if not character or not humanoid or humanoid.Health <= 0 then
				return nil, false
			end
			local tool = character:FindFirstChildWhichIsA("Tool")

			if tool ~= nil and tbl14.Valid(tool) then
				tbl14.Tool = tool
				str2 = tbl14.Name(tool)
				return tool, true
			end

			if not tbl14.Owned(tbl14.Tool) then
				tbl14.Tool = fn52()
			end

			local tool2 = tbl14.Tool
			if not tool2 then
				str2 = ""
				return nil, false
			end
			str2 = tbl14.Name(tool2)
			tbl14.Put(tool2, humanoid, character)
			return tool2, tool2.Parent == character
		end

		local function fn54()
			local v13, v14 = fn53()

			if v13 and v14 then
				if flag2 then
					pcall(function()
						v13:Activate()
					end)

					task.defer(function()
						pcall(function()
							v13:Deactivate()
						end)
					end)
				else
					pcall(function()
						v13:Deactivate()
						v13:Activate()
					end)
				end
			end

			return v13 ~= nil
		end

		local function fn55()
			local v13, v14 = fn51()
			local v15 = nil
			local v16 = nil
			local v17 = nil

			for _, v18 in ipairs({ v13, v14 }) do
				if v18 then
					for _, child in ipairs(v18:GetChildren()) do
						if tbl14.Valid(child) then
							if fn50(child) then
								v15 = v15 or child
							elseif tbl4.IsBatTool(child) and (v16 == nil or not tbl4.IsBatTool(v16)) then
								if v17 then
									v16 = child
								else
									v17 = v16
									v16 = child
								end
							elseif v16 == nil then
								v16 = child
							elseif v17 == nil then
								v17 = child
							end
						end
					end
				end
			end

			return v16, v15 or v17
		end

		local function fn56(arg)
			pcall(function()
				arg:Activate()
			end)

			task.defer(function()
				pcall(function()
					arg:Deactivate()
				end)
			end)
		end

		tbl15.SpamUntil = 0
		tbl15.List = {}
		tbl15.Dirty = true
		tbl15.BuiltAt = 0
		tbl15.NextBag = 0
		tbl15.Links = {}

		tbl15.Click = function(arg)
			pcall(arg.Deactivate, arg)
			pcall(arg.Activate, arg)
		end

		tbl15.Rebuild = function()
			tbl15.Dirty = false
			tbl15.BuiltAt = os.clock()
			table.clear(tbl15.List)
			local v13, v14 = fn51()

			for _, v15 in ipairs({ v13, v14 }) do
				if v15 then
					for _, child in ipairs(v15:GetChildren()) do
						if tbl14.Valid(child) then
							tbl15.List[#tbl15.List + 1] = child
						end
					end
				end
			end
		end

		tbl15.Beat = RunService.Heartbeat:Connect(function()
			local now = os.clock()
			if tbl15.SpamUntil <= now then
				return
			end

			if tbl15.Dirty or now - tbl15.BuiltAt > 1 then
				tbl15.Rebuild()
			end

			local character = localPlayer.Character
			local flag4 = now >= tbl15.NextBag

			if flag4 then
				tbl15.NextBag = now + 0.25
			end

			for _, v13 in ipairs(tbl15.List) do
				local parent = v13.Parent

				if parent == character then
					tbl15.Click(v13)
				elseif flag4 and parent ~= nil then
					tbl15.Click(v13)
				end
			end
		end)

		tbl15.Unwatch = function()
			for i = #tbl15.Links, 1, -1 do
				pcall(function()
					tbl15.Links[i]:Disconnect()
				end)

				tbl15.Links[i] = nil
			end
		end

		tbl15.Watch = function(arg)
			tbl15.Unwatch()
			tbl15.Dirty = true
			if not arg then
				return
			end

			tbl15.Links[#tbl15.Links + 1] = arg.ChildAdded:Connect(function(child)
				if not child:IsA("Tool") then
					return
				end
				tbl15.Dirty = true
				local spamUntil = tbl15.SpamUntil

				if os.clock() < spamUntil and tbl14.Valid(child) then
					tbl15.Click(child)
					task.defer(tbl15.Click, child)
				end
			end)

			tbl15.Links[#tbl15.Links + 1] = arg.ChildRemoved:Connect(function(child)
				if child:IsA("Tool") then
					tbl15.Dirty = true
				end
			end)

			task.defer(function()
				local backpack = localPlayer:FindFirstChildOfClass("Backpack") or localPlayer:WaitForChild("Backpack", 5)

				if backpack and localPlayer.Character == arg then
					tbl15.Links[#tbl15.Links + 1] = backpack.ChildAdded:Connect(function()
						tbl15.Dirty = true
					end)

					tbl15.Links[#tbl15.Links + 1] = backpack.ChildRemoved:Connect(function()
						tbl15.Dirty = true
					end)
				end
			end)
		end

		tbl15.Watch(localPlayer.Character)
		tbl15.CharLink = localPlayer.CharacterAdded:Connect(tbl15.Watch)

		fn4(function()
			tbl15.SpamUntil = 0
			tbl15.Unwatch()

			for _, v13 in ipairs({ "Beat", "CharLink" }) do
				if tbl15[v13] then
					pcall(function()
						tbl15[v13]:Disconnect()
					end)

					tbl15[v13] = nil
				end
			end
		end)

		local function fn57()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			if not character or not humanoid or humanoid.Health <= 0 then
				return false
			end
			local v13, v14 = fn55()
			if not v13 or not v14 then
				return fn54()
			end
			local tbl22 = { v13, v14 }
			local tbl23 = { 0.3, 0.4 }
			local v15 = tbl22[tbl15.Index]

			if tbl15.Tool ~= v15 then
				local v16 = tbl15
				local v17 = tbl15
				local now = os.clock()
				v16.Tool = v15
				v17.Since = now
			end

			local flag4 = v15.Parent == character

			if flag4 then
				local since = tbl15.Since
				flag4 = os.clock() - since >= tbl23[tbl15.Index]
			end

			if flag4 then
				tbl15.Index = tbl15.Index == 1 and 2 or 1
				v15 = tbl22[tbl15.Index]
				local v16 = tbl15
				local v17 = tbl15
				local now = os.clock()
				v16.Tool = v15
				v17.Since = now
			end

			tbl14.Tool = v15
			str2 = tbl14.Name(v15)

			if v15.Parent ~= character then
				pcall(function()
					humanoid:EquipTool(v15)
				end)

				if v15.Parent ~= character then
					pcall(function()
						v15.Parent = character
					end)
				end

				tbl15.Since = os.clock()

				if v15.Parent == character then
					fn56(v15)
					task.defer(fn56, v15)
				end

				return true
			end

			fn56(v15)
			return true
		end

		local function fn58(arg, arg2, arg3)
			local now = os.clock()
			local n19 = now + n12

			while os.clock() < n19 and not arg() do
				local v13, v14 = fn47()
				local flag4 = not v14

				if not flag4 then
					if arg2 then
						flag4 = (v14.Position - arg2).Magnitude > (arg3 or 40)
					else
						flag4 = arg2
					end
				end

				if flag4 then
					if arg2 and os.clock() - now < 1.2 then
						task.wait(0.1)
						continue
					end
					return
				end

				if fn22() and not fn22(v14.Position) then
					fn32()
					str = "Leaving the base through the safe zone"
					if not fn24(v14.Position + Vector3.new(0, 2.5, 0), arg, 6) then
						return
					end
					continue
				end

				str = v14.Kind == "Part" and "Picking up a Drone Part" or "Picking up Samples"
				fn48(v14.Position + Vector3.new(0, 2.5, 0), v14.Position)
				local n20 = os.clock() + 2.5

				while tbl13[v13] and os.clock() < n20 and not arg() do
					task.wait(0.1)
				end

				tbl13[v13] = nil
				n19 = os.clock() + 1.2
			end
		end

		local function fn59(arg, arg2)
			local now = os.clock()
			local n19 = tonumber(arg.Health) or 0
			local v13 = nil
			local v14 = nil
			local fn60 = nil
			local flag4 = false

			while not arg2() do
				local v15 = tbl12[arg.Id]
				local flag5 = not v15

				if not flag5 then
					flag5 = (tonumber(v15.Health) or 0) <= 0
				end

				if flag5 then
					return true
				end
				local v16 = fn40(arg.Id)
				if v16 and v16:GetAttribute("DroneState") == "Death" then
					tbl12[arg.Id] = nil
					return true
				end
				local v17 = fn16()
				local flag6 = v17 ~= nil and v15.Position ~= nil

				if flag6 then
					flag6 = (v17.Position - (fn44(v15) or v15.Position)).Magnitude <= 30
				end

				if flag6 and not v16 then
					local now2 = v13 or os.clock()
					if os.clock() - now2 > 1.5 then
						tbl12[arg.Id] = nil
						return false
					end
					v13 = now2
				else
					v13 = nil
				end

				local n20 = tonumber(v15.Health) or 0

				if n20 ~= n19 then
					v14 = nil
					n19 = n20
				end

				if n11 < os.clock() - now then
					tbl18[arg.Id] = os.clock() + 30
					return false
				end
				local position = fn44(v15) or v15.Position
				local v18 = fn16()
				if not v18 then
					return false
				end

				if fn22() and not fn22(position) then
					fn32()
					str = "Leaving the base through the safe zone"
					if not fn24(position, arg2, 12) then
						return false
					end

					if arg2() then
						return false
					end
				end

				if not fn60 then
					local v19 = nil
					local isBasePart = nil

					fn60 = function()
						local v20 = tbl12[arg.Id]
						if not v20 then
							return nil
						end

						if not v19 or not v19.Parent then
							v19 = fn40(arg.Id)
							local hitbox = v19 and v19:FindFirstChild("Hitbox")
							isBasePart = hitbox and hitbox:IsA("BasePart") and hitbox or v19 and v19.PrimaryPart or nil
						end

						if isBasePart and isBasePart.Parent then
							return isBasePart.Position
						end
						return v20.Position
					end
				end

				if flag2 then
					fn48(position + Vector3.new(0, -1, 16), position, fn60)
				else
					fn48(position + Vector3.new(0, -1, 5), position)
				end

				if (v18.Position - position).Magnitude <= 60 and not flag2 then
					fn53()
				end

				local magnitude = (v18.Position - position).Magnitude
				local flag7 = false

				if flag2 then
					flag7 = math.max(12, n8 + 7)
				end

				local flag8 = magnitude <= (flag7 or 12)

				if flag8 then
					if flag2 then
						tbl15.SpamUntil = os.clock() + 0.2
					end

					local now2 = v14 or os.clock()
					if os.clock() - now2 > 8 then
						tbl18[arg.Id] = os.clock() + 30
						return false
					end
					local flag9 = false

					if flag2 then
						flag9 = fn57()
					end

					if flag9 or not flag2 and fn54() then
						str = string.format("Smashing %s  %d HP", v15.Tier ~= "" and v15.Tier or "drone", math.max(0, tonumber(v15.Health) or 0))
						v14 = now2
					elseif not flag4 then
						str = "No bat found, get any bat to smash drones"
						flag4 = true
						v14 = now2
					else
						v14 = now2
					end
				else
					str = "Flying to a drone"
				end

				local wait = task.wait
				local flag9 = false

				if flag2 then
					flag9 = flag8
				end

				wait(flag9 and 0.03 or 0.1)
			end

			return false
		end

		local function fn60(arg)
			for _, v13 in ipairs(tbl17) do
				if arg() then
					return false
				end
				str = "Looking for drones"
				fn48(v13)
				local n19 = os.clock() + 12

				while os.clock() < n19 and not arg() do
					fn43()
					if #fn45() > 0 then
						return true
					end

					if tbl4.DistanceTo(v13) < 8 then
						break
					end
					task.wait(0.2)
				end
			end

			return #fn45() > 0
		end

		local function fn61()
			local serverTimeNow = workspace:GetServerTimeNow()
			local v13, v14 = fn12()
			if v13 and v14 and v14 < 25 then
				return next(tbl13) ~= nil
			end

			for _, v15 in pairs(tbl13) do
				if v15.Kind == "Part" or v15.ExpiresAt and v15.ExpiresAt - serverTimeNow < 30 then
					return true
				end
			end

			return false
		end

		local v13 = nil

		local function fn62()
			local window = type(snapshot) == "table" and snapshot.Window or nil
			return type(window) == "table" and window.Index or nil
		end

		local function fn63(arg)
			local flag4 = v13 ~= nil and v13 == fn62()

			while not arg() do
				RunService.Heartbeat:Wait()
				if arg() then
					break
				end
				fn43()

				if fn61() then
					fn58(arg)
				end

				if fn22() then
					fn32()
					if not fn23(arg) then
						break
					end
				end

				local v14 = fn46()

				if not v14 and next(tbl13) ~= nil then
					fn58(arg)
					fn43()
					v14 = fn46()
				end

				if not v14 then
					if not fn12() or flag4 then
						break
					end
					v13 = fn62()
					local flag5 = true
					flag4 = true
					if not fn60(arg) then
						break
					end
					continue
				end

				local position = fn44(v14) or v14.Position
				local flag5 = fn16()
				local magnitude = flag5 and (flag5.Position - position).Magnitude or 0
				flag5 = v9 == "Teleport" and flag5

				if flag5 then
					flag5 = not (fn22() and not fn22(position))
				end

				if flag5 then
					if magnitude > n10 and magnitude <= n13 and os.clock() >= n16 and os.clock() - n17 >= n14 then
						n17 = os.clock()
						local vector = Vector3.new
						local flag6 = false

						if flag2 then
							flag6 = 16
						end

						local n19 = position + vector(0, -1, flag6 or 5)
						fn48(n19, position)
						local v15 = fn16()

						if v15 then
							str = "Teleporting to the next drone"

							pcall(function()
								v15.CFrame = CFrame.lookAt(n19, Vector3.new(position.X, n19.Y, position.Z))
								v15.AssemblyLinearVelocity = Vector3.zero
								v15.AssemblyAngularVelocity = Vector3.zero
							end)

							local n20 = os.clock() + 0.8

							while true do
								if os.clock() < n20 and not arg() then
									local v16 = fn16()

									if v16 and (v16.Position - n19).Magnitude > 40 then
										n16 = os.clock() + 30
										str = "Teleport pulled back, tweening"
										break
									else
										RunService.Heartbeat:Wait()
										continue
									end
								end

								break
							end
						end
					end
				end

				fn59(v14, arg)
			end

			fn58(arg)
			fn32()
		end

		local tbl22 = { LostPart1 = "Mechanical Gear", LostPart2 = "Wiring Harness" }

		tbl4.ScrambleLostPart = function(arg)
			return fn13(fn10(), arg)
		end

		v10 = nil

		fn33 = function()
			local v14 = fn10()
			if not v14 then
				return "Lost Parts: no event data"
			end
			local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
			local tbl23 = {}
			local n19 = 0
			local n20 = 0

			for _, v15 in ipairs(tbl10) do
				local v16 = drScrambleEvent and drScrambleEvent:FindFirstChild(v15)

				if v16 then
					n19 += 1
				end

				if fn13(v14, v15) then
					n20 += 1
				elseif v16 then
					local ok, result = pcall(v16.GetPivot, v16)
					ok = ok and tbl4.DistanceTo(result.Position) or nil
					tbl23[#tbl23 + 1] = ok and string.format("%s %d studs", tbl22[v15], math.floor(ok)) or tbl22[v15]
				else
					tbl23[#tbl23 + 1] = tbl22[v15] .. " not on map"
				end
			end

			local str3 = string.format("Lost Parts on map %d/2  -  Collected %d/2", n19, n20)
			local str4

			if #tbl23 > 0 then
				str4 = str3 .. "  -  " .. table.concat(tbl23, "  -  ")
			else
				str4 = str3
			end

			return str4
		end

		local function fn64(arg)
			if not fn21() then
				return true
			end
			local Exit = fn19("Exit")
			local v14 = fn20(Exit, nil)
			if not v14 then
				return false
			end
			str = "Leaving the Secret Cave"
			if not fn17(v14, arg, 4) then
				return false
			end

			for i = 1, 4 do
				if arg() then
					return false
				end
				fn18(Exit or fn19("Exit"))
				local n19 = os.clock() + 1.5

				while os.clock() < n19 and fn21() do
					RunService.Heartbeat:Wait()
				end

				if not fn21() then
					return true
				end
			end

			return not fn21()
		end

		local function fn65()
			return tbl4.IsNight() or tbl4.WallSealed()
		end

		local function fn66(arg)
			if not fn65() then
				return true
			end
			fn32()

			while fn65() and not arg() do
				str = tbl4.IsNight() and "Night, waiting for the wall to drop" or "Waiting for the wall to drop"
				RunService.Heartbeat:Wait()
			end

			return not arg()
		end

		fn34 = function()
			if not tbl4.Toggle(nil, false) or not fn11() then
				return false
			end

			if tbl16.Ended then
				return false
			end

			if fn12() then
				return true
			end
			fn43()
			return #fn45() > 0 or next(tbl13) ~= nil
		end

		fn35 = function()
			local v14 = fn10()
			if not v14 or v14.Completed == true or not fn11() then
				return false
			end
			local num = tonumber(v14.TotalParts)

			if not num then
				num = fn14(v14) + (tonumber(v14.DroneParts) or 0)
			end

			local flag4 = tbl4.Toggle(nil, false)

			if flag4 then
				local n19 = #tbl10
				flag4 = fn14(v14) < n19
			end

			local flag5 = tbl4.Toggle(nil, false) and (num >= 5 or v14.Discovered ~= true)
			return flag4 or flag5
		end

		fn36 = function(arg)
			local function fn67()
				return arg ~= n6 or tbl4.Movement.Owner ~= "scramble"
			end

			local function fn68()
				return fn67() or not fn34() or fn65()
			end

			while true do
				if fn34() and not fn67() then
					if fn66(fn67) then
						pcall(fn63, fn68)
						if fn65() then
							continue
						end
					end
				end

				break
			end

			fn32()
			if fn67() or fn34() then
				return
			end

			if not fn35() then
				fn25(fn67)
				str = ""
				return
			end

			if not fn66(fn67) then
				return
			end
			fn9(true)
			local v14 = fn10()
			if not v14 then
				return
			end

			if not fn35() then
				str = ""
				return
			end

			if tbl4.Toggle(nil, false) and v14.Discovered ~= true then
				pcall(fn26, fn67)
			end

			if tbl4.Toggle(nil, false) then
				pcall(fn27, function()
					return fn67() or not tbl4.Toggle(nil, false) or fn34() or fn65()
				end)
			end

			if tbl4.Toggle(nil, false) then
				pcall(fn28, function()
					return fn67() or not tbl4.Toggle(nil, false) or fn34() or fn65()
				end)
			end

			if fn21() and not fn67() then
				pcall(fn64, fn67)
			end

			if not fn21() and not fn34() then
				pcall(fn25, fn67)
			end
		end
	end

	local fn37

	fn37 = function(arg)
		if not (tbl4.Treadmill.Riding or tbl4.OnBelt()) then
			return true
		end

		for i = 1, 3 do
			if arg() then
				return false
			end
			str = "Jumping off the treadmill"
			tbl4.Treadmill.Riding = false
			task.spawn(tbl4.LeaveBelt)
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				pcall(function()
					humanoid.Sit = false
					humanoid.Jump = true
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end

			local v11 = fn16()

			if v11 then
				local position = v11.Position
				local n15 = position + Vector3.new(0, 18, 0)
				local now = os.clock()

				while true do
					RunService.Heartbeat:Wait()
					local v12 = fn16()

					if not v12 then
						break
					else
						local n16 = math.min(1, (os.clock() - now) / 0.25)

						pcall(function()
							local rotation = v12.CFrame.Rotation
							v12.CFrame = CFrame.new(position:Lerp(n15, n16)) * rotation
							v12.AssemblyLinearVelocity = Vector3.zero
							v12.AssemblyAngularVelocity = Vector3.zero
						end)

						if not (n16 >= 1) then
							continue
						end
						break
					end
				end
			end

			if not (tbl4.Treadmill.Riding or tbl4.OnBelt()) then
				return true
			end
		end

		return not tbl4.OnBelt()
	end

	do
		local tbl19 = { "Highest Value", "Best Rarity", "Biggest Size" }
		local tbl20 = { idle = "#8C93A6", work = "#FFC857", good = "#57E08A", stop = "#FF6B6B" }
		local n15 = 6

		local tbl21 = {
			Handle = nil,
			BuyHandle = nil,
			Loop = 0,
			MinRarity = 0,
			MinIncome = 0,
			Priority = tbl19[1],
			SkipMutated = true,
			Targets = {},
			Cooldown = 0,
			Status = "Idle",
			State = "idle",
			Detail = "Turn it on to start applying Scrambled",
			RarityColor = "#FFFFFF",
			Icon = "",
			Ui = {},
			Row = nil,
			Left = 0,
			Pen = 0,
			Match = 0,
			Tries = 0,
			Hits = 0,
			Locked = nil,
			Short = false,
			EggOptions = {},
			EggCategory = {},
		}

		local directory = tbl.Assets and tbl.Assets.Directory
		local tbl22 = {}

		if type(directory) == "table" then
			for k, v11 in pairs(directory) do
				local rarity = type(v11) == "table" and v11.Rarity or nil
				local flag4 = type(rarity) == "table"

				if flag4 then
					flag4 = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				local v12 = flag4 or nil

				if v12 then
					table.insert(tbl22, {
						Category = tostring(k),
						Name = tostring(v11.DisplayName or k),
						Rarity = v12,
						RarityName = tostring(rarity.DisplayName or rarity._id or v12),
					})
				end
			end
		end

		table.sort(tbl22, function(arg, arg2)
			if arg.Rarity ~= arg2.Rarity then
				return arg.Rarity > arg2.Rarity
			end
			return arg.Name < arg2.Name
		end)

		for _, v11 in ipairs(tbl22) do
			local str3 = string.format("%s [%s]", v11.Name, v11.RarityName)

			if tbl21.EggCategory[str3] then
				str3 = string.format("%s [%s] (%s)", v11.Name, v11.RarityName, v11.Category)
			end

			table.insert(tbl21.EggOptions, str3)
			tbl21.EggCategory[str3] = v11.Category
		end

		local function fn38(arg)
			local directory2 = tbl.Assets and tbl.Assets.Directory
			return type(directory2) == "table" and directory2[tostring(arg)] or nil
		end

		local function fn39(arg)
			local v11 = fn38(arg.AssetCategory)
			local rarity = type(v11) == "table" and v11.Rarity or nil
			local flag4 = type(rarity) == "table"

			if flag4 then
				flag4 = tonumber(rarity.RarityNumber or rarity.Rank)
			end

			return flag4 or 0
		end

		local function fn40(arg)
			local v11 = fn38(arg.AssetCategory)
			local n16 = type(v11) == "table" and tonumber(v11.EarningRate) or 0
			local n17 = tonumber(arg.AssetScale) or 0
			if n16 <= 0 or n17 <= 0 then
				return 0
			end
			return n16 * (n17 > 5 and (n17 / 5) ^ 1.2 * 19.637875755794113 or n17 ^ 1.85)
		end

		local function fn41(arg)
			if tostring(arg.BaseMutation or "") == "Scrambled" then
				return true
			end

			if type(arg.Mutations) == "table" then
				for k, mutation in pairs(arg.Mutations) do
					if type(mutation) == "string" and mutation == "Scrambled" then
						return true
					end

					if type(k) == "string" and k == "Scrambled" and mutation ~= false then
						return true
					end
				end
			end

			return false
		end

		local function fn42()
			local eggState = tbl.EggState
			if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
				return {}
			end
			local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
			if not ok or type(result) ~= "table" then
				return {}
			end
			local tbl23 = {}

			for k, v11 in pairs(result) do
				if type(v11) == "table" and v11.Placement ~= nil then
					k = v11.Uid or k
					v11.Uid = k
					tbl23[#tbl23 + 1] = v11
				end
			end

			return tbl23
		end

		local function fn43(arg)
			arg = arg and arg.Uid

			if arg then
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				areaEggSlotsClient = areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(arg)

				if areaEggSlotsClient then
					local ok, result = pcall(function()
						return areaEggSlotsClient:GetPivot().Position
					end)

					if ok and typeof(result) == "Vector3" then
						return result
					end
				end
			end

			if type(tbl4.PenAnchor) == "function" then
				local ok, result = pcall(tbl4.PenAnchor)
				if ok and typeof(result) == "Vector3" then
					return result
				end
			end

			return nil
		end

		local function fn44(arg, arg2)
			local v11 = fn43(arg)
			if v11 == nil then
				return true
			end

			if tbl4.DistanceTo(v11) <= n15 then
				return true
			end

			local function fn45()
				if arg2 ~= tbl21.Loop or not tbl4.Toggle(tbl21.Handle, false) then
					return true
				end

				if tbl4.Movement.PlaceWanted == true then
					return true
				end
				return tbl4.Movement.ScrambleWanted == true or tbl4.Steal.Wanted == true
			end

			if tbl4.Treadmill.Riding or tbl4.OnBelt() then
				tbl4.ExitBelt()
			end

			tbl4.HoldBelt()
			local ok, result = pcall(tbl4.FlyTo, v11 + Vector3.new(0, 3, 0), fn45, "mutation")
			tbl4.ReleaseBelt()
			tbl4.LeaveBelt()
			result = ok and result

			if result then
				local n16 = n15 + 4
				result = tbl4.DistanceTo(v11) <= n16
			end

			return result
		end

		local v11 = fn29

		local function fn45(arg)
			if not arg then
				return 0
			end
			local num = tonumber(arg:GetAttribute("Uses"))
			if num ~= nil then
				return num
			end
			local v12 = string.match(arg.Name, "%[X(%d+)%]")
			return tonumber(v12) or 1
		end

		local function fn46()
			local v12 = v11()
			if not v12 then
				return nil, 0
			end
			local v13 = fn45(v12)
			if v13 <= 0 then
				return nil, 0
			end
			return v12, v13
		end

		tbl21.Grip = function(arg)
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not character or not humanoid or not arg or arg.Parent == nil then
				return false
			end

			if arg.Parent ~= character then
				pcall(function()
					humanoid:EquipTool(arg)
				end)

				if arg.Parent ~= character then
					pcall(function()
						arg.Parent = character
					end)
				end

				task.wait(0.2)
			end

			return arg.Parent == character
		end

		local function fn47()
			if not tbl4.Toggle(tbl21.BuyHandle, false) or flag3 then
				return false
			end
			flag3 = true
			local flag4 = false

			local ok, result = pcall(function()
				flag4 = tbl21.Purchase()
			end)

			flag3 = false

			if not ok then
				tbl21.Status = "Buy failed: " .. tostring(result)
			end

			return flag4
		end

		tbl21.Purchase = function()
			local n16 = 0
			local short = false

			for i = 1, 10 do
				local flag4 = n16 == 0 and fn9(true) or snapshot
				local v12 = fn10()

				if not (type(flag4) ~= "table" or type(v12) ~= "table") then
					local v13, v14, v15 = ipairs(type(flag4.Shop) == "table" and flag4.Shop or {})
					local v16 = nil

					for _, v17 in v13, v14, v15 do
						if type(v17) == "table" and v17.Id == "MutationConsumable" then
							v16 = v17
						end
					end

					if v16 then
						local num = tonumber(v16.PurchaseLimit)

						if not (num and fn30(v12, v16) >= num) then
							local huge = tonumber(v16.Price) or math.huge

							if (tonumber(v12.Samples) or 0) - huge < n4 then
								short = true

								if n16 == 0 then
									tbl21.Status = "Need " .. tostring(math.floor(huge)) .. " Samples"
								end

								break
							else
								local Shop = fn8("Shop", v16.Id, { Quote = v16.Quote, Sequence = tonumber(v12.ShopSequence) or 0 })

								if not (type(Shop) ~= "table" or Shop.Ok ~= true) then
									n16 += 1
									task.wait(0.4)
									continue
								end
							end
						end
					end
				end

				break
			end

			if n16 > 0 then
				tbl21.Status = string.format("Bought %d Scrambled", n16)
				tbl21.Short = short
				return true
			end

			tbl21.Short = short
			return false
		end

		local function fn48()
			local pen = 0
			local match = 0
			local n16 = -1
			local v12 = nil

			for _, v13 in ipairs(fn42()) do
				pen += 1
				local skipMutated = tbl21.SkipMutated and fn41(v13)
				local flag4 = false

				if skipMutated then
					flag4 = true
				end

				local flag5 = not flag4

				if flag5 then
					local minRarity = tbl21.MinRarity
					flag5 = fn39(v13) < minRarity
				end

				if flag5 then
					flag4 = true
				end

				local flag6 = not flag4 and tbl21.MinIncome > 0

				if flag6 then
					local minIncome = tbl21.MinIncome
					flag6 = fn40(v13) < minIncome
				end

				if flag6 then
					flag4 = true
				end

				if not flag4 and next(tbl21.Targets) ~= nil and tbl21.Targets[tostring(v13.AssetCategory)] ~= true then
					flag4 = true
				end

				if not flag4 then
					match += 1
					local n17

					if tbl21.Priority == tbl19[2] then
						n17 = fn39(v13) * 1000 + (tonumber(v13.AssetScale) or 0)
					elseif tbl21.Priority == tbl19[3] then
						n17 = tonumber(v13.AssetScale) or 0
					else
						n17 = fn40(v13)
					end

					local flag7 = n17 > n16

					if not flag7 and v12 ~= nil and n17 == n16 and v13.Uid == tbl21.Locked then
						n16 = n17
						v12 = v13
					elseif flag7 then
						n16 = n17
						v12 = v13
					end
				end
			end

			local v13 = tbl21
			tbl21.Pen = pen
			v13.Match = match
			return v12
		end

		local function fn49(arg)
			if typeof(arg) ~= "Color3" then
				return "#FFFFFF"
			end
			return string.format("#%02X%02X%02X", math.floor(arg.R * 255 + 0.5), math.floor(arg.G * 255 + 0.5), math.floor(arg.B * 255 + 0.5))
		end

		local function fn50(arg)
			local ok, result = pcall(Color3.fromHex, arg)
			if not ok or typeof(result) ~= "Color3" then
				return arg
			end
			local v12, v13, v14 = result:ToHSV()
			return fn49(Color3.fromHSV(v12, math.min(v13, 0.78), math.max(v14, 0.82)))
		end

		local function fn51(arg)
			local v12 = fn38(arg and arg.AssetCategory)
			local icon = type(v12) == "table" and v12.Icon or nil
			if icon == nil then
				return ""
			end

			if tonumber(icon) then
				return "rbxassetid://" .. tostring(icon)
			end
			return tostring(icon)
		end

		local function fn52(arg)
			local v12 = fn38(arg and arg.AssetCategory)
			local rarity = type(v12) == "table" and v12.Rarity or nil
			local flag4 = type(rarity) == "table"

			if flag4 then
				flag4 = tostring(rarity.DisplayName or rarity._id or "")
			end

			flag4 = flag4 or ""
			local v13 = table.pack(fn50(fn49(type(rarity) == "table" and rarity.Color or nil)))
			return flag4, table.unpack(v13, 1, v13.n)
		end

		local function fn53(arg)
			if type(arg) ~= "table" then
				return "No egg selected"
			end
			local v12 = fn38(arg.AssetCategory)
			local flag4 = type(v12) == "table"

			if flag4 then
				flag4 = tostring(v12.DisplayName or arg.AssetCategory)
			end

			return flag4 or tostring(arg.AssetCategory)
		end

		local function fn54()
			local idle = tbl20[tbl21.State] or tbl20.idle

			if tbl21.Ui.Accent and type(tbl21.Ui.Accent.Set) == "function" then
				tbl21.Ui.Accent.Set({ Background = idle })
			end

			if tbl21.Ui.Title and type(tbl21.Ui.Title.Set) == "function" then
				tbl21.Ui.Title.Set({ Text = tbl21.Status, Color = idle })
			end

			if tbl21.Ui.Egg and type(tbl21.Ui.Egg.Set) == "function" then
				tbl21.Ui.Egg.Set({ Text = tbl21.Detail, Color = tbl21.RarityColor })
			end

			if tbl21.Ui.Meta and type(tbl21.Ui.Meta.Set) == "function" then
				tbl21.Ui.Meta.Set({
					Text = string.format("Charges %d  Eggs %d/%d  Tries %d  Applied %d", tbl21.Left, tbl21.Match, tbl21.Pen, tbl21.Tries, tbl21.Hits),
				})
			end

			if tbl21.Ui.Icon and type(tbl21.Ui.Icon.Set) == "function" then
				tbl21.Ui.Icon.Set({ Visible = tbl21.Icon ~= "", Image = tbl21.Icon, StrokeColor = tbl21.RarityColor })
			end

			if tbl21.Row and type(tbl21.Row.Set) == "function" then
				pcall(tbl21.Row.Set, tbl21.Row, tbl21.Status .. "  -  " .. tbl21.Detail)
			end
		end

		local function fn55(arg)
			if type(arg) ~= "table" then
				tbl21.Detail = "No egg matches the filters"
				tbl21.RarityColor = "#C7CBD6"
				tbl21.Icon = ""
				return
			end

			local v12, v13 = fn52(arg)
			local n16 = tonumber(arg.AssetScale) or 0
			tbl21.Detail = string.format("%s   %.2f kg", fn53(arg), n16)

			if v12 ~= "" then
				tbl21.Detail = tbl21.Detail .. "   " .. string.upper(v12)
			end

			tbl21.RarityColor = v13
			tbl21.Icon = fn51(arg)
		end

		tbl21.Apply = function(arg, arg2)
			if not tbl21.Grip(arg2) then
				tbl21.State = "work"
				tbl21.Status = "Could not hold Scrambled"
				tbl21.Cooldown = os.clock() + 2
				return false
			end

			local packages = ReplicatedStorage:FindFirstChild("Packages")
			packages = packages and packages:FindFirstChild("Networking")
			local rfBossMasteryAskUseMutationConsu = packages and packages:FindFirstChild("RF/BossMastery/AskUseMutationConsumable")

			if not rfBossMasteryAskUseMutationConsu or not rfBossMasteryAskUseMutationConsu:IsA("RemoteFunction") then
				tbl21.State = "stop"
				tbl21.Status = "Mutation remote is missing"
				tbl21.Cooldown = os.clock() + 10
				return false
			end

			tbl21.State = "work"
			tbl21.Status = "Applying Scrambled"
			tbl21.Tries = tbl21.Tries + 1

			local ok, result = pcall(function()
				return rfBossMasteryAskUseMutationConsu:InvokeServer(arg.Uid)
			end)

			if not ok or type(result) ~= "table" then
				tbl21.Cooldown = os.clock() + 10
				return false
			end

			if result.Success == true then
				tbl21.Status = "Scrambled applied"
				tbl21.Locked = nil
				tbl21.State = "good"
				tbl21.Hits = tbl21.Hits + 1
				return true
			end

			local str3 = tostring(result.Message or "")
			local v12 = string.lower(str3)
			tbl21.Status = str3 ~= "" and str3 or "Try failed"
			tbl21.State = "work"

			if string.find(v12, "not found") or string.find(v12, "invalid") then
				tbl21.Locked = nil
				tbl21.Cooldown = os.clock() + 3
				return false
			end

			return true
		end

		tbl21.Settle = function()
			local n16 = os.clock() + 3

			while os.clock() < n16 do
				if tbl4.Grounded() then
					return
				end
				RunService.Heartbeat:Wait()
			end
		end

		tbl21.Over = function(arg)
			if arg ~= tbl21.Loop or not tbl4.Toggle(tbl21.Handle, false) then
				return true
			end

			if tbl4.Movement.PlaceWanted == true then
				return true
			end
			return tbl4.Movement.ScrambleWanted == true or tbl4.Steal.Wanted == true
		end

		tbl21.Idle = function(status, detail, arg)
			tbl21.State = "idle"
			tbl21.Status = status
			tbl21.Left = 0
			tbl21.Detail = detail
			tbl21.RarityColor = "#C7CBD6"
			tbl21.Icon = ""
			tbl21.Cooldown = os.clock() + (arg or 5)
		end

		local function fn56(arg)
			if tbl4.Movement.ScrambleWanted == true or tbl4.Steal.Wanted == true then
				tbl21.State = "work"
				tbl21.Status = tbl4.Movement.ScrambleWanted == true and "Drone hunt goes first" or "Auto Steal goes first"
				tbl21.Cooldown = os.clock() + 2
				return
			end

			local cooldown = tbl21.Cooldown
			if os.clock() < cooldown then
				return
			end
			local v12, v13 = fn46()

			if not v12 then
				pcall(fn48)
				if fn47() then
					tbl21.Cooldown = os.clock() + 0.5
					return
				end

				if tbl21.Short then
					tbl21.Idle("Out of Samples, waiting for more", "Hunt drones to earn Samples", 10)
					return
				end

				if not string.find(tbl21.Status, "Samples", 1, true) then
					tbl21.Status = "Need a Scrambled consumable"
				end

				tbl21.Idle(tbl21.Status, "Buy Scrambled from the event shop", 5)
				return
			end

			tbl21.Left = v13
			local v14 = fn48()

			if not v14 or not v14.Uid then
				tbl21.State = "stop"
				tbl21.Status = "Waiting"
				fn55(nil)
				return
			end

			if tbl4.Movement.PlaceWanted == true then
				tbl21.State = "work"
				tbl21.Status = "Auto Place goes first"
				tbl21.Cooldown = os.clock() + 2
				return
			end

			if not tbl4.ClaimMovement("mutation") then
				tbl21.State = "work"
				tbl21.Status = "Waiting for " .. tostring(tbl4.Movement.Owner or "movement")
				tbl21.Cooldown = os.clock() + 2
				return
			end

			tbl4.Movement.MutationWanted = true

			local ok, result = pcall(function()
				while not tbl21.Over(arg) do
					local v15, v16 = fn46()

					if v15 then
						tbl21.Left = v16
						local v17 = fn48()

						if not v17 or not v17.Uid then
							tbl21.State = "stop"
							tbl21.Status = "Waiting"
							fn55(nil)
							break
						else
							if v17.Uid ~= tbl21.Locked then
								tbl21.Locked = v17.Uid
								tbl21.Status = "New target picked"
							end

							fn55(v17)

							if not fn44(v17, arg) then
								tbl21.State = "work"
								tbl21.Status = "Could not reach the egg"
								tbl21.Cooldown = os.clock() + 3
								break
							elseif not tbl21.Over(arg) then
								if tbl21.Apply(v17, v15) then
									pcall(fn54)
									task.wait(0.35)
									continue
								end
							end
						end
					end

					break
				end
			end)

			if not ok then
				tbl21.Status = "Stopped: " .. tostring(result)
				tbl21.State = "work"
				tbl21.Cooldown = os.clock() + 3
			end

			tbl21.Settle()
			tbl4.Movement.MutationWanted = false
			tbl4.ReleaseMovement("mutation")
		end

		tbl21.Handle = v6:CreateToggle({
			Name = "Auto Use Scrambled Mutation",
			Default = false,
			Callback = function(arg)
				tbl21.Loop = tbl21.Loop + 1
				tbl4.Movement.MutationWanted = false
				tbl4.ReleaseMovement("mutation")
				if arg ~= true then
					return
				end
				local loop = tbl21.Loop

				task.spawn(function()
					while loop == tbl21.Loop and tbl4.Toggle(tbl21.Handle, false) do
						pcall(fn56, loop)
						pcall(fn54)
						task.wait(tbl21.State == "idle" and 3 or 1)
					end
				end)
			end,
		})

		if type(v6.CreateCanvas) == "function" then
			local v12 = v6:CreateCanvas({
				Name = "Scrambled Status",
				ShowTitle = false,
				Layout = "free",
				SubOf = tbl21.Handle,
				Style = {
					TextScale = 1,
					LineHeight = 1.1,
					MinLines = 4,
					MaxLines = 4,
					AutoHeight = true,
					BackgroundTransparency = 0.35,
					TextColor = Color3.fromRGB(255, 255, 255),
					TextStrokeTransparency = 0.7,
				},
				Build = function(arg)
					tbl21.Ui.Card = arg:Frame({
						X = 0,
						Y = 0,
						Width = 1,
						Height = 3.6,
						Corner = 0.3,
						Background = "#151821",
						BackgroundTransparency = 0.25,
					})

					tbl21.Ui.Accent = arg:Frame({
						Parent = tbl21.Ui.Card,
						X = 0.08,
						Y = 0.18,
						Width = 0.16,
						Height = 3.24,
						Corner = 0.2,
						Background = tbl20.idle,
					})

					tbl21.Ui.Icon = arg:Image({
						Parent = tbl21.Ui.Card,
						X = 0.42,
						Y = 0.3,
						Width = 3,
						Height = 3,
						Corner = 0.3,
						Background = "#242938",
						BackgroundTransparency = 0.1,
						StrokeThickness = 0.06,
						StrokeTransparency = 0,
						Visible = false,
					})

					tbl21.Ui.Title = arg:Text({
						Parent = tbl21.Ui.Card,
						X = 3.7,
						Y = 0.32,
						Width = 1,
						Height = 1.05,
						Scale = 1.16,
						Wrap = false,
						Text = tbl21.Status,
						Color = tbl20.idle,
						TextStrokeTransparency = 1,
					})

					tbl21.Ui.Egg = arg:Text({
						Parent = tbl21.Ui.Card,
						X = 3.7,
						Y = 1.42,
						Width = 1,
						Height = 1,
						Scale = 1,
						Wrap = false,
						Text = tbl21.Detail,
						Color = "#FFFFFF",
						TextStrokeTransparency = 1,
					})

					tbl21.Ui.Meta = arg:Text({
						Parent = tbl21.Ui.Card,
						X = 3.7,
						Y = 2.42,
						Width = 1,
						Height = 0.9,
						Scale = 0.86,
						Wrap = false,
						Text = "Charges 0  Eggs 0/0  Tries 0  Applied 0",
						Color = "#AEB4C6",
						TextStrokeTransparency = 1,
					})

					fn54()
				end,
			})

			fn4(function()
				pcall(function()
					v12:Destroy()
				end)
			end)
		else
			tbl21.Row = v6:CreateText({ Name = "Scrambled Status", Text = "Idle", SubOf = tbl21.Handle })
		end

		v6:CreateDropdown({
			Name = "Mutation Min Rarity",
			Note = "Only eggs of this rarity and above are used",
			Options = tbl8,
			Default = tbl8[1],
			SubOf = tbl21.Handle,
			Callback = function(arg)
				tbl21.MinRarity = tbl9[arg] or 0
			end,
		})

		local tbl23 = {
			["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
			["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
			["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
		}

		local tbl24 = { Slider = nil, Value = 0, Unit = "M/s" }

		local function fn57(arg, arg2)
			if arg ~= nil then
				tbl24.Value = math.max(0, math.floor(tonumber(arg) or tbl24.Value))
			end

			if arg2 ~= nil then
				tbl24.Unit = tostring(arg2)
			end

			tbl21.MinIncome = tbl24.Value * (tbl23[tbl24.Unit] or tbl23["M/s"]).Mult
		end

		tbl24.Slider = fn5(v6, {
			Name = "Min Mutation Value",
			Note = "Skip eggs worth less than this (0 = off)",
			SubOf = tbl21.Handle,
			Legacy = "Mutation Min Value",
			SectionName = "Dr Scramble Event",
			OnRaw = function(arg)
				fn57(math.floor(arg / 1000), "K/s")
			end,
		})

		v6:CreateDropdown({
			Name = "Mutation Priority",
			Note = "Which egg gets the consumable first",
			Options = tbl19,
			Default = tbl19[1],
			SubOf = tbl21.Handle,
			Callback = function(arg)
				tbl21.Priority = tostring(arg)
			end,
		})

		fn6(v6:CreateMultiDropdown({
			Name = "Mutation Target Eggs",
			Note = "Only use the consumable on these eggs (empty = all)",
			Options = tbl21.EggOptions,
			Default = {},
			SubOf = tbl21.Handle,
			Callback = function(arg)
				local targets = {}

				if type(arg) == "table" then
					for k, v12 in pairs(arg) do
						k = v12 == true and type(k) == "string" and k or type(v12) == "string" and v12
						local v13 = k or nil

						if v13 and tbl21.EggCategory[v13] then
							targets[tbl21.EggCategory[v13]] = true
						end
					end
				end

				tbl21.Targets = targets
			end,
		}))

		tbl21.BuyHandle = v6:CreateToggle({
			Name = "Auto Buy Scrambled",
			Note = "Buy another Scrambled from the event shop when you run out",
			Default = false,
			SubOf = tbl21.Handle,
			Callback = function()
				tbl21.Cooldown = 0
			end,
		})

		fn4(function()
			tbl21.Loop = tbl21.Loop + 1
			tbl4.Movement.MutationWanted = false
			tbl4.ReleaseMovement("mutation")
		end)
	end

	do
		local n15 = nil
		local flag4 = false
		local flag5 = false

		tbl3.Add(function()
			if not flag5 and os.clock() - n5 >= n then
				flag5 = true

				task.spawn(function()
					pcall(fn9, true)
					flag5 = false
				end)
			end

			local flag6 = nil

			if v8 then
				flag6 = type(v8.Set) == "function"
			end

			if flag6 then
				pcall(v8.Set, nil, fn15())
			end

			local flag7 = nil

			if v10 then
				flag7 = type(v10.Set) == "function"
			end

			if flag7 then
				pcall(v10.Set, nil, fn33())
			end

			local v11 = fn12()
			local v12 = tbl4.IsNight()

			if v11 and not flag4 then
				tbl16.Latch = v12
				tbl16.Ended = false
			end

			if not v12 then
				tbl16.Latch = false
			elseif v11 and not tbl16.Latch and not tbl16.Ended then
				tbl16.Ended = true
				str = "Night arrived, this outbreak is over"
				table.clear(tbl12)
				table.clear(tbl13)
			end

			if not v11 then
				tbl16.Ended = false
			end

			if flag4 and not v11 then
				task.delay(15, function()
					if not fn12() then
						table.clear(tbl12)
						table.clear(tbl18)
					end
				end)
			end

			flag4 = v11

			if tbl4.Toggle(nil, false) and not flag3 and os.clock() >= n9 and fn11() then
				flag3 = true
				n9 = os.clock() + 8

				task.spawn(function()
					pcall(fn31, function()
						return not tbl4.Toggle(nil, false)
					end)

					flag3 = false
				end)
			end

			local v13 = fn34()
			local v14 = fn35()
			tbl4.Movement.ScrambleWanted = v13 or v14
			local invisibilityHandle = tbl4.InvisibilityHandle
			local flag8 = invisibilityHandle ~= nil and tbl4.Toggle(invisibilityHandle, false)

			if v13 then
				n15 = nil

				if not tbl4.InvisSuspended then
					tbl4.InvisSuspended = true
					flag8 = flag8 and type(v.Notify) == "function"

					if flag8 then
						pcall(v.Notify, "Invisibility", "Invisibility is paused for the drone hunt and comes back after it.", 5)
					end
				end
			elseif tbl4.InvisSuspended and not flag then
				n15 = n15 or os.clock() + 5

				if os.clock() >= n15 then
					n15 = nil
					tbl4.InvisSuspended = false

					if flag8 and type(v.Notify) == "function" then
						pcall(v.Notify, "Invisibility", "The drone hunt is over, Invisibility is back on.", 5)
					end
				end
			end

			local character = localPlayer.Character
			if v13 and not flag and character and character:GetAttribute("InvisApplied") == true then
				str = "Leaving Invisibility for the hunt"
				return true
			end

			if flag then
				return v13
			end

			if not (v13 or v14) or os.clock() < n7 then
				if not v13 and not v14 then
					str = ""
				end

				return false
			end

			local steal = tbl4.Steal
			if steal.Active or steal.Carrying or steal.Wanted then
				str = "Auto Steal goes first"
				return v13
			end

			if not tbl4.ClaimMovement("scramble") then
				str = "Waiting for " .. tostring(tbl4.Movement.Owner or "movement") .. " to finish"
				return v13
			end
			flag = true
			n7 = os.clock() + n2
			local v15 = n6

			task.spawn(function()
				pcall(fn37, function()
					return v15 ~= n6
				end)

				tbl4.HoldBelt()
				pcall(fn36, v15)
				fn32()
				tbl4.ReleaseBelt()
				tbl4.ReleaseMovement("scramble")
				flag = false
				tbl3.Wake()
			end)

			return v13
		end)
	end

	fn4(function()
		n6 += 1
		fn32()
		tbl4.InvisSuspended = false
		tbl4.Movement.ScrambleWanted = false
		tbl4.ReleaseMovement("scramble")
	end)

	local v11, v12

	do

-- === Extracted Anti Guard runtime ===
	TweenService = game:GetService("TweenService")
	GuiService = game:GetService("GuiService")
	StarterGui = game:GetService("StarterGui")
	antiGuard = tbl4.AntiGuard

	tbl14 = {
		Target = "line",
		LineOffset = 8,
		Height = 45,
		OffsetX = -90,
		OffsetZ = -35,
		Jitter = 0,
		Point = false,
		Disguise = true,
		Limp = true,
		Facing = "Zero",
		Freeze = false,
		StartAt = 0,
		Steps = {
			{ At = 0.1, To = "home" },
			{ At = 0.33, To = "home" },
			{ At = 0.56, To = "home" },
			{ At = 0.75, To = "start" },
		},
		ReleaseAt = 0.8,
		WeldScanGap = 0.03,
		BusyLimit = 2.5,
	}

	local function fn20(arg, arg2, arg3, arg4, arg5, arg6)
		local tbl15 = {}

		for i = 1, arg do
			tbl15[#tbl15 + 1] = { At = arg2 + arg3 * (i - 1), To = "home" }
		end

		tbl15[#tbl15 + 1] = { At = arg4, To = "start" }

		return {
			Target = "home",
			LineOffset = 8,
			Height = 0,
			OffsetX = 0,
			OffsetZ = 0,
			Jitter = 0,
			Point = false,
			Disguise = true,
			Limp = false,
			Facing = "Zero",
			Freeze = true,
			StartAt = 0,
			StartRandom = 0,
			HopRandom = 0.085,
			HoldRandom = 0.395,
			Steps = tbl15,
			ReleaseAt = arg5,
			WeldScanGap = 0.03,
			BusyLimit = arg6,
		}
	end

	chilliAntiGuard = { LightDark = tbl14, Default = fn20(25, 0, 0.05, 1.27, 1.52, 2.5) }
end

pcall(function()
	getgenv().ChilliAntiGuard = chilliAntiGuard
end)

local tbl15

tbl15 = {
	Card = Color3.fromRGB(15, 15, 19),
	CardTop = Color3.fromRGB(24, 22, 28),
	Stroke = Color3.fromRGB(48, 46, 56),
	Text = Color3.fromRGB(240, 238, 244),
	AccentA = Color3.fromRGB(255, 72, 72),
	AccentB = Color3.fromRGB(255, 150, 60),
	Good = Color3.fromRGB(80, 220, 140),
	Work = Color3.fromRGB(255, 190, 70),
	Bad = Color3.fromRGB(240, 90, 90),
	Off = Color3.fromRGB(58, 56, 66),
}

local tbl16

tbl16 = {
	{ Path = { "GearGiver_Slap", "Podium" }, Offset = Vector3.new(-16.415, 21.072, -6.106) },
	{
		Path = { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
		Offset = Vector3.new(-26.776, 1.75, 18.665),
	},
	{
		Path = { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
		Offset = Vector3.new(-26.776, 1.75, 18.665),
	},
}

local n4
n4 = 52
local flag4
flag4 = true
local tbl17
tbl17 = {}
local tbl18

tbl18 = {
	AreaId = nil,
	SignalCarrying = false,
	WeldCarrying = false,
	Carrying = false,
	Active = false,
	Disguise = nil,
	FlashRequest = nil,
	FlashUntil = 0,
}

local fn19

fn19 = function()
	local tbl19 = {}

	for i = 1, math.random(10, 16) do
		tbl19[i] = string.char(math.random(97, 122))
	end

	return table.concat(tbl19)
end

local hui
hui = nil

pcall(function()
	hui = gethui()
end)

hui = hui or CoreGui
local fn20

fn20 = function(arg, parent, arg2)
	local instance = Instance.new(arg)
	instance.Name = fn19()
	local v10 = pairs
	local tbl19 = arg2 or {}

	for k, v11 in v10(tbl19) do
		instance[k] = v11
	end

	instance.Parent = parent
	return instance
end

local fn21

fn21 = function(arg, arg2, arg3, arg4)
	local ok, result = pcall(function()
		local v10 = TweenService
		local create = v10.Create
		local tweenInfo = TweenInfo.new
		local v11 = arg4
		local quint

		if arg4 then
			quint = v11
		else
			quint = Enum.EasingStyle.Quint
		end

		return create(v10, arg, tweenInfo(arg2, quint, Enum.EasingDirection.Out), arg3)
	end)

	if ok and result then
		result:Play()
	end
end

local ScreenGui

ScreenGui = fn20("ScreenGui", nil, {
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = -100,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local Frame

Frame = fn20("Frame", ScreenGui, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 1, -120),
	Size = UDim2.fromOffset(226, 52),
	BackgroundTransparency = 1,
})

local UIScale
UIScale = fn20("UIScale", Frame, { Scale = 1 })
local Frame2
Frame2 = fn20("Frame", Frame, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = tbl15.Card, BorderSizePixel = 0, Active = true })
fn20("UICorner", Frame2, { CornerRadius = UDim.new(0, 14) })
local UIScale2
UIScale2 = fn20("UIScale", Frame2, { Scale = 0.86 })
fn20("UIGradient", Frame2, { Color = ColorSequence.new(tbl15.CardTop, tbl15.Card), Rotation = 90 })
local UIGradient, Frame3, render, fn22

do
	local UIStroke = fn20("UIStroke", Frame2, {
		Thickness = 1.5,
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})

	UIGradient = fn20("UIGradient", UIStroke, { Color = ColorSequence.new(tbl15.Stroke, tbl15.Stroke) })

	Frame3 = fn20("Frame", Frame2, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = Color3.fromRGB(28, 26, 32),
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	fn20("UICorner", Frame3, { CornerRadius = UDim.new(0, 11) })
	local UIStroke2 = fn20("UIStroke", Frame3, { Thickness = 1.5, Color = tbl15.Off, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })

	local ImageLabel = fn20("ImageLabel", Frame3, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.86, 0.86),
		BackgroundTransparency = 1,
		Image = "rbxassetid://128961717706452",
		ImageTransparency = 0.35,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 3,
	})

	fn20("UICorner", ImageLabel, { CornerRadius = UDim.new(0, 8) })
	local UIScale3 = fn20("UIScale", ImageLabel, { Scale = 1 })
	local color3 = Color3.fromRGB

	fn20("UIGradient", fn20("TextLabel", Frame2, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 7),
		Size = UDim2.new(1, -112, 0, 15),
		Font = Enum.Font.BuilderSansExtraBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Chilli Hub",
		ZIndex = 2,
	}), { Color = ColorSequence.new(Color3.fromRGB(255, 120, 100), color3(255, 190, 110)) })

	fn20("TextLabel", Frame2, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 22),
		Size = UDim2.new(1, -112, 0, 20),
		Font = Enum.Font.GothamBlack,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = tbl15.Text,
		Text = "Anti Guard",
		ZIndex = 2,
	})

	local TextButton = fn20("TextButton", Frame2, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 2,
	})

	fn20("UICorner", TextButton, { CornerRadius = UDim.new(1, 0) })
	local UIGradient2 = fn20("UIGradient", TextButton, { Color = ColorSequence.new(tbl15.Off, tbl15.Off) })

	local Frame4 = fn20("Frame", TextButton, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.fromRGB(245, 245, 250),
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	fn20("UICorner", Frame4, { CornerRadius = UDim.new(1, 0) })

	local function fn23()
		return antiGuard.Enabled and tbl15.AccentA or tbl15.Off
	end

	render = function(arg)
		local n5 = arg and 0 or 0.28

		if antiGuard.Enabled then
			UIGradient2.Color = ColorSequence.new(tbl15.AccentA, tbl15.AccentB)
			local v10 = UIGradient
			local colorSequence = ColorSequence.new
			local tbl19 = {}
			local v11 = ColorSequenceKeypoint.new(0, tbl15.Stroke)
			local v12 = ColorSequenceKeypoint.new(0.45, tbl15.AccentA)
			local v13 = ColorSequenceKeypoint.new(0.55, tbl15.AccentB)
			local new = ColorSequenceKeypoint.new
			local stroke = tbl15.Stroke
			tbl19[1] = v11
			tbl19[2] = v12
			tbl19[3] = v13

			do
				local values = table.pack(new(1, stroke))
				table.move(values, 1, values.n, 4, tbl19)
			end

			v10.Color = colorSequence(tbl19)
			fn21(Frame4, n5, { Position = UDim2.new(1, -19, 0.5, 0) }, Enum.EasingStyle.Back)
			fn21(ImageLabel, n5, { ImageTransparency = 0 })
			fn21(UIStroke, 0.3, { Transparency = 0 })
		else
			UIGradient2.Color = ColorSequence.new(tbl15.Off, tbl15.Off)
			UIGradient.Color = ColorSequence.new(tbl15.Stroke, tbl15.Stroke)
			fn21(Frame4, n5, { Position = UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
			fn21(ImageLabel, n5, { ImageTransparency = 0.35 })
			fn21(UIStroke, 0.3, { Transparency = 0.2 })
		end

		if tbl18.FlashUntil <= os.clock() then
			fn21(UIStroke2, n5, { Color = fn23() })
		end
	end

	fn22 = function(arg, arg2)
		tbl18.FlashRequest = { Color = arg, Hold = arg2 }
	end

	local function fn24()
		local flashRequest = tbl18.FlashRequest
		if not flashRequest then
			return
		end
		tbl18.FlashRequest = nil
		tbl18.FlashUntil = os.clock() + (flashRequest.Hold or 0)
		fn21(UIStroke2, 0.2, { Color = flashRequest.Color })

		if flashRequest.Hold then
			task.delay(flashRequest.Hold, function()
				local flag5 = flag4

				if flag4 then
					local flashUntil = tbl18.FlashUntil
					flag5 = os.clock() >= flashUntil
				end

				if flag5 then
					fn21(UIStroke2, 0.3, { Color = fn23() })
				end
			end)
		end
	end

	local function fn25(arg)
		local handle = antiGuard.Handle
		if type(handle) ~= "table" then
			return
		end

		for _, v10 in ipairs({ "Set", "SetValue" }) do
			local ok, result = pcall(function()
				return handle[v10]
			end)

			if ok and type(result) == "function" and pcall(result, handle, arg) then
				return
			end
		end
	end

	antiGuard.Render = render

	local TextButton2 = fn20("TextButton", Frame2, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 10,
	})

	tbl17[#tbl17 + 1] = TextButton2.MouseButton1Click:Connect(function()
		antiGuard.Enabled = not antiGuard.Enabled
		render(false)
		fn25(antiGuard.Enabled)
		fn21(UIScale3, 0.12, { Scale = 1.15 })

		task.delay(0.12, function()
			if flag4 then
				fn21(UIScale3, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			end
		end)
	end)

	local size = TextButton.Size

	tbl17[#tbl17 + 1] = TextButton2.MouseEnter:Connect(function()
		fn21(TextButton, 0.15, { Size = size + UDim2.fromOffset(2, 2) })
	end)

	tbl17[#tbl17 + 1] = TextButton2.MouseLeave:Connect(function()
		fn21(TextButton, 0.15, { Size = size })
	end)

	local tbl19 = {
		Hotbar = true,
		HotBar = true,
		Toolbar = true,
		ToolBar = true,
		Backpack = true,
		Inventory = true,
	}

	local tbl20 = {}
	local huge = math.huge
	local huge2 = math.huge
	local rotation = 0
	local n5 = nil

	local function fn26(arg)
		while arg do
			if arg:IsA("GuiObject") and not arg.Visible then
				return false
			end

			if arg:IsA("LayerCollector") then
				return arg.Enabled
			end
			arg = arg.Parent
		end

		return false
	end

	local function fn27()
		local ok, result = pcall(function()
			return GuiService:GetGuiInset().Y
		end)

		return ok and result or 0
	end

	local function fn28(arg)
		local v10 = nil

		for _, descendant in ipairs(arg:GetDescendants()) do
			if descendant:IsA("GuiButton") and descendant.Visible and descendant.AbsoluteSize.Y > 8 and descendant.AbsoluteSize.X > 8 then
				local y = descendant.AbsolutePosition.Y

				if not v10 or y < v10 then
					v10 = y
				end
			end
		end

		return v10 or arg.AbsolutePosition.Y
	end

	local function fn29()
		table.clear(tbl20)
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		if not playerGui then
			return
		end

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant:IsA("GuiObject") and tbl19[descendant.Name] then
				tbl20[#tbl20 + 1] = descendant
			end
		end
	end

	local function fn30()
		local tbl21 = {}

		pcall(function()
			if not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then
				return
			end

			for _, child in ipairs(CoreGui.RobloxGui.Backpack:GetChildren()) do
				if child:IsA("GuiObject") then
					tbl21[#tbl21 + 1] = child
				end
			end
		end)

		for _, v10 in ipairs(tbl20) do
			if v10.Parent then
				tbl21[#tbl21 + 1] = v10
			end
		end

		return tbl21
	end

	local function fn31()
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return
		end
		local viewportSize = currentCamera.ViewportSize
		if viewportSize.X < 10 or viewportSize.Y < 10 then
			return
		end
		local flag5 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		local n6 = math.min(viewportSize.X / 1280, viewportSize.Y / 720)
		local scale = flag5 and math.clamp(n6 * 1.05, 0.6, 0.8) * 0.97 or math.clamp(n6, 0.8, 1.1)
		UIScale.Scale = scale
		local backgroundTransparency = flag5 and 0.3 or 0

		if Frame2.BackgroundTransparency ~= backgroundTransparency then
			Frame2.BackgroundTransparency = backgroundTransparency
			Frame3.BackgroundTransparency = backgroundTransparency
		end

		local n7 = viewportSize.Y - 8 * scale
		local flag6 = false

		for _, v10 in ipairs(fn30()) do
			local ok, result = pcall(fn26, v10)

			if ok and result then
				local absoluteSize = v10.AbsoluteSize
				local y = v10.AbsolutePosition.Y

				if absoluteSize.X > 20 and absoluteSize.Y > 20 and absoluteSize.Y < viewportSize.Y * 0.4 and y + absoluteSize.Y / 2 > viewportSize.Y * 0.5 then
					local ok2, result2 = pcall(fn28, v10)
					y = ok2 and result2 or y
					flag6 = true
					n7 = math.min(n7, y + fn27(v10))
				end
			end
		end

		if flag6 then
			n5 = viewportSize.Y - n7
		elseif n5 then
			n7 = viewportSize.Y - n5
		end

		local n8 = math.max(n7 - (flag5 and 4 or 6) * scale - n4 * scale / 2, n4 * scale / 2 + 8)
		Frame.Position = UDim2.new(0.5, 0, 0, n8)
	end

	tbl17[#tbl17 + 1] = RunService.RenderStepped:Connect(function(deltaTime)
		fn24()
		huge += deltaTime
		huge2 += deltaTime

		if huge >= 3 then
			huge = 0
			pcall(fn29)
		end

		if huge2 >= 0.2 then
			huge2 = 0
			pcall(fn31)
		end

		if antiGuard.Enabled then
			rotation = (rotation + deltaTime * (tbl18.Active and 360 or 90)) % 360
			UIGradient.Rotation = rotation
		end
	end)
end

render(true)

antiGuard.ShowPanel = function(arg)
	ScreenGui.Enabled = arg == true
end

ScreenGui.Enabled = antiGuard.PanelShown == true
ScreenGui.Parent = hui
fn21(UIScale2, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
local fn23

fn23 = function()
	local v10 = tbl4.Root()
	if not v10 then
		return nil
	end

	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Model") and child:FindFirstChild("Hitbox") then
			for _, descendant in ipairs(child:GetDescendants()) do
				if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("RigidConstraint") then
					local ok, result, result2 = pcall(function()
						return descendant.Part0, descendant.Part1
					end)

					if ok and (result == v10 or result2 == v10) then
						return child
					end
				end
			end
		end
	end

	return nil
end

local fn24

do
	local function fn25(arg, parent)
		local tbl19 = {}

		for _, descendant in ipairs(arg:GetDescendants()) do
			tbl19[descendant] = descendant.Archivable

			pcall(function()
				descendant.Archivable = true
			end)
		end

		local archivable = arg.Archivable
		arg.Archivable = true

		local ok, result = pcall(function()
			return arg:Clone()
		end)

		arg.Archivable = archivable

		for k, v10 in pairs(tbl19) do
			pcall(function()
				k.Archivable = v10
			end)
		end

		if not ok or not result then
			return nil
		end
		result.Name = fn19()

		for _, descendant in ipairs(result:GetDescendants()) do
			if descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") or descendant:IsA("ForceField") or descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("WeldConstraint") or descendant:IsA("BodyMover") or descendant:IsA("ProximityPrompt") or descendant:IsA("BillboardGui") then
				pcall(function()
					descendant:Destroy()
				end)
			elseif descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
			elseif descendant:IsA("Humanoid") then
				descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				descendant.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			end
		end

		result.Parent = parent
		return result
	end

	local function fn26(arg, arg2)
		local currentCamera = workspace.CurrentCamera
		if not arg or not currentCamera or tbl18.Disguise then
			return
		end
		arg2 = arg2 or Vector3.zero
		local disguise = { Camera = currentCamera, CameraType = currentCamera.CameraType, CameraCFrame = currentCamera.CFrame, Copies = {}, Hidden = {} }
		tbl18.Disguise = disguise
		local tbl19 = { arg }
		local ok, result = pcall(fn23)

		if ok and result then
			tbl19[#tbl19 + 1] = result
		end

		for _, v10 in ipairs(tbl19) do
			for _, descendant in ipairs(v10:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
					disguise.Hidden[#disguise.Hidden + 1] = descendant
				end
			end
		end

		local function fn27()
			for _, v10 in ipairs(disguise.Hidden) do
				pcall(function()
					v10.LocalTransparencyModifier = 1
				end)
			end

			pcall(function()
				if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
					currentCamera.CameraType = Enum.CameraType.Scriptable
				end

				currentCamera.CFrame = disguise.CameraCFrame
			end)
		end

		fn27()
		disguise.BindName = fn19()

		if not pcall(function()
			RunService:BindToRenderStep(disguise.BindName, Enum.RenderPriority.Last.Value + 1, fn27)
		end) then
			disguise.BindName = nil
			disguise.Link = RunService.RenderStepped:Connect(fn27)
		end

		disguise.Beat = RunService.Heartbeat:Connect(fn27)

		for _, v10 in ipairs(tbl19) do
			local ok2, result2 = pcall(fn25, v10, currentCamera)

			if ok2 and result2 then
				if arg2.Magnitude > 0.01 then
					for _, descendant in ipairs(result2:GetDescendants()) do
						if descendant:IsA("BasePart") then
							pcall(function()
								descendant.CFrame = descendant.CFrame + arg2
							end)
						end
					end
				end

				disguise.Copies[#disguise.Copies + 1] = result2
			end
		end
	end

	fn24 = function()
		local disguise = tbl18.Disguise
		if not disguise then
			return
		end
		tbl18.Disguise = nil

		if disguise.BindName then
			pcall(function()
				RunService:UnbindFromRenderStep(disguise.BindName)
			end)
		end

		if disguise.Link then
			pcall(function()
				disguise.Link:Disconnect()
			end)
		end

		if disguise.Beat then
			pcall(function()
				disguise.Beat:Disconnect()
			end)
		end

		for _, v10 in ipairs(disguise.Hidden) do
			pcall(function()
				v10.LocalTransparencyModifier = 0
			end)
		end

		pcall(function()
			disguise.Camera.CameraType = disguise.CameraType
		end)

		for _, copy in ipairs(disguise.Copies) do
			pcall(function()
				copy:Destroy()
			end)
		end
	end

	local function fn27()
		for _, v10 in ipairs(tbl16) do
			local v11 = workspace

			for _, v12 in ipairs(v10.Path) do
				v11 = v11 and v11:FindFirstChild(v12) or nil
			end

			if v11 and v11:IsA("BasePart") then
				return v11.CFrame:PointToWorldSpace(v10.Offset)
			end
		end

		return Vector3.new(528.7, 70.57, -364.11)
	end

	local function fn28(arg, arg2, arg3, arg4, arg5)
		local cFrame = CFrame.new(arg3) * arg4

		pcall(function()
			arg:PivotTo(cFrame)
		end)

		if (arg2.Position - arg3).Magnitude > 3 then
			pcall(function()
				arg2.CFrame = cFrame
			end)
		end

		if arg5 == false then
			return
		end

		for _, descendant in ipairs(arg:GetDescendants()) do
			if descendant:IsA("BasePart") then
				pcall(function()
					descendant.AssemblyLinearVelocity = Vector3.zero
					descendant.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
	end

	local function fn29()
		local areaId = tbl18.AreaId

		if type(areaId) ~= "string" or areaId == "" then
			areaId = type(tbl4.Steal) == "table" and tbl4.Steal.CarryAreaId or nil
		end

		if type(areaId) ~= "string" or areaId == "" then
			local attribute = localPlayer:GetAttribute("AreaId")
			areaId = type(attribute) == "string" and attribute or nil
		end

		return areaId
	end

	local tbl19 = { lightdark = "LightDark" }

	local function fn30(arg)
		if type(arg) ~= "string" then
			return "Default"
		end
		local lower = string.lower
		local v10 = string.gsub(arg, "[^%a]", "")
		return tbl19[lower(v10)] or "Default"
	end

	local function fn31()
		local ok, result = pcall(function()
			return getgenv().ChilliAntiGuard
		end)

		if ok and type(result) == "table" then
			if type(result.Steps) == "table" then
				return result
			end
			local default = result[fn30(fn29())] or result.Default
			if type(default) == "table" then
				return default
			end
		end

		return chilliAntiGuard[fn30(fn29())] or tbl14
	end

	local function fn32()
		local v10 = fn31()
		local options = antiGuard.Options
		if type(options) ~= "table" or options.Destination == "Safe Zone" and not options.Stay then
			return v10
		end
		local tbl20 = {}

		for k, v11 in pairs(v10) do
			tbl20[k] = v11
		end

		if options.Destination == "Next To Line" then
			tbl20.Target = "edge"
			tbl20.LineOffset = 6
			tbl20.Height = 0
			tbl20.OffsetX = 0
			tbl20.OffsetZ = 0
		elseif options.Destination == "Saved Spot" and typeof(options.Spot) == "Vector3" then
			tbl20.Target = "point"
			tbl20.Point = options.Spot
			tbl20.Height = 0
			tbl20.OffsetX = 0
			tbl20.OffsetZ = 0
		end

		if options.Stay and type(v10.Steps) == "table" then
			local steps = {}

			for _, step in ipairs(v10.Steps) do
				if type(step) == "table" and step.To ~= "start" then
					steps[#steps + 1] = step
				end
			end

			tbl20.Steps = steps
		end

		return tbl20
	end

	local function fn33(arg, arg2)
		local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		world = world and world:FindFirstChild("Areas")
		world = world and world:FindFirstChild("SeparationLine")

		if world and world:IsA("BasePart") then
			local cFrame = world.CFrame
			local v10 = (Vector3.new(0, 1, 0)):Cross(world.Size.X >= world.Size.Z and cFrame.RightVector or cFrame.LookVector)
			local vector = Vector3.new(v10.X, 0, v10.Z)

			if vector.Magnitude > 0.001 then
				local unit = vector.Unit
				local n5 = cFrame.Position + ((arg2 - cFrame.Position):Dot(unit) >= 0 and -unit or unit) * (tonumber(arg.LineOffset) or 8)
				return Vector3.new(n5.X, arg2.Y + 0.5, n5.Z)
			end
		end

		return nil
	end

	local function fn34(arg, arg2)
		local str = tostring(arg.Target or "home")
		if str == "sky" then
			return arg2
		end

		if str == "point" then
			if typeof(arg.Point) == "Vector3" then
				return arg.Point
			end
			return arg2
		end

		if str == "line" then
			local v10 = fn33(arg, arg2)
			if v10 then
				return v10
			end
		end

		if str == "edge" then
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Areas")
			world = world and world:FindFirstChild("SeparationLine")

			if world and world:IsA("BasePart") then
				local cFrame = world.CFrame
				local rightVector = world.Size.X >= world.Size.Z and cFrame.RightVector or cFrame.LookVector
				local vector = Vector3.new(rightVector.X, 0, rightVector.Z)
				local v10 = (Vector3.new(0, 1, 0)):Cross(vector)
				local vector2 = Vector3.new(v10.X, 0, v10.Z)

				if vector2.Magnitude > 0.001 and vector.Magnitude > 0.001 then
					local unit = vector.Unit
					local unit2 = vector2.Unit
					local n5 = arg2 - cFrame.Position
					local n6 = -world.Size.Magnitude / 2
					local n7 = world.Size.Magnitude / 2
					local n8 = cFrame.Position + unit * math.clamp(n5:Dot(unit), n6, n7) + (n5:Dot(unit2) >= 0 and unit2 or -unit2) * (tonumber(arg.LineOffset) or 6)
					local v11 = fn27()
					return Vector3.new(n8.X, (v11 and v11.Y or arg2.Y) + 3, n8.Z)
				end
			end
		end

		return fn27()
	end

	local function fn35(arg, arg2)
		return fn34(arg, arg2) + Vector3.new(tonumber(arg.OffsetX) or 0, tonumber(arg.Height) or 0, tonumber(arg.OffsetZ) or 0)
	end

	local function fn36()
		tbl18.Active = false
		antiGuard.Busy = false
	end

	local function fn37(arg)
		local n5 = math.max(tonumber(arg) or 0, 0)
		if n5 <= 0 then
			return 0
		end
		return (math.random() * 2 - 1) * n5
	end

	local function fn38(arg)
		local steps = type(arg.Steps) == "table" and arg.Steps or {}
		local n5 = tonumber(arg.ReleaseAt) or 0
		local n6 = math.max(tonumber(arg.StartAt) or 0, 0)
		local n7 = math.max(tonumber(arg.StartRandom) or 0, 0)
		local n8 = math.max(tonumber(arg.HopRandom) or 0, 0)
		local n9 = math.max(tonumber(arg.HoldRandom) or 0, 0)
		if n7 <= 0 and n8 <= 0 and n9 <= 0 then
			return steps, n5, n6
		end
		local n10 = math.max(n6 + fn37(n7), 0)
		local tbl20 = {}
		local n11 = 0
		local n12 = 0

		for i, step in ipairs(steps) do
			if type(step) == "table" then
				local n13 = math.max(tonumber(step.At) or 0, 0)
				n12 = math.max(n12 + math.max(n13 - n11, 0) + fn37(step.To == "start" and n9 or n8), n10)
				tbl20[i] = { At = n12, To = step.To, Glide = step.Glide }
				n11 = n13
				continue
			end

			break
		end

		return tbl20, n12 + math.max(n5 - n11, 0), n10
	end

	local function fn39(arg)
		local character = localPlayer.Character
		local v10 = tbl4.Root()
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not v10 or not humanoid or humanoid.Health <= 0 then
			fn36()
			fn22(tbl15.Bad, 1.6)
			return
		end

		local function fn40()
			return flag4 and v10.Parent ~= nil and humanoid.Parent ~= nil and humanoid.Health > 0
		end

		local platformStand = humanoid.PlatformStand
		local cFrame = v10.CFrame
		local position = cFrame.Position
		local v11 = fn32()
		local v12, v13, v14 = fn38(v11)
		local flag5 = v11.Freeze ~= false
		local str = tostring(v11.Facing or "Keep")
		local n5 = math.max(tonumber(v11.Jitter) or 0, 0)
		local cframe = str == "Zero" and CFrame.new() or cFrame.Rotation

		local function fn41()
			if str == "Spin" then
				return CFrame.Angles(0, math.rad(math.random(0, 359)), 0)
			end
			return cframe
		end

		local function fn42(arg2)
			if n5 <= 0 then
				return arg2
			end
			return arg2 + Vector3.new((math.random() * 2 - 1) * n5, 0, (math.random() * 2 - 1) * n5)
		end

		local v15 = fn35(v11, position)

		local function fn43(arg2)
			while fn40() and os.clock() - arg < arg2 do
				RunService.Heartbeat:Wait()

				if flag5 then
					pcall(function()
						v10.AssemblyLinearVelocity = Vector3.zero
						v10.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end

			return fn40()
		end

		local function fn44(arg2, arg3)
			fn28(character, v10, arg2, arg3, flag5)
			RunService.PreSimulation:Wait()

			if fn40() and (v10.Position - arg2).Magnitude > 3 then
				fn28(character, v10, arg2, arg3, flag5)
			end
		end

		pcall(function()
			humanoid.BreakJointsOnDeath = false
		end)

		if v11.Disguise ~= false then
			pcall(fn26, character, Vector3.zero)
		end

		fn22(tbl15.Work)

		if fn43(v14) and v11.Limp ~= false then
			humanoid.PlatformStand = true
		end

		local v16 = position

		for _, v17 in ipairs(v12) do
			local flag6 = type(v17) ~= "table"

			if not flag6 then
				flag6 = not fn43(tonumber(v17.At) or 0)
			end

			if not flag6 then
				local flag7 = v17.To == "start" and position or fn42(v15)
				local v18 = fn41()

				if type(v17.Glide) == "table" and #v17.Glide > 0 then
					for _, v19 in ipairs(v17.Glide) do
						if fn40() then
							local clamp = math.clamp
							local n6 = tonumber(v19) or 1
							local v20 = fn28
							local v21 = clamp(n6, 0, 1)
							v20(character, v10, v16:Lerp(flag7, v21), v18, flag5)
							RunService.Heartbeat:Wait()
							continue
						end

						break
					end

					v16 = flag7
				else
					fn44(flag7, v18)
					v16 = flag7
				end

				continue
			end

			break
		end

		fn43(v13)

		pcall(function()
			humanoid.PlatformStand = platformStand
		end)

		fn24()
		fn36()

		if fn40() and tbl18.Carrying then
			fn22(tbl15.Good, 1.6)
		else
			fn22(tbl15.Bad, 1.6)
		end
	end

	local function fn40(arg)
		if not pcall(fn39, arg) then
			pcall(function()
				local character = localPlayer.Character
				character = character and character:FindFirstChildOfClass("Humanoid")

				if character then
					character.PlatformStand = false
				end
			end)

			fn24()
			fn36()
			fn22(tbl15.Bad, 1.6)
		end
	end

	local n5 = 25

	local function fn41()
		if antiGuard.HitArms <= 0 then
			return false
		end

		if n5 < os.clock() - (antiGuard.HitArmedAt or 0) then
			antiGuard.HitArms = 0
			return false
		end
		return true
	end

	local function fn42()
		local carrying = tbl18.Carrying
		tbl18.Carrying = tbl18.SignalCarrying or tbl18.WeldCarrying
		local enabled = tbl18.Carrying and not carrying and flag4 and antiGuard.Enabled
		local flag5

		if enabled then
			flag5 = not (tbl4.SafeCarry.LineDrop and tbl4.Steal.Active)
		else
			flag5 = enabled
		end

		if flag5 and not tbl18.Active and not fn41() then
			tbl18.Active = true
			antiGuard.Busy = true
			antiGuard.BusySince = os.clock()
			task.spawn(fn40, os.clock())
		end
	end

	local eggState = tbl.EggState
	local carryChanged = type(eggState) == "table" and eggState.CarryChanged or nil

	if type(carryChanged) == "table" and type(carryChanged.Connect) == "function" then
		local ok, result = pcall(carryChanged.Connect, carryChanged, function(arg)
			local signalCarrying = type(arg) == "table" and arg.IsCarrying == true

			if signalCarrying and arg.GuardDisabled == true then
				signalCarrying = false
			end

			if signalCarrying and type(arg.AreaId) == "string" then
				tbl18.AreaId = arg.AreaId
			end

			if not signalCarrying then
				tbl18.AreaId = nil
			end

			tbl18.SignalCarrying = signalCarrying
			fn42()
		end)

		if ok and result then
			tbl17[#tbl17 + 1] = result
		end
	end

	local n6 = 0

	tbl17[#tbl17 + 1] = RunService.Heartbeat:Connect(function(deltaTime)
		local busy = antiGuard.Busy or tbl18.Active
		local flag5

		if busy then
			local busySince = antiGuard.BusySince
			flag5 = os.clock() - busySince > math.max(tonumber(fn32().BusyLimit) or tbl14.BusyLimit, (tonumber(fn32().ReleaseAt) or 0) + 1)
		else
			flag5 = busy
		end

		if flag5 then
			fn24()
			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.PlatformStand then
				pcall(function()
					humanoid.PlatformStand = false
				end)
			end

			fn36()
		end

		fn41()
		n6 += deltaTime
		if n6 < tbl14.WeldScanGap then
			return
		end
		n6 = 0
		local weldCarrying = fn23() ~= nil

		if weldCarrying ~= tbl18.WeldCarrying then
			tbl18.WeldCarrying = weldCarrying
			fn42()
		end
	end)

	fn4(function()
		flag4 = false

		for _, v10 in ipairs(tbl17) do
			pcall(function()
				v10:Disconnect()
			end)
		end

		table.clear(tbl17)
		fn24()
		fn36()
		antiGuard.Render = nil
		antiGuard.ShowPanel = nil

		pcall(function()
			ScreenGui:Destroy()
		end)
	end)
end


-- Finalize extracted Farm + Anti Guard host.
v:Finalize({ Window = v2, MainTab = defaultTab, ShowMainTab = true })
