-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x38] = {
	["LevelName"] = {
		["Main"] = [[Scene ?-?]],
	},
	["LevelMonitorIDList"] = {
		"Scene??.BossMonitor.ManRight",
		"Scene??.BossMonitor.ManLeft",
		"Scene??.BossMonitor.TheatreOwner",
	},

	["LevelScript"] = function()
		local ManRight = BossHealth({
			["ID"] = "ManRight",
			["PrintName"] = {
				["Int"] = "Right-Hand Man",
			},
			["Address"] = 0xFFD239,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x6F,
		})
		local ManLeft = BossHealth({
			["ID"] = "ManLeft",
			["PrintName"] = {
				["Int"] = "Left-Hand Man",
			},
			["Address"] = 0xFFD23D,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x6F,
		})
		local TheatreOwner = BossHealth({
			["ID"] = "TheatreOwner",
			["PrintName"] = {
				["Int"] = "Theatre Owner",
			},
			["Address"] = 0xFFD235,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x71,
		})

		local BossLookup = {
			[ManRight] = 0xFFD13A,
			[ManLeft] = 0xFFD13E,
			[TheatreOwner] = 0xFFD136,
		}

		local function BossMonitor()
			for bossBar,address in pairs(BossLookup) do
				local flags = ReadU16BE(address)

				bossBar:Show(
					flags >= 8
				and	flags < 0x18
				)
			end
		end

		for bossBar,address in pairs(BossLookup) do
			MemoryMonitor.Register("Scene??.BossMonitor." .. bossBar.BossData.ID,address,BossMonitor,true)
		end
	end,
}
