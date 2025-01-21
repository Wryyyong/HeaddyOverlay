-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor

local GUI = {}
Overlay.GUI = GUI

local Elements = {}
GUI.Elements = Elements

local CustomElements = {}

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be
local ClientBufferWidth,ClientBufferHeight = client.bufferwidth,client.bufferheight

-- Include sub-scripts
local LibPath = "lib/"
dofile(LibPath .. "headdystats.lua")
dofile(LibPath .. "levelmonitor.lua")

local UiElemPath = LibPath .. "uielements/"
dofile(UiElemPath .. "mainhud.lua")
dofile(UiElemPath .. "bosshealth.lua")
dofile(UiElemPath .. "debrispickup.lua")
dofile(UiElemPath .. "secretbonuspopup.lua")

local LevelMonitor = Overlay.LevelMonitor

function GUI.Draw()
	local width,height = ClientBufferWidth(),ClientBufferHeight()

	Hook.Run("DrawGUI",width,height)
	Hook.Run("DrawCustomElements",width,height)
end

function GUI.LerpOffset(oldPos,inc,thresTrue,thresFalse,check)
	local diff

	if check then
		if oldPos == thresTrue then
			return oldPos
		elseif oldPos > thresTrue then
			diff = -inc
		else
			diff = inc
		end
	else
		if oldPos == thresFalse then
			return oldPos
		elseif oldPos < thresFalse then
			diff = inc
		else
			diff = -inc
		end
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
