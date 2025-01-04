-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor

local BossHealth = Overlay.BossHealth or {}
BossHealth.__index = BossHealth
Overlay.BossHealth = BossHealth

local ActiveBars = BossHealth.ActiveBars or {}
BossHealth.ActiveBars = ActiveBars

local BossGlobals = {}

-- Commonly-used functions
local ReadU8 = memory.read_u8
local ReadU16BE = memory.read_u16_be

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

local BossDataDefault = {
	["PrintName"] = "N/A",
	["Address"] = 0xFFFFFF,
	["HealthInit"] = 0xFF,
	["HealthDeath"] = 0,
	["StartHidden"] = true,
}

local HealthColorVals = {
	["Max"] = 0xFF00FF00,
	["Min"] = 0xFFFF0000,
}

function BossHealth.Create(bossName,bossData,startHidden)
	bossName = tostring(bossName)
	bossData = bossData or BossDataDefault
	startHidden =
			(
				startHidden ~= nil
			and	startHidden
		)
		or	(
				bossData["StartHidden"] ~= nil
			and	bossData["StartHidden"]
		)
		or	false

	local newBar = {}
	setmetatable(newBar,BossHealth)

	newBar:UpdateBoss(bossName,bossData)

	newBar.Render = not startHidden

	local activeIndex = #ActiveBars + 1
	newBar.ActiveIndex = activeIndex
	ActiveBars[activeIndex] = newBar

	return newBar
end

function BossHealth:Show()
	if self.Render then return end

	self:UpdateHealth()
	self.Render = true
end

function BossHealth:Hide()
	if not self.Render then return end

	self.Render = false
end

function BossHealth:UpdateBoss(bossName,bossData)
	if self.BossData == bossData then return end

	MemoryMonitor.Unregister(self.MonitorID)

	self.BossData = bossData

	local monitorID = "BossHealth." .. bossName
	self.MonitorID = monitorID
	self.HealthTotal = bossData.HealthInit - bossData.HealthDeath

	self.ReadFunc = bossData.Use16Bit and ReadU16BE or ReadU8

	MemoryMonitor.Register(monitorID,bossData.Address,function()
		self:UpdateHealth()
	end,true)
end

function BossHealth:UpdateHealth()
	local bossData = self.BossData

	self.Health = self.ReadFunc(bossData.Address) - bossData.HealthDeath
	self.HealthPercent = self.Health / self.HealthTotal
	self:UpdateColor()
end

function BossHealth:UpdateColor()
	local healthPercent,newColor = self.HealthPercent

	if healthPercent > .8 then
		newColor = 0x00FF00
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

function BossHealth:Draw()
	local PosY_InnerUp = self.PosY + 4

	-- Black background
	DrawRectangle(
		BossGlobals.PosX,
		self.PosY,
		BossGlobals.BarLength,
		16,
		0,
		0xFF000000
	)
	-- Health bar outline
	DrawRectangle(
		BossGlobals.PosX_InnerLeft,
		PosY_InnerUp,
		72,
		8,
		0xFFFFFFFF,
		0
	)
	-- Health bar fill
	DrawRectangle(
		BossGlobals.PosX_InnerLeft,
		PosY_InnerUp,
		self.HealthPercent * 72,
		8,
		0,
		self.HealthColor
	)

	DrawString(
		BossGlobals.PosX_InnerRight,
		self.PosY + 8,
		self.BossData.PrintName,
		nil,
		nil,
		10,
		"MS Gothic",
		nil,
		"right",
		"middle"
	)
end

function BossHealth:Destroy()
	MemoryMonitor.Unregister(self.MonitorID)

	ActiveBars[self.ActiveIndex] = nil
end

function BossHealth.DestroyAll()
	if #ActiveBars <= 0 then return end

	for _,bar in ipairs(ActiveBars) do
		bar:Destroy()
	end
end

function BossHealth.DrawAll()
	if #ActiveBars <= 0 then return end

	BossGlobals.BarLength = Overlay.BufferWidth * 0.575
	BossGlobals.PosX = Overlay.BufferWidth * 0.2125
	BossGlobals.PosX_InnerLeft = BossGlobals.PosX + 4
	BossGlobals.PosX_InnerRight = Overlay.BufferWidth - BossGlobals.PosX - 4

	local barCounter = -1

	for _,bar in ipairs(ActiveBars) do
		if bar.Render then
			barCounter = barCounter + 1
			bar.PosY = (barCounter * 16) - (barCounter > 0 and 2 or 1)

			bar:Draw()
		end
	end
end
