-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x24] = {
	["LevelName"] = {
		["Main"] = [[Scene 8-2]],
		["Sub"] = {
			["Int"] = [["ILLEGAL WEAPON 3"]],
			["Jpn"] = [["MISSILE BASE"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene82.BossMonitor",
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
			["HealthDeath"] = 0x7F,
		})

		MemoryMonitor.Register("Scene82.BossMonitor",0xFFD14A,function(address)
			MissileMan:Show(ReadU16BE(address) == 2)
		end,true)
	end,
}
