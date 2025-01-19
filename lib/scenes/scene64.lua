-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local Elements = Overlay.GUI.Elements
local BossHealth = Elements.BossHealth
local DebrisPickup = Elements.DebrisPickup

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x56] = {
	["SceneNumbers"] = {
		["Major"] = "6",
		["Minor"] = "4",
	},
	["Name"] = {
		["Int"] = [["BABY FACE"]],
	},
	["ScoreTallyThres"] = 6,

	["LevelScript"] = function()
		local BabyFace = BossHealth({
			["ID"] = "BabyFace",
			["PrintName"] = {
				["Int"] = "Baby Face",
				["Jpn"] = "Mitsuru",
			},
			["Address"] = 0xFFD235,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = {
				["Int"] = 0x60,
			},
		})

		LevelMonitor.SetSceneMonitor({
			["BabyFace.Flags"] = 0xFFD132,
			["BabyFace.State"] = 0xFFDB64,
			["BabyFace.EarlyEnd"] = 0xFFD030,
		},function(addressTbl)
			local flags = ReadU16BE(addressTbl["BabyFace.Flags"])

			local doShow =
				ReadU16BE(addressTbl["BabyFace.EarlyEnd"]) ~= 0
			and	flags >= 0xC
			and	flags < 0x1C

			if doShow then
				local newStr = "Baby Face"

				if ReadU16BE(addressTbl["BabyFace.State"]) >= 0x1C then
					newStr = newStr .. "...?"
				end

				BabyFace.BossData.PrintName.Int = newStr
			end

			BabyFace:Show(doShow)

			DebrisPickup.Enable(flags >= 0x1C)
		end)
	end,
}
