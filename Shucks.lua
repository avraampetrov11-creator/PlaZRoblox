

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
    DefaultRunAnimSpeed = 0.6,        -- baseline run anim speed
    CurrentRunAnimSpeed = 0.6,        -- value actively used by the RunAnimator (can be changed by Shuck)

    -- Shuck-specific
    ShuckSpeed = 65,            -- walk speed while Shuck music plays
    ShuckRunAnimSpeed = 0.8,    -- run animation speed while Shuck music plays
    ShuckMaxDuration = 25,      -- safety fallback (seconds)

    -- Cooldowns (seconds)
    Cooldowns = {
        Bleed = 7,
        Warned = 8,
        Heed = 60,
        Fault = 3,
        Modulation = 7,
        Evade = 8,
        Shuck = 26
    },

    -- Visual / Impact settings
    ImpactPartsCount = 55,
    WorkspaceEnvName = "Thrown_WORKSPACE_ENV",
}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local lp = Players.LocalPlayer

-- Utility to get the current character safely
local function getChar()
    return lp and (lp.Character or lp.CharacterAdded:Wait())
end

-- Create or get a workspace environment folder used for temporary parts
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

-- Small helper for system chat messages
local function sendSystemMessage(text, color)
    local msg = {
        Color = color or Color3.fromRGB(255,255,255),
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
        Text = text
    }
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", msg)
    end)
end

-- Typewriter-style UI info (kept from original)
local function info(text)
    spawn(function()
        pcall(function() game.CoreGui.Revit:Destroy() end)
        task.wait(0.1)
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "Revit"
        screenGui.Parent = game.CoreGui
        screenGui.IgnoreGuiInset = true
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.ResetOnSpawn = false

        local label = Instance.new("TextLabel", screenGui)
        label.Font = Enum.Font.Arcade
        label.TextColor3 = Color3.new(1,1,1)
        label.Size = UDim2.new(1, 0, 0.1, 0)
        label.Position = UDim2.new(0,0,0,0)
        label.BackgroundTransparency = 1
        label.TextSize = 35
        label.Text = ""

        local function typewriter(lbl, str)
            local out = ""
            for i = 1, #str do
                out = out .. str:sub(i,i)
                lbl.Text = out
                task.wait(.03)
            end
        end

        typewriter(label, text)
        task.wait(2)
        screenGui:Destroy()
    end)
end

