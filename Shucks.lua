
local Settings = {
    -- Animation IDs (numbers only, as strings or numbers)
    RunAnimId = "18897115785",

    -- Movement & Camera
    RunSpeed = 45,
    DefaultWalkSpeed = 25,
    FOV_Run = 110,
    FOV_Default = 80,
    FOV_TransitionTime = 0.5,

    -- Cooldowns (seconds)
    Cooldowns = {
        Bleed = 7,    -- originally slot 1 logic (placeholder if present)
        Warned = 8,   -- slot 2
        Heed = 60,    -- slot 3
        Fault = 10,   -- slot 4
        Modulation = 7, -- slot 5 (original Modulation)
        Evade = 8,      -- slot 6 (original Evade)
        Sense = 60      -- slot 7 (original Sense)
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

-- Startup messages (kept from original)
local blank = ("\n"):rep(7)

-- Set ultimate attribute name
pcall(function()
    local char = getChar()
    if char then
        char:SetAttribute("UltimateName", "AW SHUCKS")
    end
end)

-- Typewriter-style UI info (used when downloading assets in original)
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

-- Impact visual function (kept behavior from original)
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

-- Animation handlers: these respond to specific animation IDs played on the humanoid
-- They were preserved from original, slightly condensed but functional.

-- Helper: safely disconnect stored global connections by name
local function safeDisconnectGlobal(name)
    pcall(function()
        if getgenv()[name] and typeof(getgenv()[name].Disconnect) == "function" then
            getgenv()[name]:Disconnect()
        end
        getgenv()[name] = nil
    end)
end

-- Menarehot / DEATHBLOW animation handler (kept behavior)
local function connectDeathblowHandler()
    safeDisconnectGlobal("menarehotDEATHBLOW")
    local char = getChar()
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    getgenv().menarehotDEATHBLOW = humanoid.AnimationPlayed:Connect(function(track)
        if track.Animation and track.Animation.AnimationId == "rbxassetid://15123665491" then
            -- start cinematic effect sequence
            -- reduce any background music volumes if present (pcall kept)
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

            -- visual sequence
            impct(55, 15, 5, 5)

            -- play the animation on humanoid (replay to ensure it's controlled)
            local Anim = Instance.new("Animation")
            Anim.AnimationId = "rbxassetid://15123665491"
            local dbAnim = humanoid:LoadAnimation(Anim)
            dbAnim:Play()
            dbAnim:AdjustSpeed(1)
            dbAnim.Priority = Enum.AnimationPriority.Action

            -- spawn existing effects from ReplicatedStorage (if present)
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

            -- large ring spawn effect (condensed)
            spawn(function()
                local bvf = false
                for i = 1, 255 do
                    if bvf then break end
                    spawn(function()
                        local v = Instance.new("Part")
                        v.CFrame = Players.LocalPlayer.Character['Right Arm'].CFrame * CFrame.new(0, -1.5, 0) * CFrame.Angles(i/9, i/9, 0)
                        v.Transparency = .7
                        v.Size = Vector3.new(1,1,1)
                        v.Material = Enum.Material.Neon
                        v.Color = Color3.new(1,1,1)
                        v.Anchored = true
                        v.CanCollide = false
                        v.Parent = WorkspaceEnv
                        TweenService:Create(v, TweenInfo.new(.5), { Size = Vector3.new(0,0,0) }):Play()
                        task.wait(.5)
                        v:Destroy()
                    end)
                    task.wait(.04)
                end
            end)

            -- camera choreography and extra effects (kept functional, condensed)
            spawn(function()
                if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    workspace.CurrentCamera.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(-5,0,-5) * CFrame.Angles(0, math.rad(240), 0)
                    task.wait(1)
                    workspace.CurrentCamera.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(10,10,5) * CFrame.Angles(math.rad(-60), math.rad(5), 0)
                end

                -- additional animations and impct bursts
                impct(450, 1, 100, 1)
                task.wait(.3)
            end)

            -- final cleanup & restore camera
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

-- Another cinematic animation handler (kept)
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

            -- camera choreography (condensed)
            spawn(function()
                workspace.CurrentCamera.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(-5,0,-5) * CFrame.Angles(0, math.rad(240), 0)
                task.wait(1.5)
                workspace.CurrentCamera.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(5,35,15) * CFrame.Angles(math.rad(50), 0, 0)
                task.wait(2)
                workspace.CurrentCamera.CameraType = 'Custom'
            end)

            -- a big flash sequence
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
        ["7"] = "Sense"
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

-- ---------- Bleed (slot1) / Warned (slot2) / Heed (slot3) / Fault (slot4) placeholders ----------
-- Original file had heavy logic for many moves. We preserve Modulation (slot5), Evade (6), Sense (7).
-- If original logic existed for slots 1-4 in the full file, you can paste them and we'll integrate.
-- For now, ensure hotbar names are updated (above). If you want slot1-4 full logic added to match original,
-- paste their code blocks and I will integrate them.

-- ---------- Modulation (kept, bound to slot 5) - renamed not to keep original name since user requested keep logic ---
local function Modulation()
    -- original behavior preserved. This function performs close-range teleport and emit effects.
    local vim = game:GetService("VirtualInputManager")
    local AlreadyHit = false

    -- ensure _Map model exists and highlight it
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

    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "Live" then
            -- keep original loop behavior if Live existed; else skip
        end
    end

    -- preserved movement/teleport behavior from original
    -- find nearby players from workspace.Live if present
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

-- Evade (slot 6) - preserved, with sound effects kept
local function Evade()
    -- after-image & trailing visual effect
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

    -- short evade animation & sound (sound kept)
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

-- Bind Evade to UI slot 6 and key 6
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

-- Sense (slot 7) - preserved
local function Sense()
    if workspace._Map and workspace._Map:FindFirstChild("Highlight") then
        workspace._Map.Highlight.FillTransparency = 0
        workspace._Map.Highlight.OutlineTransparency = 0
    end

    pcall(function()
        local s = Instance.new('Sound', game.CoreGui)
        s.SoundId = 'rbxassetid://4576364825'
        s.TimePosition = 0
        s.PlaybackSpeed = .8
        s.Volume = 3
        s:Play()
        task.spawn(function() task.wait(3); s:Destroy() end)
    end)

    -- reduce lighting exposure temporarily
    local prevExposure = nil
    pcall(function() prevExposure = game.Lighting.ExposureCompensation end)
    pcall(function() game.Lighting.ExposureCompensation = -5000 end)

    task.spawn(function()
        task.wait(3)
        pcall(function() game.Lighting.ExposureCompensation = prevExposure end)
    end)

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            local owner = player
            local HealthBar = Instance.new("BillboardGui", owner.Character.Head)
            HealthBar.MaxDistance = 155
            HealthBar.ExtentsOffset = Vector3.new(0,3,0)
            HealthBar.Size = UDim2.new(9,0,8,0)
            HealthBar.AlwaysOnTop = true

            local Frame = Instance.new("Frame", HealthBar)
            Frame.BackgroundTransparency = 1
            Frame.Size = UDim2.new(1,0,1,0)

            local Current_Character = Instance.new("TextLabel", Frame)
            Current_Character.BackgroundTransparency = 1
            Current_Character.Position = UDim2.new(.9, 0, 0.7, 0)
            Current_Character.Size = UDim2.new(0.45, 0, 0.25, 0)
            Current_Character.Font = Enum.Font.Arcade
            Current_Character.TextSize = 15
            Current_Character.TextColor3 = Color3.new(1,1,1)

            spawn(function()
                local items = {}
                for i = 1, 4 do
                    table.insert(items, (owner.Backpack:GetChildren()[i] and owner.Backpack:GetChildren()[i].Name) or "")
                end
                Current_Character.Text = tostring(owner:GetAttribute('Character') or "") .. '\n' .. table.concat(items, '\n')
            end)

            spawn(function()
                task.wait(23)
                HealthBar:Destroy()
            end)

            local HL = Instance.new('Highlight', owner.Character)
            HL.FillTransparency = 0
            HL.FillColor = Color3.new(0,0,0)
            spawn(function()
                task.wait(23)
                HL:Destroy()
                pcall(function() game.Lighting.ExposureCompensation = prevExposure end)
                if workspace._Map and workspace._Map:FindFirstChild("Highlight") then
                    workspace._Map.Highlight.FillTransparency = 1
                    workspace._Map.Highlight.OutlineTransparency = 1
                end
            end)
        end
    end
end

-- Bind Sense to UI slot 7 and key 7
do
    pcall(function()
        local hot7 = lp.PlayerGui.Hotbar.Backpack.Hotbar["7"]
        local cdTemplate = lp.PlayerGui.Hotbar.Backpack.LocalScript:FindFirstChild("Cooldown")
        if hot7 and hot7.Base and cdTemplate then
            hot7.Visible = true
            hot7.Base.Reuse.Visible = false
            hot7.Base.ToolName.Text = "Sense"

            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.Seven and not hot7.Base:FindFirstChild("Cooldown") then
                    spawn(Sense)
                    local deez = cdTemplate:Clone()
                    deez.Parent = hot7.Base
                    TweenService:Create(deez, TweenInfo.new(Settings.Cooldowns.Sense, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(1,0,0,0) }):Play()
                    task.wait(Settings.Cooldowns.Sense)
                    deez:Destroy()
                end
            end)

            hot7.Base.MouseButton1Click:Connect(function()
                if not hot7.Base:FindFirstChild("Cooldown") then
                    spawn(Sense)
                    local deez = cdTemplate:Clone()
                    deez.Parent = hot7.Base
                    TweenService:Create(deez, TweenInfo.new(Settings.Cooldowns.Sense, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(1,0,0,0) }):Play()
                    task.wait(Settings.Cooldowns.Sense)
                    deez:Destroy()
                end
            end)
        end
    end)
end

-- ---------- Running animation and FOV management (fixed & robust) ----------
local RunAnimator = {
    animTrack = nil,
    humanoid = nil,
    connected = nil
}

local function setupRunAnimationForCharacter(char)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- disconnect previous connections/tracks
    if RunAnimator.connected then
        pcall(function() RunAnimator.connected:Disconnect() end)
        RunAnimator.connected = nil
    end
    if RunAnimator.animTrack and RunAnimator.animTrack.IsPlaying then
        pcall(function() RunAnimator.animTrack:Stop() end)
    end
    RunAnimator.humanoid = humanoid

    -- load animation
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(Settings.RunAnimId)
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action3
    RunAnimator.animTrack = track
    track:AdjustSpeed(0.6) -- 👈 initial speed set to 0.5

    -- We'll use RenderStepped for smooth check
    RunAnimator.connected = RunService.RenderStepped:Connect(function()
        local character = getChar()
        if not character or not character:FindFirstChildOfClass("Humanoid") then return end
        local humanoidLocal = character:FindFirstChildOfClass("Humanoid")
        local moveDir = humanoidLocal.MoveDirection
        local isMoving = (moveDir.Magnitude > 0.01)

        -- Manage walk speed
        if Settings.RunSpeed and Settings.ConstantSpeed then
            humanoidLocal.WalkSpeed = Settings.RunSpeed
        else
            humanoidLocal.WalkSpeed = Settings.DefaultWalkSpeed
        end

        -- Play/Stop animation and change FOV smoothly
        if isMoving then
            if not RunAnimator.animTrack.IsPlaying then
                RunAnimator.animTrack:Play()
                RunAnimator.animTrack:AdjustSpeed(0.6) -- 👈 apply speed each time it starts
            end
            TweenService:Create(workspace.CurrentCamera, TweenInfo.new(Settings.FOV_TransitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = Settings.FOV_Run }):Play()
        else
            if RunAnimator.animTrack.IsPlaying then
                RunAnimator.animTrack:Stop(0.2)
            end
            TweenService:Create(workspace.CurrentCamera, TweenInfo.new(Settings.FOV_TransitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = Settings.FOV_Default }):Play()
        end
    end)
end


-- Ensure Settings.ConstantSpeed exists (default true to match original)
if getgenv().ConstantSpeed == nil then
    getgenv().ConstantSpeed = true
end
Settings.ConstantSpeed = getgenv().ConstantSpeed

-- Set up initial run animation when character exists, and on respawn
local function bindCharacter(char)
    pcall(function()
        setupRunAnimationForCharacter(char)
        -- re-set ultimate attribute on respawn
        pcall(function() char:SetAttribute("UltimateName", "AW SHUCKS") end)
        -- reconnect move handlers or other bindings if necessary
        connectDeathblowHandler()
        connectCinematicHandler()
    end)
end

-- Bind on current char and character added
local currentChar = getChar()
if currentChar then bindCharacter(currentChar) end
lp.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    bindCharacter(character)
end)

-- Remove global music creation/loops from original:
-- In the original file there was a looping music sound attached to the player's head.
-- Per request, music is removed entirely. We keep short move sound effects in their locations.

-- ---------- Map load helper (ensures _Map exists) ----------
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

-- ---------- Safe reconnect on respawn to re-bootstrap environment ----------
pcall(function() if getgenv().pepe then getgenv().pepe:Disconnect() end end)
getgenv().pepe = lp.CharacterAdded:Connect(function(c)
    repeat task.wait() until c:FindFirstChild('Humanoid')
    task.spawn(function() task.wait(1); pcall(function() if MainEnv then MainEnv() end end) end)
    pcall(function() if SpawnA then SpawnA() end end)
end)

-- ---------- Main environment bootstrap (disconnect conflicting handlers) ----------
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

