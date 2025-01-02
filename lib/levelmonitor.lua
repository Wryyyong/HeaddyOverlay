-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

local LevelMonitor = Overlay.LevelMonitor or {}
Overlay.LevelMonitor = LevelMonitor

local LevelDataDefault = {
	["LevelName"] = [[!! INVALID LEVEL !!]],
	["LevelMonitorIDList"] = {}

	["LevelScript"] = function()
	end,
}

LevelMonitor.LevelData = {}
local LevelData = LevelMonitor.LevelData
setmetatable(LevelData,{
	["__index"] = function()
		return LevelDataDefault
	end,
})

-- Include sub-scripts
local ScenePath = "lib/scenes/"
dofile(ScenePath .. "scene64.lua")

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

local function UpdateCurrentLevel()
	local oldLevel = LevelMonitor.CurrentLevel
	local newLevel = LevelData[ReadU16BE(0xFFE8AA)]

	LevelMonitor.CurrentLevel = newLevel

	BossHealth.DestroyAll()

	for _,id in ipairs(oldLevel.LevelMonitorIDList) do
		MemoryMonitor.Unregister(id)
	end

	newLevel.LevelScript()
end

local function UpdateInStageTransition()
	LevelMonitor.InStageTransition = ReadU16BE(0xFFE8CC) ~= 0x9200
end

UpdateCurrentLevel()
UpdateInStageTransition()

MemoryMonitor.Register("LevelMonitor.CurrentLevel",0xFFE8AA,UpdateCurrentLevel,true)
MemoryMonitor.Register("LevelMonitor.InStageTransition",0xFFE8CC,UpdateInStageTransition,true)

function LevelMonitor.DrawGUI()
	DrawRectangle(-1,Overlay.BufferHeight - 16,Overlay.BufferWidth + 1,16,0,0x7F000000)
	DrawString(Overlay.BufferWidth * 0.5,Overlay.BufferHeight - 9,LevelMonitor.CurrentLevel.LevelName,nil,nil,12,"Courier New","regular","center","middle")
end
