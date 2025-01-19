-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local Elements = Overlay.GUI.Elements
local BossHealth = Elements.BossHealth
local DebrisPickup = Elements.DebrisPickup

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x2A] = {
	["SceneNumbers"] = {
		["Major"] = "8",
		["Minor"] = "5",
	},
	["Name"] = {
		["Int"] = [["TWIN FREAKS"]],
		["Jpn"] = [["FUNNY ANGRY"]],
	},
	["ScoreTallyThres"] = 8,

	["LevelScript"] = function()
		local TwinFreaks = BossHealth({
			["ID"] = "TwinFreaks",
			["PrintName"] = {
				["Int"] = "Twin Freaks",
				["Jpn"] = "Rever Face",
			},
			["Address"] = 0xFFD241,
			["HealthInit"] = {
				["Int"] = 0x50,
				["Jpn"] = 0x60,
			},
			["HealthDeath"] = {
				["Int"] = 0x3F,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD142,function(addressTbl)
			local newVal = ReadU16BE(addressTbl[1])

			TwinFreaks:Show(
				newVal >= 6
			and	newVal < 0x10
			)

			DebrisPickup.Enable(newVal >= 0x10)
		end)
	end,
}
