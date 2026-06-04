---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.duih = true

	local distance = self:distance(self.entity)
	local action = Action.new()
	action._when = 500
	action._type = "Parry"
	action.name = string.format("(%.2f) Dynamic Metal Drop Kick Timing", distance)
	return self:action(timing, action)
end
