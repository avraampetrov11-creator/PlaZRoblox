-- LocalScript (place in StarterPlayerScripts)
-- Updated: Fixes the speed button so it reliably toggles the player's Humanoid WalkSpeed
-- between normal (16) and fast (40), and preserves state across respawns.
-- Also includes the UI panel + Fly button (improved to avoid duplicate RunService connections).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Speed settings
local NORMAL_SPEED = 16
local FAST_SPEED = 40

-- state
local speedOn = false
local flying = false

-- UI --------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlaZ_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 230, 0, 160)
panel.Position = UDim2.new(0.03, 0, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
panel.BackgroundTransparency = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0, 14)

local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Thickness = 1
panelStroke.Transparency = 0.7

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 6)
title.BackgroundTransparency = 1
title.Text = "PlaZ"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextYAlignment = Enum.TextYAlignment.Center

local flyBtn = Instance.new("TextButton", panel)
flyBtn.Size = UDim2.new(0.85, 0, 0, 44)
flyBtn.Position = UDim2.new(0.075, 0, 0.28, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
flyBtn.Font = Enum.Font.GothamSemibold
flyBtn.TextSize = 18
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Text = "Fly"
flyBtn.AutoButtonColor = true
local flyCorner = Instance.new("UICorner", flyBtn)
flyCorner.CornerRadius = UDim.new(0, 10)

local speedBtn = Instance.new("TextButton", panel)
speedBtn.Size = UDim2.new(0.85, 0, 0, 44)
speedBtn.Position = UDim2.new(0.075, 0, 0.68, 0)
speedBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
speedBtn.Font = Enum.Font.GothamSemibold
speedBtn.TextSize = 18
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Text = "Fast Speed"
speedBtn.AutoButtonColor = true
local speedCorner = Instance.new("UICorner", speedBtn)
speedCorner.CornerRadius = UDim.new(0, 10)

-- Utility: get current Humanoid (waits for character if needed)
local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		hum = char:WaitForChild("Humanoid")
	end
	return hum
end

-- Speed control ----------------------------------------------------------------
local function applySpeedState()
	local success, hum = pcall(getHumanoid)
	if not success or not hum then return end
	if speedOn then
		-- set fast
		hum.WalkSpeed = FAST_SPEED
		speedBtn.Text = "Normal Speed"
	else
		-- set normal
		hum.WalkSpeed = NORMAL_SPEED
		speedBtn.Text = "Fast Speed"
	end
end

-- Toggle handler (debounced)
local speedDebounce = false
local function toggleSpeed()
	if speedDebounce then return end
	speedDebounce = true
	speedOn = not speedOn
	applySpeedState()
	wait(0.2)
	speedDebounce = false
end

-- Fly control (improved: single RunService connection at a time)
local bodyVel, bodyGyro, flyConnection

local function startFly()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVel.Velocity = Vector3.new(0, 0, 0)
	bodyVel.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.CFrame = root.CFrame
	bodyGyro.Parent = root

	-- safe single connection
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	flyConnection = RunService.Heartbeat:Connect(function()
		if not flying then return end
		if not bodyVel or not bodyGyro or not root then return end
		local cam = workspace.CurrentCamera
		local move = Vector3.new(0, 0, 0)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			-- MoveDirection works for mobile and PC (virtual joystick / keyboard)
			move = hum.MoveDirection
		end
		-- multiply to get a nice speed; keep some upward to feel floaty
		local forwardVel = (cam and cam.CFrame.LookVector or root.CFrame.LookVector) * (move.Magnitude > 0 and 50 or 0)
		local upVel = Vector3.new(0, 28, 0) -- maintain height
		bodyVel.Velocity = forwardVel + upVel
		bodyGyro.CFrame = cam and cam.CFrame or root.CFrame
	end)

	flyBtn.Text = "Stop Fly"
end

local function stopFly()
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if bodyVel then
		bodyVel:Destroy()
		bodyVel = nil
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end
	flyBtn.Text = "Fly"
end

local function toggleFly()
	flying = not flying
	if flying then
		startFly()
	else
		stopFly()
	end
end

-- Connections -------------------------------------------------------------------
flyBtn.MouseButton1Click:Connect(toggleFly)
speedBtn.MouseButton1Click:Connect(toggleSpeed)

-- Ensure speed state is applied on spawn / respawn
player.CharacterAdded:Connect(function(char)
	-- small delay so Humanoid exists
	local hum = char:WaitForChild("Humanoid")
	-- apply whichever speed state we currently have
	if speedOn then
		-- short wait to ensure humanoid properties are writable
		hum.WalkSpeed = FAST_SPEED
	else
		hum.WalkSpeed = NORMAL_SPEED
	end

	-- If the player respawns while flying, stop fly to be safe (optional)
	if flying then
		-- reset flying state and UI (player must re-enable fly)
		flying = false
		stopFly()
	end
end)

-- Apply initial speed if character already exists
if player.Character then
	applySpeedState()
end
