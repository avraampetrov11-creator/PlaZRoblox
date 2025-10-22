-- =======================
-- SETTINGS
-- =======================
local Settings = {
    -- Animation IDs
    RunAnimId = "18897115785",

    -- Movement & Camera
    RunSpeed = 38,
    DefaultWalkSpeed = 25,
    FOV_Run = 115,
    FOV_Default = 80,
    FOV_TransitionTime = 0.5,

    -- Run animation speeds
    DefaultRunAnimSpeed = 0.6,
    CurrentRunAnimSpeed = 0.6,

    -- Shuck-specific
    ShuckSpeed = 65,
    ShuckRunAnimSpeed = 0.8,
    ShuckMaxDuration = 25,

    -- Visual / Impact settings
    ImpactPartsCount = 55,
    WorkspaceEnvName = "Thrown_WORKSPACE_ENV",
}
-- =======================
-- SERVICES
-- =======================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local lp = Players.LocalPlayer

-- =======================
-- UTILITY FUNCTIONS
-- =======================
local function getChar()
    return lp and (lp.Character or lp.CharacterAdded:Wait())
end

local function ensureWorkspaceEnv()
    if getgenv().WorkspaceEnv and getgenv().WorkspaceEnv.Parent == workspace then
        return getgenv().WorkspaceEnv
    end
    local env = Instance.new("Folder")
    env.Name = Settings.WorkspaceEnvName
    env.Parent = workspace
    getgenv().WorkspaceEnv = env
    return env
end
local WorkspaceEnv = ensureWorkspaceEnv()

-- =======================
-- ANIMATION FUNCTIONS
-- =======================
function playAnimation(animId, speed, duration)
    local char = getChar()
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    pcall(function()
        local Anim = Instance.new("Animation")
        Anim.AnimationId = "rbxassetid://" .. animId
        local track = humanoid:LoadAnimation(Anim)
        track.Priority = Enum.AnimationPriority.Action4
        track:AdjustSpeed(speed or 1)
        track:Play()

        if duration then
            task.spawn(function()
                task.wait(duration)
                track:Stop(0.4)
            end)
        end
    end)
end

-- =======================
-- SOUND FUNCTIONS
-- =======================
function playSound(soundId, volume, fadeDuration)
    pcall(function()
        local s = Instance.new("Sound", game.CoreGui)
        s.SoundId = "rbxassetid://" .. soundId
        s.TimePosition = 0
        s.PlaybackSpeed = 1
        s.Volume = volume or 1
        s:Play()
        if fadeDuration then
            task.spawn(function()
                task.wait(fadeDuration)
                s.Volume = 0.5
                task.wait(fadeDuration)
                s.Volume = 0.2
                s:Destroy()
            end)
        end
    end)
end

function playMusic(soundId, volume)
    local sound = Instance.new("Sound")
    sound.Name = "ShuckMusic"
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 3
    sound.PlaybackSpeed = 1
    sound.Looped = false
    sound.Parent = SoundService
    sound:Play()

    task.delay(Settings.ShuckMaxDuration + 1, function()
        pcall(function()
            if sound and sound.IsPlaying then sound:Stop() end
            if sound and sound.Parent then sound:Destroy() end
        end)
    end)

    return sound
end

