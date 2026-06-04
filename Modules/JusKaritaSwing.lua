---@class Action
local Action = getfenv().Action

---Module function for Jus Karita swing.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 0
	action._type = "Parry"
	action.hitbox = Vector3.new(12, 12, 18)
	action.name = "Jus Karita Swing"
	return self:action(timing, action)
end
