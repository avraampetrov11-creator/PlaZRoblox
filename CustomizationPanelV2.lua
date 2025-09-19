-- LocalScript (StarterPlayerScripts)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")
local LocalPlayer = Players.LocalPlayer

-- === Helper Functions ===
local function waitForChild(parent, childName, timeout)
	timeout = timeout or 5
	local start = tick()
	local child = parent:FindFirstChild(childName)
	while not child and (tick() - start) < timeout do
		child = parent:FindFirstChild(childName)
		task.wait(0.1)
	end
	return child
end

local function safeFireServer(...)
	local success, err = pcall(Core_Replication.FireServer, Core_Replication, ...)
	if not success then
		warn("Failed to FireServer: " .. tostring(err))
	end
end

-- === Step 1: Build CustomizationStuff container ===
local PlaceholderFolder = ReplicatedStorage.Homework_Related:WaitForChild("Answer_Types")
local Misc = ReplicatedStorage:WaitForChild("Misc")

-- Create main container
safeFireServer("Tools", "Add", PlaceholderFolder, Misc)
local CustomizationStuff = waitForChild(Misc, "Answer_Types")
if CustomizationStuff then
	CustomizationStuff.Name = "CustomizationStuff"  -- Rename for clarity
	CustomizationStuff:SetAttribute("Type", "Container")
	for _, child in ipairs(CustomizationStuff:GetChildren()) do
		safeFireServer("Tools", "Remove", child, CustomizationStuff)
	end
end

-- Create Accessories folder
if CustomizationStuff then
	safeFireServer("Tools", "Add", PlaceholderFolder, CustomizationStuff)
	local AccessoryFolder = waitForChild(CustomizationStuff, "Answer_Types")
	if AccessoryFolder then
		AccessoryFolder.Name = "Accessories"
		AccessoryFolder:SetAttribute("Type", "Accessories")
		for _, sub in ipairs(AccessoryFolder:GetChildren()) do
			safeFireServer("Tools", "Remove", sub, AccessoryFolder)
		end
	end

	-- Create Clothing folder
	safeFireServer("Tools", "Add", PlaceholderFolder, CustomizationStuff)
	local ClothingFolder = waitForChild(CustomizationStuff, "Answer_Types")
	if ClothingFolder then
		ClothingFolder.Name = "Clothing"
		ClothingFolder:SetAttribute("Type", "Clothing")
		for _, sub in ipairs(ClothingFolder:GetChildren()) do
			safeFireServer("Tools", "Remove", sub, ClothingFolder)
		end
	end
end

-- === Step 2: Save Character Stuff ===
local function saveCharacterStuff(char, AccessoryFolder, ClothingFolder)
	task.wait(1)  -- Short wait for character to fully load
	if not AccessoryFolder or not ClothingFolder then return end

	-- Save accessories
	for _, accessory in ipairs(char:GetChildren()) do
		if accessory:IsA("Accessory") then
			local handle = accessory:FindFirstChild("Handle")
			local mesh = handle and handle:FindFirstChildOfClass("SpecialMesh")
			local meshId = mesh and mesh.MeshId or ""
			local textureId = mesh and mesh.TextureId or ""
			-- Check if exists
			local exists = false
			for _, existing in ipairs(AccessoryFolder:GetChildren()) do
				if existing:IsA("Accessory") then
					local ehandle = existing:FindFirstChild("Handle")
					local emesh = ehandle and ehandle:FindFirstChildOfClass("SpecialMesh")
					if emesh and emesh.MeshId == meshId and emesh.TextureId == textureId then
						exists = true
						break
					end
				end
			end
			if not exists then
				safeFireServer("Tools", "Add", accessory, AccessoryFolder)
			end
		end
	end

	-- Save shirt
	local shirt = char:FindFirstChildOfClass("Shirt")
	if shirt and shirt.ShirtTemplate ~= "" then
		local exists = false
		for _, existing in ipairs(ClothingFolder:GetChildren()) do
			if existing:IsA("Shirt") and existing.ShirtTemplate == shirt.ShirtTemplate then
				exists = true
				break
			end
		end
		if not exists then
			safeFireServer("Tools", "Add", shirt, ClothingFolder)
		end
	end

	-- Save pants
	local pants = char:FindFirstChildOfClass("Pants")
	if pants and pants.PantsTemplate ~= "" then
		local exists = false
		for _, existing in ipairs(ClothingFolder:GetChildren()) do
			if existing:IsA("Pants") and existing.PantsTemplate == pants.PantsTemplate then
				exists = true
				break
			end
		end
		if not exists then
			safeFireServer("Tools", "Add", pants, ClothingFolder)
		end
	end
end

