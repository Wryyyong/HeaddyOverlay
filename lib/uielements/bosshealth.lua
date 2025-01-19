-- Set up globals and local references
local Overlay = HeaddyOverlay
local Hook = Overlay.Hook
local MemoryMonitor = Overlay.MemoryMonitor
local GUI = Overlay.GUI

local BossHealth = {}
BossHealth.__index = BossHealth
GUI.Elements.BossHealth = BossHealth

local ActiveBars = {}
BossHealth.ActiveBars = ActiveBars

local BossGlobals = {
	["Multipliers"] = {
		["PosX"] = 68 / 320,
		["ElementWidth"] = 184 / 320,
		["ElementHeight"] = 16 / 224,
		["BarWidth"] = 68 / 184,
		["BarHeight"] = 1 / 2,
	},
	["Element"] = {
		["InnerPadding"] = {},
	},
	["Bar"] = {},
	["PosYInit"] = {
		["Min"] = -18,
		["Max"] = 0,
		["Inc"] = 1,
	},
}

local GMultipliers = BossGlobals.Multipliers
local GElement = BossGlobals.Element
local GBar = BossGlobals.Bar
local GPosYInit = BossGlobals.PosYInit
local GInnerPadding = GElement.InnerPadding

-- Commonly-used functions
local type = type
local next = next
local ipairs = ipairs
local setmetatable = setmetatable

local ReadU8 = memory.read_u8
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

local BossDataDefault = {
	["ID"] = "DEFAULT",
	["PrintName"] = {
		["Int"] = "N/A",
		["Jpn"] = "N/A",
	},
	["Address"] = 0xFFFFFF,
	["HealthInit"] = {
		["Int"] = 0xFF,
		["Jpn"] = 0xFF,
	},
	["HealthDeath"] = {
		["Int"] = 0,
		["Jpn"] = 0,
	},
	["Use16Bit"] = false,
}

--[[
local HealthColorVals = {
	["Max"] = 0xFF00FF00,
	["Min"] = 0xFFFF0000,
}
--]]

setmetatable(BossHealth,{
	["__call"] = function(_,bossData)
		bossData = bossData or BossDataDefault

		local newBar = {}
		setmetatable(newBar,BossHealth)

		newBar:UpdateBoss(bossData)
		newBar.Render = false
		newBar.PosY = GPosYInit.Min
		newBar.MaxPosY = GPosYInit.Max

		local activeIndex = #ActiveBars + 1
		newBar.ActiveIndex = activeIndex
		ActiveBars[activeIndex] = newBar

		return newBar
	end,
})

function BossHealth:Show(newVal)
	if
		newVal == nil
	or	newVal == self.Render
	then return end

	if newVal then
		self:UpdateHealth()
	end

	self.Render = newVal
end

function BossHealth:UpdateBoss(bossData)
	if
		type(bossData) ~= "table"
	or	self.BossData == bossData
	then return end

	MemoryMonitor.Unregister(self.MonitorID)

	self.BossData = bossData
	setmetatable(bossData.PrintName,Overlay.LangFallback)
	setmetatable(bossData.HealthInit,Overlay.LangFallback)
	setmetatable(bossData.HealthDeath,Overlay.LangFallback)

	local monitorID = "BossHealth." .. bossData.ID
	self.MonitorID = monitorID
	self.HealthTotal = bossData.HealthInit[Overlay.Lang] - bossData.HealthDeath[Overlay.Lang]
	self.ReadFunc = bossData.Use16Bit and ReadU16BE or ReadU8

	MemoryMonitor.Register(monitorID,bossData.Address,function()
		self:UpdateHealth()
	end)
end

function BossHealth:UpdateHealth()
	local bossData = self.BossData

	self.Health = self.ReadFunc(bossData.Address) - bossData.HealthDeath[Overlay.Lang]
	self.HealthPercent = self.Health / self.HealthTotal
	self:UpdateColor()
end

function BossHealth:UpdateColor()
	local healthPercent,newColor = self.HealthPercent

	if healthPercent > .8 then
		newColor = 0xFF00
	elseif healthPercent > .6 then
		newColor = 0x7FFF00
	elseif healthPercent > .4 then
		newColor = 0xFFFF00
	elseif healthPercent > .2 then
		newColor = 0xFF7F00
	else
		newColor = 0xFF0000
	end

	self.HealthColor = newColor + 0xFF000000
	--self.HealthColor = (HealthColorVals.Max - (self.HealthPercent * (HealthColorVals.Min - HealthColorVals.Max))) & 0xFFFFFF00
end

function BossHealth:UpdateOffsetY()
	local pos,inc = self.PosY,GPosYInit.Inc
	local thres,diff

	if self.Render then
		thres = self.MaxPosY

		if pos == thres then
			return
		elseif pos > thres then
			diff = -inc
		else
			diff = inc
		end
	else
		thres = GPosYInit.Min

		if pos == thres then
			return
		elseif pos < thres then
			diff = inc
		else
			diff = -inc
		end
	end

	self.PosY = pos + diff
end

function BossHealth:Draw()
	local innerPaddingUp = self.PosY + GBar.HeightHalf

	-- Black background
	DrawRectangle(
		GElement.PosX,
		self.PosY,
		GElement.Width,
		GElement.Height,
		0x7F000000,
		0x7F000000
	)
	-- Health bar outline
	DrawRectangle(
		GInnerPadding.Left,
		innerPaddingUp,
		GBar.Width,
		GBar.Height,
		0xFFFFFFFF,
		0
	)
	-- Health bar fill
	DrawRectangle(
		GInnerPadding.Left,
		innerPaddingUp,
		GBar.Width * self.HealthPercent,
		GBar.Height,
		0,
		self.HealthColor
	)

	DrawString(
		GInnerPadding.Right,
		innerPaddingUp + 4,
		self.BossData.PrintName[Overlay.Lang],
		nil,
		0xFF000000,
		10,
		"MS Gothic",
		nil,
		"right",
		"middle"
	)
end

Hook.Set("DrawGUI","BossHealth",function(width,height)
	if
		GUI.IsMenuOrLoadingScreen
	or	next(ActiveBars) == nil
	then return end

	GElement.PosX = width * GMultipliers.PosX

	GElement.Width = width * GMultipliers.ElementWidth
	GElement.Height = height * GMultipliers.ElementHeight

	GInnerPadding.Left = GElement.PosX + 4
	GInnerPadding.Right = width - GElement.PosX - 4

	GBar.Width = GElement.Width * GMultipliers.BarWidth
	GBar.Height = GElement.Height * GMultipliers.BarHeight
	GBar.HeightHalf = GBar.Height * .5

	local barCounter = 0

	for _,bossBar in ipairs(ActiveBars) do
		if bossBar.Render then
			bossBar.MaxPosY = (barCounter * GElement.Height) + (barCounter > 0 and 1 or 0)
			barCounter = barCounter + 1
		end

		bossBar:UpdateOffsetY()
		print(_,bossBar.MaxPosY)

		if bossBar.PosY > GPosYInit.Min then
			bossBar:Draw()
		end
	end
end)

Hook.Set("LevelChange","BossHealth",function()
	if #ActiveBars <= 0 then return end

	for _,bossbar in ipairs(ActiveBars) do
		MemoryMonitor.Unregister(bossbar.MonitorID)

		ActiveBars[bossbar.ActiveIndex] = nil
	end
end)
