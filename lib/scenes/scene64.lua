-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth
local Width = BossHealth.Width

-- Commonly-used functions
local ReadU16BE = memory.read_u16_be

HeaddyOverlay.LevelMonitor.LevelData[0x56] = {
	["LevelName"] = [[Scene 6-4 ("Baby Face")]],
	["LevelMonitorIDList"] = {
		"Scene64.BossPhase1Pre",
		"Scene64.BossPhase1",
		"Scene64.BossPhase2Pre",
		"Scene64.BossPhase2",
		"Scene64.BossPhase3Pre",
		"Scene64.BossPhase3",
		"Scene64.BossPhase4Pre",
		"Scene64.BossPhase4",
		"Scene64.BossPhase4EarlyEnd",
		"Scene64.BossPhase5Pre",
		"Scene64.BossPhase5",
	},

	["LevelScript"] = function()
		local HealthBar

		local function BossEnd(address)
			if ReadU16BE(address) ~= 0 then
				return false
			end

			HealthBar:Destroy()

			MemoryMonitor.Unregister("Scene64.BossPhase5Pre")
		end

		local function BossPhase5Pre(address)
			if ReadU16BE(address) ~= 0x8056 then
				return false
			end

			local binoData = {
				["PrintName"]     = "Bino",
				["Address"]       = 0xFFD26D,
				["AddressLength"] = Width.U8,
				["HealthInit"]    = 0x80,
				["HealthDeath"]   = 0x7F,
			}
			binoData.HealthInit = binoData.AddressLength(binoData.Address)
			binoData.HealthDeath = binoData.HealthInit - 1

			HealthBar:UpdateBoss("BabyFaceBino",binoData)

			MemoryMonitor.Register("Scene64.BossPhase5",0xFFD050,BossEnd)
		end

		local function BossPhase4(address)
			if ReadU16BE(address) ~= 0x8057 then
				return false
			end

			MemoryMonitor.Register("Scene64.BossPhase5Pre",0xFFD050,BossPhase5Pre)
			MemoryMonitor.Unregister("Scene64.BossPhase4EarlyEnd")
		end

		local function BossPhase4Pre(address)
			if ReadU16BE(address) ~= 0x8056 then
				return false
			end

			HealthBar:UpdateBoss("BabyFaceD",{
				["PrintName"] = "Grandpa Face",
				["Address"] = 0xFFD235,
				["AddressLength"] = Width.U8,
				["HealthInit"] = 0x80,
				["HealthDeath"] = 0x5F,
			})

			MemoryMonitor.Register("Scene64.BossPhase4",0xFFD050,BossPhase4)
			MemoryMonitor.Register("Scene64.BossPhase4EarlyEnd",0xFFD030,BossEnd)
		end

		local function BossPhase3(address)
			if ReadU16BE(address) ~= 0x8057 then
				return false
			end

			MemoryMonitor.Register("Scene64.BossPhase4Pre",0xFFD050,BossPhase4Pre)
		end

		local function BossPhase3Pre(address)
			if ReadU16BE(address) ~= 0x8056 then
				return false
			end

			HealthBar:UpdateBoss("BabyFaceC",{
				["PrintName"] = "Man Face",
				["Address"] = 0xFFD235,
				["AddressLength"] = Width.U8,
				["HealthInit"] = 0x80,
				["HealthDeath"] = 0x60,
			})

			MemoryMonitor.Register("Scene64.BossPhase3",0xFFD050,BossPhase3)
		end

		local function BossPhase2(address)
			if ReadU16BE(address) ~= 0x8057 then
				return false
			end

			MemoryMonitor.Register("Scene64.BossPhase3Pre",0xFFD050,BossPhase3Pre)
		end

		local function BossPhase2Pre(address)
			if ReadU16BE(address) ~= 0x8056 then
				return false
			end

			HealthBar:UpdateBoss("BabyFaceB",{
				["PrintName"] = "Boy Face",
				["Address"] = 0xFFD235,
				["AddressLength"] = Width.U8,
				["HealthInit"] = 0x80,
				["HealthDeath"] = 0x60,
			})

			MemoryMonitor.Register("Scene64.BossPhase2",0xFFD050,BossPhase2)
		end

		local function BossPhase1(address)
			if ReadU16BE(address) ~= 0x8057 then
				return false
			end

			MemoryMonitor.Register("Scene64.BossPhase2Pre",0xFFD050,BossPhase2Pre)
		end

		local function BossPhase1Pre(address)
			if ReadU16BE(address) ~= 0x8001 then
				return false
			end

			HealthBar = BossHealth.Create("BabyFaceA",{
				["PrintName"] = "Baby Face",
				["Address"] = 0xFFD235,
				["AddressLength"] = Width.U8,
				["HealthInit"] = 0x80,
				["HealthDeath"] = 0x60,
			})

			MemoryMonitor.Register("Scene64.BossPhase1",0xFFD050,BossPhase1)
		end

		MemoryMonitor.Register("Scene64.BossPhase1Pre",0xFFD060,BossPhase1Pre)
	end,
}
