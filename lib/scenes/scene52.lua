-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x1A] = {
	["SceneNumbers"] = {
		["Major"] = "5",
		["Minor"] = "2",
	},
	["Name"] = {
		["Int"] = [["STAIR WARS"]],
		["Jpn"] = [["GO UP!"]],
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

		LevelMonitor.SetSceneMonitor({
			["FlyingScythe.Properties"] = 0xFFD060,
			["FlyingScythe.Routine"] = 0xFFD162,
		},function(addressTbl)
			local routine = ReadU16BE(addressTbl["FlyingScythe.Routine"])

			KeepOn =
				ReadU16BE(addressTbl["FlyingScythe.Properties"]) ~= 0
			and	routine >= 2
			and	(
					KeepOn
				or	routine >= 8
			)
			and	routine < 0x1A

			FlyingScythe:Show(KeepOn)
		end)
	end,
}
