-- Define target player
local target = workspace:WaitForChild("Players"):WaitForChild("AvraamPetroman")

-- Add MeshPartAccessory.Handle.SpecialMesh to the target's Ruler.Handle
game.ReplicatedStorage.Events.Core_Replication:FireServer(
    "Tools",
    "Add",
    game:GetService("ReplicatedStorage").Misc.Answer_Types.Answer_Types.MeshPartAccessory.Handle.SpecialMesh,
    target.Ruler.Handle
)

-- Set transparency values
game.ReplicatedStorage.Events.Core_Replication:FireServer("Change_Transparency", target.Ruler.Handle, 0)
game.ReplicatedStorage.Events.Core_Replication:FireServer("Change_Transparency", target.Ruler.Ruler, 1)

-- Clear children of target.Ruler.Ruler
for _, child in ipairs(target.Ruler.Ruler:GetChildren()) do
    game.ReplicatedStorage.Events.Core_Replication:FireServer("Tools", "Remove", child)
end
