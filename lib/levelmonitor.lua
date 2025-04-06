-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI

local LevelMonitor = {
	["LevelNameString"] = "",
}
Overlay.LevelMonitor = LevelMonitor

local LevelData = {}
LevelMonitor.LevelData = LevelData

-- Cache commonly-used functions and constants
local setmetatable = setmetatable

local ReadU16BE = memory.read_u16_be

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
	["DisableMainHud"] = false,
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

	GUI.InvalidateCheck(LevelMonitor.LevelNameString ~= newStr)

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
	MemoryMonitor.ManuallyExecuteByIDs("Headdy.Health")

	Hook.Run("LevelChange")

	newLevel.LevelScript()
end)

Hook.Set("FinalizeSetup","ExecuteSceneScripts",function()
	for _,script in ipairs({
		"scene11",
		"scene22",
		"scene23",
		"scene32",
		"scene33",
		"scene34",
		"scene41",
		"scene44",
		"scene52",
		"scene53",
		"scene54",
		"scene61",
		"scene62",
		"scene64",
		"scene71",
		"scene82",
		"scene83",
		"scene84",
		"scene85",
		"scene93",
		"sceneXX",
		"intermission",
		"inputsecretnumber",
		"gameover",
		"nogui",
		"misc",
	}) do
		dofile("lib/scenes/" .. script .. ".lua")
	end

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
