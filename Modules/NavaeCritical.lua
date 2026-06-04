---@class Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 700
	action._type = "Parry"
	action.hitbox = Vector3.new(10, 10, 15)
	action.name = "Static Navae Critical"
	return self:action(timing, action)
end
