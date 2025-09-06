-- LocalScript: Place in StarterPlayer -> StarterPlayerScripts
-- All features implemented client-side only

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Flight settings
local FLY_SPEED = 60         -- horizontal speed
local VERTICAL_SPEED = 40    -- vertical speed when holding up/down
local SMOOTH = 0.15          -- smoothing factor (0..1)

-- State
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart
local flying = false
local bv, bg
local isSpeedEnabled = false
local isHighlighted = false
local highlightInstance

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Toggle Fly button (left bottom)
local flyToggleButton = Instance.new("TextButton")
flyToggleButton.Name = "FlyToggle"
flyToggleButton.Size = UDim2.new(0, 120, 0, 48)
flyToggleButton.Position = UDim2.new(0.05, 0, 0.78, 0)
flyToggleButton.AnchorPoint = Vector2.new(0, 0)
flyToggleButton.BackgroundColor3 = Color3.fromRGB(37, 150, 255)
flyToggleButton.TextColor3 = Color3.new(1,1,1)
flyToggleButton.Font = Enum.Font.SourceSansBold
flyToggleButton.TextSize = 20
flyToggleButton.Text = "Fly: OFF"
flyToggleButton.Parent = screenGui
flyToggleButton.AutoButtonColor = true

-- Toggle Speed button (next to fly)
local speedToggleButton = Instance.new("TextButton")
speedToggleButton.Name = "SpeedToggle"
speedToggleButton.Size = UDim2.new(0, 120, 0, 48)
speedToggleButton.Position = UDim2.new(0.05, 0, 0.88, 0)
speedToggleButton.AnchorPoint = Vector2.new(0, 0)
speedToggleButton.BackgroundColor3 = Color3.fromRGB(37, 150, 255)
speedToggleButton.TextColor3 = Color3.new(1,1,1)
speedToggleButton.Font = Enum.Font.SourceSansBold
speedToggleButton.TextSize = 20
speedToggleButton.Text = "Speed: OFF"
speedToggleButton.Parent = screenGui
speedToggleButton.AutoButtonColor = true

-- Toggle Highlight button (next to speed)
local highlightToggleButton = Instance.new("TextButton")
highlightToggleButton.Name = "HighlightToggle"
highlightToggleButton.Size = UDim2.new(0, 120, 0, 48)
highlightToggleButton.Position = UDim2.new(0.05, 0, 0.98, 0)
highlightToggleButton.AnchorPoint = Vector2.new(0, 0)
highlightToggleButton.BackgroundColor3 = Color3.fromRGB(37, 150, 255)
highlightToggleButton.TextColor3 = Color3.new(1,1,1)
highlightToggleButton.Font = Enum.Font.SourceSansBold
highlightToggleButton.TextSize = 20
highlightToggleButton.Text = "Highlight: OFF"
highlightToggleButton.Parent = screenGui
highlightToggleButton.AutoButtonColor = true

-- Up / Down buttons (right side) - visible only while flying
local upButton = Instance.new("TextButton")
upButton.Name = "FlyUp"
upButton.Size = UDim2.new(0, 64, 0, 64)
upButton.Position = UDim2.new(0.85, 0, 0.68, 0)
upButton.AnchorPoint = Vector2.new(0, 0)
upButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
upButton.TextColor3 = Color3.new(1,1,1)
upButton.Font = Enum.Font.SourceSansBold
upButton.TextSize = 30
upButton.Text = "↑"
upButton.Visible = false
upButton.Parent = screenGui
upButton.AutoButtonColor = true

local downButton = Instance.new("TextButton")
downButton.Name = "FlyDown"
downButton.Size = UDim2.new(0, 64, 0, 64)
downButton.Position = UDim2.new(0.85, 0, 0.78, 0)
downButton.AnchorPoint = Vector2.new(0, 0)
downButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
downButton.TextColor3 = Color3.new(1,1,1)
downButton.Font = Enum.Font.SourceSansBold
downButton.TextSize = 30
downButton.Text = "↓"
downButton.Visible = false
downButton.Parent = screenGui
downButton.AutoButtonColor = true

-- Helper to refresh character after respawn
local function refreshCharacter(c)
    character = c
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    -- Re-apply states if needed
    if isSpeedEnabled then
        humanoid.WalkSpeed = 100
    end
    if isHighlighted then
        if highlightInstance then highlightInstance:Destroy() end
        highlightInstance = Instance.new("Highlight")
        highlightInstance.Name = "SelfHighlight"
        highlightInstance.FillColor = Color3.fromRGB(255, 0, 0)
        highlightInstance.FillTransparency = 0.5
        highlightInstance.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlightInstance.OutlineTransparency = 0
        highlightInstance.Parent = character
    end
end

if player.Character then
    refreshCharacter(player.Character)
end
player.CharacterAdded:Connect(refreshCharacter)

