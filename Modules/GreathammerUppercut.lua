---@class Action
local Action = getfenv().Action

---Module function for greathammer uppercut.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 200
	action._type = "Parry"
	action.hitbox = Vector3.new(15, 20, 18)
	action.name = "Greathammer Uppercut"
	return self:action(timing, action)
end
