---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local distance = self:distance(self.entity)

	if distance < 10 then
		timing.duih = false

		local action = Action.new()
		action._when = 470
		action._type = "Parry"
		action.ihbc = true
		action.name = "Jetstriker Kick Close"
		return self:action(timing, action)
	elseif distance <= 29 then
		timing.duih = false

		local startBlock = Action.new()
		startBlock._when = 400
		startBlock._type = "Start Block"
		startBlock.ihbc = true
		startBlock.name = "Jetstriker Kick Mid Start Block"
		self:action(timing, startBlock)

		local endBlock = Action.new()
		endBlock._when = 700
		endBlock._type = "End Block"
		endBlock.ihbc = true
		endBlock.name = "Jetstriker Kick Mid End Block"
		return self:action(timing, endBlock)
	else
		task.wait(0.45)

		timing.duih = true
		timing.fhb = true

		local actionFar = Action.new()
		actionFar._when = 0
		actionFar._type = "Parry"
		actionFar.hitbox = Vector3.new(23, 20, 29)
		actionFar.name = "Jetstriker Kick Far"
		return self:action(timing, actionFar)
	end
end
