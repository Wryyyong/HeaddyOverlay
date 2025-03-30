-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor

local GUI = {}
Overlay.GUI = GUI

local Elements = {}
GUI.Elements = Elements

local Invalidated = true

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
local GuiClearGraphics = gui.clearGraphics
local ClientBufferWidth,ClientBufferHeight = client.bufferwidth,client.bufferheight

function GUI.InvalidateCheck(check)
	if Invalidated or not check then return end

	Invalidated = true
end

function GUI.Draw()
	Hook.Run("PreDrawGUI")

	if not Invalidated then return end
	Invalidated = false

	GuiClearGraphics()

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

	GUI.InvalidateCheck(true)

	return oldPos + diff
end

MemoryMonitor.Register("GUI.StageRoutineScoreTally",0xFFE850,function(addressTbl)
	local newVal = ReadU16BE(addressTbl[1]) > LevelMonitor.CurrentLevel.ScoreTallyThres

	GUI.InvalidateCheck(GUI.ScoreTallyActive ~= newVal)

	GUI.ScoreTallyActive = newVal
end)

MemoryMonitor.Register("GUI.IsMenuOrLoadingScreen",{
	["Game.State"] = 0xFFE802,
	["Game.Routine"] = 0xFFE804,
	["Game.Curtains"] = 0xFFE8CC,
},function(addressTbl)
	local newVal =
		ReadU16BE(addressTbl["Game.State"]) ~= 0x20
	or	ReadU16BE(addressTbl["Game.Routine"]) ~= 0
	or	ReadU16BE(addressTbl["Game.Curtains"]) ~= 0x9200

	GUI.InvalidateCheck(GUI.IsMenuOrLoadingScreen ~= newVal)

	GUI.IsMenuOrLoadingScreen = newVal
end)

Hook.Set("LevelChange","GUI",function()
	GUI.ScoreTallyActive = false

	Hook.ClearAll("DrawCustomElements")
end)
