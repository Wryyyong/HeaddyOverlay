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

		local Sparky = BossHealth.Create("Sparky",{
			["PrintName"] = {
				["Int"] = "Sparky",
				["Jpn"] = "Thunder Captain",
			},
			["Address"] = 0xFFD251,
			["HealthInit"] = {
				["Int"] = 0x88,
			},
			["HealthDeath"] = 0x7F,
		},true)

		local function StageMonitor()
			if
				ReadU16BE(0xFFD144) ~= 0x498
			or	(
					not KeepOn
				and	ReadU16BE(0xFFD146) < 4
			)
			then
				Sparky:Hide()

				KeepOn = false
			else
				Sparky:Show()

				KeepOn = true
			end
		end

		for address,append in pairs({
			[0xFFD144] = "Ball.Ent",
			[0xFFD146] = "Ball.Flags",
		}) do
			MemoryMonitor.Register("Scene84.StageMonitor." .. append,address,StageMonitor,true)
		end
	end,
}
