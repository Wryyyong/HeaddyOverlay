-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI
local LevelMonitor = Overlay.LevelMonitor

local Counters = {
	["PopUp"] = {
		["Init"] = 180,
		["Value"] = 0,
	},
	["FadeOut"] = {
		["Init"] = 30,
		["Value"] = 0,
	},
}

local CPopUp = Counters.PopUp
local CFadeOut = Counters.FadeOut

local PopUpString = ""

local BonusPointsBySceneMajor = {
	["1"] = 1,
	["2"] = 8,
	["3"] = 4,
	["4"] = 7,
	["5"] = 3,
	["6"] = 3,
	["7"] = 3,
	["8"] = 6,
	["9"] = 4,
}

-- Commonly-used functions
local MathFloor = math.floor

local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

local function DrawPopUp(width,height)
	local height125 = height * .125
	local height175 = height * .175
	local transparency = 0xFF

	local newPopUp = CPopUp.Value - 1
	CPopUp.Value = newPopUp

	if newPopUp <= 0 then
		local newFadeOut = CFadeOut.Value - 1
		CFadeOut.Value = newFadeOut

		transparency = MathFloor((newFadeOut / CFadeOut.Init) * transparency)
	end

	local transHalf = (transparency >> 1) << 24
	local transMain = transparency << 24

	DrawRectangle(
		width * .4,
		height175,
		width * .2,
		height125,
		transHalf,
		transHalf
	)

	DrawString(
		width * .5,
		height175 + height125 * .5 + 2,
		PopUpString,
		transMain + 0xFFFFFF,
		transMain,
		16,
		"MS Gothic",
		nil,
		"center",
		"middle"
	)

	if CFadeOut.Value > 0 then return end

	Hook.Set("DrawCustomElements","SecretBonusPopUp")
end

MemoryMonitor.Register("GUI.SecretBonusPoints",0xFFE8F6,function(addressTbl)
	local totalBonuses = BonusPointsBySceneMajor[LevelMonitor.CurrentLevel.SceneNumbers.Major]

	if
		not totalBonuses
	or	GUI.IsMenuOrLoadingScreen
	or	GUI.ScoreTallyActive
	then return end

	PopUpString = ReadU16BE(addressTbl[1]) .. " / " .. totalBonuses
	CPopUp.Value = CPopUp.Init
	CFadeOut.Value = CFadeOut.Init

	Hook.Set("DrawCustomElements","SecretBonusPopUp",DrawPopUp)
end,true)
