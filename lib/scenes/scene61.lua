-- Set up globals and local references
local Overlay = HeaddyOverlay
local BossHealth = Overlay.BossHealth
local LevelMonitor = Overlay.LevelMonitor

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x50] = {
	["LevelName"] = {
		["Main"] = [[Scene 6-1]],
		["Sub"] = {
			["Int"] = [["FLYING GAME"]],
			["Jpn"] = [["AIR WALKER"]],
		},
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
			["HealthDeath"] = {
				["Int"] = 0,
			},
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
			["HealthDeath"] = {
				["Int"] = 0x7F,
			},
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
			["HealthDeath"] = {
				["Int"] = 0,
			},
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
			["HealthDeath"] = {
				["Int"] = 0,
			},
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
			["HealthDeath"] = {
				["Int"] = 0,
			},
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
			["HealthDeath"] = {
				["Int"] = 0,
			},
		})
		--]]

		LevelMonitor.SetSceneMonitor({
			["Battleship.Ent"] = 0xFFD140,
			["Battleship.Flags"] = 0xFFD142,

			["Claw.Ent"] = 0xFFD138,
			["Claw.Flags"] = 0xFFD13A,
		},function(addressTbl)
			BattleshipClaw:Show(
				ReadU16BE(addressTbl["Claw.Ent"]) == 0x748
			and	ReadU16BE(addressTbl["Claw.Flags"]) >= 0xA
			and	ReadU16BE(addressTbl["Battleship.Ent"]) == 0x76C
			and	ReadU16BE(addressTbl["Battleship.Flags"]) < 6
			)
		end)
	end,
}
