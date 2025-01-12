-- Set up globals and local references
local Overlay = HeaddyOverlay
local BossHealth = Overlay.BossHealth
local LevelMonitor = Overlay.LevelMonitor

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x20] = {
	["LevelName"] = {
		["Main"] = [[Scene 7-1]],
		["Sub"] = {
			["Int"] = [["HEADDY WONDERLAND"]],
			["Jpn"] = [["PARADISE?"]],
		},
	},
	["ScoreTallyThres"] = 8,

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
			["HealthDeath"] = {
				["Int"] = 0,
			},
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
			["HealthDeath"] = {
				["Int"] = 0x3F,
			},
		}

		LevelMonitor.SetSceneMonitor({
			["Gatekeeper.Flags"] = 0xFFD132,
			["NastyGatekeeper.Flags"] = 0xFFD152,
		},function(addressTbl)
			local flagsNastyGatekeeper = ReadU16BE(addressTbl["Gatekeeper.Flags"])
			local flagsGatekeeper = ReadU16BE(addressTbl["NastyGatekeeper.Flags"])
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
		end)
	end,
}
