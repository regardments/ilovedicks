---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local distance = self:distance(self.entity)
	local action = Action.new()
	action._when = 1100
	if distance >= 10 then
		action._when = math.min(1290 + distance * 5.2, 3500)
	end
	action._type = "Parry"
	action.hitbox = Vector3.new(160, 120, 160)
	action.name = string.format("(%.2f) Dynamic Duke Grasp Timing", distance)
	return self:action(timing, action)
end
