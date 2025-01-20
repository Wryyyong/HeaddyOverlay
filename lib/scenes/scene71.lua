-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local Elements = Overlay.GUI.Elements
local BossHealth = Elements.BossHealth
local DebrisPickup = Elements.DebrisPickup

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x20] = {
	["SceneNumbers"] = {
		["Major"] = "7",
		["Minor"] = "1",
	},
	["Name"] = {
		["Int"] = [["HEADDY WONDERLAND"]],
		["Jpn"] = [["PARADISE?"]],
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
			["Stage.Routine"] = 0xFFE850,
			["NastyGatekeeper.Routine"] = 0xFFD132,
			["Gatekeeper.Routine"] = 0xFFD152,
		},function(addressTbl)
			local nastyRoutine = ReadU16BE(addressTbl["NastyGatekeeper.Routine"])
			local gatekeeperRoutine = ReadU16BE(addressTbl["Gatekeeper.Routine"])
			local bossData,checkLowerVal,checkLowerThres,checkUpperThres

			if nastyRoutine >= 0x1A then
				bossData = DataNastyGatekeeper
				checkLowerVal = gatekeeperRoutine
				checkLowerThres = 0x16
				checkUpperThres = 0x80
			else
				bossData = DataGatekeeper
				checkLowerVal = nastyRoutine
				checkLowerThres = 0x12
				checkUpperThres = 0x40
			end

			Gatekeeper:UpdateBoss(bossData)
			Gatekeeper:Show(
				ReadU16BE(addressTbl["Stage.Routine"]) == 4
			and	checkLowerVal >= checkLowerThres
			and	gatekeeperRoutine < checkUpperThres
			)

			DebrisPickup.Enable(
				bossData == DataNastyGatekeeper
			and	gatekeeperRoutine >= 0x80
			)
		end)
	end,
}
