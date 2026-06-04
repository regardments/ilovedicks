---@class Action
local Action = getfenv().Action

---Module function for spear uppercut.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 150
	action._type = "Parry"
	action.hitbox = Vector3.new(12, 18, 16)
	action.name = "Spear Uppercut"
	return self:action(timing, action)
end
