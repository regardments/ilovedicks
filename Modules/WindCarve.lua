---@type Action
local Action = getfenv().Action

---@module Modules.Globals.Mantra
local Mantra = getfenv().Mantra

---@type Signal
local Signal = getfenv().Signal

---@type HitboxOptions
local HitboxOptions = getfenv().HitboxOptions

---@module Game.Latency
local Latency = getfenv().Latency

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local data = Mantra.data(self.entity, "Mantra:CarveWind{{Wind Carve}}")
	local range = data.stratus * 1.4 + data.cloud * 0.9

	timing.ffh = true
	timing.pfh = true
	timing.fhb = true
	timing.rpue = false
	timing.duih = true
	timing.hitbox = Vector3.new(20 + range, 20 + range, 13.5 + range)

	local root = self.entity:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	-- Set up End Block listener before waiting.
	local onDescendantAdded = Signal.new(self.entity.DescendantAdded)

	self.tmaid:add(onDescendantAdded:connect("WindCarve_StopCarve", function(child)
		if child.Name == "StopCarve" then
			local actionTwo = Action.new()
			actionTwo._when = 0
			actionTwo._type = "End Block"
			actionTwo.ihbc = true
			actionTwo.name = "Wind Carve End"
			self:action(timing, actionTwo)
		end
	end))

	-- Wait initial delay.
	task.wait(0.6 - Latency.rtt())

	-- Wait until in hitbox.
	local hoptions = HitboxOptions.new(root, timing)
	hoptions.spredict = false
	hoptions.entity = self.entity
	hoptions:ucache()

	while task.wait() do
		if self:hc(hoptions, nil) then
			break
		end
	end

	-- Start block.
	local action = Action.new()
	action._when = 0
	action._type = "Start Block"
	action.ihbc = true
	action.name = "Wind Carve Start"
	self:action(timing, action)
end
