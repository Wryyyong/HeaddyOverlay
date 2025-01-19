-- Set up globals and local references
local Overlay = HeaddyOverlay

local GUI = {}
Overlay.GUI = GUI

local OffsetY = {
	["Min"] = 0,
	["Max"] = 96,
	["Inc"] = 32 / 28,
}
GUI.GlobalOffsetY = GUI.GlobalOffsetY or OffsetY.Max

local CustomElements = {}

-- Commonly-used functions
local type = type
local next = next
local pairs = pairs
local tostring = tostring

local ClientBufferWidth,ClientBufferHeight = client.bufferwidth,client.bufferheight

-- Include sub-scripts
local LibPath = "lib/"
dofile(LibPath .. "headdystats.lua")
dofile(LibPath .. "levelmonitor.lua")
dofile(LibPath .. "secretbonuspopup.lua")

local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth
local DebrisPickup = Overlay.DebrisPickup

-- drawFunc can be either a function or nil; passing nil effectively removes
-- the custom element from the table
function GUI.SetCustomElement(id,drawFunc)
	local funcType = type(drawFunc)

	if
		funcType ~= "nil"
	and	funcType ~= "function"
	then return end

	id = tostring(id)

	CustomElements[id] = drawFunc
end

function GUI.ClearCustomElements()
	if next(CustomElements) == nil then return end

	for id in pairs(CustomElements) do
		CustomElements[id] = nil
	end
end

function GUI.ResetGlobalOffsetY()
	GUI.GlobalOffsetY = OffsetY.Max
end

function GUI.UpdateGlobalOffsetY()
	local diff

	if
		LevelMonitor.InStageTransition
	or	(
			Headdy.DisableGUI
		and	LevelMonitor.DisableGUI
	)
	then
		if GUI.GlobalOffsetY >= OffsetY.Max then return end

		diff = OffsetY.Inc
	else
		if GUI.GlobalOffsetY <= OffsetY.Min then return end

		diff = -OffsetY.Inc * .5
	end

	local newOffset = GUI.GlobalOffsetY + diff

	if newOffset < OffsetY.Min then
		newOffset = OffsetY.Min
	elseif newOffset > OffsetY.Max then
		newOffset = OffsetY.Max
	end

	GUI.GlobalOffsetY = newOffset
end

function GUI.Draw()
	GUI.BufferWidth,GUI.BufferHeight = ClientBufferWidth(),ClientBufferHeight()

	GUI.UpdateGlobalOffsetY()
	Headdy.DrawGUI()
	LevelMonitor.DrawGUI()
	DebrisPickup.DrawGUI()

	BossHealth.DrawAll()

	if next(CustomElements) == nil then return end

	for _,drawFunc in pairs(CustomElements) do
		drawFunc()
	end
end
