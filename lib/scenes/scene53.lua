-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local pairs = pairs

local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x1C] = {
	["LevelName"] = {
		["Main"] = [[Scene 5-3]],
		["Sub"] = {
			["Int"] = [["TOWERING INTERNAL"]],
			["Jpn"] = [["ROLLING ROLLING"]],
		},
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
			["HealthDeath"] = {
				["Int"] = 0x7B,
			},
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
			["HealthDeath"] = {
				["Int"] = 0x7B,
			},
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
			["HealthDeath"] = {
				["Int"] = 0x70,
			},
		})

		local BossLookup = {
			[ChainA] = {
				["Sprite"] = {
					["Address"] = 0xFFD078,
				},
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
				["Sprite"] = {
					["Address"] = 0xFFD090,
				},
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
				["Sprite"] = {
					["Address"] = 0xFFD080,
				},
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

		LevelMonitor.SetSceneMonitor({
			BossLookup[ChainA].Ent.Address,
			BossLookup[ChainA].Flags.Address,

			BossLookup[ChainB].Ent.Address,
			BossLookup[ChainB].Flags.Address,

			BossLookup[Armordillo].Ent.Address,
			BossLookup[Armordillo].Flags.Address,
		},function()
			for bossBar,addrTbl in pairs(BossLookup) do
				local bossSprite,bossEnt,bossFlags = addrTbl["Sprite"],addrTbl["Ent"],addrTbl["Flags"]

				bossBar:Show(
					ReadU16BE(bossSprite["Address"]) ~= 0
				and	ReadU16BE(bossEnt["Address"]) == bossEnt["Target"]
				and	ReadU16BE(bossFlags["Address"]) >= bossFlags["Target"]
				)
			end
		end)
	end,
}