-- =======================
-- IMPACT FUNCTION
-- =======================
local function impct(amount, flashRepeats, fadeRepeats, pulseRepeats)
    spawn(function()
        spawn(function()
            for i = 1, flashRepeats do
                if workspace._Map and workspace._Map:FindFirstChild("Highlight") then
                    workspace._Map.Highlight.FillTransparency = 1 - i/155
                    workspace._Map.Highlight.OutlineTransparency = 1 - i/155
                    task.wait(0.01)
                    workspace._Map.Highlight.FillTransparency = 0
                    workspace._Map.Highlight.OutlineTransparency = 0
                    task.wait(0.01)
                end
            end
        end)

        spawn(function()
            for i = 1, amount do
                task.spawn(function()
                    local char = getChar()
                    if not char then return end
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    local p = Instance.new("Part")
                    p.Shape = Enum.PartType.Cylinder
                    p.Size = Vector3.new(math.random(1,77), math.random(55,99)/255, math.random(55,99)/255)
                    p.Name = "IMPACT"
                    p.Material = Enum.Material.Neon
                    p.Anchored = true
                    p.CanCollide = false
                    p.CFrame = root.CFrame * CFrame.new(math.random(-15,15), -15, math.random(-35,35)) * CFrame.Angles(0,0,math.rad(90))
                    local mesh = Instance.new("SpecialMesh", p)
                    mesh.MeshType = Enum.MeshType.Sphere
                    p.Parent = WorkspaceEnv

                    local tw = TweenService:Create(p, TweenInfo.new(0.05), { CFrame = p.CFrame * CFrame.new(math.random(5,35), 0, 0) })
                    tw:Play()
                    tw.Completed:Wait()
                    p:Destroy()
                end)
                task.wait(0.01)
            end
        end)

        task.wait(0.4)

        for i = 1, pulseRepeats do
            if workspace._Map and workspace._Map:FindFirstChild("Highlight") then
                workspace._Map.Highlight.FillColor = Color3.new(1,1,1)
                workspace._Map.Highlight.OutlineColor = Color3.new(0,0,0)
                task.wait(0.01)
                workspace._Map.Highlight.FillColor = Color3.new(0,0,0)
                workspace._Map.Highlight.OutlineColor = Color3.new(1,1,1)
                task.wait(0.01)
            end
        end

        for i = 1, fadeRepeats do
            if workspace._Map and workspace._Map:FindFirstChild("Highlight") then
                workspace._Map.Highlight.FillTransparency = 0 + i/35
                workspace._Map.Highlight.OutlineTransparency = 0 + i/35
                task.wait(0.01)
                workspace._Map.Highlight.FillTransparency = 1
                workspace._Map.Highlight.OutlineTransparency = 1
                task.wait(0.01)
            end
        end
    end)
end

