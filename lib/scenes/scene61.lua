-- Set up and/or create local references to our "namespaces"
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor
local BossHealth = Overlay.GUI.Elements.BossHealth

-- Cache commonly-used functions and constants
local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x50] = {
	["SceneNumbers"] = {
		["Major"] = "6",
		["Minor"] = "1",
	},
	["Name"] = {
		["Int"] = [["FLYING GAME"]],
		["Jpn"] = [["AIR WALKER"]],
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
			["Battleship.Sprite"] = 0xFFD140,
			["Battleship.Routine"] = 0xFFD142,

			["Claw.Sprite"] = 0xFFD138,
			["Claw.Routine"] = 0xFFD13A,
		},function(addressTbl)
			BattleshipClaw:Show(
				ReadU16BE(addressTbl["Claw.Sprite"]) == 0x748
			and	ReadU16BE(addressTbl["Claw.Routine"]) >= 0xA
			and	ReadU16BE(addressTbl["Battleship.Sprite"]) == 0x76C
			and	ReadU16BE(addressTbl["Battleship.Routine"]) < 6
			)
		end)
	end,
}
