---@module Features.Visuals.Objects.ModelESP
local ModelESP = require("Features/Visuals/Objects/ModelESP")

---@module Utility.Configuration
local Configuration = require("Utility/Configuration")

---@class ObeliskESP: ModelESP
local ObeliskESP = setmetatable({}, { __index = ModelESP })
ObeliskESP.__index = ObeliskESP
ObeliskESP.__type = "ObeliskESP"

---Update ObeliskESP.
---@param self ObeliskESP
ObeliskESP.update = LPH_NO_VIRTUALIZE(function(self)
	local model = self.model

	local bpart = model:FindFirstChild("BuzzPart")
	if not bpart then
		return self:visible(false)
	end

	local interactPrompt = bpart:FindFirstChildOfClass("ProximityPrompt")

	if Configuration.idToggleValue(self.identifier, "HideIfTurnedOn") and not interactPrompt then
		return self:visible(false)
	end

	ModelESP.update(self, {})
end)

---Create new ObeliskESP object.
---@param identifier string
---@param model Model
---@param label string
function ObeliskESP.new(identifier, model, label)
	return setmetatable(ModelESP.new(identifier, model, label), ObeliskESP)
end

-- Return ObeliskESP module.
return ObeliskESP
