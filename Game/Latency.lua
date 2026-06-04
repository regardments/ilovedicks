-- Latency module.
local Latency = {}

-- Services.
local stats = game:GetService("Stats")

---@note: Perhaps one day, we can get better approximations for these.
--- These used to rely on GetNetworkPing which we assumed would be sending or atleast receiving delay.
--- That is incorrect, it is RakNet ping thereby being RTT.

---Get receiving delay.
---@return number
function Latency.rdelay()
	return math.max(Latency.rtt() / 2, 0.0)
end

---Get sending delay.
---@return number
function Latency.sdelay()
	return math.max(Latency.rtt() / 2, 0.0)
end

---Get data ping.
---@note: https://devforum.roblox.com/t/in-depth-information-about-robloxs-remoteevents-instance-replication-and-physics-replication-w-sources/1847340
---@note: The forum post above is misleading, not only is it the RTT time, please note that this also takes into account all delays like frame time.
---@note: This is our round-trip time (e.g double the ping) since we have a receiving delay (replication) and a sending delay when we send the input to the server.
---@todo: For every usage, the sending delay needs to be continously updated. The receiving one must be calculated once at initial send for AP ping compensation.
---@return number
function Latency.rtt()
	local network = stats:FindFirstChild("Network")
	if not network then
		return
	end

	local serverStatsItem = network:FindFirstChild("ServerStatsItem")
	if not serverStatsItem then
		return
	end

	local dataPingItem = serverStatsItem:FindFirstChild("Data Ping")
	if not dataPingItem then
		return
	end

	return (dataPingItem:GetValue() / 1000)
end

-- Return Latency module.
return Latency
