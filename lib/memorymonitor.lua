-- Set up globals and local references
local Overlay = HeaddyOverlay

local MemoryMonitor = Overlay.MemoryMonitor or {}
Overlay.MemoryMonitor = MemoryMonitor

local ActiveByID = {}
local ActiveByAddress = {}
local CallbacksToExec = {}

-- Commonly-used functions
local type = type
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber

--[[
	As of writing, the Genplus-gx core only returns '0' for all read/write/exec callbacks.

	[TODO: Explain this better]
	To work around this limitation, we set up a monitoring system utilizing a global
	on_bus_write event that fills a table with callbacks to be executed on the next frame.
--]]

-- Create global memory monitor
event.unregisterbyname("HeaddyOverlay.MemoryMonitor.Main")
event.unregisterbyname("HeaddyOverlay.MemoryMonitor.ForceRefreshAllMonitors")

event.on_bus_write(function(address)
	-- read/write/exec callbacks return 32-bit address values
	-- We only want the 24 least-significant bits of that address
	address = address - 0xFF000000

	local monitors = ActiveByAddress[address]
	if not monitors then return end

	for _,data in pairs(monitors) do
		CallbacksToExec[data.Callback] = data.AddressTbl
	end
end,nil,"HeaddyOverlay.MemoryMonitor.Main")

event.onloadstate(function()
	for _,data in pairs(ActiveByID) do
		data.Callback(data.AddressTbl)
	end
end,"HeaddyOverlay.MemoryMonitor.ForceRefreshAllMonitors")

--[[
	[TODO: Explain this]
--]]

local function UnregisterInternal(id,monitorData)
	for _,address in ipairs(monitorData.AddressTbl) do
		ActiveByAddress[address][id] = nil
	end

	ActiveByID[id] = nil
end

function MemoryMonitor.Register(id,addressTbl,callback)
	if type(callback) ~= "function" then return end

	id = tostring(id)

	if ActiveByID[id] then
		UnregisterInternal(id,ActiveByID[id])
	end

	-- Backwards-compat with non-table arguments
	if type(addressTbl) ~= "table" then
		addressTbl = {addressTbl}
	end

	local monitorData = {
		["AddressTbl"] = addressTbl,
		["Callback"] = callback,
	}

	for idx,address in pairs(addressTbl) do
		local addressConv = tonumber(address)

		if not ActiveByAddress[addressConv] then
			ActiveByAddress[addressConv] = {}
		end

		addressTbl[idx] = addressConv
		ActiveByID[id] = monitorData
		ActiveByAddress[addressConv][id] = monitorData
	end

	CallbacksToExec[monitorData.Callback] = addressTbl
end

function MemoryMonitor.Unregister(id)
	id = tostring(id)

	local monitorData = ActiveByID[id]
	if not monitorData then return end

	UnregisterInternal(id,monitorData)
end

function MemoryMonitor.ExecuteCallbacks()
	for callback,addressTbl in pairs(CallbacksToExec) do
		callback(addressTbl)

		CallbacksToExec[callback] = nil
	end
end
