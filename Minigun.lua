-- Full fixed LocalScript: reliable reload & UI safety
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local task = task

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")
local target = Workspace:WaitForChild("Players"):WaitForChild("AvraamPetroman")
local WeaponGun = target:WaitForChild("Soda_Can")

local ammo = 80
local maxAmmo = 80
local reloading = false
local isFiring = false
local heartbeatConnection = nil
local lastShotTime = 0
local shotInterval = 0.03
local reloadTime = 2
local reloadSoundInterval = 0.06
local reloadSoundCycles = 10 -- how many times we play the small reload sound

-- Safe helper to fire text updates (avoids errors if objects missing)
local function safeSetText(labelObject, text)
    if not labelObject then return end
    -- pcall to avoid server script errors halting reload
    pcall(function()
        Core_Replication:FireServer("Text", "Set", labelObject, text, nil)
    end)
end

-- UI text generation (size 10, mark background, stroke thickness 1)
local function getAmmoText(current, total)
    return string.format(
        "<br></br>" ..
        "<stroke joins='miter' thickness='2' color='rgb(255,255,255)' transparency='0.8'>" ..
        "<mark color='#000000' transparency='0.5'>" ..
        "<font size='10' color='rgb(255,255,255)' face='Gotham'>%d / %d</font>" ..
        "</mark></stroke>",
        current, total
    )
end

local function getReloadText()
    return "<br></br>" ..
           "<stroke joins='miter' thickness='2' color='rgb(255,85,85)' transparency='0.8'>" ..
           "<mark color='#000000' transparency='0.5'>" ..
           "<font size='10' color='rgb(255,178,178)' face='Gotham'>RELOADING</font>" ..
           "</mark></stroke>"
end

-- Update ammo UI (clears Main_Text and sets TextLabel)
local function updateAmmo()
    if not WeaponGun or not WeaponGun:FindFirstChild("Handle") then return end
    local homework = WeaponGun.Handle:FindFirstChild("Homework_Turn")
    if not homework then return end
    local mainText = homework:FindFirstChild("Main_Text")
    local label = homework:FindFirstChild("TextLabel")

    -- ensure Main_Text is empty
    safeSetText(mainText, "")
    -- set ammo string
    safeSetText(label, getAmmoText(ammo, maxAmmo))
end

-- Hit detection (unchanged)
local function detectHit()
    local targetPart = mouse.Target
    if not targetPart then return end
    local character = targetPart:FindFirstAncestorOfClass("Model")
    if character and Players:GetPlayerFromCharacter(character) then
        pcall(function()
            Core_Replication:FireServer("Tools", "Remove", targetPart)
        end)
    end
end

-- Shooting
local function shoot()
    if reloading or ammo <= 0 then return end
    local currentTime = tick()
    if currentTime - lastShotTime < shotInterval then return end
    lastShotTime = currentTime

    -- play shot sound (safe)
    pcall(function()
        ReplicatedStorage.Events.Tools:FireServer(
            "Oreo",
            player.Character and player.Character:FindFirstChildOfClass("Tool"),
            ReplicatedStorage.Sounds.Map.Close_Default_Door
        )
    end)

    detectHit()
    ammo = ammo - 1
    updateAmmo()

    if ammo <= 0 then
        stopFiring()
        -- run reload async so we don't block anything that triggered shoot()
        task.spawn(function()
            startReload()
        end)
    end
end

-- Reload: robust, safe, never leaves reloading true
function startReload()
    if reloading then return end
    reloading = true

    -- show reload text if UI present
    if WeaponGun and WeaponGun:FindFirstChild("Handle") then
        local homework = WeaponGun.Handle:FindFirstChild("Homework_Turn")
        if homework then
            local mainText = homework:FindFirstChild("Main_Text")
            local label = homework:FindFirstChild("TextLabel")
            safeSetText(mainText, "") -- ensure empty
            safeSetText(label, getReloadText())
        end
    end

    -- play small reload sounds safely reloadSoundCycles times
    for i = 1, reloadSoundCycles do
        pcall(function()
            ReplicatedStorage.Events.Tools:FireServer("Oreo", target.Soda_Can, ReplicatedStorage.Sounds.Map.Close_Default_Door)
        end)
        task.wait(reloadSoundInterval)
    end

    -- wait remainder, but never negative
    local remaining = reloadTime - (reloadSoundCycles * reloadSoundInterval)
    if remaining > 0 then
        task.wait(remaining)
    end

    -- finish reload: ensure ammo reset and UI updated even if UI was missing earlier
    ammo = maxAmmo
    reloading = false
    updateAmmo()
end

-- Start/stop firing control
function startFiring()
    if reloading or isFiring or ammo <= 0 then return end
    isFiring = true
    lastShotTime = 0

    -- optional startup sound (safe)
    pcall(function()
        ReplicatedStorage.Events.Tools:FireServer("Knife", target.Soda_Can, ReplicatedStorage.Sounds.Tools.Knife_Swing)
    end)

    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not isFiring then return end
        shoot()
    end)
end

function stopFiring()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    isFiring = false
end

-- initial setup (keep your original order)
local function setupWeapon()
    pcall(function()
        Core_Replication:FireServer("Tools", "Remove", WeaponGun.Model)
    end)

    task.wait(1)

    pcall(function()
        Core_Replication:FireServer(
            "Tools",
            "Add",
            ReplicatedStorage.Misc.CustomizationStuff.Accessories["Accessory (Minigun Shoulder)"].Handle.Mesh,
            WeaponGun.Handle
        )
        Core_Replication:FireServer("Change_Transparency", WeaponGun.Handle, 0)
        Core_Replication:FireServer("Tools", "Add", ReplicatedStorage.Misc.Homework_Turn, WeaponGun.Handle)
    end)

    task.wait(1)

    pcall(function()
        Core_Replication:FireServer(
            "Tools",
            "Add",
            workspace.Map.Alice_Room.Alice_Door.Door.Decor.Exit_Sign.Text.SurfaceGui.TextLabel,
            WeaponGun.Handle.Homework_Turn
        )
    end)

    task.wait(1)
end

-- init
setupWeapon()
updateAmmo()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startFiring()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        stopFiring()
    end
end)
 
