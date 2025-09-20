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

	local player = Players:GetPlayerFromCharacter(char)
	if not player then return end

	-- Save accessories (unchanged, flat list)
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

	-- Create or get player-specific clothing subfolder
	local playerClothingFolder = ClothingFolder:FindFirstChild(player.Name)
	if not playerClothingFolder then
		safeFireServer("Tools", "Add", PlaceholderFolder, ClothingFolder)
		playerClothingFolder = waitForChild(ClothingFolder, "Answer_Types")
		if playerClothingFolder then
			playerClothingFolder.Name = player.Name
		end
	end

	if playerClothingFolder then
		-- Save shirt
		local shirt = char:FindFirstChildOfClass("Shirt")
		if shirt and shirt.ShirtTemplate ~= "" then
			local exists = false
			for _, existing in ipairs(playerClothingFolder:GetChildren()) do
				if existing:IsA("Shirt") and existing.ShirtTemplate == shirt.ShirtTemplate then
					exists = true
					break
				end
			end
			if not exists then
				safeFireServer("Tools", "Add", shirt, playerClothingFolder)
			end
		end

		-- Save pants
		local pants = char:FindFirstChildOfClass("Pants")
		if pants and pants.PantsTemplate ~= "" then
			local exists = false
			for _, existing in ipairs(playerClothingFolder:GetChildren()) do
				if existing:IsA("Pants") and existing.PantsTemplate == pants.PantsTemplate then
					exists = true
					break
				end
			end
			if not exists then
				safeFireServer("Tools", "Add", pants, playerClothingFolder)
			end
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

-- Target Player Selector for Main GUI
local mainTargetPlayer = LocalPlayer
local mainTargetLabel = Instance.new("TextLabel", titleBar)
mainTargetLabel.Size = UDim2.new(0, 140, 1, 0)
mainTargetLabel.Position = UDim2.new(1, -180, 0, 0)
mainTargetLabel.BackgroundTransparency = 1
mainTargetLabel.Text = "Target: " .. LocalPlayer.Name
mainTargetLabel.Font = Enum.Font.Gotham
mainTargetLabel.TextSize = 16
mainTargetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
mainTargetLabel.TextXAlignment = Enum.TextXAlignment.Right

local mainTargetButton = Instance.new("TextButton", titleBar)
mainTargetButton.Size = UDim2.new(0, 140, 1, 0)
mainTargetButton.Position = UDim2.new(1, -180, 0, 0)
mainTargetButton.BackgroundTransparency = 1
mainTargetButton.Text = ""

local mainPlayersListFrame = Instance.new("ScrollingFrame", mainFrame)
mainPlayersListFrame.Size = UDim2.new(1, 0, 0, 100)
mainPlayersListFrame.Position = UDim2.new(0, 0, 0, 40)
mainPlayersListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainPlayersListFrame.Visible = false
mainPlayersListFrame.ScrollBarThickness = 6
mainPlayersListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
mainPlayersListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local mainPlayersGrid = Instance.new("UIGridLayout", mainPlayersListFrame)
mainPlayersGrid.CellSize = UDim2.new(1, 0, 0, 30)
mainPlayersGrid.CellPadding = UDim2.new(0, 0, 0, 5)

