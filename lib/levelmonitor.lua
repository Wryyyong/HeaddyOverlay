-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

Overlay.LevelMonitor = Overlay.LevelMonitor or {}
local LevelMonitor = Overlay.LevelMonitor

local LevelDataDefault = {
	["LevelName"] = [[!! INVALID LEVEL !!]],

	["LevelInit"] = function()
	end,

	["LevelScript"] = function()
	end,
}

LevelMonitor.LevelData = {}
local LevelData = LevelMonitor.LevelData
setmetatable(LevelData,{
	["__index"] = function()
		return LevelDataDefault
	end,
})

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

local function UpdateCurrentLevel()
	local newLevel = LevelData[ReadU16BE(0xFFE8AA)]

	LevelMonitor.CurrentLevel = newLevel

	BossHealth.DestroyAll()

	newLevel.LevelInit()
	newLevel.LevelScript()
end

UpdateCurrentLevel()

MemoryMonitor.RegisterMonitor("LevelMonitor.CurrentLevel",0xFFE8AA,UpdateCurrentLevel,true)

function LevelMonitor.DrawGUI()
	DrawRectangle(-1,Overlay.BufferHeight - 16,Overlay.BufferWidth + 1,16,0,0x7F000000)
	DrawString(Overlay.BufferWidth * 0.5,Overlay.BufferHeight - 9,LevelMonitor.CurrentLevel.LevelName,nil,nil,12,"Courier New","regular","center","middle")
end

local LevelDataOld = {
	[0x00] = [[Scene 1-1 ("The Getaway")]],
	[0x02] = [[Scene 2-2 ("Toys N The Hood")]],
	[0x04] = [[Scene 4-1 ("Terminate Her Too")]],
	[0x06] = [[Scene 2-3 ("Mad Dog and Headdy")]],
	[0x08] = [[Scene 2-1.1 ("Meet Headcase")]],
	[0x0A] = [[Scene 2-1.2 ("Meet Hangman")]],
	[0x0C] = [[Scene 2-1 ("Practice Area")]],
	[0x0E] = [[Scene 2-1.3 ("Meet Beau")]],
	[0x10] = [[Scene 3-1 ("Down Under")]],
	[0x12] = [[Scene 3-2 ("Backstage Battle")]],
	[0x14] = [[Scene 3-4 ("Clothes Encounter")]],
	[0x16] = [[Scene 4-2 ("Mad Mechs")]],
	[0x18] = [[Scene 4-3 ("Mad Mechs 2")]],
	[0x1A] = [[Scene 5-2 ("Stair Wars")]],
	[0x1C] = [[Scene 5-3 ("Towering Internal")]],
	[0x1E] = [[Scene 5-4 ("Spinderella")]],
	[0x20] = [[Scene 7-1 ("Headdy Wonderland")]],
	[0x22] = [[Scene 8-1 ("The Rocket Tier")]],
	[0x24] = [[Scene 8-2 ("Illegal Weapon 3")]],
	[0x26] = [[Scene 8-3 ("Fun Forgiven")]],
	[0x28] = [[Scene 8-4 ("Vice Versa")]],
	[0x2A] = [[Scene 8-5 ("Twin Freaks")]],
	[0x2C] = [[Scene 9-1 ("Fatal Contrapion")]],
	[0x2E] = [[Scene 9-2 ("Far Trek")]],
	[0x30] = [[Scene 9-3 ("Finale Analysis")]],
	[0x32] = [[Scene 3-3 ("The Green Room")]],
	[0x34] = [[Scene 4-4 ("Heathernapped")]],
	[0x36] = [[Scene 5-1 ("Go Headdy Go")]],
	[0x38] = [[Scene ?-? (Theatre Owner boss)]],
	[0x3A] = [[Game Over]],
	[0x3C] = [[Scene 0-1.1 (Opening Demo, shot 1)]],
	[0x3E] = [[Scene 0-1.2 (Opening Demo, shot 2)]],
	[0x40] = [[Scene 0-1.3 (Opening Demo, shot 3)]],
	[0x42] = [[Curtain Call]],
	[0x44] = [[Intermission Bonus Game]],
	[0x46] = [[Ending Demo, shot 1]],
	[0x48] = [[Ending Demo, shot 2]],
	[0x4A] = [[Credits]],
	[0x4C] = [[Input Secret Number]],
	[0x4E] = [[The End]],
	[0x50] = [[Scene 6-1 ("Flying Game")]],
	[0x52] = [[Scene 6-2 ("Fly Hard")]],
	[0x54] = [[Scene 6-3 ("Fly Hard 2")]],
	[0x56] = [[Scene 6-4 ("Baby Face")]],
	[0x58] = [["Flyi Ngia"]],
	[0x5A] = [["Flyi Ngia"]],
}
