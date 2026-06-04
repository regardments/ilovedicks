---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.htype = Enum.PartType.Ball

	local action = Action.new()
	action._when = 370
	action._type = "Parry"
	action.hitbox = Vector3.new(16, 16, 16)
	action.name = "Inferno M1"
	return self:action(timing, action)
end
