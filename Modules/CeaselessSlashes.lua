---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
    local action = Action.new()
    action._when = 100
    action._type = "Parry"
    action.hitbox = Vector3.new(31, 15, 31)
    action.name = "Ceaseless Slashes"
    return self:action(timing, action)
end
