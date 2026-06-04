---@module Utility.Signal
local Signal = getfenv().Signal

---@class Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	---Handler for barrage iteration.
	local function onBarrageIteration()
		-- Handle first swing.
		local actionOne = Action.new()
		actionOne._when = 950
		actionOne._type = "Parry"
		actionOne.hitbox = Vector3.new(30, 25, 60)
		actionOne.name = "Terrapod Barrage Swing 1"
		self:action(timing, actionOne)

		-- Handle second swing.
		local actionTwo = Action.new()
		actionTwo._when = 1280
		actionTwo._type = "Parry"
		actionTwo.hitbox = Vector3.new(30, 25, 60)
		actionTwo.name = "Terrapod Barrage Swing 2"
		self:action(timing, actionTwo)
	end

	local didLoopSignal = Signal.new(self.track.DidLoop)

	self.tmaid:add(didLoopSignal:connect("TerrapodBarrage_DidLoop", onBarrageIteration))

	onBarrageIteration()
end
