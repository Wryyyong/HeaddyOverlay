-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI
local Headdy = Overlay.Headdy

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

-- Set up BossHealth here to avoid mutual dependency issues
dofile("lib/bosshealth.lua")

local BossHealth = Overlay.BossHealth

-- Include sub-scripts
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
	["ScoreTallyThres"] = math.huge,

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

LevelMonitor.CurrentLevel = LevelDataDefault

MemoryMonitor.Register("LevelMonitor.CurrentLevel",0xFFE8AA,function(addressTbl)
	local newLevel = LevelData[ReadU16BE(addressTbl[1])]

	LevelMonitor.CurrentLevel = newLevel
	UpdateLevelNameString()

	BossHealth.DestroyAll()
	MemoryMonitor.Unregister("SceneMonitor")

	Headdy.DisableGUI = false
	Headdy.SetInfiniteLives(false)
	Headdy.CommitTotalScore()

	LevelMonitor.DisableGUI = false

	GUI.ScoreTallyActive = false
	GUI.ResetGlobalOffsetY()
	GUI.ClearCustomElements()

	newLevel.LevelScript()

	MemoryMonitor.ManuallyExecuteByIDs("Headdy.Health")
end)

MemoryMonitor.Register("LevelMonitor.StageFlags",0xFFE850,function(addressTbl)
	local newVal = ReadU16BE(addressTbl[1])
	LevelMonitor.StageFlags = newVal

	GUI.ScoreTallyActive = newVal > LevelMonitor.CurrentLevel.ScoreTallyThres
end)

MemoryMonitor.Register("LevelMonitor.InStageTransition",{
	["Status"] = 0xFFE804,
	["Curtains"] = 0xFFE8CC,
},function(addressTbl)
	LevelMonitor.InStageTransition =
		ReadU16BE(addressTbl["Status"]) ~= 0
	or	ReadU16BE(addressTbl["Curtains"]) ~= 0x9200
end)

function LevelMonitor.SetSceneMonitor(addressTbl,callback)
	MemoryMonitor.Register("SceneMonitor",addressTbl,callback)
end

function LevelMonitor.DrawGUI()
	if
		LevelMonitor.DisableGUI
	or	GUI.ScoreTallyActive
	then return end

	DrawRectangle(
		-1,
		GUI.GlobalOffsetY + GUI.BufferHeight - 17,
		GUI.BufferWidth + 1,
		17,
		0,
		0x7F000000
	)

	DrawString(
		GUI.BufferWidth * .5,
		GUI.GlobalOffsetY + GUI.BufferHeight - 2,
		LevelNameString,
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"center",
		"bottom"
	)
end
