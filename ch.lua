--==================================================
-- 😈 CH V12.5 - CLEAN UI
-- Sin Silent Aim + Hitbox Color + Transparencia
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local PASSWORD = "05"
local MenuKey = Enum.KeyCode.RightControl

local DEFAULT_WALK_SPEED = 16
local sprintSpeed = 32
local flySpeed = 80

local MIN_FLY = 40
local MAX_FLY = 200
local MIN_SPRINT = 16
local MAX_SPRINT = 200

-- AIM
local aimEnabled = false
local aimFOV = 150
local aimSmooth = 18
local aimHoldMode = false
local aimHeld = false
local aimTargetPart = "Head"
local ignoreFriends = true
local ignoreTeam = true
local aimThroughWalls = false

-- ESP
local espEnabled = false
local espNames = true
local espHealth = true
local espDistance = true
local espBoxes = true
local espMaxDistance = 1000

-- HITBOX
local hitboxEnabled = false
local hitboxSize = 8
local hitboxTransparency = 0.65
local hitboxColor = Color3.fromRGB(200, 45, 75)
local currentColorIndex = 1

local hitboxColors = {
	Color3.fromRGB(200, 45, 75),   -- Rojo
	Color3.fromRGB(40, 120, 230),  -- Azul
	Color3.fromRGB(35, 160, 85),   -- Verde
	Color3.fromRGB(255, 170, 0),   -- Naranja
	Color3.fromRGB(180, 70, 255),  -- Morado
	Color3.fromRGB(0, 220, 220),   -- Cyan
	Color3.fromRGB(255, 255, 255), -- Blanco
}
local colorNames = {"Rojo", "Azul", "Verde", "Naranja", "Morado", "Cyan", "Blanco"}

--==================================================
-- STATE
--==================================================

local Character, Humanoid, Root
local sprintEnabled = false
local noclipEnabled = false
local flyEnabled = false
local infiniteJump = false
local menuClosedForever = false

local currentAimTarget = nil
local lastTargetUpdate = 0
local targetUpdateRate = 0.04

local activeSlider = nil
local draggingMenu = false
local dragStart, menuStart
local resizingMenu = false
local resizeStart, resizeMenuStart

local flyVelocity, flyGyro, flyConnection, noclipConnection
local ESP = {}
local Waypoints = {}
local hitboxParts = {}

--==================================================
-- THEMES
--==================================================

local Themes = {
	Red = {
		Name = "Rojo",
		Background = Color3.fromRGB(12,12,16),
		Panel = Color3.fromRGB(18,18,24),
		Panel2 = Color3.fromRGB(24,24,32),
		Element = Color3.fromRGB(28,28,36),
		ElementHover = Color3.fromRGB(38,38,48),
		Text = Color3.fromRGB(245,245,250),
		SubText = Color3.fromRGB(150,150,165),
		Muted = Color3.fromRGB(100,100,115),
		Accent = Color3.fromRGB(200,45,75),
		AccentLight = Color3.fromRGB(255,75,110),
		Track = Color3.fromRGB(45,45,55),
		White = Color3.fromRGB(255,255,255)
	},
	Purple = {
		Name = "Morado",
		Background = Color3.fromRGB(14,11,20),
		Panel = Color3.fromRGB(22,17,32),
		Panel2 = Color3.fromRGB(30,23,44),
		Element = Color3.fromRGB(36,28,52),
		ElementHover = Color3.fromRGB(48,38,68),
		Text = Color3.fromRGB(245,242,255),
		SubText = Color3.fromRGB(170,155,190),
		Muted = Color3.fromRGB(115,100,135),
		Accent = Color3.fromRGB(140,70,220),
		AccentLight = Color3.fromRGB(180,110,255),
		Track = Color3.fromRGB(55,45,70),
		White = Color3.fromRGB(255,255,255)
	},
	Blue = {
		Name = "Azul",
		Background = Color3.fromRGB(10,14,20),
		Panel = Color3.fromRGB(15,22,32),
		Panel2 = Color3.fromRGB(22,32,45),
		Element = Color3.fromRGB(28,40,55),
		ElementHover = Color3.fromRGB(38,52,72),
		Text = Color3.fromRGB(240,247,255),
		SubText = Color3.fromRGB(150,170,195),
		Muted = Color3.fromRGB(100,120,145),
		Accent = Color3.fromRGB(40,120,230),
		AccentLight = Color3.fromRGB(70,160,255),
		Track = Color3.fromRGB(45,55,70),
		White = Color3.fromRGB(255,255,255)
	},
	Green = {
		Name = "Verde",
		Background = Color3.fromRGB(10,16,13),
		Panel = Color3.fromRGB(15,24,18),
		Panel2 = Color3.fromRGB(22,34,26),
		Element = Color3.fromRGB(28,42,32),
		ElementHover = Color3.fromRGB(36,55,42),
		Text = Color3.fromRGB(240,255,245),
		SubText = Color3.fromRGB(150,180,160),
		Muted = Color3.fromRGB(95,125,105),
		Accent = Color3.fromRGB(35,160,85),
		AccentLight = Color3.fromRGB(60,210,115),
		Track = Color3.fromRGB(42,60,48),
		White = Color3.fromRGB(255,255,255)
	},
	Cyan = {
		Name = "Cyan",
		Background = Color3.fromRGB(8,15,17),
		Panel = Color3.fromRGB(12,24,28),
		Panel2 = Color3.fromRGB(18,35,40),
		Element = Color3.fromRGB(22,44,50),
		ElementHover = Color3.fromRGB(30,58,65),
		Text = Color3.fromRGB(235,255,255),
		SubText = Color3.fromRGB(140,190,195),
		Muted = Color3.fromRGB(85,130,135),
		Accent = Color3.fromRGB(0,180,200),
		AccentLight = Color3.fromRGB(40,230,245),
		Track = Color3.fromRGB(40,70,75),
		White = Color3.fromRGB(255,255,255)
	},
	Black = {
		Name = "Negro",
		Background = Color3.fromRGB(0,0,0),
		Panel = Color3.fromRGB(10,10,10),
		Panel2 = Color3.fromRGB(16,16,16),
		Element = Color3.fromRGB(22,22,22),
		ElementHover = Color3.fromRGB(32,32,32),
		Text = Color3.fromRGB(245,245,245),
		SubText = Color3.fromRGB(155,155,155),
		Muted = Color3.fromRGB(95,95,95),
		Accent = Color3.fromRGB(80,80,80),
		AccentLight = Color3.fromRGB(130,130,130),
		Track = Color3.fromRGB(50,50,50),
		White = Color3.fromRGB(255,255,255)
	}
}

