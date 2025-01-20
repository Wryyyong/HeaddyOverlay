-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x26] = {
	["SceneNumbers"] = {
		["Major"] = "8",
		["Minor"] = "3",
	},
	["Name"] = {
		["Int"] = [["FUN FORGIVEN"]],
		["Jpn"] = [["RADICAL PARTY"]],
	},

	["LevelScript"] = function()
		local Tarot = BossHealth()

		local DataTarotA = {
			["ID"] = "TarotA",
			["PrintName"] = {
				["Int"] = "Tarot",
				["Jpn"] = "Taro",
			},
			["Address"] = 0xFFD231,
			["HealthInit"] = {
				["Int"] = 0xA0,
			},
			["HealthDeath"] = {
				["Int"] = 0x7F,
			},
		}
		local DataTarotB = {
			["ID"] = "TarotB",
			["PrintName"] = {
				["Int"] = "Tarot",
				["Jpn"] = "Taro",
			},
			["Address"] = 0xFFD231,
			["HealthInit"] = {
				["Int"] = 0x90,
			},
			["HealthDeath"] = {
				["Int"] = 0x7F,
			},
		}

		LevelMonitor.SetSceneMonitor({
			["Tarot.Sprite"] = 0xFFD130,
			["Tarot.Routine"] = 0xFFD132,

			["Rope.Sprite"] = 0xFFD138,
			["Rope.Routine"] = 0xFFD13A,
		},function(addressTbl)
			local tarotRoutine = ReadU16BE(addressTbl["Tarot.Routine"])

			local tarotCheck =
				ReadU16BE(addressTbl["Tarot.Sprite"]) == 0x454
			and	tarotRoutine >= 4
			and	(
					ReadU16BE(addressTbl["Rope.Sprite"]) ~= 0x458
				or	ReadU16BE(addressTbl["Rope.Routine"]) < 2
			)

			Tarot:UpdateBoss(tarotCheck and (tarotRoutine >= 6 and DataTarotB or DataTarotA) or nil)
			Tarot:Show(tarotCheck)
		end)
	end,
}
