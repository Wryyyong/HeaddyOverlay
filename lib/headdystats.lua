-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor

Overlay.Headdy = Overlay.Headdy or {}
local Headdy = Overlay.Headdy

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be
local ToInt = math.tointeger

local function UpdateHealth()
	-- Headdy technically has a max health of 32, but this only ever gets
	-- incremented/decremented in multiples of 2, effectively halving his health. 
	local newVal = ToInt(ReadU16BE(0xFFD200) * 0.5)

	Headdy["Health"] = newVal
end

local function UpdateLives()
	Headdy["Lives"] = ReadU16BE(0xFFE8EC)
end

local function UpdateContinues()
	Headdy["Continues"] = ReadU16BE(0xFFE93C)
end

local function UpdateCurrentLevel()
	Headdy["CurrentLevel"] = ReadU16BE(0xFFE8AA)
end

UpdateHealth()
UpdateLives()
UpdateContinues()
UpdateCurrentLevel()

MemoryMonitor.RegisterMonitor("Headdy.Health",0xFFD200,UpdateHealth)
MemoryMonitor.RegisterMonitor("Headdy.Lives",0xFFE8EC,UpdateLives)
MemoryMonitor.RegisterMonitor("Headdy.Continues",0xFFE93C,UpdateContinues)
MemoryMonitor.RegisterMonitor("Headdy.CurrentLevel",0xFFE8AA,UpdateCurrentLevel)
