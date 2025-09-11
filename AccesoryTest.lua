-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")

local LocalPlayer = Players.LocalPlayer

-- ScreenGui setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryPanel"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main frame container
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

-- Title bar
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

-- Tab buttons
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

-- Container for tab contents
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -75)
contentFrame.Position = UDim2.new(0, 0, 0, 75)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- === Accessories Tab ===
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

-- === Clothing Tab ===
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

-- ===== ACCESSORIES =====
local accessoryButtons = {}

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

	-- Use mesh texture instead of Roblox thumbnails
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

local function addPlayerAccessories(player)
	local function scan(char)
		task.wait(1)
		for _, accessory in ipairs(char:GetChildren()) do
			if accessory:IsA("Accessory") then
				createAccessoryButton(accessory)
			end
		end
	end
	player.CharacterAdded:Connect(scan)
	if player.Character then scan(player.Character) end
end

local function scanReplicatedStorageAccessories()
	for _, accessory in ipairs(ReplicatedStorage:GetDescendants()) do
		if accessory:IsA("Accessory") then
			createAccessoryButton(accessory)
		end
	end
end

-- ===== CLOTHING =====
local clothingButtons = {}

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

		-- Remove old clothing of same type
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

		-- Equip new
		Core_Replication:FireServer("Tools", "Add", instance, character)
	end)
end

local function addPlayerClothing(player)
	local function scanClothing(char)
		task.wait(1)
		local shirt = char:FindFirstChildOfClass("Shirt")
		local pants = char:FindFirstChildOfClass("Pants")

		if shirt and shirt.ShirtTemplate ~= "" then
			local id = tonumber(shirt.ShirtTemplate:match("%d+"))
			if id then createClothingButton(id, "Shirt", shirt) end
		end
		if pants and pants.PantsTemplate ~= "" then
			local id = tonumber(pants.PantsTemplate:match("%d+"))
			if id then createClothingButton(id, "Pants", pants) end
		end
	end
	player.CharacterAdded:Connect(scanClothing)
	if player.Character then scanClothing(player.Character) end
end

local function scanReplicatedStorageClothing()
	for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
		if item:IsA("Shirt") and item.ShirtTemplate ~= "" then
			local id = tonumber(item.ShirtTemplate:match("%d+"))
			if id then createClothingButton(id, "Shirt", item) end
		elseif item:IsA("Pants") and item.PantsTemplate ~= "" then
			local id = tonumber(item.PantsTemplate:match("%d+"))
			if id then createClothingButton(id, "Pants", item) end
		end
	end
end

-- Hook up players
for _, player in ipairs(Players:GetPlayers()) do
	addPlayerAccessories(player)
	addPlayerClothing(player)
end
Players.PlayerAdded:Connect(function(player)
	addPlayerAccessories(player)
	addPlayerClothing(player)
end)

-- Scan ReplicatedStorage
scanReplicatedStorageAccessories()
scanReplicatedStorageClothing()



