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

		local FlyingScythe = BossHealth.Create("FlyingScythe",{
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
		},true)

		MemoryMonitor.Register("Scene52.BossMonitor",0xFFD162,function(address)
			local newVal = ReadU16BE(address)

			if
				(
					not KeepOn
				and	newVal < 0x8
			)
			or	newVal >= 0x1A
			then
				FlyingScythe:Hide()

				KeepOn = false
			else
				FlyingScythe:Show()

				KeepOn = true
			end
		end,true)
	end,
}
