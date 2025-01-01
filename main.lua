-- Debugging
console.clear()

-- Set up global table
HeaddyOverlay = HeaddyOverlay or {}
local Overlay = HeaddyOverlay

-- Include sub-scripts
local LibPath = "lib/"
dofile(LibPath .. "memorymonitor.lua")
dofile(LibPath .. "headdystats.lua")
dofile(LibPath .. "bosshealth.lua")
dofile(LibPath .. "levelmonitor.lua")

-- Commonly-used functions
local EmuYield = emu.yield
local GuiClearGraphics = gui.clearGraphics

-- Main loop
while true do
	GuiClearGraphics()

	Overlay.MemoryMonitor.ExecuteCallbacks()

	Overlay.BufferWidth,Overlay.BufferHeight = BufferWidth(),BufferHeight()

	Overlay.LevelMonitor.DrawGUI()
	Overlay.BossHealth.DrawAll()

	EmuYield()
end
