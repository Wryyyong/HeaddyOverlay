-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x30] = {
	["LevelName"] = {
		["Main"] = [[Scene 9-3]],
		["Sub"] = {
			["Int"] = [["FINALE ANALYSIS"]],
			["Jpn"] = [["FINAL ATTACK"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene93.BossMonitorA",
		"Scene93.BossMonitorB",
	},

	["LevelScript"] = function()
		local DarkDemon = BossHealth({
			["ID"] = "DarkDemon",
			["PrintName"] = {
				["Int"] = "Dark Demon",
				["Jpn"] = "King Dark Demon",
			},
			["Address"] = 0xFFD231,
			["HealthInit"] = {
				["Int"] = 0x50,
				["Jpn"] = 0x48,
			},
			["HealthDeath"] = 0x3F,
		})

		local function BossMonitor()
			DarkDemon:Show(
				ReadU16BE(0xFFD106) ~= 0x10
			and	ReadU16BE(0xFFD10A) >= 0x4
			)
		end

		for address,append in pairs({
			[0xFFD106] = "A",
			[0xFFD10A] = "B",
		}) do
			MemoryMonitor.Register("Scene93.BossMonitor" .. append,address,BossMonitor,true)
		end
	end,
}