-- Start/stop fly (client-side)
local function startFly()
    if flying then return end
    if not character or not character.Parent then return end
    rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    flying = true
    flyToggleButton.Text = "Fly: ON"
    flyToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    upButton.Visible = true
    downButton.Visible = true

    bv = Instance.new("BodyVelocity")
    bv.Name = "Fly_BodyVelocity"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.P = 3000
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = rootPart

    bg = Instance.new("BodyGyro")
    bg.Name = "Fly_BodyGyro"
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 3000
    bg.CFrame = rootPart.CFrame
    bg.Parent = rootPart

    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function stopFly()
    if not flying then return end
    flying = false
    flyToggleButton.Text = "Fly: OFF"
    flyToggleButton.BackgroundColor3 = Color3.fromRGB(37, 150, 255)
    upButton.Visible = false
    downButton.Visible = false

    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

-- Fly toggle handler
flyToggleButton.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

-- Speed toggle handler (local)
speedToggleButton.MouseButton1Click:Connect(function()
    isSpeedEnabled = not isSpeedEnabled
    if humanoid then
        humanoid.WalkSpeed = isSpeedEnabled and 100 or 16
    end
    speedToggleButton.Text = "Speed: " .. (isSpeedEnabled and "ON" or "OFF")
    speedToggleButton.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(37, 150, 255)
end)

-- Highlight toggle handler (local, visible only to self)
highlightToggleButton.MouseButton1Click:Connect(function()
    isHighlighted = not isHighlighted
    if isHighlighted then
        if character then
            if highlightInstance then highlightInstance:Destroy() end
            highlightInstance = Instance.new("Highlight")
            highlightInstance.Name = "SelfHighlight"
            highlightInstance.FillColor = Color3.fromRGB(255, 0, 0)
            highlightInstance.FillTransparency = 0.5
            highlightInstance.OutlineColor = Color3.fromRGB(255, 255, 0)
            highlightInstance.OutlineTransparency = 0
            highlightInstance.Parent = character
        end
    else
        if highlightInstance then
            highlightInstance:Destroy()
            highlightInstance = nil
        end
    end
    highlightToggleButton.Text = "Highlight: " .. (isHighlighted and "ON" or "OFF")
    highlightToggleButton.BackgroundColor3 = isHighlighted and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(37, 150, 255)
end)

-- Support touch and mouse for up/down hold detection
local upHeld = false
local downHeld = false
local function inputBeganOnButton(input, isUp)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isUp then upHeld = true else downHeld = true end
    end
end
local function inputEndedOnButton(input, isUp)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isUp then upHeld = false else downHeld = false end
    end
end

upButton.InputBegan:Connect(function(input) inputBeganOnButton(input, true) end)
upButton.InputEnded:Connect(function(input) inputEndedOnButton(input, true) end)
downButton.InputBegan:Connect(function(input) inputBeganOnButton(input, false) end)
downButton.InputEnded:Connect(function(input) inputEndedOnButton(input, false) end)

-- Main movement loop (physics, client-side)
RunService.Heartbeat:Connect(function()
    if not flying or not bv or not bg then return end
    if not character or not character.Parent then return end
    rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    humanoid = character:FindFirstChildOfClass("Humanoid") or humanoid

    -- Use Humanoid.MoveDirection for mobile joystick input (camera-relative)
    local moveDir = Vector3.new(0,0,0)
    if humanoid then
        moveDir = humanoid.MoveDirection
    end

    -- Vertical control from up/down buttons
    local vert = 0
    if upHeld then vert = vert + 1 end
    if downHeld then vert = vert - 1 end

    -- Target velocity
    local horizontalVel = moveDir * FLY_SPEED
    local verticalVel = Vector3.new(0, vert * VERTICAL_SPEED, 0)
    local targetVel = horizontalVel + verticalVel

    -- Smoothing the velocity
    bv.Velocity = bv.Velocity + (targetVel - bv.Velocity) * SMOOTH

    -- Orientation: face the movement direction, otherwise face camera
    local cam = workspace.CurrentCamera
    if moveDir.Magnitude > 0.05 then
        local lookVec = Vector3.new(moveDir.X, 0, moveDir.Z)
        bg.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVec)
    elseif cam then
        bg.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cam.CFrame.LookVector)
    end
end)

-- Cleanup if character removed
player.CharacterRemoving:Connect(function()
    stopFly()
    isSpeedEnabled = false
    speedToggleButton.Text = "Speed: OFF"
    speedToggleButton.BackgroundColor3 = Color3.fromRGB(37, 150, 255)
    if highlightInstance then
        highlightInstance:Destroy()
        highlightInstance = nil
    end
    isHighlighted = false
    highlightToggleButton.Text = "Highlight: OFF"
    highlightToggleButton.BackgroundColor3 = Color3.fromRGB(37, 150, 255)
end)
