-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Util = Overlay.Util
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x12] = {
	["SceneNumbers"] = {
		["Major"] = "3",
		["Minor"] = "2",
	},
	["Name"] = {
		["Int"] = [["BACKSTAGE BATTLE"]],
	},

	["LevelScript"] = function()
		local RocketGrappler = BossHealth({
			["ID"] = "RocketGrappler",
			["PrintName"] = {
				["Int"] = "Rocket Grappler",
				["Jpn"] = "Tail Hanger",
			},
			["Address"] = 0xFFD285,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = {
				["Int"] = 0x70,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD186,function(addressTbl)
			RocketGrappler:Show(Util.IsInRange(ReadU16BE(addressTbl[1]),8,0x1E))
		end)
	end,
}
