-- Put this script in ServerScriptService

local accessoryId = 84285572503442 -- replace with your accessory's ID

local function giveAccessory(player)
	local success, accessory = pcall(function()
		return game:GetService("InsertService"):LoadAsset(accessoryId)
	end)

	if success and accessory then
		-- Find the accessory inside the inserted model
		local acc = accessory:FindFirstChildWhichIsA("Accessory")
		if acc then
			-- Wait for character to load
			player.CharacterAdded:Connect(function(char)
				local newAcc = acc:Clone()
				newAcc.Parent = char
			end)
			
			-- If character already exists (player already spawned), add it
			if player.Character then
				local newAcc = acc:Clone()
				newAcc.Parent = player.Character
			end
		end
		accessory:Destroy()
	else
		warn("Failed to load accessory with ID:", accessoryId)
	end
end

-- Give accessory when players join
game.Players.PlayerAdded:Connect(giveAccessory)

-- Also give to players already in-game (if script is added while running)
for _, player in pairs(game.Players:GetPlayers()) do
	giveAccessory(player)
end
