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
		["Int"] = [[Opening Demo — Shot 1]],
	},
	[0x3E] = {
		["Int"] = [[Opening Demo — Shot 2]],
	},
	[0x40] = {
		["Int"] = [[Opening Demo — Shot 3]],
	},
	[0x42] = {
		["Int"] = [[Curtain Call]],
		["Jpn"] = [[Puppets Introduction]],
	},
	[0x46] = {
		["Int"] = [[Ending Demo — Shot 1]],
	},
	[0x48] = {
		["Int"] = [[Ending Demo — Shot 2]],
	},
	[0x4A] = {
		["Int"] = [[Credits]],
	},
	[0x4E] = {
		["Int"] = [[The End]],
	},
}) do
	LevelMonitor.LevelData[sceneID] = {
		["Name"] = sceneName,
		["LevelScript"] = LevelScriptCommon,
	}
end