-- =======================
-- MOVES LIST
-- =======================
local Moves = {
    {
        Name = "Bleed",
        Slot = "1",
        Cooldown = 7,
        Func = function() end
    },
    {
        Name = "Warned",
        Slot = "2",
        Cooldown = 8,
        Func = function() end
    },
    {
        Name = "Heed",
        Slot = "3",
        Cooldown = 60,
        Func = function()
  
            end
        },
    {
        Name = "Fault",
        Slot = "4",
        Cooldown = 3,
        Func = function() end
    },
 
    {
        Name = "Dodge",
        Slot = "5",
        Cooldown = 8,
        Func = function()
            playAnimation("18435535291", 1, 0.3)
            playSound("7094593247", 1.5, 0.4)

            task.spawn(function()
                local Player = lp
                local BodyParts = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }

                local function AfterImage(color3, material, duration, trans)
                    for _, v in pairs(Player.Character:GetChildren()) do
                        if table.find(BodyParts, v.Name) then
                            local part = Instance.new("Part")
                            part.Anchored = true
                            part.CanCollide = false
                            part.Massless = true
                            part.CFrame = v.CFrame
                            part.Size = v.Size
                            part.Transparency = trans
                            part.Color = color3
                            part.Material = Enum.Material[material]

                            if v.Name == "Head" then
                                local mesh = Instance.new("SpecialMesh", part)
                                mesh.MeshType = Enum.MeshType.Head
                                mesh.Scale = Vector3.new(1.25,1.25,1.25)
                            end
                            part.Parent = WorkspaceEnv
                            Debris:AddItem(part, duration)
                        end
                    end
                end

                local function createTrail(duration)
                    local part = Instance.new("Part")
                    part.Anchored = true
                    part.CanCollide = false
                    part.CanTouch = false
                    part.CanQuery = false
                    part.Massless = true
                    if Player.Character and Player.Character:FindFirstChild("Torso") then
                        part.Position = Player.Character.Torso.Position + Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
                        part.CFrame = CFrame.lookAt(part.Position, part.Position + Player.Character.Torso.Velocity) * CFrame.new(0,0,math.random(-3,0)) * CFrame.Angles(math.rad(90), math.rad(90), 0)
                    end
                    part.Size = Vector3.new(0.25, 0.25, 5)
                    part.Material = Enum.Material.Neon
                    part.Parent = WorkspaceEnv
                    TweenService:Create(part, TweenInfo.new(duration), { Size = Vector3.new(0.1,0.1, part.Size.Z + 1), Transparency = 1, Position = part.Position + Vector3.new(math.random(-15,15),0,0) }):Play()
                    Debris:AddItem(part, duration)
                    local mesh = Instance.new("SpecialMesh", part)
                    mesh.MeshType = Enum.MeshType.Sphere
                end

                for i = 1, 20 do
                    createTrail(1)
                    AfterImage(Color3.fromRGB(255,255,255), "Neon", 0.6, 0.2)
                    task.wait(0.02)
                end
            end)

            local char2 = getChar()
            if not char2 then return end
            local hrp = char2:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local rnd = math.random(1,3)
            if rnd == 1 then
                for i = 1, 35 do
                    if char2:FindFirstChild("Torso") then
                        char2.Torso.DashSpin:Emit(1)
                        char2.Torso.DashSpin1:Emit(1)
                    end
                    hrp.CFrame = hrp.CFrame * CFrame.new(0.8,0,0.8)
                    task.wait(0.01)
                end
            elseif rnd == 2 then
                for i = 1, 35 do
                    if char2:FindFirstChild("Torso") then
                        char2.Torso.DashSpin:Emit(1)
                        char2.Torso.DashSpin1:Emit(1)
                    end
                    hrp.CFrame = hrp.CFrame * CFrame.new(-0.8,0,0.8)
                    task.wait(0.01)
                end
            else
                for i = 1, 35 do
                    if char2:FindFirstChild("Torso") then
                        char2.Torso.DashSpin:Emit(1)
                        char2.Torso.DashSpin1:Emit(1)
                    end
                    hrp.CFrame = hrp.CFrame * CFrame.new(0,0,0.8)
                    task.wait(0.01)
                end
            end
        end
    },
    {
        Name = "Aw Shuck",
        Slot = "6",
        Cooldown = 26, 
        Func = function()
            if getgenv().ShuckLock then return end
            getgenv().ShuckLock = true

            local char = getChar()
            if not char then getgenv().ShuckLock = false; return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            pcall(function()
                if workspace.CurrentCamera and hrp then
                    local origCFrame = workspace.CurrentCamera.CFrame
                    workspace.CurrentCamera.CameraType = "Scriptable"
                    workspace.CurrentCamera.CFrame = hrp.CFrame * CFrame.new(0,5,-10) * CFrame.Angles(math.rad(-10),0,0)
                    task.wait(0.25)
                    workspace.CurrentCamera.CFrame = origCFrame
                    workspace.CurrentCamera.CameraType = "Custom"
                end
            end)

            playAnimation("13499771836", 1, 5)
            impct(80, 10, 25, 10)

            spawn(function()
                if not hrp then return end
                for i = 1, 24 do
                    local p = Instance.new("Part")
                    p.Size = Vector3.new(1.5,1.5,1.5)
                    p.Shape = Enum.PartType.Ball
                    p.Material = Enum.Material.Neon
                    p.Transparency = 0.1
                    p.Anchored = true
                    p.CanCollide = false
                    local angle = (i/24) * math.pi * 2
                    p.CFrame = hrp.CFrame * CFrame.new(math.cos(angle)*6, math.random(-1,3), math.sin(angle)*6)
                    p.Parent = WorkspaceEnv
                    local v = TweenService:Create(p, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = p.Position + Vector3.new(math.cos(angle)*12, 6, math.sin(angle)*12), Transparency = 1, Size = Vector3.new(0.1,0.1,0.1) })
                    v:Play()
                    Debris:AddItem(p, 1)
                    task.wait(0.02)
                end
            end)

            local sound = playMusic("89192934241765", 3)

            local prevRunSpeed = Settings.RunSpeed
            local prevAnimSpeed = Settings.CurrentRunAnimSpeed or Settings.DefaultRunAnimSpeed
            if getgenv().RunAnimator and getgenv().RunAnimator.animTrack then
                pcall(function()
                    prevAnimSpeed = getgenv().RunAnimator.animTrack and (getgenv().RunAnimator.animTrack.Speed or prevAnimSpeed) or prevAnimSpeed
                end)
            end

            Settings.RunSpeed = Settings.ShuckSpeed
            getgenv().ConstantSpeed = true
            Settings.ConstantSpeed = true
            Settings.CurrentRunAnimSpeed = Settings.ShuckRunAnimSpeed
            if getgenv().RunAnimator and getgenv().RunAnimator.animTrack then
                pcall(function() getgenv().RunAnimator.animTrack:AdjustSpeed(Settings.CurrentRunAnimSpeed) end)
            end

            pcall(function()
                if humanoid then humanoid.WalkSpeed = Settings.ShuckSpeed end
            end)

            local function restoreShuck()
                Settings.RunSpeed = prevRunSpeed or 45
                Settings.CurrentRunAnimSpeed = prevAnimSpeed or Settings.DefaultRunAnimSpeed
                if getgenv().RunAnimator and prevAnimSpeed and getgenv().RunAnimator.animTrack then
                    pcall(function() getgenv().RunAnimator.animTrack:AdjustSpeed(Settings.CurrentRunAnimSpeed) end)
                end
                Settings.ConstantSpeed = getgenv().ConstantSpeed
                getgenv().ShuckLock = false
            end

            if sound then
                local conn
                conn = sound.Ended:Connect(function()
                    pcall(function()
                        if sound and sound.IsPlaying then sound:Stop() end
                        if sound and sound.Parent then sound:Destroy() end
                    end)
                    pcall(function() if conn then conn:Disconnect() end end)
                    restoreShuck()
                end)

                task.delay(Settings.ShuckMaxDuration, function()
                    if sound and sound.IsPlaying then
                        pcall(function() sound:Stop() end)
                    end
                    restoreShuck()
                end)
            else
                task.delay(Settings.ShuckMaxDuration, restoreShuck)
            end
        end
    }, 
{
    Name = "Gotta Cut",
    Slot = "7", -- choose your hotkey slot
    Cooldown = 5, -- cooldown in seconds
    Func = function()
        local char = getChar()
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        -- Stop all animations
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop(0.2)
        end

        -- Play the new animation
        playAnimation("136363608783208", 0.9, 6) -- adjust speed/duration if needed
    end
}


}
-- =======================
-- COOLDOWN MANAGEMENT
-- =======================
local Cooldowns = {}

