-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local Elements = Overlay.GUI.Elements
local BossHealth = Elements.BossHealth
local DebrisPickup = Elements.DebrisPickup

-- Cache commonly-used functions and constants
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
			["BabyFace.Routine"] = 0xFFD132,
			["BabyFace.State"] = 0xFFDB64,
			["BabyFace.EarlyEnd"] = 0xFFD030,
		},function(addressTbl)
			local routine = ReadU16BE(addressTbl["BabyFace.Routine"])

			local doShow =
				ReadU16BE(addressTbl["BabyFace.EarlyEnd"]) ~= 0
			and	routine >= 0xC
			and	routine < 0x1C

			if doShow then
				local newStr = "Baby Face"

				if ReadU16BE(addressTbl["BabyFace.State"]) >= 0x1C then
					newStr = newStr .. "...?"
				end

				BabyFace.BossData.PrintName.Int = newStr
			end

			BabyFace:Show(doShow)

			DebrisPickup.Enable(routine >= 0x1C)
		end)
	end,
}
