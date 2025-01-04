-- Set up globals and local references
local LevelData = HeaddyOverlay.LevelMonitor.LevelData

-- Add barebones LevelData entries for all maps
-- that don't need any special treatment
for sceneID,sceneName in pairs({
	[0x00] = [[Scene 1-1 — "The Getaway"]],
	[0x02] = [[Scene 2-2 — "Toys N The Hood"]],
	[0x04] = [[Scene 4-1 — "Terminate Her Too"]],
	[0x06] = [[Scene 2-3 — "Mad Dog and Headdy"]],
	[0x08] = [["Meet Headcase"]],
	[0x0A] = [["Meet Hangman"]],
	[0x0C] = [[Scene 2-1 — "Practice Area"]],
	[0x0E] = [["Meet Beau"]],
	[0x10] = [[Scene 3-1 — "Down Under"]],
	[0x12] = [[Scene 3-2 — "Backstage Battle"]],
	[0x16] = [[Scene 4-2 — "Mad Mechs"]],
	[0x18] = [[Scene 4-3 — "Mad Mechs 2"]],
	[0x1A] = [[Scene 5-2 — "Stair Wars"]],
	[0x1C] = [[Scene 5-3 — "Towering Internal"]],
	[0x1E] = [[Scene 5-4 — "Spinderella"]],
	[0x22] = [[Scene 8-1 — "The Rocket Tier"]],
	[0x24] = [[Scene 8-2 — "Illegal Weapon 3"]],
	[0x26] = [[Scene 8-3 — "Fun Forgiven"]],
	[0x28] = [[Scene 8-4 — "Vice Versa"]],
	[0x2A] = [[Scene 8-5 — "Twin Freaks"]],
	[0x2C] = [[Scene 9-1 — "Fatal Contrapion"]],
	[0x2E] = [[Scene 9-2 — "Far Trek"]],
	[0x32] = [[Scene 3-3 — "The Green Room"]],
	[0x34] = [[Scene 4-4 — "Heathernapped"]],
	[0x36] = [[Scene 5-1 — "Go Headdy Go"]],
	[0x38] = [[Scene ?-?]],
	[0x3A] = [[Game Over]],
	[0x3C] = [[Opening Demo, shot 1]],
	[0x3E] = [[Opening Demo, shot 2]],
	[0x40] = [[Opening Demo, shot 3]],
	[0x42] = [[Curtain Call]],
	[0x44] = [[Intermission Bonus Game]],
	[0x46] = [[Ending Demo, shot 1]],
	[0x48] = [[Ending Demo, shot 2]],
	[0x4A] = [[Credits]],
	[0x4C] = [[Input Secret Number]],
	[0x4E] = [[The End]],
	[0x50] = [[Scene 6-1 — "Flying Game"]],
	[0x52] = [[Scene 6-2 — "Fly Hard"]],
	[0x54] = [[Scene 6-3 — "Fly Hard 2"]],
	[0x58] = [["Flyi Ngia"]],
	[0x5A] = [["Flyi Ngia"]],
}) do
	LevelData[sceneID] = {
		["LevelName"] = sceneName,
	}
end
