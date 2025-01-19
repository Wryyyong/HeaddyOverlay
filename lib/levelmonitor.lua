-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor

local LevelMonitor = {
	["LevelNameString"] = "",
}
Overlay.LevelMonitor = LevelMonitor

local LevelData = {}
LevelMonitor.LevelData = LevelData

-- Commonly-used functions
local setmetatable = setmetatable

local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

-- Default/fallback values for LevelData entries so we
-- don't need to specify them in every single subtable
local LevelDataDefault = {
	["SceneNumbers"] = {
		["Major"] = "",
		["Minor"] = "",
	},
	["Name"] = {
		["Int"] = [[!! UNRECOGNISED LEVEL !!]],
	},
	["ScoreTallyThres"] = math.huge,

	["LevelScript"] = function()
	end,
}

setmetatable(LevelData,{
	["__index"] = function()
		return LevelDataDefault
	end,
})

LevelMonitor.CurrentLevel = LevelDataDefault

local function UpdateLevelNameString()
	local curLevel = LevelMonitor.CurrentLevel
	local newStr = ""

	local sceneNum = curLevel.SceneNumbers

	if
		#sceneNum.Major > 0
	and	#sceneNum.Minor > 0
	then
		newStr = newStr .. "Scene " .. sceneNum.Major .. "-" .. sceneNum.Minor
	end

	local name = curLevel.Name[Overlay.Lang]

	if #name > 0 then
		newStr = newStr .. (#newStr > 0 and " — " or "") .. name
	end

	LevelMonitor.LevelNameString = newStr
end

function LevelMonitor.SetSceneMonitor(addressTbl,callback)
	MemoryMonitor.Register("SceneMonitor",addressTbl,callback)
end

MemoryMonitor.Register("LevelMonitor.CurrentLevel",0xFFE8AA,function(addressTbl)
	local newLevel = LevelData[ReadU16BE(addressTbl[1])]

	LevelMonitor.CurrentLevel = newLevel
	UpdateLevelNameString()

	MemoryMonitor.Unregister("SceneMonitor")

	Hook.Run("LevelChange")

	newLevel.LevelScript()

	MemoryMonitor.ManuallyExecuteByIDs("Headdy.Health")
end)

Hook.Set("FinalizeSetup","ExecuteSceneScripts",function()
	local ScenePath = "lib/scenes/"

	dofile(ScenePath .. "scene11.lua")
	dofile(ScenePath .. "scene22.lua")
	dofile(ScenePath .. "scene23.lua")
	dofile(ScenePath .. "Scene32.lua")
	dofile(ScenePath .. "scene33.lua")
	dofile(ScenePath .. "scene34.lua")
	dofile(ScenePath .. "scene41.lua")
	dofile(ScenePath .. "scene44.lua")
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
	dofile(ScenePath .. "inputsecretnumber.lua")
	dofile(ScenePath .. "gameover.lua")
	dofile(ScenePath .. "nogui.lua")
	dofile(ScenePath .. "misc.lua")

	local LevelDataMeta = {
		["__index"] = LevelDataDefault,
	}

	local LevelNumMeta = {
		["__index"] = LevelDataDefault.SceneNumbers,
	}

	for _,sceneTbl in pairs(LevelData) do
		setmetatable(sceneTbl,LevelDataMeta)
		setmetatable(sceneTbl.SceneNumbers,LevelNumMeta)
		setmetatable(sceneTbl.Name,Overlay.LangFallback)
	end
end)
