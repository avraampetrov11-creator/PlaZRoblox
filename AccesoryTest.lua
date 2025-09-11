-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")

local LocalPlayer = Players.LocalPlayer

-- ScreenGui setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccessoryPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ScrollingFrame for accessory icons
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(0, 400, 0, 300)
scrollingFrame.Position = UDim2.new(0, 20, 0, 100)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scrollingFrame.Parent = screenGui

local uiGrid = Instance.new("UIGridLayout")
uiGrid.CellSize = UDim2.new(0, 80, 0, 80)
uiGrid.FillDirectionMaxCells = 4
uiGrid.SortOrder = Enum.SortOrder.LayoutOrder
uiGrid.Parent = scrollingFrame

-- Store accessories we've already added
local accessoryButtons = {}

-- Function to create a button for an accessory
local function createAccessoryButton(accessory)
	if accessoryButtons[accessory] then return end -- prevent duplicates
	accessoryButtons[accessory] = true

	local button = Instance.new("ImageButton")
	button.Size = UDim2.new(0, 80, 0, 80)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.Name = accessory.Name

	-- Try using the accessory thumbnail (if it has an asset id)
	local handle = accessory:FindFirstChild("Handle")
	if handle and handle:FindFirstChildOfClass("SpecialMesh") then
		local mesh = handle:FindFirstChildOfClass("SpecialMesh")
		if mesh.TextureId ~= "" then
			button.Image = mesh.TextureId
		else
			button.Image = "rbxassetid://0" -- fallback
		end
	else
		button.Image = "rbxassetid://0" -- fallback
	end

	-- Click connection
	button.MouseButton1Click:Connect(function()
		local character = LocalPlayer.Character
		if character then
			Core_Replication:FireServer("Tools", "Add", accessory, character)
		end
	end)

	button.Parent = scrollingFrame
end

-- Function to get a player’s accessories
local function addPlayerAccessories(player)
	player.CharacterAdded:Connect(function(char)
		task.wait(1) -- give time to load
		for _, accessory in ipairs(char:GetChildren()) do
			if accessory:IsA("Accessory") then
				createAccessoryButton(accessory)
			end
		end
	end)

	if player.Character then
		for _, accessory in ipairs(player.Character:GetChildren()) do
			if accessory:IsA("Accessory") then
				createAccessoryButton(accessory)
			end
		end
	end
end

-- Hook up existing players
for _, player in ipairs(Players:GetPlayers()) do
	addPlayerAccessories(player)
end

-- Listen for new players
Players.PlayerAdded:Connect(addPlayerAccessories)
