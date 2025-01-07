-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x26] = {
	["LevelName"] = {
		["Main"] = [[Scene 8-3]],
		["Sub"] = {
			["Int"] = [["FUN FORGIVEN"]],
			["Jpn"] = [["RADICAL PARTY"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene83.StageMonitor.Tarot.Ent",
		"Scene83.StageMonitor.Tarot.Flags",
		"Scene83.StageMonitor.Rope.Ent",
		"Scene83.StageMonitor.Rope.Flags",
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
			["HealthDeath"] = 0x7F,
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
			["HealthDeath"] = 0x7F,
		}

		local function StageMonitor()
			local tarotFlags = ReadU16BE(0xFFD132)

			local tarotCheck =
				ReadU16BE(0xFFD130) == 0x454
			and	tarotFlags >= 4
			and	(
					ReadU16BE(0xFFD138) ~= 0x458
				or	ReadU16BE(0xFFD13A) < 2
			)

			Tarot:UpdateBoss(tarotCheck and (tarotFlags >= 6 and DataTarotB or DataTarotA) or nil)
			Tarot:Show(tarotCheck)
		end

		for address,append in pairs({
			[0xFFD130] = "Tarot.Ent",
			[0xFFD132] = "Tarot.Flags",
			[0xFFD138] = "Rope.Ent",
			[0xFFD13A] = "Rope.Flags",
		}) do
			MemoryMonitor.Register("Scene83.StageMonitor." .. append,address,StageMonitor,true)
		end
	end,
}
