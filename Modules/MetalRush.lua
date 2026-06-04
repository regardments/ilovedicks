---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.duih = true
	timing.iae = true
	timing.ieae = true

	local distance = self:distance(self.entity)

	-- Close range: smaller Z hitbox.
	if distance <= 30 then
		timing.hitbox = Vector3.new(27, 14, 14)
	else
		timing.hitbox = Vector3.new(27, 14, 18.5)
	end

	local action = Action.new()
	action._when = 450
	action._type = "Start Block"
	action.name = string.format("(%.2f) Dynamic Metal Rush Start", distance)
	self:action(timing, action)

	local endAction = Action.new()
	endAction._when = 1300
	endAction._type = "End Block"
	endAction.name = "Metal Rush End"
	self:action(timing, endAction)
end
