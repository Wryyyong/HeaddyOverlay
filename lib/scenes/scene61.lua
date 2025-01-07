-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x50] = {
	["LevelName"] = {
		["Main"] = [[Scene 6-1]],
		["Sub"] = {
			["Int"] = [["FLYING GAME"]],
			["Jpn"] = [["AIR WALKER"]],
		},
	},
	["LevelMonitorIDList"] = {
		"Scene61.StageMonitor.Battleship.Ent",
		"Scene61.StageMonitor.Battleship.Flags",
		"Scene61.StageMonitor.Claw.Ent",
		"Scene61.StageMonitor.Claw.Flags",
	},

	["LevelScript"] = function()
		local BattleshipClaw = BossHealth({
			["ID"] = "BattleshipClaw",
			["PrintName"] = {
				["Int"] = "Claw",
			},
			["Address"] = 0xFFD239,
			["HealthInit"] = {
				["Int"] = 0x40,
			},
			["HealthDeath"] = 0,
		})

		-- [TODO: Consider whether to implement the bars for the other Battleship components]
		--[[
		local BattleshipJaw = BossHealth({
			["ID"] = "BattleshipJaw",
			["PrintName"] = {
				["Int"] = "Jaw",
			},
			["Address"] = 0xFFD24D,
			["HealthInit"] = {
				["Int"] = 0x86,
			},
			["HealthDeath"] = 0x7F,
		})
		local BattleshipTurretA = BossHealth({
			["ID"] = "BattleshipTurretA",
			["PrintName"] = {
				["Int"] = "Turret (A)",
			},
			["Address"] = 0xFFD251,
			["HealthInit"] = {
				["Int"] = 0x18,
			},
			["HealthDeath"] = 0,
		})
		local BattleshipTurretB = BossHealth({
			["ID"] = "BattleshipTurretB",
			["PrintName"] = {
				["Int"] = "Turret (B)",
			},
			["Address"] = 0xFFD255,
			["HealthInit"] = {
				["Int"] = 0x18,
			},
			["HealthDeath"] = 0,
		})
		local BattleshipTurretC = BossHealth({
			["ID"] = "BattleshipTurretC",
			["PrintName"] = {
				["Int"] = "Turret (C)",
			},
			["Address"] = 0xFFD259,
			["HealthInit"] = {
				["Int"] = 0x18,
			},
			["HealthDeath"] = 0,
		})
		local BattleshipWorm = BossHealth({
			["ID"] = "BattleshipWorm",
			["PrintName"] = {
				["Int"] = "Worm",
			},
			["Address"] = 0xFFD269,
			["HealthInit"] = {
				["Int"] = 6,
			},
			["HealthDeath"] = 0,
		})
		--]]

		local function StageMonitor()
			BattleshipClaw:Show(
				ReadU16BE(0xFFD138) == 0x748
			and	ReadU16BE(0xFFD13A) >= 0xA
			and	ReadU16BE(0xFFD140) == 0x76C
			and	ReadU16BE(0xFFD142) < 6
			)
		end

		for address,append in pairs({
			[0xFFD140] = "Battleship.Ent",
			[0xFFD142] = "Battleship.Flags",
			[0xFFD138] = "Claw.Ent",
			[0xFFD13A] = "Claw.Flags",
		}) do
			MemoryMonitor.Register("Scene61.StageMonitor." .. append,address,StageMonitor,true)
		end
	end,
}
