-- =======================
-- AUDIO LOADER INTEGRATION
-- =======================
local audioUrl = "https://raw.githubusercontent.com/avraampetrov11-creator/PlaZRoblox/main/ShucksAudio.mp3"
local audioName = "ShucksAudio"
local audioFileName = audioName .. ".mp3"

local function DownloadAudio()
    local success, response = pcall(function()
        local fileContent = game:HttpGet(audioUrl)
        writefile(audioFileName, fileContent)
        print("Audio downloaded successfully: " .. audioFileName)
    end)
    if not success then
        warn("Failed to download audio: " .. tostring(response))
    end
end

if not isfile(audioFileName) then
    DownloadAudio()
else
    print("Audio file already exists: " .. audioFileName)
end

-- =======================
-- AW SHUCKS SCRIPT START
-- =======================

-- =======================
-- SETTINGS
-- =======================
local Settings = {
    -- Run Animation (Existing)
    RunAnimId = "18897115785",

    -- New Random Idle Animations
    IdleAnimsList = {
        "137841251329955",
        "103362214977039", 
        "113201609340793", 
        "104862750267967" 
    },

    -- New Random Walk Animations
    WalkAnimsList = {
        "89642715363301", 
        "17269023470" 

    },

    -- Old definitions (kept for compatibility with some logic, but overridden by new system)
    IdleBaseAnimId = "14516273501", 
    OLDIdleAnimId = "17465544429",
    IdleAnimId = "18459183268", 

    -- Movement & Camera
    RunSpeed = 38,
    DefaultWalkSpeed = 25,
    WalkThreshold = 24, -- Speed below this triggers walking anims
    FOV_Run = 115,
    FOV_Default = 80,
    FOV_TransitionTime = 0.5,

    -- Run animation speeds
    DefaultRunAnimSpeed = 0.6,
    CurrentRunAnimSpeed = 0.6,

    -- Shuck-specific
    ShuckSpeed = 65,
    ShuckRunAnimSpeed = 0.8,
    ShuckMaxDuration = 26,

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
local StarterGui = game:GetService("StarterGui") 

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

local function highlightAndFade(delayTime, fadeTime)
    local map = workspace:WaitForChild("_Map")
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

    local workspaceHighlight = Instance.new("Highlight")
    workspaceHighlight.Adornee = map
    workspaceHighlight.FillColor = Color3.fromRGB(255, 0, 0)
    workspaceHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    workspaceHighlight.FillTransparency = 0
    workspaceHighlight.OutlineTransparency = 0
    workspaceHighlight.Parent = map

    local playerHighlight = Instance.new("Highlight")
    playerHighlight.Adornee = character
    playerHighlight.FillColor = Color3.fromRGB(255, 255, 255)
    playerHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    playerHighlight.FillTransparency = 0
    playerHighlight.OutlineTransparency = 0
    playerHighlight.Parent = character

    task.spawn(function()
        task.wait(delayTime)
        workspaceHighlight.FillColor = Color3.fromRGB(255, 255, 255)
        workspaceHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        playerHighlight.FillColor = Color3.fromRGB(0, 0, 0)
        playerHighlight.OutlineColor = Color3.fromRGB(0, 0, 0)

        local startTime = tick()
        while tick() - startTime < fadeTime do
            local alpha = math.clamp((tick() - startTime) / fadeTime, 0, 1)
            workspaceHighlight.FillTransparency = alpha
            workspaceHighlight.OutlineTransparency = alpha
            playerHighlight.FillTransparency = alpha
            playerHighlight.OutlineTransparency = alpha
            task.wait()
        end
        pcall(function()
            workspaceHighlight:Destroy()
            playerHighlight:Destroy()
        end)
    end)
end

local function pushForward(forcePower, duration)
    local char = getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = hrp.CFrame.LookVector * forcePower
    bodyVelocity.Parent = hrp

    local startTime = tick()
    task.spawn(function()
        while tick() - startTime < duration do
            local alpha = 1 - ((tick() - startTime) / duration)
            if hrp then
                bodyVelocity.Velocity = hrp.CFrame.LookVector * forcePower * alpha
            end
            task.wait()
        end
        pcall(function() bodyVelocity:Destroy() end)
    end)
end

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
                pcall(function() track:Stop(0.4) end)
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
                pcall(function() s:Destroy() end)
            end)
        end
    end)
end

