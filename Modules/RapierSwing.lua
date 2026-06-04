---@class Action
local Action = getfenv().Action

---Module function for rapier swing.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 0
	action._type = "Parry"
	action.hitbox = Vector3.new(8, 8, 15)
	action.name = "Rapier Swing"
	return self:action(timing, action)
end
