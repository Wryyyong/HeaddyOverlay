-- Set up globals and local references
local Overlay = HeaddyOverlay

Overlay.MemoryMonitor = Overlay.MemoryMonitor or {}
local MemoryMonitor = Overlay.MemoryMonitor

MemoryMonitor.ActiveMonitors = MemoryMonitor.ActiveMonitors or {}
MemoryMonitor.MonitorLookup = MemoryMonitor.MonitorLookup or {}
local ActiveMonitors = MemoryMonitor.ActiveMonitors
local MonitorLookup = MemoryMonitor.MonitorLookup
local CallbacksToExec = {}

-- Commonly-used functions
local unpack = table.unpack

--[[
	As of writing, the Genplus-gx core only returns '0' for all read/write/exec callbacks.

	[TODO: Explain this better]
	To work around this limitation, we set up a monitoring system utilizing a global
	on_bus_write event that fills a table with callbacks to be executed on the next frame.
--]]

-- Create global memory monitor
event.unregisterbyname("HeaddyOverlay.MemoryMonitor")
event.on_bus_write(function(address)
	-- read/write/exec callbacks return 32-bit address values
	-- We only want the 24 least-significant bits of that address
	address = address - 0xFF000000

	local monitors = ActiveMonitors[address]
	if not monitors then return end

	local args = {address}

	for _,callback in pairs(monitors) do
		CallbacksToExec[#CallbacksToExec + 1] = {
			["func"] = callback,
			["args"] = args,
		}
	end
end,nil,"HeaddyOverlay.MemoryMonitor")

--[[
	[TODO: Explain this]
--]]

function MemoryMonitor.RegisterMonitor(id,address,callback)
	id = tostring(id)
	address = tonumber(address)

	if not ActiveMonitors[address] then
		ActiveMonitors[address] = {}
	end

	ActiveMonitors[address][id] = callback
	MonitorLookup[id] = address
end

function MemoryMonitor.UnregisterMonitor(id)
	id = tostring(id)

	local address = MonitorLookup[id]
	local monitorTbl = ActiveMonitors[address]
	if not monitorTbl then return end

	local monitor = monitorTbl[id]
	if not monitor then return end

	ActiveMonitors[address][id] = nil
	MonitorLookup[id] = nil
end

function MemoryMonitor.ExecuteCallbacks()
	if #CallbacksToExec <= 0 then return end

	for idx,data in ipairs(CallbacksToExec) do
		data.func(unpack(data.args))

		CallbacksToExec[idx] = nil
	end
end
