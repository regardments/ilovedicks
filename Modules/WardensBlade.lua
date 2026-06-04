---@module Features.Combat.Objects.RepeatInfo
local RepeatInfo = getfenv().RepeatInfo

---@module Game.Latency
local Latency = getfenv().Latency

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	self:hook("rc", function(_)
		local center = self.entity:FindFirstChild("IceBladeCenter")
		if not center then
			return
		end

		if not center:FindFirstChild("IceSword") then
			return
		end

		return true
	end)

	---@todo: FIXME: I can be movestacked but need to also have a hook
	local info = RepeatInfo.new(timing, Latency.rdelay(), self:uid(10))
	info.track = self.track
	timing.fhb = false
	timing.ieae = true
	timing.iae = true
	timing.rpue = true
	timing.duih = true
	timing.imdd = 0
	timing.imxd = 100
	timing._rsd = 750
	timing._rpd = 400
	timing.hitbox = Vector3.new(15, 15, 15)
	self:srpue(self.entity, timing, info)
end
