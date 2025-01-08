-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor

local Headdy = Overlay.Headdy or {}
Overlay.Headdy = Headdy

local HealthString = ""

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be
local ToInt = math.tointeger
local StringSub = string.sub

MemoryMonitor.Register("Headdy.Health",0xFFD200,function(addressTbl)
	-- Headdy technically has a max health of 32, but this only ever gets
	-- incremented/decremented in multiples of 2, effectively halving his health.
	local newVal = ToInt(ReadU16BE(addressTbl[1]) * .5)
	Headdy.Health = newVal

	HealthString = "Health: " .. StringSub(0 .. newVal,-2) .. " / 16"
end)

MemoryMonitor.Register("Headdy.Lives",0xFFE8EC,function(addressTbl)
	Headdy.Lives = ReadU16BE(addressTbl[1])
end)

MemoryMonitor.Register("Headdy.Continues",0xFFE93C,function(addressTbl)
	Headdy.Continues = ReadU16BE(addressTbl[1])
end)

