-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x28] = {
	["SceneNumbers"] = {
		["Major"] = "8",
		["Minor"] = "4",
	},
	["Name"] = {
		["Int"] = [["VICE VERSA"]],
		["Jpn"] = [["REVERSE WORLD"]],
	},

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local Sparky = BossHealth({
			["ID"] = "Sparky",
			["PrintName"] = {
				["Int"] = "Sparky",
				["Jpn"] = "Thunder Captain",
			},
			["Address"] = 0xFFD251,
			["HealthInit"] = {
				["Int"] = 0x88,
			},
			["HealthDeath"] = {
				["Int"] = 0x7F,
			},
		})

		LevelMonitor.SetSceneMonitor({
			["Stage.Routine"] = 0xFFE850,

			["Ball.Sprite"] = 0xFFD144,
			["Ball.Routine"] = 0xFFD146,
		},function(addressTbl)
			local routine = ReadU16BE(addressTbl["Ball.Routine"])

			KeepOn =
				ReadU16BE(addressTbl["Stage.Routine"]) == 2
			and	ReadU16BE(addressTbl["Ball.Sprite"]) == 0x498
			and	routine >= 2
			and	(
					KeepOn
				or	routine >= 4
			)

			Sparky:Show(KeepOn)
		end)
	end,
}
