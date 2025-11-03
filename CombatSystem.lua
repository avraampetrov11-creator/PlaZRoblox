--// LocalScript inside StarterPlayerScripts
--// Full Saw Slash + Target Lock System

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Animation IDs
local idleAnimId = 299246734
local sawAnims = {
	243641880,   -- SawSlash
	243642291,   -- SawSlashU0
	243642696    -- SawSlashOther
}

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SawSlashUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Saw Button
local button = Instance.new("ImageButton")
button.Name = "SawButton"
button.Size = UDim2.new(0, 100, 0, 100)
button.Position = UDim2.new(1, -120, 0.5, -50)
button.BackgroundTransparency = 1
button.Image = "rbxassetid://111546284473515"
button.Parent = screenGui

-- Charge Bar
local barBackground = Instance.new("Frame")
barBackground.Size = UDim2.new(0, 300, 0, 20)
barBackground.Position = UDim2.new(0.5, -150, 0.75, 0)
barBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBackground.BackgroundTransparency = 0.3
barBackground.BorderSizePixel = 0
barBackground.Visible = false
barBackground.Parent = screenGui

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 10)
bgCorner.Parent = barBackground

local chargeBar = Instance.new("Frame")
chargeBar.Size = UDim2.new(0, 0, 1, 0)
chargeBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
chargeBar.BorderSizePixel = 0
chargeBar.Parent = barBackground

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 10)
barCorner.Parent = chargeBar

-- Toggle Button (Target Lock)
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "TargetToggleButton"
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(1, -190, 0.5, -30) -- Left of saw button
toggleButton.BackgroundTransparency = 1
toggleButton.Image = "rbxassetid://3926305904" -- Circle icon
toggleButton.ImageColor3 = Color3.fromRGB(100, 100, 100) -- Gray = OFF
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

-- Target Billboard (Floating Name)
local targetBillboard = Instance.new("BillboardGui")
targetBillboard.Size = UDim2.new(0, 100, 0, 30)
targetBillboard.StudsOffset = Vector3.new(0, 3, 0)
targetBillboard.Adornee = nil
targetBillboard.AlwaysOnTop = true
targetBillboard.Enabled = false
targetBillboard.Parent = screenGui

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, 0, 1, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
targetLabel.TextStrokeTransparency = 0.7
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextScaled = true
targetLabel.Parent = targetBillboard

-- Animations
local idleAnim = Instance.new("Animation")
idleAnim.AnimationId = "rbxassetid://" .. idleAnimId
local idleTrack = humanoid:LoadAnimation(idleAnim)
idleTrack.Looped = true
idleTrack:Play()

-- Variables
local currentTrack
local charging = false
local charge = 0
local maxCharge = 2.5
local dashing = false
local dashHitPlayers = {}
local HIT_DISTANCE = 4

-- Targeting Variables
local targeting = false
local selectedTarget = nil
local targetConnection = nil
local ping = 0
local clickConnection = nil

-- Update Ping
task.spawn(function()
	while true do
		ping = player:GetNetworkPing()
		task.wait(0.5)
	end
end)

-- Functions
local function pushForward(strength)
	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(1e5, 0, 1e5)
	bodyVel.Velocity = root.CFrame.LookVector * strength
	bodyVel.Parent = root
	game:GetService("Debris"):AddItem(bodyVel, 0.3)
end

local function getBarColor(ratio)
	local r = math.clamp(ratio * 2, 0, 1)
	local g = math.clamp(2 - ratio * 2, 0, 1)
	return Color3.new(r, g, 0)
end

