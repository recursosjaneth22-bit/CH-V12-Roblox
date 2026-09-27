--==================================================
-- 😈 CH PC - Trigger + ESP + TEXTURAS ULTRA MAX
-- X = menú · Q = trigger · sin FOV
-- DETECCIÓN OPTIMIZADA
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local MenuKey = Enum.KeyCode.X
local TriggerKey = Enum.KeyCode.Q

local triggerbotEnabled = false
local lastTriggerShot = 0

local ignoreFriends = true
local ignoreTeam = true

local espEnabled = false
local espNames = true
local espHealth = true
local espDistance = true
local espBoxes = true
local espMaxDistance = 1000
local ESP = {}

local Character, Root

local menuClosedForever = false
local streamerMode = false
local waitingMenuKey = false
local waitingTriggerKey = false
local activeSlider = nil
local draggingMenu = false
local dragStart, menuStart

--==================================================
-- TEXTURAS / ULTRA MAX
--==================================================

local texturesRemoved = false
local savedVisuals = {}

--==================================================
-- TEMA
--==================================================

local Theme = {
	Background = Color3.fromRGB(12, 12, 16),
	Panel = Color3.fromRGB(18, 18, 24),
	Element = Color3.fromRGB(28, 28, 36),
	ElementHover = Color3.fromRGB(38, 38, 48),
	Text = Color3.fromRGB(245, 245, 250),
	SubText = Color3.fromRGB(150, 150, 165),
	Accent = Color3.fromRGB(200, 45, 75),
	AccentLight = Color3.fromRGB(255, 75, 110),
	Track = Color3.fromRGB(45, 45, 55),
	White = Color3.fromRGB(255, 255, 255)
}

--==================================================
-- CHARACTER
--==================================================

local function setupChar(char)
	Character = char
	Root = char:WaitForChild("HumanoidRootPart", 5)
end

if LocalPlayer.Character then
	task.spawn(setupChar, LocalPlayer.Character)
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "CH_PC"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
	gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
	gui.Parent = PlayerGui
end

--==================================================
-- SOUND
--==================================================

local toggleSound = Instance.new("Sound")
toggleSound.Name = "CH_Toggle"
toggleSound.SoundId = "rbxassetid://6026984224"
toggleSound.Volume = 3
toggleSound.Parent = gui

local function playToggleSound(enabled)
	pcall(function()
		toggleSound.PlaybackSpeed = enabled and 1.6 or 0.85
		toggleSound.Volume = 3
		toggleSound.TimePosition = 0
		toggleSound:Play()
	end)
end

--==================================================
-- UI HELPERS
--==================================================

local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
end

local function tween(obj, t, props)
	TweenService:Create(
		obj,
		TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		props
	):Play()
end

local function makeButton(parent, text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 34)
	b.BackgroundColor3 = Theme.Element
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Theme.Text
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 12
	b.AutoButtonColor = false
	b.Parent = parent

	corner(b, 8)

	b.MouseEnter:Connect(function()
		tween(b, 0.12, {
			BackgroundColor3 = Theme.ElementHover
		})
	end)

	b.MouseLeave:Connect(function()
		tween(b, 0.12, {
			BackgroundColor3 = Theme.Element
		})
	end)

	return b
end

local function makeSection(parent, titleText)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 20)
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
end

--==================================================
-- MAIN MENU
--==================================================

local menu = Instance.new("Frame")
menu.Size = UDim2.fromOffset(360, 480)
menu.Position = UDim2.fromOffset(30, 50)
menu.BackgroundColor3 = Theme.Background
menu.BorderSizePixel = 0
menu.Visible = true
menu.Active = true
menu.Parent = gui

corner(menu, 14)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Theme.Panel
header.BorderSizePixel = 0
header.Parent = menu