function playMusic(soundId, volume, playbackSpeed, startPosition)
    local sound = Instance.new("Sound")
    sound.Name = "ShuckMusic"
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 3
    sound.PlaybackSpeed = playbackSpeed
    sound.TimePosition = startPosition
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
                workspace._Map.Highlight.FillTransparency = i/35
                workspace._Map.Highlight.OutlineTransparency = i/35
                task.wait(0.01)
            end
        end
    end)
end

-- =======================
-- IDLE ANIMATION HANDLER
-- =======================
local function setupIdleAnimation(char)
    -- This is now handled in the main RenderStepped loop for smoother transitions
end

-- =======================
-- MOVES LIST
-- =======================
local Moves = {
    {
        Name = "BLEED",
        Slot = "1",
        Cooldown = 7, 
        Ultimate = false, 
        Func = function() end
    },
    {
        Name = "WARNED",
        Slot = "2",
        Cooldown = 8,
        Ultimate = false, 
        Func = function() end
    },
    {
        Name = "HEED",
        Slot = "3",
        Cooldown = 60,
        Ultimate = false, 
        Func = function()
            -- placeholder Heed functionality
        end
    },
    {
        Name = "FAULT",
        Slot = "4",
        Cooldown = 3,
        Ultimate = false, 
        Func = function() end
    },
    {
        Name = "DODGE",
        Slot = "5",
        Cooldown = 8, 
        Ultimate = false, 
        Func = function()
            playAnimation("18435535291", 1, 0.3)
            playSound("7094593247", 1.5, 0.4)

            task.spawn(function()
                local Player = lp
                local BodyParts = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }

                local function AfterImage(color3, material, duration, trans)
                    if not Player.Character then return end
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
                        if char2.Torso:FindFirstChild("DashSpin") then char2.Torso.DashSpin:Emit(1) end
                        if char2.Torso:FindFirstChild("DashSpin1") then char2.Torso.DashSpin1:Emit(1) end
                    end
                    hrp.CFrame = hrp.CFrame * CFrame.new(0.8,0,0.8)
                    task.wait(0.01)
                end
            elseif rnd == 2 then
                for i = 1, 35 do
                    if char2:FindFirstChild("Torso") then
                        if char2.Torso:FindFirstChild("DashSpin") then char2.Torso.DashSpin:Emit(1) end
                        if char2.Torso:FindFirstChild("DashSpin1") then char2.Torso.DashSpin1:Emit(1) end
                    end
                    hrp.CFrame = hrp.CFrame * CFrame.new(-0.8,0,0.8)
                    task.wait(0.01)
                end
            else
                for i = 1, 35 do
                    if char2:FindFirstChild("Torso") then
                        if char2.Torso:FindFirstChild("DashSpin") then char2.Torso.DashSpin:Emit(1) end
                        if char2.Torso:FindFirstChild("DashSpin1") then char2.Torso.DashSpin1:Emit(1) end
                    end
                    hrp.CFrame = hrp.CFrame * CFrame.new(0,0,0.8)
                    task.wait(0.01)
                end
            end
        end
    },
    {
        Name = "S H U C K S",
        Slot = "8",
        Cooldown = 34,
        Ultimate = true, 
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

            playAnimation("85025226664507", 0.5, 5)
            highlightAndFade(2.3, 1)

            -- MODIFIED: Playing the Custom Audio using getcustomasset
            local sound = Instance.new("Sound")
            sound.Name = "CustomShucksAudio"
            -- Try to use the file downloaded at start
            local assetId = getcustomasset(audioFileName) 
            sound.SoundId = assetId
            sound.Volume = 3
            sound.PlaybackSpeed = 1 
            sound.Looped = false
            sound.Parent = SoundService
            sound:Play()

            task.wait(2)
            playAnimation("136363608783208", 0.9, 6)
            task.wait(0.8)
            pushForward(50,0.6)
            task.wait(0.65)
            pushForward(70,0.9)
            task.wait(0.65)
            pushForward(60,0.9)
            task.wait(0.6)
            pushForward(80,1)
            task.wait(0.5)
            pushForward(70,0.9)

            local prevRunSpeed = Settings.RunSpeed
            local prevAnimSpeed = Settings.CurrentRunAnimSpeed or Settings.DefaultRunAnimSpeed
            if getgenv().MovementHandler and getgenv().MovementHandler.animTrack then
                pcall(function()
                    prevAnimSpeed = getgenv().MovementHandler.animTrack and (getgenv().MovementHandler.animTrack.Speed or prevAnimSpeed) or prevAnimSpeed
                end)
            end

            Settings.RunSpeed = Settings.ShuckSpeed
            getgenv().ConstantSpeed = true
            Settings.ConstantSpeed = true
            Settings.CurrentRunAnimSpeed = Settings.ShuckRunAnimSpeed
            if getgenv().MovementHandler and getgenv().MovementHandler.animTrack then
                pcall(function() getgenv().MovementHandler.animTrack:AdjustSpeed(Settings.CurrentRunAnimSpeed) end)
            end

            pcall(function()
                if humanoid then humanoid.WalkSpeed = Settings.ShuckSpeed end
            end)

            local function restoreShuck()
                Settings.RunSpeed = prevRunSpeed or 45
                Settings.CurrentRunAnimSpeed = prevAnimSpeed or Settings.DefaultRunAnimSpeed
                if getgenv().MovementHandler and prevAnimSpeed and getgenv().MovementHandler.animTrack then
                    pcall(function() getgenv().MovementHandler.animTrack:AdjustSpeed(Settings.CurrentRunAnimSpeed) end)
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
                    -- Cleanup if not ended yet
                    pcall(function() sound:Destroy() end)
                    restoreShuck()
                end)
            else
                task.delay(Settings.ShuckMaxDuration, restoreShuck)
            end
        end
    },
    {
        Name = "MISTAKE",
        Slot = "6",
        Cooldown = 5,
        Ultimate = false, 
        Func = function()
            local char = getChar()
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            -- Stop all animations
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end

            playAnimation("119293848229043", 0.8, 9)
            task.wait(2.4)
            playAnimation("128934660661875", 0.8, 9)
            highlightAndFade(0.69, 1)
            task.wait(0.69)
            pushForward(150,0.5)
            task.wait(0)

            -- Example server call (custom to your game)
            if workspace.Live and workspace.Live:FindFirstChild("AvraamPetroman") and workspace.Live.AvraamPetroman:FindFirstChild("Communicate") then
                pcall(function()
                    workspace.Live.AvraamPetroman.Communicate:FireServer({["Mobile"] = true,["Goal"] = "LeftClick"})
                end)
                task.wait(1)
                pcall(function()
                    workspace.Live.AvraamPetroman.Communicate:FireServer({["Goal"] = "LeftClickRelease",["Mobile"] = true})
                end)
            end
        end
    }, 
{
        Name = "SAWDUST",
        Slot = "7",
        Cooldown = 1,
        Ultimate = false,
        Func = function()
            local char = getChar()
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            -- Stop all animations
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end

            playAnimation("137561511768861", 0.8, 9) 
            --highlightAndFade(0.69, 1)
            task.wait(0.69)
            pushForward(200,0.4)
            task.wait(0)

            -- Example server call (custom to your game)
            if workspace.Live and workspace.Live:FindFirstChild("AvraamPetroman") and workspace.Live.AvraamPetroman:FindFirstChild("Communicate") then
                pcall(function()
                    workspace.Live.AvraamPetroman.Communicate:FireServer({["Mobile"] = true,["Goal"] = "LeftClick"})
                end)
                task.wait(0.6)
                pcall(function()
                    workspace.Live.AvraamPetroman.Communicate:FireServer({["Goal"] = "LeftClickRelease",["Mobile"] = true})
                end)
            end
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
                        -- Locate the player's hotbar slot
                        local hotbar = lp.PlayerGui:FindFirstChild("Hotbar")
                                and lp.PlayerGui.Hotbar:FindFirstChild("Backpack")
                                and lp.PlayerGui.Hotbar.Backpack:FindFirstChild("Hotbar")

                        if not hotbar then return end

                        local slotGui = hotbar:FindFirstChild(tostring(move.Slot))
                        if not slotGui or not slotGui:FindFirstChild("Base") then return end

                        local base = slotGui.Base

                        -- Set move name
                        if base:FindFirstChild("ToolName") then
                                base.ToolName.Text = move.Name
                        end

                        -- If Ultimate = true, clone Flipbook into this Base
                        if move.Ultimate == true then
                                local flipbookSource = StarterGui:FindFirstChild("Hotbar")
                                        and StarterGui.Hotbar:FindFirstChild("Backpack")
                                        and StarterGui.Hotbar.Backpack:FindFirstChild("LocalScript")
                                        and StarterGui.Hotbar.Backpack.LocalScript:FindFirstChild("Flipbook")

                                if flipbookSource and not base:FindFirstChild("Flipbook") then
                                        local clone = flipbookSource:Clone()
                                        clone.Parent = base
                                        clone.LocalScript.Enabled = true
                                end
                        end
                end)
        end
