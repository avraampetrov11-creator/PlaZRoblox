-- I WARNED, YOU ALL. YOU'VE IGNORED NOW YOUL LIFES WILL FALL. AS FOR. MY NAME, REPUTATIONS ARLEADY BEEN STAINED. AW SHUCKS!
-- Plasmablake

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core_Replication = ReplicatedStorage.Events.Core_Replication
local LocalPlayer = Players.LocalPlayer

local CreateNewMeshCMD = Instance.new("TextChatCommand")
CreateNewMeshCMD.Name = "SpeedCommand"
CreateNewMeshCMD.PrimaryAlias = "!CreateNewMesh"
CreateNewMeshCMD.Parent = TextChatService

CreateNewMeshCMD.Triggered:Connect(function(textSource, message)
    if textSource.UserId == LocalPlayer.UserId then
        local args = string.split(message, " ")
        table.remove(args, 1))

        local PlayerName = args[1]
        local AffectedPlayer = game.Players:FindFirstChild(PlayerName)

        if AffectedPlayer then
            print("Found player: " .. affectedPlayer.Name)
        else
            warn("Player not found: " .. tostring(playerName))
        end
    end
end)