local CurrentTheme = "Red"
local Theme = Themes[CurrentTheme]

--==================================================
-- CHARACTER
--==================================================

local function setupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Root = char:WaitForChild("HumanoidRootPart")
	Humanoid.WalkSpeed = sprintEnabled and sprintSpeed or DEFAULT_WALK_SPEED
	if flyEnabled then flyEnabled = false end
	if noclipEnabled then
		for _,obj in ipairs(char:GetDescendants()) do
			if obj:IsA("BasePart") then obj.CanCollide = false end
		end
	end
end

if LocalPlayer.Character then task.spawn(setupCharacter, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "CH_V12_Clean"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = obj
	return c
end

local function addStroke(obj, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Element
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = obj
	return s
end

local function tween(obj, time, props)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function makeButton(parent, text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 36)
	b.BackgroundColor3 = Theme.Element
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Theme.Text
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 12
	b.AutoButtonColor = false
	b.Parent = parent
	corner(b, 8)
	b.MouseEnter:Connect(function() tween(b, 0.12, {BackgroundColor3 = Theme.ElementHover}) end)
	b.MouseLeave:Connect(function() tween(b, 0.12, {BackgroundColor3 = Theme.Element}) end)
	return b
end

local function makeSection(parent, titleText)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 22)
	holder.BackgroundTransparency = 1
	holder.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = string.upper(titleText)
	label.TextColor3 = Theme.SubText
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder
	return holder
end

--==================================================
-- PASSWORD
--==================================================

local passwordFrame = Instance.new("Frame")
passwordFrame.Size = UDim2.fromOffset(340, 200)
passwordFrame.Position = UDim2.new(0.5, -170, 0.5, -100)
passwordFrame.BackgroundColor3 = Theme.Background
passwordFrame.BorderSizePixel = 0
passwordFrame.Parent = gui
corner(passwordFrame, 14)
local passwordStroke = addStroke(passwordFrame, Theme.Element, 1, 0)

local passwordTitle = Instance.new("TextLabel")
passwordTitle.Size = UDim2.new(1, -30, 0, 32)
passwordTitle.Position = UDim2.fromOffset(15, 14)
passwordTitle.BackgroundTransparency = 1
passwordTitle.Text = "😈  CH V12.5"
passwordTitle.TextColor3 = Theme.Text
passwordTitle.Font = Enum.Font.GothamBold
passwordTitle.TextSize = 20
passwordTitle.TextXAlignment = Enum.TextXAlignment.Left
passwordTitle.Parent = passwordFrame

local passwordInfo = Instance.new("TextLabel")
passwordInfo.Size = UDim2.new(1, -30, 0, 20)
passwordInfo.Position = UDim2.fromOffset(15, 48)
passwordInfo.BackgroundTransparency = 1
passwordInfo.Text = "Introduce la contraseña para continuar"
passwordInfo.TextColor3 = Theme.SubText
passwordInfo.Font = Enum.Font.Gotham
passwordInfo.TextSize = 12
passwordInfo.TextXAlignment = Enum.TextXAlignment.Left
passwordInfo.Parent = passwordFrame

local passwordBox = Instance.new("TextBox")
passwordBox.Size = UDim2.new(1, -30, 0, 38)
passwordBox.Position = UDim2.fromOffset(15, 78)
passwordBox.BackgroundColor3 = Theme.Element
passwordBox.BorderSizePixel = 0
passwordBox.PlaceholderText = "Contraseña"
passwordBox.PlaceholderColor3 = Theme.Muted
passwordBox.Text = ""
passwordBox.TextColor3 = Theme.Text
passwordBox.Font = Enum.Font.Gotham
passwordBox.TextSize = 13
passwordBox.ClearTextOnFocus = false
passwordBox.Parent = passwordFrame
corner(passwordBox, 8)

local enterButton = Instance.new("TextButton")
enterButton.Size = UDim2.new(1, -30, 0, 38)
enterButton.Position = UDim2.fromOffset(15, 128)
enterButton.BackgroundColor3 = Theme.Accent
enterButton.BorderSizePixel = 0
enterButton.Text = "ENTRAR"
enterButton.TextColor3 = Theme.White
enterButton.Font = Enum.Font.GothamBold
enterButton.TextSize = 13
enterButton.AutoButtonColor = false
enterButton.Parent = passwordFrame
corner(enterButton, 8)

--==================================================
-- MAIN MENU
--==================================================

local menu = Instance.new("Frame")
menu.Size = UDim2.fromOffset(400, 580)
menu.Position = UDim2.fromOffset(30, 70)
menu.BackgroundColor3 = Theme.Background
menu.BorderSizePixel = 0
menu.Visible = false
menu.Active = true
menu.Parent = gui
corner(menu, 14)
local menuStroke = addStroke(menu, Theme.Element, 1, 0)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 54)
header.BackgroundColor3 = Theme.Panel
header.BorderSizePixel = 0
header.Parent = menu
corner(header, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 26)
title.Position = UDim2.fromOffset(16, 6)
title.BackgroundTransparency = 1
title.Text = "😈  CH V12.5"
title.TextColor3 = Theme.Text
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 16)
subtitle.Position = UDim2.fromOffset(18, 32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "CLEAN CONTROL PANEL"
subtitle.TextColor3 = Theme.AccentLight
subtitle.Font = Enum.Font.GothamBold
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.Position = UDim2.new(1, -42, 0, 12)
closeButton.BackgroundColor3 = Theme.Element
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = Theme.SubText
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.AutoButtonColor = false
closeButton.Parent = header
corner(closeButton, 7)

local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.fromOffset(18, 18)
resizeHandle.AnchorPoint = Vector2.new(1, 1)
resizeHandle.Position = UDim2.new(1, -6, 1, -6)
resizeHandle.BackgroundColor3 = Theme.Accent
resizeHandle.BorderSizePixel = 0
resizeHandle.Text = "↘"
resizeHandle.TextColor3 = Theme.White
resizeHandle.Font = Enum.Font.GothamBold
resizeHandle.TextSize = 10
resizeHandle.AutoButtonColor = false
resizeHandle.ZIndex = 20
resizeHandle.Parent = menu
corner(resizeHandle, 5)

local MIN_MENU_WIDTH, MIN_MENU_HEIGHT = 340, 460
local MAX_MENU_WIDTH, MAX_MENU_HEIGHT = 650, 820

resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizingMenu = true
		resizeStart = input.Position
		resizeMenuStart = menu.AbsoluteSize
	end
end)

