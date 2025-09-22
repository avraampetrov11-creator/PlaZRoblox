-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

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

	-- Add Homework_Turn tool to Handle
	Core_Replication:FireServer("Tools", "Add", ReplicatedStorage.Misc.Homework_Turn, WeaponGun.Handle)
	task.wait(1)

	-- Add Exit_Sign text
	Core_Replication:FireServer(
		"Tools",
		"Add",
		workspace.Map.Alice_Room.Alice_Door.Door.Decor.Exit_Sign.Text.SurfaceGui.TextLabel,
		WeaponGun.Handle.Homework_Turn
	)
	task.wait(1)


end

local ammo = 10
local maxAmmo = 10
local reloading = false

local function updateAmmo()
	local tagText = string.format(
		"<br></br><stroke joins='miter' thickness='3' color='rgb(128,128,128)'>" ..
		"<font size='15' color='rgb(153,255,204)' face='GothamBlack'>%d / %d</font></stroke>",
		ammo, maxAmmo
	)
	Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.Main_Text, "", nil)
	Core_Replication:FireServer("Text", "Set", WeaponGun.Handle.Homework_Turn.TextLabel, tagText, nil)
end

local function detectHit()
	local targetPart = mouse.Target
	if not targetPart then return end

	local character = targetPart:FindFirstAncestorOfClass("Model")
	if character and Players:GetPlayerFromCharacter(character) then
		Core_Replication:FireServer("Tools", "Remove", targetPart)
	end
end

local function onShoot()
	if not (WeaponGun:FindFirstChild("Handle") and WeaponGun.Handle:FindFirstChild("Homework_Turn")) then
		return
	end
	if reloading then return end

	if ammo > 0 then
		ammo -= 1
		updateAmmo()

	    game.ReplicatedStorage.Events.Tools:FireServer("Knife", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Knife_Swing"))
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        game.ReplicatedStorage.Events.Tools:FireServer("Mobile", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Mobile_Notification"))
        task.wait(0.01)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
		task.wait(0.01)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        task.wait(0.02)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        task.wait(0.03)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        task.wait(0.04)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        task.wait(0.05)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
		task.wait(0.06)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        task.wait(0.07)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        task.wait(0.08)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        task.wait(0.1)
        game.ReplicatedStorage.Events.Tools:FireServer("Ruler", workspace.Players.AvraamPetroman.Ruler, game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Tools"):WaitForChild("Ruler"))
        

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

setupWeapon()
updateAmmo()
mouse.Button1Down:Connect(onShoot)