corner(header, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 22)
title.Position = UDim2.fromOffset(14, 6)
title.BackgroundTransparency = 1
title.Text = "😈  CH PC"
title.TextColor3 = Theme.Text
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -50, 0, 14)
subtitle.Position = UDim2.fromOffset(14, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "TRIGGER  |  ESP  |  MENU"
subtitle.TextColor3 = Theme.AccentLight
subtitle.Font = Enum.Font.GothamBold
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(28, 28)
closeButton.Position = UDim2.new(1, -38, 0, 11)
closeButton.BackgroundColor3 = Theme.Element
closeButton.Text = "×"
closeButton.TextColor3 = Theme.SubText
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = header

corner(closeButton, 7)

--==================================================
-- TABS
--==================================================

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 32)
tabFrame.Position = UDim2.fromOffset(10, 56)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = menu

local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -20, 1, -100)
contentHolder.Position = UDim2.fromOffset(10, 94)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = menu

local pages = {}
local tabs = {}

local function createPage()
	local p = Instance.new("ScrollingFrame")
	p.Size = UDim2.fromScale(1, 1)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ScrollBarThickness = 3
	p.ScrollBarImageColor3 = Theme.Accent
	p.CanvasSize = UDim2.fromOffset(0, 0)
	p.Visible = false
	p.Parent = contentHolder

	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 6)
	lay.Parent = p

	lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		p.CanvasSize = UDim2.fromOffset(
			0,
			lay.AbsoluteContentSize.Y + 12
		)
	end)

	table.insert(pages, p)

	return p
end

local triggerPage = createPage()
local espPage = createPage()
local menuPage = createPage()
local texturePage = createPage()

local function makeTab(text, order, width)
	local b = Instance.new("TextButton")

	b.Size = UDim2.new(width, -4, 1, 0)
	b.Position = UDim2.new(order, 0, 0, 0)
	b.BackgroundColor3 = Theme.Element
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Theme.SubText
	b.Font = Enum.Font.GothamBold
	b.TextSize = 10
	b.Parent = tabFrame

	corner(b, 6)

	table.insert(tabs, b)

	return b
end

local tabWidth = 1 / 4

local triggerTab = makeTab("TRIGGER", 0, tabWidth)
local espTab = makeTab("ESP", tabWidth, tabWidth)
local configTab = makeTab("MENU", tabWidth * 2, tabWidth)
local textureTab = makeTab("TEXTURAS", tabWidth * 3, tabWidth)

local function showPage(page, selected)
	for _, p in ipairs(pages) do
		p.Visible = false
	end

	page.Visible = true

	for _, t in ipairs(tabs) do
		t.BackgroundColor3 = Theme.Element
		t.TextColor3 = Theme.SubText
	end

	selected.BackgroundColor3 = Theme.Accent
	selected.TextColor3 = Theme.White
end

triggerTab.MouseButton1Click:Connect(function()
	showPage(triggerPage, triggerTab)
end)

espTab.MouseButton1Click:Connect(function()
	showPage(espPage, espTab)
end)

configTab.MouseButton1Click:Connect(function()
	showPage(menuPage, configTab)
end)

textureTab.MouseButton1Click:Connect(function()
	showPage(texturePage, textureTab)
end)

--==================================================
-- SLIDER
--==================================================

local function createSlider(parent, text, min, max, value)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 48)
	holder.BackgroundTransparency = 1
	holder.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 16)
	label.BackgroundTransparency = 1
	label.Text = text .. tostring(value)
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local bar = Instance.new("TextButton")
	bar.Size = UDim2.new(1, -2, 0, 6)
	bar.Position = UDim2.fromOffset(1, 26)
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
	knob.Size = UDim2.fromOffset(12, 12)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Theme.White
	knob.BorderSizePixel = 0
	knob.Parent = bar

	corner(knob, 6)

	local slider = {
		bar = bar,
		fill = fill,
		knob = knob,
		label = label,
		min = min,
		max = max,
		value = value
	}

	local function update(x)
		local width = bar.AbsoluteSize.X

		if width <= 0 then
			return
		end

		local percent = math.clamp(
			(x - bar.AbsolutePosition.X) / width,
			0,
			1
		)

		local newValue = math.floor(
			min + (max - min) * percent + 0.5
		)

		slider.value = newValue
		slider.label.Text = text .. tostring(newValue)

		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, 0, 0.5, 0)

		if slider.onChanged then
			slider.onChanged(newValue)
		end
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			activeSlider = slider
			update(input.Position.X)
		end
	end)

	slider.update = update

	task.defer(function()
		local percent = math.clamp(
			(value - min) / (max - min),
			0,
			1
		)

		update(
			bar.AbsolutePosition.X +
			bar.AbsoluteSize.X * percent
		)
	end)

	return slider
