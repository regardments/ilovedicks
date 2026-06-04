-- Teleport module.
---@note: Teleports in Deepwoken do not work the same. They lag you back, obviously. This is a utility module to handle repeatedly teleporting for a specific purpose.
local Teleport = { destination = nil, gdp = nil }

---@module Utility.Maid
local Maid = require("Utility/Maid")

---@module Utility.Signal
local Signal = require("Utility/Signal")

---@module Utility.TaskSpawner
local TaskSpawner = require("Utility/TaskSpawner")

---@module Utility.Configuration
local Configuration = require("Utility/Configuration")

-- Services.
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

-- Maids.
local tmaid = Maid.new()

-- Teleport state.
local RUBBERBAND_THRESHOLD = 1000
local teleportFrameCount = 0
local SPAM_FRAMES = 30
local PAUSE_FRAMES = 15
local STREAM_REQUEST_INTERVAL = 1.0
local REALM_ALIASES = {
	EasternLuminant = { "EastLuminant", "East Luminant", "EasternLuminant", "Eastern Luminant" },
	EtreanLuminant = { "EtreanLuminant", "Etrean Luminant" },
}
local REALM_TELEPORTER_PATHS = {
	{ "ValleyExit", "RealmTeleport" },
	{ "ValleyExit", "RealmTeleporter" },
}
local teleporterCache = {}
local streamRequestTimes = {}

---On player GUI descendant added.
---@param child Instance
local function onPlayerGuiDescendantAdded(child)
	if not child:IsA("TextLabel") then
		return
	end

	local coords = string.split(child.Text, ", ")
	local x, y, z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
	if not x or not y or not z then
		return
	end

	local position = Vector3.new(x, y, z)

	if (position - Vector3.new(-20000, 20000, -20000)).Magnitude <= 20 and Teleport.destination == "Voidheart" then
		return Teleport.stop()
	end

	if (position - Vector3.new(1596.1, 555.7, 2849.9)).Magnitude <= 20 and Teleport.destination == "LowerErisia" then
		return Teleport.stop()
	end

	if Teleport.gdp and (position - Teleport.gdp).Magnitude <= 20 and Teleport.destination == "GuildDoor" then
		return Teleport.stop()
	end
end

---Get guild doors from partial or exact name.
---@note: First instance is the entrance door. The second instance is the exit door.
---@param name string
---@return Instance?, Instance?
local function getGuildDoors(name)
	for _, instance in next, workspace:GetChildren() do
		if not instance.Name:match("GuildDoor") then
			continue
		end

		local guildName = instance:GetAttribute("GuildName")
		if not guildName then
			continue
		end

		if not guildName:lower():match(name:lower()) then
			continue
		end

		return instance, workspace:FindFirstChild(string.gsub(instance.Name, "GuildDoor", "GuildExitDoor"))
	end

	return nil
end

---Fire touch interest on a part.
---@param character Model
---@param part BasePart
local function fireTouchOn(character, part)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	pcall(firetouchinterest, hrp, part, 0)
	pcall(firetouchinterest, hrp, part, 1)
	pcall(firetouchinterest, hrp, part, 0)
	pcall(firetouchinterest, hrp, part, 1)
end

---Reset teleport state.
local function resetTeleportState()
	teleportFrameCount = 0
	teleporterCache = {}
	streamRequestTimes = {}
end

---Request stream around a position.
---@param label string
---@param position Vector3
local function requestStreamAround(label, position)
	local timestamp = os.clock()
	local lastRequestTime = streamRequestTimes[label]
	if lastRequestTime and timestamp - lastRequestTime < STREAM_REQUEST_INTERVAL then
		return
	end

	streamRequestTimes[label] = timestamp
	tmaid:add(
		TaskSpawner.spawn(
			label,
			players.LocalPlayer.RequestStreamAroundAsync,
			players.LocalPlayer,
			position,
			0.1
		)
	)
end

