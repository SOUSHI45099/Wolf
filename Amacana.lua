--// ============================================
--// ADVANCED AIMBOT
--// ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

----------------------------------------------------
-- HIDDEN / PROTECTED GUI CONTAINER (ANTI-DETECTION)
----------------------------------------------------
local function GetSafeGuiParent()
	if gethui then
		return gethui()
	elseif syn and syn.protect_gui then
		local folder = Instance.new("Folder")
		syn.protect_gui(folder)
		folder.Parent = CoreGui
		return folder
	else
		return CoreGui
	end
end

local SafeParent = GetSafeGuiParent()

--// ============================================
--// DEEP CLEANUP SYSTEM
--// ============================================

local function destroyExisting(parent, name)
	if parent then
		local found = parent:FindFirstChild(name)
		if found then
			pcall(function()
				found:Destroy()
			end)
		end
	end
end

destroyExisting(CoreGui, "AimbotFOVScreen")
destroyExisting(CoreGui, "AimbotNativeMenu")
destroyExisting(playerGui, "AimbotFOVScreen")
destroyExisting(playerGui, "AimbotNativeMenu")
destroyExisting(SafeParent, "AimbotEnableShortcut")
destroyExisting(CoreGui, "AimbotEnableShortcut")
destroyExisting(playerGui, "AimbotEnableShortcut")

pcall(function()
	RunService:UnbindFromRenderStep("HardLockAimbotStep_Pre")
end)
pcall(function()
	RunService:UnbindFromRenderStep("HardLockAimbotStep_Post")
end)

if _G.AimbotCleanup then
	pcall(_G.AimbotCleanup)
end

--// ============================================
--// CONFIG & JSON SAVE SYSTEM
--// ============================================

local CONFIG_FILE = "aimbot_config.json"

local DEFAULT_CONFIG = {
	enabled = false,
	wallCheck = false,
	targetPart = "Head",
	fov = 100,
	showFOV = true,
	teamCheckMode = "Off",
	trustedPlayers = {},
}

local CONFIG = DEFAULT_CONFIG

local function loadConfig()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) then
			local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
			if type(decoded) == "table" then
				for k, v in pairs(decoded) do
					CONFIG[k] = v
				end
			end
		end
	end)
	CONFIG.trustedPlayers = CONFIG.trustedPlayers or {}
	CONFIG.damageDealt = {}
end

local function saveConfig()
	pcall(function()
		if writefile then
			local dataToSave = {
				enabled = CONFIG.enabled,
				wallCheck = CONFIG.wallCheck,
				targetPart = CONFIG.targetPart,
				fov = CONFIG.fov,
				showFOV = CONFIG.showFOV,
				teamCheckMode = CONFIG.teamCheckMode,
				trustedPlayers = CONFIG.trustedPlayers,
			}
			writefile(CONFIG_FILE, HttpService:JSONEncode(dataToSave))
		end
	end)
end

loadConfig()

local function findPlayerByNameOrDisplayName(input)
	input = input:gsub("^%s+", ""):gsub("%s+$", "")
	if input == "" then
		return nil
	end

	local lowerInput = input:lower()

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower() == lowerInput then
			return player
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.DisplayName:lower() == lowerInput then
			return player
		end
	end

	return nil
end

local function isUserTrusted(username)
	for _, name in ipairs(CONFIG.trustedPlayers) do
		if string.lower(name) == string.lower(username) then
			return true
		end
	end
	return false
end

local function toggleTrustUser(username)
	local foundIndex = nil
	for i, name in ipairs(CONFIG.trustedPlayers) do
		if string.lower(name) == string.lower(username) then
			foundIndex = i
			break
		end
	end

	if foundIndex then
		table.remove(CONFIG.trustedPlayers, foundIndex)
	else
		table.insert(CONFIG.trustedPlayers, username)
	end
	saveConfig()
end

--// ============================================
--// PERFECT CENTER FOV CIRCLE
--// ============================================

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "AimbotFOVScreen"
FOVGui.ResetOnSpawn = false
FOVGui.DisplayOrder = 999
FOVGui.IgnoreGuiInset = true

pcall(function()
	FOVGui.Parent = CoreGui
end)
if not FOVGui.Parent then
	FOVGui.Parent = playerGui
end

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.BackgroundTransparency = 1
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, CONFIG.fov * 2, 0, CONFIG.fov * 2)
FOVCircle.Visible = false
FOVCircle.Parent = FOVGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CircleStroke.Color = Color3.fromRGB(150, 0, 0)
CircleStroke.Thickness = 1.5
CircleStroke.Parent = FOVCircle

local function updateFOVCircle()
	FOVCircle.Visible = CONFIG.enabled and CONFIG.showFOV
	FOVCircle.Size = UDim2.new(0, CONFIG.fov * 2, 0, CONFIG.fov * 2)
end

--// ============================================
--// TARGETING LOGIC & SWIPE SYSTEM
--// ============================================

local targetedPlayer = nil

local function getTargetedPlayer()
	if targetedPlayer and targetedPlayer.Parent then
		return targetedPlayer
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if isUserTrusted(player.Name) then
			targetedPlayer = player
			return player
		end
	end

	targetedPlayer = nil
	return nil
end

local lockedTarget = nil
local swipeStartPos = nil
local SWIPE_THRESHOLD = 30 -- Pixels needed to register a swipe

local function getTargetPart(character)
	if not character then
		return nil
	end
	if CONFIG.targetPart == "Head" then
		return character:FindFirstChild("Head")
	else
		return character:FindFirstChild("HumanoidRootPart")
			or character:FindFirstChild("UpperTorso")
			or character:FindFirstChild("Torso")
	end
end

local function isTeammate(targetCharacter)
	if CONFIG.teamCheckMode == "Off" then
		return false
	end

	local player = Players:GetPlayerFromCharacter(targetCharacter)
	if not player then
		return false
	end

	if CONFIG.teamCheckMode == "Roblox Team" then
		return player.Team and localPlayer.Team and player.Team == localPlayer.Team
	elseif CONFIG.teamCheckMode == "Trusted Players" then
		return isUserTrusted(player.Name)
	elseif CONFIG.teamCheckMode == "Targeted Player" then
		-- ONLY allow the saved targeted player.
		return not isUserTrusted(player.Name)
	elseif CONFIG.teamCheckMode == "Damage Check" then
		if (CONFIG.damageDealt[player.Name] or 0) > 0 then
			return false
		end
		return true
	end

	return false
