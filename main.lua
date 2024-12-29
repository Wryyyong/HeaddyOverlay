-- Debugging
console.clear()
gui.clearGraphics()

-- Set up global table
HeaddyOverlay = HeaddyOverlay or {}
local Overlay = HeaddyOverlay

-- Include sub-scripts
local LibPath = "lib/"
dofile(LibPath .. "memorymonitor.lua")
dofile(LibPath .. "headdystats.lua")
dofile(LibPath .. "levelmonitor.lua")

-- Commonly-used functions
local Yield = emu.yield

-- Main loop
while true do
	Yield()

	Overlay.MemoryMonitor.ExecuteCallbacks()
end
