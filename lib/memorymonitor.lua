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

local MemoryMonitor = {
	["Priority"] = {},
}
Overlay.MemoryMonitor = MemoryMonitor

local ActiveByID = {}
local ActiveByAddress = {}
local ActiveByPriority = {}

local CallbacksToExec = {}

-- Cache commonly-used functions and constants
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber

-- Create priority tables in CallbacksToExec
for idx,priority in ipairs({
	"Global",
	"Entity",
	"Scene",
}) do
	MemoryMonitor.Priority[priority] = idx

	ActiveByPriority[idx] = {}
	CallbacksToExec[idx] = {}
end

local function QueueCallback(monitorData)
	CallbacksToExec[monitorData.Priority][monitorData.Callback] = monitorData.AddressTbl
end

local function UnregisterInternal(id,monitorData)
	for _,address in ipairs(monitorData.AddressTblPadded) do
		ActiveByAddress[address][id] = nil
	end

	local priority = monitorData.Priority

	ActiveByID[id] = nil
	ActiveByPriority[priority][id] = nil

	CallbacksToExec[priority][monitorData.Callback] = nil
end

function MemoryMonitor.Register(id,addressTbl,callback,priority,skipInit)
	if not Util.IsFunction(callback) then return end

	id = tostring(id)
	priority = tonumber(priority)

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
		["Priority"] = CallbacksToExec[priority] and priority or 1,
		["SkipInit"] = Util.ToBool(skipInit),
	}

	ActiveByID[id] = monitorData
	ActiveByPriority[priority][id] = monitorData

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
	QueueCallback(monitorData)
end

function MemoryMonitor.Unregister(id)
	id = tostring(id)

	local monitorData = ActiveByID[id]
	if not monitorData then return end

	UnregisterInternal(id,monitorData)
end

function MemoryMonitor.ExecuteCallbacks()
	for _,callbackList in ipairs(CallbacksToExec) do
		if Util.IsTableEmpty(callbackList) then goto continue end

		for callback,addressTbl in pairs(callbackList) do
			callback(addressTbl)

			callbackList[callback] = nil
		end

		::continue::
	end
end

function MemoryMonitor.ManuallyExecuteByIDs(...)
	for _,arg in ipairs({...}) do
		local id = tostring(arg)

		local monitorData = ActiveByID[id]

		if monitorData then
			QueueCallback(monitorData)
		end
	end
end

-- Create global memory monitor
event.on_bus_write(function(address)
	local monitors = ActiveByAddress[address]

	if
		not monitors
	or	Util.IsTableEmpty(monitors)
	then return end

	for _,data in pairs(monitors) do
		QueueCallback(data)
	end
end,nil,"HeaddyOverlay.MemoryMonitor.Main")

-- Force-refresh all active monitors upon loading a savestate,
-- skipping CallbacksToExec entirely
event.onloadstate(function()
	for _,priorityTbl in ipairs(ActiveByPriority) do
		for _,data in pairs(priorityTbl) do
			if not data.SkipInit then
				data.Callback(data.AddressTbl)
			end
		end
	end
end,"HeaddyOverlay.MemoryMonitor.ForceRefreshAllMonitors")
