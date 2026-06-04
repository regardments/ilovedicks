---@class Action
local Action = getfenv().Action

---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local windup = 400

	if self.entity and self.entity.Name:lower():match("titus") then
		windup = 300
		self:notify(timing, "Titus Vent Windup")
	end

	local action = Action.new()
	action._when = windup
	action._type = "Parry"
	action.name = "Titus Vent"
	action.hitbox = timing.hitbox

	return self:action(timing, action)
end
