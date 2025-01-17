-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x30] = {
	["LevelName"] = {
		["Main"] = [[Scene 9-3]],
		["Sub"] = {
			["Int"] = [["FINALE ANALYSIS"]],
			["Jpn"] = [["FINAL ATTACK"]],
		},
	},

	["LevelScript"] = function()
		local DarkDemon = BossHealth({
			["ID"] = "DarkDemon",
			["PrintName"] = {
				["Int"] = "Dark Demon",
				["Jpn"] = "King Dark Demon",
			},
			["Address"] = 0xFFD231,
			["HealthInit"] = {
				["Int"] = 0x50,
				["Jpn"] = 0x48,
			},
			["HealthDeath"] = {
				["Int"] = 0x3F,
			},
		})

		LevelMonitor.SetSceneMonitor({
			["Stage.Flags"] = 0xFFE850,
			["DarkDemon.Flags"] = 0xFFD106,
			["Smiley.Flags"] = 0xFFD10A,
		},function(addressTbl)
			DarkDemon:Show(
				ReadU16BE(addressTbl["Stage.Flags"]) == 4
			and	ReadU16BE(addressTbl["DarkDemon.Flags"]) ~= 0x10
			and	ReadU16BE(addressTbl["Smiley.Flags"]) >= 4
			)
		end)
	end,
}
