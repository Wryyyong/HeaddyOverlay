-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[2] = {
	["LevelName"] = {
		["Main"] = [[Scene 2-2]],
		["Sub"] = {
			["Int"] = [["TOYS N THE HOOD"]],
			["Jpn"] = [["NORTH TOWN"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene22.StageMonitor.Catherine.Ent",
		"Scene22.StageMonitor.Catherine.Flags",
		"Scene22.StageMonitor.SnakeEyes.Ent",
		"Scene22.StageMonitor.SnakeEyes.Flags",
		"Scene22.StageMonitor.SnakeHelp.Ent",
		"Scene22.StageMonitor.SnakeHelp.Flags",
	},

	["LevelScript"] = function()
		local Catherine = BossHealth.Create("Catherine",{
			["PrintName"] = {
				["Int"] = "Catherine Derigueur",
				["Jpn"] = "Catherine Degoon",
			},
			["Address"] = 0xFFD259,
			["HealthInit"] = {
				["Int"] = 0x48,
			},
			["HealthDeath"] = 0x3F,
		},true)
		local SnakeEyes = BossHealth.Create("SnakeEyes",{
			["PrintName"] = {
				["Int"] = "Snake Eyes",
				["Jpn"] = "Happy Comecome",
			},
			["Address"] = 0xFFD265,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x78,
		},true)

		local function StageMonitor()
			-- Catherine
			if ReadU16BE(0xFFD158) == 0x74 then
				local flags = ReadU16BE(0xFFD15A)

				if
					flags >= 4
				and	flags < 0x10
				then
					Catherine:Show()
				else
					Catherine:Hide()
				end
			else
				Catherine:Hide()
			end

			-- Snake Eyes
			if ReadU16BE(0xFFD164) == 0xA0 then
				if
					ReadU16BE(0xFFD1A0) == 0x180
				and	(
						ReadU16BE(0xFFD1A2) < 6
					or	ReadU16BE(0xFFD166) >= 4
				)
				then
					SnakeEyes:Show()
				else
					SnakeEyes:Hide()
				end
			else
				SnakeEyes:Hide()
			end
		end

		for address,append in pairs({
			[0xFFD158] = "Catherine.Ent",
			[0xFFD15A] = "Catherine.Flags",
			[0xFFD164] = "SnakeEyes.Ent",
			[0xFFD166] = "SnakeEyes.Flags",
			[0xFFD1A0] = "SnakeHelp.Ent",
			[0xFFD1A2] = "SnakeHelp.Flags",
		}) do
			MemoryMonitor.Register("Scene22.StageMonitor." .. append,address,StageMonitor,true)
		end
	end,
}
