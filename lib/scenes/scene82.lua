-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x24] = {
	["LevelName"] = {
		["Main"] = [[Scene 8-2]],
		["Sub"] = {
			["Int"] = [["ILLEGAL WEAPON 3"]],
			["Jpn"] = [["MISSILE BASE"]],
		},
	},

	["LevelScript"] = function()
		local MissileMan = BossHealth({
			["ID"] = "MissileMan",
			["PrintName"] = {
				["Int"] = "Missile Man",
				["Jpn"] = "Base Captain",
			},
			["Address"] = 0xFFD245,
			["HealthInit"] = {
				["Int"] = 0x90,
			},
			["HealthDeath"] = {
				["Int"] = 0x7F,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD14A,function(addressTbl)
			MissileMan:Show(ReadU16BE(addressTbl[1]) == 2)
		end)
	end,
}
