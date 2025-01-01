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
local ClientBufferWidth,ClientBufferHeight = client.bufferwidth,client.bufferheight

-- Main loop
while true do
	GuiClearGraphics()

	Overlay.MemoryMonitor.ExecuteCallbacks()

	if not Overlay.LevelMonitor.InStageTransition then
		Overlay.BufferWidth,Overlay.BufferHeight = ClientBufferWidth(),ClientBufferHeight()

		Overlay.LevelMonitor.DrawGUI()
		Overlay.BossHealth.DrawAll()
	end

	EmuYield()
end