-- Connect for all players
local AccessoryFolder = CustomizationStuff and CustomizationStuff:FindFirstChild("Accessories")
local ClothingFolder = CustomizationStuff and CustomizationStuff:FindFirstChild("Clothing")

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function(char)
		saveCharacterStuff(char, AccessoryFolder, ClothingFolder)
	end)
	if player.Character then
		saveCharacterStuff(player.Character, AccessoryFolder, ClothingFolder)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		saveCharacterStuff(char, AccessoryFolder, ClothingFolder)
	end)
	if player.Character then
		saveCharacterStuff(player.Character, AccessoryFolder, ClothingFolder)
	end
end)

-- === Step 3: GUI Setup ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryPanel"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -140, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Inventory"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeButton = Instance.new("TextButton", titleBar)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)
closeButton.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)

-- Target Player Selector
local targetPlayer = LocalPlayer
local targetLabel = Instance.new("TextLabel", titleBar)
targetLabel.Size = UDim2.new(0, 140, 1, 0)
targetLabel.Position = UDim2.new(1, -180, 0, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Target: " .. LocalPlayer.Name
targetLabel.Font = Enum.Font.Gotham
targetLabel.TextSize = 16
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLabel.TextXAlignment = Enum.TextXAlignment.Right

local targetButton = Instance.new("TextButton", titleBar)
targetButton.Size = UDim2.new(0, 140, 1, 0)
targetButton.Position = UDim2.new(1, -180, 0, 0)
targetButton.BackgroundTransparency = 1
targetButton.Text = ""

local playersListFrame = Instance.new("ScrollingFrame", mainFrame)
playersListFrame.Size = UDim2.new(1, 0, 0, 100)
playersListFrame.Position = UDim2.new(0, 0, 0, 40)
playersListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
playersListFrame.Visible = false
playersListFrame.ScrollBarThickness = 6
playersListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playersListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local playersGrid = Instance.new("UIGridLayout", playersListFrame)
playersGrid.CellSize = UDim2.new(1, 0, 0, 30)
playersGrid.CellPadding = UDim2.new(0, 0, 0, 5)

local function updatePlayersList()
	for _, child in ipairs(playersListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton", playersListFrame)
		btn.Text = player.Name
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 16
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		btn.MouseButton1Click:Connect(function()
			targetPlayer = player
			targetLabel.Text = "Target: " .. player.Name
			playersListFrame.Visible = false
		end)
	end
	playersGrid:ApplyLayout()
end

updatePlayersList()

Players.PlayerAdded:Connect(updatePlayersList)
Players.PlayerRemoving:Connect(updatePlayersList)

targetButton.MouseButton1Click:Connect(function()
	playersListFrame.Visible = not playersListFrame.Visible
	if playersListFrame.Visible then
		updatePlayersList()
	end
end)

-- Tabs
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 35)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local accessoriesTab = Instance.new("TextButton", tabBar)
accessoriesTab.Size = UDim2.new(0.5, 0, 1, 0)
accessoriesTab.Text = "Accessories"
accessoriesTab.Font = Enum.Font.GothamBold
accessoriesTab.TextSize = 16
accessoriesTab.TextColor3 = Color3.fromRGB(255, 255, 255)
accessoriesTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local clothingTab = Instance.new("TextButton", tabBar)
clothingTab.Size = UDim2.new(0.5, 0, 1, 0)
clothingTab.Position = UDim2.new(0.5, 0, 0, 0)
clothingTab.Text = "Clothing"
clothingTab.Font = Enum.Font.GothamBold
clothingTab.TextSize = 16
clothingTab.TextColor3 = Color3.fromRGB(255, 255, 255)
clothingTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -75)
contentFrame.Position = UDim2.new(0, 0, 0, 75)
contentFrame.BackgroundTransparency = 1

-- Adjust content position if players list is visible
playersListFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if playersListFrame.Visible then
		tabBar.Position = UDim2.new(0, 0, 0, 140)
		contentFrame.Position = UDim2.new(0, 0, 0, 175)
		contentFrame.Size = UDim2.new(1, 0, 1, -175)
	else
		tabBar.Position = UDim2.new(0, 0, 0, 40)
		contentFrame.Position = UDim2.new(0, 0, 0, 75)
		contentFrame.Size = UDim2.new(1, 0, 1, -75)
	end
end)

-- Accessories Frame
local accessoriesFrame = Instance.new("ScrollingFrame", contentFrame)
accessoriesFrame.Size = UDim2.new(1, -20, 1, -10)
accessoriesFrame.Position = UDim2.new(0, 10, 0, 5)
accessoriesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
accessoriesFrame.ScrollBarThickness = 8
accessoriesFrame.BackgroundTransparency = 1
accessoriesFrame.Active = true

