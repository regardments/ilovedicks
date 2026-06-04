---@class Action
local Action = getfenv().Action

---Module function for greatsword uppercut.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 200
	action._type = "Parry"
	action.hitbox = Vector3.new(14, 20, 18)
	action.name = "Greatsword Uppercut"
	return self:action(timing, action)
end
