-- Set up globals and local references
local LevelData = HeaddyOverlay.LevelMonitor.LevelData

-- Add barebones LevelData entries for all maps
-- that don't need any special treatment
for sceneID,sceneName in pairs({
	[8] = {
		["Main"] = [[]],
		["Sub"] = {
			["Int"] = [["MEET HEADCASE"]],
			["Jpn"] = [["FRIEND'S ROOM"]],
		},
	},
	[0xA] = {
		["Main"] = [[]],
		["Sub"] = {
			["Int"] = [["MEET HANGMAN"]],
			["Jpn"] = [["FRIEND'S ROOM"]],
		},
	},
	[0xC] = {
		["Main"] = [[Scene 2-1]],
		["Sub"] = {
			["Int"] = [["PRACTICE AREA"]],
			["Jpn"] = [["THREE FRIENDS"]],
		},
	},
	[0xE] = {
		["Main"] = [[]],
		["Sub"] = {
			["Int"] = [["MEET BEAU"]],
			["Jpn"] = [["FRIEND'S ROOM"]],
		},
	},
	[0x10] = {
		["Main"] = [[Scene 3-1]],
		["Sub"] = {
			["Int"] = [["DOWN UNDER"]],
			["Jpn"] = [["FIRE CARNIVAL"]],
		},
	},
	[0x16] = {
		["Main"] = [[Scene 4-2]],
		["Sub"] = {
			["Int"] = [["MAD MECHS"]],
			["Jpn"] = [["WORKING GEAR"]],
		},
	},
	[0x18] = {
		["Main"] = [[Scene 4-3]],
		["Sub"] = {
			["Int"] = [["MAD MECHS 2"]],
			["Jpn"] = [["RESTLESS FACTORY"]],
		},
	},
	[0x22] = {
		["Main"] = [[Scene 8-1]],
		["Sub"] = {
			["Int"] = [["THE ROCKET TIER"]],
			["Jpn"] = [["FIGHT!"]],
		},
	},
	[0x2C] = {
		["Main"] = [[Scene 9-1]],
		["Sub"] = {
			["Int"] = [["FATAL CONTRAPION"]],
			["Jpn"] = [["THE RIVAL"]],
		},
	},
	[0x2E] = {
		["Main"] = [[Scene 9-2]],
		["Sub"] = {
			["Int"] = [["FAR TREK"]],
			["Jpn"] = [["BRAIN BREAK!"]],
		},
	},
	[0x36] = {
		["Main"] = [[Scene 5-1]],
		["Sub"] = {
			["Int"] = [["GO HEADDY GO"]],
			["Jpn"] = [["PUPPET TOWER"]],
		},
	},
	[0x3C] = {
		["Main"] = [[Opening Demo]],
		["Sub"] = {
			["Int"] = [[Shot 1]],
		},
	},
	[0x3E] = {
		["Main"] = [[Opening Demo]],
		["Sub"] = {
			["Int"] = [[Shot 2]],
		},
	},
	[0x40] = {
		["Main"] = [[Opening Demo]],
		["Sub"] = {
			["Int"] = [[Shot 3]],
		},
	},
	[0x42] = {
		["Sub"] = {
			["Int"] = [[Curtain Call]],
			["Jpn"] = [[Puppets Introduction]],
		},
	},
	[0x44] = {
		["Main"] = [[Intermission]],
	},
	[0x46] = {
		["Main"] = [[Ending Demo]],
		["Sub"] = {
			["Int"] = [[Shot 1]],
		},
	},
	[0x48] = {
		["Main"] = [[Ending Demo]],
		["Sub"] = {
			["Int"] = [[Shot 2]],
		},
	},
	[0x4A] = {
		["Main"] = [[Credits]],
	},
	[0x4E] = {
		["Main"] = [[The End]],
	},
	[0x54] = {
		["Main"] = [[Scene 6-3]],
		["Sub"] = {
			["Int"] = [["FLY HARD 2"]],
			["Jpn"] = [["LIGHT VELOCITY"]],
		},
	},
	[0x58] = {
		["Main"] = [["FLYI NGIA"]],
	},
	[0x5A] = {
		["Main"] = [["FLYI NGIA"]],
	},
}) do
	LevelData[sceneID] = {
		["LevelName"] = sceneName,
	}
end
