-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[6] = {
	["LevelName"] = {
		["Main"] = [[Scene 2-3]],
		["Sub"] = {
			["Int"] = [["MAD DOG AND HEADDY"]],
			["Jpn"] = [["CONCERT PANIC"]],
		},
	},

	["LevelScript"] = function()
		local MadDog = BossHealth({
			["ID"] = "MadDog",
			["PrintName"] = {
				["Int"] = "Mad Dog",
				["Jpn"] = "Bounty Boundy",
			},
			["Address"] = 0xFFD285,
			["HealthInit"] = {
				["Int"] = 0x50,
			},
			["HealthDeath"] = {
				["Int"] = 0x3F,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD142,function(addressTbl)
			local newVal = ReadU16BE(addressTbl[1])

			MadDog:Show(
				newVal >= 0x16
			and	newVal < 0x5E
			)
		end)
	end,
}