local function startCooldown(slot, duration)
    Cooldowns[slot] = true
    task.delay(duration, function()
        Cooldowns[slot] = nil
    end)
end

-- =======================
-- MOVE BINDINGS
-- =======================
local function bindMoves()
    for _, move in ipairs(Moves) do
        local slot = move.Slot
        pcall(function()
            local hotbarSlot = lp.PlayerGui:FindFirstChild("Hotbar") 
                and lp.PlayerGui.Hotbar:FindFirstChild("Backpack") 
                and lp.PlayerGui.Hotbar.Backpack:FindFirstChild("Hotbar") 
                and lp.PlayerGui.Hotbar.Backpack.Hotbar[slot]

            local cdTemplate = lp.PlayerGui:FindFirstChild("Hotbar") 
                and lp.PlayerGui.Hotbar:FindFirstChild("Backpack") 
                and lp.PlayerGui.Hotbar.Backpack:FindFirstChild("LocalScript") 
                and lp.PlayerGui.Hotbar.Backpack.LocalScript:FindFirstChild("Cooldown")

            if hotbarSlot and hotbarSlot:FindFirstChild("Base") and cdTemplate then
                hotbarSlot.Visible = true
                if hotbarSlot.Base:FindFirstChild("Reuse") then
                    hotbarSlot.Base.Reuse.Visible = false
                end
                hotbarSlot.Base.ToolName.Text = move.Name

                local function triggerMove()
                    if Cooldowns[slot] then return end
                    spawn(move.Func)
                    startCooldown(slot, move.Cooldown)

                    local deez = cdTemplate:Clone()
                    deez.Parent = hotbarSlot.Base
                    TweenService:Create(deez, TweenInfo.new(move.Cooldown, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(1,0,0,0) }):Play()
                    task.spawn(function()
                        task.wait(move.Cooldown)
                        pcall(function() deez:Destroy() end)
                    end)
                end

                hotbarSlot.Base.MouseButton1Click:Connect(triggerMove)
            end
        end)
    end

    -- Keyboard bindings
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local keyToSlot = {
            [Enum.KeyCode.One] = "1",
            [Enum.KeyCode.Two] = "2", 
            [Enum.KeyCode.Three] = "3",
            [Enum.KeyCode.Four] = "4",
            [Enum.KeyCode.Five] = "5",
            [Enum.KeyCode.Six] = "6",
            [Enum.KeyCode.Seven] = "7"
        }
        local slot = keyToSlot[input.KeyCode]
        if slot and not Cooldowns[slot] then
            for _, move in ipairs(Moves) do
                if move.Slot == slot then
                    spawn(move.Func)
                    startCooldown(slot, move.Cooldown)
                    break
                end
            end
        end
    end)
end