end

--==================================================
-- BUTTONS
--==================================================

makeSection(triggerPage, "TRIGGERBOT")

local triggerbotButton =
	makeButton(triggerPage, "🔫  Triggerbot  •  OFF")

local triggerKeyButton =
	makeButton(triggerPage, "⌨  Tecla Trigger  •  Q")

local friendsButton =
	makeButton(triggerPage, "👥  Ignorar amigos  •  ON")

local teamButton =
	makeButton(triggerPage, "🟢  Ignorar equipo  •  ON")

makeSection(espPage, "ESP")

local espButton =
	makeButton(espPage, "👁  ESP  •  OFF")

local espNamesButton =
	makeButton(espPage, "🏷  Nombres  •  ON")

local espHealthButton =
	makeButton(espPage, "❤️  Vida  •  ON")

local espDistanceButton =
	makeButton(espPage, "📏  Distancia  •  ON")

local espBoxesButton =
	makeButton(espPage, "⬜  Boxes  •  ON")

local espDistSlider =
	createSlider(espPage, "Distancia ESP  ", 100, 2000, 1000)

espDistSlider.onChanged = function(v)
	espMaxDistance = v
end

makeSection(menuPage, "MENU")

local keyButton =
	makeButton(menuPage, "⌨  Tecla menú  •  X")

local streamerButton =
	makeButton(menuPage, "📺  Modo Streamer  •  OFF")

local closeForever =
	makeButton(menuPage, "🔒  Cerrar para siempre")

--==================================================
-- TEXTURAS PAGE
--==================================================

makeSection(texturePage, "TEXTURAS")

local textureButton =
	makeButton(texturePage, "🔥  ULTRA MAX  •  OFF")

local textureInfo = Instance.new("TextLabel")
textureInfo.Size = UDim2.new(1, 0, 0, 55)
textureInfo.BackgroundTransparency = 1
textureInfo.Text =
	"ULTRA MAX: reduce texturas, partículas, luces y efectos visuales para priorizar rendimiento."
textureInfo.TextColor3 = Theme.SubText
textureInfo.Font = Enum.Font.Gotham
textureInfo.TextSize = 10
textureInfo.TextWrapped = true
textureInfo.TextXAlignment = Enum.TextXAlignment.Left
textureInfo.Parent = texturePage

--==================================================
-- SISTEMA ULTRA MAX
--==================================================

local function saveAndSet(obj, property, value)
	pcall(function()
		if not savedVisuals[obj] then
			savedVisuals[obj] = {}
		end

		if savedVisuals[obj][property] == nil then
			savedVisuals[obj][property] = obj[property]
		end

		obj[property] = value
	end)
end

local function processVisualObject(obj)

	if obj:IsA("Decal") then
		saveAndSet(obj, "Transparency", 1)
		return
	end

	if obj:IsA("Texture") then
		saveAndSet(obj, "Transparency", 1)
		return
	end

	if obj:IsA("SurfaceAppearance") then
		saveAndSet(obj, "Parent", nil)
		return
	end

	if obj:IsA("ParticleEmitter") then
		saveAndSet(obj, "Enabled", false)
		return
	end

	if obj:IsA("Trail") then
		saveAndSet(obj, "Enabled", false)
		return
	end

	if obj:IsA("Beam") then
		saveAndSet(obj, "Enabled", false)
		return
	end

	if obj:IsA("Fire") then
		saveAndSet(obj, "Enabled", false)
		return
	end

	if obj:IsA("Smoke") then
		saveAndSet(obj, "Enabled", false)
		return
	end

	if obj:IsA("Sparkles") then
		saveAndSet(obj, "Enabled", false)
		return
	end

	if obj:IsA("PointLight")
		or obj:IsA("SpotLight")
		or obj:IsA("SurfaceLight") then

		saveAndSet(obj, "Enabled", false)
		return
	end

	if obj:IsA("BloomEffect")
		or obj:IsA("BlurEffect")
		or obj:IsA("ColorCorrectionEffect")
		or obj:IsA("DepthOfFieldEffect")
		or obj:IsA("SunRaysEffect") then

		saveAndSet(obj, "Enabled", false)
		return
	end

	if obj:IsA("Atmosphere") then
		saveAndSet(obj, "Density", 0)
		saveAndSet(obj, "Haze", 0)
		saveAndSet(obj, "Glare", 0)
		return
	end
