-- ServerScriptService Script
local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIG
local accessoryId = 84285572503442 -- replace with your accessory ID
local remoteName = "GiveAccessoryEvent"

-- Create RemoteEvent if not already there
local remote = ReplicatedStorage:FindFirstChild(remoteName)
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = remoteName
	remote.Parent = ReplicatedStorage
end

-- Try to load the accessory
local function loadAccessory()
	local ok, modelOrErr = pcall(function()
		return InsertService:LoadAsset(accessoryId)
	end)

	if not ok then
		warn("Error loading accessory ID:", accessoryId, "—", modelOrErr)
		return nil
	end

	local acc = modelOrErr:FindFirstChildWhichIsA("Accessory")
	if not acc then
		modelOrErr:Destroy()
		warn("Accessory not found inside asset:", accessoryId)
		return nil
	end

	local clone = acc:Clone()
	modelOrErr:Destroy()
	return clone
end

local template = loadAccessory()
if not template then
	warn("Accessory template could not be created.")
end

-- Function to give accessory to character
local function giveAccessory(player, character)
	if not template then return end

	local success, err = pcall(function()
		local newAcc = template:Clone()
		newAcc.Parent = character
	end)

	if not success then
		warn("Failed to attach accessory to", player.Name, ":", err)
	end
end

-- Hook up players
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		giveAccessory(player, char)
	end)
	if player.Character then
		giveAccessory(player, player.Character)
	end
end)

-- RemoteEvent: let clients request accessory again manually
remote.OnServerEvent:Connect(function(player)
	if player.Character then
		giveAccessory(player, player.Character)
	end
end)

