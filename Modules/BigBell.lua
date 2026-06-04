---@class Action
local Action = getfenv().Action

---@module Utility.Finder
local Finder = getfenv().Finder

-- Services.
local players = game:GetService("Players")

---Module function.
---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
	if Finder.entity("knell") then
		return
	end

	local localChar = players.LocalPlayer.Character
	if not localChar then
		return
	end

	local handWeapon = localChar:FindFirstChild("RightHand") and localChar.RightHand:FindFirstChild("HandWeapon")
	if handWeapon then
		local critical = handWeapon:GetAttribute("Critical")
		if critical == "Dissonantcall" then
			local humanoid = localChar:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
			if animator then
				for _, track in next, animator:GetPlayingAnimationTracks() do
					if track.Animation and track.Animation.AnimationId:match("75972447119162") then
						self:notify(timing, "Skipped - local player crit")
						return
					end
				end
			end
		end
	end

	self:notify(timing, "Big Bell detected")

	timing.duih = true
	timing.fhb = false
	timing.hso = 0
	timing.hitbox = Vector3.new(20, 20, 20)

	local action = Action.new()
	action._when = 500
	action._type = "Dodge"
	action.hitbox = Vector3.new(20, 20, 20)
	action.name = "Dynamic Big Bell Timing"
	return self:action(timing, action)
end