-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Util = Overlay.Util
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[2] = {
	["SceneNumbers"] = {
		["Major"] = "2",
		["Minor"] = "2",
	},
	["Name"] = {
		["Int"] = [["TOYS N THE HOOD"]],
		["Jpn"] = [["NORTH TOWN"]],
	},

	["LevelScript"] = function()
		local Catherine = BossHealth({
			["ID"] = "Catherine",
			["PrintName"] = {
				["Int"] = "Catherine Derigueur",
				["Jpn"] = "Catherine Degoon",
			},
			["Address"] = 0xFFD259,
			["HealthInit"] = {
				["Int"] = 0x48,
			},
			["HealthDeath"] = {
				["Int"] = 0x3F,
			},
		})
		local SnakeEyes = BossHealth({
			["ID"] = "SnakeEyes",
			["PrintName"] = {
				["Int"] = "Snake Eyes",
				["Jpn"] = "Happy Comecome",
			},
			["Address"] = 0xFFD265,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = {
				["Int"] = 0x78,
			},
		})

		LevelMonitor.SetSceneMonitor({
			["Stage.Routine"] = 0xFFE850,

			["Catherine.Sprite"] = 0xFFD158,
			["Catherine.Routine"] = 0xFFD15A,

			["SnakeEyes.Sprite"] = 0xFFD164,
			["SnakeEyes.Routine"] = 0xFFD166,

			["SnakeHelp.Sprite"] = 0xFFD1A0,
			["SnakeHelp.Routine"] = 0xFFD1A2,
		},function(addressTbl)
			local stageRoutine = ReadU16BE(addressTbl["Stage.Routine"])

			Catherine:Show(
				stageRoutine == 4
			and	ReadU16BE(addressTbl["Catherine.Sprite"]) == 0x74
			and	Util.IsInRange(ReadU16BE(addressTbl["Catherine.Routine"]),4,0xE)
			)

			SnakeEyes:Show(
				stageRoutine >= 0xA
			and	ReadU16BE(addressTbl["SnakeEyes.Sprite"]) == 0xA0
			and	ReadU16BE(addressTbl["SnakeHelp.Sprite"]) == 0x180
			and	(
					ReadU16BE(addressTbl["SnakeEyes.Routine"]) >= 4
				or	ReadU16BE(addressTbl["SnakeHelp.Routine"]) < 6
			))
		end)
	end,
}
