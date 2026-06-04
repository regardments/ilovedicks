-- Module: RegentGrapple
-- Extracted from preprocessed bundle

---@type Action
        local Action = getfenv().Action

        ---Module function.
        ---@param self AnimatorDefender
        ---@param timing AnimationTiming
        return function(self, timing)
	local speed = self.track.Speed
	local action = Action.new()
	action._when = 500
	action._type = "Dodge"
	action.hitbox = Vector3.new(40, 40, 400)
	action.name = string.format("(%.2f) Lord Regent Grapple Timing", self.track.Speed)
	return self:action(timing, action)
        end
