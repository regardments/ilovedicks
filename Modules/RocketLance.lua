---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.duih = true

	local distance = self:distance(self.entity)
	local action = Action.new()
	action._when = 350
	action._type = "Parry"
	action.name = string.format("(%.2f) Dynamic Rocket Lance Timing", distance)
	return self:action(timing, action)
end
