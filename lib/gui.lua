-- Set up globals and local references
local Overlay = HeaddyOverlay

local GUI = Overlay.GUI or {}
Overlay.GUI = GUI

local CustomElements = {}

-- Commonly-used functions
local next = next
local pairs = pairs
local tostring = tostring

local ClientBufferWidth,ClientBufferHeight = client.bufferwidth,client.bufferheight

-- Include sub-scripts
local LibPath = "lib/"
dofile(LibPath .. "headdystats.lua")
dofile(LibPath .. "bosshealth.lua")
dofile(LibPath .. "levelmonitor.lua")

local Headdy = Overlay.Headdy
local BossHealth = Overlay.BossHealth
local LevelMonitor = Overlay.LevelMonitor

function GUI.AddCustomElement(id,drawFunc)
	id = tostring(id)

	CustomElements[id] = drawFunc
end

function GUI.ClearCustomElements()
	if next(CustomElements) == nil then return end

	for id in pairs(CustomElements) do
		CustomElements[id] = nil
	end
end

function GUI.Draw()
	if LevelMonitor.InStageTransition then return end

	GUI.BufferWidth,GUI.BufferHeight = ClientBufferWidth(),ClientBufferHeight()

	BossHealth.DrawAll()
	LevelMonitor.DrawGUI()

	if next(CustomElements) == nil then return end

	for _,drawFunc in pairs(CustomElements) do
		drawFunc()
	end
end
