-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x32] = {
	["SceneNumbers"] = {
		["Major"] = "3",
		["Minor"] = "3",
	},
	["Name"] = {
		["Int"] = [["THE GREEN ROOM"]],
		["Jpn"] = [["GUEST AREA"]],
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
			["Stage.Flags"] = 0xFFE850,
			["Puppeteer.Flags"] = 0xFFD142,
			["GentlemanJim.Flags"] = 0xFFD15E,
		},function(addressTbl)
			local flagsPuppeteer = ReadU16BE(addressTbl["Puppeteer.Flags"])
			local flagsJim = ReadU16BE(addressTbl["GentlemanJim.Flags"])

			if ReadU16BE(addressTbl["Stage.Flags"]) < 0xC then
				Puppeteer:Show(false)
				GentlemanJim:Show(false)
			elseif (flagsPuppeteer << 8) + flagsJim == 0xC06 then
				Puppeteer:Show(true)
				GentlemanJim:Show(true)
			else
				if flagsJim >= 8 then
					Puppeteer:Show(false)
				end

				if
					flagsPuppeteer >= 0xE
				or	flagsJim >= 0xC
				then
					GentlemanJim:Show(false)
				end
			end
		end)
	end,
}
