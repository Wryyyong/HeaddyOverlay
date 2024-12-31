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
dofile(LibPath .. "bosshealth.lua")
dofile(LibPath .. "levelmonitor.lua")

-- Commonly-used functions
local Yield = emu.yield
local BufferWidth,BufferHeight = client.bufferwidth,client.bufferheight

-- Main loop
while true do
	Yield()

	Overlay.MemoryMonitor.ExecuteCallbacks()

	Overlay.BufferWidth,Overlay.BufferHeight = BufferWidth(),BufferHeight()

	Overlay.BossHealth.DrawAll()
end