-- Tabs
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -24, 0, 36)
tabFrame.Position = UDim2.fromOffset(12, 64)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = menu

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -112)
content.Position = UDim2.fromOffset(12, 106)
content.BackgroundTransparency = 1
content.Parent = menu

local pages = {}
local function createPage()
	local p = Instance.new("ScrollingFrame")
	p.Size = UDim2.fromScale(1, 1)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ScrollBarThickness = 3
	p.ScrollBarImageColor3 = Theme.Accent
	p.CanvasSize = UDim2.fromOffset(0, 0)
	p.Visible = false
	p.Parent = content
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 7)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = p
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		p.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 14)
	end)
	table.insert(pages, p)
	return p
end

local homePage = createPage()
local aimPage = createPage()
local espPage = createPage()
local playersPage = createPage()
local configPage = createPage()

local tabs = {}
local function tab(text, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.2, -4, 1, 0)
	b.Position = UDim2.new(order, 0, 0, 0)
	b.BackgroundColor3 = Theme.Element
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Theme.SubText
	b.Font = Enum.Font.GothamBold
	b.TextSize = 10
	b.AutoButtonColor = false
	b.Parent = tabFrame
	corner(b, 7)
	table.insert(tabs, b)
	return b
end

local homeTab = tab("CASA", 0)
local aimTab = tab("AIM", 0.2)
local espTab = tab("ESP", 0.4)
local playersTab = tab("PLAYERS", 0.6)
local configTab = tab("CONFIG", 0.8)

local function showPage(page, selected)
	for _, p in ipairs(pages) do p.Visible = false end
	page.Visible = true
	for _, t in ipairs(tabs) do
		t.BackgroundColor3 = Theme.Element
		t.TextColor3 = Theme.SubText
	end
	selected.BackgroundColor3 = Theme.Accent
	selected.TextColor3 = Theme.White
end

homeTab.MouseButton1Click:Connect(function() showPage(homePage, homeTab) end)
aimTab.MouseButton1Click:Connect(function() showPage(aimPage, aimTab) end)
espTab.MouseButton1Click:Connect(function() showPage(espPage, espTab) end)
playersTab.MouseButton1Click:Connect(function() showPage(playersPage, playersTab) end)
configTab.MouseButton1Click:Connect(function() showPage(configPage, configTab) end)

--==================================================
-- SLIDER
--==================================================

