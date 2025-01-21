-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local GUI = Overlay.GUI
local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor
local MainHud = GUI.Elements.MainHud

-- Commonly-used functions
local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

LevelMonitor.LevelData[0x44] = {
	["Name"] = {
		["Int"] = [[Intermission]],
	},

	["LevelScript"] = function()
		MainHud.ForceDisable = true

		local ElementHeight = 14
		local ElementHeightHalf = ElementHeight * .5

		local OffsetYData = {
			["Min"] = -ElementHeight,
			["Max"] = 60,
			["Inc"] = 1,
		}
		local OffsetY = OffsetYData.Max

		Hook.Set("DrawCustomElements","CompactHud",function(width,height)
			OffsetY = GUI.LerpOffset(
				OffsetY,
				OffsetYData.Inc,
				OffsetYData.Max,
				OffsetYData.Min,
				GUI.IsMenuOrLoadingScreen
			)

			local widthHalf = width * .5
			local heightBase = OffsetY + height

			local stringHeight = heightBase + ElementHeightHalf

			-- Background
			DrawRectangle(
				0,
				heightBase,
				width,
				ElementHeight,
				0x7F000000,
				0x7F000000
			)

			-- Health
			DrawString(
				1,
				stringHeight,
				Headdy.StatStrings.Health,
				nil,
				0xFF000000,
				10,
				"MS Gothic",
				nil,
				"left",
				"middle"
			)

			-- LevelName
			DrawString(
				width - 1,
				stringHeight,
				LevelMonitor.LevelNameString,
				nil,
				0xFF000000,
				10,
				"MS Gothic",
				nil,
				"right",
				"middle"
			)
		end)
	end,
}
