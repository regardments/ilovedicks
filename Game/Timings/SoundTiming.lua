---@module Game.Timings.Timing
local Timing = require("Game/Timings/Timing")

---@class SoundTiming: Timing
---@field id string Sound ID.
---@field rpue boolean Repeat parry until end.
---@field _rsd number Repeat start delay in miliseconds. Never access directly.
---@field _rpd number Delay between each repeat parry in miliseconds. Never access directly.
---@field alp boolean Allow local player to be hit.
local SoundTiming = setmetatable({}, { __index = Timing })
SoundTiming.__index = SoundTiming

---Timing ID.
---@return string
function SoundTiming:id()
	return self._id
end

---Equals check.
---@param other SoundTiming
function SoundTiming:equals(other)
	if not Timing.equals(self, other) then
		return false
	end

	if self._id ~= other._id then
		return false
	end

	if self.alp ~= other.alp then
		return false
	end

	return true
end

---Load from partial values.
---@param values table
function SoundTiming:load(values)
	Timing.load(self, values)

	if typeof(values._id) == "string" then
		self._id = values._id
	end

	if typeof(values.alp) == "boolean" then
		self.alp = values.alp
	end
end

---Clone timing.
---@return SoundTiming
function SoundTiming:clone()
	local clone = setmetatable(Timing.clone(self), SoundTiming)

	clone._id = self._id
	clone.alp = self.alp

	return clone
end

---Return a serializable table.
---@return SoundTiming
function SoundTiming:serialize()
	local serializable = Timing.serialize(self)

	serializable._id = self._id
	serializable.alp = self.alp

	return serializable
end

---Create a new sound timing.
---@param values table?
---@return SoundTiming
function SoundTiming.new(values)
	local self = setmetatable(Timing.new(), SoundTiming)

	self._id = ""
	self.rpue = false
	self._rsd = 0
	self._rpd = 0
	self.alp = false

	if values then
		self:load(values)
	end

	return self
end

-- Return SoundTiming module.
return SoundTiming
