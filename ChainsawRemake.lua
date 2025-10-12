local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Core_Replication = ReplicatedStorage.Events.Core_Replication
local target = Workspace:WaitForChild("Players"):WaitForChild("AvraamPetroman")
local WeaponGun = target.Ruler

local function waitFor(parent, name)
	parent:WaitForChild(name)
	return parent[name]
end

local function setupWeapon()
	for _, child in ipairs(WeaponGun.Ruler:GetChildren()) do
		Core_Replication:FireServer("Tools", "Remove", child)
	end
	task.wait(1)

	Core_Replication:FireServer(
		"Tools",
		"Add",
		game:GetService("ReplicatedStorage").Misc.CustomizationStuff.Accessories["MeshPartAccessory"].Handle.SpecialMesh,
		WeaponGun.Handle
	)
	Core_Replication:FireServer("Change_Transparency", WeaponGun.Handle, 0)
	Core_Replication:FireServer("Change_Transparency", WeaponGun.Ruler, 1)

	Core_Replication:FireServer("Tools", "Add", ReplicatedStorage.Misc.Homework_Turn, WeaponGun.Handle)
	task.wait(1)

	Core_Replication:FireServer(
		"Tools",
		"Add",
		workspace.Map.Alice_Room.Alice_Door.Door.Decor.Exit_Sign.Text.SurfaceGui.TextLabel,
		WeaponGun.Handle.Homework_Turn
	)
	task.wait(1)
end

local ammo = 20
local maxAmmo = 20
local reloading = false
local isActive = false
local heartbeatConnection = nil
local lastSoundTime = 0
local lastHitTime = 0
local soundInterval = 0.03  -- Faster revving sound
local hitInterval = 0.05    -- Faster hit detection
local ammoDrainInterval = 0.1  -- Faster ammo drain
local accumulatedTime = 0

local function updateAmmo()
	local tagText = string.format(
		"<br></br><stroke joins='miter' thickness='4' color='rgb(200,0,0)'>" ..
		"<font size='16' color='rgb(255,100,100)' face='Bangers'>%d / %d</font></stroke>",
		ammo, maxAmmo
	)
	Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.Main_Text, "", nil)
	Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.TextLabel, tagText, nil)
end

local function detectHit()
	local currentTime = tick()
	if currentTime - lastHitTime < hitInterval then return end
	lastHitTime = currentTime

	local targetPart = mouse.Target
	if not targetPart then return end

	local character = targetPart:FindFirstAncestorOfClass("Model")
	if character and Players:GetPlayerFromCharacter(character) then
		Core_Replication:FireServer("Tools", "Remove", targetPart)
		game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
	end
end

local function stopChainsaw()
	isActive = false
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
	game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
end

local function startChainsaw()
	if not (WeaponGun:FindFirstChild("Handle") and WeaponGun.Handle:FindFirstChild("Homework_Turn")) then
		return
	end
	if reloading or isActive then return end
	if ammo <= 0 then return end

	isActive = true
	accumulatedTime = 0

	game.ReplicatedStorage.Events.Tools:FireServer("Knife", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Knife_Swing"))

	heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		if not isActive then return end

		local currentTime = tick()

		if currentTime - lastSoundTime >= soundInterval then
			game.ReplicatedStorage.Events.Tools:FireServer("Oreo", game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool"), game:GetService("ReplicatedStorage").Sounds.Map.Close_Default_Door)
			lastSoundTime = currentTime
		end

		detectHit()

		accumulatedTime += deltaTime
		if accumulatedTime >= ammoDrainInterval then
			if ammo > 0 then
				ammo = math.max(0, ammo - 1)
				updateAmmo()
				accumulatedTime = 0
			end

			if ammo <= 0 then
				stopChainsaw()
				reloading = true
				local reloadText =
					"<br></br><stroke joins='miter' thickness='4' color='rgb(255,50,50)'>" ..
					"<font size='16' color='rgb(255,120,120)' face='Bangers'>REVVIN' UP!</font></stroke>"
				Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.TextLabel, reloadText, nil)

				for i = 1, 5 do
					game.ReplicatedStorage.Events.Tools:FireServer("Oreo", game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool"), game:GetService("ReplicatedStorage").Sounds.Map.Close_Default_Door)
					task.wait(0.06) -- Faster reload sound
				end

				task.wait(1.5) -- Faster reload time
				ammo = maxAmmo
				reloading = false
				updateAmmo()
			end
		end

		if ammo == 0 then
			local reloadText =
				"<br></br><stroke joins='miter' thickness='4' color='rgb(255,0,0)'>" ..
				"<font size='16' color='rgb(255,80,80)' face='Bangers'>SAW'S HUNGRY!</font></stroke>"
			Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.TextLabel, reloadText, nil)
		end
	end)
end

setupWeapon()
updateAmmo()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		startChainsaw()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		stopChainsaw()
	end
end)