local function startCharge()
	if charging then return end
	charging = true
	charge = 0
	barBackground.Visible = true

	if idleTrack.IsPlaying then idleTrack:Stop() end
	if currentTrack then currentTrack:Stop() end

	local randomAnimId = sawAnims[math.random(1, #sawAnims)]
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. randomAnimId
	currentTrack = humanoid:LoadAnimation(anim)
	currentTrack:Play()
	currentTrack:AdjustSpeed(0)

	while charging and charge < maxCharge do
		task.wait(0.03)
		charge += 0.07
		local ratio = math.clamp(charge / maxCharge, 0, 1)
		chargeBar.Size = UDim2.new(ratio, 0, 1, 0)
		chargeBar.BackgroundColor3 = getBarColor(ratio)
	end
end

local function releaseCharge()
	if not charging then return end
	charging = false
	barBackground.Visible = false

	if currentTrack then currentTrack:AdjustSpeed(1.05) end

	local pushPower = 150 * (charge / maxCharge)
	pushForward(pushPower)
	dashing = true
	dashHitPlayers = {}

	local dashStart = tick()
	local dashDuration = 0.3

	local connection
	connection = RunService.Heartbeat:Connect(function()
		if tick() - dashStart > dashDuration then
			connection:Disconnect()
			dashing = false
			if not idleTrack.IsPlaying then idleTrack:Play() end
			return
		end

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local otherRoot = otherPlayer.Character.HumanoidRootPart
				local distance = (otherRoot.Position - root.Position).Magnitude
				if distance < HIT_DISTANCE and not dashHitPlayers[otherPlayer] then
					dashHitPlayers[otherPlayer] = true
					RS.Events.Core_Replication:FireServer("Change_Att", otherPlayer.Character.Character_Settings, "Ragdoll", true)
					task.delay(9, function()
						if otherPlayer.Character and otherPlayer.Character:FindFirstChild("Character_Settings") then
							RS.Events.Core_Replication:FireServer("Change_Att", otherPlayer.Character.Character_Settings, "Ragdoll", false)
						end
					end)
				end
			end
		end
	end)

	chargeBar.Size = UDim2.new(0, 0, 1, 0)
end

-- Predictive Look-At
local function getPredictedPosition(targetRoot)
	if not targetRoot or not targetRoot.Parent then return nil end
	local vel = targetRoot.Velocity
	local pos = targetRoot.Position
	local latency = ping + 0.05
	return pos + vel * latency
end

local function lookAtTarget()
	if not selectedTarget or not selectedTarget.Character or not selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local targetRoot = selectedTarget.Character.HumanoidRootPart
	local predictedPos = getPredictedPosition(targetRoot)
	if not predictedPos then return end

	local lookAt = Vector3.new(predictedPos.X, root.Position.Y, predictedPos.Z)
	local currentCFrame = root.CFrame
	local targetCFrame = CFrame.new(root.Position, lookAt)
	root.CFrame = currentCFrame:Lerp(targetCFrame, 0.25)
end

-- Select Target via Click
local function enableTargetSelection()
	if clickConnection then clickConnection:Disconnect() end

	local mouse = player:GetMouse()
	clickConnection = mouse.Button1Down:Connect(function()
		if not targeting then return end

		local target = mouse.Target
		if not target then return end

		local model = target:FindFirstAncestorWhichIsA("Model")
		if not model then return end

		local targetPlayer = Players:GetPlayerFromCharacter(model)
		if targetPlayer and targetPlayer ~= player then
			selectedTarget = targetPlayer
			local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
			targetBillboard.Adornee = head
			targetLabel.Text = targetPlayer.DisplayName
			targetBillboard.Enabled = true
		end
	end)
end

-- Toggle Targeting Mode
toggleButton.MouseButton1Click:Connect(function()
	targeting = not targeting

	if targeting then
		toggleButton.ImageColor3 = Color3.fromRGB(0, 255, 100) -- Green = ON
		enableTargetSelection()
		if targetConnection then targetConnection:Disconnect() end
		targetConnection = RunService.RenderStepped:Connect(lookAtTarget)
	else
		toggleButton.ImageColor3 = Color3.fromRGB(100, 100, 100) -- Gray = OFF
		targetBillboard.Enabled = false
		if targetConnection then
			targetConnection:Disconnect()
			targetConnection = nil
		end
		if clickConnection then
			clickConnection:Disconnect()
			clickConnection = nil
		end
		selectedTarget = nil
	end
end)

-- Handle Respawn
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	root = newChar:WaitForChild("HumanoidRootPart")

	-- Reload idle animation
	idleAnim = Instance.new("Animation")
	idleAnim.AnimationId = "rbxassetid://" .. idleAnimId
	idleTrack = humanoid:LoadAnimation(idleAnim)
	idleTrack.Looped = true
	idleTrack:Play()

	-- Reconnect targeting if active
	task.wait(1)
	if targeting and selectedTarget and selectedTarget.Character then
		local head = selectedTarget.Character:FindFirstChild("Head") or selectedTarget.Character:FindFirstChild("HumanoidRootPart")
		targetBillboard.Adornee = head
		targetBillboard.Enabled = true
	end
end)

-- Re-attach billboard on target respawn
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		if selectedTarget == plr then
			task.wait(1)
			local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
			targetBillboard.Adornee = head
			targetBillboard.Enabled = targeting
		end
	end)
end)

-- Input Connections
button.MouseButton1Down:Connect(startCharge)
button.MouseButton1Up:Connect(releaseCharge)

-- Mobile Long Press Support
button.TouchLongPress:Connect(function(_, state)
	if state == Enum.UserInputState.Begin then
		startCharge()
	elseif state == Enum.UserInputState.End then
		releaseCharge()
	end
end)