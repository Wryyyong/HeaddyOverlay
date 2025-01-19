--[[
	Loosely based on "Garry's Mod"'s hook library
	https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/hook.lua
--]]

-- Set up globals and local references
local Overlay = HeaddyOverlay

local Hook = {}
Overlay.Hook = Hook

local HookTable = {}

-- Commonly-used functions
local type = type
local next = next
local pairs = pairs
local tostring = tostring

function Hook.Set(event,id,func)
	local funcType = type(func)

	if
		funcType ~= "nil"
	and	funcType ~= "function"
	then return end

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
	or	next(eventTbl) == nil
	then return end

	for id in pairs(eventTbl) do
		eventTbl[id] = nil
	end
end

function Hook.Run(event,...)
	local eventTbl = HookTable[tostring(event)]

	if
		not eventTbl
	or	next(eventTbl) == nil
	then return end

	for _,func in pairs(eventTbl) do
		func(...)
	end
end
