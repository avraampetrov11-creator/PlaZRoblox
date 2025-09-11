-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")

local LocalPlayer = Players.LocalPlayer

-- // UI SETUP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccessoryPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Scrollable container
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(0, 420, 0, 320)
scrollingFrame.Position = UDim2.new(0, 20, 0, 100)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scrollingFrame.BackgroundTransparency = 0.2
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = scrollingFrame

-- Stroke outline
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.5
stroke.Parent = scrollingFrame

-- Grid layout for accessories
local uiGrid = Instance.new("UIGridLayout")
uiGrid.CellSize = UDim2.new(0, 90, 0, 90)
uiGrid.CellPadding = UDim2.new(0, 6, 0, 6)
uiGrid.FillDirectionMaxCells = 4
uiGrid.SortOrder = Enum.SortOrder.LayoutOrder
uiGrid.Parent = scrollingFrame

-- Keep track of created buttons
local accessoryButtons = {}

-- Function to create a styled button
local function createAccessoryButton(accessory)
	if accessoryButtons[accessory] then return end
	accessoryButtons[accessory] = true

	local button = Instance.new("ImageButton")
	button.Size = UDim2.new(0, 90, 0, 90)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.BackgroundTransparency = 0.1
	button.Name = accessory.Name

	-- Rounded button
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = button

	-- Stroke for button
	local btnStroke = Instance.new("UIStroke")
	btnStroke.Thickness = 1.5
	btnStroke.Color = Color3.fromRGB(255, 255, 255)
	btnStroke.Transparency = 0.5
	btnStroke.Parent = button

	-- Set image from mesh texture if available
	local handle = accessory:FindFirstChild("Handle")
	if handle and handle:FindFirstChildOfClass("SpecialMesh") then
		local mesh = handle:FindFirstChildOfClass("SpecialMesh")
		if mesh.TextureId ~= "" then
			button.Image = mesh.TextureId
		else
			button.Image = "rbxassetid://0"
		end
	else
		button.Image = "rbxassetid://0"
	end

	-- Click event
	button.MouseButton1Click:Connect(function()
		local character = LocalPlayer.Character
		if character then
			Core_Replication:FireServer("Tools", "Add", accessory, character)
		end
	end)

	button.Parent = scrollingFrame
end

-- Add accessories from a player
local function addPlayerAccessories(player)
	local function scanChar(char)
		task.wait(1) -- wait for load
		for _, accessory in ipairs(char:GetChildren()) do
			if accessory:IsA("Accessory") then
				createAccessoryButton(accessory)
			end
		end
	end

	player.CharacterAdded:Connect(scanChar)
	if player.Character then
		scanChar(player.Character)
	end
end

-- Hook existing + new players
for _, player in ipairs(Players:GetPlayers()) do
	addPlayerAccessories(player)
end
Players.PlayerAdded:Connect(addPlayerAccessories)
