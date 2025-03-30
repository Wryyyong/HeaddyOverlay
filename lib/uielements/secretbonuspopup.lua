-- Set up and/or create local references to our "namespaces"
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
	["Transparency"] = {
		["Init"] = 0xFF,
		["Value"] = 0,
	},
}

local CPopUp = Counters.PopUp
local CFadeOut = Counters.FadeOut
local CTrans = Counters.Transparency

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

-- Cache commonly-used functions and constants
local MathFloor = math.floor

local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

local function ProcessCounters()
	local newPopUp = CPopUp.Value - 1
	CPopUp.Value = newPopUp

	if newPopUp <= 0 then
		local newFadeOut = CFadeOut.Value - 1
		CFadeOut.Value = newFadeOut

		CTrans.Value = MathFloor((newFadeOut / CFadeOut.Init) * CTrans.Init)

		GUI.InvalidateCheck(true)
	end

	if CFadeOut.Value > 0 then return end

	Hook.Set("PreDrawGUI","SecretBonusPopUpPreProc")
	Hook.Set("DrawCustomElements","SecretBonusPopUp")
end

local function DrawPopUp(width,height)
	local height125 = height * .125
	local height175 = height * .175

	local transBase = CTrans.Value
	local transHalf = (transBase >> 1) << 24
	local transMain = transBase << 24

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
end

MemoryMonitor.Register("GUI.SecretBonusPoints",0xFFE8F6,function(addressTbl)
	local totalBonuses = BonusPointsBySceneMajor[LevelMonitor.CurrentLevel.SceneNumbers.Major]

	if
		not totalBonuses
	or	GUI.IsMenuOrLoadingScreen
	or	GUI.ScoreTallyActive
	then return end

	PopUpString = ReadU16BE(addressTbl[1]) .. " / " .. totalBonuses

	for _,counter in pairs(Counters) do
		counter.Value = counter.Init
	end

	Hook.Set("PreDrawGUI","SecretBonusPopUpPreProc",ProcessCounters)
	Hook.Set("DrawCustomElements","SecretBonusPopUp",DrawPopUp)

	GUI.InvalidateCheck(true)
end,true)
