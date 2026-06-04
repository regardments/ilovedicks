---@class Action
local Action = getfenv().Action

---Module function for Lightning impact.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 200
	action._type = "Parry"
	action.hitbox = Vector3.new(25, 25, 25)
	action.name = "Lightning Impact"
	return self:action(timing, action)
end
