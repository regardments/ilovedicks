---@class Action
local Action = getfenv().Action

---Module function for Lightning charge up.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 500
	action._type = "Parry"
	action.hitbox = Vector3.new(20, 20, 25)
	action.name = "Lightning Charge Up"
	return self:action(timing, action)
end