---Check if realm name matches a destination.
---@param realm string
---@param destination string
---@return boolean
local function isRealmName(realm, destination)
	for _, alias in next, REALM_ALIASES[destination] or { destination } do
		if realm == alias then
			return true
		end
	end

	return false
end

---Get workspace child from path.
---@param path table
---@return Instance?
local function getWorkspacePath(path)
	local current = workspace
	for _, name in next, path do
		current = current:FindFirstChild(name)
		if not current then
			return nil
		end
	end

	return current
end

---Get realm teleporter from direct workspace paths.
---@param realm string
---@return BasePart?
local function getRealmTeleporter(realm)
	local cachedTeleporter = teleporterCache[realm]
	if cachedTeleporter and cachedTeleporter.Parent and isRealmName(cachedTeleporter:GetAttribute("Realm"), realm) then
		return cachedTeleporter
	end

	for _, path in next, REALM_TELEPORTER_PATHS do
		local teleporter = getWorkspacePath(path)
		if not teleporter or not teleporter:IsA("BasePart") then
			continue
		end

		if not isRealmName(teleporter:GetAttribute("Realm"), realm) then
			continue
		end

		teleporterCache[realm] = teleporter
		return teleporter
	end

	return nil
end

---Scan voidheart teleporter.
---@return BasePart?
local function scanVoidheartTeleporter()
	local warpPoints = workspace:FindFirstChild("WarpPoints")
	local voidheartWarpPoint = warpPoints and warpPoints:FindFirstChild("Voidheart")
	if voidheartWarpPoint and voidheartWarpPoint:IsA("BasePart") then
		return voidheartWarpPoint
	end

	local voidheart = workspace:FindFirstChild("Voidheart")
	local voidheartVoidWarp = voidheart and voidheart:FindFirstChild("VoidheartVoidWarp", true)
	if voidheartVoidWarp and voidheartVoidWarp:IsA("BasePart") then
		return voidheartVoidWarp
	end

	return nil
end

---Get voidheart teleporter.
---@return BasePart?
local function getVoidheartTeleporter()
	local cachedTeleporter = teleporterCache.Voidheart
	if cachedTeleporter and cachedTeleporter.Parent then
		return cachedTeleporter
	end

	local teleporter = scanVoidheartTeleporter()
	if teleporter then
		teleporterCache.Voidheart = teleporter
	end

	return teleporter
end

