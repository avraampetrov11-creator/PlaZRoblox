-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Core_Replication = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Core_Replication")

local LocalPlayer = Players.LocalPlayer

-- ScreenGui setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccessoryPanel"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main frame container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 350)
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

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Accessory Panel"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

-- Minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0.5, -15)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(1, 0)
minimizeCorner.Parent = minimizeBtn

-- ScrollingFrame for accessory icons
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 1, -55)
scrollingFrame.Position = UDim2.new(0, 10, 0, 45)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Parent = mainFrame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)
padding.Parent = scrollingFrame

local uiGrid = Instance.new("UIGridLayout")
uiGrid.CellSize = UDim2.new(0, 100, 0, 110)
uiGrid.CellPadding = UDim2.new(0, 10, 0, 10)
uiGrid.FillDirectionMaxCells = 4
uiGrid.SortOrder = Enum.SortOrder.LayoutOrder
uiGrid.Parent = scrollingFrame

-- Make scrolling work automatically
uiGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollingFrame.CanvasSize = UDim2.new(0, uiGrid.AbsoluteContentSize.X, 0, uiGrid.AbsoluteContentSize.Y)
end)

-- Store accessories we've already added
local accessoryButtons = {}

-- Function to create a button for an accessory
local function createAccessoryButton(accessory)
	if accessoryButtons[accessory] then return end
	accessoryButtons[accessory] = true

	local button = Instance.new("Frame")
	button.Size = UDim2.new(0, 100, 0, 110)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Name = accessory.Name
	button.Parent = scrollingFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = button

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Thickness = 1.5
	btnStroke.Color = Color3.fromRGB(90, 90, 90)
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.Parent = button

	-- Image for accessory
	local imageButton = Instance.new("ImageButton")
	imageButton.Size = UDim2.new(1, -10, 0, 80)
	imageButton.Position = UDim2.new(0, 5, 0, 5)
	imageButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	imageButton.Parent = button

	local imgCorner = Instance.new("UICorner")
	imgCorner.CornerRadius = UDim.new(0, 8)
	imgCorner.Parent = imageButton

	-- Try to get Roblox catalog thumbnail
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(accessory.AssetId)
	end)

	if success and info and info.AssetId then
		imageButton.Image = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", info.AssetId)
	else
		imageButton.Image = "rbxassetid://0" -- fallback
	end

	-- Label for accessory name
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

	-- Hover effect
	imageButton.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)
	imageButton.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end)

	-- Click connection
	imageButton.MouseButton1Click:Connect(function()
		local character = LocalPlayer.Character
		if character then
			Core_Replication:FireServer("Tools", "Add", accessory, character)
		end
	end)
end

-- Function to add accessories for a player
local function addPlayerAccessories(player)
	player.CharacterAdded:Connect(function(char)
		task.wait(1)
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

Players.PlayerAdded:Connect(addPlayerAccessories)

-- Close & minimize logic
closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	if minimized then
		scrollingFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 450, 0, 350)
		minimized = false
	else
		scrollingFrame.Visible = false
		mainFrame.Size = UDim2.new(0, 450, 0, 50)
		minimized = true
	end
end)
