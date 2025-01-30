-- Set up onexit cleanup event before doing anything else
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

-- Set up global "namespace" table
-- This helps keep the global environment organized
local Overlay = {}
HeaddyOverlay = Overlay

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

-- Execute sub-scripts
local LibPath = "lib/"
dofile(LibPath .. "hook.lua")
dofile(LibPath .. "memorymonitor.lua")
dofile(LibPath .. "gui.lua")

local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI

-- Cache commonly-used functions and constants
local EmuFrameAdvance = emu.frameadvance
local GuiClearGraphics = gui.clearGraphics

Hook.Run("FinalizeSetup")

-- Our main loop
while true do
	GuiClearGraphics()

	MemoryMonitor.ExecuteCallbacks()
	GUI.Draw()

	EmuFrameAdvance()
end
