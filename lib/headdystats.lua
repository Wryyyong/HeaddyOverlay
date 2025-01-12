-- Set up globals and local references
local Overlay = HeaddyOverlay
local GUI = Overlay.GUI
local MemoryMonitor = Overlay.MemoryMonitor

local Headdy = Overlay.Headdy or {}
Overlay.Headdy = Headdy

local StatStrings = {
	["Health"] = "",
	["Lives"] = "",
	["ContinueLives"] = "",
}

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be
local MathToInt = math.tointeger
local StringSub = string.sub

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

MemoryMonitor.Register("Headdy.Health",0xFFD200,function(addressTbl)
	-- Headdy technically has a max health of 32, but this only ever gets
	-- incremented/decremented in multiples of 2, effectively halving his health.
	local newVal = MathToInt(ReadU16BE(addressTbl[1]) * .5)
	Headdy.Health = newVal

	StatStrings.Health = "Health: " .. StringSub(0 .. newVal,-2) .. " / 16"
end)

MemoryMonitor.Register("Headdy.Lives",0xFFE8EC,function(addressTbl)
	local newVal = ReadU16BE(addressTbl[1])
	Headdy.Lives = newVal

	StatStrings.Lives = "Lives: " .. newVal
end)

MemoryMonitor.Register("Headdy.Continues",0xFFE93C,function(addressTbl)
	local newVal = ReadU16BE(addressTbl[1])
	Headdy.Continues = newVal

	StatStrings.ContinueLives = newVal > 0 and "(+" .. newVal * 3 .. ")" or ""
end)

function Headdy.DrawGUI()
	if Headdy.DisableGUI then return end

	-- Background
	DrawRectangle(
		-1,
		GUI.GlobalOffsetY + GUI.BufferHeight - 33,
		GUI.BufferWidth + 1,
		17,
		0,
		0x7F000000
	)

	local StringHeight = GUI.GlobalOffsetY + GUI.BufferHeight - 2 - 16

	-- Health
	DrawString(
		1,
		StringHeight,
		StatStrings.Health,
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"left",
		"bottom"
	)

	-- Lives
	DrawString(
		GUI.BufferWidth - 32 - 1,
		StringHeight,
		StatStrings.Lives,
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"right",
		"bottom"
	)

	-- Extra lives from available continues
	DrawString(
		GUI.BufferWidth - 1,
		StringHeight,
		StatStrings.ContinueLives,
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"right",
		"bottom"
	)
end
