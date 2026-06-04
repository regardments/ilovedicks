---@type Action
local Action = getfenv().Action

---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
    local character = game.Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local dist = (root.Position - self.part.Position).Magnitude
    if dist <= 1 then
        self:notify(timing, "Skipped (from local player, dist: %.1f)", dist)
        return
    end

    local action = Action.new()
    action._type = "Parry"
    action._when = 0
    action.name = "VengefulSlashes"

    return self:action(timing, action)
end