end

-- =======================
-- MOVEMENT & ANIMATION SYSTEM (WALK/RUN/IDLE)
-- =======================
getgenv().MovementHandler = getgenv().MovementHandler or { 
    animTrack = nil, 
    humanoid = nil, 
    connected = nil,
    currentState = "None" -- "Idle", "Walk", "Run"
}

local function setupMovementSystem(char)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    -- Cleanup previous
    if getgenv().MovementHandler.connected then
        pcall(function() getgenv().MovementHandler.connected:Disconnect() end)
        getgenv().MovementHandler.connected = nil
    end
    if getgenv().MovementHandler.animTrack then
        pcall(function() getgenv().MovementHandler.animTrack:Stop() end)
    end

    getgenv().MovementHandler.humanoid = humanoid
    getgenv().MovementHandler.currentState = "None"

    -- Function to play a new animation based on ID
    local function playAnim(id, speed, priority)
        if getgenv().MovementHandler.animTrack then
            getgenv().MovementHandler.animTrack:Stop(0.2)
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(id)
        local track = humanoid:LoadAnimation(anim)
        track.Priority = priority or Enum.AnimationPriority.Action3
        track:Play(0.2)
        track:AdjustSpeed(speed or 1)
        getgenv().MovementHandler.animTrack = track
    end

    getgenv().MovementHandler.connected = RunService.RenderStepped:Connect(function()
        local character = getChar()
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local hum = character:FindFirstChildOfClass("Humanoid")

        -- Calculate actual movement speed (ignoring vertical Y movement)
        local velocity = character.HumanoidRootPart.AssemblyLinearVelocity
        local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

        -- Force Movement Speed if needed (unless joystick slow walking is active visually, we usually want high max speed)
        if Settings.ConstantSpeed then
            pcall(function() hum.WalkSpeed = Settings.RunSpeed end)
        else
            pcall(function() hum.WalkSpeed = Settings.DefaultWalkSpeed end)
        end

        -- Determine State
        local newState = "Idle"
        if speed > 0.1 then
            if speed < Settings.WalkThreshold then
                newState = "Walk"
            else
                newState = "Run"
            end
        end

        -- State Machine Transition
        if newState ~= getgenv().MovementHandler.currentState then
            getgenv().MovementHandler.currentState = newState

            if newState == "Idle" then
                -- Play Random Idle
                local rnd = Settings.IdleAnimsList[math.random(1, #Settings.IdleAnimsList)]
                playAnim(rnd, 1, Enum.AnimationPriority.Idle)

                -- Reset FOV
                pcall(function()
                    TweenService:Create(workspace.CurrentCamera, TweenInfo.new(Settings.FOV_TransitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = Settings.FOV_Default }):Play()
                end)

            elseif newState == "Walk" then
                -- Play Random Walk
                local rnd = Settings.WalkAnimsList[math.random(1, #Settings.WalkAnimsList)]
                playAnim(rnd, 1, Enum.AnimationPriority.Action2)

                -- Reset FOV (Walking usually doesn't need huge FOV)
                pcall(function()
                    TweenService:Create(workspace.CurrentCamera, TweenInfo.new(Settings.FOV_TransitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = Settings.FOV_Default }):Play()
                end)

            elseif newState == "Run" then
                -- Play Run
                playAnim(Settings.RunAnimId, Settings.CurrentRunAnimSpeed, Enum.AnimationPriority.Action3)

                -- Increase FOV
                pcall(function()
                    TweenService:Create(workspace.CurrentCamera, TweenInfo.new(Settings.FOV_TransitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = Settings.FOV_Run }):Play()
                end)
            end
        else
            -- State hasn't changed, but maybe we need to adjust speed of running anim
            if newState == "Run" and getgenv().MovementHandler.animTrack then
                pcall(function()
                     getgenv().MovementHandler.animTrack:AdjustSpeed(Settings.CurrentRunAnimSpeed)
                end)
            end
        end
    end)
end

local function bindCharacter(char)
    pcall(function()
        setupMovementSystem(char)
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

lp.CharacterAdded:Connect(function(character)
        task.wait(1)

        local success, err = pcall(setHotbarNames)
        if not success then
                warn("Error setting hotbar names:", err)
        end
        bindMoves()   
end)
