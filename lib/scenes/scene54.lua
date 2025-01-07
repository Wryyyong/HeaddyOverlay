-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU8 = memory.read_u8
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x1E] = {
	["LevelName"] = {
		["Main"] = [[Scene 5-4]],
		["Sub"] = {
			["Int"] = [["SPINDERELLA"]],
			["Jpn"] = [["ON THE SKY"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene54.BossMonitor",
	},

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local Spinderella = BossHealth({
			["ID"] = "Spinderella",
			["PrintName"] = {
				["Int"] = "Spinderella",
				["Jpn"] = "Motor Hand",
			},
			["Address"] = 0xFFD249,
			["HealthInit"] = {
				["Int"] = 0x50,
			},
			["HealthDeath"] = 0x3F,
		})

		MemoryMonitor.Register("Scene54.BossMonitor",0xFFD142,function(address)
			local newVal = ReadU16BE(address)

			KeepOn =
				(
					KeepOn
				or	newVal >= 0xC
			)
			and	newVal < 0x1E

			Spinderella:Show(KeepOn)
		end,true)
	end,
}