local function createSlider(parent, text, min, max, value)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 52)
	holder.BackgroundTransparency = 1
	holder.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = text .. tostring(value)
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local bar = Instance.new("TextButton")
	bar.Size = UDim2.new(1, -2, 0, 6)
	bar.Position = UDim2.fromOffset(1, 28)
	bar.BackgroundColor3 = Theme.Track
	bar.BorderSizePixel = 0
	bar.Text = ""
	bar.AutoButtonColor = false
	bar.Parent = holder
	corner(bar, 4)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Parent = bar
	corner(fill, 4)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(13, 13)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Theme.White
	knob.BorderSizePixel = 0
	knob.Parent = bar
	corner(knob, 7)

	local slider = {bar = bar, fill = fill, knob = knob, label = label, min = min, max = max, value = value}

	local function update(x)
		local width = bar.AbsoluteSize.X
		if width <= 0 then return end
		local percent = math.clamp((x - bar.AbsolutePosition.X) / width, 0, 1)
		local newValue = math.floor(min + (max - min) * percent + 0.5)
		slider.value = newValue
		slider.label.Text = text .. tostring(newValue)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, 0, 0.5, 0)
		if slider.onChanged then slider.onChanged(newValue) end
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			activeSlider = slider
			update(input.Position.X)
		end
	end)

	slider.update = update
	task.defer(function()
		local percent = math.clamp((value - min) / (max - min), 0, 1)
		update(bar.AbsolutePosition.X + bar.AbsoluteSize.X * percent)
	end)
	return slider
end

--==================================================
-- HOME
--==================================================

makeSection(homePage, "MOVEMENT")
local noclipButton = makeButton(homePage, "👻  Noclip  •  OFF")
local sprintButton = makeButton(homePage, "🏃  Sprint  •  OFF")
local sprintSlider = createSlider(homePage, "Sprint Speed  ", MIN_SPRINT, MAX_SPRINT, sprintSpeed)
sprintSlider.onChanged = function(value)
	sprintSpeed = value
	if sprintEnabled and Humanoid then Humanoid.WalkSpeed = value end
end
local flySlider = createSlider(homePage, "Fly Speed  ", MIN_FLY, MAX_FLY, flySpeed)
flySlider.onChanged = function(value) flySpeed = value end
local flyButton = makeButton(homePage, "🪽  Fly  •  OFF")
local infiniteJumpButton = makeButton(homePage, "🦘  Infinite Jump  •  OFF")

--==================================================
-- AIM
--==================================================

makeSection(aimPage, "AIM SETTINGS")
local aimButton = makeButton(aimPage, "🎯  Aim  •  OFF")
local aimHoldButton = makeButton(aimPage, "🔘  Modo tecla  •  TOGGLE")
local friendsButton = makeButton(aimPage, "👥  Ignorar amigos  •  ON")
local teamButton = makeButton(aimPage, "🟢  Ignorar equipo  •  ON")
local throughWallsButton = makeButton(aimPage, "🧱  A través de paredes  •  OFF")

local aimFOVSlider = createSlider(aimPage, "FOV  ", 50, 500, aimFOV)
aimFOVSlider.onChanged = function(value) aimFOV = value end

local smoothSlider = createSlider(aimPage, "Suavizado  ", 5, 100, aimSmooth)
smoothSlider.onChanged = function(value) aimSmooth = value end

local targetParts = {"Head", "UpperTorso", "HumanoidRootPart"}
local targetIndex = 1
local aimTargetButton = makeButton(aimPage, "🎯  Objetivo  •  Head")

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.ZIndex = 50
fovCircle.Parent = gui
corner(fovCircle, 999)

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Theme.AccentLight
fovStroke.Thickness = 1.2
fovStroke.Transparency = 0.3
fovStroke.Parent = fovCircle

local function updateFOV()
	fovCircle.Size = UDim2.fromOffset(aimFOV * 2, aimFOV * 2)
	fovStroke.Color = Theme.AccentLight
end

--==================================================
-- AIM LOGIC
--==================================================

local function isValidTarget(plr)
	if not plr or plr == LocalPlayer then return false end
	if ignoreFriends then
		local ok, friend = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
		if ok and friend then return false end
	end
	if ignoreTeam and LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then return false end
	return true
end

local function canSeeTarget(part, char, camera)
	if aimThroughWalls then return true end
	local origin = camera.CFrame.Position
	local direction = part.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {LocalPlayer.Character}
	local result = workspace:Raycast(origin, direction, params)
	if not result then return true end
	return result.Instance:IsDescendantOf(char)
end

local function getClosestTarget()
	local camera = workspace.CurrentCamera
	if not camera then return nil end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local closest, closestDistance = nil, aimFOV

	for _, plr in ipairs(Players:GetPlayers()) do
		if isValidTarget(plr) then
			local char = plr.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local part = char:FindFirstChild(aimTargetPart)
				if hum and hum.Health > 0 and part then
					local screen, visible = camera:WorldToViewportPoint(part.Position)
					if visible and screen.Z > 0 and canSeeTarget(part, char, camera) then
						local distance = (Vector2.new(screen.X, screen.Y) - center).Magnitude
						if distance < closestDistance then
							closestDistance = distance
							closest = part
						end
					end
				end
			end
		end
	end
	return closest
end

