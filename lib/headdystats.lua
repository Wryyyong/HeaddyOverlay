-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI

local Headdy = {
	["StatStrings"] = {
		["Health"] = "",
		["Score"] = "",
		["Lives"] = "",
	},
}
Overlay.Headdy = Headdy

local StatStrings = Headdy.StatStrings
local ScoreStore = {
	["Total"] = 0,
	["Stage"] = 0,
	["Time"] = 0,
	["Secret"] = 0,
}

-- Commonly-used functions
local MathHuge = math.huge

local PadStart = bizstring.pad_start
local ReadU16BE = memory.read_u16_be

function Headdy.SetInfiniteLives(newVal)
	if
		newVal == nil
	or	newVal == Headdy.InfiniteLives
	then return end

	Headdy.InfiniteLives = newVal

	MemoryMonitor.ManuallyExecuteByIDs("Headdy.LivesContinues")
end

MemoryMonitor.Register("Headdy.Health",0xFFD200,function(addressTbl)
	-- Headdy technically has a max health of 32, but this only ever gets
	-- incremented/decremented in multiples of 2, effectively halving this value.
	local newVal = ReadU16BE(addressTbl[1]) >> 1

	Headdy.Health = newVal
	StatStrings.Health = "Health: " .. PadStart(newVal,2,0) .. " / 16"
end)

MemoryMonitor.Register("Headdy.Score",{
	["Score.Stage"] = 0xFFE8F0,
	["Score.Time"] = 0xFFE8F2,
	["Score.Secret"] = 0xFFE8F4,
},function(addressTbl)
	if GUI.ScoreTallyActive then return end

	ScoreStore.Stage = ReadU16BE(addressTbl["Score.Stage"])
	ScoreStore.Time = ReadU16BE(addressTbl["Score.Time"])
	ScoreStore.Secret = ReadU16BE(addressTbl["Score.Secret"])

	local newScore =
		(
			ScoreStore.Total
		+	ScoreStore.Stage
		+	ScoreStore.Time
		+	ScoreStore.Secret
	) * 100

	StatStrings.Score = "Score: " .. PadStart(newScore,6,0)
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

Hook.Set("LevelChange","Headdy",function()
	Headdy.SetInfiniteLives(false)

	ScoreStore.Total = ReadU16BE(0xFFE8FA)
	MemoryMonitor.ManuallyExecuteByIDs("Headdy.Score")
end)
