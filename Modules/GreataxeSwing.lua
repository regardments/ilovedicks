---@class Action
local Action = getfenv().Action

---Module function for greataxe swing.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 0
	action._type = "Parry"
	action.hitbox = Vector3.new(14, 14, 20)
	action.name = "Greataxe Swing"
	return self:action(timing, action)
end
