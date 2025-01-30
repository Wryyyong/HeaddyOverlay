-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Cache commonly-used functions and constants
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
			["Stage.Routine"] = 0xFFE850,
			["Puppeteer.Routine"] = 0xFFD142,
			["GentlemanJim.Routine"] = 0xFFD15E,
		},function(addressTbl)
			local puppeteerRoutine = ReadU16BE(addressTbl["Puppeteer.Routine"])
			local jimRoutine = ReadU16BE(addressTbl["GentlemanJim.Routine"])

			if ReadU16BE(addressTbl["Stage.Routine"]) < 0xC then
				Puppeteer:Show(false)
				GentlemanJim:Show(false)
			elseif (puppeteerRoutine << 8) + jimRoutine == 0xC06 then
				Puppeteer:Show(true)
				GentlemanJim:Show(true)
			else
				if jimRoutine >= 8 then
					Puppeteer:Show(false)
				end

				if
					puppeteerRoutine >= 0xE
				or	jimRoutine >= 0xC
				then
					GentlemanJim:Show(false)
				end
			end
		end)
	end,
}
