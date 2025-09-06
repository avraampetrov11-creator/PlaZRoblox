-- LocalScript for Roblox UI Panel
-- Place this in StarterPlayerScripts

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "PlaZPanel"
gui.ResetOnSpawn = false

-- Main Frame: Small, compact, plain professional UI
local mainFrame = Instance.new("Frame")
mainFrame.Parent = gui
mainFrame.Size = UDim2.new(0.25, 0, 0.4, 0)  -- Compact size
mainFrame.Position = UDim2.new(0.375, 0, 0.3, 0)  -- Centered
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  -- Plain dark gray
mainFrame.BorderSizePixel = 0

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- Title Label: Simple and clean
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0.08, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PlaZ"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamSemibold

-- ScrollingFrame for buttons
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainFrame
scrollingFrame.Size = UDim2.new(1, 0, 0.92, 0)
scrollingFrame.Position = UDim2.new(0, 0, 0.08, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  -- Auto-adjust later

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Function to create plain professional buttons
local function createButton(name, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.85, 0, 0, 30)  -- Compact buttons
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = scrollingFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = button
    
    -- Subtle hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Services
local UIS = game:GetService("UserInputService")

-- Draggable functionality
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle states outside functions for persistence
local isFlying = false
local isSpeedEnabled = false
local isInfJump = false
local infJumpConnection
local isNoclip = false
local isInvisible = false
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local defaultGravity = 196.2

-- Fly with mobile joystick
createButton("Toggle Fly", function()
    isFlying = not isFlying
    if isFlying then
        local speed = 50
        local bodyGyro = Instance.new("BodyGyro", player.Character:WaitForChild("HumanoidRootPart"))
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = player.Character.HumanoidRootPart.CFrame
        
        local bodyVelocity = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Velocity = Vector3.zero
        
        local controlsGui
        local moveVector = Vector3.zero
        local verticalMove = 0
        
        if UIS.TouchEnabled then
            controlsGui = Instance.new("ScreenGui", player.PlayerGui)
            controlsGui.Name = "FlyControls"
            
            -- Joystick frame
            local joystickFrame = Instance.new("Frame", controlsGui)
            joystickFrame.Size = UDim2.new(0.15, 0, 0.25, 0)
            joystickFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
            joystickFrame.BackgroundTransparency = 0.7
            joystickFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            
            local jsCorner = Instance.new("UICorner", joystickFrame)
            jsCorner.CornerRadius = UDim.new(0.5, 0)
            
            local thumb = Instance.new("Frame", joystickFrame)
            thumb.Size = UDim2.new(0.5, 0, 0.5, 0)
            thumb.Position = UDim2.new(0.25, 0, 0.25, 0)
            thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            
            local thumbCorner = Instance.new("UICorner", thumb)
            thumbCorner.CornerRadius = UDim.new(0.5, 0)
            
            local touchObject
            local center = UDim2.new(0.5, 0, 0.5, 0)
            joystickFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    touchObject = input
                    thumb.Position = center
                end
            end)
            joystickFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    touchObject = nil
                    thumb.Position = center
                    moveVector = Vector3.zero
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if input == touchObject then
                    local absPos = joystickFrame.AbsolutePosition
                    local absSize = joystickFrame.AbsoluteSize / 2
                    local delta = (input.Position - Vector3.new(absPos.X + absSize.X, absPos.Y + absSize.Y, 0)) / absSize.X
                    local mag = delta.Magnitude
                    if mag > 1 then delta = delta.Unit end
                    thumb.Position = center + UDim2.new(0.25 * delta.X, 0, 0.25 * delta.Y)
                    moveVector = Vector3.new(delta.X, 0, -delta.Y)
                end
            end)
            
            -- Up/Down buttons
            local function createVertBtn(name, pos, dir)
                local btn = Instance.new("TextButton", controlsGui)
                btn.Size = UDim2.new(0.08, 0, 0.08, 0)
                btn.Position = pos
                btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                btn.Text = name
                btn.TextSize = 14
                local btnCorner = Instance.new("UICorner", btn)
                btnCorner.CornerRadius = UDim.new(0.5, 0)
                btn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch then verticalMove = dir end
                end)
                btn.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch then verticalMove = 0 end
                end)
            end
            createVertBtn("Up", UDim2.new(0.87, 0, 0.75, 0), 1)
            createVertBtn("Dn", UDim2.new(0.87, 0, 0.85, 0), -1)
        end
        
        spawn(function()
            while isFlying do
                local move = Vector3.zero
                -- Keyboard
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += Vector3.new(0, 0, -1) end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move += Vector3.new(0, 0, 1) end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move += Vector3.new(-1, 0, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += Vector3.new(1, 0, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move += Vector3.new(0, -1, 0) end
                if move.Magnitude > 0 then move = move.Unit * speed else move = Vector3.zero end
                
                -- Mobile
                move += moveVector * speed + Vector3.new(0, verticalMove * speed, 0)
                
                local hrp = player.Character.HumanoidRootPart
                bodyVelocity.Velocity = hrp.CFrame:VectorToWorldSpace(move)
                bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                task.wait()
            end
            if controlsGui then controlsGui:Destroy() end
        end)
    else
        local hrp = player.Character.HumanoidRootPart
        if hrp:FindFirstChild("BodyGyro") then hrp.BodyGyro:Destroy() end
        if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end
        local flyGui = player.PlayerGui:FindFirstChild("FlyControls")
        if flyGui then flyGui:Destroy() end
    end
end)

-- Fast Speed toggle
createButton("Toggle Fast Speed", function()
    isSpeedEnabled = not isSpeedEnabled
    player.Character.Humanoid.WalkSpeed = isSpeedEnabled and 100 or defaultWalkSpeed
end)

-- Infinite Jump toggle
createButton("Toggle Inf Jump", function()
    isInfJump = not isInfJump
    if isInfJump then
        infJumpConnection = UIS.JumpRequest:Connect(function()
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    elseif infJumpConnection then
        infJumpConnection:Disconnect()
        infJumpConnection = nil
    end
end)

-- Noclip toggle
createButton("Toggle Noclip", function()
    isNoclip = not isNoclip
    if isNoclip then
        spawn(function()
            while isNoclip do
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- Teleport to Spawn
createButton("TP to Spawn", function()
    local spawnLoc = workspace:FindFirstChildOfClass("SpawnLocation")
    if spawnLoc then
        player.Character.HumanoidRootPart.CFrame = spawnLoc.CFrame + Vector3.new(0, 3, 0)
    end
end)

-- God Mode (one-time, infinite health)
createButton("God Mode", function()
    local hum = player.Character.Humanoid
    hum.MaxHealth = math.huge
    hum.Health = math.huge
end)

-- Toggle Invisible
createButton("Toggle Invisible", function()
    isInvisible = not isInvisible
    for _, part in pairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = isInvisible and 1 or 0
        end
    end
end)

-- Reset Character
createButton("Reset Char", function()
    player.Character:BreakJoints()
end)

-- High Jump (set to high, no toggle)
createButton("High Jump", function()
    player.Character.Humanoid.JumpPower = 100
end)

-- Low Gravity
createButton("Low Gravity", function()
    workspace.Gravity = 50
end)

-- Reset Gravity
createButton("Reset Gravity", function()
    workspace.Gravity = defaultGravity
end)

-- ESP
createButton("Enable ESP", function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and not p.Character:FindFirstChild("Highlight") then
            local hl = Instance.new("Highlight", p.Character)
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    end
end)

-- Remove ESP
createButton("Remove ESP", function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("Highlight")
            if hl then hl:Destroy() end
        end
    end
end)

-- Auto-adjust canvas size
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end)

-- Close Button: Plain and compact
local closeButton = Instance.new("TextButton")
closeButton.Parent = mainFrame
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
closeButton.TextSize = 14
closeButton.BorderSizePixel = 0

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

closeButton.MouseEnter:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
end)
closeButton.MouseLeave:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
end)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
    if infJumpConnection then infJumpConnection:Disconnect() end
end)
