-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x28] = {
	["LevelName"] = {
		["Main"] = [[Scene 8-4]],
		["Sub"] = {
			["Int"] = [["VICE VERSA"]],
			["Jpn"] = [["REVERSE WORLD"]],
		},
	},

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local Sparky = BossHealth({
			["ID"] = "Sparky",
			["PrintName"] = {
				["Int"] = "Sparky",
				["Jpn"] = "Thunder Captain",
			},
			["Address"] = 0xFFD251,
			["HealthInit"] = {
				["Int"] = 0x88,
			},
			["HealthDeath"] = {
				["Int"] = 0x7F,
			},
		})

		LevelMonitor.SetSceneMonitor({
			["Ball.Ent"] = 0xFFD144,
			["Ball.Flags"] = 0xFFD146,
		},function(addressTbl)
			local flags = ReadU16BE(addressTbl["Ball.Flags"])

			KeepOn =
				ReadU16BE(addressTbl["Ball.Ent"]) == 0x498
			and	flags >= 2
			and	(
					KeepOn
				or	flags >= 4
			)

			Sparky:Show(KeepOn)
		end)
	end,
}
