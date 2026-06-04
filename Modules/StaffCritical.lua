---@class Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.fhb = false
	timing.hso = 0
	timing.pfh = true
	timing.phd = true
	timing.pfht = 0.3
	timing.phds = 1.0

	local action = Action.new()
	action._when = 450
	action._type = "Parry"
	action.hitbox = Vector3.new(23, 30, 23)
	action.name = "Static Staff Critical"
	self:action(timing, action)

	local actionTwo = Action.new()
	actionTwo._when = 1150
	actionTwo._type = "Parry"
	actionTwo.hitbox = Vector3.new(23, 30, 23)
	actionTwo.name = "Static Staff Critical Backup"
	return self:action(timing, actionTwo)
end
