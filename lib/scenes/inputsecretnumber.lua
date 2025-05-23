-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local GUI = Overlay.GUI
local LevelMonitor = Overlay.LevelMonitor

-- Cache commonly-used functions and constants
local ReadU8 = memory.read_u8
local ReadU16BE = memory.read_u16_be

local DrawString = gui.drawString

LevelMonitor.LevelData[0x4C] = {
	["Name"] = {
		["Int"] = [[Input Secret Number]],
	},
	["DisableMainHud"] = true,

	["LevelScript"] = function()
		local GuiData = {
			["String"] = "",
			["Size"] = 16,
			["Colors"] = {
				["Header"] = 0,
				["Current"] = 0,
				["Prev"] = 0,
			},
		}
		local GuiColors = GuiData.Colors

		Hook.Set("DrawCustomElements","SecretNumberDisplay",function(width,height)
			if GUI.IsMenuOrLoadingScreen then return end

			local posX = width * .5
			local posY = height * .835

			DrawString(
				posX,
				posY,
				"Your Secret Number is...",
				GuiData.Colors.Header,
				0,
				GuiData.Size - 6,
				"MS Gothic",
				nil,
				"center",
				"middle"
			)
			DrawString(
				posX,
				posY + GuiData.Size + 4,
				GuiData.String,
				GuiData.Colors.Current,
				0,
				GuiData.Size,
				"MS Gothic",
				nil,
				"center",
				"middle"
			)
		end)

		LevelMonitor.SetSceneMonitor({
			["SecretNumber1"] = 0xFFE9C4,
			["SecretNumber2"] = 0xFFE9C6,
			["SecretNumber3"] = 0xFFE9C8,
			["SecretNumber4"] = 0xFFE9CA,
			["Transparency"] = 0xFFB30C,
			["Routine"] = 0xFFD132,
		},function(addressTbl)
			local transparency = (ReadU8(addressTbl["Transparency"] + 1) << 24)

			-- String
			if
				transparency == 0
			or	transparency >= 0xEE
			then
				local newStr = ""

				for idx = 1,4 do
					local newVal = ReadU16BE(addressTbl["SecretNumber" .. idx])

					newStr = newStr .. (newVal >= 0xA and "-" or newVal)
				end

				GUI.InvalidateCheck(GuiData.String ~= newStr)

				GuiData.String = newStr
			end

			-- Color
			local routine = ReadU16BE(addressTbl["Routine"])
			local prevColor,newColor = GuiColors.Prev

			if routine >= 0xE then
				newColor = prevColor
			elseif routine >= 0xC then
				newColor = 0xFF00
			elseif routine >= 8 then
				newColor = 0xFF0000
			else
				newColor = 0xFFFFFF
			end

			GUI.InvalidateCheck(prevColor ~= newColor)

			GuiColors.Prev = newColor
			GuiColors.Current = transparency + newColor
			GuiColors.Header = transparency + 0xFFFFFF
		end)
	end,
}