end

local function removeAllTextures()

	if texturesRemoved then
		return
	end

	table.clear(savedVisuals)

	for _, obj in ipairs(workspace:GetDescendants()) do
		processVisualObject(obj)
	end

	for _, obj in ipairs(Lighting:GetDescendants()) do
		processVisualObject(obj)
	end

	for _, plr in ipairs(Players:GetPlayers()) do

		if plr.Character then
			for _, obj in ipairs(plr.Character:GetDescendants()) do
				processVisualObject(obj)
			end
		end

		if plr:FindFirstChild("PlayerGui") then
			for _, obj in ipairs(plr.PlayerGui:GetDescendants()) do
				processVisualObject(obj)
			end
		end
	end

	texturesRemoved = true
end

local function restoreAllTextures()

	if not texturesRemoved then
		return
	end

	for obj, properties in pairs(savedVisuals) do

		if obj then

			for property, oldValue in pairs(properties) do

				pcall(function()

					if property == "Parent" then

						if oldValue then
							obj.Parent = oldValue
						end

					else
						obj[property] = oldValue
					end

				end)
			end
		end
	end

	table.clear(savedVisuals)
	texturesRemoved = false
end

workspace.DescendantAdded:Connect(function(obj)

	if not texturesRemoved then
		return
	end

	task.defer(function()

		if texturesRemoved
			and obj.Parent then

			processVisualObject(obj)
		end
	end)
end)

Lighting.DescendantAdded:Connect(function(obj)

	if not texturesRemoved then
		return
	end

	task.defer(function()

		if texturesRemoved
			and obj.Parent then

			processVisualObject(obj)
		end
	end)
end)

local function setTexturesState(remove)

	if remove then

		removeAllTextures()

		textureButton.Text =
			"🔥  ULTRA MAX  •  ON"

		playToggleSound(true)

	else

		restoreAllTextures()

		textureButton.Text =
			"🔥  ULTRA MAX  •  OFF"

		playToggleSound(false)
	end
end

textureButton.MouseButton1Click:Connect(function()
	setTexturesState(not texturesRemoved)
end)

--==================================================
-- FLOATING BUTTON
--==================================================

local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.fromOffset(46, 46)
floatingButton.Position = UDim2.fromOffset(25, 280)
floatingButton.BackgroundColor3 = Theme.Accent
floatingButton.Text = "😈"
floatingButton.TextSize = 18
floatingButton.Visible = false
floatingButton.Parent = gui

corner(floatingButton, 23)

--==================================================
-- MENU CONTROL
--==================================================

local function setStreamerMode(on)

	streamerMode = on == true

	streamerButton.Text =
		streamerMode
		and "📺  Modo Streamer  •  ON"
		or "📺  Modo Streamer  •  OFF"

	if streamerMode then
		menu.Visible = false
		floatingButton.Visible = false
	end
end

local function setMenuVisible(state, showBall)

	if menuClosedForever then
		return
	end

	if streamerMode then
		menu.Visible = false
		floatingButton.Visible = false
		return
	end

	menu.Visible = state

	floatingButton.Visible =
		(not state) and (showBall == true)
end

closeButton.MouseButton1Click:Connect(function()
	setMenuVisible(false, true)
end)

floatingButton.MouseButton1Click:Connect(function()
	setMenuVisible(true, false)
end)

streamerButton.MouseButton1Click:Connect(function()
	setStreamerMode(not streamerMode)
end)

--==================================================
-- TARGET FILTER
--==================================================

