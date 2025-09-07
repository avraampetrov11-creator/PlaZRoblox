-- UniversalAccessoryGiver.lua
-- Put as a Script (ServerScriptService) OR the same code as a LocalScript (StarterPlayerScripts).
-- It will detect environment and behave accordingly.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Server-only services (won't be used by the client branch)
local InsertService = game:GetService("InsertService")
local ServerStorage = game:GetService("ServerStorage")

-- ======== CONFIG ========
local accessoryId = 84285572503442 -- replace with your accessory's ID
local remoteName = "RequestAccessoryRF" -- RemoteFunction name used to request the accessory from client
-- ========================

local function findAccessory(root)
	-- look for Accessory (and older Hat objects) anywhere in the loaded asset
	for _, v in ipairs(root:GetDescendants()) do
		if v:IsA("Accessory") or v:IsA("Hat") then
			return v
		end
	end
	return nil
end

if RunService:IsServer() then
	-- === SERVER BRANCH ===
	-- Create RemoteFunction if missing
	local remote = ReplicatedStorage:FindFirstChild(remoteName)
	if not remote then
		remote = Instance.new("RemoteFunction")
		remote.Name = remoteName
		remote.Parent = ReplicatedStorage
	end

	-- folder to keep cached templates
	local templateFolder = ServerStorage:FindFirstChild("AccessoryTemplates")
	if not templateFolder then
		templateFolder = Instance.new("Folder")
		templateFolder.Name = "AccessoryTemplates"
		templateFolder.Parent = ServerStorage
	end

	local templateName = "Accessory_" .. tostring(accessoryId)
	local template = templateFolder:FindFirstChild(templateName)

	local function tryLoadTemplate()
		-- if already cached, return it
		if template and template.Parent then
			return true, template
		end

		-- pcall around LoadAsset to capture exact error
		local ok, resultOrErr = pcall(function()
			return InsertService:LoadAsset(accessoryId)
		end)

		if not ok then
			-- resultOrErr is the error message/string from the pcall
			return false, ("InsertService:LoadAsset failed for id %s — %s"):format(tostring(accessoryId), tostring(resultOrErr))
		end

		if not resultOrErr then
			return false, ("InsertService returned nil for id %s"):format(tostring(accessoryId))
		end

		local acc = findAccessory(resultOrErr)
		if not acc then
			-- destroy loaded temporary model to avoid clutter
			resultOrErr:Destroy()
			return false, ("No Accessory/Hat found inside loaded asset for id %s (checked descendants)."):format(tostring(accessoryId))
		end

		-- clone accessory to ServerStorage for safe reuse
		local accClone = acc:Clone()
		accClone.Name = templateName
		accClone.Parent = templateFolder
		-- destroy the temporary loaded model
		resultOrErr:Destroy()

		template = accClone
		return true, template
	end

	-- Give accessory to a single player (returns success(boolean), message(string))
	local function giveToPlayer(player)
		-- Ensure template exists (lazy load)
		local ok, loadedOrMsg = tryLoadTemplate()
		if not ok then
			return false, loadedOrMsg -- exact error message from load
		end
		-- Wait for character, then attach; protect with pcall to capture errors exactly
		local char = player.Character
		if not char then
			-- Wait up to a short period for character (avoid infinite wait)
			char = player.CharacterAdded:Wait()
		end

		local okAttach, attachErr = pcall(function()
			local newAcc = loadedOrMsg:Clone()
			newAcc.Parent = char
		end)

		if not okAttach then
			return false, ("Failed to attach accessory to %s — %s"):format(player.Name, tostring(attachErr))
		end

		return true, ("Accessory id %s attached to %s"):format(tostring(accessoryId), player.Name)
	end

	-- Automatic give when players join
	Players.PlayerAdded:Connect(function(player)
		-- Preload template if missing, capturing exact error
		local okLoad, loadResult = tryLoadTemplate()
		if not okLoad then
			warn(("Server Error: could not load accessory id %s for player %s — %s"):format(tostring(accessoryId), player.Name, tostring(loadResult)))
			return
		end

		-- Attach on CharacterAdded
		player.CharacterAdded:Connect(function(char)
			local ok, msg = pcall(function()
				local newAcc = loadResult:Clone()
				newAcc.Parent = char
			end)

			if not ok then
				warn(("Server Error: failed to attach accessory id %s to %s on spawn — %s"):format(tostring(accessoryId), player.Name, tostring(msg)))
			end
		end)

		-- If already present, attach immediately
		if player.Character then
			local okAttach, errAttach = pcall(function()
				local newAcc = loadResult:Clone()
				newAcc.Parent = player.Character
			end)
			if not okAttach then
				warn(("Server Error: failed to attach accessory id %s to %s (already spawned) — %s"):format(tostring(accessoryId), player.Name, tostring(errAttach)))
			end
		end
	end)

	-- RemoteFunction handler: clients can request the accessory explicitly
	remote.OnServerInvoke = function(requestingPlayer)
		local ok, res = giveToPlayer(requestingPlayer)
		if ok then
			return { success = true, message = ("Server: %s"):format(res) }
		else
			-- return the exact server-side error string
			return { success = false, message = ("Server Error while processing request from %s: %s"):format(requestingPlayer.Name, tostring(res)) }
		end
	end

	-- Try to preload at server start and print exact outcome
	local okStart, startRes = tryLoadTemplate()
	if not okStart then
		warn(("Server startup: Failed to load accessory id %s — %s"):format(tostring(accessoryId), tostring(startRes)))
	else
		print(("Server startup: Accessory id %s loaded and cached."):format(tostring(accessoryId)))
	end

else
	-- === CLIENT BRANCH === (LocalScript)
	-- The client cannot use InsertService for this; it must ask the server.
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local remote = ReplicatedStorage:FindFirstChild(remoteName)
	if not remote then
		warn(("Client Error: RemoteFunction %s not found in ReplicatedStorage. Make sure a server script created it."):format(remoteName))
		return
	end

	-- Call the server and capture the exact error if any
	local ok, resultOrErr = pcall(function()
		return remote:InvokeServer()
	end)

	if not ok then
		-- network or runtime error (server code raised an error not handled)
		warn(("Client Error: InvokeServer failed while requesting accessory id %s — %s"):format(tostring(accessoryId), tostring(resultOrErr)))
		return
	end

	-- The server returns a table { success = bool, message = string }
	if type(resultOrErr) == "table" and resultOrErr.message then
		if resultOrErr.success then
			print(("Client: Success — %s"):format(resultOrErr.message))
		else
			warn(("Client: Server returned error while requesting accessory id %s — %s"):format(tostring(accessoryId), tostring(resultOrErr.message)))
		end
	else
		warn(("Client: Unexpected server response while requesting accessory id %s — %s"):format(tostring(accessoryId), tostring(resultOrErr)))
	end
end