RunService:BindToRenderStep("CH_V12_Aim", Enum.RenderPriority.Camera.Value + 1, function()
	updateFOV()
	if not aimEnabled then
		currentAimTarget = nil
		fovCircle.Visible = false
		return
	end
	if aimHoldMode and not aimHeld then
		currentAimTarget = nil
		fovCircle.Visible = true
		return
	end
	fovCircle.Visible = true
	local camera = workspace.CurrentCamera
	if not camera then currentAimTarget = nil return end

	local now = os.clock()
	if now - lastTargetUpdate >= targetUpdateRate then
		lastTargetUpdate = now
		currentAimTarget = getClosestTarget()
	end

	if currentAimTarget then
		local targetCharacter = currentAimTarget.Parent
		local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
		local targetPlayer = targetCharacter and Players:GetPlayerFromCharacter(targetCharacter)
		if not targetCharacter or not targetHumanoid or targetHumanoid.Health <= 0 or not isValidTarget(targetPlayer) then
			currentAimTarget = nil
		end
	end

	if currentAimTarget and currentAimTarget.Parent then
		local targetCF = CFrame.lookAt(camera.CFrame.Position, currentAimTarget.Position)
		local smooth = math.clamp(aimSmooth / 100, 0.01, 1)
		camera.CFrame = camera.CFrame:Lerp(targetCF, smooth)
	end
end)

aimButton.MouseButton1Click:Connect(function()
	aimEnabled = not aimEnabled
	aimButton.Text = aimEnabled and "🎯  Aim  •  ON" or "🎯  Aim  •  OFF"
	if not aimEnabled then fovCircle.Visible = false end
end)

aimHoldButton.MouseButton1Click:Connect(function()
	aimHoldMode = not aimHoldMode
	aimHeld = false
	currentAimTarget = nil
	aimHoldButton.Text = aimHoldMode and "🔘  Modo tecla  •  HOLD" or "🔘  Modo tecla  •  TOGGLE"
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		if aimHoldMode and aimEnabled then aimHeld = true end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aimHeld = false
		currentAimTarget = nil
	end
end)

throughWallsButton.MouseButton1Click:Connect(function()
	aimThroughWalls = not aimThroughWalls
	currentAimTarget = nil
	throughWallsButton.Text = aimThroughWalls and "🧱  A través de paredes  •  ON" or "🧱  A través de paredes  •  OFF"
end)
friendsButton.MouseButton1Click:Connect(function()
	ignoreFriends = not ignoreFriends
	currentAimTarget = nil
	friendsButton.Text = ignoreFriends and "👥  Ignorar amigos  •  ON" or "👥  Ignorar amigos  •  OFF"
end)
teamButton.MouseButton1Click:Connect(function()
	ignoreTeam = not ignoreTeam
	currentAimTarget = nil
	teamButton.Text = ignoreTeam and "🟢  Ignorar equipo  •  ON" or "🟢  Ignorar equipo  •  OFF"
end)
aimTargetButton.MouseButton1Click:Connect(function()
	targetIndex = targetIndex % #targetParts + 1
	aimTargetPart = targetParts[targetIndex]
	currentAimTarget = nil
	aimTargetButton.Text = "🎯  Objetivo  •  " .. aimTargetPart
end)

--==================================================
-- ESP
--==================================================

makeSection(espPage, "ESP SETTINGS")

local function removeESP(plr)
	local data = ESP[plr]
	if data then
		if data.highlight then data.highlight:Destroy() end
		if data.billboard then data.billboard:Destroy() end
		ESP[plr] = nil
	end
end

local function createESP(plr)
	if plr == LocalPlayer then return end
	removeESP(plr)
	local char = plr.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	local data = {character = char, root = root, humanoid = hum}
	if espBoxes then
		local highlight = Instance.new("Highlight")
		highlight.Adornee = char
		highlight.FillColor = Theme.Accent
		highlight.OutlineColor = Theme.Accent
		highlight.FillTransparency = 0.85
		highlight.OutlineTransparency = 0.1
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = gui
		data.highlight = highlight
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = root
	billboard.Size = UDim2.fromOffset(180, 60)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = gui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Theme.White
	label.TextStrokeTransparency = 0.4
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.Parent = billboard

	data.billboard = billboard
	data.label = label
	ESP[plr] = data
end

local function updateESP()
	if not espEnabled then
		for plr in pairs(ESP) do removeESP(plr) end
		return
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChildOfClass("Humanoid")
				if root and hum and hum.Health > 0 then
					local data = ESP[plr]
					if not data or data.character ~= char then
						createESP(plr)
						data = ESP[plr]
					end
					if data then
						local distance = Root and (Root.Position - root.Position).Magnitude or 0
						local visible = distance <= espMaxDistance
						if data.highlight then data.highlight.Enabled = visible and espBoxes end
						if data.billboard then data.billboard.Enabled = visible end
						if data.label and visible then
							local text = ""
							if espNames then text = plr.Name end
							if espHealth then text = text .. (text ~= "" and "\n" or "") .. "❤️ " .. math.floor(hum.Health) end
							if espDistance then text = text .. (text ~= "" and "\n" or "") .. "📏 " .. math.floor(distance) end
							data.label.Text = text
						end
					end
				else
					removeESP(plr)
				end
			else
				removeESP(plr)
			end
		end
	end
end

