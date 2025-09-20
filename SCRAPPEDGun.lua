-- 📜 LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Core_Replication = ReplicatedStorage.Events.Core_Replication
local WeaponGun = workspace.Players.AvraamPetroman.Soda_Can

-- 🔧 Utility: wait until something exists
local function waitFor(parent, name)
	parent:WaitForChild(name)
	return parent[name]
end

-- 🔥 Fireplace references
local Fireplace = waitFor(workspace.Map.Outside.Houses.House_1.Inside.Reactors, "Fireplace")
local Fire = waitFor(Fireplace, "Fire")
local Trigger = waitFor(Fireplace, "Trigger")
local Light = waitFor(Fire, "PointLight")

-- 🧪 Preload setup
local function setupWeapon()
	Core_Replication:FireServer("Tools", "Remove", WeaponGun.Model)
	task.wait(2.5)

	Core_Replication:FireServer("Tools", "Add",
		game:GetService("ReplicatedStorage").Misc.CustomizationStuff.Accessories["MeshPartAccessory"].Handle.SpecialMesh,
		WeaponGun.Handle
	)

	Core_Replication:FireServer("Change_Transparency", WeaponGun.Handle, 0)

	Core_Replication:FireServer("Tools", "Add", ReplicatedStorage.Misc.Homework_Turn, WeaponGun.Handle)
	task.wait(3)

	Core_Replication:FireServer("Tools", "Add",
		workspace.Map.Alice_Room.Alice_Door.Door.Decor.Exit_Sign.Text.SurfaceGui.TextLabel,
		WeaponGun.Handle.Homework_Turn
	)

	task.wait(1.5)

	Core_Replication:FireServer("Tools", "Add", Light, ReplicatedStorage.Misc.CustomizationStuff)
	task.wait(1)
end

-- 📦 Ammo variables
local ammo = 10
local maxAmmo = 10
local reloading = false

-- 🎨 Update ammo text
local function updateAmmo()
	local tagText = string.format(
		"<br></br><stroke joins='miter' thickness='3' color='rgb(128,128,128)'>" ..
		"<font size='15' color='rgb(153,255,204)' face='GothamBlack'>%d / %d</font></stroke>",
		ammo, maxAmmo
	)

	Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.Main_Text, "", nil)
	Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.TextLabel, tagText, nil)
end

-- 💡 Shooting visual effect
local function shootVFX()
	local ShootLight = ReplicatedStorage.Misc.CustomizationStuff:WaitForChild("PointLight")
	Core_Replication:FireServer("Tools", "Add", ShootLight, WeaponGun.Handle)

	repeat task.wait() until WeaponGun.Handle:FindFirstChild("PointLight")
	task.wait(0.2)

	if WeaponGun.Handle:FindFirstChild("PointLight") then
		Core_Replication:FireServer("Tools", "Remove", WeaponGun.Handle.PointLight)
		repeat task.wait() until not WeaponGun.Handle:FindFirstChild("PointLight")
	end
end

-- 🎯 Mouse.Target hit detection
local function detectHit()
	local targetPart = mouse.Target
	if not targetPart then return end

	-- Check if it's part of a character
	local character = targetPart:FindFirstAncestorOfClass("Model")
	if character and Players:GetPlayerFromCharacter(character) then
		-- 🔥 Remove just the bodypart clicked
		Core_Replication:FireServer("Tools", "Remove", targetPart)
	end
end

-- 🔫 Handle shooting
local function onShoot()
	if not (WeaponGun:FindFirstChild("Handle") and WeaponGun.Handle:FindFirstChild("Homework_Turn")) then
		return
	end
	if reloading then return end

	if ammo > 0 then
		ammo -= 1
		updateAmmo()
		--shootVFX()
        game.ReplicatedStorage.Events.Tools:FireServer("Knife", workspace.Players.AvraamPetroman.Soda_Can, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Knife_Swing"))
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Soda_Can, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        game.ReplicatedStorage.Events.Tools:FireServer("Mobile", workspace.Players.AvraamPetroman.Soda_Can, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Mobile_Notification"))
        task.wait(0.05)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Soda_Can, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
		task.wait(0.05)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Soda_Can, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        task.wait(0.05)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Soda_Can, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        task.wait(0.05)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Soda_Can, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
         task.wait(0.05)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Soda_Can, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        
        
        
        detectHit()

		if ammo == 0 then
			local reloadText =
				"<br></br><stroke joins='miter' thickness='3' color='rgb(255,0,0)'>" ..
				"<font size='15' color='rgb(255,200,200)' face='GothamBlack'>RE'SAW!</font></stroke>"
			Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.TextLabel, reloadText, nil)
		end
	else
		reloading = true
		local reloadText =
			"<br></br><stroke joins='miter' thickness='3' color='rgb(0,128,255)'>" ..
			"<font size='15' color='rgb(200,230,255)' face='GothamBlack'>RE'SAWIN'</font></stroke>"
		Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.TextLabel, reloadText, nil)

		task.wait(2.5)
		ammo = maxAmmo
		reloading = false
		updateAmmo()
	end
end

-- 🚀 Init
setupWeapon()
updateAmmo()
mouse.Button1Down:Connect(onShoot)
