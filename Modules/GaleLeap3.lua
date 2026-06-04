---@param self EffectDefender
---@param timing EffectTiming
return function(self, timing)
	if _G.HeavenlyWindPending and _G.HeavenlyWindPending.entity == self.owner then
		_G.GaleLeap3Received = {
			entity = self.owner,
			time = os.clock()
		}
	end
end
