---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local distance = self:distance(self.entity)
	local action = Action.new()
	action._when = math.min(400 + distance * 7.5)
	action._type = "Parry"
	action.hitbox = Vector3.new(45, 20, 75)
	action.name = string.format("(%.2f) Dynamic Crimson Rain Timing", distance)
	return self:action(timing, action)
end
