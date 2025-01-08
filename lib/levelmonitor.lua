-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

local LevelMonitor = Overlay.LevelMonitor or {}
Overlay.LevelMonitor = LevelMonitor

local LevelData = {}
LevelMonitor.LevelData = LevelData

local LevelNameString = ""

-- Commonly-used functions
local setmetatable = setmetatable

local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

-- Include sub-scripts
local ScenePath = "lib/scenes/"
dofile(ScenePath .. "scene11.lua")
dofile(ScenePath .. "scene22.lua")
dofile(ScenePath .. "scene23.lua")
dofile(ScenePath .. "Scene32.lua")
dofile(ScenePath .. "scene33.lua")
dofile(ScenePath .. "scene34.lua")
dofile(ScenePath .. "scene41.lua")
dofile(ScenePath .. "scene52.lua")
dofile(ScenePath .. "scene53.lua")
dofile(ScenePath .. "scene54.lua")
dofile(ScenePath .. "scene61.lua")
dofile(ScenePath .. "scene62.lua")
dofile(ScenePath .. "scene64.lua")
dofile(ScenePath .. "scene71.lua")
dofile(ScenePath .. "scene82.lua")
dofile(ScenePath .. "scene83.lua")
dofile(ScenePath .. "scene84.lua")
dofile(ScenePath .. "scene85.lua")
dofile(ScenePath .. "scene93.lua")
dofile(ScenePath .. "sceneXX.lua")
dofile(ScenePath .. "misc.lua")

-- Default/fallback values for LevelData entries so we
-- don't need to specify them in every single subtable
local LevelDataDefault = {
	["LevelName"] = {
		["Main"] = [[!! UNRECOGNISED LEVEL !!]],
		["Sub"] = {
			["Int"] = [[]],
			["Jpn"] = [[]],
		},
	},

	["LevelScript"] = function()
	end,
}

setmetatable(LevelData,{
	["__index"] = function()
		return LevelDataDefault
	end,
})

local LevelDataMeta = {
	["__index"] = LevelDataDefault,
}

local LevelNameMeta = {
	["__index"] = LevelDataDefault.LevelName,
}

for _,sceneTbl in pairs(LevelData) do
	setmetatable(sceneTbl,LevelDataMeta)

	local levelName = sceneTbl.LevelName
	setmetatable(levelName,LevelNameMeta)
	setmetatable(levelName.Sub,Overlay.LangFallback)
end

local function UpdateLevelNameString()
	local levelName = LevelMonitor.CurrentLevel.LevelName

	local newStr,strSub = levelName.Main,levelName.Sub[Overlay.Lang]
	local doesStrMainExist = #levelName.Main > 0

	if not doesStrMainExist then
		newStr = strSub
	elseif #strSub > 0 then
		newStr = newStr .. (doesStrMainExist and " — " or "") .. strSub
	end

	LevelNameString = newStr
end

MemoryMonitor.Register("LevelMonitor.CurrentLevel",0xFFE8AA,function(addressTbl)
	local newLevel = LevelData[ReadU16BE(addressTbl[1])]

	LevelMonitor.CurrentLevel = newLevel
	UpdateLevelNameString()

	BossHealth.DestroyAll()
	MemoryMonitor.Unregister("SceneMonitor")

	newLevel.LevelScript()
end)

MemoryMonitor.Register("LevelMonitor.InStageTransition",0xFFE8CC,function(addressTbl)
	LevelMonitor.InStageTransition = ReadU16BE(addressTbl[1]) ~= 0x9200
end)

function LevelMonitor.SetSceneMonitor(addressTbl,callback)
	MemoryMonitor.Register("SceneMonitor",addressTbl,callback)
end

function LevelMonitor.DrawGUI()
	DrawRectangle(-1,Overlay.BufferHeight - 16,Overlay.BufferWidth + 1,16,0,0x7F000000)
	DrawString(Overlay.BufferWidth * 0.5,Overlay.BufferHeight - 9,LevelMonitor.CurrentLevel.LevelName,nil,nil,12,"Courier New","regular","center","middle")
end
