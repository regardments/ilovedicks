---@class Action
local Action = getfenv().Action

---Module function for Jus Karita uppercut.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 150
	action._type = "Parry"
	action.hitbox = Vector3.new(14, 20, 16)
	action.name = "Jus Karita Uppercut"
	return self:action(timing, action)
end
