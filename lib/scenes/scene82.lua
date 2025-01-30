-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x24] = {
	["SceneNumbers"] = {
		["Major"] = "8",
		["Minor"] = "2",
	},
	["Name"] = {
		["Int"] = [["ILLEGAL WEAPON 3"]],
		["Jpn"] = [["MISSILE BASE"]],
	},

	["LevelScript"] = function()
		local MissileMan = BossHealth({
			["ID"] = "MissileMan",
			["PrintName"] = {
				["Int"] = "Missile Man",
				["Jpn"] = "Base Captain",
			},
			["Address"] = 0xFFD245,
			["HealthInit"] = {
				["Int"] = 0x90,
			},
			["HealthDeath"] = {
				["Int"] = 0x7F,
			},
		})

		LevelMonitor.SetSceneMonitor({
			["Stage.Routine"] = 0xFFE850,
			["MissileMan.Routine"] = 0xFFD14A,
		},function(addressTbl)
			MissileMan:Show(
				ReadU16BE(addressTbl["Stage.Routine"]) >= 2
			and	ReadU16BE(addressTbl["MissileMan.Routine"]) == 2
			)
		end)
	end,
}