---Loop for teleport module.
local function onTeleportLoop()
	local dest = Teleport.destination
	if not dest then
		return
	end

	local localPlayer = players.LocalPlayer
	local character = localPlayer.Character
	if not character then
		return
	end

	if dest == "EasternLuminant" then
		requestStreamAround("Teleport_EasternLuminantStream", Vector3.new(-2632.86084, 628.632935, -6707.99805))

		local realmTeleporter = getRealmTeleporter("EasternLuminant")
		if not realmTeleporter then
			return
		end

		character:PivotTo(realmTeleporter.CFrame)
		fireTouchOn(character, realmTeleporter)
	end

	if dest == "EtreanLuminant" then
		requestStreamAround("Teleport_EtreanLuminantStream", Vector3.new(-514.263, 665.174316, -4772.3208))

		local realmTeleporter = getRealmTeleporter("EtreanLuminant")
		if not realmTeleporter then
			return
		end

		character:PivotTo(realmTeleporter.CFrame)
		fireTouchOn(character, realmTeleporter)
	end

	if dest == "Depths" then
		tmaid:add(
			TaskSpawner.spawn(
				"Teleport_DepthsStream",
				players.LocalPlayer.RequestStreamAroundAsync,
				players.LocalPlayer,
				Vector3.new(39911.3672, 39980.9375, 39708.3203),
				0.1
			)
		)

		local modOffice = workspace:FindFirstChild("ModOffice")
		local officePit = modOffice and modOffice:FindFirstChild("OfficePit")
		if not officePit then
			return
		end

		character:PivotTo(officePit.CFrame)
	end

	if dest == "Voidheart" then
		local voidheartTeleporter = getVoidheartTeleporter()
		requestStreamAround(
			"Teleport_VoidheartStream",
			voidheartTeleporter and voidheartTeleporter.Position or Vector3.new(-20000.0, 19713.9609, -20000.0)
		)

		if not voidheartTeleporter then
			return
		end

		local vhCFrame = voidheartTeleporter.CFrame
		teleportFrameCount = teleportFrameCount + 1
		local cycleFrame = (teleportFrameCount - 1) % (SPAM_FRAMES + PAUSE_FRAMES)

		-- Spam phase: PivotTo + touch.
		if cycleFrame < SPAM_FRAMES then
			character:PivotTo(vhCFrame)
			fireTouchOn(character, voidheartTeleporter)
			return
		end

		-- Pause phase: let server respond. Check on the last pause frame.
		if cycleFrame == SPAM_FRAMES + PAUSE_FRAMES - 1 then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - vhCFrame.Position).Magnitude <= RUBBERBAND_THRESHOLD then
				return Teleport.stop()
			end
		end
	end

	if dest == "TrialOfOne" then
		tmaid:add(
			TaskSpawner.spawn(
				"Teleport_TrialStream",
				players.LocalPlayer.RequestStreamAroundAsync,
				players.LocalPlayer,
				Vector3.new(-959.787659, 146.996887, -6659.63037),
				0.1
			)
		)

		local oneEntrance = workspace:FindFirstChild("OneEntrance")
		if not oneEntrance then
			return
		end

		local effectReplicator = replicatedStorage:FindFirstChild("EffectReplicator")
		if not effectReplicator then
			return
		end

		local effectReplicatorModule = require(effectReplicator)
		if not effectReplicatorModule then
			return
		end

		if effectReplicatorModule:FindEffect("Knocked") then
			return Teleport.stop()
		end

		character:PivotTo(oneEntrance.CFrame)
	end

	if dest == "GuildDoor" then
		local guildName = Configuration.expectOptionValue("GuildDoorName")
		if not guildName or #guildName <= 0 then
			return
		end

		local entranceDoor, exitDoor = getGuildDoors(guildName)
		if not entranceDoor or not exitDoor then
			return
		end

		local guildBaseCFrame = entranceDoor:GetAttribute("TargetCFrame")
		if not guildBaseCFrame then
			return
		end

		local guildDoorCFrame = exitDoor:GetAttribute("TargetCFrame")
		if not guildDoorCFrame then
			return
		end

		Teleport.gdp = guildDoorCFrame.Position

		-- Stream in the guild base.
		requestStreamAround("Teleport_GuildBaseStream", guildBaseCFrame.Position)

		teleportFrameCount = teleportFrameCount + 1

		-- Only check arrival after at least one PivotTo cycle.
		if teleportFrameCount > 1 then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - entranceDoor.Position).Magnitude <= 50 then
				return Teleport.stop()
			end
		end

		-- Teleport over their bounds to trigger a forced game teleport.
		character:PivotTo(CFrame.new(guildBaseCFrame.Position - Vector3.new(0, 150, 0)))
	end
end

---Start teleport module.
---@param destination string
function Teleport.start(destination)
	if not destination then
		return error("Destination must be provided for teleporting.")
	end

	resetTeleportState()
	Teleport.destination = destination
end

---Stop teleport module.
function Teleport.stop()
	resetTeleportState()
	Teleport.destination = nil
end

---Initialize Teleport module.
function Teleport.init()
	local localPlayer = players.LocalPlayer
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local descendantAddedSignal = Signal.new(playerGui.DescendantAdded)
	tmaid:mark(descendantAddedSignal:connect("Teleport_PlayerGui_DescendantAdded", onPlayerGuiDescendantAdded))

	local renderStepped = Signal.new(runService.RenderStepped)
	tmaid:mark(renderStepped:connect("Teleport_RenderStepped", onTeleportLoop))
end

---Detach Teleport module.
function Teleport.detach()
	tmaid:clean()
end

-- Return Teleport module.
return Teleport
