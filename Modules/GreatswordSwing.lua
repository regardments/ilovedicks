---@class Action
local Action = getfenv().Action

---Module function for basic greatsword M1 swings.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 0
	action._type = "Parry"
	action.hitbox = Vector3.new(12, 12, 18)
	action.name = "Greatsword Swing"
	return self:action(timing, action)
end
