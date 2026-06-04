---@class Action
local Action = getfenv().Action

---Module function for BoneBoy running attack.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 200
	action._type = "Parry"
	action.hitbox = Vector3.new(15, 15, 25)
	action.name = "BoneBoy Run"
	return self:action(timing, action)
end
