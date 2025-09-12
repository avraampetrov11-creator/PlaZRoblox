-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")
local LocalPlayer = Players.LocalPlayer

-- === Step 1: Build CustomizationStuff container ===
local PlaceholderFolder = ReplicatedStorage.Homework_Related:WaitForChild("Answer_Types")
local Misc = ReplicatedStorage:WaitForChild("Misc")

-- Create main container
Core_Replication:FireServer("Tools", "Add", PlaceholderFolder, Misc)
task.wait(2)

local CustomizationStuff = Misc:FindFirstChild("Answer_Types")
if CustomizationStuff then
	CustomizationStuff:SetAttribute("Type", "Container")
	for _, child in ipairs(CustomizationStuff:GetChildren()) do
		Core_Replication:FireServer("Tools", "Remove", child, CustomizationStuff)
	end
end

-- Create Accessories
Core_Replication:FireServer("Tools", "Add", PlaceholderFolder, CustomizationStuff)
task.wait(2)
local AccessoryFolder
for _, child in ipairs(CustomizationStuff:GetChildren()) do
	if child:IsA("Folder") and not child:GetAttribute("Type") then
		AccessoryFolder = child
		AccessoryFolder:SetAttribute("Type", "Accessories")
		for _, sub in ipairs(AccessoryFolder:GetChildren()) do
			Core_Replication:FireServer("Tools", "Remove", sub, AccessoryFolder)
		end
	end
end

-- Create Clothing
Core_Replication:FireServer("Tools", "Add", PlaceholderFolder, CustomizationStuff)
task.wait(2)
local ClothingFolder
for _, child in ipairs(CustomizationStuff:GetChildren()) do
	if child:IsA("Folder") and not child:GetAttribute("Type") then
		ClothingFolder = child
		ClothingFolder:SetAttribute("Type", "Clothing")
		for _, sub in ipairs(ClothingFolder:GetChildren()) do
			Core_Replication:FireServer("Tools", "Remove", sub, ClothingFolder)
		end
	end
end

-- === Step 2: Save Character Stuff ===
local function saveCharacterStuff(char)
	task.wait(1)
	if not AccessoryFolder or not ClothingFolder then return end

	-- Save accessories
	for _, accessory in ipairs(char:GetChildren()) do
		if accessory:IsA("Accessory") then
			Core_Replication:FireServer("Tools", "Add", accessory, AccessoryFolder)
		end
	end

	-- Save shirt
	local shirt = char:FindFirstChildOfClass("Shirt")
	if shirt and shirt.ShirtTemplate ~= "" then
		Core_Replication:FireServer("Tools", "Add", shirt, ClothingFolder)
	end

	-- Save pants
	local pants = char:FindFirstChildOfClass("Pants")
	if pants and pants.PantsTemplate ~= "" then
		Core_Replication:FireServer("Tools", "Add", pants, ClothingFolder)
	end
end

LocalPlayer.CharacterAdded:Connect(saveCharacterStuff)
if LocalPlayer.Character then saveCharacterStuff(LocalPlayer.Character) end

-- === Step 3: GUI Setup ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryPanel"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -140, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Inventory"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Tabs
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 35)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabBar.Parent = mainFrame

local accessoriesTab = Instance.new("TextButton")
accessoriesTab.Size = UDim2.new(0.5, 0, 1, 0)
accessoriesTab.Text = "Accessories"
accessoriesTab.Font = Enum.Font.GothamBold
accessoriesTab.TextSize = 16
accessoriesTab.TextColor3 = Color3.fromRGB(255, 255, 255)
accessoriesTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
accessoriesTab.Parent = tabBar

local clothingTab = Instance.new("TextButton")
clothingTab.Size = UDim2.new(0.5, 0, 1, 0)
clothingTab.Position = UDim2.new(0.5, 0, 0, 0)
clothingTab.Text = "Clothing"
clothingTab.Font = Enum.Font.GothamBold
clothingTab.TextSize = 16
clothingTab.TextColor3 = Color3.fromRGB(255, 255, 255)
clothingTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
clothingTab.Parent = tabBar

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -75)
contentFrame.Position = UDim2.new(0, 0, 0, 75)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Accessories Frame
local accessoriesFrame = Instance.new("ScrollingFrame")
accessoriesFrame.Size = UDim2.new(1, -20, 1, -10)
accessoriesFrame.Position = UDim2.new(0, 10, 0, 5)
accessoriesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
accessoriesFrame.ScrollBarThickness = 8
accessoriesFrame.BackgroundTransparency = 1
accessoriesFrame.Active = true
accessoriesFrame.Parent = contentFrame

local accGrid = Instance.new("UIGridLayout")
accGrid.CellSize = UDim2.new(0, 100, 0, 110)
accGrid.CellPadding = UDim2.new(0, 10, 0, 10)
accGrid.FillDirectionMaxCells = 4
accGrid.SortOrder = Enum.SortOrder.LayoutOrder
accGrid.Parent = accessoriesFrame

-- Clothing Frame
local clothingFrame = Instance.new("ScrollingFrame")
clothingFrame.Size = UDim2.new(1, -20, 1, -10)
clothingFrame.Position = UDim2.new(0, 10, 0, 5)
clothingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
clothingFrame.ScrollBarThickness = 8
clothingFrame.BackgroundTransparency = 1
clothingFrame.Active = true
clothingFrame.Visible = false
clothingFrame.Parent = contentFrame

local clothGrid = Instance.new("UIGridLayout")
clothGrid.CellSize = UDim2.new(0, 120, 0, 150)
clothGrid.CellPadding = UDim2.new(0, 10, 0, 10)
clothGrid.FillDirectionMaxCells = 3
clothGrid.SortOrder = Enum.SortOrder.LayoutOrder
clothGrid.Parent = clothingFrame

-- Tab switching
accessoriesTab.MouseButton1Click:Connect(function()
	accessoriesTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	clothingTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	accessoriesFrame.Visible = true
	clothingFrame.Visible = false
end)

clothingTab.MouseButton1Click:Connect(function()
	clothingTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	accessoriesTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	clothingFrame.Visible = true
	accessoriesFrame.Visible = false
end)

-- === Build Buttons from Stored Items ===
local function createAccessoryButton(accessory)
	if not accessory:IsA("Accessory") then return end

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 100, 0, 110)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Text = accessory.Name
	button.TextColor3 = Color3.new(1,1,1)
	button.Parent = accessoriesFrame

	button.MouseButton1Click:Connect(function()
		local char = LocalPlayer.Character
		if char then
			Core_Replication:FireServer("Tools", "Add", accessory, char)
		end
	end)
end

local function createClothingButton(item)
	if not (item:IsA("Shirt") or item:IsA("Pants")) then return end

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 120, 0, 150)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Text = item.ClassName
	button.TextColor3 = Color3.new(1,1,1)
	button.Parent = clothingFrame

	button.MouseButton1Click:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		Core_Replication:FireServer("Tools", "Add", item, char)
	end)
end

-- Watch for new accessories/clothing being stored
if AccessoryFolder then
	for _, child in ipairs(AccessoryFolder:GetChildren()) do
		createAccessoryButton(child)
	end
	AccessoryFolder.ChildAdded:Connect(createAccessoryButton)
end

if ClothingFolder then
	for _, child in ipairs(ClothingFolder:GetChildren()) do
		createClothingButton(child)
	end
	ClothingFolder.ChildAdded:Connect(createClothingButton)
end



