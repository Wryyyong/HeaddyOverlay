-- Set up globals and local references
local Overlay = HeaddyOverlay

local MemoryMonitor = Overlay.MemoryMonitor or {}
Overlay.MemoryMonitor = MemoryMonitor

local ActiveMonitors = MemoryMonitor.ActiveMonitors or {}
local MonitorLookup = MemoryMonitor.MonitorLookup or {}
MemoryMonitor.ActiveMonitors = ActiveMonitors
MemoryMonitor.MonitorLookup = MonitorLookup

local CallbacksToExec = {}

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

	for id,data in pairs(monitors) do
		CallbacksToExec[id] = data
	end
end,nil,"HeaddyOverlay.MemoryMonitor")

--[[
	[TODO: Explain this]
--]]

function MemoryMonitor.Register(id,address,callback,persist)
	id = tostring(id)
	address = tonumber(address)
	persist = type(persist) == "boolean" and persist or false

	if not ActiveMonitors[address] then
		ActiveMonitors[address] = {}
	end

	local monitorData = {
		["Address"] = address,
		["Callback"] = callback,
		["Persistence"] = persist,
	}

	MonitorLookup[id] = monitorData
	ActiveMonitors[address][id] = monitorData
end

function MemoryMonitor.Unregister(id)
	id = tostring(id)

	local monitorTbl = MonitorLookup[id]
	if not monitorTbl then return end

	ActiveMonitors[monitorTbl.Address][id] = nil
	MonitorLookup[id] = nil
end

function MemoryMonitor.ExecuteCallbacks()
	for id,data in pairs(CallbacksToExec) do
		local result = data.Callback(data.Address)

		if not data.Persistence and result ~= false then
			MemoryMonitor.Unregister(id)
		end

		CallbacksToExec[id] = nil
	end
end