-- Impact visual function
local function impct(amount, flashRepeats, fadeRepeats, pulseRepeats)
    spawn(function()
        -- brief highlight flashes
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

        -- spawn cylinder parts around player
        spawn(function()
            for i = 1, amount do
                task.spawn(function()
                    local char = getChar()
                    if not char then return end
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    local p = Instance.new("Part")
                    p.Shape = Enum.PartType.Cylinder
                    p.Size = Vector3.new(math.random(1,77),
                        math.random(55,99)/255,
                        math.random(55,99)/255)
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

        -- flicker highlight
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

        -- fade out
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

-- Helper: safely disconnect stored global connections by name
local function safeDisconnectGlobal(name)
    pcall(function()
        if getgenv()[name] and typeof(getgenv()[name].Disconnect) == "function" then
            getgenv()[name]:Disconnect()
        end
        getgenv()[name] = nil
    end)
end

-- Menarehot / DEATHBLOW animation handler
local function connectDeathblowHandler()
    safeDisconnectGlobal("menarehotDEATHBLOW")
    local char = getChar()
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    getgenv().menarehotDEATHBLOW = humanoid.AnimationPlayed:Connect(function(track)
        if track.Animation and track.Animation.AnimationId == "rbxassetid://15123665491" then
            -- cinematic sequence (condensed)
            pcall(function()
                if game.CoreGui:FindFirstChild("HeadsetDisconnectedDialog") then
                    local root = game.CoreGui.HeadsetDisconnectedDialog
                    pcall(function() TweenService:Create(root['2'], TweenInfo.new(.5), { Volume = 0 }):Play() end)
                    pcall(function() TweenService:Create(root['1'], TweenInfo.new(.5), { Volume = 0 }):Play() end)
                end
            end)

            workspace.CurrentCamera.CameraType = 'Scriptable'
            task.wait(0.04)
            pcall(function() workspace.CurrentCamera:remove() end)
            task.wait(0.1)
            repeat task.wait() until Players.LocalPlayer.Character ~= nil
            workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid')
            workspace.CurrentCamera.CameraType = "Scriptable"
            Players.LocalPlayer.CameraMinZoomDistance = 0.5
            Players.LocalPlayer.CameraMaxZoomDistance = 400
            Players.LocalPlayer.CameraMode = "Classic"
            if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head") then
                Players.LocalPlayer.Character.Head.Anchored = false
            end

            impct(55, 15, 5, 5)

            local Anim = Instance.new("Animation")
            Anim.AnimationId = "rbxassetid://15123665491"
            local dbAnim = humanoid:LoadAnimation(Anim)
            dbAnim:Play()
            dbAnim:AdjustSpeed(1)
            dbAnim.Priority = Enum.AnimationPriority.Action

            spawn(function()
                local ok, v = pcall(function()
                    return ReplicatedStorage.Resources and ReplicatedStorage.Resources:FindFirstChild("FuneralEffect") and ReplicatedStorage.Resources.FuneralEffect:Clone()
                end)
                if ok and v then
                    v.Parent = WorkspaceEnv
                    v.Anchored = true
                    if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Right Arm") then
                        v.CFrame = Players.LocalPlayer.Character['Right Arm'].CFrame * CFrame.new(0,-1,0)
                    end
                    task.wait(7)
                    v:Destroy()
                end
            end)

            spawn(function()
                if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    workspace.CurrentCamera.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(-5,0,-5) * CFrame.Angles(0, math.rad(240), 0)
                    task.wait(1)
                    workspace.CurrentCamera.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(10,10,5) * CFrame.Angles(math.rad(-60), math.rad(5), 0)
                end

                impct(450, 1, 100, 1)
                task.wait(.3)
            end)

            task.wait(3)
            workspace.CurrentCamera.CameraType = "Custom"
            pcall(function()
                if game.CoreGui:FindFirstChild("HeadsetDisconnectedDialog") then
                    local root = game.CoreGui.HeadsetDisconnectedDialog
                    pcall(function() TweenService:Create(root['2'], TweenInfo.new(1.5), { Volume = .5 }):Play() end)
                    pcall(function() TweenService:Create(root['1'], TweenInfo.new(.5), { Volume = 0 }):Play() end)
                end
            end)
        end
    end)
end

-- Another cinematic animation handler
local function connectCinematicHandler()
    safeDisconnectGlobal("yoinkpeni")
    local char = getChar()
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    getgenv().yoinkpeni = humanoid.AnimationPlayed:Connect(function(track)
        if track.Animation and track.Animation.AnimationId == "rbxassetid://14920779925" then
            pcall(function()
                if game.CoreGui:FindFirstChild("HeadsetDisconnectedDialog") then
                    local root = game.CoreGui.HeadsetDisconnectedDialog
                    pcall(function() TweenService:Create(root['2'], TweenInfo.new(.5), { Volume = 0 }):Play() end)
                    pcall(function() TweenService:Create(root['1'], TweenInfo.new(.5), { Volume = 0 }):Play() end)
                end
            end)
            workspace.CurrentCamera.CameraType = 'Scriptable'
            task.wait(.1)
            pcall(function() workspace.CurrentCamera:remove() end)
            task.wait(.1)
            repeat task.wait() until Players.LocalPlayer.Character ~= nil
            workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid')
            workspace.CurrentCamera.CameraType = "Scriptable"
            Players.LocalPlayer.CameraMinZoomDistance = 0.5
            Players.LocalPlayer.CameraMaxZoomDistance = 400
            Players.LocalPlayer.CameraMode = "Classic"
            if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head") then
                Players.LocalPlayer.Character.Head.Anchored = false
            end

            local Anim = Instance.new("Animation")
            Anim.AnimationId = "rbxassetid://17278415853"
            local k = humanoid:LoadAnimation(Anim)
            k:Play()
            k.TimePosition = 4.5
            k:AdjustSpeed(1)
            k.Priority = Enum.AnimationPriority.Action4

            spawn(function()
                workspace.CurrentCamera.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(-5,0,-5) * CFrame.Angles(0, math.rad(240), 0)
                task.wait(1.5)
                workspace.CurrentCamera.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(5,35,15) * CFrame.Angles(math.rad(50), 0, 0)
                task.wait(2)
                workspace.CurrentCamera.CameraType = 'Custom'
            end)

            impct(155, 15, 55, 55)
            task.wait(1)
            pcall(function()
                if game.CoreGui:FindFirstChild("HeadsetDisconnectedDialog") then
                    local root = game.CoreGui.HeadsetDisconnectedDialog
                    pcall(function() TweenService:Create(root['2'], TweenInfo.new(1.5), { Volume = .5 }):Play() end)
                    pcall(function() TweenService:Create(root['1'], TweenInfo.new(.5), { Volume = 0 }):Play() end)
                end
            end)
        end
    end)
end

-- ---------- Hotbar naming and UI setup ----------
local function setHotbarNames()
    local mapping = {
        ["1"] = "Bleed",
        ["2"] = "Warned",
        ["3"] = "Heed",
        ["4"] = "Fault",
        ["5"] = "Modulation",
        ["6"] = "Evade",
        ["7"] = "Shuck"
    }
    pcall(function()
        for slot, name in pairs(mapping) do
            local gui = lp.PlayerGui:FindFirstChild("Hotbar") and lp.PlayerGui.Hotbar:FindFirstChild("Backpack") and lp.PlayerGui.Hotbar.Backpack:FindFirstChild("Hotbar") and lp.PlayerGui.Hotbar.Backpack.Hotbar:FindFirstChild(slot)
            if gui and gui.Base then
                gui.Visible = true
                gui.Base.Reuse.Visible = false
                gui.Base.ToolName.Text = name
            end
        end
    end)
end
pcall(setHotbarNames)

-- ---------- Modulation (slot 5) ----------
local function Modulation()
    local vim = game:GetService("VirtualInputManager")
    local AlreadyHit = false

    if getgenv().MapLoad ~= true then
        getgenv().MapLoad = true
        local v = Instance.new('Model', workspace)
        v.Name = '_Map'
        task.wait(4)
        local parts = workspace:FindFirstChild("Map") and workspace.Map:GetDescendants() or {}
        for _, part in ipairs(parts) do
            if part.Parent and part.Parent:IsA("Folder") then
                part.Parent = v
            end
        end
        local h = Instance.new('Highlight', v)
        h.DepthMode = Enum.HighlightDepthMode.Occluded
        h.FillTransparency = 0
        h.FillColor = Color3.fromRGB(0,0,0)
        h.OutlineTransparency = 0
    end

    local char = getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if workspace:FindFirstChild("Live") then
        for _, target in pairs(workspace.Live:GetChildren()) do
            if target ~= char and target:FindFirstChild("Torso") and target:FindFirstChildOfClass("Humanoid") and target:FindFirstChild("HumanoidRootPart") then
                local torso = target:FindFirstChild("Torso")
                local hum = target:FindFirstChildOfClass("Humanoid")
                local otherHRP = target:FindFirstChild("HumanoidRootPart")
                if torso and hum and otherHRP and hrp then
                    if (torso.Position - hrp.Position).Magnitude <= 77 then
                        if AlreadyHit then return end
                        if target:GetAttribute('LastHit') == char.Name then
                            AlreadyHit = true
                            spawn(function()
                                for i = 1, 40 do
                                    hrp.CFrame = otherHRP.CFrame * CFrame.new(0,0,-35 + i) * CFrame.Angles(math.rad(180), 0, 0)
                                    task.wait(.02)
                                end
                                task.wait(.4)
                                for i = 1, 40 do
                                    hrp.CFrame = otherHRP.CFrame * CFrame.new(0,0,-5) * CFrame.Angles(0, math.rad(180), 0)
                                    task.wait(.02)
                                end
                            end)
                            task.wait(.01)
                            pcall(function()
                                vim:SendKeyEvent(true, Enum.KeyCode.Q, false, workspace)
                            end)
                        end
                    end
                end
            end
        end
    end
end

-- Bind Modulation to UI slot 5 and key 5
do
    pcall(function()
        local hb5 = lp.PlayerGui.Hotbar.Backpack.Hotbar["5"]
        local cdTemplate = lp.PlayerGui.Hotbar.Backpack.LocalScript:FindFirstChild("Cooldown")
        if hb5 and hb5.Base and cdTemplate then
            hb5.Visible = true
            hb5.Base.Reuse.Visible = false
            hb5.Base.ToolName.Text = "Modulation"
            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.Five and not hb5.Base:FindFirstChild("Cooldown") then
                    spawn(Modulation)
                    local deez = cdTemplate:Clone()
                    deez.Parent = hb5.Base
                    TweenService:Create(deez, TweenInfo.new(Settings.Cooldowns.Modulation, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(1,0,0,0) }):Play()
                    task.wait(Settings.Cooldowns.Modulation)
                    deez:Destroy()
                end
            end)
            hb5.Base.MouseButton1Click:Connect(function()
                if not hb5.Base:FindFirstChild("Cooldown") then
                    spawn(Modulation)
                    local deez = cdTemplate:Clone()
                    deez.Parent = hb5.Base
                    TweenService:Create(deez, TweenInfo.new(Settings.Cooldowns.Modulation, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(1,0,0,0) }):Play()
                    task.wait(Settings.Cooldowns.Modulation)
                    deez:Destroy()
                end
            end)
        end
    end)
end

-- Evade (slot 6)
local function Evade()
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
                    TweenService:Create(part, TweenInfo.new(duration), { Transparency = 1 }):Play()
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
            task.wait(.02)
        end
    end)

    local char = getChar()
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local Anim = Instance.new("Animation")
        Anim.AnimationId = "rbxassetid://18435535291"
        local k = humanoid:LoadAnimation(Anim)
        k:Play()
        k.Priority = Enum.AnimationPriority.Action4
        k:AdjustSpeed(1)
        spawn(function() task.wait(.3); k:Stop(.4) end)
    end

    pcall(function()
        local s = Instance.new('Sound', game.CoreGui)
        s.SoundId = 'rbxassetid://7094593247'
        s.TimePosition = 0
        s.PlaybackSpeed = 1
        s.Volume = 1.5
        s:Play()
        task.spawn(function()
            task.wait(.4); s.Volume = .5; task.wait(.4); s.Volume = .2; s:Destroy()
        end)
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
            hrp.CFrame = hrp.CFrame * CFrame.new(.8,0,.8)
            task.wait(.01)
        end
    elseif rnd == 2 then
        for i = 1, 35 do
            if char2:FindFirstChild("Torso") then
                char2.Torso.DashSpin:Emit(1)
                char2.Torso.DashSpin1:Emit(1)
            end
            hrp.CFrame = hrp.CFrame * CFrame.new(-.8,0,.8)
            task.wait(.01)
        end
    else
        for i = 1, 35 do
            if char2:FindFirstChild("Torso") then
                char2.Torso.DashSpin:Emit(1)
                char2.Torso.DashSpin1:Emit(1)
            end
            hrp.CFrame = hrp.CFrame * CFrame.new(0,0,.8)
            task.wait(.01)
        end
    end
end

-- Bind Evade to slot 6 and key 6
do
    pcall(function()
        local hotb6 = lp.PlayerGui.Hotbar.Backpack.Hotbar["6"]
        local cdTemplate = lp.PlayerGui.Hotbar.Backpack.LocalScript:FindFirstChild("Cooldown")
        if hotb6 and hotb6.Base and cdTemplate then
            hotb6.Visible = true
            hotb6.Base.Reuse.Visible = false
            hotb6.Base.ToolName.Text = "Evade"
            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.Six and not hotb6.Base:FindFirstChild("Cooldown") then
                    spawn(Evade)
                    local deez = cdTemplate:Clone()
                    deez.Parent = hotb6.Base
                    TweenService:Create(deez, TweenInfo.new(Settings.Cooldowns.Evade, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(1,0,0,0) }):Play()
                    task.wait(Settings.Cooldowns.Evade)
                    deez:Destroy()
                end
            end)
            hotb6.Base.MouseButton1Click:Connect(function()
                if not hotb6.Base:FindFirstChild("Cooldown") then
                    spawn(Evade)
                    local deez = cdTemplate:Clone()
                    deez.Parent = hotb6.Base
                    TweenService:Create(deez, TweenInfo.new(Settings.Cooldowns.Evade, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(1,0,0,0) }):Play()
                    task.wait(Settings.Cooldowns.Evade)
                    deez:Destroy()
                end
            end)
        end
    end)
end

-- ---------- Shuck (slot 7): full implementation ----------
-- Music function used by Shuck. Returns the Sound so we can detect Ended.
local function Music()
    local sound = Instance.new("Sound")
    sound.Name = "ShuckMusic"
    sound.SoundId = "rbxassetid://89192934241765"
    sound.Volume = 3
    sound.PlaybackSpeed = 1
    sound.Looped = false
    sound.Parent = SoundService
    sound:Play()

    -- safety cleanup
    task.delay(Settings.ShuckMaxDuration + 1, function()
        pcall(function()
            if sound and sound.IsPlaying then
                sound:Stop()
            end
            if sound and sound.Parent then
                sound:Destroy()
            end
        end)
    end)

    return sound
end

local function Shuck()
    if getgenv().ShuckLock then return end
    getgenv().ShuckLock = true

    local char = getChar()
    if not char then getgenv().ShuckLock = false; return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    -- camera pulse
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

    -- play short anim
    pcall(function()
        if humanoid then
            local Anim = Instance.new("Animation")
            Anim.AnimationId = "rbxassetid://13499771836"
            local track = humanoid:LoadAnimation(Anim)
            track.Priority = Enum.AnimationPriority.Action
            track:Play()
            task.spawn(function() task.wait(5); track:Stop() end)
        end
    end)

    -- visual flash & impact
    pcall(function() impct(80, 10, 25, 10) end)

    -- spawn radial parts and particles
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

    -- Play music and apply movement/anim changes while it plays
    local sound = nil
    pcall(function()
        sound = Music()
    end)

    -- Save previous values to restore later
    local prevRunSpeed = Settings.RunSpeed

    -- determine current anim speed
    local prevAnimSpeed = Settings.CurrentRunAnimSpeed or Settings.DefaultRunAnimSpeed
    if getgenv().RunAnimator and getgenv().RunAnimator.animTrack then
        pcall(function()
            -- capture the current speed in a safe way
            prevAnimSpeed = getgenv().RunAnimator.animTrack and (getgenv().RunAnimator.animTrack.Speed or prevAnimSpeed) or prevAnimSpeed
        end)
    end

    -- Apply Shuck overrides
    Settings.RunSpeed = Settings.ShuckSpeed
    getgenv().ConstantSpeed = true
    Settings.ConstantSpeed = true

    -- set the active requested run anim speed (the RunAnimator loop will apply it every tick)
    Settings.CurrentRunAnimSpeed = Settings.ShuckRunAnimSpeed
    if getgenv().RunAnimator and getgenv().RunAnimator.animTrack then
        pcall(function() getgenv().RunAnimator.animTrack:AdjustSpeed(Settings.CurrentRunAnimSpeed) end)
    end

    -- force humanoid walk speed immediately
    pcall(function()
        if humanoid then humanoid.WalkSpeed = Settings.ShuckSpeed end
    end)

    local function restoreShuck()
        -- restore run speed and anim speed
        Settings.RunSpeed = prevRunSpeed or 45
        Settings.CurrentRunAnimSpeed = prevAnimSpeed or Settings.DefaultRunAnimSpeed
        if getgenv().RunAnimator and prevAnimSpeed and getgenv().RunAnimator.animTrack then
            pcall(function() getgenv().RunAnimator.animTrack:AdjustSpeed(Settings.CurrentRunAnimSpeed) end)
        end
        -- restore ConstantSpeed global (leave it as it was globally)
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

-- Bind Shuck to UI slot 7 and key 7
-- Note: This block ensures hotbar binding and cooldown visuals
do
    pcall(function()
        local hot7 = lp.PlayerGui.Hotbar.Backpack.Hotbar["7"]
        local cdTemplate = lp.PlayerGui.Hotbar.Backpack.LocalScript:FindFirstChild("Cooldown")
        if hot7 and hot7.Base and cdTemplate then
            hot7.Visible = true
            hot7.Base.Reuse.Visible = false
            hot7.Base.ToolName.Text = "Shuck"

            local function triggerShuck()
                if not hot7.Base:FindFirstChild("Cooldown") then
                    spawn(Shuck)
                    local deez = cdTemplate:Clone()
                    deez.Parent = hot7.Base
                    TweenService:Create(deez, TweenInfo.new(Settings.Cooldowns.Shuck, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(1,0,0,0) }):Play()
                    task.wait(Settings.Cooldowns.Shuck)
                    deez:Destroy()
                end
            end

            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.Seven then
                    triggerShuck()
                end
            end)

            hot7.Base.MouseButton1Click:Connect(triggerShuck)
        end
    end)
