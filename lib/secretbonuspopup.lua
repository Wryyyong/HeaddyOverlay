-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI
local LevelMonitor = Overlay.LevelMonitor

local PopUpCounter = 0
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
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

local function DrawPopup()
	local height125 = GUI.BufferHeight * .125
	local height175 = GUI.BufferHeight * .175

	DrawRectangle(
		GUI.BufferWidth * .4,
		height175,
		GUI.BufferWidth * .2,
		height125,
		0,
		0x7F000000
	)

	DrawString(
		GUI.BufferWidth * .5,
		height175 + height125 * .5 + 2,
		PopUpString,
		nil,
		0xFF000000,
		16,
		"MS Gothic",
		nil,
		"center",
		"middle"
	)

	PopUpCounter = PopUpCounter - 1
	if PopUpCounter > 0 then return end

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
	PopUpCounter = 300

	Hook.Set("DrawCustomElements","SecretBonusPopUp",DrawPopup)
end,true)
