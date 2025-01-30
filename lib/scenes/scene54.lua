-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local Elements = Overlay.GUI.Elements
local BossHealth = Elements.BossHealth
local DebrisPickup = Elements.DebrisPickup

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x1E] = {
	["SceneNumbers"] = {
		["Major"] = "5",
		["Minor"] = "4",
	},
	["Name"] = {
		["Int"] = [["SPINDERELLA"]],
		["Jpn"] = [["ON THE SKY"]],
	},
	["ScoreTallyThres"] = 4,

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local Spinderella = BossHealth({
			["ID"] = "Spinderella",
			["PrintName"] = {
				["Int"] = "Spinderella",
				["Jpn"] = "Motor Hand",
			},
			["Address"] = 0xFFD249,
			["HealthInit"] = {
				["Int"] = 0x50,
			},
			["HealthDeath"] = {
				["Int"] = 0x3F,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD142,function(addressTbl)
			local newVal = ReadU16BE(addressTbl[1])

			KeepOn =
				newVal >= 8
			and	(
					KeepOn
				or	newVal >= 0xC
			)
			and	newVal < 0x1E

			Spinderella:Show(KeepOn)

			DebrisPickup.Enable(newVal >= 0x1E)
		end)
	end,
}
