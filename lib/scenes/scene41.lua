-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[4] = {
	["LevelName"] = {
		["Main"] = [[Scene 4-1]],
		["Sub"] = {
			["Int"] = [["TERMINATE HER TOO"]],
			["Jpn"] = [["SOUTH TOWN"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene41.StageMonitor.MonsMeg.Ent",
		"Scene41.StageMonitor.MonsMeg.Flags",
	},

	["LevelScript"] = function()
		local MonsMeg = BossHealth.Create("MonsMeg",{
			["PrintName"] = {
				["Int"] = "Mons Meg",
				["Jpn"] = "Rebecca",
			},
			["Address"] = 0xFFD275,
			["HealthInit"] = {
				["Int"] = 0xFF,
			},
			["HealthDeath"] = 0xE7,
		},true)

		local function StageMonitor()
			local flags = ReadU16BE(0xFFD176)

			if
				ReadU16BE(0xFFD174) == 0x134
			and	flags >= 6
			and	flags < 0xC
			then
				MonsMeg:Show()
			else
				MonsMeg:Hide()
			end
		end

		for address,append in pairs({
			[0xFFD174] = "MonsMeg.Ent",
			[0xFFD176] = "MonsMeg.Flags",
		}) do
			MemoryMonitor.Register("Scene41.StageMonitor." .. append,address,StageMonitor,true)
		end
	end,
}
