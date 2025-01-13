-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x26] = {
	["LevelName"] = {
		["Main"] = [[Scene 8-3]],
		["Sub"] = {
			["Int"] = [["FUN FORGIVEN"]],
			["Jpn"] = [["RADICAL PARTY"]],
		},
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
			["Tarot.Ent"] = 0xFFD130,
			["Tarot.Flags"] = 0xFFD132,

			["Rope.Ent"] = 0xFFD138,
			["Rope.Flags"] = 0xFFD13A,
		},function(addressTbl)
			local tarotFlags = ReadU16BE(addressTbl["Tarot.Flags"])

			local tarotCheck =
				ReadU16BE(addressTbl["Tarot.Ent"]) == 0x454
			and	tarotFlags >= 4
			and	(
					ReadU16BE(addressTbl["Rope.Ent"]) ~= 0x458
				or	ReadU16BE(addressTbl["Rope.Flags"]) < 2
			)

			Tarot:UpdateBoss(tarotCheck and (tarotFlags >= 6 and DataTarotB or DataTarotA) or nil)
			Tarot:Show(tarotCheck)
		end)
	end,
}
