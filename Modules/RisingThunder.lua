---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.duih = true
	timing.hitbox = Vector3.new(20, 20, 20)
	timing.mat = 1300
	timing.iae = true
	timing.ieae = true

	local distance = self:distance(self.entity)
	local action = Action.new()
	action._when = 250
	action._type = "Start Block"
	action.name = string.format("(1) Rising Thunder Start", distance)
	self:action(timing, action)

	local secondAction = Action.new()
	secondAction._when = 1250
	secondAction._type = "End Block"
	secondAction.name = "(2) Rising Thunder End"
	self:action(timing, secondAction)

	local entity = self.entity

	local function onFolderCreated(folder)
		self:notify(timing, "(3) Rising Thunder Strike")

		task.spawn(function()
			task.wait(750 / 1000)
			self:notify(timing, "Folder Detected, Executing Parry")
			self:parry(timing, nil)
		end)
	end

	local folderConn
	folderConn = entity.DescendantAdded:Connect(function(d)
		if not d:IsA("Folder") then return end
		if not d.Name:match("RisingLightning") then return end
		onFolderCreated(d)
	end)

	self.tmaid:mark(folderConn)
end
