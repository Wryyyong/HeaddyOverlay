-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local GUI = Overlay.GUI
local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor

local MainHud = {}
GUI.Elements.MainHud = MainHud

local ElementHeight = 28
local ElementHeightQuart1 = ElementHeight * .25
local ElementHeightQuart3 = ElementHeight * .75

local OffsetYData = {
	["Min"] = -ElementHeight,
	["Max"] = 60,
	["Inc"] = 1,
}
local OffsetYInit = OffsetYData.Max
local OffsetY = OffsetYInit

-- Cache commonly-used functions and constants
local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

Hook.Set("DrawGUI","MainHud",function(width,height)
	OffsetY = GUI.LerpOffset(
		OffsetY,
		OffsetYData.Inc,
		OffsetYData.Max,
		OffsetYData.Min,

			MainHud.ForceDisable
		or	GUI.IsMenuOrLoadingScreen
		or	GUI.ScoreTallyActive
	)

	if
		MainHud.ForceDisable
	or	GUI.ScoreTallyActive
	then return end

	local widthHalf = width * .5
	local heightBase = OffsetY + height

	local stringHeightUpper = heightBase + ElementHeightQuart1
	local stringHeightLower = heightBase + ElementHeightQuart3

	-- Background
	DrawRectangle(
		0,
		heightBase,
		width,
		ElementHeight,
		0x7F000000,
		0x7F000000
	)

	-- LevelName
	DrawString(
		widthHalf,
		stringHeightLower,
		LevelMonitor.LevelNameString,
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"center",
		"middle"
	)

	-- Health
	DrawString(
		1,
		stringHeightUpper,
		Headdy.StatStrings.Health,
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"left",
		"middle"
	)

	-- Score
	DrawString(
		widthHalf,
		stringHeightUpper,
		Headdy.StatStrings.Score,
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"center",
		"middle"
	)

	-- Lives
	DrawString(
		width - 1,
		stringHeightUpper,
		Headdy.StatStrings.Lives,
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"right",
		"middle"
	)
end)

Hook.Set("LevelChange","MainHud",function()
	MainHud.ForceDisable = false
	OffsetY = OffsetYInit
end)
