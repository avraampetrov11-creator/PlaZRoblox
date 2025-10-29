-- AW SHUCKS

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait for character and humanoid
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Wait for PunchButton safely
local punchButton = player:WaitForChild("PlayerGui")
	:WaitForChild("TouchGui")
	:WaitForChild("TouchControlFrame")
	:WaitForChild("JumpButton")
	:WaitForChild("PunchButton")

-- Custom animations
local ANIM_A = "rbxassetid://125955606488863"
local ANIM_B = "rbxassetid://109617620932970"
local ANIM_SPEED = 1.4 -- playback speed

local trackA, trackB
local nextIsA = true

-- Stop both custom animations if playing
local function stopCustomTracks()
	if trackA and trackA.IsPlaying then
		trackA:Stop()
	end
	if trackB and trackB.IsPlaying then
		trackB:Stop()
	end
end

-- Play an animation at the set speed
local function playAnim(animId)
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local track = humanoid:LoadAnimation(anim)
	track:Play()
	track:AdjustSpeed(ANIM_SPEED)
	return track
end

-- Alternate between A and B on each click
punchButton.MouseButton1Click:Connect(function()
	stopCustomTracks()

	if nextIsA then
		trackA = playAnim(ANIM_A)
	else
		trackB = playAnim(ANIM_B)
	end

	nextIsA = not nextIsA
end)
