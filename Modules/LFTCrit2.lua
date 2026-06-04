---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local rightHand = self.entity:FindFirstChild("RightHand")
	if not rightHand then return end
	local handWeapon = rightHand:FindFirstChild("HandWeapon")
	if not handWeapon then return end

	local critical = handWeapon:GetAttribute("Critical")

	if critical == "The Death Knell" then
		local action = Action.new()
		action._when = 160
		action._type = "Parry"
		action.hitbox = Vector3.new(20, 31, 25)
		action.name = "Death Knell Crit2 (1)"
		self:action(timing, action)

		local actionTwo = Action.new()
		actionTwo._when = 400
		actionTwo._type = "Parry"
		actionTwo.hitbox = Vector3.new(20, 31, 25)
		actionTwo.name = "Death Knell Crit2 (2)"
		return self:action(timing, actionTwo)
	end

	local action = Action.new()
	action._when = 400
	action._type = "Parry"
	action.hitbox = Vector3.new(20, 31, 25)
	action.name = "LFT Crit2"
	return self:action(timing, action)
end
