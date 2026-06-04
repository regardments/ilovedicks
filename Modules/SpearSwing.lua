---@class Action
local Action = getfenv().Action

---Module function for basic spear M1 swings.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 0
	action._type = "Parry"
	action.hitbox = Vector3.new(10, 10, 20)
	action.name = "Spear Swing"
	return self:action(timing, action)
end
