---@type Action
local Action = getfenv().Action

---@module Modules.Globals.Mantra
local Mantra = getfenv().Mantra

---@type HitboxOptions
local HitboxOptions = getfenv().HitboxOptions

---@module Game.Latency
local Latency = getfenv().Latency

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local data = Mantra.data(self.entity, "Mantra:CarveIce{{Ice Carve}}")
	local range = data.stratus * 1.4 + data.cloud * 0.9

	timing.ffh = true
	timing.pfh = true
	timing.fhb = true
	timing.rpue = false
	timing.duih = true
	timing.hitbox = Vector3.new(20 + range, 25 + range, 12 + range)

	local root = self.entity:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	-- Wait initial delay.
	task.wait(0.57 - Latency.rtt())

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
	action.name = "Ice Carve Start"
	self:action(timing, action)

	-- Wait for animation end.
	local humanoid = self.entity:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	repeat
		task.wait()
	until not self.track.IsPlaying

	local activeAnim = nil

	for _, animTrack in next, humanoid:GetPlayingAnimationTracks() do
		if animTrack.Animation.AnimationId ~= "rbxassetid://15714151635" then
			continue
		end

		activeAnim = animTrack
		break
	end

	if activeAnim then
		repeat
			task.wait()
		until not activeAnim.IsPlaying

		task.wait(0.7)
	end

	-- End block.
	local actionEnd = Action.new()
	actionEnd._when = 0
	actionEnd._type = "End Block"
	actionEnd.ihbc = true
	actionEnd.name = "Ice Carve End"
	self:action(timing, actionEnd)
end
