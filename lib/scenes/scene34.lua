-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x14] = {
	["LevelName"] = [[Scene 3-4 ("Clothes Encounter")]],
	["LevelMonitorIDList"] = {
		"Scene34.BossMonitor",
	},

	["LevelScript"] = function()
		local KeepOn

		local WoodenDresser = BossHealth.Create("WoodenDresser",{
			["PrintName"] = "Wooden Dresser",
			["Address"] = 0xFFD279,
			["HealthInit"] = 0x48,
			["HealthDeath"] = 0x3F,
		},true)

		MemoryMonitor.Register("Scene34.BossMonitor",0xFFD17A,function(address)
			local newVal = ReadU16BE(address)

			if
				(
					not KeepOn
				and	newVal < 0x0A
			)
			or	newVal >= 0x28
			then
				WoodenDresser:Hide()
			else
				WoodenDresser:Show()

				-- Disable hiding when going under threshold after first success
				KeepOn = true
			end
		end,true)
	end,
}
