---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	repeat
		task.wait()
	until self.track.TimePosition >= 0.45

	local action = Action.new()
	action._when = 0
	action._type = "Dodge"
	action.hitbox = Vector3.new(40, 40, 40)
	action.name = string.format("(%.2f) Dynamic Spider Bite Timing", self.track.Speed)

	if self.entity.Name:match(".miniwidow") then
		action.hitbox /= 3.0
	end
	self:action(timing, action)
end
