-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor

local Headdy = Overlay.Headdy or {}
Overlay.Headdy = Headdy

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be
local ToInt = math.tointeger

MemoryMonitor.Register("Headdy.Health",0xFFD200,function(address)
	-- Headdy technically has a max health of 32, but this only ever gets
	-- incremented/decremented in multiples of 2, effectively halving his health.
	local newVal = ToInt(ReadU16BE(address) * 0.5)

	Headdy.Health = newVal
	HealthString = "Health: " .. newVal .. " / 16"
end,true)

MemoryMonitor.Register("Headdy.Lives",0xFFE8EC,function(address)
	Headdy.Lives = ReadU16BE(address)
end,true)

MemoryMonitor.Register("Headdy.Continues",0xFFE93C,function(address)
	Headdy.Continues = ReadU16BE(address)
end,true)

