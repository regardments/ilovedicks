---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	if self.entity.Name:match("evengarde") then
		timing.ieae = true
		timing.iae = true

		local action = Action.new()
		action._type = "Parry"
		action._when = 850
		action.hitbox = Vector3.new(55, 55, 55)
		action.name = "Maestro Heavenly Wind Timing"

		return self:action(timing, action)
	end

	_G.HeavenlyWindPending = {
		entity = self.entity,
		time = os.clock()
	}

	while task.wait() do

		if _G.GaleLeap3Received and _G.GaleLeap3Received.entity == self.entity then
			_G.GaleLeap3Received = nil
			_G.HeavenlyWindPending = nil

			local startBlock = Action.new()
			startBlock._type = "Start Block"
			startBlock._when = 150
			startBlock.ihbc = true
			startBlock.name = "Heavenly Wind (GaleLeap3) Start Block"
			self:action(timing, startBlock)

			local endBlock = Action.new()
			endBlock._type = "End Block"
			endBlock._when = 300
			endBlock.ihbc = true
			endBlock.name = "Heavenly Wind (GaleLeap3) End Block"
			self:action(timing, endBlock)

			return
		end
	end
end
