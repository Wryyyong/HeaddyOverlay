-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[4] = {
	["LevelName"] = {
		["Main"] = [[Scene 4-1]],
		["Sub"] = {
			["Int"] = [["TERMINATE HER TOO"]],
			["Jpn"] = [["SOUTH TOWN"]],
		},
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
			["HealthDeath"] = 0xE7,
		})

		LevelMonitor.SetSceneMonitor({
			["MonsMeg.Ent"] = 0xFFD174,
			["MonsMeg.Flags"] = 0xFFD176,
		},function(addressTbl)
			if ReadU16BE(addressTbl["MonsMeg.Ent"]) ~= 0x134 then return end

			local flags = ReadU16BE(addressTbl["MonsMeg.Flags"])

			MonsMeg:Show(
				flags >= 6
			and	flags < 0xC
			)
		end)
	end,
}
