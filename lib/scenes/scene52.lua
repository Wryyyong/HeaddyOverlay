-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x1A] = {
	["LevelName"] = {
		["Main"] = [[Scene 5-2]],
		["Sub"] = {
			["Int"] = [["STAIR WARS"]],
			["Jpn"] = [["GO UP!"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene52.BossMonitor",
	},

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local FlyingScythe = BossHealth({
			["ID"] = "FlyingScythe",
			["PrintName"] = {
				["Int"] = "Flying Scythe",
				["Jpn"] = "Tower Crasher",
			},
			["Address"] = 0xFFD261,
			["HealthInit"] = {
				["Int"] = 0x40,
				["Jpn"] = 0x3C,
			},
			["HealthDeath"] = 0x38,
		})

		MemoryMonitor.Register("Scene52.BossMonitor",0xFFD162,function(address)
			local newVal = ReadU16BE(address)

			KeepOn =
				(
					KeepOn
				or	newVal >= 0x8
			)
			and	newVal < 0x1A

			FlyingScythe:Show(KeepOn)
		end,true)
	end,
}
