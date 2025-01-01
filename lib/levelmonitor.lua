-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

Overlay.LevelMonitor = Overlay.LevelMonitor or {}
local LevelMonitor = Overlay.LevelMonitor

local LevelDataDefault = {
	["LevelName"] = [[!! INVALID LEVEL !!]],

	["LevelInit"] = function()
	end,

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

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

local function UpdateCurrentLevel()
	local oldLevel = LevelMonitor.CurrentLevel
	local newLevel = LevelData[ReadU16BE(0xFFE8AA)]

	LevelMonitor.CurrentLevel = newLevel

	BossHealth.DestroyAll()

	if oldLevel ~= newLevel then
		oldLevel.LevelInit()
	end

	newLevel.LevelInit()
	newLevel.LevelScript()
end

local function UpdateInStageTransition()
	LevelMonitor.InStageTransition = ReadU16BE(0xFFE8CC) ~= 0x9200
end

UpdateCurrentLevel()
UpdateInStageTransition()

MemoryMonitor.RegisterMonitor("LevelMonitor.CurrentLevel",0xFFE8AA,UpdateCurrentLevel,true)
MemoryMonitor.RegisterMonitor("LevelMonitor.InStageTransition",0xFFE8CC,UpdateInStageTransition,true)

function LevelMonitor.DrawGUI()
	DrawRectangle(-1,Overlay.BufferHeight - 16,Overlay.BufferWidth + 1,16,0,0x7F000000)
	DrawString(Overlay.BufferWidth * 0.5,Overlay.BufferHeight - 9,LevelMonitor.CurrentLevel.LevelName,nil,nil,12,"Courier New","regular","center","middle")
end
