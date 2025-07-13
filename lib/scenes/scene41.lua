-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local Util = Overlay.Util
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[4] = {
	["SceneNumbers"] = {
		["Major"] = "4",
		["Minor"] = "1",
	},
	["Name"] = {
		["Int"] = [["TERMINATE HER TOO"]],
		["Jpn"] = [["SOUTH TOWN"]],
	},

	["LevelScript"] = function()
		local MonsMeg = BossHealth({
			["ID"] = "MonsMeg",
			["PrintName"] = {
				["Int"] = "Mons Meg",
				["Jpn"] = "Rebecca",
			},
			["Address"] = 0xFFD275,
			["HealthInit"] = {
				["Int"] = 0xFF,
			},
			["HealthDeath"] = {
				["Int"] = 0xE7,
			},
		})

		LevelMonitor.SetSceneMonitor({
			["Stage.Routine"] = 0xFFE850,

			["MonsMeg.Sprite"] = 0xFFD174,
			["MonsMeg.Routine"] = 0xFFD176,
		},function(addressTbl)
			if ReadU16BE(addressTbl["MonsMeg.Sprite"]) ~= 0x134 then return end

			MonsMeg:Show(
				ReadU16BE(addressTbl["Stage.Routine"]) == 0xC
			and	Util.IsInRange(ReadU16BE(addressTbl["MonsMeg.Routine"]),6,0xA)
			)
		end)
	end,
}
