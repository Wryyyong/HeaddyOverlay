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
		local MissileMan = BossHealth.Create("MissileMan",{
			["PrintName"] = {
				["Int"] = "Missile Man",
				["Jpn"] = "Base Captain",
			},
			["Address"] = 0xFFD245,
			["HealthInit"] = {
				["Int"] = 0x90,
			},
			["HealthDeath"] = 0x7F,
		},true)

		MemoryMonitor.Register("Scene82.BossMonitor",0xFFD14A,function(address)
			local newVal = ReadU16BE(address)

			if
				newVal < 2
			or	newVal >= 4
			then
				MissileMan:Hide()
			else
				MissileMan:Show()
			end
		end,true)
	end,
}
