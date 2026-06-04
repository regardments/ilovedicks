---@class Action
local Action = getfenv().Action

---Module function for Twister Kicks.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 100
	action._type = "Parry"
	action.hitbox = Vector3.new(12, 15, 15)
	action.name = "Twister Kicks"
	return self:action(timing, action)
end