local espButton = makeButton(espPage, "👁  ESP  •  OFF")
local espNamesButton = makeButton(espPage, "🏷  Nombres  •  ON")
local espHealthButton = makeButton(espPage, "❤️  Vida  •  ON")
local espDistanceButton = makeButton(espPage, "📏  Distancia  •  ON")
local espBoxesButton = makeButton(espPage, "⬜  Boxes  •  ON")
local espDistanceSlider = createSlider(espPage, "Distancia ESP  ", 100, 2000, espMaxDistance)
espDistanceSlider.onChanged = function(value) espMaxDistance = value end

espButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espButton.Text = espEnabled and "👁  ESP  •  ON" or "👁  ESP  •  OFF"
	if espEnabled then updateESP() else for plr in pairs(ESP) do removeESP(plr) end end
end)
espNamesButton.MouseButton1Click:Connect(function()
	espNames = not espNames
	espNamesButton.Text = espNames and "🏷  Nombres  •  ON" or "🏷  Nombres  •  OFF"
end)
espHealthButton.MouseButton1Click:Connect(function()
	espHealth = not espHealth
	espHealthButton.Text = espHealth and "❤️  Vida  •  ON" or "❤️  Vida  •  OFF"
end)
espDistanceButton.MouseButton1Click:Connect(function()
	espDistance = not espDistance
	espDistanceButton.Text = espDistance and "📏  Distancia  •  ON" or "📏  Distancia  •  OFF"
end)
espBoxesButton.MouseButton1Click:Connect(function()
	espBoxes = not espBoxes
	espBoxesButton.Text = espBoxes and "⬜  Boxes  •  ON" or "⬜  Boxes  •  OFF"
	if espEnabled then for plr in pairs(ESP) do createESP(plr) end end
end)

--==================================================
-- PLAYERS + HITBOX
--==================================================

makeSection(playersPage, "TELEPORT TO PLAYER")

local playersListFrame = Instance.new("ScrollingFrame")
playersListFrame.Size = UDim2.new(1, 0, 0, 160)
playersListFrame.BackgroundColor3 = Theme.Panel2
playersListFrame.BorderSizePixel = 0
playersListFrame.ScrollBarThickness = 3
playersListFrame.ScrollBarImageColor3 = Theme.Accent
playersListFrame.CanvasSize = UDim2.fromOffset(0, 0)
playersListFrame.Parent = playersPage
corner(playersListFrame, 8)

local playersLayout = Instance.new("UIListLayout")
playersLayout.Padding = UDim.new(0, 4)
playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
playersLayout.Parent = playersListFrame
playersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	playersListFrame.CanvasSize = UDim2.fromOffset(0, playersLayout.AbsoluteContentSize.Y + 8)
end)

local function refreshPlayersList()
	for _, child in ipairs(playersListFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -10, 0, 28)
			btn.BackgroundColor3 = Theme.Element
			btn.BorderSizePixel = 0
			btn.Text = "  " .. plr.Name
			btn.TextColor3 = Theme.Text
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.AutoButtonColor = false
			btn.Parent = playersListFrame
			corner(btn, 6)
			btn.MouseEnter:Connect(function() tween(btn, 0.12, {BackgroundColor3 = Theme.ElementHover}) end)
			btn.MouseLeave:Connect(function() tween(btn, 0.12, {BackgroundColor3 = Theme.Element}) end)
			btn.MouseButton1Click:Connect(function()
				local targetChar = plr.Character
				if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and Root then
					Root.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
				end
			end)
		end
	end
end

makeSection(playersPage, "HITBOX EXPANDER")

local hitboxButton = makeButton(playersPage, "📦  Hitbox Expander  •  OFF")
local hitboxSlider = createSlider(playersPage, "Hitbox Size  ", 2, 25, hitboxSize)
local transparencySlider = createSlider(playersPage, "Transparencia  ", 0, 100, math.floor(hitboxTransparency * 100))
local colorButton = makeButton(playersPage, "🎨  Color Hitbox  •  Rojo")

local function clearHitboxes()
	for _, part in pairs(hitboxParts) do
		if part and part.Parent then part:Destroy() end
	end
	table.clear(hitboxParts)
end

local function updateHitboxes()
	clearHitboxes()
	if not hitboxEnabled then return end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local box = Instance.new("Part")
				box.Name = "CH_Hitbox"
				box.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
				box.Transparency = hitboxTransparency
				box.Color = hitboxColor
				box.Material = Enum.Material.ForceField
				box.Anchored = true
				box.CanCollide = false
				box.CanQuery = false
				box.CanTouch = false
				box.Parent = workspace
				table.insert(hitboxParts, box)

				local conn
				conn = RunService.Heartbeat:Connect(function()
					if not hitboxEnabled or not box or not box.Parent or not hrp or not hrp.Parent then
						if box then box:Destroy() end
						if conn then conn:Disconnect() end
						return
					end
					box.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
					box.Transparency = hitboxTransparency
					box.Color = hitboxColor
					box.CFrame = hrp.CFrame
				end)
			end
		end
	end
end

hitboxSlider.onChanged = function(value)
	hitboxSize = value
	if hitboxEnabled then updateHitboxes() end
end

transparencySlider.onChanged = function(value)
	hitboxTransparency = value / 100
	if hitboxEnabled then updateHitboxes() end
