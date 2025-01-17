-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI

local Headdy = {}
Overlay.Headdy = Headdy

local HeightRatio = 208 / 224

local StatStrings = {
	["Health"] = "",
	["Score"] = "",
	["Lives"] = "",
}

local ScoreStore = {
	["Total"] = 0,
	["Stage"] = 0,
	["Time"] = 0,
	["Secret"] = 0,
}

-- Commonly-used functions
local MathHuge = math.huge
local MathToInt = math.tointeger
local StringSub = string.sub
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

MemoryMonitor.Register("Headdy.Health",0xFFD200,function(addressTbl)
	-- Headdy technically has a max health of 32, but this only ever gets
	-- incremented/decremented in multiples of 2, effectively halving his health.
	local newVal = MathToInt(ReadU16BE(addressTbl[1]) * .5)
	Headdy.Health = newVal

	StatStrings.Health = "Health: " .. StringSub("00" .. newVal,-2) .. " / 16"
end)

MemoryMonitor.Register("Headdy.Score",{
	["Score.Stage"] = 0xFFE8F0,
	["Score.Time"] = 0xFFE8F2,
	["Score.Secret"] = 0xFFE8F4,
},function(addressTbl)
	ScoreStore.Stage = ReadU16BE(addressTbl["Score.Stage"])
	ScoreStore.Time = ReadU16BE(addressTbl["Score.Time"])
	ScoreStore.Secret = ReadU16BE(addressTbl["Score.Secret"])

	if GUI.ScoreTallyActive then return end

	local newScore =
			(
				ScoreStore.Total
			+	ScoreStore.Stage
			+	ScoreStore.Time
			+	ScoreStore.Secret
		) * 100

	StatStrings.Score = "Score: " .. StringSub("000000" .. newScore,-6)
end)

MemoryMonitor.Register("Headdy.LivesContinues",{
	["Lives"] = 0xFFE8EC,
	["Continues"] = 0xFFE93C,
},function(addressTbl)
	Headdy.Lives = ReadU16BE(addressTbl["Lives"])
	Headdy.Continues = ReadU16BE(addressTbl["Continues"])

	local newStr = "Lives: "

	if Headdy.InfiniteLives then
		newStr = newStr .. MathHuge
	else
		newStr = newStr .. Headdy.Lives .. (Headdy.Continues > 0 and " (+" .. Headdy.Continues * 3 .. ")" or "")
	end

	StatStrings.Lives = newStr
end)

function Headdy.SetInfiniteLives(newVal)
	if
		newVal == nil
	or	newVal == Headdy.InfiniteLives
	then return end

	Headdy.InfiniteLives = newVal

	MemoryMonitor.ManuallyExecuteByIDs("Headdy.LivesContinues")
end

function Headdy.CommitTotalScore()
	ScoreStore.Total = ReadU16BE(0xFFE8FA)

	MemoryMonitor.ManuallyExecuteByIDs("Headdy.Score")
end

function Headdy.DrawGUI()
	if
		Headdy.DisableGUI
	or	GUI.ScoreTallyActive
	then return end

	-- Background
	DrawRectangle(
		-1,
		GUI.GlobalOffsetY + GUI.BufferHeight - 33,
		GUI.BufferWidth + 1,
		17,
		0,
		0x7F000000
	)

	local StringHeight = GUI.GlobalOffsetY + GUI.BufferHeight * HeightRatio - 2

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

	-- Score
	DrawString(
		GUI.BufferWidth * .5,
		StringHeight,
		StatStrings.Score,
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
		GUI.BufferWidth - 1,
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
end
