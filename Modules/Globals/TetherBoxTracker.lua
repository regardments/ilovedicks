---@class Action
local Action = getfenv().Action

---@module Utility.TaskSpawner
local TaskSpawner = getfenv().TaskSpawner

-- Services.
local players = game:GetService("Players")
local runService = game:GetService("RunService")

-- Tether box tracker.
local TetherBoxTracker = {}

-- State.
local activeBoxes = {}
local lastParry = 0

---Get local root part.
---@return BasePart?
local function localRoot()
	local character = players.LocalPlayer and players.LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

---Get tether box.
---@param instance Instance
---@return Instance?
function TetherBoxTracker.box(instance)
	if not instance then
		return
	end

	if instance.Name == "Tether Box" then
		return instance
	end

	return instance:FindFirstAncestor("Tether Box")
end

---Get fallback part.
---@param box Instance
---@param fallback Instance?
---@return BasePart?
local function fallbackPart(box, fallback)
	if fallback and fallback:IsA("BasePart") then
		return fallback
	end

	if box:IsA("BasePart") then
		return box
	end

	return box:FindFirstChildWhichIsA("BasePart", true)
end

---Get box position.
---@param box Instance
---@param fallback BasePart?
---@return Vector3?
local function boxPosition(box, fallback)
	if box:IsA("Model") then
		return box:GetPivot().Position
	end

	if box:IsA("BasePart") then
		return box.Position
	end

	local position = Vector3.zero
	local count = 0

	for _, descendant in next, box:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		position += descendant.Position
		count += 1
	end

	if count <= 0 then
		return fallback and fallback.Position or nil
	end

	return position / count
end

---Check hitbox range.
---@param position Vector3
---@param movement Vector3
---@param rootPosition Vector3
---@return boolean
local function inHitboxRange(position, movement, rootPosition)
	local cframe = CFrame.lookAt(position, position + movement.Unit)
	local offset = cframe:PointToObjectSpace(rootPosition)

	return math.abs(offset.X) <= 25 / 2
		and math.abs(offset.Y) <= 10 / 2
		and math.abs(offset.Z) <= 10 / 2
end

---Queue parry.
---@param self Defender
---@param timing Timing
local function queueParry(self, timing)
	timing.forced = true

	local action = Action.new()
	action._when = 50
	action._type = "Parry"
	action.hitbox = Vector3.zero
	action.ihbc = true
	action.name = "Tether Box Timing"
	return self:action(timing, action)
end

---Track box movement.
---@param self Defender
---@param timing Timing
---@param box Instance
---@param fallback Instance?
function TetherBoxTracker.track(self, timing, box, fallback)
	if not box then
		return
	end

	local info = activeBoxes[box] or {}
	if info.tracking then
		return
	end

	local root = localRoot()
	if not root then
		return
	end

	local part = fallbackPart(box, fallback)
	local position = boxPosition(box, part)
	if not position then
		return
	end

	info.position = position
	info.distance = (position - root.Position).Magnitude
	info.updated = os.clock()
	info.tracking = true
	activeBoxes[box] = info

	local started = os.clock()

	while box.Parent and os.clock() - started <= 10 do
		local delta = runService.Heartbeat:Wait() or 1 / 60
		root = localRoot()

		if not root then
			continue
		end

		part = fallbackPart(box, fallback)
		position = boxPosition(box, part)

		if not position then
			continue
		end

		local now = os.clock()
		local movement = position - info.position
		local distance = (position - root.Position).Magnitude
		local moveDistance = movement.Magnitude
		local toRoot = root.Position - position

		info.position = position
		info.updated = now

		if moveDistance < 0.02 or toRoot.Magnitude <= 0 then
			info.distance = distance
			continue
		end

		local closingSpeed = (info.distance - distance) / math.max(delta, 1 / 60)
		local movingTowardRoot = movement.Unit:Dot(toRoot.Unit) >= 0.6

		info.distance = distance

		if not movingTowardRoot or closingSpeed < 3 then
			continue
		end

		if not inHitboxRange(position, movement, root.Position) then
			continue
		end

		if now - lastParry < 0.6 then
			continue
		end

		lastParry = now
		activeBoxes[box] = nil
		return queueParry(self, timing)
	end

	activeBoxes[box] = nil
end

---Track candidate instance.
---@param self Defender
---@param timing Timing
---@param candidate Instance
function TetherBoxTracker.candidate(self, timing, candidate)
	local box = TetherBoxTracker.box(candidate)
	if not box then
		return
	end

	TaskSpawner.spawn("TetherBoxTracker_Track", TetherBoxTracker.track, self, timing, box, candidate)
end

---Watch for tether boxes.
---@param self Defender
---@param timing Timing
---@param duration number
function TetherBoxTracker.watch(self, timing, duration)
	local expires = os.clock() + duration

	TaskSpawner.spawn("TetherBoxTracker_Watch", function()
		local connection = workspace.DescendantAdded:Connect(function(descendant)
			if os.clock() > expires then
				return
			end

			TetherBoxTracker.candidate(self, timing, descendant)
		end)

		for _, descendant in next, workspace:GetDescendants() do
			TetherBoxTracker.candidate(self, timing, descendant)
		end

		while os.clock() <= expires do
			task.wait(0.1)
		end

		connection:Disconnect()
	end)
end

---Detach function.
function TetherBoxTracker.detach()
	activeBoxes = {}
	lastParry = 0
end

-- Return tether box tracker.
return TetherBoxTracker
