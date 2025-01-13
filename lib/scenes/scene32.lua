-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x12] = {
	["LevelName"] = {
		["Main"] = [[Scene 3-2]],
		["Sub"] = {
			["Int"] = [["BACKSTAGE BATTLE"]],
		},
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
			["HealthDeath"] = {
				["Int"] = 0x70,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD186,function(addressTbl)
			local newVal = ReadU16BE(addressTbl[1])

			RocketGrappler:Show(
				newVal >= 0x14
			and	newVal < 0x20
			)
		end)
	end,
}
