-- Set up and/or create local references to our "namespaces"
local Util = HeaddyOverlay.Util

-- Cache commonly-used functions and constants
local type = type

function Util.IsTypeMulti(obj,...)
	local objType = type(obj)

	for _,inType in ipairs({...}) do
		if objType == inType then
			return true
		end
	end

	return false
end

function Util.IsTable(obj)
	return type(obj) == "table"
end

function Util.IsFunction(obj)
	return type(obj) == "function"
end
