-- LocalScript inside StarterPlayerScripts
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer

-- Create a custom command (/speed)
local speedCommand = Instance.new("TextChatCommand")
speedCommand.Name = "SpeedCommand"
speedCommand.PrimaryAlias = "/speed"
speedCommand.SecondaryAlias = "/walkspeed"
speedCommand.Parent = TextChatService

-- Handle when command is triggered
speedCommand.Triggered:Connect(function(textSource, message)
    -- Only run for the local player
    if textSource.UserId == LocalPlayer.UserId then
        local args = string.split(message, " ")
        table.remove(args, 1) -- remove the alias (/speed)

        local amount = tonumber(args[1]) or 16
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = amount
        end
    end
end)

-- Another example: /jump
local jumpCommand = Instance.new("TextChatCommand")
jumpCommand.Name = "JumpCommand"
jumpCommand.PrimaryAlias = "/jump"
jumpCommand.Parent = TextChatService

jumpCommand.Triggered:Connect(function(textSource, message)
    if textSource.UserId == LocalPlayer.UserId then
        local args = string.split(message, " ")
        table.remove(args, 1)

        local amount = tonumber(args[1]) or 50
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = amount
        end
    end
end)
