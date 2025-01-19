-- Set up onexit event before doing anything else
local function Cleanup()
	HeaddyOverlay = nil

	for _,eventName in ipairs({
		"MemoryMonitor.Main",
		"MemoryMonitor.ForceRefreshAllMonitors",
		"Cleanup",
	}) do
		event.unregisterbyname("HeaddyOverlay." .. eventName)
	end
end

Cleanup()
event.onexit(Cleanup,"HeaddyOverlay.Cleanup")

-- Set up global table
local Overlay = {
	["Debug"] = false,
}
HeaddyOverlay = Overlay

-- Debugging
if Overlay.Debug then
	console.clear()
end

local RecognizedROMs = {
	["D11EC9B230E88403CD75EF186A884C97"]         = "Int", -- International release
	["CDB36911439289D3453060F58682057C"]         = "Jpn", -- Japanese release
	["241D076E6CAF02496A916AF30C009A5279E0832E"] = "Jpn", -- Japanese release, MIJET fan translation patch v. 070428
}

Overlay.Lang = RecognizedROMs[gameinfo.getromhash()]

if not Overlay.Lang then
	error("Invalid ROM")
end

Overlay.LangFallback = {
	["__index"] = function(tbl)
		return tbl["Int"]
	end
}

-- Commonly-used functions
local EmuFrameAdvance = Overlay.Debug and emu.yield or emu.frameadvance
local GuiClearGraphics = gui.clearGraphics

-- Include sub-scripts
local LibPath = "lib/"
dofile(LibPath .. "memorymonitor.lua")
dofile(LibPath .. "gui.lua")

-- Main loop
while true do
	GuiClearGraphics()

	Overlay.MemoryMonitor.ExecuteCallbacks()
	Overlay.GUI.Draw()

	EmuFrameAdvance()
end
