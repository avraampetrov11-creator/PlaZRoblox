-- LocalScript (StarterPlayerScripts)

--// Setup
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Constants
local NORMAL_SPEED = 16
local FAST_SPEED = 40

-- States
local flying = false
local speedOn = false
local infJumpOn = false
local noclipOn = false

local bodyVel, bodyGyro, flyConnection, noclipConnection

--// UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlaZ_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 230, 0, 280)
panel.Position = UDim2.new(0.03, 0, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
panel.Parent = screenGui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", panel).Transparency = 0.7

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 6)
title.BackgroundTransparency = 1
title.Text = "PlaZ"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local function makeButton(text, yPos)
	local btn = Instance.new("TextButton", panel)
	btn.Size = UDim2.new(0.85, 0, 0, 40)
	btn.Position = UDim2.new(0.075, 0, yPos, 0)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 18
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.AutoButtonColor = true
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	return btn
end

-- Buttons
local flyBtn = makeButton("Fly", 0.18)
local speedBtn = makeButton("Fast Speed", 0.36)
local infJumpBtn = makeButton("Infinite Jump", 0.54)
local noclipBtn = makeButton("Noclip", 0.72)
local resetBtn = makeButton("Reset Character", 0.9)

--// Helpers
local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("Humanoid")
end

-- Fly
local function toggleFly()
	flying = not flying
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if flying then
		bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVel.Parent = root

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.CFrame = root.CFrame
		bodyGyro.Parent = root

		flyConnection = RunService.Heartbeat:Connect(function()
			if not flying then return end
			local cam = workspace.CurrentCamera
			local move = Vector3.new(0, 0, 0)
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then move = hum.MoveDirection end
			local forwardVel = (cam.CFrame.LookVector) * (move.Magnitude > 0 and 50 or 0)
			local upVel = Vector3.new(0, 28, 0)
			bodyVel.Velocity = forwardVel + upVel
			bodyGyro.CFrame = cam.CFrame
		end)

		flyBtn.Text = "Stop Fly"
	else
		if flyConnection then flyConnection:Disconnect() end
		if bodyVel then bodyVel:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		flyBtn.Text = "Fly"
	end
end

-- Speed
local function toggleSpeed()
	speedOn = not speedOn
	local hum = getHumanoid()
	if speedOn then
		hum.WalkSpeed = FAST_SPEED
		speedBtn.Text = "Normal Speed"
	else
		hum.WalkSpeed = NORMAL_SPEED
		speedBtn.Text = "Fast Speed"
	end
end

-- Infinite Jump
local function toggleInfJump()
	infJumpOn = not infJumpOn
	if infJumpOn then
		infJumpBtn.Text = "Stop Inf Jump"
		player:GetMouse().KeyDown:Connect(function(key)
			if key == Enum.KeyCode.Space.Name:lower() and infJumpOn then
				local hum = getHumanoid()
				if hum and hum.Parent:FindFirstChild("HumanoidRootPart") then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
		end)
	else
		infJumpBtn.Text = "Infinite Jump"
	end
end

-- Noclip
local function toggleNoclip()
	noclipOn = not noclipOn
	local char = player.Character
	if not char then return end

	if noclipOn then
		noclipConnection = RunService.Stepped:Connect(function()
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end)
		noclipBtn.Text = "Stop Noclip"
	else
		if noclipConnection then noclipConnection:Disconnect() end
		noclipBtn.Text = "Noclip"
	end
end

-- Reset
local function resetChar()
	if player.Character then
		player.Character:BreakJoints()
	end
end

--// Connect buttons
flyBtn.MouseButton1Click:Connect(toggleFly)
speedBtn.MouseButton1Click:Connect(toggleSpeed)
infJumpBtn.MouseButton1Click:Connect(toggleInfJump)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
resetBtn.MouseButton1Click:Connect(resetChar)

-- Reset speed when respawning
player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	hum.WalkSpeed = NORMAL_SPEED
	if flying then flying = false flyBtn.Text = "Fly" end
	if noclipOn then noclipOn = false noclipBtn.Text = "Noclip" end
end)

