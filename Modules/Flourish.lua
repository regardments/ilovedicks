---@class Action
local Action = getfenv().Action

---Module function for flourish attacks.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.ffh = true

	local action = Action.new()
	action._when = 350
	action._type = "Parry"
	action.hitbox = Vector3.new(15, 15, 20)
	action.name = "Flourish"
	return self:action(timing, action)
end
