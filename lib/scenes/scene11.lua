-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0] = {
	["LevelName"] = {
		["Main"] = [[Scene 1-1]],
		["Sub"] = {
			["Int"] = [["THE GETAWAY"]],
			["Jpn"] = [["ESCAPE HERO!"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene11.StageMonitor.RoboCollector.Ent",
		"Scene11.StageMonitor.RoboCollector.Flags",
		"Scene11.StageMonitor.RoboBag.Ent",
		"Scene11.StageMonitor.RoboBag.Flags",
	},

	["LevelScript"] = function()
		local RoboCollector = BossHealth.Create("RoboCollector",{
			["PrintName"] = {
				["Int"] = "Robo-Collector",
				["Jpn"] = "Toruzo-kun",
			},
			["Address"] = 0xFFD241,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x60,
		},true)
		local TroubleBruin = BossHealth.Create("TroubleBruin",{
			["PrintName"] = {
				["Int"] = "Trouble Bruin",
				["Jpn"] = "Maruyama",
			},
			["Address"] = 0xFFEEF2,
			["HealthInit"] = {
				["Int"] = 2,
			},
			["HealthDeath"] = 0,
			["Use16Bit"] = true,
		},true)

		local function StageMonitor()
			local commonEnt = ReadU16BE(0xFFD140)
			local commonFlags = ReadU16BE(0xFFD142)

			-- Robo-Collector
			if
				commonEnt == 0x2C
			and	ReadU16BE(0xFFD144) == 0x48
			and	commonFlags >= 6
			and	(
					commonFlags < 0xC
				or	ReadU16BE(0xFFD146) < 2
			)
			then
				RoboCollector:Show()
			else
				RoboCollector:Hide()
			end

			-- Trouble Bruin
			if
				commonEnt == 0x80
			and	commonFlags >= 0xA
			and	commonFlags < 0x2E
			then
				TroubleBruin:Show()
			else
				TroubleBruin:Hide()
			end
		end

		for address,append in pairs({
			[0xFFD140] = "RoboCollector.Ent",
			[0xFFD142] = "RoboCollector.Flags",
			[0xFFD144] = "RoboBag.Ent",
			[0xFFD146] = "RoboBag.Flags",
		}) do
			MemoryMonitor.Register("Scene11.StageMonitor." .. append,address,StageMonitor,true)
		end
	end,
}
