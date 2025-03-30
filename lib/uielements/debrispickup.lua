-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI

local DebrisPickup = {
	["Count"] = 0,
}
GUI.Elements.DebrisPickup = DebrisPickup

local Render
local Count = 0

local ElementHeight = 28
local ElementHeightQuart1 = ElementHeight * .25
local ElementHeightQuart3 = ElementHeight * .75

local OffsetYData = {
	["Min"] = -(ElementHeight + 1),
	["Max"] = 0,
	["Inc"] = 1,
}
local OffsetYInit = OffsetYData.Min
local OffsetY = OffsetYInit

local ContinueReqByVersion = {
	["Int"] = 13,
	["Jpn"] = 10,
}

local TextColour = 0xFFFFFFFF
local PickupString = ""
local PickupGoal = ContinueReqByVersion[Overlay.Lang]

-- Cache commonly-used functions and constants
local PadStart = bizstring.pad_start
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

function DebrisPickup.Enable(newVal)
	if
		newVal == nil
	or	newVal == Render
	then return end

	if newVal then
		MemoryMonitor.ManuallyExecuteByIDs("DebrisPickup.Count")
	end

	Render = newVal
end

MemoryMonitor.Register("DebrisPickup.Count",0xFFE93A,function(addressTbl)
	local newVal = Count >= (PickupGoal - 1) and PickupGoal or ReadU16BE(addressTbl[1])

	GUI.InvalidateCheck(Count ~= newVal)

	Count = newVal
	PickupString = PadStart(newVal,2,0) .. " / " .. PickupGoal
	TextColour = newVal == PickupGoal and 0xFF00FF00 or 0xFFFFFFFF
end)

Hook.Set("DrawGUI","DebrisPickup",function(width)
	OffsetY = GUI.LerpOffset(
		OffsetY,
		OffsetYData.Inc,
		OffsetYData.Max,
		OffsetYData.Min,
		Render
	)

	if
		OffsetY <= OffsetYData.Min
	or	GUI.IsMenuOrLoadingScreen
	or	GUI.ScoreTallyActive
	then return end

	local widthHalf = width * .5

	DrawRectangle(
		width * .3,
		OffsetY,
		width * .4,
		ElementHeight,
		0x7F000000,
		0x7F000000
	)

	DrawString(
		widthHalf,
		OffsetY + ElementHeightQuart1,
		"Debris Collected:",
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"center",
		"middle"
	)

	DrawString(
		widthHalf,
		OffsetY + ElementHeightQuart3,
		PickupString,
		TextColour,
		0xFF000000,
		12,
		"MS Gothic",
		nil,
		"center",
		"middle"
	)
end)

Hook.Set("LevelChange","DebrisPickup",function()
	DebrisPickup.Enable(false)
	OffsetY = OffsetYInit
end)