local function isFriend(plr)

	if not ignoreFriends or not plr then
		return false
	end

	local ok, friend = pcall(function()
		return LocalPlayer:IsFriendsWith(plr.UserId)
	end)

	return ok and friend == true
end

local function isSameTeam(plr)

	if not ignoreTeam then
		return false
	end

	if not plr or plr == LocalPlayer then
		return false
	end

	-- IMPORTANTE:
	-- Si ambos tienen Team, compara directamente.
	if LocalPlayer.Team ~= nil
		and plr.Team ~= nil then

		return LocalPlayer.Team == plr.Team
	end

	return false
end

local function shouldTarget(plr)

	if not plr or plr == LocalPlayer then
		return false
	end

	-- FILTRO DE AMIGOS
	if ignoreFriends and isFriend(plr) then
		return false
	end

	-- FILTRO DE EQUIPO
	if ignoreTeam and isSameTeam(plr) then
		return false
	end

	return true
end

--==================================================
-- TRIGGERBOT
--==================================================

local TRIGGER_INTERVAL = 0.008
local TRIGGER_DISTANCE = 3000
local TRIGGER_PIXEL_TOLERANCE = 16

local triggerRayParams = RaycastParams.new()
triggerRayParams.FilterType =
	Enum.RaycastFilterType.Exclude
triggerRayParams.IgnoreWater = true

local function updateTriggerFilter()

	if Character then

		triggerRayParams.FilterDescendantsInstances = {
			Character
		}

	else

		triggerRayParams.FilterDescendantsInstances =
			{}
	end
end

updateTriggerFilter()

LocalPlayer.CharacterAdded:Connect(function(char)

	Character = char

	Root =
		char:WaitForChild(
			"HumanoidRootPart",
			5
		)

	updateTriggerFilter()
end)

--==================================================
-- PARTES DEL CUERPO
--==================================================

local TriggerParts = {

	"Head",

	"UpperTorso",
	"LowerTorso",
	"HumanoidRootPart",

	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",

	"RightUpperArm",
	"RightLowerArm",
	"RightHand",

	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",

	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",

	-- R6
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg"
}

local function getTargetCharacterFromPart(part)

	if not part then
		return nil, nil
	end

	local character =
		part:FindFirstAncestorOfClass(
			"Model"
		)

	if not character then
		return nil, nil
	end

	local humanoid =
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	if not humanoid
		or humanoid.Health <= 0 then

		return nil, nil
	end

	local player =
		Players:GetPlayerFromCharacter(
			character
		)

	if not player then
		return nil, nil
	end

	--==================================================
	-- FILTRO OBLIGATORIO
	--==================================================

	if not shouldTarget(player) then
		return nil, nil
	end

	return character, player
end

local function canSeeTargetPart(
	character,
	part,
	camera
)

	if not character or not part then
		return false
	end

	local origin =
		camera.CFrame.Position

	local direction =
		part.Position - origin

	if direction.Magnitude
		> TRIGGER_DISTANCE then

		return false
	end

	local result =
		workspace:Raycast(
			origin,
			direction,
			triggerRayParams
		)

	if not result then
		return false
	end

	return result.Instance == part
		or result.Instance:IsDescendantOf(
			character
		)
end

--==================================================
-- DETECCIÓN
--==================================================

