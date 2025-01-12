-- Set up globals and local references
local Overlay = HeaddyOverlay
local Headdy = Overlay.Headdy
local BossHealth = Overlay.BossHealth
local LevelMonitor = Overlay.LevelMonitor

-- Commonly-used functions
local pairs = pairs

local ReadU16BE = memory.read_u16_be

LevelMonitor.LevelData[0x38] = {
	["LevelName"] = {
		["Main"] = [[Scene ?-?]],
	},

	["LevelScript"] = function()
		local ManRight = BossHealth({
			["ID"] = "ManRight",
			["PrintName"] = {
				["Int"] = "Right-Hand Man",
			},
			["Address"] = 0xFFD239,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = {
				["Int"] = 0x6F,
			},
		})
		local ManLeft = BossHealth({
			["ID"] = "ManLeft",
			["PrintName"] = {
				["Int"] = "Left-Hand Man",
			},
			["Address"] = 0xFFD23D,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = {
				["Int"] = 0x6F,
			},
		})
		local TheatreOwner = BossHealth({
			["ID"] = "TheatreOwner",
			["PrintName"] = {
				["Int"] = "Theatre Owner",
			},
			["Address"] = 0xFFD235,
			["HealthInit"] = {
				["Int"] = 0x80,
			},
			["HealthDeath"] = {
				["Int"] = 0x71,
			},
		})

		Headdy.SetInfiniteLives(true)

		LevelMonitor.SetSceneMonitor({
			["CurrentLevel"] = 0xFFE8AA,
			["Stage.Flags"] = 0xFFE850,
			[ManRight] = 0xFFD13A,
			[ManLeft] = 0xFFD13E,
			[TheatreOwner] = 0xFFD136,
		},function(addressTbl)
			for bossBar,address in pairs(addressTbl) do
				-- Skip Stage.Flags entry
				if not bossBar.Show then
					goto skip
				end

				local flags = ReadU16BE(address)

				bossBar:Show(
					LevelMonitor.StageFlags >= 4
				and	flags >= 8
				and	flags < 0x18
				)

				::skip::
			end
		end)
	end,
}