end

colorButton.MouseButton1Click:Connect(function()
	currentColorIndex = currentColorIndex % #hitboxColors + 1
	hitboxColor = hitboxColors[currentColorIndex]
	colorButton.Text = "🎨  Color Hitbox  •  " .. colorNames[currentColorIndex]
	if hitboxEnabled then updateHitboxes() end
end)

hitboxButton.MouseButton1Click:Connect(function()
	hitboxEnabled = not hitboxEnabled
	hitboxButton.Text = hitboxEnabled and "📦  Hitbox Expander  •  ON" or "📦  Hitbox Expander  •  OFF"
	updateHitboxes()
end)

--==================================================
-- FLY / NOCLIP / SPRINT / JUMP
--==================================================

local function stopFly()
	flyEnabled = false
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
	if flyGyro then flyGyro:Destroy() flyGyro = nil end
	if Humanoid then Humanoid.PlatformStand = false end
	if flyButton then flyButton.Text = "🪽  Fly  •  OFF" end
end

local function startFly()
	if not Root or not Humanoid then return end
	stopFly()
	flyEnabled = true
	Humanoid.PlatformStand = true
	flyVelocity = Instance.new("BodyVelocity")
	flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	flyVelocity.Velocity = Vector3.zero
	flyVelocity.Parent = Root
	flyGyro = Instance.new("BodyGyro")
	flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	flyGyro.P = 9000
	flyGyro.D = 500
	flyGyro.Parent = Root
	flyConnection = RunService.RenderStepped:Connect(function()
		if not flyEnabled or not Root or not Root.Parent then stopFly() return end
		local camera = workspace.CurrentCamera
		if not camera then return end
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
		if move.Magnitude > 0 then move = move.Unit * flySpeed end
		flyVelocity.Velocity = move
		flyGyro.CFrame = CFrame.lookAt(Root.Position, Root.Position + camera.CFrame.LookVector)
	end)
	flyButton.Text = "🪽  Fly  •  ON"
end

flyButton.MouseButton1Click:Connect(function()
	if flyEnabled then stopFly() else startFly() end
end)

local function setNoclip(state)
	noclipEnabled = state
	if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			if Character then
				for _, obj in ipairs(Character:GetDescendants()) do
					if obj:IsA("BasePart") then obj.CanCollide = false end
				end
			end
		end)
	else
		if Character then
			for _, obj in ipairs(Character:GetDescendants()) do
				if obj:IsA("BasePart") then obj.CanCollide = true end
			end
		end
	end
	noclipButton.Text = noclipEnabled and "👻  Noclip  •  ON" or "👻  Noclip  •  OFF"
end
noclipButton.MouseButton1Click:Connect(function() setNoclip(not noclipEnabled) end)

local function setSprint(state)
	sprintEnabled = state
	if Humanoid then Humanoid.WalkSpeed = sprintEnabled and sprintSpeed or DEFAULT_WALK_SPEED end
	sprintButton.Text = sprintEnabled and "🏃  Sprint  •  ON" or "🏃  Sprint  •  OFF"
end
sprintButton.MouseButton1Click:Connect(function() setSprint(not sprintEnabled) end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then setSprint(true) end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then setSprint(false) end
end)

