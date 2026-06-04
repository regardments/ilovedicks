---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local distance = self:distance(self.entity)

	local action = Action.new()
	action._when = math.min(300 + distance * 5)
	action._type = "Parry"
	action.hitbox = Vector3.new(20, 20, 130)
	action.name = string.format("Tornado Kick Timing", distance)

	return self:action(timing, action)
end
