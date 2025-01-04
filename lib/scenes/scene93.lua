-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x30] = {
	["LevelName"] = [[Scene 9-3 — "Finale Analysis"]],
	["LevelMonitorIDList"] = {
		"Scene93.BossMonitorA",
		"Scene93.BossMonitorB",
	},

	["LevelScript"] = function()
		local DarkDemon = BossHealth.Create("DarkDemon",{
			["PrintName"] = "Dark Demon",
			["Address"] = 0xFFD231,
			["HealthInit"] = 0x50,
			["HealthDeath"] = 0x3F,
		},true)

		local function BossMonitor()
			if
				ReadU16BE(0xFFD106) == 0x10
			or	ReadU16BE(0xFFD10A) < 0x4
			then
				DarkDemon:Hide()
			else
				DarkDemon:Show()
			end
		end

		for address,append in pairs({
			[0xFFD106] = "A",
			[0xFFD10A] = "B",
		}) do
			MemoryMonitor.Register("Scene93.BossMonitor" .. append,address,BossMonitor,true)
		end
	end,
}
