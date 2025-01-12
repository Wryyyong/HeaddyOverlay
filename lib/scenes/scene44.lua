-- Set up globals and local references
local Overlay = HeaddyOverlay
local LevelMonitor = Overlay.LevelMonitor

LevelMonitor.LevelData[0x34] = {
	["LevelName"] = {
		["Main"] = [[Scene 4-4]],
		["Sub"] = {
			["Int"] = [["HEATHERNAPPED"]],
			["Jpn"] = [["MYSTERY SPOT"]],
		},
	},
	["ScoreTallyThres"] = 8,
}
