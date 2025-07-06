-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local GUI = Overlay.GUI
local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

LevelMonitor.LevelData[0x3A] = {
	["Name"] = {
		["Int"] = [[Game Over]],
	},
	["DisableMainHud"] = true,

	["LevelScript"] = function()
		if Overlay.Lang == "Jpn" then return end

		local OffsetY = {
			["Prev"] = 0xFFFF,
			["Cur"] = 0xFFFF,
		}

		Hook.Set("DrawCustomElements","GameOverRemainingContinues",function(width)
			if GUI.IsMenuOrLoadingScreen then return end

			local posX = width * .425

			DrawRectangle(
				posX,
				OffsetY.Prev,
				width * .25,
				47,
				0xFF2244EE,
				0xFF000000
			)

			local stringPosX = posX + width * .125

			DrawString(
				stringPosX,
				OffsetY.Prev + 2,
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
				OffsetY.Prev + 47,
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
			["Sprite.Routine"] = 0xFFD132,
			["Sprite.OffsetY"] = 0xFFD530,
		},function(addressTbl)
			-- The game only applies the new position on the frame following
			-- the value change, this mimics the result of that behaviour
			local newPrev = OffsetY.Cur

			GUI.InvalidateCheck(OffsetY.Prev ~= newPrev)

			OffsetY.Prev = newPrev
			OffsetY.Cur = ReadU16BE(addressTbl["Sprite.OffsetY"]) - 152
		end)
	end,
}
