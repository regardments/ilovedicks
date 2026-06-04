---@class Action
local Action = getfenv().Action

---Module function for Duke arrow attack.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 350
	action._type = "Parry"
	action.hitbox = Vector3.new(15, 15, 30)
	action.name = "Duke Arrow"
	return self:action(timing, action)
end
