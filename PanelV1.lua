-- LocalScript for Roblox UI Panel
-- Place this in StarterPlayerScripts or similar

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "PlaZPanel"
gui.ResetOnSpawn = false  -- Prevent reset on respawn

-- Main Frame (Panel) with rounded corners
local mainFrame = Instance.new("Frame")
mainFrame.Parent = gui
mainFrame.Size = UDim2.new(0.5, 0, 0.7, 0)  -- Big screen: 50% width, 70% height
mainFrame.Position = UDim2.new(0.25, 0, 0.15, 0)  -- Centered
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  -- Dark background
mainFrame.BorderSizePixel = 0

-- Rounded corners for smooth design
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 20)  -- Smooth round edges
uiCorner.Parent = mainFrame

-- Title Label "PlaZ" at the top
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)  -- 10% height of frame
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PlaZ"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 40
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextStrokeTransparency = 0.8  -- Slight stroke for visibility

-- ScrollingFrame for buttons to make it "long" with many features
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainFrame
scrollingFrame.Size = UDim2.new(1, 0, 0.9, 0)
scrollingFrame.Position = UDim2.new(0, 0, 0.1, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)  -- Make it long vertically

-- UIListLayout for organizing buttons vertically
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Function to create a button
local function createButton(name, callback)
    local button = Instance.new("TextButton")
    button.Parent = scrollingFrame
    button.Size = UDim2.new(0.8, 0, 0, 50)  -- Wide buttons
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 24
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Services
local UIS = game:GetService("UserInputService")

-- Make panel draggable (works for mouse and touch)
local dragging = false
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
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
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Fly Button
createButton("Fly", function()
    -- Simple fly script with mobile support
    local flying = false
    local speed = 50
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")
    local controlsGui
    local moveDirections = {}
    
    if flying then
        flying = false
        bodyGyro:Destroy()
        bodyVelocity:Destroy()
        if controlsGui then controlsGui:Destroy() end
    else
        flying = true
        bodyGyro.Parent = player.Character:WaitForChild("HumanoidRootPart")
        bodyGyro.CFrame = player.Character.HumanoidRootPart.CFrame
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        bodyVelocity.Parent = player.Character.HumanoidRootPart
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        -- Mobile controls if touch enabled
        if UIS.TouchEnabled then
            controlsGui = Instance.new("ScreenGui")
            controlsGui.Parent = player.PlayerGui
            controlsGui.Name = "FlyControls"
            
            local directionVectors = {
                Forward = Vector3.new(0, 0, -1),
                Backward = Vector3.new(0, 0, 1),
                Left = Vector3.new(-1, 0, 0),
                Right = Vector3.new(1, 0, 0),
                Up = Vector3.new(0, 1, 0),
                Down = Vector3.new(0, -1, 0)
            }
            
            -- Create buttons with positions (simple layout)
            local function createControlButton(name, pos)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, 80, 0, 80)
                btn.Position = pos
                btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                btn.Text = name
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.TextSize = 20
                btn.Parent = controlsGui
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 40)  -- Round buttons
                btnCorner.Parent = btn
                
                btn.MouseButton1Down:Connect(function()
                    moveDirections[name] = true
                end)
                btn.MouseButton1Up:Connect(function()
                    moveDirections[name] = nil
                end)
                btn.TouchLongPress:Connect(function()  -- For better mobile hold
                    moveDirections[name] = true
                end)
                btn.MouseLeave:Connect(function()
                    moveDirections[name] = nil
                end)
            end
            
            -- Positions: Left bottom for movement cross, right for up/down
            createControlButton("Forward", UDim2.new(0.1, 0, 0.8, 0))
            createControlButton("Backward", UDim2.new(0.1, 0, 0.95, 0))
            createControlButton("Left", UDim2.new(0.05, 0, 0.875, 0))
            createControlButton("Right", UDim2.new(0.15, 0, 0.875, 0))
            createControlButton("Up", UDim2.new(0.85, 0, 0.8, 0))
            createControlButton("Down", UDim2.new(0.85, 0, 0.9, 0))
        end
        
        spawn(function()
            while flying do
                local move = Vector3.new(0, 0, 0)
                
                -- Keyboard inputs
                if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -speed) end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, speed) end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-speed, 0, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(speed, 0, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, speed, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0, -speed, 0) end
                
                -- Mobile button inputs
                for dir, active in pairs(moveDirections) do
                    if active then
                        if dir == "Forward" then move = move + Vector3.new(0, 0, -speed) end
                        if dir == "Backward" then move = move + Vector3.new(0, 0, speed) end
                        if dir == "Left" then move = move + Vector3.new(-speed, 0, 0) end
                        if dir == "Right" then move = move + Vector3.new(speed, 0, 0) end
                        if dir == "Up" then move = move + Vector3.new(0, speed, 0) end
                        if dir == "Down" then move = move + Vector3.new(0, -speed, 0) end
                    end
                end
                
                local hrp = player.Character.HumanoidRootPart
                bodyVelocity.Velocity = (hrp.CFrame.LookVector * move.Z + hrp.CFrame.RightVector * move.X + hrp.CFrame.UpVector * move.Y)
                bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                wait()
            end
            if controlsGui then controlsGui:Destroy() end
        end)
    end
end)

-- Fast Speed Button
createButton("Fast Speed", function()
    -- Toggle super speed
    local speedEnabled = false
    if speedEnabled then
        speedEnabled = false
        player.Character.Humanoid.WalkSpeed = 16  -- Default
    else
        speedEnabled = true
        player.Character.Humanoid.WalkSpeed = 100  -- Fast speed
    end
end)

-- More buttons for "and more" - making it long
createButton("Infinite Jump", function()
    -- Infinite jump toggle
    local infJump = false
    if infJump then
        infJump = false
    else
        infJump = true
        UIS.JumpRequest:Connect(function()
            if infJump then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

createButton("Noclip", function()
    -- Noclip toggle
    local noclip = false
    if noclip then
        noclip = false
    else
        noclip = true
        spawn(function()
            while noclip do
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                wait(0.1)
            end
        end)
    end
end)

createButton("Teleport to Spawn", function()
    -- Teleport to spawn location
    local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
    if spawnLocation then
        player.Character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
    end
end)

createButton("God Mode", function()
    -- Simple god mode (infinite health)
    player.Character.Humanoid.MaxHealth = math.huge
    player.Character.Humanoid.Health = math.huge
end)

createButton("Invisible", function()
    -- Make character invisible
    for _, part in pairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        end
    end
end)

createButton("Reset Character", function()
    player.Character:BreakJoints()  -- Reset
end)

createButton("High Jump", function()
    player.Character.Humanoid.JumpPower = 100
end)

createButton("Low Gravity", function()
    workspace.Gravity = 50  -- Lower gravity
end)

createButton("Reset Gravity", function()
    workspace.Gravity = 196.2  -- Default
end)

createButton("ESP (Highlight Players)", function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local highlight = Instance.new("Highlight")
            highlight.Parent = p.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
        end
    end
end)

createButton("Remove ESP", function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character then
            local highlight = p.Character:FindFirstChildOfClass("Highlight")
            if highlight then highlight:Destroy() end
        end
    end
end)

-- Adjust CanvasSize based on number of buttons
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)

-- Close Button at top right
local closeButton = Instance.new("TextButton")
closeButton.Parent = mainFrame
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.BorderSizePixel = 0

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
