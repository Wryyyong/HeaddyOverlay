-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x56] = {
	["LevelName"] = {
		["Main"] = [[Scene 6-4]],
		["Sub"] = {
			["Int"] = [["BABY FACE"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene64.BossMonitor.BabyFace.Flags",
		"Scene64.BossMonitor.BabyFace.State",
		"Scene64.BossMonitor.BabyFace.EarlyEnd",
	},

	["LevelScript"] = function()
		local BabyFace = BossHealth({
			["ID"] = "BabyFace",
			["PrintName"] = {
				["Int"] = "Baby Face",
				["Jpn"] = "Mitsuru",
			},
			["Address"] = 0xFFD235,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x60,
		})

		local function BossMonitor()
			local flags = ReadU16BE(0xFFD132)

			local doShow =
				ReadU16BE(0xFFD030) ~= 0
			and	flags >= 0xC
			and	flags < 0x1C

			if doShow then
				local newStr = "Baby Face"

				if ReadU16BE(0xFFDB64) >= 0x1C then
					newStr = newStr .. "...?"
				end

				BabyFace.BossData.PrintName.Int = newStr
			end

			BabyFace:Show(doShow)
		end

		for address,append in pairs({
			[0xFFD132] = "BabyFace.Flags",
			[0xFFDB64] = "BabyFace.State",
			[0xFFD030] = "BabyFace.EarlyEnd",
		}) do
			MemoryMonitor.Register("Scene64.BossMonitor." .. append,address,BossMonitor,true)
		end
	end,
}
