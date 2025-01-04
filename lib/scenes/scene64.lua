-- Set up globals and local references
local Overlay = HeaddyOverlay
local MemoryMonitor = Overlay.MemoryMonitor
local BossHealth = Overlay.BossHealth

-- Commonly-used functions
local ReadU8 = memory.read_u8
local ReadU16BE = memory.read_u16_be

Overlay.LevelMonitor.LevelData[0x56] = {
	["LevelName"] = [[Scene 6-4 ("Baby Face")]],
	["LevelMonitorIDList"] = {
		"Scene64.BossPhaseMonitor",
		"Scene64.BossEnd",
	},

	["LevelScript"] = function()
		local BabyFace = BossHealth.Create()

		local function BossEnd(address)
			if ReadU16BE(address) ~= 0 then
				return false
			end

			BabyFace:Hide()

			MemoryMonitor.Unregister("Scene64.BossPhaseMonitor")
		end

		local function SetupBossEndMonitor(address)
			MemoryMonitor.Register("Scene64.BossEnd",address,BossEnd)
		end

		MemoryMonitor.Register("Scene64.BossPhaseMonitor",0xFFD132,function(address)
			local newVal = ReadU16BE(address)

			if newVal == 0xC then
				-- This was the only way I could find a reproducible way of getting
				-- different values for each phase
				-- [TODO: search for a better method]
				local secCheck = (ReadU8(0xFFDB65) << 8) + ReadU8(0xFFDB6D)

				if secCheck == 0x800 then
					BabyFace:UpdateBoss("BabyFaceA",{
						["PrintName"] = "Baby Face",
						["Address"] = 0xFFD235,
						["HealthInit"] = 0x80,
						["HealthDeath"] = 0x60,
					})
				elseif secCheck == 0x1C20 then
					BabyFace:UpdateBoss("BabyFaceB",{
						["PrintName"] = "Boy Face",
						["Address"] = 0xFFD235,
						["HealthInit"] = 0x80,
						["HealthDeath"] = 0x60,
					})
				elseif secCheck == 0x1C60 then
					BabyFace:UpdateBoss("BabyFaceC",{
						["PrintName"] = "Man Face",
						["Address"] = 0xFFD235,
						["HealthInit"] = 0x80,
						["HealthDeath"] = 0x60,
					})
				elseif secCheck == 0x6060 then
					BabyFace:UpdateBoss("BabyFaceD",{
						["PrintName"] = "Grandpa Face",
						["Address"] = 0xFFD235,
						["HealthInit"] = 0x80,
						["HealthDeath"] = 0x5F,
					})

					SetupBossEndMonitor(0xFFD030)
				end

				BabyFace:Show()
			elseif newVal == 0x1C then
				local binoData = {
					["PrintName"] = "Bino",
					["Address"] = 0xFFD26D,
					["HealthInit"] = 0x80,
					["HealthDeath"] = 0x7F,
				}
				binoData.HealthInit = ReadU8(binoData.Address)
				binoData.HealthDeath = binoData.HealthInit - 1

				BabyFace:UpdateBoss("BabyFaceBino",binoData)

				SetupBossEndMonitor(0xFFD050)

				BabyFace:Show()
			end
		end,true)
	end,
}
