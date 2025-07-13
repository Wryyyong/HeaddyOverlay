-- Set up and/or create local references to our "namespaces"
local Util = {}
HeaddyOverlay.Util = Util

-- Execute sub-scripts
for _,script in ipairs({
	"type",
}) do
	dofile("lib/util/" .. script .. ".lua")
end

-- Cache commonly-used functions and constants
local next = next
local tonumber = tonumber

function Util.IsTableEmpty(tbl)
	return next(tbl) == nil
end

function Util.IsInRange(obj,min,max)
	obj = tonumber(obj)
	min = tonumber(min)
	max = tonumber(max)

	return
		obj >= min
	and	obj	<= max
end
