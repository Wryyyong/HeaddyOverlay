-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x1A] = {
	["LevelName"] = {
		["Main"] = [[Scene 5-2]],
		["Sub"] = {
			["Int"] = [["STAIR WARS"]],
			["Jpn"] = [["GO UP!"]],
		},
	},

	["LevelScript"] = function()
		-- Disable hiding when going under threshold after first success
		local KeepOn

		local FlyingScythe = BossHealth({
			["ID"] = "FlyingScythe",
			["PrintName"] = {
				["Int"] = "Flying Scythe",
				["Jpn"] = "Tower Crasher",
			},
			["Address"] = 0xFFD261,
			["HealthInit"] = {
				["Int"] = 0x40,
			},
			["HealthDeath"] = {
				["Int"] = 0x38,
				["Jpn"] = 0x3C,
			},
		})

		LevelMonitor.SetSceneMonitor(0xFFD162,function(addressTbl)
			local newVal = ReadU16BE(addressTbl[1])

			KeepOn =
				newVal >= 2
			and (
					KeepOn
				or	newVal >= 8
			)
			and	newVal < 0x1A

			FlyingScythe:Show(KeepOn)
		end)
	end,
}
