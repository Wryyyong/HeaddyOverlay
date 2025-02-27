-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay

local MemoryMonitor = {}
Overlay.MemoryMonitor = MemoryMonitor

local ActiveByID = {}
local ActiveByAddress = {}
local CallbacksToExec = {}

-- Cache commonly-used functions and constants
local type = type
local next = next
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber

--[[
	As of writing, both Mega Drive cores in BizHawk only return 0 for all
	read/write/exec callbacks.

	To work around this limitation, we set up a monitoring system utilizing a
	global on_bus_write event that fills a table with callback functions to be
	executed on the following frame, if the modified address matches with our
	active monitors.
--]]

-- Create global memory monitor
event.on_bus_write(function(address)
	-- read/write/exec callbacks return 32-bit address values
	-- We only want the 24 least-significant bits of that address
	address = address & 0xFFFFFF

	local monitors = ActiveByAddress[address]

	if
		not monitors
	or	next(monitors) == nil
	then return end

	for _,data in pairs(monitors) do
		CallbacksToExec[data.Callback] = data.AddressTbl
	end
end,nil,"HeaddyOverlay.MemoryMonitor.Main")

-- Force-refresh all active monitors upon loading a savestate,
-- skipping CallbacksToExec entirely
event.onloadstate(function()
	for _,data in pairs(ActiveByID) do
		if not data.SkipInit then
			data.Callback(data.AddressTbl)
		end
	end
end,"HeaddyOverlay.MemoryMonitor.ForceRefreshAllMonitors")

local function UnregisterInternal(id,monitorData)
	for _,address in ipairs(monitorData.AddressTbl) do
		ActiveByAddress[address][id] = nil
	end

	ActiveByID[id] = nil
	CallbacksToExec[monitorData.Callback] = nil
end

function MemoryMonitor.Register(id,addressTbl,callback,skipInit)
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
		["SkipInit"] = skipInit,
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

	if skipInit then return end

	-- Queue the callback up to be executed immediately after registering,
	-- to help with initialisation
	CallbacksToExec[monitorData.Callback] = addressTbl
end

function MemoryMonitor.Unregister(id)
	id = tostring(id)

	local monitorData = ActiveByID[id]
	if not monitorData then return end

	UnregisterInternal(id,monitorData)
end

function MemoryMonitor.ExecuteCallbacks()
	if next(CallbacksToExec) == nil then return end

	for callback,addressTbl in pairs(CallbacksToExec) do
		callback(addressTbl)

		CallbacksToExec[callback] = nil
	end
end

function MemoryMonitor.ManuallyExecuteByIDs(...)
	for _,arg in ipairs({...}) do
		local id = tostring(arg)

		local monitorData = ActiveByID[id]

		if monitorData then
			CallbacksToExec[monitorData.Callback] = monitorData.AddressTbl
		end
	end
end
