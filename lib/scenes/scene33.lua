-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x32] = {
	["LevelName"] = {
		["Main"] = [[Scene 3-3]],
		["Sub"] = {
			["Int"] = [["THE GREEN ROOM"]],
			["Jpn"] = [["GUEST AREA"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene33.BossMonitorA",
		"Scene33.BossMonitorB",
	},

	["LevelScript"] = function()
		local Puppeteer = BossHealth({
			["ID"] = "Puppeteer",
			["PrintName"] = {
				["Int"] = "Puppeteer",
				["Jpn"] = "Marrio",
			},
			["Address"] = 0xFFD241,
			["HealthInit"] = {
				["Int"] = 0x10,
			},
			["HealthDeath"] = 0,
		})
		local GentlemanJim = BossHealth({
			["ID"] = "GentlemanJim",
			["PrintName"] = {
				["Int"] = "Gentleman Jim",
				["Jpn"] = "Nettoh",
			},
			["Address"] = 0xFFD245,
			["HealthInit"] = {
				["Int"] = 0x10,
			},
			["HealthDeath"] = 0,
		})

		-- [TODO: FIND BETTER WAYS TO LOGIC THIS JESUS CHRIST]
		local function BossMonitor()
			local flagsPuppeteer = ReadU16BE(0xFFD142)
			local flagsStage = ReadU16BE(0xFFD15E)

			if (flagsPuppeteer << 8) + flagsStage == 0xC06 then
				Puppeteer:Show(true)
				GentlemanJim:Show(true)

				return
			end

			if flagsStage >= 8 then
				Puppeteer:Show(false)
			end

			if
				flagsPuppeteer >= 0xE
			or	flagsStage >= 0xC
			then
				GentlemanJim:Show(false)
			end
		end

		for address,append in pairs({
			[0xFFD142] = "A",
			[0xFFD15E] = "B",
		}) do
			MemoryMonitor.Register("Scene33.BossMonitor" .. append,address,BossMonitor,true)
		end
	end,
}
