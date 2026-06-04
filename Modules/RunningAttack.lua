---@class Action
local Action = getfenv().Action

---Module function for generic running attack.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 150
	action._type = "Parry"
	action.hitbox = Vector3.new(12, 12, 20)
	action.name = "Running Attack"
	return self:action(timing, action)
end
