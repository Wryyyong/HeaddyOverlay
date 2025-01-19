-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local GUI = Overlay.GUI
local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor
local MainHud = GUI.Elements.MainHud

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

LevelMonitor.LevelData[0x3A] = {
	["Name"] = {
		["Int"] = [[Game Over]],
	},

	["LevelScript"] = function()
		MainHud.ForceDisable = true

		if Overlay.Lang == "Jpn" then return end

		local OffsetY = {
			["Prev"] = 0xFFFF,
			["Cur"] = 0xFFFF,
		}

		Hook.Set("DrawCustomElements","GameOverRemainingContinues",function(width,height)
			if GUI.IsMenuOrLoadingScreen then return end

			local posX = width * .425
			local width = width * .25

			DrawRectangle(
				posX,
				OffsetY.Prev,
				width,
				47,
				0xFF2244EE,
				0xFF000000
			)

			local stringPosX = posX + width * .5

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
			["Sprite.Flags"] = 0xFFD132,
			["Sprite.OffsetY"] = 0xFFD530,
		},function(addressTbl)
			if ReadU16BE(addressTbl["Sprite.Flags"]) < 6 then return end

			-- The game only applies the new position on the frame following
			-- the value change, this mimics the result of that behaviour
			OffsetY.Prev = OffsetY.Cur
			OffsetY.Cur = ReadU16BE(addressTbl["Sprite.OffsetY"]) - 152
		end)
	end,
}