infiniteJumpButton.MouseButton1Click:Connect(function()
	infiniteJump = not infiniteJump
	infiniteJumpButton.Text = infiniteJump and "🦘  Infinite Jump  •  ON" or "🦘  Infinite Jump  •  OFF"
end)
UserInputService.JumpRequest:Connect(function()
	if infiniteJump and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

--==================================================
-- FLOATING BUTTON
--==================================================

local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.fromOffset(48, 48)
floatingButton.Position = UDim2.fromOffset(25, 300)
floatingButton.BackgroundColor3 = Theme.Accent
floatingButton.BorderSizePixel = 0
floatingButton.Text = "😈"
floatingButton.TextSize = 20
floatingButton.Visible = false
floatingButton.AutoButtonColor = false
floatingButton.Parent = gui
corner(floatingButton, 24)
local floatingStroke = addStroke(floatingButton, Theme.Element, 1, 0)

local function setMenuVisible(state)
	if menuClosedForever then return end
	menu.Visible = state
	floatingButton.Visible = not state
end
closeButton.MouseButton1Click:Connect(function() setMenuVisible(false) end)
floatingButton.MouseButton1Click:Connect(function() setMenuVisible(true) end)

--==================================================
-- CONFIG + WAYPOINTS
--==================================================

makeSection(configPage, "THEMES")
local themeButton = makeButton(configPage, "🎨  Tema  •  " .. Theme.Name)
local themeNames = {"Red", "Purple", "Blue", "Green", "Cyan", "Black"}
local themeIndex = 1

makeSection(configPage, "MENU")
local waitingMenuKey = false
local keyButton = makeButton(configPage, "⌨  Tecla del menú  •  " .. MenuKey.Name)
local closeForever = makeButton(configPage, "🔒  Cerrar para siempre")

makeSection(configPage, "WAYPOINTS")
local waypointNameBox = Instance.new("TextBox")
waypointNameBox.Size = UDim2.new(1, 0, 0, 32)
waypointNameBox.BackgroundColor3 = Theme.Element
waypointNameBox.BorderSizePixel = 0
waypointNameBox.PlaceholderText = "Nombre del waypoint"
waypointNameBox.PlaceholderColor3 = Theme.Muted
waypointNameBox.Text = ""
waypointNameBox.TextColor3 = Theme.Text
waypointNameBox.Font = Enum.Font.Gotham
waypointNameBox.TextSize = 12
waypointNameBox.Parent = configPage
corner(waypointNameBox, 7)

local saveWaypointButton = makeButton(configPage, "📌  Guardar Waypoint")
local waypointsList = Instance.new("Frame")
waypointsList.Size = UDim2.new(1, 0, 0, 120)
waypointsList.BackgroundColor3 = Theme.Panel2
waypointsList.BorderSizePixel = 0
waypointsList.Parent = configPage
corner(waypointsList, 8)

local wpLayout = Instance.new("UIListLayout")
wpLayout.Padding = UDim.new(0, 4)
wpLayout.Parent = waypointsList

local function refreshWaypoints()
	for _, child in ipairs(waypointsList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for name, pos in pairs(Waypoints) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 0, 26)
		btn.BackgroundColor3 = Theme.Element
		btn.BorderSizePixel = 0
		btn.Text = "  📍 " .. name
		btn.TextColor3 = Theme.Text
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 11
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = waypointsList
		corner(btn, 6)
		btn.MouseButton1Click:Connect(function()
			if Root then Root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
		end)
	end
end

saveWaypointButton.MouseButton1Click:Connect(function()
	local name = waypointNameBox.Text
	if name == "" or not Root then return end
	Waypoints[name] = Root.Position
	waypointNameBox.Text = ""
	refreshWaypoints()
end)

--==================================================
-- THEME + INPUTS
--==================================================

local function applyTheme()
	Theme = Themes[CurrentTheme] or Themes.Red
	menu.BackgroundColor3 = Theme.Background
	menuStroke.Color = Theme.Element
	header.BackgroundColor3 = Theme.Panel
	title.TextColor3 = Theme.Text
	subtitle.TextColor3 = Theme.AccentLight
	closeButton.BackgroundColor3 = Theme.Element
	closeButton.TextColor3 = Theme.SubText
	resizeHandle.BackgroundColor3 = Theme.Accent
	floatingButton.BackgroundColor3 = Theme.Accent
	floatingStroke.Color = Theme.Element
	passwordFrame.BackgroundColor3 = Theme.Background
	passwordStroke.Color = Theme.Element
	enterButton.BackgroundColor3 = Theme.Accent
	themeButton.Text = "🎨  Tema  •  " .. Theme.Name
	updateFOV()
end

themeButton.MouseButton1Click:Connect(function()
	themeIndex = themeIndex % #themeNames + 1
	CurrentTheme = themeNames[themeIndex]
	applyTheme()
end)

keyButton.MouseButton1Click:Connect(function()
	waitingMenuKey = true
	keyButton.Text = "⌨  Presiona una tecla..."
end)

closeForever.MouseButton1Click:Connect(function()
	menuClosedForever = true
	stopFly()
	setSprint(false)
	setNoclip(false)
	aimEnabled = false
	for plr in pairs(ESP) do removeESP(plr) end
	clearHitboxes()
	gui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if waitingMenuKey and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			MenuKey = input.KeyCode
			waitingMenuKey = false
			keyButton.Text = "⌨  Tecla del menú  •  " .. MenuKey.Name
		end
		return
	end
	if input.KeyCode == MenuKey then
		setMenuVisible(not menu.Visible)
	end
end)

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMenu = true
		dragStart = input.Position
		menuStart = menu.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if activeSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		activeSlider.update(input.Position.X)
		return
	end
	if resizingMenu and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - resizeStart
		local newWidth = math.clamp(resizeMenuStart.X + delta.X, MIN_MENU_WIDTH, MAX_MENU_WIDTH)
		local newHeight = math.clamp(resizeMenuStart.Y + delta.Y, MIN_MENU_HEIGHT, MAX_MENU_HEIGHT)
		menu.Size = UDim2.fromOffset(newWidth, newHeight)
		return
	end
	if draggingMenu and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		menu.Position = UDim2.new(menuStart.X.Scale, menuStart.X.Offset + delta.X, menuStart.Y.Scale, menuStart.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMenu = false
		resizingMenu = false
		activeSlider = nil
	end
end)

task.spawn(function()
	while gui.Parent do
		if espEnabled then updateESP() end
		refreshPlayersList()
		task.wait(0.6)
	end
end)

local function authenticate()
	if passwordBox.Text == PASSWORD then
		passwordFrame.Visible = false
		menu.Visible = true
		floatingButton.Visible = false
		showPage(homePage, homeTab)
		print("😈 CH V12.5 iniciado")
	else
		passwordBox.Text = ""
		passwordBox.PlaceholderText = "Contraseña incorrecta"
	end
end

enterButton.MouseButton1Click:Connect(authenticate)
passwordBox.FocusLost:Connect(function(enter) if enter then authenticate() end end)

applyTheme()
passwordFrame.Visible = true
menu.Visible = false
floatingButton.Visible = false

print("😈 CH V12.5 cargado | Hitbox con Color + Transparencia")
