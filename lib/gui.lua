-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor

local GUI = {}
Overlay.GUI = GUI

local Elements = {}
GUI.Elements = Elements

-- Execute sub-scripts
local LibPath = "lib/"
dofile(LibPath .. "headdystats.lua")
dofile(LibPath .. "levelmonitor.lua")

local UiElemPath = LibPath .. "uielements/"
dofile(UiElemPath .. "mainhud.lua")
dofile(UiElemPath .. "bosshealth.lua")
dofile(UiElemPath .. "debrispickup.lua")
dofile(UiElemPath .. "secretbonuspopup.lua")

local LevelMonitor = Overlay.LevelMonitor

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be
local ClientBufferWidth,ClientBufferHeight = client.bufferwidth,client.bufferheight

function GUI.Draw()
	local width,height = ClientBufferWidth(),ClientBufferHeight()

	Hook.Run("DrawGUI",width,height)
	Hook.Run("DrawCustomElements",width,height)
end

function GUI.LerpOffset(oldPos,inc,thresTrue,thresFalse,check)
	local thresUse = check and thresTrue or thresFalse
	local diff

	if oldPos == thresUse then
		return oldPos
	elseif oldPos > thresUse then
		diff = -inc
	else
		diff = inc
	end

	return oldPos + diff
end

MemoryMonitor.Register("GUI.StageRoutineScoreTally",0xFFE850,function(addressTbl)
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

	Hook.ClearAll("DrawCustomElements")
end)
