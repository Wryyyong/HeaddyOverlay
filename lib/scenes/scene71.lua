-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x20] = {
	["LevelName"] = {
		["Main"] = [[Scene 7-1]],
		["Sub"] = {
			["Int"] = [["HEADDY WONDERLAND"]],
			["Jpn"] = [["PARADISE?"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene71.BossMonitorA",
		"Scene71.BossMonitorB",
	},

	["LevelScript"] = function()
		local Gatekeeper = BossHealth()

		local DataGatekeeper = {
			["ID"] = "Gatekeeper",
			["PrintName"] = {
				["Int"] = "Gatekeeper",
				["Jpn"] = "Yayoi",
			},
			["Address"] = 0xFFCC14,
			["HealthInit"] = {
				["Int"] = 5,
			},
			["HealthDeath"] = 0,
			["Use16Bit"] = true,
		}
		local DataNastyGatekeeper = {
			["ID"] = "NastyGatekeeper",
			["PrintName"] = {
				["Int"] = "Nasty Gatekeeper",
				["Jpn"] = "Izayoi",
			},
			["Address"] = 0xFFD269,
			["HealthInit"] = {
				["Int"] = 0x50,
				["Jpn"] = 0x48,
			},
			["HealthDeath"] = 0x3F,
		}

		local function BossMonitor()
			local flagsNastyGatekeeper = ReadU16BE(0xFFD132)
			local flagsGatekeeper = ReadU16BE(0xFFD152)
			local bossData,checkLowerVal,checkLowerThres,checkUpperThres

			if flagsNastyGatekeeper >= 0x1A then
				bossData = DataNastyGatekeeper
				checkLowerVal = flagsGatekeeper
				checkLowerThres = 0x16
				checkUpperThres = 0x80
			else
				bossData = DataGatekeeper
				checkLowerVal = flagsNastyGatekeeper
				checkLowerThres = 0x12
				checkUpperThres = 0x40
			end

			Gatekeeper:UpdateBoss(bossData)
			Gatekeeper:Show(
				checkLowerVal >= checkLowerThres
			and	flagsGatekeeper < checkUpperThres
			)
		end

		for address,append in pairs({
			[0xFFD132] = "A",
			[0xFFD152] = "B",
		}) do
			MemoryMonitor.Register("Scene93.BossMonitor" .. append,address,BossMonitor,true)
		end
	end,
}
