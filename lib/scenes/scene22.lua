-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[2] = {
	["LevelName"] = {
		["Main"] = [[Scene 2-2]],
		["Sub"] = {
			["Int"] = [["TOYS N THE HOOD"]],
			["Jpn"] = [["NORTH TOWN"]],
		},
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
			["Catherine.Ent"] = 0xFFD158,
			["Catherine.Flags"] = 0xFFD15A,

			["SnakeEyes.Ent"] = 0xFFD164,
			["SnakeEyes.Flags"] = 0xFFD166,

			["SnakeHelp.Ent"] = 0xFFD1A0,
			["SnakeHelp.Flags"] = 0xFFD1A2,
		},function(addressTbl)
			local flagsCatherine = ReadU16BE(addressTbl["Catherine.Flags"])

			-- Catherine
			Catherine:Show(
				ReadU16BE(addressTbl["Catherine.Ent"]) == 0x74
			and	flagsCatherine >= 4
			and	flagsCatherine < 0x10
			)

			-- Snake Eyes
			SnakeEyes:Show(
				ReadU16BE(addressTbl["SnakeEyes.Ent"]) == 0xA0
			and	ReadU16BE(addressTbl["SnakeHelp.Ent"]) == 0x180
			and	(
					ReadU16BE(addressTbl["SnakeEyes.Flags"]) >= 4
				or	ReadU16BE(addressTbl["SnakeHelp.Flags"]) < 6
			))
		end)
	end,
}
