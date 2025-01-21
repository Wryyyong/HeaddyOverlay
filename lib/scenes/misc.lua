-- Set up globals and local references
local LevelData = HeaddyOverlay.LevelMonitor.LevelData

-- Add barebones LevelData entries for all maps
-- that don't need any special treatment
for sceneID,sceneData in pairs({
	[8] = {
		["SceneNumbers"] = {
			["Major"] = "2",
			["Minor"] = "1",
		},
		["Name"] = {
			["Int"] = [["MEET HEADCASE"]],
			["Jpn"] = [["FRIEND'S ROOM"]],
		},
	},
	[0xA] = {
		["SceneNumbers"] = {
			["Major"] = "2",
			["Minor"] = "1",
		},
		["Name"] = {
			["Int"] = [["MEET HANGMAN"]],
			["Jpn"] = [["FRIEND'S ROOM"]],
		},
	},
	[0xC] = {
		["SceneNumbers"] = {
			["Major"] = "2",
			["Minor"] = "1",
		},
		["Name"] = {
			["Int"] = [["PRACTICE AREA"]],
			["Jpn"] = [["THREE FRIENDS"]],
		},
	},
	[0xE] = {
		["SceneNumbers"] = {
			["Major"] = "2",
			["Minor"] = "1",
		},
		["Name"] = {
			["Int"] = [["MEET BEAU"]],
			["Jpn"] = [["FRIEND'S ROOM"]],
		},
	},
	[0x10] = {
		["SceneNumbers"] = {
			["Major"] = "3",
			["Minor"] = "1",
		},
		["Name"] = {
			["Int"] = [["DOWN UNDER"]],
			["Jpn"] = [["FIRE CARNIVAL"]],
		},
	},
	[0x16] = {
		["SceneNumbers"] = {
			["Major"] = "4",
			["Minor"] = "2",
		},
		["Name"] = {
			["Int"] = [["MAD MECHS"]],
			["Jpn"] = [["WORKING GEAR"]],
		},
	},
	[0x18] = {
		["SceneNumbers"] = {
			["Major"] = "4",
			["Minor"] = "3",
		},
		["Name"] = {
			["Int"] = [["MAD MECHS 2"]],
			["Jpn"] = [["RESTLESS FACTORY"]],
		},
	},
	[0x22] = {
		["SceneNumbers"] = {
			["Major"] = "8",
			["Minor"] = "1",
		},
		["Name"] = {
			["Int"] = [["THE ROCKET TIER"]],
			["Jpn"] = [["FIGHT!"]],
		},
	},
	[0x2C] = {
		["SceneNumbers"] = {
			["Major"] = "9",
			["Minor"] = "1",
		},
		["Name"] = {
			["Int"] = [["FATAL CONTRAPION"]],
			["Jpn"] = [["THE RIVAL"]],
		},
	},
	[0x2E] = {
		["SceneNumbers"] = {
			["Major"] = "9",
			["Minor"] = "2",
		},
		["Name"] = {
			["Int"] = [["FAR TREK"]],
			["Jpn"] = [["BRAIN BREAK!"]],
		},
	},
	[0x36] = {
		["SceneNumbers"] = {
			["Major"] = "5",
			["Minor"] = "1",
		},
		["Name"] = {
			["Int"] = [["GO HEADDY GO"]],
			["Jpn"] = [["PUPPET TOWER"]],
		},
	},
	[0x54] = {
		["SceneNumbers"] = {
			["Major"] = "6",
			["Minor"] = "3",
		},
		["Name"] = {
			["Int"] = [["FLY HARD 2"]],
			["Jpn"] = [["LIGHT VELOCITY"]],
		},
	},
	[0x58] = {
		["Name"] = {
			["Int"] = [["FLYI NGIA"]],
		},
	},
	[0x5A] = {
		["Name"] = {
			["Int"] = [["FLYI NGIA"]],
		},
	},
}) do
	LevelData[sceneID] = sceneData
end
