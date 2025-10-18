local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")

-- SETTINGS
local TRAP_RADIUS = 2
local TRAP_LIFETIME = 10
local RAGDOLL_TIME = 20

local Beartraps = {}

----------------------------------------------------
-- 🔍 Finds the specific beartrap accessory
----------------------------------------------------
local function findSpecificAccessory()
	local accessories = ReplicatedStorage:WaitForChild("Misc"):WaitForChild("CustomizationStuff"):WaitForChild("Accessories")
	for _, accessory in pairs(accessories:GetChildren()) do
		if accessory.Name == "Accessory (MeshPartAccessory)" then
			local handle = accessory:FindFirstChild("Handle")
			if handle then
				local mesh = handle:FindFirstChild("SpecialMesh")
				if mesh and mesh.MeshId == "rbxassetid://18872264420" then
					return accessory
				end
			end
		end
	end
	return nil
end

----------------------------------------------------
-- 🪤 Spawn beartrap
----------------------------------------------------
local function spawnNewBeartrap()
	local character = player.Character or player.CharacterAdded:Wait()
	local head = character:FindFirstChild("Head")
	if not head then return end

	-- Only if holding tool
	local tool = character:FindFirstChildOfClass("Tool")
	if not tool or tool.Name ~= "Ruler" then
		warn("Not holding Ruler tool — cannot place beartrap.")
		return
	end

	-- Create clone on server
	Core_Replication:FireServer("Tools", "Add", head, Workspace)
	task.wait(0.25)

	local newTrap
	for _, obj in pairs(Workspace:GetChildren()) do
		if obj:IsA("BasePart") and obj.Name == head.Name and obj.Parent == Workspace then
			if obj.Size == head.Size and not obj:GetAttribute("Spawned") then
				newTrap = obj
				break
			end
		end
	end
	if not newTrap then
		warn("❌ Could not find spawned trap part")
		return
	end

	newTrap:SetAttribute("Spawned", true)

	local face = newTrap:FindFirstChild("face") or newTrap:FindFirstChild("Face")
	if face then face:Destroy() end

	local beartrapAccessory = findSpecificAccessory()
	if beartrapAccessory then
		local mesh = beartrapAccessory.Handle:FindFirstChild("SpecialMesh")
		if mesh then
			task.wait(0.2)
			Core_Replication:FireServer("Tools", "Add", mesh, newTrap)
			print("✅ Beartrap placed!")
			table.insert(Beartraps, newTrap)
		end
	end

	-- Despawn after lifetime
	task.delay(TRAP_LIFETIME, function()
		if newTrap and newTrap.Parent then
			Core_Replication:FireServer("Tools", "Remove", newTrap)
			for i, trap in ipairs(Beartraps) do
				if trap == newTrap then
					table.remove(Beartraps, i)
					break
				end
			end
			print("🕒 Beartrap despawned.")
		end
	end)
end

----------------------------------------------------
-- 💥 Check for players near traps
----------------------------------------------------
local function monitorBeartraps()
	while task.wait(0.25) do
		for i = #Beartraps, 1, -1 do
			local trap = Beartraps[i]
			if not trap or not trap.Parent then
				table.remove(Beartraps, i)
				continue
			end

			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local dist = (trap.Position - plr.Character.HumanoidRootPart.Position).Magnitude
					if dist <= TRAP_RADIUS then
						print("💥 Trap triggered by:", plr.Name)

						-- Ragdoll player
						local settings = plr.Character:FindFirstChild("Character_Settings")
						if settings then
							Core_Replication:FireServer("Change_Att", settings, "Ragdoll", true)
							task.delay(RAGDOLL_TIME, function()
								if settings then
									Core_Replication:FireServer("Change_Att", settings, "Ragdoll", false)
								end
							end)
						end

						-- Destroy trap
						Core_Replication:FireServer("Tools", "Remove", trap)
						table.remove(Beartraps, i)
						break
					end
				end
			end
		end
	end
end

----------------------------------------------------
-- 🎨 Make the tool look like a beartrap
----------------------------------------------------
local function setupWeaponAsBeartrap()
	local character = player.Character or player.CharacterAdded:Wait()
	local tool = character:FindFirstChild("Ruler")
	if not tool then return end

	for _, child in ipairs(tool:GetChildren()) do
		if child.Name ~= "Handle" then
			Core_Replication:FireServer("Tools", "Remove", child)
		end
	end

	local beartrapAccessory = findSpecificAccessory()
	if beartrapAccessory then
		local mesh = beartrapAccessory.Handle:FindFirstChild("SpecialMesh")
		if mesh then
			Core_Replication:FireServer("Tools", "Add", mesh, tool.Handle)
			Core_Replication:FireServer("Change_Transparency", tool.Handle, 0)
			print("🔧 Tool now looks like a beartrap!")
		end
	end
end

----------------------------------------------------
-- 🖱️ Controls
----------------------------------------------------
mouse.Button1Down:Connect(function()
	task.spawn(spawnNewBeartrap)
end)

UserInputService.TouchStarted:Connect(function(_, processed)
	if not processed then
		task.spawn(spawnNewBeartrap)
	end
end)

----------------------------------------------------
-- 🏁 Init
----------------------------------------------------
task.spawn(monitorBeartraps)
task.delay(1, setupWeaponAsBeartrap)
