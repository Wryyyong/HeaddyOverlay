-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Util = Overlay.Util
local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Cache commonly-used functions and constants
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
				bossBar:Show(Util.IsInRange(ReadU16BE(address),8,0x16))
			end
		end)
	end,
}