end

-- ---------- Running animation and FOV management (robust) ----------
-- We'll store RunAnimator in getgenv() so other functions (Shuck) can access it easily
getgenv().RunAnimator = getgenv().RunAnimator or { animTrack = nil, humanoid = nil, connected = nil }

local function setupRunAnimationForCharacter(char)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- disconnect previous
    if getgenv().RunAnimator.connected then
        pcall(function() getgenv().RunAnimator.connected:Disconnect() end)
        getgenv().RunAnimator.connected = nil
    end
    if getgenv().RunAnimator.animTrack and getgenv().RunAnimator.animTrack.IsPlaying then
        pcall(function() getgenv().RunAnimator.animTrack:Stop() end)
    end

    getgenv().RunAnimator.humanoid = humanoid

    -- load animation
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(Settings.RunAnimId)
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action3
    getgenv().RunAnimator.animTrack = track
    -- apply the requested speed (this value can change at runtime)
    pcall(function() track:AdjustSpeed(Settings.CurrentRunAnimSpeed) end)

    getgenv().RunAnimator.connected = RunService.RenderStepped:Connect(function()
        local character = getChar()
        if not character or not character:FindFirstChildOfClass("Humanoid") then return end
        local humanoidLocal = character:FindFirstChildOfClass("Humanoid")
        local moveDir = humanoidLocal.MoveDirection
        local isMoving = (moveDir.Magnitude > 0.01)

        -- Ensure anim speed matches the requested current value every tick (solves timing/play issues)
        if getgenv().RunAnimator.animTrack then
            pcall(function()
                -- AdjustSpeed is safe to call frequently; we only call with a number
                getgenv().RunAnimator.animTrack:AdjustSpeed(Settings.CurrentRunAnimSpeed)
            end)
        end

        -- Manage walk speed
        if Settings.ConstantSpeed then
            pcall(function() humanoidLocal.WalkSpeed = Settings.RunSpeed end)
        else
            pcall(function() humanoidLocal.WalkSpeed = Settings.DefaultWalkSpeed end)
        end

        -- Play/Stop animation and change FOV smoothly
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

-- Ensure Settings.ConstantSpeed exists
if getgenv().ConstantSpeed == nil then
    getgenv().ConstantSpeed = true
end
Settings.ConstantSpeed = getgenv().ConstantSpeed

-- Bind character and respawn handlers
local function bindCharacter(char)
    pcall(function()
        setupRunAnimationForCharacter(char)
        pcall(function() char:SetAttribute("UltimateName", "AW SHUCKS") end)
        connectDeathblowHandler()
        connectCinematicHandler()
    end)
end

local currentChar = getChar()
if currentChar then bindCharacter(currentChar) end
lp.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    bindCharacter(character)
end)

-- ---------- Map load helper ----------
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

-- ---------- Safe reconnect on respawn ----------
pcall(function() if getgenv().pepe then getgenv().pepe:Disconnect() end end)
getgenv().pepe = lp.CharacterAdded:Connect(function(c)
    repeat task.wait() until c:FindFirstChild('Humanoid')
    task.spawn(function() task.wait(1); pcall(function() if MainEnv then MainEnv() end end) end)
    pcall(function() if SpawnA then SpawnA() end end)
end)

-- ---------- Main environment bootstrap ----------
function MainEnv()
    for _, name in ipairs({
        "penisthethird","gaer","gfawggawg","jum1","jum","peng","bbafaf",
        "Bash","yeah","yeahj","ultya","musicya","boingboing","terrible","yoinkpeni"
    }) do
        safeDisconnectGlobal(name)
    end
    safeDisconnectGlobal("menarehotDEATHBLOW")
    if not getgenv().WorkspaceEnv then ensureWorkspaceEnv() end
    pcall(setHotbarNames)
end
pcall(MainEnv)

-- Set ultimate attribute on startup
pcall(function()
    local char = getChar()
    if char then char:SetAttribute("UltimateName", "AW SHUCKS") end
end)


