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
		local Puppeteer = BossHealth.Create("Puppeteer",{
			["PrintName"] = {
				["Int"] = "Puppeteer",
				["Jpn"] = "Marrio",
			},
			["Address"] = 0xFFD241,
			["HealthInit"] = {
				["Int"] = 0x10,
			},
			["HealthDeath"] = 0,
		},true)
		local GentlemanJim = BossHealth.Create("GentlemanJim",{
			["PrintName"] = {
				["Int"] = "Gentleman Jim",
				["Jpn"] = "Nettoh",
			},
			["Address"] = 0xFFD245,
			["HealthInit"] = {
				["Int"] = 0x10,
			},
			["HealthDeath"] = 0,
		},true)

		-- [[TODO: FIND BETTER WAYS TO LOGIC THIS JESUS CHRIST]]
		local function BossMonitor()
			local checkD142 = ReadU16BE(0xFFD142)
			local checkD15E = ReadU16BE(0xFFD15E)

			if (checkD142 << 8) + checkD15E == 0xC06 then
				Puppeteer:Show()
				GentlemanJim:Show()

				return
			end

			if checkD15E >= 8 then
				Puppeteer:Hide()
			end

			if
				checkD142 >= 0xE
			or	checkD15E >= 0xC
			then
				GentlemanJim:Hide()
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
