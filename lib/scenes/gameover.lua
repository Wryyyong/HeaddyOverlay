-- Set up globals and local references
local Overlay = HeaddyOverlay
local GUI = Overlay.GUI
local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

LevelMonitor.LevelData[0x3A] = {
	["LevelName"] = {
		["Main"] = [[Game Over]],
	},

	["LevelScript"] = function()
		Headdy.DisableGUI = true
		LevelMonitor.DisableGUI = true

		if Overlay.Lang == "Jpn" then return end

		local OffsetY = 0xFFFF

		GUI.AddCustomElement("GameOverRemainingContinues",function()
			local posX = GUI.BufferWidth * .425
			local width = GUI.BufferWidth * .25

			DrawRectangle(
				posX,
				OffsetY,
				width,
				46,
				0xFF2244EE,
				0xFF000000
			)

			local stringPosX = posX + width * .5

			DrawString(
				stringPosX,
				OffsetY + 2,
				"Continues\nremaining:",
				nil,
				nil,
				10,
				"MS Gothic",
				nil,
				"center",
				"top"
			)
			DrawString(
				stringPosX,
				OffsetY + 46,
				Headdy.Continues,
				nil,
				nil,
				16,
				"MS Gothic",
				nil,
				"center",
				"bottom"
			)
		end)

		LevelMonitor.SetSceneMonitor({
			["Sprite.Flags"] = 0xFFD132,
			["Sprite.OffsetY"] = 0xFFD530,
		},function(addressTbl)
			if ReadU16BE(addressTbl["Sprite.Flags"]) < 6 then return end

			OffsetY = ReadU16BE(addressTbl["Sprite.OffsetY"]) - 152
		end)
	end,
}
