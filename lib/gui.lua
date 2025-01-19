-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor

local GUI = {}
Overlay.GUI = GUI

local OffsetY = {
	["Min"] = 0,
	["Max"] = 96,
	["Inc"] = 32 / 28,
}
GUI.GlobalOffsetY = GUI.GlobalOffsetY or OffsetY.Max

-- Commonly-used functions
local type = type
local next = next
local pairs = pairs
local tostring = tostring

local ReadU16BE = memory.read_u16_be
local ClientBufferWidth,ClientBufferHeight = client.bufferwidth,client.bufferheight

-- Include sub-scripts
local LibPath = "lib/"
dofile(LibPath .. "headdystats.lua")
dofile(LibPath .. "levelmonitor.lua")
dofile(LibPath .. "bosshealth.lua")
dofile(LibPath .. "debrispickup.lua")
dofile(LibPath .. "secretbonuspopup.lua")

local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor

function GUI.UpdateGlobalOffsetY()
	local diff

	if
		GUI.IsMenuOrLoadingScreen
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

	Hook.Run("DrawGUI")
	Hook.Run("DrawCustomElements")
end

MemoryMonitor.Register("GUI.StageFlagsScoreTally",0xFFE850,function(addressTbl)
	GUI.ScoreTallyActive = ReadU16BE(addressTbl[1]) > LevelMonitor.CurrentLevel.ScoreTallyThres
end)

MemoryMonitor.Register("GUI.IsMenuOrLoadingScreen",{
	["Game.State"] = 0xFFE802,
	["Game.Routine"] = 0xFFE804,
	["Game.Curtains"] = 0xFFE8CC,
},function(addressTbl)
	GUI.IsMenuOrLoadingScreen =
		ReadU16BE(addressTbl["Game.State"]) ~= 0x20
	or	ReadU16BE(addressTbl["Game.Routine"]) ~= 0
	or	ReadU16BE(addressTbl["Game.Curtains"]) ~= 0x9200
end)

Hook.Set("LevelChange","GUI",function()
	GUI.ScoreTallyActive = false
	GUI.GlobalOffsetY = OffsetY.Max

	Hook.ClearAll("DrawCustomElements")
end)
