---@class Action
local Action = getfenv().Action

---@module Modules.Globals.TetherBoxTracker
local TetherBoxTracker = getfenv().TetherBoxTracker

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	TetherBoxTracker.watch(self, timing, 10)

	local action = Action.new()
	action._when = 1750
	action._type = "Parry"
	action.hitbox = Vector3.new(118, 115, 118)
	action.name = "Wind Forge Timing"
	return self:action(timing, action)
end
