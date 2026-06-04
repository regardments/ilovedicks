---@class Maid
local Maid = getfenv().Maid

---@class Signal
local Signal = getfenv().Signal

---@class Logger
local Logger = getfenv().Logger

---@class TerrainListener
---@field maid Maid
---@field identifier string
local TerrainListener = {}
TerrainListener.__index = TerrainListener

-- Object list.
local trackerObjects = {}

---Detach function.
function TerrainListener.detach()
	for _, trackerObject in next, trackerObjects do
		if not trackerObject.maid then
			continue
		end

		trackerObject.maid:clean()
	end
end

---Create connection.
function TerrainListener:connect(callback)
	local terrain = workspace:WaitForChild("Terrain")
	local childAdded = Signal.new(terrain.ChildAdded)

	self.maid:clean()

	self.maid:mark(childAdded:connect(string.format("%s_TerrainListener_TerrainChildAdded", self.identifier), callback))
end

---Create a new TerrainListener object.
---@param identifier string
---@return TerrainListener
function TerrainListener.new(identifier)
	local self = setmetatable({}, TerrainListener)
	self.maid = Maid.new()
	self.identifier = identifier
	trackerObjects[#trackerObjects + 1] = self
	return self
end

-- Return TerrainListener module.
return TerrainListener
