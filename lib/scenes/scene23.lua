-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Util = Overlay.Util
local LevelMonitor = Overlay.LevelMonitor
local Elements = Overlay.GUI.Elements
local BossHealth = Elements.BossHealth
local DebrisPickup = Elements.DebrisPickup

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[6] = {
	["SceneNumbers"] = {
		["Major"] = "2",
		["Minor"] = "3",
	},
	["Name"] = {
		["Int"] = [["MAD DOG AND HEADDY"]],
		["Jpn"] = [["CONCERT PANIC"]],
	},
	["ScoreTallyThres"] = 4,

	["LevelScript"] = function()
		local MadDog = BossHealth({
			["ID"] = "MadDog",
			["PrintName"] = {
				["Int"] = "Mad Dog",
				["Jpn"] = "Bounty Boundy",
			},
			["Address"] = 0xFFD285,
			["HealthInit"] = {
				["Int"] = 0x50,
			},
			["HealthDeath"] = {
				["Int"] = 0x3F,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD142,function(addressTbl)
			local newVal = ReadU16BE(addressTbl[1])

			MadDog:Show(Util.IsInRange(newVal,0x16,0x5C))

			DebrisPickup.Enable(newVal > 0x5C)
		end)
	end,
}
