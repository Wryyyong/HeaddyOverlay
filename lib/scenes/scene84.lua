-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x28] = {
	["LevelName"] = {
		["Main"] = [[Scene 8-4]],
		["Sub"] = {
			["Int"] = [["VICE VERSA"]],
			["Jpn"] = [["REVERSE WORLD"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene84.StageMonitor.Ball.Ent",
		"Scene84.StageMonitor.Ball.Flags",
	},

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local Sparky = BossHealth({
			["ID"] = "Sparky",
			["PrintName"] = {
				["Int"] = "Sparky",
				["Jpn"] = "Thunder Captain",
			},
			["Address"] = 0xFFD251,
			["HealthInit"] = {
				["Int"] = 0x88,
			},
			["HealthDeath"] = 0x7F,
		})

		local function StageMonitor()
			local newVal = ReadU16BE(address)

			KeepOn =
				ReadU16BE(0xFFD144) == 0x498
			and	(
					KeepOn
				or	newVal >= 4
			)

			Sparky:Show(KeepOn)
		end

		for address,append in pairs({
			[0xFFD144] = "Ball.Ent",
			[0xFFD146] = "Ball.Flags",
		}) do
			MemoryMonitor.Register("Scene84.StageMonitor." .. append,address,StageMonitor,true)
		end
	end,
}