local function isEnemyExactlyUnderCrosshair()

	local camera =
		workspace.CurrentCamera

	if not camera then
		return false
	end

	local mousePos =
		UserInputService:GetMouseLocation()

	--==================================================
	-- FAST PATH
	--==================================================

	local ray =
		camera:ScreenPointToRay(
			mousePos.X,
			mousePos.Y
		)

	local result =
		workspace:Raycast(
			ray.Origin,
			ray.Direction * TRIGGER_DISTANCE,
			triggerRayParams
		)

	if result and result.Instance then

		local character, player =
			getTargetCharacterFromPart(
				result.Instance
			)

		-- IMPORTANTE:
		-- Solo dispara si el personaje pasó
		-- todos los filtros.
		if character
			and player
			and shouldTarget(player) then

			return true
		end
	end

	--==================================================
	-- BODY PART SCAN
	--==================================================

	local closestPart = nil

	local closestDistance =
		TRIGGER_PIXEL_TOLERANCE

	local closestCharacter = nil
	local closestPlayer = nil

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		-- FILTRO ANTES DE ESCANEAR
		if shouldTarget(player) then

			local character =
				player.Character

			if character then

				local humanoid =
					character:FindFirstChildOfClass(
						"Humanoid"
					)

				if humanoid
					and humanoid.Health > 0 then

					for _, partName in ipairs(
						TriggerParts
					) do

						local part =
							character:FindFirstChild(
								partName
							)

						if part
							and part:IsA("BasePart")
							and part.Transparency < 1 then

							local screenPosition, onScreen =
								camera:WorldToViewportPoint(
									part.Position
								)

							if onScreen
								and screenPosition.Z > 0 then

								local dx =
									screenPosition.X
									- mousePos.X

								local dy =
									screenPosition.Y
									- mousePos.Y

								local screenDistance =
									math.sqrt(
										dx * dx +
										dy * dy
									)

								if screenDistance
									< closestDistance then

									closestDistance =
										screenDistance

									closestPart =
										part

									closestCharacter =
										character

									closestPlayer =
										player
								end
							end
						end
					end
				end
			end
		end
	end

	--==================================================
	-- FILTRO FINAL
	--==================================================

	if closestPart
		and closestCharacter
		and closestPlayer then

		-- Segunda comprobación para evitar
		-- cualquier disparo a compañeros.
		if not shouldTarget(
			closestPlayer
		) then

			return false
		end

		if canSeeTargetPart(
			closestCharacter,
			closestPart,
			camera
		) then

			return true
		end
	end

	return false
end

--==================================================
-- DISPARO
--==================================================

local function clickMouse()

	if mouse1press
		and mouse1release then

		pcall(function()

			mouse1press()
			mouse1release()

		end)

		return
	end

	pcall(function()

		local VIM =
			game:GetService(
				"VirtualInputManager"
			)

		local UIS =
			game:GetService(
				"UserInputService"
			)

		local pos =
			UIS:GetMouseLocation()

		VIM:SendMouseButtonEvent(
			pos.X,
			pos.Y,
			0,
			true,
			game,
			0
		)

		VIM:SendMouseButtonEvent(
			pos.X,
			pos.Y,
			0,
			false,
			game,
			0
		)
	end)
end

local function doTriggerbot()

	if not triggerbotEnabled then
		return
	end

	local now =
		os.clock()

	if now - lastTriggerShot
		< TRIGGER_INTERVAL then

		return
	end

	if isEnemyExactlyUnderCrosshair() then

		lastTriggerShot =
			now

		clickMouse()
	end
end

RunService.RenderStepped:Connect(
	doTriggerbot
)

--==================================================
-- ESP
--==================================================

local function removeESP(plr)

	local data = ESP[plr]

	if data then

		if data.highlight then
			data.highlight:Destroy()
		end

		if data.billboard then
			data.billboard:Destroy()
		end

		ESP[plr] = nil
	end
end

local function createESP(plr)

	if not shouldTarget(plr) then
		return
	end

	removeESP(plr)

	local char =
		plr.Character

	if not char then
		return
	end

	local root =
		char:FindFirstChild(
			"HumanoidRootPart"
		)

	local hum =
		char:FindFirstChildOfClass(
			"Humanoid"
		)

	if not root or not hum then
		return
	end

	local data = {
		character = char,
		root = root,
		humanoid = hum
	}

	if espBoxes then

		local hl =
			Instance.new("Highlight")

		hl.Adornee = char

		hl.FillColor =
			Theme.Accent

		hl.OutlineColor =
			Theme.Accent

		hl.FillTransparency =
			0.85

		hl.OutlineTransparency =
			0.1

		hl.DepthMode =
			Enum.HighlightDepthMode.AlwaysOnTop

		hl.Parent = gui

		data.highlight = hl
	end

	local bill =
		Instance.new("BillboardGui")

	bill.Adornee = root

	bill.Size =
		UDim2.fromOffset(
			160,
			55
		)

	bill.StudsOffset =
		Vector3.new(0, 3, 0)

	bill.AlwaysOnTop = true
	bill.Parent = gui

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.fromScale(1, 1)

	label.BackgroundTransparency = 1

	label.TextColor3 =
		Theme.White

	label.TextStrokeTransparency =
		0.4

	label.Font =
		Enum.Font.GothamBold

	label.TextSize = 11
	label.Parent = bill

	data.billboard = bill
	data.label = label

	ESP[plr] = data
