-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor

Overlay.BossHealth = Overlay.BossHealth or {}
local BossHealth = Overlay.BossHealth

local HealthColorVals = {
	["Max"] = 0xFF00FF00,
	["Min"] = 0xFFFF0000,
}

-- Commonly-used functions
BossHealth.Width = {
	["U8"] = memory.read_u8,
	["U16"] = memory.read_u16_be,
}

local DrawRectangle = gui.drawRectangle
local DrawString = gui.drawString

function BossHealth.Create(bossName,bossData)
	local newBar = {}
	setmetatable(newBar,BossHealth)

	newBar:UpdateBoss(bossName,bossData)

	local activeIndex = #BossHealth.ActiveBars + 1
	newBar.ActiveIndex = activeIndex
	BossHealth.ActiveBars[activeIndex] = newBar

	return newBar
end

function BossHealth:UpdateBoss(bossName,bossData)
	if self.BossData == bossData then return end

	MemoryMonitor.UnregisterMonitor(self.MonitorID)

	self.BossData = bossData

	local monitorID = "BossHealth." .. bossName
	self.MonitorID = monitorID

	self.HealthTotal = bossData.HealthInit - bossData.HealthDeath
	self.ReadFunc = bossData.AddressLength or BossHealth.Width.U16
	self:UpdateHealth()

	MemoryMonitor.RegisterMonitor(monitorID,bossData.Address,function()
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
	local x,y = Overlay.BufferWidth * 0.5 - 33,Overlay.BufferHeight * 0.1

	self.PosX = Overlay.BufferWidth * 0.25
	self.PosY = -1

	DrawRectangle(
		self.PosX,
		self.PosY,
		Overlay.BufferWidth * 0.5,
		16,
		0,
		0xFF000000
	)
	DrawRectangle(
		self.PosX + 4,
		self.PosY + 4,
		72,
		8,
		0xFFFFFFFF,
		0
	)
	DrawRectangle(
		self.PosX + 4,
		self.PosY + 4,
		self.HealthPercent * 72,
		8,
		0,
		self.HealthColor
	)
	DrawString(
		Overlay.BufferWidth - self.PosX - 2,
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
	--DrawRectangle(x,y,64,8,0xFFFFFFFF,0xFF000000) -- Outline + Background
	--DrawRectangle(x,y,self.HealthPercent * 64,8,0,self.HealthColor) -- Fill
end

function BossHealth:Destroy()
	MemoryMonitor.UnregisterMonitor(self.MonitorID)

	BossHealth.ActiveBars[self.ActiveIndex] = nil
end

function BossHealth.DestroyAll()
	if #BossHealth.ActiveBars <= 0 then return end

	for _,bar in ipairs(BossHealth.ActiveBars) do
		bar:Destroy()
	end
end

function BossHealth.DrawAll()
	if #BossHealth.ActiveBars <= 0 then return end

	for _,bar in ipairs(BossHealth.ActiveBars) do
		bar:Draw()
	end
end

BossHealth.__index = BossHealth
BossHealth.ActiveBars = {}
