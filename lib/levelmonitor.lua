-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

local LevelMonitor = Overlay.LevelMonitor or {}
Overlay.LevelMonitor = LevelMonitor

local LevelData = {}
LevelMonitor.LevelData = LevelData

-- Commonly-used functions
local SetMetaTable = setmetatable
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

-- Include sub-scripts
local ScenePath = "lib/scenes/"
dofile(ScenePath .. "scene34.lua")
dofile(ScenePath .. "scene64.lua")
dofile(ScenePath .. "scene71.lua")
dofile(ScenePath .. "scene93.lua")

-- Default/fallback values for LevelData entries so we
-- don't need to specify them in every single subtable
local LevelDataDefault = {
	["LevelName"] = [[!! UNRECOGNISED LEVEL !!]],
	["LevelMonitorIDList"] = {},

	["LevelScript"] = function()
	end,
}

SetMetaTable(LevelData,{
	["__index"] = function()
		return LevelDataDefault
	end,
})

local LevelDataMeta = {
	["__index"] = LevelDataDefault,
}

for _,sceneTbl in pairs(LevelData) do
	SetMetaTable(sceneTbl,LevelDataMeta)
end

MemoryMonitor.Register("LevelMonitor.CurrentLevel",0xFFE8AA,function(address)
	local oldLevel = LevelMonitor.CurrentLevel or LevelDataDefault
	local newLevel = LevelData[ReadU16BE(address)]

	LevelMonitor.CurrentLevel = newLevel

	BossHealth.DestroyAll()

	for _,id in ipairs(oldLevel.LevelMonitorIDList) do
		MemoryMonitor.Unregister(id)
	end

	newLevel.LevelScript()
end,true)

MemoryMonitor.Register("LevelMonitor.InStageTransition",0xFFE8CC,function(address)
	LevelMonitor.InStageTransition = ReadU16BE(address) ~= 0x9200
end,true)

function LevelMonitor.DrawGUI()
	DrawRectangle(-1,Overlay.BufferHeight - 16,Overlay.BufferWidth + 1,16,0,0x7F000000)
	DrawString(Overlay.BufferWidth * 0.5,Overlay.BufferHeight - 9,LevelMonitor.CurrentLevel.LevelName,nil,nil,12,"Courier New","regular","center","middle")
end
