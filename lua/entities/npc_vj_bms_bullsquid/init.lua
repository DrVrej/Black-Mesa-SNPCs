AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/VJ_BLACKMESA/bullsquid.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 120
ENT.HullType = HULL_WIDE_SHORT
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.Immune_AcidPoisonRadiation = true -- Immune to Acid, Poison and Radiation

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1, ACT_MELEE_ATTACK2}
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDistance = 75 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 100 -- How far does the damage go | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy

ENT.HasRangeAttack = true -- Can this NPC range attack?
ENT.AnimTbl_RangeAttack = ACT_RANGE_ATTACK1
ENT.RangeAttackEntityToSpawn = "obj_vj_bms_acidspit" -- Entities that it can spawn when range attacking | If set as a table, it picks a random entity
ENT.RangeDistance = 2000 -- How far can it range attack?
ENT.RangeToMeleeDistance = 300 -- How close does it have to be until it uses melee?
ENT.TimeUntilRangeAttackProjectileRelease = 0.6 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 1.2 -- How much time until it can use a range attack?
ENT.RangeAttackExtraTimers = {0.65, 0.65, 0.7, 0.75, 0.8} -- Extra range attack timers | it will run the projectile code after the given amount of seconds

ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfAttacking = true -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Standing" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 2000 -- How close does it have to be until it starts to face the enemy?
ENT.NoChaseAfterCertainRange = true -- Should the NPC stop chasing when the enemy is within the given far and close distances?
ENT.NoChaseAfterCertainRange_FarDistance = "UseRangeDistance" -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = "UseRangeDistance" -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "OnlyRange" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack
ENT.FootStepTimeRun = 0.25 -- Delay between footstep sounds while it is running | false = Disable while running
ENT.FootStepTimeWalk = 0.6 -- Delay between footstep sounds while it is walking | false = Disable while walking
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound Paths ====== --
ENT.SoundTbl_FootStep = {"vj_bms_bullsquid/step1.wav","vj_bms_bullsquid/step2.wav"}
ENT.SoundTbl_Idle = {"vj_bms_bullsquid/Idle1.wav","vj_bms_bullsquid/Idle2.wav","vj_bms_bullsquid/Idle3.wav","vj_bms_bullsquid/Idle4.wav"}
ENT.SoundTbl_Alert = {"vj_bms_bullsquid/detect1.wav","vj_bms_bullsquid/detect2.wav","vj_bms_bullsquid/detect3.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_bms_bullsquid/attack1.wav","vj_bms_bullsquid/attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_bms_zombies/claw_miss1.wav","vj_bms_zombies/claw_miss2.wav"}
ENT.SoundTbl_RangeAttack = {"vj_bms_bullsquid/goo_attack1.wav","vj_bms_bullsquid/goo_attack2.wav","vj_bms_bullsquid/goo_attack3.wav"}
ENT.SoundTbl_Pain = {"vj_bms_bullsquid/pain1.wav","vj_bms_bullsquid/pain2.wav","vj_bms_bullsquid/pain3.wav","vj_bms_bullsquid/pain4.wav","vj_bms_bullsquid/pain5.wav"}
ENT.SoundTbl_Death = {"vj_bms_bullsquid/die1.wav","vj_bms_bullsquid/die2.wav"}

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(45, 45 , 50), Vector(-45, -45, 0))
	self:SetSkin(1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local getEventName = util.GetAnimEventNameByID
--
function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	local eventName = getEventName(ev)
	if eventName == "AE_SQUID_MELEE_ATTACK1" then
		self.MeleeAttackDamage = 40
		self:MeleeAttackCode()
	elseif eventName == "AE_SQUID_MELEE_ATTACK2" then
		self.MeleeAttackDamage = 50
		self:MeleeAttackCode()
	//elseif eventName == "AE_SQUID_RANGE_ATTACK1" then
		//self:RangeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(hitEnt)
	return self:GetForward()*55 + self:GetUp()*255
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjSpawnPos(projectile)
	return self:GetAttachment(self:LookupAttachment("Mouth")).Pos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjVelocity(projectile)
	return VJ.CalculateTrajectory(self, self:GetEnemy(), "Curve", projectile:GetPos() + VectorRand(-15, 15), 1, 50)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local colorYellow = VJ.Color2Byte(Color(255, 221, 35))
--
function ENT:HandleGibOnDeath(dmginfo, hitgroup)
	if GetConVarNumber("vj_bms_bullsquid_gib") == 0 then return false end -- Because sometimes it crashes!
	self.HasDeathSounds = false
	if self.HasGibOnDeathEffects then
		local effectData = EffectData()
		effectData:SetOrigin(self:GetPos() + self:OBBCenter())
		effectData:SetColor(colorYellow)
		effectData:SetScale(120)
		util.Effect("VJ_Blood1", effectData)
		effectData:SetScale(8)
		effectData:SetFlags(3)
		effectData:SetColor(1)
		util.Effect("bloodspray", effectData)
		util.Effect("bloodspray", effectData)
	end
	
	self:CreateGibEntity("prop_ragdoll", "models/gibs/bullsquid/torso.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 0)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-50, 50)+self:GetForward()*math.Rand(-50, 50)+self:GetUp()*math.Rand(30, 100)})
	self:CreateGibEntity("prop_ragdoll", "models/gibs/bullsquid/tail.mdl", {Pos=self:LocalToWorld(Vector(4, 0, 0)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-50, 50)+self:GetForward()*math.Rand(-50, -50)})
	self:CreateGibEntity("prop_ragdoll", "models/gibs/bullsquid/right_leg.mdl", {Pos=self:LocalToWorld(Vector(0, 0.1, 0)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(100, 100)+self:GetForward()*math.Rand(-50, 50)})
	self:CreateGibEntity("prop_ragdoll", "models/gibs/bullsquid/left_leg.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 0.1)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-100, -100)+self:GetForward()*math.Rand(-50, 50)})
	self:CreateGibEntity("prop_ragdoll", "models/gibs/bullsquid/head.mdl", {Pos=self:LocalToWorld(Vector(4, 0.1, 0)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-50, 50)+self:GetForward()*math.Rand(50, 50)})
	return true
end