end

local function updateESP()

	if not espEnabled then

		for plr in pairs(ESP) do
			removeESP(plr)
		end

		return
	end

	for _, plr in ipairs(
		Players:GetPlayers()
	) do

		if not shouldTarget(plr) then

			removeESP(plr)

		else

			local char =
				plr.Character

			if char then

				local root =
					char:FindFirstChild(
						"HumanoidRootPart"
					)

				local hum =
					char:FindFirstChildOfClass(
						"Humanoid"
					)

				if root
					and hum
					and hum.Health > 0 then

					local data =
						ESP[plr]

					if not data
						or data.character ~= char then

						createESP(plr)
						data = ESP[plr]
					end

					if data then

						local distance =
							Root
							and (
								Root.Position
								- root.Position
							).Magnitude
							or 0

						local visible =
							distance
							<= espMaxDistance

						if data.highlight then

							data.highlight.Enabled =
								visible
								and espBoxes
						end

						if data.billboard then

							data.billboard.Enabled =
								visible
						end

						if data.label
							and visible then

							local text = ""

							if espNames then
								text = plr.Name
							end

							if espHealth then

								text =
									text
									.. (
										text ~= ""
										and "\n"
										or ""
									)
									.. "❤️ "
									.. math.floor(
										hum.Health
									)
							end

							if espDistance then

								text =
									text
									.. (
										text ~= ""
										and "\n"
										or ""
									)
									.. "📏 "
									.. math.floor(
										distance
									)
							end

							data.label.Text =
								text
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

task.spawn(function()

	while gui.Parent do

		if espEnabled then
			updateESP()
		end

		task.wait(0.45)
	end
end)

--==================================================
-- TRIGGER BUTTONS
--==================================================

local function setTriggerState(on)

	triggerbotEnabled =
		on == true

	triggerbotButton.Text =
		triggerbotEnabled
		and "🔫  Triggerbot  •  ON"
		or "🔫  Triggerbot  •  OFF"

	playToggleSound(
		triggerbotEnabled
	)
end

triggerbotButton.MouseButton1Click:Connect(
	function()

		setTriggerState(
			not triggerbotEnabled
		)
	end
)

triggerKeyButton.MouseButton1Click:Connect(
	function()

		waitingTriggerKey = true
		waitingMenuKey = false

		triggerKeyButton.Text =
			"⌨  Presiona tecla Trigger..."
	end
)

friendsButton.MouseButton1Click:Connect(
	function()

		ignoreFriends =
			not ignoreFriends

		friendsButton.Text =
			ignoreFriends
			and "👥  Ignorar amigos  •  ON"
			or "👥  Ignorar amigos  •  OFF"
	end
)

teamButton.MouseButton1Click:Connect(
	function()

		ignoreTeam =
			not ignoreTeam

		teamButton.Text =
			ignoreTeam
			and "🟢  Ignorar equipo  •  ON"
			or "🟢  Ignorar equipo  •  OFF"
	end
)

--==================================================
-- ESP BUTTONS
--==================================================

espButton.MouseButton1Click:Connect(
	function()

		espEnabled =
			not espEnabled

		espButton.Text =
			espEnabled
			and "👁  ESP  •  ON"
			or "👁  ESP  •  OFF"

		if not espEnabled then

			for plr in pairs(ESP) do
				removeESP(plr)
			end
		end
	end
)

espNamesButton.MouseButton1Click:Connect(
	function()

		espNames =
			not espNames

		espNamesButton.Text =
			espNames
			and "🏷  Nombres  •  ON"
			or "🏷  Nombres  •  OFF"
	end
)

