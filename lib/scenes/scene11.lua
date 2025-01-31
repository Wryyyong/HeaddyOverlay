-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0] = {
	["SceneNumbers"] = {
		["Major"] = "1",
		["Minor"] = "1",
	},
	["Name"] = {
		["Int"] = [["THE GETAWAY"]],
		["Jpn"] = [["ESCAPE HERO!"]],
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
			["Stage.Routine"] = 0xFFE850,

			["Common.Sprite"] = 0xFFD140,
			["Common.Routine"] = 0xFFD142,

			["RoboBag.Sprite"] = 0xFFD144,
			["RoboBag.Routine"] = 0xFFD146,
		},function(addressTbl)
			local stageRoutine = ReadU16BE(addressTbl["Stage.Routine"])

			local commonSprite = ReadU16BE(addressTbl["Common.Sprite"])
			local commonRoutine = ReadU16BE(addressTbl["Common.Routine"])

			RoboCollector:Show(
				stageRoutine == 2
			and	commonSprite == 0x2C
			and	ReadU16BE(addressTbl["RoboBag.Sprite"]) == 0x48
			and	(
					commonRoutine == 6
				or	commonRoutine == 0xC
			)
			and	ReadU16BE(addressTbl["RoboBag.Routine"]) < 2
			)

			TroubleBruin:Show(
				stageRoutine >= 0x12
			and	commonSprite == 0x80
			and	commonRoutine >= 0xA
			and	commonRoutine < 0x2E
			)
		end)
	end,
}
