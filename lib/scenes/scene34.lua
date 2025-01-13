-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x14] = {
	["LevelName"] = {
		["Main"] = [[Scene 3-4]],
		["Sub"] = {
			["Int"] = [["CLOTHES ENCOUNTERS"]],
			["Jpn"] = [["STARLIGHT STORM"]],
		},
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
				(
					KeepOn
				or	newVal >= 0xA
			)
			and	newVal < 0x28

			WoodenDresser:Show(KeepOn)
		end)
	end,
}
