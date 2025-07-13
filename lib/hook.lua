--[[
	Loosely based on "Garry's Mod"'s hook library
	https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/hook.lua
--]]

-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Util = Overlay.Util

local Hook = {}
Overlay.Hook = Hook

local HookTable = {}

-- Cache commonly-used functions and constants
local pairs = pairs
local tostring = tostring

function Hook.Set(event,id,func)
	if not Util.IsTypeMulti(func,"nil","function") then return end

	event = tostring(event)

	if not HookTable[event] then
		HookTable[event] = {}
	end

	HookTable[event][tostring(id)] = func
end

function Hook.ClearAll(event)
	local eventTbl = HookTable[tostring(event)]

	if
		not eventTbl
	or	Util.IsTableEmpty(eventTbl)
	then return end

	for id in pairs(eventTbl) do
		eventTbl[id] = nil
	end
end

function Hook.Run(event,...)
	local eventTbl = HookTable[tostring(event)]

	if
		not eventTbl
	or	Util.IsTableEmpty(eventTbl)
	then return end

	for _,func in pairs(eventTbl) do
		func(...)
	end
end
