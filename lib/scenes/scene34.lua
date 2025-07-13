-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Util = Overlay.Util
local LevelMonitor = Overlay.LevelMonitor
local Elements = Overlay.GUI.Elements
local BossHealth = Elements.BossHealth
local DebrisPickup = Elements.DebrisPickup

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x14] = {
	["SceneNumbers"] = {
		["Major"] = "3",
		["Minor"] = "4",
	},
	["Name"] = {
		["Int"] = [["CLOTHES ENCOUNTERS"]],
		["Jpn"] = [["STARLIGHT STORM"]],
	},
	["ScoreTallyThres"] = 4,

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local WoodenDresser = BossHealth({
			["ID"] = "WoodenDresser",
			["PrintName"] = {
				["Int"] = "Wooden Dresser",
				["Jpn"] = "Jacquline Dressy",
			},
			["Address"] = 0xFFD279,
			["HealthInit"] = {
				["Int"] = 0x48,
			},
			["HealthDeath"] = {
				["Int"] = 0x3F,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD17A,function(addressTbl)
			local newVal = ReadU16BE(addressTbl[1])

			KeepOn =
				Util.IsInRange(newVal,8,0x26)
			and	(
					KeepOn
				or	newVal >= 0xA
			)

			WoodenDresser:Show(KeepOn)

			DebrisPickup.Enable(newVal > 0x26)
		end)
	end,
}
