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
local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
local flying = false
local bv, bg
local isSpeedEnabled = false
local isHighlighted = false
local highlightInstance

-- GUI - Professional panel with plain colors, rounded corners, draggable
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Main Panel Frame
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(0, 140, 0, 180)  -- Compact size (will be adjusted)
mainPanel.Position = UDim2.new(0.05, 0, 0.78, 0)
mainPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  -- Plain dark gray
mainPanel.BorderSizePixel = 0
mainPanel.Parent = screenGui

-- Rounded corners for panel
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = mainPanel

-- Subtle gradient for cool effect
local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
panelGradient.Parent = mainPanel

-- Title "PlaZ" at top
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PlaZ"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainPanel

-- UIListLayout for buttons in panel
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = mainPanel

-- Function to create better buttons
-- callback receives the button instance as the first argument to avoid closure timing issues
local function createToggleButton(name, initialText, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.9, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  -- Plain gray
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 16
    button.Text = initialText
    button.BorderSizePixel = 0
    button.Parent = mainPanel
    button.AutoButtonColor = false  -- Custom hover

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    button.MouseLeave:Connect(function()
        -- preserve green when enabled
        if (button.Name == "SpeedToggle" and isSpeedEnabled) or (button.Name == "HighlightToggle" and isHighlighted) or (button.Name == "FlyToggle" and flying) then
            -- keep current enabled color
            return
        end
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    button.MouseButton1Click:Connect(function()
        callback(button)
    end)
    return button
end

-- Forward declarations for buttons so refreshCharacter can update them
local flyToggleButton, speedToggleButton, highlightToggleButton

-- Toggle Fly button
flyToggleButton = createToggleButton("FlyToggle", "Fly: OFF", function(btn)
    if flying then
        -- stop
        if typeof(stopFly) == "function" then stopFly() end
    else
        if typeof(startFly) == "function" then startFly() end
    end
    -- btn update happens inside startFly/stopFly
end)

-- Toggle Speed button
speedToggleButton = createToggleButton("SpeedToggle", "Speed: OFF", function(btn)
    isSpeedEnabled = not isSpeedEnabled
    if humanoid and humanoid.Parent then
        -- safety check
        humanoid.WalkSpeed = isSpeedEnabled and 100 or 16
    end
    btn.Text = "Speed: " .. (isSpeedEnabled and "ON" or "OFF")
    btn.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(50, 50, 50)
end)

-- Toggle Highlight button
highlightToggleButton = createToggleButton("HighlightToggle", "Highlight: OFF", function(btn)
    isHighlighted = not isHighlighted
    if isHighlighted then
        if character and character.Parent then
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
    btn.Text = "Highlight: " .. (isHighlighted and "ON" or "OFF")
    btn.BackgroundColor3 = isHighlighted and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(50, 50, 50)
end)

-- Adjust main panel size to fit title + 3 buttons + padding
mainPanel.Size = UDim2.new(0, 140, 0, 40 + 3*35 + 3*8 + 20)

-- Draggable panel
local dragging, dragInput, dragStart, startPos
mainPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainPanel.Position
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                conn:Disconnect()
            end
        end)
    end
end)
mainPanel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Up / Down buttons (right side, with rounded corners, better look)
local function createFlyButton(name, text, pos)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 64, 0, 64)
    button.Position = pos
    button.AnchorPoint = Vector2.new(0, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 30
    button.Text = text
    button.Visible = false
    button.Parent = screenGui
    button.AutoButtonColor = false

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.5, 0)  -- Circular
    buttonCorner.Parent = button

    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    return button
end

local upButton = createFlyButton("FlyUp", "↑", UDim2.new(0.85, 0, 0.68, 0))
local downButton = createFlyButton("FlyDown", "↓", UDim2.new(0.85, 0, 0.78, 0))

-- Helper to refresh character after respawn
local function refreshCharacter(c)
    character = c
    humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
    rootPart = character:FindFirstChild("HumanoidRootPart") or rootPart

    -- Re-apply states and GUI
    if isSpeedEnabled and humanoid then
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

    -- Update button visuals (if created)
    if speedToggleButton then
        speedToggleButton.Text = "Speed: " .. (isSpeedEnabled and "ON" or "OFF")
        speedToggleButton.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(0,150,50) or Color3.fromRGB(50,50,50)
    end
    if highlightToggleButton then
        highlightToggleButton.Text = "Highlight: " .. (isHighlighted and "ON" or "OFF")
        highlightToggleButton.BackgroundColor3 = isHighlighted and Color3.fromRGB(0,150,50) or Color3.fromRGB(50,50,50)
    end
end

if player.Character then
    refreshCharacter(player.Character)
end
player.CharacterAdded:Connect(refreshCharacter)

-- Start/stop fly
function startFly()
    if flying then return end
    if not character or not character.Parent then return end
    rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    flying = true
    if flyToggleButton then
        flyToggleButton.Text = "Fly: ON"
        flyToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    end
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

function stopFly()
    if not flying then return end
    flying = false
    if flyToggleButton then
        flyToggleButton.Text = "Fly: OFF"
        flyToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    upButton.Visible = false
    downButton.Visible = false

    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

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

-- Main movement loop
RunService.Heartbeat:Connect(function()
    if not flying or not bv or not bg then return end
    if not character or not character.Parent then return end
    rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    humanoid = character:FindFirstChildOfClass("Humanoid") or humanoid

    local moveDir = Vector3.new(0,0,0)
    if humanoid then
        moveDir = humanoid.MoveDirection or Vector3.new(0,0,0)
    end

    local vert = 0
    if upHeld then vert = vert + 1 end
    if downHeld then vert = vert - 1 end

    local horizontalVel = moveDir * FLY_SPEED
    local verticalVel = Vector3.new(0, vert * VERTICAL_SPEED, 0)
    local targetVel = horizontalVel + verticalVel

    bv.Velocity = bv.Velocity + (targetVel - bv.Velocity) * SMOOTH

    local cam = workspace.CurrentCamera
    if moveDir.Magnitude > 0.05 then
        local lookVec = Vector3.new(moveDir.X, 0, moveDir.Z)
        bg.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVec)
    elseif cam then
        bg.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cam.CFrame.LookVector)
    end
end)

-- Cleanup
player.CharacterRemoving:Connect(function()
    stopFly()
    isSpeedEnabled = false
    if speedToggleButton then
        speedToggleButton.Text = "Speed: OFF"
        speedToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    if highlightInstance then
        highlightInstance:Destroy()
        highlightInstance = nil
    end
    isHighlighted = false
    if highlightToggleButton then
        highlightToggleButton.Text = "Highlight: OFF"
        highlightToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

print("[ControlGUI] Loaded successfully")

