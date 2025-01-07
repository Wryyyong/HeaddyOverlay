-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor

local BossHealth = Overlay.BossHealth or {}
BossHealth.__index = BossHealth
Overlay.BossHealth = BossHealth

local ActiveBars = BossHealth.ActiveBars or {}
BossHealth.ActiveBars = ActiveBars

local BossGlobals = {
	["Multipliers"] = {
		["PosX"] = 68 / 320,
		["ElementWidth"] = 184 / 320,
		["ElementHeight"] = 16 / 224,
		["BarWidth"] = 68 / 184,
		["BarHeight"] = 8 / 16,
	},
	["Element"] = {
		["InnerPadding"] = {},
	},
	["Bar"] = {},
}

-- Commonly-used functions
local SetMetaTable = setmetatable
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
	["HealthDeath"] = 0,
	["Use16Bit"] = false,
}

local HealthColorVals = {
	["Max"] = 0xFF00FF00,
	["Min"] = 0xFFFF0000,
}

local function CreateBar(_,bossData)
	bossData = bossData or BossDataDefault

	local newBar = {}
	SetMetaTable(newBar,BossHealth)

	newBar:UpdateBoss(bossData)
	newBar.Render = false

	local activeIndex = #ActiveBars + 1
	newBar.ActiveIndex = activeIndex
	ActiveBars[activeIndex] = newBar

	return newBar
end

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
	SetMetaTable(bossData.PrintName,Overlay.LangFallback)
	SetMetaTable(bossData.HealthInit,Overlay.LangFallback)

	local monitorID = "BossHealth." .. bossData.ID
	self.MonitorID = monitorID
	self.HealthTotal = bossData.HealthInit[Overlay.Lang] - bossData.HealthDeath
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

function BossHealth:Draw()
	local innerPaddingUp = self.PosY + 4

	-- Black background
	DrawRectangle(
		BossGlobals.Element.PosX,
		self.PosY,
		BossGlobals.Element.Width,
		BossGlobals.Element.Height,
		0,
		0xFF000000
	)
	-- Health bar outline
	DrawRectangle(
		BossGlobals.Element.InnerPadding.Left,
		innerPaddingUp,
		BossGlobals.Bar.Width,
		BossGlobals.Bar.Height,
		0xFFFFFFFF,
		0
	)
	-- Health bar fill
	DrawRectangle(
		BossGlobals.Element.InnerPadding.Left,
		innerPaddingUp,
		BossGlobals.Bar.Width * self.HealthPercent,
		BossGlobals.Bar.Height,
		0,
		self.HealthColor
	)

	DrawString(
		BossGlobals.Element.InnerPadding.Right,
		innerPaddingUp + 4,
		self.BossData.PrintName[Overlay.Lang],
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

	local multipliers = BossGlobals.Multipliers
	local element = BossGlobals.Element
	local bar = BossGlobals.Bar

	element.PosX = Overlay.BufferWidth * multipliers.PosX

	element.Width = Overlay.BufferWidth * multipliers.ElementWidth
	element.Height = Overlay.BufferHeight * multipliers.ElementHeight

	element.InnerPadding.Left = element.PosX + 4
	element.InnerPadding.Right = Overlay.BufferWidth - element.PosX - 4

	bar.Width = element.Width * multipliers.BarWidth
	bar.Height = element.Height * multipliers.BarHeight

	local clamp2,clamp1 = element.Height / 8,element.Height / 16
	local barCounter = -1

	for _,bossBar in ipairs(ActiveBars) do
		if bossBar.Render then
			barCounter = barCounter + 1
			bossBar.PosY = (barCounter * element.Height) - (barCounter > 0 and clamp2 or clamp1)

			bossBar:Draw()
		end
	end
end

SetMetaTable(BossHealth,{
	["__call"] = CreateBar,
})
