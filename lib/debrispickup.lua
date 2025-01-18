-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI
local LevelMonitor = Overlay.LevelMonitor

local DebrisPickup = {
	["Count"] = 0,
}
Overlay.DebrisPickup = DebrisPickup

local OffsetY = {
	["Min"] = -33,
	["Max"] = -1,
	["Inc"] = 1,
}
DebrisPickup.OffsetY = DebrisPickup.OffsetY or OffsetY.Min

local ContinueReqByVersion = {
	["Int"] = 13,
	["Jpn"] = 10,
}

local TextColour = 0xFFFFFFFF
local PickupString = ""
local PickupGoal = ContinueReqByVersion[Overlay.Lang]

-- Commonly-used functions
local PadStart = bizstring.pad_start
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

MemoryMonitor.Register("DebrisPickup.Count",0xFFE93A,function(addressTbl)
	local newVal = DebrisPickup.Count >= (PickupGoal - 1) and PickupGoal or ReadU16BE(addressTbl[1])

	DebrisPickup.Count = newVal
	PickupString = PadStart(newVal,2,0) .. " / " .. PickupGoal
	TextColour = newVal == PickupGoal and 0xFF00FF00 or 0xFFFFFFFF
end)

function DebrisPickup.Enable(newVal)
	if
		newVal == nil
	or	newVal == DebrisPickup.Render
	then return end

	DebrisPickup.Render = newVal
end

function DebrisPickup.UpdateOffsetY()
	local pos,inc = DebrisPickup.OffsetY,OffsetY.Inc
	local thres,diff

	if DebrisPickup.Render then
		thres = OffsetY.Max

		if pos == thres then
			return
		elseif pos > thres then
			diff = -inc
		else
			diff = inc
		end
	else
		thres = OffsetY.Min

		if pos == thres then
			return
		elseif pos < thres then
			diff = inc
		else
			diff = -inc
		end
	end

	DebrisPickup.OffsetY = pos + diff
end

function DebrisPickup.DrawGUI()
	DebrisPickup.UpdateOffsetY()

	if
		DebrisPickup.OffsetY <= OffsetY.Min
	or	LevelMonitor.InStageTransition
	or	GUI.ScoreTallyActive
	then return end

	local widthHalf = GUI.BufferWidth * .5

	DrawRectangle(
		GUI.BufferWidth * .3,
		DebrisPickup.OffsetY,
		GUI.BufferWidth * .4,
		33,
		0,
		0x7F000000
	)

	DrawString(
		widthHalf,
		DebrisPickup.OffsetY + GUI.BufferHeight * .02,
		"Debris Collected:",
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"center",
		"top"
	)

	DrawString(
		widthHalf,
		DebrisPickup.OffsetY + GUI.BufferHeight * .08,
		PickupString,
		TextColour,
		0xFF000000,
		12,
		"MS Gothic",
		nil,
		"center",
		"top"
	)
end
