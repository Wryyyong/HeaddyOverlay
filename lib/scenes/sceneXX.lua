-- Set up globals and local references
local Overlay = HeaddyOverlay
local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local pairs = pairs

local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x38] = {
	["SceneNumbers"] = {
		["Major"] = "?",
		["Minor"] = "?",
	},
	["Name"] = {
		["Int"] = [[]],
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
			["HealthDeath"] = {
				["Int"] = 0x6F,
			},
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
			["HealthDeath"] = {
				["Int"] = 0x6F,
			},
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
			["HealthDeath"] = {
				["Int"] = 0x71,
			},
		})

		Headdy.SetInfiniteLives(true)

		LevelMonitor.SetSceneMonitor({
			[ManRight] = 0xFFD13A,
			[ManLeft] = 0xFFD13E,
			[TheatreOwner] = 0xFFD136,
		},function(addressTbl)
			for bossBar,address in pairs(addressTbl) do
				local flags = ReadU16BE(address)

				bossBar:Show(
					flags >= 8
				and	flags < 0x18
				)
			end
		end)
	end,
}
