-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x52] = {
	["LevelName"] = {
		["Main"] = [[Scene 6-2]],
		["Sub"] = {
			["Int"] = [["FLY HARD"]],
			["Jpn"] = [["RECKLESS WHEEL"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene62.BossMonitor",
	},

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local WheelerDealer = BossHealth({
			["ID"] = "WheelerDealer",
			["PrintName"] = {
				["Int"] = "Wheeler-Dealer",
				["Jpn"] = "Chris Wheel",
			},
			["Address"] = 0xFFD245,
			["HealthInit"] = {
				["Int"] = 0xC0,
			},
			["HealthDeath"] = 0x7F,
		})

		MemoryMonitor.Register("Scene62.BossMonitor",0xFFD142,function(address)
			local newVal = ReadU16BE(address)

			KeepOn =
				(
					KeepOn
				or	newVal >= 6
			)
			and	newVal < 0x10

			WheelerDealer:Show(KeepOn)
		end,true)
	end,
}
