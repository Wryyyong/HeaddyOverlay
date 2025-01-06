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
		local Tarot = BossHealth.Create()

		local DataTarotA = {
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
			if ReadU16BE(0xFFD130) ~= 0x454 then return end

			local tarotFlags = ReadU16BE(0xFFD132)

			if
				tarotFlags >= 4
			and	(
					ReadU16BE(0xFFD138) ~= 0x458
				or	ReadU16BE(0xFFD13A) < 2
			)
			then
				local newName,newData

				if tarotFlags >= 6 then
					newName = "TarotB"
					newData = DataTarotB
				else
					newName = "TarotA"
					newData = DataTarotA
				end

				Tarot:UpdateBoss(newName,newData)
				Tarot:Show()
			else
				Tarot:Hide()
			end
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
