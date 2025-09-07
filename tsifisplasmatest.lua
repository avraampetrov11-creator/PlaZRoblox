-- LocalScript

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- References
local SubterPhase2 = ReplicatedStorage:FindFirstChild("2017XPhase2")
local LocalPlayer = Players.LocalPlayer

-- Safety check
if not SubterPhase2 or not LocalPlayer then
    warn("SubterPhase2 or LocalPlayer not found!")
    return
end

-- Fire immediately (or you can put this inside a function / input check)
SubterPhase2:FireServer()