-- =======================
-- HOTBAR SETUP
-- =======================
local function setHotbarNames()
    for _, move in ipairs(Moves) do
        pcall(function()
            local gui = lp.PlayerGui:FindFirstChild("Hotbar") 
                and lp.PlayerGui.Hotbar:FindFirstChild("Backpack") 
                and lp.PlayerGui.Hotbar.Backpack:FindFirstChild("Hotbar") 
                and lp.PlayerGui.Hotbar.Backpack.Hotbar[move.Slot]

            if gui and gui:FindFirstChild("Base") then
                gui.Base.ToolName.Text = move.Name
            end
        end)
    end
end

-- =======================
-- RUN ANIMATION SYSTEM
-- =======================
getgenv().RunAnimator = getgenv().RunAnimator or { animTrack = nil, humanoid = nil, connected = nil }

local function setupRunAnimationForCharacter(char)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if getgenv().RunAnimator.connected then
        pcall(function() getgenv().RunAnimator.connected:Disconnect() end)
        getgenv().RunAnimator.connected = nil
    end
    if getgenv().RunAnimator.animTrack and getgenv().RunAnimator.animTrack.IsPlaying then
        pcall(function() getgenv().RunAnimator.animTrack:Stop() end)
    end

    getgenv().RunAnimator.humanoid = humanoid

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(Settings.RunAnimId)
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action3
    getgenv().RunAnimator.animTrack = track
    pcall(function() track:AdjustSpeed(Settings.CurrentRunAnimSpeed) end)

    getgenv().RunAnimator.connected = RunService.RenderStepped:Connect(function()
        local character = getChar()
        if not character or not character:FindFirstChildOfClass("Humanoid") then return end
        local humanoidLocal = character:FindFirstChildOfClass("Humanoid")
        local moveDir = humanoidLocal.MoveDirection
        local isMoving = (moveDir.Magnitude > 0.01)

        if getgenv().RunAnimator.animTrack then
            pcall(function()
                getgenv().RunAnimator.animTrack:AdjustSpeed(Settings.CurrentRunAnimSpeed)
            end)
        end

        if Settings.ConstantSpeed then
            pcall(function() humanoidLocal.WalkSpeed = Settings.RunSpeed end)
        else
            pcall(function() humanoidLocal.WalkSpeed = Settings.DefaultWalkSpeed end)
        end

        if isMoving then
            if not getgenv().RunAnimator.animTrack.IsPlaying then
                pcall(function() getgenv().RunAnimator.animTrack:Play() end)
            end
            pcall(function()
                TweenService:Create(workspace.CurrentCamera, TweenInfo.new(Settings.FOV_TransitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = Settings.FOV_Run }):Play()
            end)
        else
            if getgenv().RunAnimator.animTrack.IsPlaying then
                pcall(function() getgenv().RunAnimator.animTrack:Stop(0.2) end)
            end
            pcall(function()
                TweenService:Create(workspace.CurrentCamera, TweenInfo.new(Settings.FOV_TransitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = Settings.FOV_Default }):Play()
            end)
        end
    end)
end

local function bindCharacter(char)
    pcall(function()
        setupRunAnimationForCharacter(char)
        pcall(function() char:SetAttribute("UltimateName", "AW SHUCKS") end)
    end)
end

-- =======================
-- INITIALIZATION
-- =======================
if getgenv().ConstantSpeed == nil then
    getgenv().ConstantSpeed = true
end
Settings.ConstantSpeed = getgenv().ConstantSpeed

local currentChar = getChar()
if currentChar then bindCharacter(currentChar) end
lp.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    bindCharacter(character)
end)

pcall(setHotbarNames)
bindMoves()

-- =======================
-- MAP LOAD
-- =======================
pcall(function()
    if getgenv().MapLoad ~= true then
        getgenv().MapLoad = true
        local v = Instance.new('Model', workspace)
        v.Name = '_Map'
        task.wait(2)
        local parts = workspace:FindFirstChild("Map") and workspace.Map:GetDescendants() or {}
        for _, part in ipairs(parts) do
            if part.Parent and part.Parent:IsA('Folder') then
                part.Parent = v
            end
        end
        local h = Instance.new('Highlight')
        h.DepthMode = Enum.HighlightDepthMode.Occluded
        h.FillTransparency = 1
        h.FillColor = Color3.fromRGB(0,0,0)
        h.OutlineTransparency = 1
        h.Parent = v
    end
end)

pcall(function()
    local char = getChar()
    if char then char:SetAttribute("UltimateName", "AW SHUCKS") end
end)


