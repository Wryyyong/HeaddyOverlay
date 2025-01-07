-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x14] = {
	["LevelName"] = {
		["Main"] = [[Scene 3-4]],
		["Sub"] = {
			["Int"] = [["CLOTHES ENCOUNTERS"]],
			["Jpn"] = [["STARLIGHT STORM"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene34.BossMonitor",
	},

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local WoodenDresser = BossHealth({
			["ID"] = "WoodenDresser",
			["PrintName"] = {
				["Int"] = "Wooden Dresser",
				["Jpn"] = "Jacquline Dressy",
			},
			["Address"] = 0xFFD279,
			["HealthInit"] = {
				["Int"] = 0x48,
			},
			["HealthDeath"] = 0x3F,
		})

		MemoryMonitor.Register("Scene34.BossMonitor",0xFFD17A,function(address)
			local newVal = ReadU16BE(address)

			KeepOn =
				(
					KeepOn
				or	newVal >= 0xA
			)
			and	newVal < 0x28

			WoodenDresser:Show(KeepOn)
		end,true)
	end,
}
