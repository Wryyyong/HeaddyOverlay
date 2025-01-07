-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x2A] = {
	["LevelName"] = {
		["Main"] = [[Scene 8-5]],
		["Sub"] = {
			["Int"] = [["TWIN FREAKS"]],
			["Jpn"] = [["FUNNY ANGRY"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene85.BossMonitor",
	},

	["LevelScript"] = function()
		local TwinFreaks = BossHealth({
			["ID"] = "TwinFreaks",
			["PrintName"] = {
				["Int"] = "Twin Freaks",
				["Jpn"] = "Rever Face",
			},
			["Address"] = 0xFFD241,
			["HealthInit"] = {
				["Int"] = 0x50,
				["Jpn"] = 0x60,
			},
			["HealthDeath"] = 0x3F,
		})

		MemoryMonitor.Register("Scene85.BossMonitor",0xFFD142,function(address)
			local newVal = ReadU16BE(address)

			TwinFreaks:Show(
				newVal >= 6
			and	newVal < 0x10
			)
		end,true)
	end,
}
