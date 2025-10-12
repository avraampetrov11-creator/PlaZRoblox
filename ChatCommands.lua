local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")

TextChatService.OnIncomingMessage = function(message)
    local args = string.split(message.Text:lower(), " ")
    if args[1] == "/walkspeed" and args[2] then
        local speed = tonumber(args[2])
        if speed then
            updateWalkSpeed(speed)
            message.Text = "Walkspeed set to " .. speed
        else
            message.Text = "Use a number for walkspeed"
        end
    elseif args[1] == "/jumpspeed" and args[2] then
        local jump = tonumber(args[2])
        if jump then
            updateJumpSpeed(jump)
            message.Text = "Jumpspeed set to " .. jump
        else
            message.Text = "Use a number for jumpspeed"
        end
    end
end

