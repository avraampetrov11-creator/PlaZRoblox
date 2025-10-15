ect(updateToolsPlayersList)

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
				local removed = false
				for _, acc in ipairs(playerChar:GetChildren()) do
					if acc:IsA("Accessory") then
						safeFireServer("Tools", "Remove", acc, playerChar)
						removed = true
					end
				end
				if not removed then
					warn("No accessories found in " .. playerChar.Name)
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
				local removed = false
				local shirt = playerChar:FindFirstChildOfClass("Shirt")
				if shirt then
					safeFireServer("Tools", "Remove", shirt, playerChar)
					removed = true
				end
				local pants = playerChar:FindFirstChildOfClass("Pants")
				if pants then
					safeFireServer("Tools", "Remove", pants, playerChar)
					removed = true
				end
				local tshirt = playerChar:FindFirstChildOfClass("ShirtGraphic")
				if tshirt then
					safeFireServer("Tools", "Remove", tshirt, playerChar)
					removed = true
				end
				if not removed then
					warn("No clothing found in " .. playerChar.Name)
				end
			else
				warn("Player character not found: " .. targetPlayer.Name)
			end
		end
	},
	{
		text = "Remove T-Shirt",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then
				warn("Players folder not found in workspace")
				return
			end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if playerChar then
				local tshirt = playerChar:FindFirstChildOfClass("ShirtGraphic")
				if tshirt then
					safeFireServer("Tools", "Remove", tshirt, playerChar)
				else
					warn("No T-Shirt found in " .. playerChar.Name)
				end
			else
				warn("Player character not found: " .. targetPlayer.Name)
			end
		end
	},
	{
		text = "Clear All",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then
				warn("Players folder not found in workspace")
				return
			end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if playerChar then
				local removed = false
				for _, acc in ipairs(playerChar:GetChildren()) do
					if acc:IsA("Accessory") then
						safeFireServer("Tools", "Remove", acc, playerChar)
						removed = true
					end
				end
				local shirt = playerChar:FindFirstChildOfClass("Shirt")
				if shirt then
					safeFireServer("Tools", "Remove", shirt, playerChar)
					removed = true
				end
				local pants = playerChar:FindFirstChildOfClass("Pants")
				if pants then
					safeFireServer("Tools", "Remove", pants, playerChar)
					removed = true
				end
				local tshirt = playerChar:FindFirstChildOfClass("ShirtGraphic")
				if tshirt then
					safeFireServer("Tools", "Remove", tshirt, playerChar)
					removed = true
				end
				if not removed then
					warn("Nothing to clear in " .. playerChar.Name)
				end
			else
				warn("Player character not found: " .. targetPlayer.Name)
			end
		end
	},
	{
		text = "Random Outfit",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then return end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if not playerChar then return end

			-- Clear all first
			for _, acc in ipairs(playerChar:GetChildren()) do
				if acc:IsA("Accessory") then
					safeFireServer("Tools", "Remove", acc, playerChar)
				end
			end
			local shirt = playerChar:FindFirstChildOfClass("Shirt")
			if shirt then safeFireServer("Tools", "Remove", shirt, playerChar) end
			local pants = playerChar:FindFirstChildOfClass("Pants")
			if pants then safeFireServer("Tools", "Remove", pants, playerChar) end
			local tshirt = playerChar:FindFirstChildOfClass("ShirtGraphic")
			if tshirt then safeFireServer("Tools", "Remove", tshirt, playerChar) end

			-- Add random accessory
			local accs = {}
			for _, item in ipairs(AccessoryFolder:GetChildren()) do
				if item:IsA("Accessory") then
					table.insert(accs, item)
				end
			end
			if #accs > 0 then
				local randAcc = accs[math.random(1, #accs)]
				safeFireServer("Tools", "Add", randAcc, playerChar)
			end

			-- Add random shirt
			local shirts = getAllItemsOfClass("Shirt")
			if #shirts > 0 then
				local randShirt = shirts[math.random(1, #shirts)]
				safeFireServer("Tools", "Add", randShirt, playerChar)
			end

			-- Add random pants
			local pantsList = getAllItemsOfClass("Pants")
			if #pantsList > 0 then
				local randPants = pantsList[math.random(1, #pantsList)]
				safeFireServer("Tools", "Add", randPants, playerChar)
			end

			-- Add random t-shirt
			local tshirts = getAllItemsOfClass("ShirtGraphic")
			if #tshirts > 0 then
				local randT = tshirts[math.random(1, #tshirts)]
				safeFireServer("Tools", "Add", randT, playerChar)
			end
		end
	},
	{
		text = "Copy My Outfit",
		action = function(targetPlayer)
			if targetPlayer == LocalPlayer then return end
			local myChar = LocalPlayer.Character
			if not myChar then return end
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then return end
			local targetChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if not targetChar then return end

			-- Clear target
			for _, acc in ipairs(targetChar:GetChildren()) do
				if acc:IsA("Accessory") then
					safeFireServer("Tools", "Remove", acc, targetChar)
				end
			end
			local shirt = targetChar:FindFirstChildOfClass("Shirt")
			if shirt then safeFireServer("Tools", "Remove", shirt, targetChar) end
			local pants = targetChar:FindFirstChildOfClass("Pants")
			if pants then safeFireServer("Tools", "Remove", pants, targetChar) end
			local tshirt = targetChar:FindFirstChildOfClass("ShirtGraphic")
			if tshirt then safeFireServer("Tools", "Remove", tshirt, targetChar) end

			-- Copy accessories
			for _, acc in ipairs(myChar:GetChildren()) do
				if acc:IsA("Accessory") then
					local handle = acc:FindFirstChild("Handle")
					local mesh = handle and handle:FindFirstChildOfClass("SpecialMesh")
					local meshId = mesh and mesh.MeshId or ""
					local textureId = mesh and mesh.TextureId or ""
					for _, stored in ipairs(AccessoryFolder:GetChildren()) do
						if stored:IsA("Accessory") then
							local shandle = stored:FindFirstChild("Handle")
							local smesh = shandle and shandle:FindFirstChildOfClass("SpecialMesh")
							if smesh and smesh.MeshId == meshId and smesh.TextureId == textureId then
								safeFireServer("Tools", "Add", stored, targetChar)
								break
							end
						end
					end
				end
			end

			-- Copy shirt
			local myShirt = myChar:FindFirstChildOfClass("Shirt")
			if myShirt then
				local template = myShirt.ShirtTemplate
				local shirts = getAllItemsOfClass("Shirt")
				for _, stored in ipairs(shirts) do
					if stored.ShirtTemplate == template then
						safeFireServer("Tools", "Add", stored, targetChar)
						break
					end
				end
			end

			-- Copy pants
			local myPants = myChar:FindFirstChildOfClass("Pants")
			if myPants then
				local template = myPants.PantsTemplate
				local pantsList = getAllItemsOfClass("Pants")
				for _, stored in ipairs(pantsList) do
					if stored.PantsTemplate == template then
						safeFireServer("Tools", "Add", stored, targetChar)
						break
					end
				end
			end

			-- Copy t-shirt
			local myT = myChar:FindFirstChildOfClass("ShirtGraphic")
			if myT then
				local graphic = myT.Graphic
				local tshirts = getAllItemsOfClass("ShirtGraphic")
				for _, stored in ipairs(tshirts) do
					if stored.Graphic == graphic then
						safeFireServer("Tools", "Add", stored, targetChar)
						break
					end
				end
			end
		end
	},
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
-- LocalScript (StarterPlayerScripts)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- === PROFESSIONAL THEME CONSTANTS ===
local THEME = {
    PRIMARY_BG = Color3.fromRGB(15, 15, 20),
    SECONDARY_BG = Color3.fromRGB(25, 25, 30),
    TERTIARY_BG = Color3.fromRGB(35, 35, 40),
    ACCENT = Color3.fromRGB(0, 162, 255),
    ACCENT_GLOW = Color3.fromRGB(0, 200, 255),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(180, 180, 185),
    DANGER = Color3.fromRGB(220, 50, 50),
    SUCCESS = Color3.fromRGB(50, 220, 50),
    OUTLINE = Color3.fromRGB(60, 60, 65),
    CORNER_RADIUS = UDim.new(0, 12),
    BUTTON_RADIUS = UDim.new(0, 8),
    SUB_BUTTON_RADIUS = UDim.new(0, 6)
}

-- === SMOOTH TWEEN INFO ===
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local GLOW_TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

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

local function addOutline(frame, thickness)
    local outline = Instance.new("UIStroke")
    outline.Parent = frame
    outline.Color = THEME.OUTLINE
    outline.Thickness = thickness or 1
    return outline
end

local function createGlowEffect(button)
    local glow = Instance.new("UIStroke")
    glow.Parent = button
    glow.Color = THEME.ACCENT_GLOW
    glow.Thickness = 0
    glow.Transparency = 1
    
    button.MouseEnter:Connect(function()
        TweenService:Create(glow, GLOW_TWEEN, {
            Thickness = 3,
            Transparency = 0.3
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(glow, GLOW_TWEEN, {
            Thickness = 0,
            Transparency = 1
        }):Play()
    end)
    
    return glow
end

local function addSmoothHover(button, hoverColor)
    hoverColor = hoverColor or Color3.fromRGB(50, 50, 60)
    button.BackgroundColor3 = THEME.TERTIARY_BG
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = hoverColor,
            Size = button.Size + UDim2.new(0, 4, 0, 4)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = THEME.TERTIARY_BG,
            Size = button.Size - UDim2.new(0, 4, 0, 4)
        }):Play()
    end)
end

-- [ALL YOUR FOLDER CREATION CODE - SAME AS ORIGINAL]
local PlaceholderFolder = ReplicatedStorage.Homework_Related:WaitForChild("Answer_Types")
local Misc = ReplicatedStorage:WaitForChild("Misc")

local CustomizationStuff = Misc:FindFirstChild("CustomizationStuff")
if not CustomizationStuff then
	local existingAnswerTypes = Misc:FindFirstChild("Answer_Types")
	if existingAnswerTypes then
		CustomizationStuff = existingAnswerTypes
		CustomizationStuff.Name = "CustomizationStuff"
		CustomizationStuff:SetAttribute("Type", "Container")
	else
		safeFireServer("Tools", "Add", PlaceholderFolder, Misc)
		CustomizationStuff = waitForChild(Misc, "Answer_Types")
		if CustomizationStuff then
			CustomizationStuff.Name = "CustomizationStuff"
			CustomizationStuff:SetAttribute("Type", "Container")
		end
	end
end

local AccessoryFolder = CustomizationStuff and CustomizationStuff:FindFirstChild("Accessories")
if not AccessoryFolder and CustomizationStuff then
	local existingAnswerTypes = CustomizationStuff:FindFirstChild("Answer_Types")
	if existingAnswerTypes then
		AccessoryFolder = existingAnswerTypes
		AccessoryFolder.Name = "Accessories"
		AccessoryFolder:SetAttribute("Type", "Accessories")
	else
		safeFireServer("Tools", "Add", PlaceholderFolder, CustomizationStuff)
		AccessoryFolder = waitForChild(CustomizationStuff, "Answer_Types")
		if AccessoryFolder then
			AccessoryFolder.Name = "Accessories"
			AccessoryFolder:SetAttribute("Type", "Accessories")
		end
	end
end

local ClothingFolder = CustomizationStuff and CustomizationStuff:FindFirstChild("Clothing")
if not ClothingFolder and CustomizationStuff then
	local existingAnswerTypes = CustomizationStuff:FindFirstChild("Answer_Types")
	if existingAnswerTypes and existingAnswerTypes ~= AccessoryFolder then
		ClothingFolder = existingAnswerTypes
		ClothingFolder.Name = "Clothing"
		ClothingFolder:SetAttribute("Type", "Clothing")
	else
		safeFireServer("Tools", "Add", PlaceholderFolder, CustomizationStuff)
		ClothingFolder = waitForChild(CustomizationStuff, "Answer_Types")
		if ClothingFolder then
			ClothingFolder.Name = "Clothing"
			ClothingFolder:SetAttribute("Type", "Clothing")
		end
	end
end

local ShirtsFolder, PantsFolder, TShirtsFolder
if ClothingFolder then
	ShirtsFolder = ClothingFolder:FindFirstChild("Shirts")
	if not ShirtsFolder then
		safeFireServer("Tools", "Add", PlaceholderFolder, ClothingFolder)
		ShirtsFolder = waitForChild(ClothingFolder, "Answer_Types")
		if ShirtsFolder then
			ShirtsFolder.Name = "Shirts"
			ShirtsFolder:SetAttribute("Type", "Clothing")
		end
	end

	PantsFolder = ClothingFolder:FindFirstChild("Pants")
	if not PantsFolder then
		safeFireServer("Tools", "Add", PlaceholderFolder, ClothingFolder)
		PantsFolder = waitForChild(ClothingFolder, "Answer_Types")
		if PantsFolder then
			PantsFolder.Name = "Pants"
			PantsFolder:SetAttribute("Type", "Clothing")
		end
	end

	TShirtsFolder = ClothingFolder:FindFirstChild("TShirts")
	if not TShirtsFolder then
		safeFireServer("Tools", "Add", PlaceholderFolder, ClothingFolder)
		TShirtsFolder = waitForChild(ClothingFolder, "Answer_Types")
		if TShirtsFolder then
			TShirtsFolder.Name = "TShirts"
			TShirtsFolder:SetAttribute("Type", "Clothing")
		end
	end
end

local function getAllItemsOfClass(className)
	local items = {}
	if ClothingFolder then
		for _, subfolder in ipairs(ClothingFolder:GetChildren()) do
			if subfolder:IsA("Folder") then
				for _, item in ipairs(subfolder:GetChildren()) do
					if item:IsA(className) then
						table.insert(items, item)
					end
				end
			end
		end
	end
	return items
end

local function saveCharacterStuff(char, AccessoryFolder, ShirtsFolder, PantsFolder, TShirtsFolder)
	task.wait(1)
	if not AccessoryFolder or not ShirtsFolder or not PantsFolder or not TShirtsFolder then return end

	for _, accessory in ipairs(char:GetChildren()) do
		if accessory:IsA("Accessory") then
			local handle = accessory:FindFirstChild("Handle")
			local mesh = handle and handle:FindFirstChildOfClass("SpecialMesh")
			local meshId = mesh and mesh.MeshId or ""
			local textureId = mesh and mesh.TextureId or ""
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

	local shirt = char:FindFirstChildOfClass("Shirt")
	if shirt and shirt.ShirtTemplate ~= "" then
		local exists = false
		for _, existing in ipairs(ShirtsFolder:GetChildren()) do
			if existing:IsA("Shirt") and existing.ShirtTemplate == shirt.ShirtTemplate then
				exists = true
				break
			end
		end
		if not exists then
			safeFireServer("Tools", "Add", shirt, ShirtsFolder)
		end
	end

	local pants = char:FindFirstChildOfClass("Pants")
	if pants and pants.PantsTemplate ~= "" then
		local exists = false
		for _, existing in ipairs(PantsFolder:GetChildren()) do
			if existing:IsA("Pants") and existing.PantsTemplate == pants.PantsTemplate then
				exists = true
				break
			end
		end
		if not exists then
			safeFireServer("Tools", "Add", pants, PantsFolder)
		end
	end

	local tshirt = char:FindFirstChildOfClass("ShirtGraphic")
	if tshirt and tshirt.Graphic ~= "" then
		local exists = false
		for _, existing in ipairs(TShirtsFolder:GetChildren()) do
			if existing:IsA("ShirtGraphic") and existing.Graphic == tshirt.Graphic then
				exists = true
				break
			end
		end
		if not exists then
			safeFireServer("Tools", "Add", tshirt, TShirtsFolder)
		end
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function(char)
		saveCharacterStuff(char, AccessoryFolder, ShirtsFolder, PantsFolder, TShirtsFolder)
	end)
	if player.Character then
		saveCharacterStuff(player.Character, AccessoryFolder, ShirtsFolder, PantsFolder, TShirtsFolder)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		saveCharacterStuff(char, AccessoryFolder, ShirtsFolder, PantsFolder, TShirtsFolder)
	end)
	if player.Character then
		saveCharacterStuff(player.Character, AccessoryFolder, ShirtsFolder, PantsFolder, TShirtsFolder)
	end
end)

-- === PROFESSIONAL GUI SETUP ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryPanel"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 520, 0, 420)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = THEME.PRIMARY_BG
mainFrame.Active = true
mainFrame.Draggable = true
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = THEME.CORNER_RADIUS
addOutline(mainFrame, 1)

-- TITLE BAR
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = THEME.SECONDARY_BG

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -160, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎨 INVENTORY MANAGER"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = THEME.TEXT_PRIMARY
title.TextXAlignment = Enum.TextXAlignment.Left

local closeButton = Instance.new("TextButton", titleBar)
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -40, 0, 5)
closeButton.BackgroundColor3 = THEME.DANGER
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.TextColor3 = THEME.TEXT_PRIMARY
Instance.new("UICorner", closeButton).CornerRadius = THEME.BUTTON_RADIUS
createGlowEffect(closeButton)
addSmoothHover(closeButton)
closeButton.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame, TWEEN_INFO, {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    screenGui.Enabled = false
end)

-- TARGET SELECTOR
local mainTargetPlayer = LocalPlayer
local mainTargetLabel = Instance.new("TextLabel", titleBar)
mainTargetLabel.Size = UDim2.new(0, 140, 1, 0)
mainTargetLabel.Position = UDim2.new(1, -185, 0, 0)
mainTargetLabel.BackgroundTransparency = 1
mainTargetLabel.Text = "🎯 " .. LocalPlayer.Name
mainTargetLabel.Font = Enum.Font.GothamSemibold
mainTargetLabel.TextSize = 14
mainTargetLabel.TextColor3 = THEME.TEXT_SECONDARY
mainTargetLabel.TextXAlignment = Enum.TextXAlignment.Right

local mainTargetButton = Instance.new("TextButton", titleBar)
mainTargetButton.Size = UDim2.new(0, 140, 1, 0)
mainTargetButton.Position = UDim2.new(1, -185, 0, 0)
mainTargetButton.BackgroundTransparency = 1
mainTargetButton.Text = ""

-- PLAYERS LIST
local mainPlayersListFrame = Instance.new("ScrollingFrame", mainFrame)
mainPlayersListFrame.Size = UDim2.new(1, 0, 0, 120)
mainPlayersListFrame.Position = UDim2.new(0, 0, 0, 45)
mainPlayersListFrame.BackgroundColor3 = THEME.TERTIARY_BG
mainPlayersListFrame.Visible = false
mainPlayersListFrame.ScrollBarThickness = 4
mainPlayersListFrame.ScrollBarImageColor3 = THEME.ACCENT
mainPlayersListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
mainPlayersListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", mainPlayersListFrame).CornerRadius = THEME.BUTTON_RADIUS
addOutline(mainPlayersListFrame, 1)

local mainPlayersGrid = Instance.new("UIGridLayout", mainPlayersListFrame)
mainPlayersGrid.CellSize = UDim2.new(1, -10, 0, 35)
mainPlayersGrid.CellPadding = UDim2.new(0, 0, 0, 5)

local function updateMainPlayersList()
	for _, child in ipairs(mainPlayersListFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton", mainPlayersListFrame)
		btn.Text = "👤 " .. player.Name
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 15
		btn.TextColor3 = THEME.TEXT_PRIMARY
		btn.BackgroundColor3 = THEME.SECONDARY_BG
		Instance.new("UICorner", btn).CornerRadius = THEME.BUTTON_RADIUS
		addOutline(btn, 1)
		createGlowEffect(btn)
		addSmoothHover(btn)
		btn.MouseButton1Click:Connect(function()
			mainTargetPlayer = player
			mainTargetLabel.Text = "🎯 " .. player.Name
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
	updateMainPlayersList()
end)

-- TABS
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 45)
tabBar.BackgroundColor3 = THEME.SECONDARY_BG
addOutline(tabBar, 1)

local accessoriesTab = Instance.new("TextButton", tabBar)
accessoriesTab.Size = UDim2.new(0.5, 0, 1, 0)
accessoriesTab.Text = "💎 ACCESSORIES"
accessoriesTab.Font = Enum.Font.GothamBold
accessoriesTab.TextSize = 14
accessoriesTab.TextColor3 = THEME.TEXT_PRIMARY
accessoriesTab.BackgroundColor3 = THEME.ACCENT
Instance.new("UICorner", accessoriesTab).CornerRadius = THEME.BUTTON_RADIUS
createGlowEffect(accessoriesTab)
addSmoothHover(accessoriesTab, THEME.ACCENT_GLOW)

local clothingTab = Instance.new("TextButton", tabBar)
clothingTab.Size = UDim2.new(0.5, 0, 1, 0)
clothingTab.Position = UDim2.new(0.5, 0, 0, 0)
clothingTab.Text = "👕 CLOTHING"
clothingTab.Font = Enum.Font.GothamBold
clothingTab.TextSize = 14
clothingTab.TextColor3 = THEME.TEXT_PRIMARY
clothingTab.BackgroundColor3 = THEME.TERTIARY_BG
Instance.new("UICorner", clothingTab).CornerRadius = THEME.BUTTON_RADIUS
createGlowEffect(clothingTab)
addSmoothHover(clothingTab)

-- CONTENT FRAME
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -90)
contentFrame.Position = UDim2.new(0, 0, 0, 85)
contentFrame.BackgroundTransparency = 1

mainPlayersListFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if mainPlayersListFrame.Visible then
		tabBar.Position = UDim2.new(0, 0, 0, 165)
		contentFrame.Position = UDim2.new(0, 0, 0, 205)
		contentFrame.Size = UDim2.new(1, 0, 1, -215)
	else
		tabBar.Position = UDim2.new(0, 0, 0, 45)
		contentFrame.Position = UDim2.new(0, 0, 0, 85)
		contentFrame.Size = UDim2.new(1, 0, 1, -90)
	end
end)

-- ACCESSORIES FRAME
local accessoriesFrame = Instance.new("ScrollingFrame", contentFrame)
accessoriesFrame.Size = UDim2.new(1, -20, 1, -10)
accessoriesFrame.Position = UDim2.new(0, 10, 0, 5)
accessoriesFrame.BackgroundTransparency = 1
accessoriesFrame.ScrollBarThickness = 6
accessoriesFrame.ScrollBarImageColor3 = THEME.ACCENT
accessoriesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
accessoriesFrame.Active = true

local accGrid = Instance.new("UIGridLayout", accessoriesFrame)
accGrid.CellSize = UDim2.new(0, 110, 0, 110)
accGrid.CellPadding = UDim2.new(0, 12, 0, 12)
accGrid.FillDirectionMaxCells = 4
accGrid.SortOrder = Enum.SortOrder.Name

-- CLOTHING FRAMES
local clothingFrame = Instance.new("Frame", contentFrame)
clothingFrame.Size = UDim2.new(1, 0, 1, 0)
clothingFrame.BackgroundTransparency = 1
clothingFrame.Visible = false

local clothingSubTabBar = Instance.new("Frame", clothingFrame)
clothingSubTabBar.Size = UDim2.new(1, 0, 0, 35)
clothingSubTabBar.BackgroundColor3 = THEME.TERTIARY_BG
addOutline(clothingSubTabBar, 1)

local shirtsSubTab = Instance.new("TextButton", clothingSubTabBar)
shirtsSubTab.Size = UDim2.new(1/3, 0, 1, 0)
shirtsSubTab.Text = "👔 SHIRTS"
shirtsSubTab.Font = Enum.Font.GothamBold
shirtsSubTab.TextSize = 13
shirtsSubTab.TextColor3 = THEME.TEXT_PRIMARY
shirtsSubTab.BackgroundColor3 = THEME.ACCENT
Instance.new("UICorner", shirtsSubTab).CornerRadius = THEME.SUB_BUTTON_RADIUS
createGlowEffect(shirtsSubTab)
addSmoothHover(shirtsSubTab, THEME.ACCENT_GLOW)

local pantsSubTab = Instance.new("TextButton", clothingSubTabBar)
pantsSubTab.Size = UDim2.new(1/3, 0, 1, 0)
pantsSubTab.Position = UDim2.new(1/3, 0, 0, 0)
pantsSubTab.Text = "👖 PANTS"
pantsSubTab.Font = Enum.Font.GothamBold
pantsSubTab.TextSize = 13
pantsSubTab.TextColor3 = THEME.TEXT_PRIMARY
pantsSubTab.BackgroundColor3 = THEME.SECONDARY_BG
Instance.new("UICorner", pantsSubTab).CornerRadius = THEME.SUB_BUTTON_RADIUS
createGlowEffect(pantsSubTab)
addSmoothHover(pantsSubTab)

local tshirtsSubTab = Instance.new("TextButton", clothingSubTabBar)
tshirtsSubTab.Size = UDim2.new(1/3, 0, 1, 0)
tshirtsSubTab.Position = UDim2.new(2/3, 0, 0, 0)
tshirtsSubTab.Text = "👕 T-SHIRTS"
tshirtsSubTab.Font = Enum.Font.GothamBold
tshirtsSubTab.TextSize = 13
tshirtsSubTab.TextColor3 = THEME.TEXT_PRIMARY
tshirtsSubTab.BackgroundColor3 = THEME.SECONDARY_BG
Instance.new("UICorner", tshirtsSubTab).CornerRadius = THEME.SUB_BUTTON_RADIUS
createGlowEffect(tshirtsSubTab)
addSmoothHover(tshirtsSubTab)

local clothingContentFrame = Instance.new("Frame", clothingFrame)
clothingContentFrame.Size = UDim2.new(1, 0, 1, -35)
clothingContentFrame.Position = UDim2.new(0, 0, 0, 35)
clothingContentFrame.BackgroundTransparency = 1

local shirtsFrame = Instance.new("ScrollingFrame", clothingContentFrame)
shirtsFrame.Size = UDim2.new(1, -20, 1, -10)
shirtsFrame.Position = UDim2.new(0, 10, 0, 5)
shirtsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
shirtsFrame.ScrollBarThickness = 6
shirtsFrame.ScrollBarImageColor3 = THEME.ACCENT
shirtsFrame.BackgroundTransparency = 1
shirtsFrame.Active = true

local shirtsGrid = Instance.new("UIGridLayout", shirtsFrame)
shirtsGrid.CellSize = UDim2.new(0, 130, 0, 150)
shirtsGrid.CellPadding = UDim2.new(0, 10, 0, 10)
shirtsGrid.FillDirectionMaxCells = 3
shirtsGrid.SortOrder = Enum.SortOrder.LayoutOrder

local pantsFrame = Instance.new("ScrollingFrame", clothingContentFrame)
pantsFrame.Size = UDim2.new(1, -20, 1, -10)
pantsFrame.Position = UDim2.new(0, 10, 0, 5)
pantsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
pantsFrame.ScrollBarThickness = 6
pantsFrame.ScrollBarImageColor3 = THEME.ACCENT
pantsFrame.BackgroundTransparency = 1
pantsFrame.Active = true
pantsFrame.Visible = false

local pantsGrid = Instance.new("UIGridLayout", pantsFrame)
pantsGrid.CellSize = UDim2.new(0, 130, 0, 150)
pantsGrid.CellPadding = UDim2.new(0, 10, 0, 10)
pantsGrid.FillDirectionMaxCells = 3
pantsGrid.SortOrder = Enum.SortOrder.LayoutOrder

local tshirtsFrame = Instance.new("ScrollingFrame", clothingContentFrame)
tshirtsFrame.Size = UDim2.new(1, -20, 1, -10)
tshirtsFrame.Position = UDim2.new(0, 10, 0, 5)
tshirtsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
tshirtsFrame.ScrollBarThickness = 6
tshirtsFrame.ScrollBarImageColor3 = THEME.ACCENT
tshirtsFrame.BackgroundTransparency = 1
tshirtsFrame.Active = true
tshirtsFrame.Visible = false

local tshirtsGrid = Instance.new("UIGridLayout", tshirtsFrame)
tshirtsGrid.CellSize = UDim2.new(0, 130, 0, 150)
tshirtsGrid.CellPadding = UDim2.new(0, 10, 0, 10)
tshirtsGrid.FillDirectionMaxCells = 3
tshirtsGrid.SortOrder = Enum.SortOrder.LayoutOrder

-- TAB SWITCHING
local function switchTab(activeTab, inactiveTab, showFrame, hideFrame)
    TweenService:Create(activeTab, TWEEN_INFO, {BackgroundColor3 = THEME.ACCENT}):Play()
    TweenService:Create(inactiveTab, TWEEN_INFO, {BackgroundColor3 = THEME.TERTIARY_BG}):Play()
    showFrame.Visible = true
    hideFrame.Visible = false
end

accessoriesTab.MouseButton1Click:Connect(function() switchTab(accessoriesTab, clothingTab, accessoriesFrame, clothingFrame) end)
clothingTab.MouseButton1Click:Connect(function() switchTab(clothingTab, accessoriesTab, clothingFrame, accessoriesFrame) end)

shirtsSubTab.MouseButton1Click:Connect(function()
    TweenService:Create(shirtsSubTab, TWEEN_INFO, {BackgroundColor3 = THEME.ACCENT}):Play()
    TweenService:Create(pantsSubTab, TWEEN_INFO, {BackgroundColor3 = THEME.SECONDARY_BG}):Play()
    TweenService:Create(tshirtsSubTab, TWEEN_INFO, {BackgroundColor3 = THEME.SECONDARY_BG}):Play()
    shirtsFrame.Visible = true
    pantsFrame.Visible = false
    tshirtsFrame.Visible = false
end)

pantsSubTab.MouseButton1Click:Connect(function()
    TweenService:Create(pantsSubTab, TWEEN_INFO, {BackgroundColor3 = THEME.ACCENT}):Play()
    TweenService:Create(shirtsSubTab, TWEEN_INFO, {BackgroundColor3 = THEME.SECONDARY_BG}):Play()
    TweenService:Create(tshirtsSubTab, TWEEN_INFO, {BackgroundColor3 = THEME.SECONDARY_BG}):Play()
    pantsFrame.Visible = true
    shirtsFrame.Visible = false
    tshirtsFrame.Visible = false
end)

tshirtsSubTab.MouseButton1Click:Connect(function()
    TweenService:Create(tshirtsSubTab, TWEEN_INFO, {BackgroundColor3 = THEME.ACCENT}):Play()
    TweenService:Create(shirtsSubTab, TWEEN_INFO, {BackgroundColor3 = THEME.SECONDARY_BG}):Play()
    TweenService:Create(pantsSubTab, TWEEN_INFO, {BackgroundColor3 = THEME.SECONDARY_BG}):Play()
    tshirtsFrame.Visible = true
    shirtsFrame.Visible = false
    pantsFrame.Visible = false
end)

-- === PROFESSIONAL ITEM BUTTONS ===
local function createAccessoryButton(accessory)
	if not accessory:IsA("Accessory") then return end

	local button = Instance.new("ImageButton", accessoriesFrame)
	button.Name = accessory.Name
	button.BackgroundColor3 = THEME.SECONDARY_BG
	Instance.new("UICorner", button).CornerRadius = THEME.BUTTON_RADIUS
	addOutline(button, 2)
	createGlowEffect(button)
	addSmoothHover(button)

	local viewport = Instance.new("ViewportFrame", button)
	viewport.Size = UDim2.new(1, 0, 0.8, 0)
	viewport.BackgroundTransparency = 1
	local clone = accessory:Clone()
	clone.Parent = viewport
	local camera = Instance.new("Camera", viewport)
	viewport.CurrentCamera = camera
	local handle = clone:FindFirstChild("Handle")
	if handle then
		camera.CFrame = CFrame.new(handle.Position + Vector3.new(0, 0, 3), handle.Position)
	end

	local nameLabel = Instance.new("TextLabel", button)
	nameLabel.Size = UDim2.new(1, 0, 0.2, 0)
	nameLabel.Position = UDim2.new(0, 0, 0.8, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = accessory.Name
	nameLabel.Font = Enum.Font.GothamSemibold
	nameLabel.TextSize = 11
	nameLabel.TextColor3 = THEME.TEXT_PRIMARY
	nameLabel.TextTruncate = Enum.TextTruncate.SplitWord

	button.MouseButton1Click:Connect(function()
		local char = mainTargetPlayer.Character
		if not char then return end
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

local function updateClothingButtonsOrder(frame)
	local buttons = {}
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("ImageButton") then table.insert(buttons, child) end
	end
	table.sort(buttons, function(a, b)
		local fromA = a:GetAttribute("FromCharacter") or "Unknown"
		local fromB = b:GetAttribute("FromCharacter") or "Unknown"
		if fromA ~= fromB then return fromA < fromB end
		return a.Name < b.Name
	end)
	for i, btn in ipairs(buttons) do btn.LayoutOrder = i end
end

local function createClothingButton(item, fromCharacter)
	if not (item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic")) then return end

	local targetFrame = item:IsA("Shirt") and shirtsFrame or item:IsA("Pants") and pantsFrame or tshirtsFrame
	
	local button = Instance.new("ImageButton", targetFrame)
	button.Name = item.Name
	button.BackgroundColor3 = THEME.SECONDARY_BG
	Instance.new("UICorner", button).CornerRadius = THEME.BUTTON_RADIUS
	addOutline(button, 2)
	createGlowEffect(button)
	addSmoothHover(button)
	button:SetAttribute("FromCharacter", fromCharacter or "Unknown")

	local id = tonumber((item:IsA("Shirt") and item.ShirtTemplate or item:IsA("Pants") and item.PantsTemplate or item.Graphic):match("%d+")) or 0
	button.Image = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", id)

	local fromLabel = Instance.new("TextLabel", button)
	fromLabel.Size = UDim2.new(1, 0, 0, 25)
	fromLabel.Position = UDim2.new(0, 0, 1, -25)
	fromLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	fromLabel.BackgroundTransparency = 0.7
	fromLabel.TextColor3 = THEME.TEXT_PRIMARY
	fromLabel.Text = fromCharacter or "Unknown"
	fromLabel.Font = Enum.Font.Gotham
	fromLabel.TextSize = 11
	Instance.new("UICorner", fromLabel).CornerRadius = THEME.SUB_BUTTON_RADIUS

	button.MouseButton1Click:Connect(function()
		local char = mainTargetPlayer.Character
		if not char then return end
		local class = item.ClassName
		local old = char:FindFirstChildOfClass(class)
		if old then safeFireServer("Tools", "Remove", old, char) end
		safeFireServer("Tools", "Add", item, char)
	end)
	
	updateClothingButtonsOrder(targetFrame)
end

-- CONNECT ITEMS
if AccessoryFolder then
	for _, child in ipairs(AccessoryFolder:GetChildren()) do createAccessoryButton(child) end
	AccessoryFolder.ChildAdded:Connect(createAccessoryButton)
end

if ClothingFolder then
	for _, subfolder in ipairs(ClothingFolder:GetChildren()) do
		if subfolder:IsA("Folder") then
			for _, item in ipairs(subfolder:GetChildren()) do
				createClothingButton(item, subfolder.Name)
			end
			subfolder.ChildAdded:Connect(function(item) createClothingButton(item, subfolder.Name) end)
		end
	end
	ClothingFolder.ChildAdded:Connect(function(subfolder)
		if subfolder:IsA("Folder") then
			for _, item in ipairs(subfolder:GetChildren()) do
				createClothingButton(item, subfolder.Name)
			end
			subfolder.ChildAdded:Connect(function(item) createClothingButton(item, subfolder.Name) end)
		end
	end)
end

-- SCANNING CODE
local ClothesFolder = Misc:WaitForChild("Clothes")

local function scanNPCCharactersForClothing()
	local npcFolder = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Characters")
	if not npcFolder then return end
	
	for _, npc in ipairs(npcFolder:GetChildren()) do
		if npc:IsA("Model") and not Players:GetPlayerFromCharacter(npc) then
			local npcClothingFolder = ClothingFolder:FindFirstChild(npc.Name)
			if not npcClothingFolder then
				safeFireServer("Tools", "Add", PlaceholderFolder, ClothingFolder)
				npcClothingFolder = waitForChild(ClothingFolder, "Answer_Types")
				if npcClothingFolder then
					npcClothingFolder.Name = npc.Name
				end
			end
			
			if npcClothingFolder then
				local shirt = npc:FindFirstChildOfClass("Shirt")
				if shirt and shirt.ShirtTemplate ~= "" then
					local exists = false
					for _, existing in ipairs(npcClothingFolder:GetChildren()) do
						if existing:IsA("Shirt") and existing.ShirtTemplate == shirt.ShirtTemplate then
							exists = true
							break
						end
					end
					if not exists then
						safeFireServer("Tools", "Add", shirt, npcClothingFolder)
					end
				end

				local pants = npc:FindFirstChildOfClass("Pants")
				if pants and pants.PantsTemplate ~= "" then
					local exists = false
					for _, existing in ipairs(npcClothingFolder:GetChildren()) do
						if existing:IsA("Pants") and existing.PantsTemplate == pants.PantsTemplate then
							exists = true
							break
						end
					end
					if not exists then
						safeFireServer("Tools", "Add", pants, npcClothingFolder)
					end
				end

				local tshirt = npc:FindFirstChildOfClass("ShirtGraphic")
				if tshirt and tshirt.Graphic ~= "" then
					local exists = false
					for _, existing in ipairs(npcClothingFolder:GetChildren()) do
						if existing:IsA("ShirtGraphic") and existing.Graphic == tshirt.Graphic then
							exists = true
							break
						end
					end
					if not exists then
						safeFireServer("Tools", "Add", tshirt, npcClothingFolder)
					end
				end
			end
		end
	end
end

local function scanClothesFolder(folder)
	local preloadedFolder = ClothingFolder:FindFirstChild("Preloaded")
	if not preloadedFolder then
		safeFireServer("Tools", "Add", PlaceholderFolder, ClothingFolder)
		preloadedFolder = waitForChild(ClothingFolder, "Answer_Types")
		if preloadedFolder then
			preloadedFolder.Name = "Preloaded"
		end
	end

	if preloadedFolder then
		for _, item in ipairs(folder:GetDescendants()) do
			if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
				local exists = false
				for _, existing in ipairs(preloadedFolder:GetChildren()) do
					if item:IsA("Shirt") and existing:IsA("Shirt") and existing.ShirtTemplate == item.ShirtTemplate then
						exists = true
						break
					elseif item:IsA("Pants") and existing:IsA("Pants") and existing.PantsTemplate == item.PantsTemplate then
						exists = true
						break
					elseif item:IsA("ShirtGraphic") and existing:IsA("ShirtGraphic") and existing.Graphic == item.Graphic then
						exists = true
						break
					end
				end
				if not exists then
					safeFireServer("Tools", "Add", item, preloadedFolder)
				end
			end
		end
	end
end

if ClothingFolder then
	scanClothesFolder(ClothesFolder)
	scanNPCCharactersForClothing()
end

ClothesFolder.DescendantAdded:Connect(function(item)
	if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
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
				elseif item:IsA("ShirtGraphic") and existing:IsA("ShirtGraphic") and existing.Graphic == item.Graphic then
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

-- HOTKEYS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		screenGui.Enabled = not screenGui.Enabled
		if screenGui.Enabled then
			mainFrame.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(mainFrame, TWEEN_INFO, {Size = UDim2.new(0, 520, 0, 420)}):Play()
		end
	end
end)

-- === Z BUTTON & TOOLS POPUP ===
local zButton = Instance.new("TextButton", screenGui)
zButton.Size = UDim2.new(0, 45, 0, 45)
zButton.Position = UDim2.new(0, 10, 0, 10)
zButton.Text = "⚙️"
zButton.Font = Enum.Font.GothamBold
zButton.TextSize = 20
zButton.BackgroundColor3 = THEME.PRIMARY_BG
zButton.TextColor3 = THEME.TEXT_PRIMARY
Instance.new("UICorner", zButton).CornerRadius = THEME.BUTTON_RADIUS
addOutline(zButton, 2)
createGlowEffect(zButton)
addSmoothHover(zButton)

local toolsPopup = Instance.new("Frame", screenGui)
toolsPopup.Size = UDim2.new(0, 320, 0, 280)
toolsPopup.Position = UDim2.new(0.5, -160, 0.5, -140)
toolsPopup.BackgroundColor3 = THEME.PRIMARY_BG
toolsPopup.Visible = false
toolsPopup.Active = true
toolsPopup.Draggable = true
Instance.new("UICorner", toolsPopup).CornerRadius = THEME.CORNER_RADIUS
addOutline(toolsPopup, 1)

local toolsTitleBar = Instance.new("Frame", toolsPopup)
toolsTitleBar.Size = UDim2.new(1, 0, 0, 45)
toolsTitleBar.BackgroundColor3 = THEME.SECONDARY_BG

local toolsTitle = Instance.new("TextLabel", toolsTitleBar)
toolsTitle.Size = UDim2.new(1, -180, 1, 0)
toolsTitle.Position = UDim2.new(0, 15, 0, 0)
toolsTitle.BackgroundTransparency = 1
toolsTitle.Text = "🔧 TOOLS PANEL"
toolsTitle.Font = Enum.Font.GothamBold
toolsTitle.TextSize = 18
toolsTitle.TextColor3 = THEME.TEXT_PRIMARY

local toolsClose = Instance.new("TextButton", toolsTitleBar)
toolsClose.Size = UDim2.new(0, 35, 0, 35)
toolsClose.Position = UDim2.new(1, -40, 0, 5)
toolsClose.BackgroundColor3 = THEME.DANGER
toolsClose.Text = "✕"
toolsClose.Font = Enum.Font.GothamBold
toolsClose.TextSize = 18
toolsClose.TextColor3 = THEME.TEXT_PRIMARY
Instance.new("UICorner", toolsClose).CornerRadius = THEME.BUTTON_RADIUS
createGlowEffect(toolsClose)
addSmoothHover(toolsClose)
toolsClose.MouseButton1Click:Connect(function() toolsPopup.Visible = false end)

local toolsTargetPlayer = LocalPlayer
local toolsTargetLabel = Instance.new("TextLabel", toolsTitleBar)
toolsTargetLabel.Size = UDim2.new(0, 140, 1, 0)
toolsTargetLabel.Position = UDim2.new(1, -185, 0, 0)
toolsTargetLabel.BackgroundTransparency = 1
toolsTargetLabel.Text = "🎯 " .. LocalPlayer.Name
toolsTargetLabel.Font = Enum.Font.GothamSemibold
toolsTargetLabel.TextSize = 14
toolsTargetLabel.TextColor3 = THEME.TEXT_SECONDARY
toolsTargetLabel.TextXAlignment = Enum.TextXAlignment.Right

local toolsTargetButton = Instance.new("TextButton", toolsTitleBar)
toolsTargetButton.Size = UDim2.new(0, 140, 1, 0)
toolsTargetButton.Position = UDim2.new(1, -185, 0, 0)
toolsTargetButton.BackgroundTransparency = 1
toolsTargetButton.Text = ""

local toolsPlayersListFrame = Instance.new("ScrollingFrame", toolsPopup)
toolsPlayersListFrame.Size = UDim2.new(1, 0, 0, 120)
toolsPlayersListFrame.Position = UDim2.new(0, 0, 0, 45)
toolsPlayersListFrame.BackgroundColor3 = THEME.TERTIARY_BG
toolsPlayersListFrame.Visible = false
toolsPlayersListFrame.ScrollBarThickness = 4
toolsPlayersListFrame.ScrollBarImageColor3 = THEME.ACCENT
toolsPlayersListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
toolsPlayersListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", toolsPlayersListFrame).CornerRadius = THEME.BUTTON_RADIUS
addOutline(toolsPlayersListFrame, 1)

local toolsPlayersGrid = Instance.new("UIGridLayout", toolsPlayersListFrame)
toolsPlayersGrid.CellSize = UDim2.new(1, -10, 0, 35)
toolsPlayersGrid.CellPadding = UDim2.new(0, 0, 0, 5)

local function updateToolsPlayersList()
	for _, child in ipairs(toolsPlayersListFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton", toolsPlayersListFrame)
		btn.Text = "👤 " .. player.Name
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 15
		btn.TextColor3 = THEME.TEXT_PRIMARY
		btn.BackgroundColor3 = THEME.SECONDARY_BG
		Instance.new("UICorner", btn).CornerRadius = THEME.BUTTON_RADIUS
		addOutline(btn, 1)
		createGlowEffect(btn)
		addSmoothHover(btn)
		btn.MouseButton1Click:Connect(function()
			toolsTargetPlayer = player
			toolsTargetLabel.Text = "🎯 " .. player.Name
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
	updateToolsPlayersList()
end)

local toolsContent = Instance.new("ScrollingFrame", toolsPopup)
toolsContent.Size = UDim2.new(1, 0, 1, -45)
toolsContent.Position = UDim2.new(0, 0, 0, 45)
toolsContent.BackgroundTransparency = 1
toolsContent.ScrollBarThickness = 4
toolsContent.ScrollBarImageColor3 = THEME.ACCENT
toolsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

local toolsGrid = Instance.new("UIGridLayout", toolsContent)
toolsGrid.CellSize = UDim2.new(1, -10, 0, 45)
toolsGrid.CellPadding = UDim2.new(0, 0, 0, 8)

-- *** FIXED LINE 840 - COMPLETE TOOLS LIST ***
local toolsList = {
	{
		text = "🧹 Remove Accessories",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then return end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if playerChar then
				for _, acc in ipairs(playerChar:GetChildren()) do
					if acc:IsA("Accessory") then
						safeFireServer("Tools", "Remove", acc, playerChar)
					end
				end
			end
		end
	},
	{
		text = "👕 Remove Clothing",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then return end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if playerChar then
				local shirt = playerChar:FindFirstChildOfClass("Shirt")
				if shirt then safeFireServer("Tools", "Remove", shirt, playerChar) end
				local pants = playerChar:FindFirstChildOfClass("Pants")
				if pants then safeFireServer("Tools", "Remove", pants, playerChar) end
				local tshirt = playerChar:FindFirstChildOfClass("ShirtGraphic")
				if tshirt then safeFireServer("Tools", "Remove", tshirt, playerChar) end
			end
		end
	},
	{
		text = "👕 Remove T-Shirt",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then return end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if playerChar then
				local tshirt = playerChar:FindFirstChildOfClass("ShirtGraphic")
				if tshirt then safeFireServer("Tools", "Remove", tshirt, playerChar) end
			end
		end
	},
	{
		text = "🗑️ Clear All",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then return end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if playerChar then
				for _, acc in ipairs(playerChar:GetChildren()) do
					if acc:IsA("Accessory") then safeFireServer("Tools", "Remove", acc, playerChar) end
				end
				local shirt = playerChar:FindFirstChildOfClass("Shirt")
				if shirt then safeFireServer("Tools", "Remove", shirt, playerChar) end
				local pants = playerChar:FindFirstChildOfClass("Pants")
				if pants then safeFireServer("Tools", "Remove", pants, playerChar) end
				local tshirt = playerChar:FindFirstChildOfClass("ShirtGraphic")
				if tshirt then safeFireServer("Tools", "Remove", tshirt, playerChar) end
			end
		end
	},
	{
		text = "🎲 Random Outfit",
		action = function(targetPlayer)
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then return end
			local playerChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if not playerChar then return end

			for _, acc in ipairs(playerChar:GetChildren()) do
				if acc:IsA("Accessory") then safeFireServer("Tools", "Remove", acc, playerChar) end
			end
			local shirt = playerChar:FindFirstChildOfClass("Shirt")
			if shirt then safeFireServer("Tools", "Remove", shirt, playerChar) end
			local pants = playerChar:FindFirstChildOfClass("Pants")
			if pants then safeFireServer("Tools", "Remove", pants, playerChar) end
			local tshirt = playerChar:FindFirstChildOfClass("ShirtGraphic")
			if tshirt then safeFireServer("Tools", "Remove", tshirt, playerChar) end

			local accs = {}
			for _, item in ipairs(AccessoryFolder:GetChildren()) do
				if item:IsA("Accessory") then table.insert(accs, item) end
			end
			if #accs > 0 then safeFireServer("Tools", "Add", accs[math.random(1, #accs)], playerChar) end

			local shirts = getAllItemsOfClass("Shirt")
			if #shirts > 0 then safeFireServer("Tools", "Add", shirts[math.random(1, #shirts)], playerChar) end

			local pantsList = getAllItemsOfClass("Pants")
			if #pantsList > 0 then safeFireServer("Tools", "Add", pantsList[math.random(1, #pantsList)], playerChar) end

			local tshirts = getAllItemsOfClass("ShirtGraphic")
			if #tshirts > 0 then safeFireServer("Tools", "Add", tshirts[math.random(1, #tshirts)], playerChar) end
		end
	},
	{
		text = "📋 Copy My Outfit",
		action = function(targetPlayer)
			if targetPlayer == LocalPlayer then return end
			local myChar = LocalPlayer.Character
			if not myChar then return end
			local playersFolder = workspace:FindFirstChild("Players")
			if not playersFolder then return end
			local targetChar = playersFolder:FindFirstChild(targetPlayer.Name)
			if not targetChar then return end

			for _, acc in ipairs(targetChar:GetChildren()) do
				if acc:IsA("Accessory") then safeFireServer("Tools", "Remove", acc, targetChar) end
			end
			local shirt = targetChar:FindFirstChildOfClass("Shirt")
			if shirt then safeFireServer("Tools", "Remove", shirt, targetChar) end
			local pants = targetChar:FindFirstChildOfClass("Pants")
			if pants then safeFireServer("Tools", "Remove", pants, targetChar) end
			local tshirt = targetChar:FindFirstChildOfClass("ShirtGraphic")
			if tshirt then safeFireServer("Tools", "Remove", tshirt, targetChar) end

			for _, acc in ipairs(myChar:GetChildren()) do
				if acc:IsA("Accessory") then
					local handle = acc:FindFirstChild("Handle")
					local mesh = handle and handle:FindFirstChildOfClass("SpecialMesh")
					local meshId = mesh and mesh.MeshId or ""
					local textureId = mesh and mesh.TextureId or ""
					for _, stored in ipairs(AccessoryFolder:GetChildren()) do
						if stored:IsA("Accessory") then
							local shandle = stored:FindFirstChild("Handle")
							local smesh = shandle and shandle:FindFirstChildOfClass("SpecialMesh")
							if smesh and smesh.MeshId == meshId and smesh.TextureId == textureId then
								safeFireServer("Tools", "Add", stored, targetChar)
								break
							end
						end
					end
				end
			end

			local myShirt = myChar:FindFirstChildOfClass("Shirt")
			if myShirt then
				local template = myShirt.ShirtTemplate
				local shirts = getAllItemsOfClass("Shirt")
				for _, stored in ipairs(shirts) do
					if stored.ShirtTemplate == template then
						safeFireServer("Tools", "Add", stored, targetChar)
						break
					end
				end
			end

			local myPants = myChar:FindFirstChildOfClass("Pants")
			if myPants then
				local template = myPants.PantsTemplate
				local pantsList = getAllItemsOfClass("Pants")
				for _, stored in ipairs(pantsList) do
					if stored.PantsTemplate == template then
						safeFireServer("Tools", "Add", stored, targetChar)
						break
					end
				end
			end

			local myT = myChar:FindFirstChildOfClass("ShirtGraphic")
			if myT then
				local graphic = myT.Graphic
				local tshirts = getAllItemsOfClass("ShirtGraphic")
				for _, stored in ipairs(tshirts) do
					if stored.Graphic == graphic then
						safeFireServer("Tools", "Add", stored, targetChar)
						break
					end
				end
			end
		end
	},
}

-- CREATE TOOL BUTTONS
for _, tool in ipairs(toolsList) do
	local button = Instance.new("TextButton", toolsContent)
	button.Text = tool.text
	button.Font = Enum.Font.GothamSemibold
	button.TextSize = 14
	button.BackgroundColor3 = THEME.SECONDARY_BG
	button.TextColor3 = THEME.TEXT_PRIMARY
	Instance.new("UICorner", button).CornerRadius = THEME.BUTTON_RADIUS
	addOutline(button, 1)
	createGlowEffect(button)
	addSmoothHover(button)
	button.MouseButton1Click:Connect(function() tool.action(toolsTargetPlayer) end)
end

zButton.MouseButton1Click:Connect(function() toolsPopup.Visible = not toolsPopup.Visible end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Z then toolsPopup.Visible = not toolsPopup.Visible end
end)
