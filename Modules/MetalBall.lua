---@type Action
local Action = getfenv().Action

---@module Game.Latency
local Latency = getfenv().Latency

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.ieae = true
	timing.iae = true

	task.wait(0.5 - Latency.rtt())

	-- Wait for SpikeBall (partial match, can have number suffix).
	local spikeBall = nil
	local isBlocking = false

	while task.wait() do
		if not spikeBall then
			for _, child in next, self.entity:GetChildren() do
				if child.Name:match("^SpikeBall") then
					spikeBall = child
					break
				end
			end
			if not spikeBall then
				continue
			end
		end

		if not spikeBall.Parent then
			local endAction = Action.new()
			endAction._when = 0
			endAction._type = "End Block"
			endAction.ihbc = true
			endAction.name = "Metal Ball End"
			return self:action(timing, endAction)
		end

		if isBlocking then
			continue
		end

		if self:distance(self.entity) >= 30 then
			continue
		end

		local action = Action.new()
		action._when = 0
		action.ihbc = true
		action._type = "Start Block"
		action.name = "Metal Ball Block"
		self:action(timing, action)

		isBlocking = true
	end
end
