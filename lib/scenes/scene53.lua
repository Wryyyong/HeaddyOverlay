-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Commonly-used functions
local pairs = pairs

local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x1C] = {
	["SceneNumbers"] = {
		["Major"] = "5",
		["Minor"] = "3",
	},
	["Name"] = {
		["Int"] = [["TOWERING INTERNAL"]],
		["Jpn"] = [["ROLLING ROLLING"]],
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
				["Properties"] = {
					["Address"] = 0xFFD078,
				},
				["Sprite"] = {
					["Address"] = 0xFFD178,
					["Target"] = 0x37C,
				},
				["Routine"] = {
					["Address"] = 0xFFD17A,
					["Target"] = 0xA,
				},
			},
			[ChainB] = {
				["Properties"] = {
					["Address"] = 0xFFD090,
				},
				["Sprite"] = {
					["Address"] = 0xFFD190,
					["Target"] = 0x37C,
				},
				["Routine"] = {
					["Address"] = 0xFFD192,
					["Target"] = 0xA,
				},
			},
			[Armordillo] = {
				["Properties"] = {
					["Address"] = 0xFFD080,
				},
				["Sprite"] = {
					["Address"] = 0xFFD180,
					["Target"] = 0x39C,
				},
				["Routine"] = {
					["Address"] = 0xFFD182,
					["Target"] = 8,
				},
			},
		}

		LevelMonitor.SetSceneMonitor({
			BossLookup[ChainA].Sprite.Address,
			BossLookup[ChainA].Routine.Address,

			BossLookup[ChainB].Sprite.Address,
			BossLookup[ChainB].Routine.Address,

			BossLookup[Armordillo].Sprite.Address,
			BossLookup[Armordillo].Routine.Address,
		},function()
			for bossBar,addrTbl in pairs(BossLookup) do
				local bossSprite = addrTbl["Sprite"]
				local bossRoutine = addrTbl["Routine"]

				bossBar:Show(
					ReadU16BE(addrTbl["Properties"]["Address"]) ~= 0
				and	ReadU16BE(bossSprite["Address"]) == bossSprite["Target"]
				and	ReadU16BE(bossRoutine["Address"]) >= bossRoutine["Target"]
				)
			end
		end)
	end,
}