end

local function getScreenCenter()
	local viewportSize = camera.ViewportSize
	local inset = GuiService:GetGuiInset()
	return Vector2.new(viewportSize.X / 2, (viewportSize.Y + inset.Y) / 2)
end

local function isTargetInFOV(targetPart)
	if not targetPart then
		return false
	end
	local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
	if not onScreen or screenPos.Z <= 0 then
		return false
	end

	local center = getScreenCenter()
	local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)

	return (targetScreenPos - center).Magnitude <= CONFIG.fov
end

local function canSeeTarget(target)
	if not CONFIG.wallCheck then
		return true
	end
	local targetPart = getTargetPart(target)
	if not targetPart then
		return false
	end

	local myChar = localPlayer.Character
	if not myChar or not myChar:FindFirstChild("Head") then
		return false
	end

	local rayOrigin = myChar.Head.Position
	local rayDirection = (targetPart.Position - rayOrigin)

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { myChar, target }
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
	return result == nil or result.Instance:IsDescendantOf(target)
end

local function isValidTarget(target)
	if not target or target == localPlayer.Character then
		return false
	end
	if isTeammate(target) then
		return false
	end
	local humanoid = target:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0 and getTargetPart(target) ~= nil
end

local function getAllTargetsInFOV()
	local targets = {}
	local center = getScreenCenter()

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			local character = player.Character
			if isValidTarget(character) then
				local part = getTargetPart(character)
				if part and isTargetInFOV(part) and canSeeTarget(character) then
					local screenPos = camera:WorldToViewportPoint(part.Position)
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					table.insert(targets, {
						character = character,
						screenX = screenPos.X,
						distanceToCenter = dist,
					})
				end
			end
		end
	end
	return targets
end

local function getBestTarget()
	local targets = getAllTargetsInFOV()
	if #targets == 0 then
		lockedTarget = nil
		return nil
	end

	-- Keep current target if still valid in FOV
	if lockedTarget and isValidTarget(lockedTarget) then
		local player = Players:GetPlayerFromCharacter(lockedTarget)

		if player then
			-- Always refresh to the player's current Character.
			local currentCharacter = player.Character

			if currentCharacter and currentCharacter ~= lockedTarget then
				lockedTarget = currentCharacter
			end
		end

		local currentTargetPart = getTargetPart(lockedTarget)

		if currentTargetPart and isTargetInFOV(currentTargetPart) and canSeeTarget(lockedTarget) then
			return lockedTarget
		end
	end

	-- Fallback to nearest player to screen center
	table.sort(targets, function(a, b)
		return a.distanceToCenter < b.distanceToCenter
	end)

	lockedTarget = targets[1].character
	return lockedTarget
end

local function cycleTarget(direction)
	local targets = getAllTargetsInFOV()
	if #targets < 2 then
		return
	end

	-- Sort targets from left to right on screen
	table.sort(targets, function(a, b)
		return a.screenX < b.screenX
	end)

	local currentIndex = 1
	for i, t in ipairs(targets) do
		if t.character == lockedTarget then
			currentIndex = i
			break
		end
	end

	local newIndex = currentIndex + direction
	if newIndex > #targets then
		newIndex = 1
	elseif newIndex < 1 then
		newIndex = #targets
	end

	lockedTarget = targets[newIndex].character
end

--// ============================================
--// EXTREME OVERRIDE HARD LOCK LOGIC
--// ============================================

local currentTarget = nil

local function hardLockToTarget(target)
	local targetPart = getTargetPart(target)
	if not targetPart then
		return
	end

	local targetPos = targetPart.Position
	local camPos = camera.CFrame.Position

	-- Force Camera LookAt
	camera.CFrame = CFrame.lookAt(camPos, targetPos)

	-- Force Body Mechanics (Stop recoil/sliding from twisting the character)
	local myChar = localPlayer.Character
	if myChar then
		local rootPart = myChar:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local lookAtPos = Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z)
			rootPart.CFrame = CFrame.lookAt(rootPart.Position, lookAtPos)
			rootPart.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

--// ============================================
--// LUCIDE ICON MODULE
--// ============================================
local Lucide
do
	local Success, Module = pcall(function()
		local Source =
			game:HttpGet("https://raw.githubusercontent.com/SOUSHI45099/Assets/refs/heads/main/LucideRoblox.lua")
		return loadstring(Source)()
	end)
	Lucide = Success and Module or nil
end

local function IsValidCustomIcon(Icon)
	return typeof(Icon) == "string"
		and (
			Icon:match("^rbxasset://textures/")
			or Icon:match("^rbxassetid://")
			or Icon:match("^rbxthumb://type=")
			or Icon:match("roblox%.com/asset/%?id=")
		)
end

local function ApplyIcon(ImageObject, iconName)
	if not iconName or iconName == "" then
		ImageObject.Visible = false
		return
	end
	ImageObject.Visible = true
	ImageObject.ImageTransparency = 0

	if tonumber(iconName) then
		iconName = "rbxassetid://" .. iconName
	end

	if IsValidCustomIcon(iconName) then
		ImageObject.Image = iconName
		ImageObject.ImageRectOffset = Vector2.new(0, 0)
		ImageObject.ImageRectSize = Vector2.new(0, 0)
		return
	end

	if Lucide then
		local Success, Asset = pcall(function()
			return Lucide.GetAsset(iconName)
		end)

		if Success and Asset then
			ImageObject.Image = Asset.Url
			ImageObject.ImageRectOffset = Asset.ImageRectOffset
			ImageObject.ImageRectSize = Asset.ImageRectSize
			return
		end
	end

	ImageObject.Image = "rbxassetid://10709782497"
	ImageObject.ImageRectOffset = Vector2.new(0, 0)
	ImageObject.ImageRectSize = Vector2.new(0, 0)
end

local function CreateIcon(Parent, IconName, Position, Size, Color, ZIndex)
	local Icon = Instance.new("ImageLabel")
	Icon.Name = "Icon"
	Icon.BackgroundTransparency = 1
	Icon.Position = Position
	Icon.Size = Size or UDim2.fromOffset(16, 16)
	Icon.ImageColor3 = Color or Color3.fromRGB(245, 245, 245)
	Icon.ZIndex = ZIndex or 2
	ApplyIcon(Icon, IconName)
	Icon.Parent = Parent
	return Icon
end

