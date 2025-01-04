-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x20] = {
	["LevelName"] = [[Scene 7-1 — "Headdy Wonderland"]],
	["LevelMonitorIDList"] = {
		"Scene71.BossMonitorA",
		"Scene71.BossMonitorB",
	},

	["LevelScript"] = function()
		local Gatekeeper = BossHealth.Create()

		local DataGatekeeper = {
			["PrintName"]   = "Gatekeeper",
			["Address"]     = 0xFFCC14,
			["HealthInit"]  = 0x5,
			["HealthDeath"] = 0,
			["Use16Bit"]    = true,
		}
		local DataNastyGatekeeper = {
			["PrintName"]   = "Nasty Gatekeeper",
			["Address"]     = 0xFFD269,
			["HealthInit"]  = 0x50,
			["HealthDeath"] = 0x3F,
		}

		local function BossMonitor()
			local checkD132 = ReadU16BE(0xFFD132)
			local checkD152 = ReadU16BE(0xFFD152)
			local bossName,bossData,checkLowerVal,checkLowerThres,checkUpperThres

			if checkD132 >= 0x1A then
				bossName = "NastyGatekeeper"
				bossData = DataNastyGatekeeper
				checkLowerVal = checkD152
				checkLowerThres = 0x16
				checkUpperThres = 0x80
			else
				bossName = "Gatekeeper"
				bossData = DataGatekeeper
				checkLowerVal = checkD132
				checkLowerThres = 0x12
				checkUpperThres = 0x40
			end

			Gatekeeper:UpdateBoss(bossName,bossData)

			if
				checkLowerVal < checkLowerThres
			or	checkD152 >= checkUpperThres
			then
				Gatekeeper:Hide()
			else
				Gatekeeper:Show()
			end
		end

		for address,append in pairs({
			[0xFFD132] = "A",
			[0xFFD152] = "B",
		}) do
			MemoryMonitor.Register("Scene93.BossMonitor" .. append,address,BossMonitor,true)
		end
	end,
}
