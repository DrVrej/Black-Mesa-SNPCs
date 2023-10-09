AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_BLACKMESA/bullsquid.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_bms_bullsquid_h")
ENT.HullType = HULL_WIDE_SHORT
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 35 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 125 -- How far does the damage go?
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK1} -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_bms_acidspit" -- Entities that it can spawn when range attacking | If set as a table, it picks a random entity
ENT.RangeDistance = 2000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 300 -- How close does it have to be until it uses melee?
ENT.RangeUseAttachmentForPos = true -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "Mouth" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.TimeUntilRangeAttackProjectileRelease = 0.6 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 1.2 -- How much time until it can use a range attack?
ENT.RangeAttackExtraTimers = {0.65, 0.65, 0.7, 0.75, 0.8} -- Extra range attack timers | it will run the projectile code after the given amount of seconds
ENT.Immune_AcidPoisonRadiation = true -- Makes the SNPC not get damage from Acid, posion, radiation
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfAttacking = true -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Standing" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 2000 -- How close does it have to be until it starts to face the enemy?
ENT.NoChaseAfterCertainRange = true -- Should the SNPC not be able to chase when it's between number x and y?
ENT.NoChaseAfterCertainRange_FarDistance = "UseRangeDistance" -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = "UseRangeDistance" -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "OnlyRange" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack
ENT.FootStepTimeRun = 0.25 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.6 -- Next foot step sound when it is walking
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_bms_bullsquid/step1.wav","vj_bms_bullsquid/step2.wav"}
ENT.SoundTbl_Idle = {"vj_bms_bullsquid/Idle1.wav","vj_bms_bullsquid/Idle2.wav","vj_bms_bullsquid/Idle3.wav","vj_bms_bullsquid/Idle4.wav"}
ENT.SoundTbl_Alert = {"vj_bms_bullsquid/detect1.wav","vj_bms_bullsquid/detect2.wav","vj_bms_bullsquid/detect3.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_bms_bullsquid/attack1.wav","vj_bms_bullsquid/attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_bms_zombies/claw_miss1.wav","vj_bms_zombies/claw_miss2.wav"}
ENT.SoundTbl_RangeAttack = {"vj_bms_bullsquid/goo_attack1.wav","vj_bms_bullsquid/goo_attack2.wav","vj_bms_bullsquid/goo_attack3.wav"}
ENT.SoundTbl_Pain = {"vj_bms_bullsquid/pain1.wav","vj_bms_bullsquid/pain2.wav","vj_bms_bullsquid/pain3.wav","vj_bms_bullsquid/pain4.wav","vj_bms_bullsquid/pain5.wav"}
ENT.SoundTbl_Death = {"vj_bms_bullsquid/die1.wav","vj_bms_bullsquid/die2.wav"}

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(45, 45 , 50), Vector(-45, -45, 0))
	self:SetSkin(1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	local randAttack = math.random(1,2)
	if randAttack == 1 then
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK2}
		self.TimeUntilMeleeAttackDamage = 0.43
		self.MeleeAttackDamage = GetConVarNumber("vj_bms_bullsquid_d_reg")
	elseif randAttack == 2 then
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
		self.TimeUntilMeleeAttackDamage = 0.5
		self.MeleeAttackDamage = GetConVarNumber("vj_bms_bullsquid_d_spin")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
	return self:CalculateProjectile("Curve", self:GetAttachment(self:LookupAttachment(self.RangeUseAttachmentForPosID)).Pos, self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter(), 1500) + self:GetUp()*math.Rand(-30,30) + self:GetRight()*math.Rand(-40,40)
	//return (self:GetEnemy():GetPos() - self:GetAttachment(self:LookupAttachment(self.RangeUseAttachmentForPosID)).Pos) + self:GetUp()*math.Rand(300,400) + self:GetRight()*math.Rand(-20,80)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(hitEnt)
	return self:GetForward()*55 + self:GetUp()*255
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
	if GetConVarNumber("vj_bms_bullsquid_gib") == 0 then return false end -- Because sometimes it crashes!
	if self.HasGibDeathParticles == true then
		local bloodeffect = EffectData()
		bloodeffect:SetOrigin(self:GetPos() +self:OBBCenter())
		bloodeffect:SetColor(VJ.Color2Byte(Color(255,221,35)))
		bloodeffect:SetScale(120)
		util.Effect("VJ_Blood1",bloodeffect)
		
		local bloodspray = EffectData()
		bloodspray:SetOrigin(self:GetPos() +self:OBBCenter())
		bloodspray:SetScale(8)
		bloodspray:SetFlags(3)
		bloodspray:SetColor(1)
		util.Effect("bloodspray",bloodspray)
		util.Effect("bloodspray",bloodspray)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos() +self:OBBCenter())
		effectdata:SetScale(1)
		util.Effect("StriderBlood",effectdata)
		util.Effect("StriderBlood",effectdata)
		//ParticleEffect("antlion_gib_02",self:GetPos() +self:OBBCenter(),Angle(0,0,0),nil)
	end
	self:CreateGibEntity("prop_ragdoll","models/gibs/bullsquid/torso.mdl",{Pos=self:LocalToWorld(Vector(0,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-50,50)+self:GetForward()*math.Rand(-50,50)+self:GetUp()*math.Rand(30,100)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/bullsquid/tail.mdl",{Pos=self:LocalToWorld(Vector(4,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-50,50)+self:GetForward()*math.Rand(-50,-50)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/bullsquid/right_leg.mdl",{Pos=self:LocalToWorld(Vector(0,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(100,100)+self:GetForward()*math.Rand(-50,50)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/bullsquid/left_leg.mdl",{Pos=self:LocalToWorld(Vector(0,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-100,-100)+self:GetForward()*math.Rand(-50,50)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/bullsquid/head.mdl",{Pos=self:LocalToWorld(Vector(4,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-50,50)+self:GetForward()*math.Rand(50,50)})
	return true
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/