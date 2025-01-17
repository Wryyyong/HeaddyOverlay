-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0] = {
	["LevelName"] = {
		["Main"] = [[Scene 1-1]],
		["Sub"] = {
			["Int"] = [["THE GETAWAY"]],
			["Jpn"] = [["ESCAPE HERO!"]],
		},
	},
	["ScoreTallyThres"] = 0x18,

	["LevelScript"] = function()
		local RoboCollector = BossHealth({
			["ID"] = "RoboCollector",
			["PrintName"] = {
				["Int"] = "Robo-Collector",
				["Jpn"] = "Toruzo-kun",
			},
			["Address"] = 0xFFD241,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = {
				["Int"] = 0x60,
			},
		})
		local TroubleBruin = BossHealth({
			["ID"] = "TroubleBruin",
			["PrintName"] = {
				["Int"] = "Trouble Bruin",
				["Jpn"] = "Maruyama",
			},
			["Address"] = 0xFFEEF2,
			["HealthInit"] = {
				["Int"] = 2,
			},
			["HealthDeath"] = {
				["Int"] = 0,
			},
			["Use16Bit"] = true,
		})

		LevelMonitor.SetSceneMonitor({
			["Stage.Flags"] = 0xFFE850,

			["Common.Ent"] = 0xFFD140,
			["Common.Flags"] = 0xFFD142,

			["RoboBag.Ent"] = 0xFFD144,
			["RoboBag.Flags"] = 0xFFD146,
		},function(addressTbl)
			local flagsStage = ReadU16BE(addressTbl["Stage.Flags"])

			local entCommon = ReadU16BE(addressTbl["Common.Ent"])
			local flagsCommon = ReadU16BE(addressTbl["Common.Flags"])

			RoboCollector:Show(
				flagsStage == 2
			and	entCommon == 0x2C
			and	ReadU16BE(addressTbl["RoboBag.Ent"]) == 0x48
			and	(
					flagsCommon == 6
				or	flagsCommon == 0xC
			)
			and	ReadU16BE(addressTbl["RoboBag.Flags"]) < 2
			)

			TroubleBruin:Show(
				flagsStage == 0x12
			and	entCommon == 0x80
			and	flagsCommon >= 0xA
			and	flagsCommon < 0x2E
			)
		end)
	end,
}
