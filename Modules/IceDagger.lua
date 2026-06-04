---@type Action
local Action = getfenv().Action

-- Services.
local players = game:GetService("Players")

---Module function.
---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
	local character = players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Skip if from local player.
	local dist = (root.Position - self.part.Position).Magnitude
	if dist <= 1 then
		self:notify(timing, "Skipped (from local player, dist: %.1f)", dist)
		return
	end

	timing.ndfb = true

	local action = Action.new()
	action._type = "Parry"
	action._when = 0
	action.name = "IceDagger"
	return self:action(timing, action)
end