--// ============================================
--// GUI WITH FULL TRUST SYSTEM & PLAYER LIST
--// CLEAN / FIXED LAYOUT
--// ============================================

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AimbotNativeMenu"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = GetSafeGuiParent()

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Size = UDim2.fromOffset(560, 470)
Frame.Position = UDim2.fromScale(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = MainGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 14)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(70, 70, 70)
FrameStroke.Thickness = 1
FrameStroke.Transparency = 0.12
FrameStroke.Parent = Frame

local MenuScale = Instance.new("UIScale")
MenuScale.Scale = 0.94
MenuScale.Parent = Frame

local WHITE = Color3.fromRGB(245, 245, 245)
local BLACK = Color3.fromRGB(12, 12, 12)
local DARK = Color3.fromRGB(32, 32, 32)
local DARKER = Color3.fromRGB(23, 23, 23)
local MID = Color3.fromRGB(52, 52, 52)
local MUTED = Color3.fromRGB(165, 165, 165)
local RED = Color3.fromRGB(150, 12, 24)
local RED_BRIGHT = Color3.fromRGB(190, 20, 34)
local RED_DARK = Color3.fromRGB(55, 12, 17)

local FastTween = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local MenuTween = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = instance
	return corner
end

local function addStroke(instance, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 100, 100)
	stroke.Thickness = 1
	stroke.Transparency = transparency or 0.55
	stroke.Parent = instance
	return stroke
end

local function addButtonFX(button)
	button.AutoButtonColor = false

	button.MouseEnter:Connect(function()
		TweenService:Create(button, FastTween, {
			BackgroundTransparency = 0.08,
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, FastTween, {
			BackgroundTransparency = 0,
		}):Play()
	end)

	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, FastTween, {
			BackgroundTransparency = 0.18,
		}):Play()
	end)

	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, FastTween, {
			BackgroundTransparency = 0.08,
		}):Play()
	end)
end

--// TITLE
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, -20, 0, 52)
TitleBar.Position = UDim2.fromOffset(10, 10)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame
addCorner(TitleBar, 10)
addStroke(TitleBar, 0.65)

CreateIcon(TitleBar, "crosshair", UDim2.fromOffset(18, 16), UDim2.fromOffset(20, 20), RED_BRIGHT, 3)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -170, 0, 22)
Title.Position = UDim2.fromOffset(44, 7)
Title.BackgroundTransparency = 1
Title.Text = "EXTREME FORCE AIMBOT"
Title.TextColor3 = WHITE
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.fromOffset(7, 7)
StatusDot.Position = UDim2.fromOffset(44, 36)
StatusDot.BackgroundColor3 = RED_BRIGHT
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TitleBar
addCorner(StatusDot, 99)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.fromOffset(90, 14)
StatusText.Position = UDim2.fromOffset(57, 32)
StatusText.BackgroundTransparency = 1
StatusText.Text = "READY"
StatusText.TextColor3 = MUTED
StatusText.TextSize = 8
StatusText.Font = Enum.Font.GothamBold
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = TitleBar

local HideHint = Instance.new("TextLabel")
HideHint.Size = UDim2.fromOffset(135, 20)
HideHint.Position = UDim2.new(1, -145, 0, 16)
HideHint.BackgroundTransparency = 1
HideHint.Text = "L  •  TOGGLE UI"
HideHint.TextColor3 = MUTED
HideHint.TextSize = 10
HideHint.Font = Enum.Font.GothamMedium
HideHint.TextXAlignment = Enum.TextXAlignment.Right
HideHint.Parent = TitleBar

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, -24, 0, 1)
AccentLine.Position = UDim2.new(0, 12, 1, -1)
AccentLine.BackgroundColor3 = RED_BRIGHT
AccentLine.BackgroundTransparency = 0.18
AccentLine.BorderSizePixel = 0
AccentLine.Parent = TitleBar

--// TWO-COLUMN CONTENT AREA
local ContentY = 70
local ContentH = 390
local LeftW = 250
local RightW = 270
local Gap = 10

--// LEFT PANEL
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "ControlsPanel"
LeftPanel.Size = UDim2.fromOffset(LeftW, ContentH)
LeftPanel.Position = UDim2.fromOffset(10, ContentY)
LeftPanel.BackgroundColor3 = DARKER
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = Frame
addCorner(LeftPanel, 10)
addStroke(LeftPanel, 0.72)

local function sectionLabel(parent, text, positionY)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 16)
	label.Position = UDim2.fromOffset(10, positionY)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(185, 185, 185)
	label.TextSize = 9
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function makePanelButton(parent, text, positionY, height)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, height or 34)
	button.Position = UDim2.fromOffset(10, positionY)
	button.BackgroundColor3 = DARK
	button.BorderSizePixel = 0
	button.Text = text or ""
	button.TextColor3 = WHITE
	button.TextSize = 11
	button.Font = Enum.Font.GothamMedium
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextTruncate = Enum.TextTruncate.AtEnd
	button.Parent = parent
	addCorner(button, 8)
	addStroke(button, 0.78)
	addButtonFX(button)
	return button
end

local function makeRightState(button, defaultText)
	local state = Instance.new("TextLabel")
	state.Name = "State"
	state.Size = UDim2.fromOffset(38, 20)
	state.Position = UDim2.new(1, -48, 0.5, -10)
	state.BackgroundTransparency = 1
	state.Text = defaultText or "OFF"
	state.TextColor3 = WHITE
	state.TextSize = 10
	state.Font = Enum.Font.GothamBold
	state.TextXAlignment = Enum.TextXAlignment.Right
	state.Parent = button
	return state
end