espHealthButton.MouseButton1Click:Connect(
	function()

		espHealth =
			not espHealth

		espHealthButton.Text =
			espHealth
			and "❤️  Vida  •  ON"
			or "❤️  Vida  •  OFF"
	end
)

espDistanceButton.MouseButton1Click:Connect(
	function()

		espDistance =
			not espDistance

		espDistanceButton.Text =
			espDistance
			and "📏  Distancia  •  ON"
			or "📏  Distancia  •  OFF"
	end
)

espBoxesButton.MouseButton1Click:Connect(
	function()

		espBoxes =
			not espBoxes

		espBoxesButton.Text =
			espBoxes
			and "⬜  Boxes  •  ON"
			or "⬜  Boxes  •  OFF"

		if espEnabled then

			for plr in pairs(ESP) do
				createESP(plr)
			end
		end
	end
)

--==================================================
-- MENU KEY
--==================================================

keyButton.MouseButton1Click:Connect(
	function()

		waitingMenuKey = true
		waitingTriggerKey = false

		keyButton.Text =
			"⌨  Presiona tecla menú..."
	end
)

--==================================================
-- CLOSE FOREVER
--==================================================

closeForever.MouseButton1Click:Connect(
	function()

		menuClosedForever = true
		triggerbotEnabled = false
		espEnabled = false
		streamerMode = false

		if texturesRemoved then
			restoreAllTextures()
		end

		for plr in pairs(ESP) do
			removeESP(plr)
		end

		gui:Destroy()
	end
)

--==================================================
-- KEYBOARD
--==================================================

UserInputService.InputBegan:Connect(
	function(input, processed)

		if waitingTriggerKey
			and input.UserInputType
				== Enum.UserInputType.Keyboard then

			if input.KeyCode
				~= Enum.KeyCode.Unknown then

				TriggerKey =
					input.KeyCode

				waitingTriggerKey =
					false

				triggerKeyButton.Text =
					"⌨  Tecla Trigger  •  "
					.. TriggerKey.Name
			end

			return
		end

		if waitingMenuKey
			and input.UserInputType
				== Enum.UserInputType.Keyboard then

			if input.KeyCode
				~= Enum.KeyCode.Unknown then

				MenuKey =
					input.KeyCode

				waitingMenuKey =
					false

				keyButton.Text =
					"⌨  Tecla menú  •  "
					.. MenuKey.Name
			end

			return
		end

		if processed then
			return
		end

		if input.KeyCode == TriggerKey then

			setTriggerState(
				not triggerbotEnabled
			)

			return
		end

		if input.KeyCode == MenuKey then

			if streamerMode then

				setStreamerMode(false)

				setMenuVisible(
					true,
					false
				)

			else

				if menu.Visible then

					setMenuVisible(
						false,
						false
					)

				else

					setMenuVisible(
						true,
						false
					)
				end
			end
		end
	end
)

--==================================================
-- MENU DRAG
--==================================================

header.InputBegan:Connect(
	function(input)

		if input.UserInputType
			== Enum.UserInputType.MouseButton1 then

			draggingMenu = true
			dragStart = input.Position
			menuStart = menu.Position
		end
	end
)

UserInputService.InputChanged:Connect(
	function(input)

		if activeSlider
			and input.UserInputType
				== Enum.UserInputType.MouseMovement then

			activeSlider.update(
				input.Position.X
			)

			return
		end

		if draggingMenu
			and input.UserInputType
				== Enum.UserInputType.MouseMovement then

			local delta =
				input.Position
				- dragStart

			menu.Position =
				UDim2.new(
					menuStart.X.Scale,
					menuStart.X.Offset
						+ delta.X,

					menuStart.Y.Scale,
					menuStart.Y.Offset
						+ delta.Y
				)
		end
	end
)

UserInputService.InputEnded:Connect(
	function(input)

		if input.UserInputType
			== Enum.UserInputType.MouseButton1 then

			draggingMenu = false
			activeSlider = nil
		end
	end
)

--==================================================
-- START
--==================================================

showPage(
	triggerPage,
	triggerTab
)

print(
	"😈 CH PC | Trigger + ESP + ULTRA MAX | Team Filter Fixed"
)
