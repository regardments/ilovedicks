---@class DodgeOptions
---@field rollCancel boolean
---@field rollCancelDelay number
---@field direct boolean
---@field actionRolling boolean
local DodgeOptions = {}
DodgeOptions.__index = DodgeOptions

---Create new DodgeOptions object.
function DodgeOptions.new()
	local self = setmetatable({}, DodgeOptions)
	self.rollCancel = false
	self.rollCancelDelay = 0.0
	self.direct = false
	self.actionRolling = false
	return self
end

-- Return DodgeOptions module.
return DodgeOptions
