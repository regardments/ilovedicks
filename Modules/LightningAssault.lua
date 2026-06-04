---@type Action
local Action = getfenv().Action

---@module Modules.Globals.Mantra
local Mantra = getfenv().Mantra

---@module Features.Combat.Objects.RepeatInfo
local RepeatInfo = getfenv().RepeatInfo

---@module Game.Latency
local Latency = getfenv().Latency

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	-- Skip if we cast it.
	if self.entity == game.Players.LocalPlayer.Character then
		return
	end

	if self.entity.Name:match("evengarde") then
		-- Skip if entity has WhisperAnchored.
		if self.entity:FindFirstChild("WhisperAnchored", true) then
			return
		end

		-- Skip if WindPassage sound is already playing (appears instantly for WindPassage, delayed for Lightning Assault).
		for _, desc in next, self.entity:GetDescendants() do
			if desc:IsA("Sound") and desc.SoundId == "rbxassetid://4681649274" and desc.IsPlaying then
				return
			end
		end

		timing.ieae = true
		timing.iae = true
		timing.mat = 4000
		timing.ndfb = true
		timing.nvfb = true
		timing.nbfb = true
		timing.rpue = true
		timing._rsd = 500
		timing._rpd = 150
		timing.hitbox = Vector3.new(55, 55, 55)

		local info = RepeatInfo.new(timing, Latency.rdelay(), self:uid(10))
		info.track = self.track
		return self:srpue(self.entity, timing, info)
	end

	local data = Mantra.data(self.entity, "Mantra:StrikeLightning{{Lightning Assault}}")
	local range = data.stratus * 2 + data.cloud * 1
	local distance = self:distance(self.entity)

	local action = Action.new()
	action._when = math.min(400 + distance * 3, 1500)
	action._type = "Parry"
	action.hitbox = Vector3.new(35, 35, 50 + range)
	action.name = string.format("(%.2f) Dynamic Lightning Assault Timing", distance)

	return self:action(timing, action)
end
