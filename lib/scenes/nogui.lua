-- Set up globals and local references
local Overlay = HeaddyOverlay
local Headdy = Overlay.Headdy
local LevelMonitor = Overlay.LevelMonitor

local function LevelScriptCommon()
	Headdy.DisableGUI = true
	LevelMonitor.DisableGUI = true
end

-- Disable the GUI elements on these maps
for sceneID,sceneName in pairs({
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
}) do
	LevelMonitor.LevelData[sceneID] = {
		["LevelName"] = sceneName,
		["LevelScript"] = LevelScriptCommon,
	}
end
