-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI
local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor

local MainHud = {}
GUI.Elements.MainHud = MainHud

local HeightRatio = 210 / 224
local OffsetY = {
	["Min"] = 0,
	["Max"] = 30 * 2.5,
	["Inc"] = 1,
}

-- Commonly-used functions
local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

function MainHud.UpdateOffsetY()
	local diff

	if
		MainHud.ForceDisable
	or	GUI.IsMenuOrLoadingScreen
	or	GUI.ScoreTallyActive
	then
		if MainHud.OffsetY >= OffsetY.Max then return end

		diff = OffsetY.Inc
	else
		if MainHud.OffsetY <= OffsetY.Min then return end

		diff = -OffsetY.Inc * .5
	end

	MainHud.OffsetY = MainHud.OffsetY + diff
end

Hook.Set("DrawGUI","MainHud",function(width,height)
	MainHud.UpdateOffsetY()

	if
		MainHud.ForceDisable
	or	GUI.ScoreTallyActive
	then return end

	local widthHalf = width * .5

	local stringHeightBase = MainHud.OffsetY - 1
	local stringHeightUpper = stringHeightBase + height * HeightRatio
	local stringHeightLower = stringHeightBase + height

	-- Background
	DrawRectangle(
		0,
		MainHud.OffsetY + height - 28,
		width,
		28,
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
		"bottom"
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
		"bottom"
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
		"bottom"
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
		"bottom"
	)
end)

Hook.Set("LevelChange","MainHud",function()
	MainHud.ForceDisable = false
	MainHud.OffsetY = OffsetY.Max
end)
