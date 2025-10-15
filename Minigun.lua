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

-- safe helper for updating text through replication
local function safeSetText(labelObject, text)
	if not labelObject then return end
	pcall(function()
		Core_Replication:FireServer("Text", "Set", labelObject, text, nil)
	end)
end

-- ammo display
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

-- reload text
local function getReloadText()
	return "<br></br>" ..
		"<stroke joins='miter' thickness='2' color='rgb(255,85,85)' transparency='0.8'>" ..
		"<mark color='#000000' transparency='0.5'>" ..
		"<font size='10' color='rgb(255,178,178)' face='Gotham'>RELOADING</font>" ..
		"</mark></stroke>"
end

-- update ammo UI
local function updateAmmo()
	if not WeaponGun or not WeaponGun:FindFirstChild("Handle") then return end
	local homework = WeaponGun.Handle:FindFirstChild("Homework_Turn")
	if not homework then return end
	local mainText = homework:FindFirstChild("Main_Text")
	local label = homework:FindFirstChild("TextLabel")

	safeSetText(mainText, "")
	safeSetText(label, getAmmoText(ammo, maxAmmo))
end

-- check if tool equipped
local function isToolEquipped()
	return player.Character and player.Character:FindFirstChildOfClass("Tool") == WeaponGun
end

-- detect hit (only if tool is equipped)
local function detectHit()
	if not isToolEquipped() then return end -- safety check
	local targetPart = mouse.Target
	if not targetPart then return end
	local character = targetPart:FindFirstAncestorOfClass("Model")
	if character and Players:GetPlayerFromCharacter(character) then
		pcall(function()
			Core_Replication:FireServer("Tools", "Remove", targetPart)
		end)
	end
end

-- shooting
local function shoot()
	if reloading or ammo <= 0 then return end
	if not isToolEquipped() then return end -- no shooting unless equipped
	local currentTime = tick()
	if currentTime - lastShotTime < shotInterval then return end
	lastShotTime = currentTime

	pcall(function()
		ReplicatedStorage.Events.Tools:FireServer(
			"Oreo",
			player.Character and player.Character:FindFirstChildOfClass("Tool"),
			ReplicatedStorage.Sounds.Map.Close_Default_Door
		)
		ReplicatedStorage.Events.Tools:FireServer(
			"Ruler",
			player.Character and player.Character:FindFirstChildOfClass("Tool"),
			ReplicatedStorage.Sounds.Tools.Ruler
		)
	end)

	detectHit()
	ammo -= 1
	updateAmmo()

	if ammo <= 0 then
		stopFiring()
		task.spawn(function()
			startReload()
		end)
	end
end

-- reload
function startReload()
	if reloading then return end
	reloading = true

	if WeaponGun and WeaponGun:FindFirstChild("Handle") then
		local homework = WeaponGun.Handle:FindFirstChild("Homework_Turn")
		if homework then
			local mainText = homework:FindFirstChild("Main_Text")
			local label = homework:FindFirstChild("TextLabel")
			safeSetText(mainText, "")
			safeSetText(label, getReloadText())
		end
	end

	for i = 1, reloadSoundCycles do
		pcall(function()
			ReplicatedStorage.Events.Tools:FireServer("Oreo", target.Soda_Can, ReplicatedStorage.Sounds.Map.Close_Default_Door)
		end)
		task.wait(reloadSoundInterval)
	end

	local remaining = reloadTime - (reloadSoundCycles * reloadSoundInterval)
	if remaining > 0 then
		task.wait(remaining)
	end

	ammo = maxAmmo
	reloading = false
	updateAmmo()
end

-- firing control
function startFiring()
	if reloading or isFiring or ammo <= 0 then return end
	if not isToolEquipped() then return end -- ensure tool is equipped
	isFiring = true
	lastShotTime = 0

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

-- weapon setup
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
