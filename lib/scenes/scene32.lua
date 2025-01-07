-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x12] = {
	["LevelName"] = {
		["Main"] = [[Scene 3-2]],
		["Sub"] = {
			["Int"] = [["BACKSTAGE BATTLE"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene32.BossMonitor",
	},

	["LevelScript"] = function()
		local RocketGrappler = BossHealth({
			["ID"] = "RocketGrappler",
			["PrintName"] = {
				["Int"] = "Rocket Grappler",
				["Jpn"] = "Tail Hanger",
			},
			["Address"] = 0xFFD285,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x70,
		})

		MemoryMonitor.Register("Scene32.BossMonitor",0xFFD186,function(address)
			local newVal = ReadU16BE(address)

			RocketGrappler:Show(
				newVal >= 0x14
			and	newVal < 0x20
			)
		end,true)
	end,
}
