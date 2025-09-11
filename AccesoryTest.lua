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

-- Main frame container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 350)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = screenGui

-- Rounded corners
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Stroke outline
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = mainFrame

-- Title label
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Accessory Panel"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- ScrollingFrame for accessory icons
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 1, -55)
scrollingFrame.Position = UDim2.new(0, 10, 0, 45)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Parent = mainFrame

-- Padding inside scrolling frame
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)
padding.Parent = scrollingFrame

-- Grid layout
local uiGrid = Instance.new("UIGridLayout")
uiGrid.CellSize = UDim2.new(0, 90, 0, 90)
uiGrid.CellPadding = UDim2.new(0, 10, 0, 10)
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
	button.Size = UDim2.new(0, 90, 0, 90)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Name = accessory.Name
	button.Parent = scrollingFrame

	-- Rounded corners
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = button

	-- Button outline
	local btnStroke = Instance.new("UIStroke")
	btnStroke.Thickness = 1.5
	btnStroke.Color = Color3.fromRGB(90, 90, 90)
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.Parent = button

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

	-- Hover effect
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end)

	-- Click connection
	button.MouseButton1Click:Connect(function()
		local character = LocalPlayer.Character
		if character then
			Core_Replication:FireServer("Tools", "Add", accessory, character)
		end
	end)
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

