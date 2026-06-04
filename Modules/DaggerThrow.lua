---@type Action
local Action = getfenv().Action

---@type ProjectileTracker
---@diagnostic disable-next-line: unused-local
local ProjectileTracker = getfenv().ProjectileTracker

---@module Game.Latency
local Latency = getfenv().Latency

---Check if orbs have all been destroyed.
local function areOrbsStillAlive(orbs)
	for _, orb in next, orbs do
		if not orb.Parent then
			continue
		end

		if not orb:FindFirstChild("PointLight") then
			continue
		end

		return true
	end

	return false
end

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local thrown = workspace:FindFirstChild("Thrown")
	if not thrown then
		return
	end

	task.wait(0.7 - Latency.rtt())

	local orbs = {}

	for _, part in pairs(thrown:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		if not part.Name:match("LightningMote") then
			continue
		end

		orbs[#orbs + 1] = part
	end

	local blockStarted = false

	while task.wait() do
		for _, orb in next, orbs do
			if not areOrbsStillAlive(orbs) then
				local secondAction = Action.new()
				secondAction._when = 0
				secondAction._type = "End Block"
				secondAction.name = "Fleeting Sparks End"
				secondAction.ihbc = true
				return self:action(timing, secondAction)
			end

			if not orb or not orb.Parent then
				continue
			end

			if self:distance(orb) >= 50 then
				continue
			end

			if blockStarted then
				continue
			end

			local action = Action.new()
			action._when = 0
			action._type = "Start Block"
			action.name = "Fleeting Sparks Start"
			action.ihbc = true
			self:action(timing, action)

			blockStarted = true
		end
	end
end
