-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x52] = {
	["SceneNumbers"] = {
		["Major"] = "6",
		["Minor"] = "2",
	},
	["Name"] = {
		["Int"] = [["FLY HARD"]],
		["Jpn"] = [["RECKLESS WHEEL"]],
	},

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local WheelerDealer = BossHealth({
			["ID"] = "WheelerDealer",
			["PrintName"] = {
				["Int"] = "Wheeler-Dealer",
				["Jpn"] = "Chris Wheel",
			},
			["Address"] = 0xFFD245,
			["HealthInit"] = {
				["Int"] = 0xC0,
			},
			["HealthDeath"] = {
				["Int"] = 0x7F,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD142,function(addressTbl)
			local newVal = ReadU16BE(addressTbl[1])

			KeepOn =
				newVal >= 2
			and	(
					KeepOn
				or	newVal >= 6
			)
			and	newVal < 0x10

			WheelerDealer:Show(KeepOn)
		end)
	end,
}