local accGrid = Instance.new("UIGridLayout", accessoriesFrame)
accGrid.CellSize = UDim2.new(0, 100, 0, 100)
accGrid.CellPadding = UDim2.new(0, 10, 0, 10)
accGrid.FillDirectionMaxCells = 4
accGrid.SortOrder = Enum.SortOrder.Name

-- Clothing Frame
local clothingFrame = Instance.new("ScrollingFrame", contentFrame)
clothingFrame.Size = UDim2.new(1, -20, 1, -10)
clothingFrame.Position = UDim2.new(0, 10, 0, 5)
clothingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
clothingFrame.ScrollBarThickness = 8
clothingFrame.BackgroundTransparency = 1
clothingFrame.Active = true
clothingFrame.Visible = false

local clothGrid = Instance.new("UIGridLayout", clothingFrame)
clothGrid.CellSize = UDim2.new(0, 120, 0, 120)
clothGrid.CellPadding = UDim2.new(0, 10, 0, 10)
clothGrid.FillDirectionMaxCells = 3
clothGrid.SortOrder = Enum.SortOrder.Name

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

	local button = Instance.new("ImageButton", accessoriesFrame)
	button.Name = accessory.Name
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

	-- Improved preview using ViewportFrame for 3D render
	local viewport = Instance.new("ViewportFrame", button)
	viewport.Size = UDim2.new(1, 0, 1, 0)
	viewport.BackgroundTransparency = 1
	local clone = accessory:Clone()
	clone.Parent = viewport
	local camera = Instance.new("Camera", viewport)
	viewport.CurrentCamera = camera
	local handle = clone:FindFirstChild("Handle")
	if handle then
		camera.CFrame = CFrame.new(handle.Position + Vector3.new(0, 0, 3), handle.Position)
	end

	button.MouseButton1Click:Connect(function()
		local char = targetPlayer.Character
		if not char then return end

		-- Check if already wearing
		local wearing = false
		local toRemove
		for _, acc in ipairs(char:GetChildren()) do
			if acc:IsA("Accessory") then
				local h = acc:FindFirstChild("Handle")
				local m = h and h:FindFirstChildOfClass("SpecialMesh")
				local meshId = m and m.MeshId or ""
				local textureId = m and m.TextureId or ""
				local origMesh = accessory:FindFirstChild("Handle"):FindFirstChildOfClass("SpecialMesh")
				local origMeshId = origMesh and origMesh.MeshId or ""
				local origTextureId = origMesh and origMesh.TextureId or ""
				if meshId == origMeshId and textureId == origTextureId then
					wearing = true
					toRemove = acc
					break
				end
			end
		end

		if wearing then
			safeFireServer("Tools", "Remove", toRemove, char)
		else
			safeFireServer("Tools", "Add", accessory, char)
		end
	end)
	
	accGrid:ApplyLayout()
end

local function createClothingButton(item)
	if not (item:IsA("Shirt") or item:IsA("Pants")) then return end

	local button = Instance.new("ImageButton", clothingFrame)
	button.Name = item.Name
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

	-- Thumbnail preview
	local id
	if item:IsA("Shirt") then
		id = tonumber(item.ShirtTemplate:match("%d+")) or 0
	elseif item:IsA("Pants") then
		id = tonumber(item.PantsTemplate:match("%d+")) or 0
	end
	button.Image = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", id)

	button.MouseButton1Click:Connect(function()
		local char = targetPlayer.Character
		if not char then return end

		-- Remove old of same type
		local class = item.ClassName
		local old = char:FindFirstChildOfClass(class)
		if old then
			safeFireServer("Tools", "Remove", old, char)
		end

		safeFireServer("Tools", "Add", item, char)
	end)
	
	clothGrid:ApplyLayout()
end

-- Watch for stored items
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

-- Additional ClothesFolder scanning (assuming it's a pre-populated folder)
local ClothesFolder = Misc:WaitForChild("Clothes")

local function scanClothesFolder(folder)
	for _, item in ipairs(folder:GetDescendants()) do
		if item:IsA("Shirt") or item:IsA("Pants") then
			-- Check if already in ClothingFolder to avoid duplicates
			local exists = false
			for _, existing in ipairs(clothingFrame:GetChildren()) do
				if existing:IsA("ImageButton") and existing.Name == item.Name then
					exists = true
					break
				end
			end
			if not exists then
				createClothingButton(item)
			end
		end
	end
end

-- Initial scan
scanClothesFolder(ClothesFolder)

-- Watch for new items added in runtime
ClothesFolder.DescendantAdded:Connect(function(item)
	if item:IsA("Shirt") or item:IsA("Pants") then
		createClothingButton(item)
	end
end)

-- Toggle GUI with hotkey (e.g., 'I')
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		screenGui.Enabled = not screenGui.Enabled
	end
end)
