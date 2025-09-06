```lua
-- LocalScript for Roblox UI Panel
-- Place this in StarterPlayerScripts or similar

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "PlaZPanel"
gui.ResetOnSpawn = false  -- Prevent reset on respawn

-- Main Frame (Panel) with rounded corners - Made smaller
local mainFrame = Instance.new("Frame")
mainFrame.Parent = gui
mainFrame.Size = UDim2.new(0.3, 0, 0.5, 0)  -- Smaller: 30% width, 50% height
mainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)  -- Centered
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)  -- Darker professional background
mainFrame.BorderSizePixel = 0

-- Rounded corners for smooth design
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)  -- Slightly smaller radius for professionalism
uiCorner.Parent = mainFrame

-- Add UIGradient for professional look
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
uiGradient.Parent = mainFrame

-- Title Label "PlaZ" at the top - More professional font and styling
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)  -- 10% height of frame
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PlaZ"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)  -- Softer white
titleLabel.TextSize = 32  -- Slightly smaller for smaller panel
titleLabel.Font = Enum.Font.GothamSemibold  -- More professional variant
titleLabel.TextStrokeTransparency = 0.9  -- Subtler stroke

-- ScrollingFrame for buttons to make it "long" with many features
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainFrame
scrollingFrame.Size = UDim2.new(1, 0, 0.9, 0)
scrollingFrame.Position = UDim2.new(0, 0, 0.1, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 6  -- Thinner scrollbar for pro look
scrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)  -- Make it long vertically

-- UIListLayout for organizing buttons vertically
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.Padding = UDim.new(0, 8)  -- Tighter padding
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Function to create a button - More professional styling
local function createButton(name, callback)
    local button = Instance.new("TextButton")
    button.Parent = scrollingFrame
    button.Size = UDim2.new(0.9, 0, 0, 40)  -- Slightly smaller buttons
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)  -- Professional gray
    button.Text = name
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 20
    button.Font = Enum.Font.GothamMedium
    button.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Add hover effect for professionalism
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    
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

-- Fly Button - Updated with joystick for mobile
createButton("Fly", function()
    -- Simple fly script with mobile joystick support
    local flying = false
    local speed = 50
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")
    local controlsGui
    local moveVector = Vector3.new(0, 0, 0)
    local verticalMove = 0  -- For up/down separately
    
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
        
        -- Mobile joystick if touch enabled
        if UIS.TouchEnabled then
            controlsGui = Instance.new("ScreenGui")
            controlsGui.Parent = player.PlayerGui
            controlsGui.Name = "FlyControls"
            
            -- Joystick for horizontal movement (left/right/forward/back)
            local joystickFrame = Instance.new("Frame")
            joystickFrame.Size = UDim2.new(0.2, 0, 0.3, 0)
            joystickFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
            joystickFrame.BackgroundTransparency = 0.5
            joystickFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            joystickFrame.Parent = controlsGui
            
            local joystickCorner = Instance.new("UICorner")
            joystickCorner.CornerRadius = UDim.new(0.5, 0)  -- Circular
            joystickCorner.Parent = joystickFrame
            
            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0.4, 0, 0.4, 0)  -- Smaller thumb
            thumb.Position = UDim2.new(0.3, 0, 0.3, 0)
            thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            thumb.Parent = joystickFrame
            
            local thumbCorner = Instance.new("UICorner")
            thumbCorner.CornerRadius = UDim.new(0.5, 0)
            thumbCorner.Parent = thumb
            
            -- Joystick logic
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
                    moveVector = Vector3.new(0, 0, 0)
                end
            end)
            
            UIS.InputChanged:Connect(function(input)
                if input == touchObject then
                    local absPos = joystickFrame.AbsolutePosition
                    local absSize = joystickFrame.AbsoluteSize
                    local delta = (input.Position - Vector3.new(absPos.X + absSize.X / 2, absPos.Y + absSize.Y / 2, 0)) / (absSize.X / 2)
                    local magnitude = delta.Magnitude
                    if magnitude > 1 then
                        delta = delta.Unit
                    end
                    thumb.Position = center + UDim2.new(0.3 * delta.X, 0, 0.3 * delta.Y)
                    moveVector = Vector3.new(delta.X, 0, -delta.Y)  -- X for left/right, Z for forward/back
                end
            end)
            
            -- Vertical buttons for up/down (simpler, as joystick is for horizontal)
            local function createVerticalButton(name, pos, direction)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.1, 0, 0.1, 0)
                btn.Position = pos
                btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                btn.Text = name
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.TextSize = 20
                btn.Parent = controlsGui
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0.5, 0)
                btnCorner.Parent = btn
                
                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        verticalMove = direction
                    end
                end)
                
                btn.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        verticalMove = 0
                    end
                end)
            end
            
            createVerticalButton("Up", UDim2.new(0.85, 0, 0.7, 0), 1)
            createVerticalButton("Down", UDim2.new(0.85, 0, 0.85, 0), -1)
        end
        
        spawn(function()
            while flying do
                local move = Vector3.new(0, 0, 0)
                
                -- Keyboard inputs
                if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -1) end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, 1) end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1, 0, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1, 0, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0, -1, 0) end
                
                -- Normalize and scale keyboard move
                if move.Magnitude > 0 then
                    move = move.Unit
                end
                move = move * speed
                
                -- Mobile joystick and vertical
                move = move + moveVector * speed + Vector3.new(0, verticalMove * speed, 0)
                
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

-- Close Button at top right - More professional
local closeButton = Instance.new("TextButton")
closeButton.Parent = mainFrame
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -35, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)  -- Softer red
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.BorderSizePixel = 0

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.5, 0)  -- Rounder
closeCorner.Parent = closeButton

-- Hover effect for close button
closeButton.MouseEnter:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
end)
closeButton.MouseLeave:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