local function updateMainPlayersList()
	for _, child in ipairs(mainPlayersListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton", mainPlayersListFrame)
		btn.Text = player.Name
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 16
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		btn.MouseButton1Click:Connect(function()
			mainTargetPlayer = player
			mainTargetLabel.Text = "Target: " .. player.Name
			mainPlayersListFrame.Visible = false
		end)
	end
	mainPlayersGrid:ApplyLayout()
end

updateMainPlayersList()

Players.PlayerAdded:Connect(updateMainPlayersList)
Players.PlayerRemoving:Connect(updateMainPlayersList)

mainTargetButton.MouseButton1Click:Connect(function()
	mainPlayersListFrame.Visible = not mainPlayersListFrame.Visible
	if mainPlayersListFrame.Visible then
		updateMainPlayersList()
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
mainPlayersListFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if mainPlayersListFrame.Visible then
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
clothGrid.CellSize = UDim2.new(0, 120, 0, 140)  -- Increased height for label
clothGrid.CellPadding = UDim2.new(0, 10, 0, 10)
clothGrid.FillDirectionMaxCells = 3
clothGrid.SortOrder = Enum.SortOrder.LayoutOrder

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
		local char = mainTargetPlayer.Character
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

local function updateClothingButtonsOrder()
	local buttons = {}
	for _, child in ipairs(clothingFrame:GetChildren()) do
		if child:IsA("ImageButton") then
			table.insert(buttons, child)
		end
	end
	
	table.sort(buttons, function(a, b)
		local fromA = a:GetAttribute("FromCharacter") or "Unknown"
		local fromB = b:GetAttribute("FromCharacter") or "Unknown"
		if fromA ~= fromB then
			return fromA < fromB
		end
		
		local isShirtA = a:GetAttribute("IsShirt")
		local isShirtB = b:GetAttribute("IsShirt")
		if isShirtA ~= isShirtB then
			return isShirtA  -- Shirts before pants
		end
		
		return a.Name < b.Name
	end)
	
	for i, btn in ipairs(buttons) do
		btn.LayoutOrder = i
	end
end

local function createClothingButton(item, fromCharacter)
	if not (item:IsA("Shirt") or item:IsA("Pants")) then return end

	local button = Instance.new("ImageButton", clothingFrame)
	button.Name = item.Name
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
	button:SetAttribute("FromCharacter", fromCharacter or "Unknown")
	button:SetAttribute("IsShirt", item:IsA("Shirt"))

	-- Thumbnail preview
	local id
	if item:IsA("Shirt") then
		id = tonumber(item.ShirtTemplate:match("%d+")) or 0
	elseif item:IsA("Pants") then
		id = tonumber(item.PantsTemplate:match("%d+")) or 0
	end
	button.Image = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", id)

	-- Add from label
	local fromLabel = Instance.new("TextLabel", button)
	fromLabel.Size = UDim2.new(1, 0, 0, 20)
	fromLabel.Position = UDim2.new(0, 0, 1, -20)
	fromLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	fromLabel.BackgroundTransparency = 0.5
	fromLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	fromLabel.Text = "From: " .. (fromCharacter or "Unknown")
	fromLabel.Font = Enum.Font.Gotham
	fromLabel.TextSize = 12
	fromLabel.TextTruncate = Enum.TextTruncate.SplitWord
	Instance.new("UICorner", fromLabel).CornerRadius = UDim.new(0, 5)

	button.MouseButton1Click:Connect(function()
		local char = mainTargetPlayer.Character
		if not char then return end

		-- Remove old of same type
		local class = item.ClassName
		local old = char:FindFirstChildOfClass(class)
		if old then
			safeFireServer("Tools", "Remove", old, char)
		end

		safeFireServer("Tools", "Add", item, char)
	end)
	
	updateClothingButtonsOrder()
end

-- Watch for stored items
if AccessoryFolder then
	for _, child in ipairs(AccessoryFolder:GetChildren()) do
		createAccessoryButton(child)
	end
	AccessoryFolder.ChildAdded:Connect(createAccessoryButton)
end

if ClothingFolder then
	for _, subfolder in ipairs(ClothingFolder:GetChildren()) do
		if subfolder:IsA("Folder") then
			for _, item in ipairs(subfolder:GetChildren()) do
				createClothingButton(item, subfolder.Name)
			end
			subfolder.ChildAdded:Connect(function(item)
				createClothingButton(item, subfolder.Name)
			end)
		end
	end
	ClothingFolder.ChildAdded:Connect(function(subfolder)
		if subfolder:IsA("Folder") then
			for _, item in ipairs(subfolder:GetChildren()) do
				createClothingButton(item, subfolder.Name)
			end
			subfolder.ChildAdded:Connect(function(item)
				createClothingButton(item, subfolder.Name)
			end)
		end
	end)
end

-- Additional ClothesFolder scanning (assuming it's a pre-populated folder)
local ClothesFolder = Misc:WaitForChild("Clothes")

local function scanClothesFolder(folder)
	-- Create or get Preloaded subfolder
	local preloadedFolder = ClothingFolder:FindFirstChild("Preloaded")
	if not preloadedFolder then
		safeFireServer("Tools", "Add", PlaceholderFolder, ClothingFolder)
		preloadedFolder = waitForChild(ClothingFolder, "Answer_Types")
		if preloadedFolder then
			preloadedFolder.Name = "Preloaded"
		end
	end

	if preloadedFolder then
    	local fromCharacter = folder.Name
    	local charFolder = preloadedFolder:FindFirstChild(fromCharacter)
    	if not charFolder then
        	safeFireServer("Tools", "Add", PlaceholderFolder, preloadedFolder)
        	charFolder = waitForChild(preloadedFolder, "Answer_Types")
        	if charFolder then
            	charFolder.Name = fromCharacter
        	end
    	end

    	if charFolder then
        	for _, item in ipairs(folder:GetDescendants()) do
            	if item:IsA("Shirt") or item:IsA("Pants") then
                	local exists = false
                	for _, existing in ipairs(charFolder:GetChildren()) do
                    	if item:IsA("Shirt") and existing:IsA("Shirt") and existing.ShirtTemplate == item.ShirtTemplate then
                        	exists = true
                        	break
                    	elseif item:IsA("Pants") and existing:IsA("Pants") and existing.PantsTemplate == item.PantsTemplate then
                        	exists = true
                        	break
                    	end
                	end
                	if not exists then
                    	safeFireServer("Tools", "Add", item, charFolder)
                	end
            	end
        	end
    	end
	end
end



-- Initial scan
if ClothingFolder then
	scanClothesFolder(ClothesFolder)
end

-- Watch for new items added in runtime
ClothesFolder.DescendantAdded:Connect(function(item)
	if item:IsA("Shirt") or item:IsA("Pants") then
		-- Add to Preloaded if not exists
		local preloadedFolder = ClothingFolder:FindFirstChild("Preloaded")
		if preloadedFolder then
			local exists = false
			for _, existing in ipairs(preloadedFolder:GetChildren()) do
				if item:IsA("Shirt") and existing:IsA("Shirt") and existing.ShirtTemplate == item.ShirtTemplate then
					exists = true
					break
				elseif item:IsA("Pants") and existing:IsA("Pants") and existing.PantsTemplate == item.PantsTemplate then
					exists = true
					break
				end
			end
			if not exists then
				safeFireServer("Tools", "Add", item, preloadedFolder)
			end
		end
	end
end)

-- Toggle GUI with hotkey (e.g., 'E')
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		screenGui.Enabled = not screenGui.Enabled
	end
end)

-- === Upgrade: Add "Z" button and tools popup ===
local zButton = Instance.new("TextButton")
zButton.Parent = screenGui
zButton.Size = UDim2.new(0, 40, 0, 40)
zButton.Position = UDim2.new(0, 10, 0, 10)
zButton.Text = "Z"
zButton.Font = Enum.Font.GothamBold
zButton.TextSize = 20
zButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
zButton.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", zButton).CornerRadius = UDim.new(0, 8)

local toolsPopup = Instance.new("Frame")
toolsPopup.Parent = screenGui
toolsPopup.Size = UDim2.new(0, 300, 0, 250)
toolsPopup.Position = UDim2.new(0.5, -150, 0.5, -125)
toolsPopup.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toolsPopup.Visible = false
toolsPopup.Active = true
toolsPopup.Draggable = true
Instance.new("UICorner", toolsPopup).CornerRadius = UDim.new(0, 12)

local toolsTitleBar = Instance.new("Frame")
toolsTitleBar.Parent = toolsPopup
toolsTitleBar.Size = UDim2.new(1, 0, 0, 40)
toolsTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toolsTitleBar.BorderSizePixel = 0

local toolsTitle = Instance.new("TextLabel")
toolsTitle.Parent = toolsTitleBar
toolsTitle.Size = UDim2.new(1, -180, 1, 0)
toolsTitle.Position = UDim2.new(0, 10, 0, 0)
toolsTitle.BackgroundTransparency = 1
toolsTitle.Text = "Tools"
toolsTitle.Font = Enum.Font.GothamBold
toolsTitle.TextSize = 20
toolsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
toolsTitle.TextXAlignment = Enum.TextXAlignment.Left

local toolsClose = Instance.new("TextButton")
toolsClose.Parent = toolsTitleBar
toolsClose.Size = UDim2.new(0, 30, 0, 30)
toolsClose.Position = UDim2.new(1, -35, 0, 5)
toolsClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toolsClose.Text = "X"
toolsClose.Font = Enum.Font.GothamBold
toolsClose.TextSize = 16
toolsClose.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", toolsClose).CornerRadius = UDim.new(0, 6)
toolsClose.MouseButton1Click:Connect(function()
	toolsPopup.Visible = false
end)

-- Target Player Selector for Tools Popup
local toolsTargetPlayer = LocalPlayer
local toolsTargetLabel = Instance.new("TextLabel", toolsTitleBar)
toolsTargetLabel.Size = UDim2.new(0, 140, 1, 0)
toolsTargetLabel.Position = UDim2.new(1, -180, 0, 0)
toolsTargetLabel.BackgroundTransparency = 1
toolsTargetLabel.Text = "Target: " .. LocalPlayer.Name
toolsTargetLabel.Font = Enum.Font.Gotham
toolsTargetLabel.TextSize = 16
toolsTargetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
toolsTargetLabel.TextXAlignment = Enum.TextXAlignment.Right

local toolsTargetButton = Instance.new("TextButton", toolsTitleBar)
toolsTargetButton.Size = UDim2.new(0, 140, 1, 0)
toolsTargetButton.Position = UDim2.new(1, -180, 0, 0)
toolsTargetButton.BackgroundTransparency = 1
toolsTargetButton.Text = ""

local toolsPlayersListFrame = Instance.new("ScrollingFrame", toolsPopup)
toolsPlayersListFrame.Size = UDim2.new(1, 0, 0, 100)
toolsPlayersListFrame.Position = UDim2.new(0, 0, 0, 40)
toolsPlayersListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toolsPlayersListFrame.Visible = false
toolsPlayersListFrame.ScrollBarThickness = 6
toolsPlayersListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
toolsPlayersListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local toolsPlayersGrid = Instance.new("UIGridLayout", toolsPlayersListFrame)
toolsPlayersGrid.CellSize = UDim2.new(1, 0, 0, 30)
toolsPlayersGrid.CellPadding = UDim2.new(0, 0, 0, 5)

local function updateToolsPlayersList()
	for _, child in ipairs(toolsPlayersListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton", toolsPlayersListFrame)
		btn.Text = player.Name
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 16
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		btn.MouseButton1Click:Connect(function()
			toolsTargetPlayer = player
			toolsTargetLabel.Text = "Target: " .. player.Name
			toolsPlayersListFrame.Visible = false
		end)
	end
	toolsPlayersGrid:ApplyLayout()
end

updateToolsPlayersList()

Players.PlayerAdded:Connect(updateToolsPlayersList)
Players.PlayerRemoving:Connect(updateToolsPlayersList)

toolsTargetButton.MouseButton1Click:Connect(function()
	toolsPlayersListFrame.Visible = not toolsPlayersListFrame.Visible
	if toolsPlayersListFrame.Visible then
		updateToolsPlayersList()
	end
end)

local toolsContent = Instance.new("ScrollingFrame")
toolsContent.Parent = toolsPopup
toolsContent.Size = UDim2.new(1, 0, 1, -40)
toolsContent.Position = UDim2.new(0, 0, 0, 40)
toolsContent.BackgroundTransparency = 1
toolsContent.ScrollBarThickness = 6
toolsContent.CanvasSize = UDim2.new(0, 0, 0, 0)
toolsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Adjust tools content position if players list is visible
toolsPlayersListFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if toolsPlayersListFrame.Visible then
		toolsContent.Position = UDim2.new(0, 0, 0, 140)
		toolsContent.Size = UDim2.new(1, 0, 1, -140)
	else
		toolsContent.Position = UDim2.new(0, 0, 0, 40)
		toolsContent.Size = UDim2.new(1, 0, 1, -40)
	end
end)

local toolsGrid = Instance.new("UIGridLayout")
toolsGrid.Parent = toolsContent
toolsGrid.CellSize = UDim2.new(1, -10, 0, 40)
toolsGrid.CellPadding = UDim2.new(0, 0, 0, 5)
toolsGrid.SortOrder = Enum.SortOrder.LayoutOrder

-- List of tools/buttons for easy addition
local toolsList = {
	{
		text = "Remove Accessories",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then
				warn("Players folder not found in workspace")
				return
			end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if playerChar then
				local targetAccessory = playerChar:FindFirstChild("Accessories")
				if targetAccessory then
					safeFireServer("Tools", "Remove", targetAccessory, playerChar)
				else
					warn("Accessory not found in " .. playerChar.Name)
				end
			else
				warn("Player character not found: " .. targetPlayer.Name)
			end
		end
	},
	{
		text = "Remove Clothing",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then
				warn("Players folder not found in workspace")
				return
			end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if playerChar then
				local shirt = playerChar:FindFirstChildOfClass("Shirt")
				if shirt then
					safeFireServer("Tools", "Remove", shirt, playerChar)
				end
				local pants = playerChar:FindFirstChildOfClass("Pants")
				if pants then
					safeFireServer("Tools", "Remove", pants, playerChar)
				end
				if not shirt and not pants then
					warn("No clothing found in " .. playerChar.Name)
				end
			else
				warn("Player character not found: " .. targetPlayer.Name)
			end
		end
	},
	-- Add more tools here easily, e.g.:
	-- {
	--     text = "Example Button",
	--     action = function(targetPlayer)
	--         -- Your script here, using targetPlayer and safeFireServer
	--     end
	-- },
}

-- Create buttons from the list
for _, tool in ipairs(toolsList) do
	local button = Instance.new("TextButton")
	button.Parent = toolsContent
	button.Text = tool.text
	button.Font = Enum.Font.Gotham
	button.TextSize = 16
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
	button.MouseButton1Click:Connect(function()
		tool.action(toolsTargetPlayer)
	end)
end

-- Connect Z button to toggle popup
zButton.MouseButton1Click:Connect(function()
	toolsPopup.Visible = not toolsPopup.Visible
end)

-- Optional: Add hotkey for Z popup (e.g., KeyCode.Z)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Z then
		toolsPopup.Visible = not toolsPopup.Visible
	end
end)
