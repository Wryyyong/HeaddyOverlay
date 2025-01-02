-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

HeaddyOverlay.LevelMonitor.LevelData[0x30] = {
	["LevelName"] = [[Scene 9-3 ("Finale Analysis")]],
	["LevelMonitorIDList"] = {
		"Scene93.BossIntro",
		"Scene93.BossOutro",
	},

	["LevelScript"] = function()
		local DarkDemon = BossHealth.Create("DarkDemon",{
			["PrintName"] = "Dark Demon",
			["Address"] = 0xFFD231,
			["HealthInit"] = 0x50,
			["HealthDeath"] = 0x3F,
		},true)

		-- [TODO: Find a better address to monitor]
		MemoryMonitor.Register("Scene34.BossIntro",0xFFD10A,function(address)
			if ReadU16BE(address) ~= 0x4 then
				return false
			end

			DarkDemon:Show()

			MemoryMonitor.Register("Scene34.BossOutro",0xFFD106,function(address)
				if ReadU16BE(address) ~= 0x10 then
					return false
				end

				DarkDemon:Hide()
			end)
		end)
	end,
}
