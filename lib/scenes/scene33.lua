-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x32] = {
	["LevelName"] = {
		["Main"] = [[Scene 3-3]],
		["Sub"] = {
			["Int"] = [["THE GREEN ROOM"]],
			["Jpn"] = [["GUEST AREA"]],
		},
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
			["HealthDeath"] = {
				["Int"] = 0,
			},
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
			["HealthDeath"] = {
				["Int"] = 0,
			},
		})

		LevelMonitor.SetSceneMonitor({
			["Puppeteer.Flags"] = 0xFFD142,
			["GentlemanJim.Flags"] = 0xFFD15E,
		},function(addressTbl)
			local flagsPuppeteer = ReadU16BE(addressTbl["Puppeteer.Flags"])
			local flagsStage = ReadU16BE(addressTbl["GentlemanJim.Flags"])

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
		end)
	end,
}
