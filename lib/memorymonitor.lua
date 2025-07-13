--[[
	As of writing, both Mega Drive cores in BizHawk only return 0 for all
	read/write/exec callbacks.

	To work around this limitation, we set up a monitoring system utilizing a
	global on_bus_write event that fills a table with callback functions to be
	executed on the following frame, if the modified address matches with our
	active monitors.
--]]

-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Util = Overlay.Util

local MemoryMonitor = {}
Overlay.MemoryMonitor = MemoryMonitor

local ActiveByID = {}
local ActiveByAddress = {}
local CallbacksToExec = {}

-- Cache commonly-used functions and constants
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber

-- Create global memory monitor
event.on_bus_write(function(address)
	local monitors = ActiveByAddress[address]

	if
		not monitors
	or	Util.IsTableEmpty(monitors)
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
	for _,address in ipairs(monitorData.AddressTblPadded) do
		ActiveByAddress[address][id] = nil
	end

	ActiveByID[id] = nil
	CallbacksToExec[monitorData.Callback] = nil
end

function MemoryMonitor.Register(id,addressTbl,callback,skipInit)
	if not Util.IsFunction(callback) then return end

	id = tostring(id)

	if ActiveByID[id] then
		UnregisterInternal(id,ActiveByID[id])
	end

	-- Backwards-compat with non-table arguments
	if not Util.IsTable(addressTbl) then
		addressTbl = {addressTbl}
	end

	local addressTblPadded = {}

	local monitorData = {
		["AddressTbl"] = addressTbl,
		["AddressTblPadded"] = addressTblPadded,
		["Callback"] = callback,
		["SkipInit"] = skipInit,
	}

	ActiveByID[id] = monitorData

	for idx,address in pairs(addressTbl) do
		-- read/write/exec callbacks return 32-bit address values, but the 68K
		-- memory bus is only 0xFFFFFF bytes long, so our input addresses are
		-- going to be only 24-bit values at most
		--
		-- Instead of bitmasking 32-bit values down to 24 bits everytime our
		-- on_bus_write callback is executed, we'll pad out 24-bit input
		-- addresses to 32-bit to accommodate
		local addressConv = tonumber(address)
		local addressPad = addressConv | 0xFF000000

		if not ActiveByAddress[addressPad] then
			ActiveByAddress[addressPad] = {}
		end

		addressTbl[idx] = addressConv
		addressTblPadded[idx] = addressPad

		ActiveByAddress[addressPad][id] = monitorData
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
	if Util.IsTableEmpty(CallbacksToExec) then return end

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
