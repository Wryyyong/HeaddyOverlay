-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x1E] = {
	["LevelName"] = {
		["Main"] = [[Scene 5-4]],
		["Sub"] = {
			["Int"] = [["SPINDERELLA"]],
			["Jpn"] = [["ON THE SKY"]],
		},
	},

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
				(
					KeepOn
				or	newVal >= 0xC
			)
			and	newVal < 0x1E

			Spinderella:Show(KeepOn)
		end)
	end,
}
