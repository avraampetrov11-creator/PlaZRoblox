-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")
local LocalPlayer = Players.LocalPlayer

-- === Step 1: Build CustomizationStuff container ===
local PlaceholderFolder = ReplicatedStorage.Homework_Related:WaitForChild("Answer_Types")
local Misc = ReplicatedStorage:WaitForChild("Misc")

-- Create CustomizationStuff
Core_Replication:FireServer("Tools", "Add", PlaceholderFolder, Misc)
task.wait(2)

local CustomizationStuff = Misc:FindFirstChild("Answer_Types")
if CustomizationStuff then
	CustomizationStuff.Name = "CustomizationStuff"
	CustomizationStuff:SetAttribute("Type", "Container")

	for _, child in ipairs(CustomizationStuff:GetChildren()) do
		Core_Replication:FireServer("Tools", "Remove", child, CustomizationStuff)
	end
end

-- Accessories folder
Core_Replication:FireServer("Tools", "Add", PlaceholderFolder, CustomizationStuff)
task.wait(2)

local AccessoryFolder = CustomizationStuff:FindFirstChild("Answer_Types")
if AccessoryFolder then
	AccessoryFolder.Name = "Accessories"
	AccessoryFolder:SetAttribute("Type", "Accessories")

	for _, child in ipairs(AccessoryFolder:GetChildren()) do
		Core_Replication:FireServer("Tools", "Remove", child, AccessoryFolder)
	end
end

-- Clothing folder
Core_Replication:FireServer("Tools", "Add", PlaceholderFolder, CustomizationStuff)
task.wait(2)

local ClothingFolder
for _, child in ipairs(CustomizationStuff:GetChildren()) do
	if child:IsA("Folder") and not child:GetAttribute("Type") then
		ClothingFolder = child
		ClothingFolder.Name = "Clothing"
		ClothingFolder:SetAttribute("Type", "Clothing")

		for _, sub in ipairs(ClothingFolder:GetChildren()) do
			Core_Replication:FireServer("Tools", "Remove", sub, ClothingFolder)
		end
	end
end

-- === Step 2: Auto-store accessories & clothing on spawn ===
local function setupInventoryStorage(player)
	local function scanCharacter(char)
		task.wait(1)

		local customization = ReplicatedStorage.Misc:FindFirstChild("CustomizationStuff")
		if not customization then return end

		local accFolder = customization:FindFirstChild("Accessories")
		local clothFolder = customization:FindFirstChild("Clothing")
		if not accFolder or not clothFolder then return end

		-- Accessories
		for _, accessory in ipairs(char:GetChildren()) do
			if accessory:IsA("Accessory") then
				Core_Replication:FireServer("Tools", "Add", accessory, accFolder)
			end
		end

		-- Shirt
		local shirt = char:FindFirstChildOfClass("Shirt")
		if shirt and shirt.ShirtTemplate ~= "" then
			Core_Replication:FireServer("Tools", "Add", shirt, clothFolder)
		end

		-- Pants
		local pants = char:FindFirstChildOfClass("Pants")
		if pants and pants.PantsTemplate ~= "" then
			Core_Replication:FireServer("Tools", "Add", pants, clothFolder)
		end
	end

	player.CharacterAdded:Connect(scanCharacter)
	if player.Character then scanCharacter(player.Character) end
end
setupInventoryStorage(LocalPlayer)

-- === Step 3: ScreenGui setup ===
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

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = mainFrame

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

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 35)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabBar.BorderSizePixel = 0
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

local accessoriesFrame = Instance.new("ScrollingFrame")
accessoriesFrame.Size = UDim2.new(1, -20, 1, -10)
accessoriesFrame.Position = UDim2.new(0, 10, 0, 5)
accessoriesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
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

local clothingFrame = Instance.new("ScrollingFrame")
clothingFrame.Size = UDim2.new(1, -20, 1, -10)
clothingFrame.Position = UDim2.new(0, 10, 0, 5)
clothingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
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

-- === Step 4: Populate GUI from CustomizationStuff ===
local accessoryButtons = {}
local clothingButtons = {}

local function createAccessoryButton(accessory)
	if accessoryButtons[accessory] then return end
	accessoryButtons[accessory] = true

	local button = Instance.new("ImageButton")
	button.Size = UDim2.new(0, 100, 0, 110)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Name = accessory.Name
	button.ScaleType = Enum.ScaleType.Fit
	button.Parent = accessoriesFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = button

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 20)
	label.Position = UDim2.new(0, 5, 1, -25)
	label.BackgroundTransparency = 1
	label.Text = accessory.Name
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextWrapped = true
	label.Parent = button

	local handle = accessory:FindFirstChild("Handle")
	if handle then
		local mesh = handle:FindFirstChildOfClass("SpecialMesh")
		if mesh and mesh.TextureId ~= "" then
			button.Image = mesh.TextureId
		else
			button.Image = "rbxassetid://0"
		end
	else
		button.Image = "rbxassetid://0"
	end

	button.MouseButton1Click:Connect(function()
		local character = LocalPlayer.Character
		if character then
			Core_Replication:FireServer("Tools", "Add", accessory, character)
		end
	end)
end

local function createClothingButton(assetId, className, instance)
	if not assetId or assetId == 0 or clothingButtons[assetId] then return end
	clothingButtons[assetId] = true

	local button = Instance.new("ImageButton")
	button.Size = UDim2.new(0, 120, 0, 150)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Name = tostring(assetId)
	button.ScaleType = Enum.ScaleType.Fit
	button.Parent = clothingFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = button

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 20)
	label.Position = UDim2.new(0, 5, 1, -25)
	label.BackgroundTransparency = 1
	label.Text = className
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextWrapped = true
	label.Parent = button

	button.Image = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", assetId)

	button.MouseButton1Click:Connect(function()
		local character = LocalPlayer.Character
		if not character then return end

		if className == "Shirt" then
			local old = character:FindFirstChildOfClass("Shirt")
			if old and old ~= instance then
				Core_Replication:FireServer("Tools", "Remove", old, character)
				old:Destroy()
			end
		elseif className == "Pants" then
			local old = character:FindFirstChildOfClass("Pants")
			if old and old ~= instance then
				Core_Replication:FireServer("Tools", "Remove", old, character)
				old:Destroy()
			end
		end

		Core_Replication:FireServer("Tools", "Add", instance, character)
	end)
end

-- === Step 5: Load items from CustomizationStuff ===
local function populateFromStorage()
	local customization = ReplicatedStorage.Misc:WaitForChild("CustomizationStuff")
	local accFolder = customization:WaitForChild("Accessories")
	local clothFolder = customization:WaitForChild("Clothing")

	for _, accessory in ipairs(accFolder:GetChildren()) do
		if accessory:IsA("Accessory") then
			createAccessoryButton(accessory)
		end
	end

	for _, item in ipairs(clothFolder:GetChildren()) do
		if item:IsA("Shirt") and item.ShirtTemplate ~= "" then
			local id = tonumber(item.ShirtTemplate:match("%d+"))
			if id then createClothingButton(id, "Shirt", item) end
		elseif item:IsA("Pants") and item.PantsTemplate ~= "" then
			local id = tonumber(item.PantsTemplate:match("%d+"))
			if id then createClothingButton(id, "Pants", item) end
		end
	end
end

populateFromStorage()


