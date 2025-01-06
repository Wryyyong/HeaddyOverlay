-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[6] = {
	["LevelName"] = {
		["Main"] = [[Scene 2-3]],
		["Sub"] = {
			["Int"] = [["MAD DOG AND HEADDY"]],
			["Jpn"] = [["CONCERT PANIC"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene23.BossMonitor",
	},

	["LevelScript"] = function()
		local MadDog = BossHealth.Create("MadDog",{
			["PrintName"] = {
				["Int"] = "Mad Dog",
				["Jpn"] = "Bounty Boundy",
			},
			["Address"] = 0xFFD285,
			["HealthInit"] = {
				["Int"] = 0x50,
			},
			["HealthDeath"] = 0x3F,
		},true)

		MemoryMonitor.Register("Scene23.BossMonitor",0xFFD142,function(address)
			local newVal = ReadU16BE(address)

			if
				newVal < 0x16
			or	newVal >= 0x5E
			then
				MadDog:Hide()
			else
				MadDog:Show()
			end
		end,true)
	end,
}
