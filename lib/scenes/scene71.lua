-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local Elements = Overlay.GUI.Elements
local BossHealth = Elements.BossHealth
local DebrisPickup = Elements.DebrisPickup

-- Cache commonly-used functions and constants
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
			["Unknown.Routine"] = 0xFFD132,
			["Gatekeeper.Routine"] = 0xFFD152,
		},function(addressTbl)
			local unkRoutine = ReadU16BE(addressTbl["Unknown.Routine"])
			local gatekeeperRoutine = ReadU16BE(addressTbl["Gatekeeper.Routine"])
			local bossData,checkLowerThres,checkUpperThres

			if unkRoutine >= 0x32 then
				bossData = DataNastyGatekeeper
				checkLowerThres = 0x24
				checkUpperThres = 0x80
			else
				bossData = DataGatekeeper
				checkLowerThres = 0x12
				checkUpperThres = 0x40
			end

			local isBossArena = ReadU16BE(addressTbl["Stage.Routine"]) == 4

			Gatekeeper:UpdateBoss(bossData)
			Gatekeeper:Show(
				isBossArena
			and	gatekeeperRoutine >= checkLowerThres
			and	gatekeeperRoutine < checkUpperThres
			)

			DebrisPickup.Enable(
				isBossArena
			and	bossData == DataNastyGatekeeper
			and	gatekeeperRoutine >= 0x80
			)
		end)
	end,
}
