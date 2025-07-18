-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x30] = {
	["SceneNumbers"] = {
		["Major"] = "9",
		["Minor"] = "3",
	},
	["Name"] = {
		["Int"] = [["FINALE ANALYSIS"]],
		["Jpn"] = [["FINAL ATTACK"]],
	},

	["LevelScript"] = function()
		local DarkDemon = BossHealth({
			["ID"] = "DarkDemon",
			["PrintName"] = {
				["Int"] = "Dark Demon",
				["Jpn"] = "King Dark Demon",
			},
			["Address"] = 0xFFD231,
			["HealthInit"] = {
				["Int"] = 0x50,
				["Jpn"] = 0x48,
			},
			["HealthDeath"] = {
				["Int"] = 0x3F,
			},
		})

		LevelMonitor.SetSceneMonitor({
			["Stage.Routine"] = 0xFFE850,
			["HeaddyHead.Routine"] = 0xFFD106,
			["DarkDemon.Routine"] = 0xFFD132,
		},function(addressTbl)
			DarkDemon:Show(
				ReadU16BE(addressTbl["Stage.Routine"]) >= 2
			and	ReadU16BE(addressTbl["HeaddyHead.Routine"]) ~= 0x10
			and	ReadU16BE(addressTbl["DarkDemon.Routine"]) >= 2
			)
		end)
	end,
}