local function createToggle(parent, text, positionY, default, callback)
	local state = default
	local button = makePanelButton(parent, "", positionY, 34)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.fromOffset(10, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = WHITE
	label.TextSize = 11
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button

	local stateLabel = makeRightState(button, "OFF")

	local function refresh()
		button.BackgroundColor3 = state and RED_DARK or DARK
		stateLabel.Text = state and "ON" or "OFF"
	end

	local function setState(value, fireCallback)
		state = value == true
		refresh()

		if fireCallback ~= false then
			callback(state)
			saveConfig()
		end
	end

	button.MouseButton1Click:Connect(function()
		setState(not state, true)
	end)

	refresh()
	return button, setState
end

local UpdateEnableShortcutVisual

local EnableBtn, SetEnableBtnState = createToggle(LeftPanel, "Extreme Aimbot", 10, CONFIG.enabled, function(v)
	CONFIG.enabled = v
	updateFOVCircle()
	if UpdateEnableShortcutVisual then
		UpdateEnableShortcutVisual()
	end
end)

--// ============================================
--// FLOATING ENABLE SHORTCUT
--// ============================================

local EnableShortcutGui = nil
local EnableShortcutButton = nil
local ShortcutTriggerBtn = nil
local ShortcutConnections = {}

local function disconnectShortcutConnections()
	for _, connection in ipairs(ShortcutConnections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(ShortcutConnections)
end

local function setShortcutTriggerVisual(enabled)
	if not ShortcutTriggerBtn then
		return
	end

	ShortcutTriggerBtn.BackgroundColor3 = enabled and RED_DARK or DARK
end

UpdateEnableShortcutVisual = function()
	if not EnableShortcutButton or not EnableShortcutButton.Parent then
		return
	end

	EnableShortcutButton.BackgroundColor3 = CONFIG.enabled and RED_DARK or DARK
end

local function DestroyEnableShortcut()
	disconnectShortcutConnections()

	if EnableShortcutGui then
		pcall(function()
			EnableShortcutGui:Destroy()
		end)
	end

	EnableShortcutGui = nil
	EnableShortcutButton = nil
	setShortcutTriggerVisual(false)
end

local function CreateEnableShortcut()
	if EnableShortcutGui and EnableShortcutGui.Parent then
		return
	end

	EnableShortcutGui = Instance.new("ScreenGui")
	EnableShortcutGui.Name = "AimbotEnableShortcut"
	EnableShortcutGui.ResetOnSpawn = false
	EnableShortcutGui.IgnoreGuiInset = true
	EnableShortcutGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	EnableShortcutGui.Parent = SafeParent

	EnableShortcutButton = Instance.new("TextButton")
	EnableShortcutButton.Name = "S1"
	EnableShortcutButton.Size = UDim2.fromOffset(48, 48)
	EnableShortcutButton.Position = UDim2.new(0.5, -24, 0.72, 0)
	EnableShortcutButton.BackgroundColor3 = DARK
	EnableShortcutButton.BackgroundTransparency = 0.55
	EnableShortcutButton.BorderSizePixel = 0
	EnableShortcutButton.AutoButtonColor = false
	EnableShortcutButton.Text = ""
	EnableShortcutButton.Active = true
	EnableShortcutButton.ZIndex = 10
	EnableShortcutButton.Parent = EnableShortcutGui
	addCorner(EnableShortcutButton, 11)
	addStroke(EnableShortcutButton, 0.55)

	CreateIcon(EnableShortcutButton, "crosshair", UDim2.new(0.5, -10, 0.5, -10), UDim2.fromOffset(20, 20), WHITE, 11)

	local DragStart = nil
	local StartPosition = nil
	local PressInput = nil
	local DragInput = nil
	local Dragging = false
	local DragMoved = false
	local DRAG_THRESHOLD = 7

	ShortcutConnections[#ShortcutConnections + 1] = EnableShortcutButton.InputBegan:Connect(function(input)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		PressInput = input
		DragStart = Vector2.new(input.Position.X, input.Position.Y)
		StartPosition = EnableShortcutButton.Position
		Dragging = true
		DragMoved = false
	end)

	ShortcutConnections[#ShortcutConnections + 1] = EnableShortcutButton.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			DragInput = input
		end
	end)

	ShortcutConnections[#ShortcutConnections + 1] = UserInputService.InputChanged:Connect(function(input)
		if not Dragging or input ~= DragInput or not EnableShortcutButton then
			return
		end

		local currentPosition = Vector2.new(input.Position.X, input.Position.Y)
		local delta = currentPosition - DragStart

		if delta.Magnitude >= DRAG_THRESHOLD then
			DragMoved = true
		end

		EnableShortcutButton.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + delta.Y
		)
	end)

	ShortcutConnections[#ShortcutConnections + 1] = UserInputService.InputEnded:Connect(function(input)
		if input ~= PressInput then
			return
		end

		Dragging = false

		if not DragMoved and EnableShortcutButton and EnableShortcutButton.Parent then
			SetEnableBtnState(not CONFIG.enabled, true)
		end

		PressInput = nil
		DragInput = nil
		DragStart = nil
		StartPosition = nil

		-- Keep the drag flag alive through the current input event so a
		-- drag release can never be interpreted as a click by Roblox.
		task.defer(function()
			DragMoved = false
		end)
	end)

	setShortcutTriggerVisual(true)
	UpdateEnableShortcutVisual()
end

local ShowFOVBtn = createToggle(LeftPanel, "Show FOV Circle", 51, CONFIG.showFOV, function(v)
	CONFIG.showFOV = v
	updateFOVCircle()
end)

local WallCheckBtn = createToggle(LeftPanel, "Wall Check", 92, CONFIG.wallCheck, function(v)
	CONFIG.wallCheck = v
end)

local TargetBtn = makePanelButton(LeftPanel, "", 133, 34)
local TargetIcon = CreateIcon(TargetBtn, "crosshair", UDim2.fromOffset(10, 9), UDim2.fromOffset(16, 16), MUTED, 3)

local TargetText = Instance.new("TextLabel")
TargetText.Size = UDim2.new(1, -38, 1, 0)
TargetText.Position = UDim2.fromOffset(34, 0)
TargetText.BackgroundTransparency = 1
TargetText.TextColor3 = WHITE
TargetText.TextSize = 11
TargetText.Font = Enum.Font.GothamMedium
TargetText.TextXAlignment = Enum.TextXAlignment.Left
TargetText.Parent = TargetBtn

local TargetValue = Instance.new("TextLabel")
TargetValue.Size = UDim2.fromOffset(55, 20)
TargetValue.Position = UDim2.new(1, -65, 0.5, -10)
TargetValue.BackgroundTransparency = 1
TargetValue.TextColor3 = MUTED
TargetValue.TextSize = 10
TargetValue.Font = Enum.Font.GothamBold
TargetValue.TextXAlignment = Enum.TextXAlignment.Right
TargetValue.Parent = TargetBtn

local function refreshTargetButton()
	TargetText.Text = "Target Part"
	TargetValue.Text = CONFIG.targetPart
end

TargetBtn.MouseButton1Click:Connect(function()
	CONFIG.targetPart = (CONFIG.targetPart == "Head") and "Torso" or "Head"
	refreshTargetButton()
	saveConfig()
end)

refreshTargetButton()

local TeamBtn = makePanelButton(LeftPanel, "", 174, 34)
local SpecificationIcon =
	CreateIcon(TeamBtn, "list-filter", UDim2.fromOffset(10, 9), UDim2.fromOffset(16, 16), MUTED, 3)

local TeamText = Instance.new("TextLabel")
TeamText.Size = UDim2.new(1, -120, 1, 0)
TeamText.Position = UDim2.fromOffset(34, 0)
TeamText.BackgroundTransparency = 1
TeamText.TextColor3 = WHITE
TeamText.TextSize = 11
TeamText.Font = Enum.Font.GothamMedium
TeamText.TextXAlignment = Enum.TextXAlignment.Left
TeamText.Text = "Specification"
TeamText.Parent = TeamBtn

local TeamValue = Instance.new("TextLabel")
TeamValue.Size = UDim2.fromOffset(88, 20)
TeamValue.Position = UDim2.new(1, -98, 0.5, -10)
TeamValue.BackgroundTransparency = 1
TeamValue.TextColor3 = MUTED
TeamValue.TextSize = 9
TeamValue.Font = Enum.Font.GothamBold
TeamValue.TextXAlignment = Enum.TextXAlignment.Right
TeamValue.TextTruncate = Enum.TextTruncate.AtEnd
TeamValue.Parent = TeamBtn

local Specification = { "Off", "Roblox Team", "Trusted Players", "Damage Check", "Targeted Player" }
local currentSpecification = 1

for i, mode in ipairs(Specification) do
	if mode == CONFIG.teamCheckMode then
		currentSpecification = i
		break
	end
end

local function refreshTeamButton()
	TeamValue.Text = CONFIG.teamCheckMode
end

TeamBtn.MouseButton1Click:Connect(function()
	currentSpecification = (currentSpecification % #Specification) + 1
	CONFIG.teamCheckMode = Specification[currentSpecification]
	refreshTeamButton()
	saveConfig()
end)

refreshTeamButton()

sectionLabel(LeftPanel, "FOV", 217)

local FOVContainer = Instance.new("Frame")
FOVContainer.Name = "FOVContainer"
FOVContainer.Size = UDim2.new(1, -20, 0, 34)
FOVContainer.Position = UDim2.fromOffset(10, 237)
FOVContainer.BackgroundColor3 = DARK
FOVContainer.BorderSizePixel = 0
FOVContainer.Parent = LeftPanel
addCorner(FOVContainer, 8)
addStroke(FOVContainer, 0.78)

CreateIcon(FOVContainer, "circle-dot", UDim2.fromOffset(9, 10), UDim2.fromOffset(14, 14), MUTED, 3)

local FOVLabel = Instance.new("TextBox")
FOVLabel.Size = UDim2.new(1, -76, 1, 0)
FOVLabel.Position = UDim2.fromOffset(29, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = tostring(math.floor(tonumber(CONFIG.fov) or 100))
FOVLabel.PlaceholderText = "100"
FOVLabel.TextColor3 = WHITE
FOVLabel.PlaceholderColor3 = MUTED
FOVLabel.TextSize = 11
FOVLabel.Font = Enum.Font.GothamMedium
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.ClearTextOnFocus = false
FOVLabel.Parent = FOVContainer

-- FOV step controls: transparent, separated by subtle strokes.
-- No hover/pressed background animation, so they never look highlighted.
local MinusFrame = Instance.new("Frame")
MinusFrame.Name = "MinusFrame"
MinusFrame.Size = UDim2.fromOffset(34, 32)
MinusFrame.Position = UDim2.new(1, -69, 0.5, -16)
MinusFrame.BackgroundTransparency = 1
MinusFrame.BorderSizePixel = 0
MinusFrame.Parent = FOVContainer
addCorner(MinusFrame, 6)
addStroke(MinusFrame, 0.82)

local MinusBtn = Instance.new("TextButton")
MinusBtn.Name = "MinusButton"
MinusBtn.Size = UDim2.fromScale(1, 1)
MinusBtn.BackgroundTransparency = 1
MinusBtn.BorderSizePixel = 0
MinusBtn.Text = "-"
MinusBtn.TextColor3 = MUTED
MinusBtn.TextSize = 16
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.AutoButtonColor = false
MinusBtn.Parent = MinusFrame

local PlusFrame = Instance.new("Frame")
PlusFrame.Name = "PlusFrame"
PlusFrame.Size = UDim2.fromOffset(34, 32)
PlusFrame.Position = UDim2.new(1, -35, 0.5, -16)
PlusFrame.BackgroundTransparency = 1
PlusFrame.BorderSizePixel = 0
PlusFrame.Parent = FOVContainer
addCorner(PlusFrame, 6)
addStroke(PlusFrame, 0.82)

local PlusBtn = Instance.new("TextButton")
PlusBtn.Name = "PlusButton"
PlusBtn.Size = UDim2.fromScale(1, 1)
PlusBtn.BackgroundTransparency = 1
PlusBtn.BorderSizePixel = 0
PlusBtn.Text = "+"
PlusBtn.TextColor3 = MUTED
PlusBtn.TextSize = 16
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.AutoButtonColor = false
PlusBtn.Parent = PlusFrame

FOVLabel:GetPropertyChangedSignal("Text"):Connect(function()
	local digits = FOVLabel.Text:gsub("%D", "")
	if digits ~= FOVLabel.Text then
		FOVLabel.Text = digits
	end
end)

FOVLabel.FocusLost:Connect(function()
	local value = tonumber(FOVLabel.Text:match("%d+"))
	if not value then
		value = tonumber(CONFIG.fov) or 100
	end

	CONFIG.fov = math.clamp(math.floor(value), 50, 400)
	FOVLabel.Text = tostring(CONFIG.fov)
	updateFOVCircle()
	saveConfig()
end)

local function refreshFOVLabel()
	FOVLabel.Text = tostring(CONFIG.fov)
end

MinusBtn.MouseButton1Click:Connect(function()
	CONFIG.fov = math.max(50, CONFIG.fov - 25)
	refreshFOVLabel()
	updateFOVCircle()
	saveConfig()
end)

PlusBtn.MouseButton1Click:Connect(function()
	CONFIG.fov = math.min(400, CONFIG.fov + 25)
	refreshFOVLabel()
	updateFOVCircle()
	saveConfig()
end)

sectionLabel(LeftPanel, "ADD PLAYERS", 281)

local ManualInputFrame = Instance.new("Frame")
ManualInputFrame.Name = "ManualInput"
ManualInputFrame.Size = UDim2.new(1, -20, 0, 34)
ManualInputFrame.Position = UDim2.fromOffset(10, 301)
ManualInputFrame.BackgroundColor3 = DARK
ManualInputFrame.BorderSizePixel = 0
ManualInputFrame.Parent = LeftPanel
addCorner(ManualInputFrame, 8)
addStroke(ManualInputFrame, 0.78)

local ManualInput = Instance.new("TextBox")
ManualInput.Name = "PlayerNameInput"
ManualInput.Size = UDim2.new(1, -84, 1, 0)
ManualInput.Position = UDim2.fromOffset(8, 0)
ManualInput.BackgroundTransparency = 1
ManualInput.BorderSizePixel = 0
ManualInput.ClipsDescendants = true
ManualInput.PlaceholderText = "Enter player name..."
ManualInput.PlaceholderColor3 = Color3.fromRGB(125, 125, 125)
ManualInput.Text = ""
ManualInput.TextColor3 = WHITE
ManualInput.TextSize = 11
ManualInput.Font = Enum.Font.Gotham
ManualInput.ClearTextOnFocus = false
ManualInput.TextXAlignment = Enum.TextXAlignment.Left
ManualInput.TextWrapped = false
ManualInput.TextTruncate = Enum.TextTruncate.AtEnd
ManualInput.Parent = ManualInputFrame

local ManualAddBtn = Instance.new("TextButton")
ManualAddBtn.Name = "AddTargetButton"
ManualAddBtn.Size = UDim2.fromOffset(30, 30)
ManualAddBtn.Position = UDim2.new(1, -66, 0.5, -15)
ManualAddBtn.BackgroundColor3 = DARK
ManualAddBtn.BorderSizePixel = 0
ManualAddBtn.Text = ""
ManualAddBtn.Parent = ManualInputFrame
addCorner(ManualAddBtn, 7)
addButtonFX(ManualAddBtn)
CreateIcon(ManualAddBtn, "user-round-plus", UDim2.new(0.5, -8, 0.5, -8), UDim2.fromOffset(16, 16), WHITE, 4)

local ClearBtn = Instance.new("TextButton")
ClearBtn.Name = "ClearTargetsButton"
ClearBtn.Size = UDim2.fromOffset(30, 30)
ClearBtn.Position = UDim2.new(1, -32, 0.5, -15)
ClearBtn.BackgroundColor3 = DARK
ClearBtn.BorderSizePixel = 0
ClearBtn.Text = ""
ClearBtn.Parent = ManualInputFrame
addCorner(ClearBtn, 7)
addButtonFX(ClearBtn)
CreateIcon(ClearBtn, "user-round-minus", UDim2.new(0.5, -8, 0.5, -8), UDim2.fromOffset(16, 16), WHITE, 4)

-- Forward declaration prevents the add/clear callbacks from resolving
-- to a missing global function.
local updateLists

ManualAddBtn.MouseButton1Click:Connect(function()
	local input = ManualInput.Text
	local player = findPlayerByNameOrDisplayName(input)

	if player then
		toggleTrustUser(player.Name)
		ManualInput.Text = ""
		updateLists()
		saveConfig()
	else
		ManualInput.Text = ""
		ManualInput.PlaceholderText = "Player not found"
		task.delay(1.5, function()
			ManualInput.PlaceholderText = "Username or display name..."
		end)
	end
end)

ClearBtn.MouseButton1Click:Connect(function()
	CONFIG.trustedPlayers = {}
	updateLists()
	saveConfig()
end)

--// FLOATING SHORTCUT TRIGGER
--// Sits directly under the manual add-player control.
ShortcutTriggerBtn = makePanelButton(LeftPanel, "", 342, 34)
ShortcutTriggerBtn.Name = "EnableShortcutTrigger"

CreateIcon(ShortcutTriggerBtn, "plug-zap", UDim2.fromOffset(10, 9), UDim2.fromOffset(16, 16), MUTED, 4)

local ShortcutTriggerLabel = Instance.new("TextLabel")
ShortcutTriggerLabel.Name = "Label"
ShortcutTriggerLabel.Size = UDim2.new(1, -42, 1, 0)
ShortcutTriggerLabel.Position = UDim2.fromOffset(34, 0)
ShortcutTriggerLabel.BackgroundTransparency = 1
ShortcutTriggerLabel.Text = "EZAccess aimbot"
ShortcutTriggerLabel.TextColor3 = WHITE
ShortcutTriggerLabel.TextSize = 11
ShortcutTriggerLabel.Font = Enum.Font.GothamMedium
ShortcutTriggerLabel.TextXAlignment = Enum.TextXAlignment.Left
ShortcutTriggerLabel.Parent = ShortcutTriggerBtn

ShortcutTriggerBtn.MouseButton1Click:Connect(function()
	if EnableShortcutGui and EnableShortcutGui.Parent then
		DestroyEnableShortcut()
	else
		CreateEnableShortcut()
	end
end)

setShortcutTriggerVisual(false)

--// RIGHT PANEL
local RightPanel = Instance.new("Frame")
RightPanel.Name = "PlayersPanel"
RightPanel.Size = UDim2.fromOffset(RightW, ContentH)
RightPanel.Position = UDim2.fromOffset(10 + LeftW + Gap, ContentY)
RightPanel.BackgroundColor3 = DARKER
RightPanel.BorderSizePixel = 0
RightPanel.Parent = Frame
addCorner(RightPanel, 10)
addStroke(RightPanel, 0.72)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1, -20, 0, 34)
RefreshBtn.Position = UDim2.fromOffset(10, 10)
RefreshBtn.BackgroundColor3 = DARK
RefreshBtn.BorderSizePixel = 0
RefreshBtn.Text = ""
RefreshBtn.TextColor3 = WHITE
RefreshBtn.Parent = RightPanel
addCorner(RefreshBtn, 8)
addStroke(RefreshBtn, 0.78)
addButtonFX(RefreshBtn)

CreateIcon(RefreshBtn, "refresh-cw", UDim2.fromOffset(10, 9), UDim2.fromOffset(16, 16), MUTED, 3)

local RefreshText = Instance.new("TextLabel")
RefreshText.Size = UDim2.new(1, -42, 1, 0)
RefreshText.Position = UDim2.fromOffset(34, 0)
RefreshText.BackgroundTransparency = 1
RefreshText.Text = "Refresh Players List"
RefreshText.TextColor3 = WHITE
RefreshText.TextSize = 11
RefreshText.Font = Enum.Font.GothamMedium
RefreshText.TextXAlignment = Enum.TextXAlignment.Left
RefreshText.Parent = RefreshBtn

local ServerLabel = Instance.new("TextLabel")
ServerLabel.Size = UDim2.new(1, -54, 0, 18)
ServerLabel.Position = UDim2.fromOffset(10, 51)
ServerLabel.BackgroundTransparency = 1
ServerLabel.Text = "SERVER PLAYERS  /  SELECT TO TARGET"
ServerLabel.TextColor3 = MUTED
ServerLabel.TextSize = 9
ServerLabel.Font = Enum.Font.GothamBold
ServerLabel.TextXAlignment = Enum.TextXAlignment.Left
ServerLabel.Parent = RightPanel

--// SELECT ALL PLAYERS BUTTON
local SelectAllPlayersBtn = Instance.new("TextButton")
SelectAllPlayersBtn.Name = "SelectAllPlayers"
SelectAllPlayersBtn.Size = UDim2.fromOffset(28, 24)
SelectAllPlayersBtn.Position = UDim2.new(1, -38, 0, 48)
SelectAllPlayersBtn.BackgroundColor3 = DARK
SelectAllPlayersBtn.BorderSizePixel = 0
SelectAllPlayersBtn.Text = ""
SelectAllPlayersBtn.AutoButtonColor = false
SelectAllPlayersBtn.Parent = RightPanel

addCorner(SelectAllPlayersBtn, 7)
addStroke(SelectAllPlayersBtn, 0.78)
addButtonFX(SelectAllPlayersBtn)

CreateIcon(SelectAllPlayersBtn, "user", UDim2.new(0.5, -8, 0.5, -8), UDim2.fromOffset(16, 16), MUTED, 4)

local ServerScroll = Instance.new("ScrollingFrame")
ServerScroll.Name = "ServerPlayers"
ServerScroll.Size = UDim2.new(1, -20, 0, 128)
ServerScroll.Position = UDim2.fromOffset(10, 72)
ServerScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ServerScroll.BorderSizePixel = 0
ServerScroll.ScrollBarThickness = 3
ServerScroll.ScrollBarImageColor3 = RED_BRIGHT
ServerScroll.ScrollBarImageTransparency = 0.45
ServerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ServerScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
ServerScroll.Parent = RightPanel
addCorner(ServerScroll, 8)
addStroke(ServerScroll, 0.82)

local ServerLayout = Instance.new("UIListLayout")
ServerLayout.Padding = UDim.new(0, 5)
ServerLayout.SortOrder = Enum.SortOrder.LayoutOrder
ServerLayout.Parent = ServerScroll

SelectAllPlayersBtn.MouseButton1Click:Connect(function()
	local players = Players:GetPlayers()

	-- Check whether every server player is already selected
	local allSelected = true

	for _, player in ipairs(players) do
		if player ~= localPlayer then
			if not isUserTrusted(player.Name) then
				allSelected = false
				break
			end
		end
	end

	-- Toggle all players
	for _, player in ipairs(players) do
		if player ~= localPlayer then
			local selected = isUserTrusted(player.Name)

			if allSelected then
				-- Deselect everyone
				if selected then
					toggleTrustUser(player.Name)
				end
			else
				-- Select everyone
				if not selected then
					toggleTrustUser(player.Name)
				end
			end
		end
	end

	updateLists()
	saveConfig()
end)

local TrustedHeaderLabel = Instance.new("TextLabel")
TrustedHeaderLabel.Size = UDim2.new(1, -58, 0, 18)
TrustedHeaderLabel.Position = UDim2.fromOffset(10, 208)
TrustedHeaderLabel.BackgroundTransparency = 1
TrustedHeaderLabel.Text = "TRUSTED / TARGETED PLAYERS = " .. #CONFIG.trustedPlayers .. " SAVED"
TrustedHeaderLabel.TextColor3 = MUTED
TrustedHeaderLabel.TextSize = 9
TrustedHeaderLabel.Font = Enum.Font.GothamBold
TrustedHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
TrustedHeaderLabel.TextTruncate = Enum.TextTruncate.AtEnd
TrustedHeaderLabel.Parent = RightPanel

-- Clear every saved trusted/targeted player without adding another text-heavy control.
local ClearSavedBtn = Instance.new("TextButton")
ClearSavedBtn.Name = "ClearSavedPlayers"
ClearSavedBtn.Size = UDim2.fromOffset(28, 24)
ClearSavedBtn.AnchorPoint = Vector2.new(1, 0.5)
ClearSavedBtn.Position = UDim2.new(1, -10, 0, 217)
ClearSavedBtn.BackgroundTransparency = 1
ClearSavedBtn.BorderSizePixel = 0
ClearSavedBtn.Text = ""
ClearSavedBtn.AutoButtonColor = false
ClearSavedBtn.Parent = RightPanel
addCorner(ClearSavedBtn, 6)

local ClearSavedIcon =
	CreateIcon(ClearSavedBtn, "trash", UDim2.new(0.5, -8, 0.5, -8), UDim2.fromOffset(16, 16), MUTED, 3)

ClearSavedBtn.MouseEnter:Connect(function()
	ClearSavedIcon.ImageColor3 = RED_BRIGHT
end)

ClearSavedBtn.MouseLeave:Connect(function()
	ClearSavedIcon.ImageColor3 = MUTED
end)

ClearSavedBtn.MouseButton1Click:Connect(function()
	if #CONFIG.trustedPlayers == 0 then
		return
	end

	CONFIG.trustedPlayers = {}
	lockedTarget = nil
	saveConfig()
	updateLists()
end)

local TrustedScroll = Instance.new("ScrollingFrame")
TrustedScroll.Name = "TrustedPlayers"
TrustedScroll.Size = UDim2.new(1, -20, 0, 148)
TrustedScroll.Position = UDim2.fromOffset(10, 229)
TrustedScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TrustedScroll.BorderSizePixel = 0
TrustedScroll.ScrollBarThickness = 3
TrustedScroll.ScrollBarImageColor3 = RED_BRIGHT
TrustedScroll.ScrollBarImageTransparency = 0.45
TrustedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TrustedScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
TrustedScroll.Parent = RightPanel
addCorner(TrustedScroll, 8)
addStroke(TrustedScroll, 0.82)

local TrustedLayout = Instance.new("UIListLayout")
TrustedLayout.Padding = UDim.new(0, 5)
TrustedLayout.SortOrder = Enum.SortOrder.LayoutOrder
TrustedLayout.Parent = TrustedScroll

local function createListButton(parent, text, active)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = active and RED_DARK or MID
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent
	addCorner(btn, 7)
	addStroke(btn, 0.82)
	addButtonFX(btn)

	CreateIcon(
		btn,
		active and "circle-check" or "circle",
		UDim2.fromOffset(9, 8),
		UDim2.fromOffset(14, 14),
		active and RED_BRIGHT or MUTED,
		3
	)

	-- Separate label prevents long names from colliding with the icon.
	local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = "PlayerName"
	NameLabel.Size = UDim2.new(1, -34, 1, 0)
	NameLabel.Position = UDim2.fromOffset(30, 0)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Text = text
	NameLabel.TextColor3 = WHITE
	NameLabel.TextSize = 10
	NameLabel.Font = Enum.Font.GothamMedium
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	NameLabel.Parent = btn

	return btn
end

updateLists = function()
	for _, child in ipairs(ServerScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, child in ipairs(TrustedScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local players = Players:GetPlayers()
	table.sort(players, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)

	for _, player in ipairs(players) do
		if player ~= localPlayer then
			local isTrusted = isUserTrusted(player.Name)
			local btn = createListButton(ServerScroll, player.Name, isTrusted)

			btn.MouseButton1Click:Connect(function()
				toggleTrustUser(player.Name)
				updateLists()
				saveConfig()
			end)
		end
	end

	for _, name in ipairs(CONFIG.trustedPlayers) do
		local btn = createListButton(TrustedScroll, name, true)

		btn.MouseButton1Click:Connect(function()
			toggleTrustUser(name)
			updateLists()
			saveConfig()
		end)
	end

	task.defer(function()
		ServerScroll.CanvasSize = UDim2.fromOffset(0, ServerLayout.AbsoluteContentSize.Y + 8)
		TrustedScroll.CanvasSize = UDim2.fromOffset(0, TrustedLayout.AbsoluteContentSize.Y + 8)
		TrustedHeaderLabel.Text = "TRUSTED / TARGETED PLAYERS = " .. #CONFIG.trustedPlayers .. " SAVED"
	end)
end

RefreshBtn.MouseButton1Click:Connect(function()
	updateLists()
end)

Players.PlayerAdded:Connect(function()
	task.wait(0.15)
	updateLists()
end)

Players.PlayerRemoving:Connect(function()
	task.wait(0.15)
	updateLists()
end)

--// MENU ANIMATION
local menuVisible = true
local menuTween

local function setMenuVisible(visible)
	if menuTween then
		pcall(function()
			menuTween:Cancel()
		end)
	end

	menuVisible = visible

	if visible then
		Frame.Visible = true
		MenuScale.Scale = 0.94
		menuTween = TweenService:Create(MenuScale, MenuTween, { Scale = 1 })
		menuTween:Play()
	else
		menuTween = TweenService:Create(MenuScale, MenuTween, { Scale = 0.94 })
		menuTween:Play()
		menuTween.Completed:Connect(function()
			if not menuVisible then
				Frame.Visible = false
			end
		end)
	end
end

local UIToggleButton = Instance.new("TextButton")
UIToggleButton.Name = "UIToggleButton"
UIToggleButton.Size = UDim2.fromOffset(34, 34)
UIToggleButton.AnchorPoint = Vector2.new(1, 0)
UIToggleButton.Position = UDim2.new(1, -12, 0, 12)
UIToggleButton.BackgroundColor3 = DARKER
UIToggleButton.BorderSizePixel = 0
UIToggleButton.Text = ""
UIToggleButton.Parent = MainGui
addCorner(UIToggleButton, 9)
addStroke(UIToggleButton, 0.65)
addButtonFX(UIToggleButton)

local UIToggleIcon =
	CreateIcon(UIToggleButton, "square-minus", UDim2.new(0.5, -8, 0.5, -8), UDim2.fromOffset(16, 16), WHITE, 4)

UIToggleButton.MouseButton1Click:Connect(function()
	setMenuVisible(not menuVisible)
	ApplyIcon(UIToggleIcon, menuVisible and "square-minus" or "square-plus")
end)

updateLists()

--// ============================================

_G.AimbotCleanup = function()
	if DestroyEnableShortcut then
		pcall(DestroyEnableShortcut)
	end

	if FOVGui then
		pcall(function()
			FOVGui:Destroy()
		end)
	end
	if MainGui then
		pcall(function()
			MainGui:Destroy()
		end)
	end
	RunService:UnbindFromRenderStep("HardLockAimbotStep_Pre")
	RunService:UnbindFromRenderStep("HardLockAimbotStep_Post")
end

updateFOVCircle()

--// ============================================
--// DUAL STAGE LOCKING & INPUT LISTENERS
--// ============================================

RunService:BindToRenderStep("HardLockAimbotStep_Pre", Enum.RenderPriority.Camera.Value - 1, function()
	if CONFIG.enabled then
		currentTarget = getBestTarget()
		if currentTarget and isValidTarget(currentTarget) then
			hardLockToTarget(currentTarget)
		end
	end
end)

RunService:BindToRenderStep("HardLockAimbotStep_Post", Enum.RenderPriority.Last.Value, function()
	if CONFIG.enabled and currentTarget and isValidTarget(currentTarget) then
		hardLockToTarget(currentTarget)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.L then
		setMenuVisible(not menuVisible)
	end

	-- Capture touch or mouse drag start inside FOV
	if
		CONFIG.enabled
		and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
	then
		local startPos = Vector2.new(input.Position.X, input.Position.Y)
		local center = getScreenCenter()

		if (startPos - center).Magnitude <= CONFIG.fov then
			swipeStartPos = startPos
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if not CONFIG.enabled or not swipeStartPos then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local endPos = Vector2.new(input.Position.X, input.Position.Y)
		local delta = endPos - swipeStartPos
		swipeStartPos = nil

		-- Trigger target swap if horizontal swipe distance is met
		if math.abs(delta.X) >= SWIPE_THRESHOLD and math.abs(delta.X) > math.abs(delta.Y) then
			if delta.X > 0 then
				cycleTarget(1) -- Swipe Right -> Next player on right
			else
				cycleTarget(-1) -- Swipe Left -> Next player on left
			end
		end
	end
end)
