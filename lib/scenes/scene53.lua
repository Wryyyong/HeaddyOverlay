-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x1C] = {
	["LevelName"] = {
		["Main"] = [[Scene 5-3]],
		["Sub"] = {
			["Int"] = [["TOWERING INTERNAL"]],
			["Jpn"] = [["ROLLING ROLLING"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene53.StageMonitor.ChainA.Ent",
		"Scene53.StageMonitor.ChainA.Flags",
		"Scene53.StageMonitor.ChainB.Ent",
		"Scene53.StageMonitor.ChainB.Flags",
		"Scene53.StageMonitor.Armordillo.Ent",
		"Scene53.StageMonitor.Armordillo.Flags",
	},

	["LevelScript"] = function()
		local ChainA = BossHealth({
			["ID"] = "ChainA",
			["PrintName"] = {
				["Int"] = "Chain (A)",
			},
			["Address"] = 0xFFD27D,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x7B,
		})
		local ChainB = BossHealth({
			["ID"] = "ChainB",
			["PrintName"] = {
				["Int"] = "Chain (B)",
			},
			["Address"] = 0xFFD295,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x7B,
		})
		local Armordillo = BossHealth({
			["ID"] = "Armordillo",
			["PrintName"] = {
				["Int"] = "Armordillo",
				["Jpn"] = "Armored Soldier",
			},
			["Address"] = 0xFFD281,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = 0x70,
		})

		local BossLookup = {
			[ChainA] = {
				["Ent"] = {
					["Address"] = 0xFFD178,
					["Target"] = 0x37C,
				},
				["Flags"] = {
					["Address"] = 0xFFD17A,
					["Target"] = 0xA,
				},
			},
			[ChainB] = {
				["Ent"] = {
					["Address"] = 0xFFD190,
					["Target"] = 0x37C,
				},
				["Flags"] = {
					["Address"] = 0xFFD192,
					["Target"] = 0xA,
				},
			},
			[Armordillo] = {
				["Ent"] = {
					["Address"] = 0xFFD180,
					["Target"] = 0x39C,
				},
				["Flags"] = {
					["Address"] = 0xFFD182,
					["Target"] = 8,
				},
			},
		}

		local function StageMonitor()
			for boss,addrTbl in pairs(BossLookup) do
				local bossEnt,bossFlags = addrTbl["Ent"],addrTbl["Flags"]

				boss:Show(
					ReadU16BE(bossEnt["Address"]) == bossEnt["Target"]
				and	ReadU16BE(bossFlags["Address"]) >= bossFlags["Target"]
				)
			end
		end

		for bossBar,bossData in pairs(BossLookup) do
			for key,dataTbl in pairs(bossData) do
				MemoryMonitor.Register("Scene53.StageMonitor." .. bossBar.BossData.ID .. "." .. key,dataTbl.Address,StageMonitor,true)
			end
		end
	end,
}
