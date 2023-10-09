AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_BLACKMESA/agrunt.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_bms_aliengrunt_h")
ENT.HullType = HULL_MEDIUM_TALL
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackDistance = 70 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 100 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.6 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = GetConVarNumber("vj_bms_aliengrunt_d_reg")

ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.AnimTbl_RangeAttack = {ACT_IDLE_ANGRY} -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_bms_hornet" -- Entities that it can spawn when range attacking | If set as a table, it picks a random entity
ENT.RangeDistance = 1000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 250 -- How close does it have to be until it uses melee?
ENT.RangeUseAttachmentForPos = true -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "muzzle" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.TimeUntilRangeAttackProjectileRelease = 0.2 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 3 -- How much time until it can use a range attack?
ENT.RangeAttackReps = 8 -- How many times does it run the projectile code?

ENT.FootStepTimeRun = 0.5 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vJ_bms_aliengrunt/step1.wav","vJ_bms_aliengrunt/step2.wav","vJ_bms_aliengrunt/step3.wav","vJ_bms_aliengrunt/step4.wav","vJ_bms_aliengrunt/step5.wav","vJ_bms_aliengrunt/step6.wav"}
ENT.SoundTbl_Idle = {"vJ_bms_aliengrunt/idle1.wav","vJ_bms_aliengrunt/idle2.wav","vJ_bms_aliengrunt/idle3.wav","vJ_bms_aliengrunt/idle4.wav","vJ_bms_aliengrunt/idle5.wav","vJ_bms_aliengrunt/idle6.wav"}
ENT.SoundTbl_Alert = {"vJ_bms_aliengrunt/alert1.wav","vJ_bms_aliengrunt/alert2.wav","vJ_bms_aliengrunt/alert3.wav","vJ_bms_aliengrunt/alert4.wav","vJ_bms_aliengrunt/alert5.wav","vJ_bms_aliengrunt/alert6.wav"}
ENT.SoundTbl_MeleeAttack = {"vJ_bms_aliengrunt/melee1.wav","vJ_bms_aliengrunt/melee2.wav","vJ_bms_aliengrunt/melee3.wav","vJ_bms_aliengrunt/melee4.wav","vJ_bms_aliengrunt/melee5.wav","vJ_bms_aliengrunt/melee6.wav"}
ENT.SoundTbl_MeleeAttackExtra = {"physics/body/body_medium_impact_hard1.wav","physics/body/body_medium_impact_hard2.wav","physics/body/body_medium_impact_hard3.wav","physics/body/body_medium_impact_hard4.wav","physics/body/body_medium_impact_hard5.wav","physics/body/body_medium_impact_hard6.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_bms_zombies/claw_miss1.wav","vj_bms_zombies/claw_miss2.wav"}
ENT.SoundTbl_RangeAttack = {"vJ_bms_aliengrunt/range1.wav","vJ_bms_aliengrunt/range2.wav"}
ENT.SoundTbl_Pain = {"vJ_bms_aliengrunt/pain1.wav","vJ_bms_aliengrunt/pain2.wav","vJ_bms_aliengrunt/pain3.wav","vJ_bms_aliengrunt/pain4.wav","vJ_bms_aliengrunt/pain5.wav","vJ_bms_aliengrunt/pain6.wav"}
ENT.SoundTbl_Death = {"vJ_bms_aliengrunt/die1.wav","vJ_bms_aliengrunt/die2.wav","vJ_bms_aliengrunt/die3.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(25, 25, 85), Vector(-25, -25, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomRangeAttackCode_AfterProjectileSpawn(projectile)
	if IsValid(self:GetEnemy()) then
		projectile.MyEnemy = self:GetEnemy()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	if self.NearestPointToEnemyDistance > 150 && self.NearestPointToEnemyDistance < 210 && !self.PropAP_IsVisible then
		self.MeleeAttackDistance = 210
		self.MeleeAttackDamageDistance = 115
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK2}
		self.TimeUntilMeleeAttackDamage = 1.3
		self.MeleeAttackDamage = GetConVarNumber("vj_bms_aliengrunt_d_charge")
		self.HasMeleeAttackKnockBack = true
	else
		self.MeleeAttackDistance = 50
		self.MeleeAttackDamageDistance = 100
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
		self.TimeUntilMeleeAttackDamage = 0.65
		self.MeleeAttackDamage = GetConVarNumber("vj_bms_aliengrunt_d_reg")
		self.HasMeleeAttackKnockBack = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(hitEnt)
	return self:GetForward()*math.random(270, 290) + self:GetUp()*300
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
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
	
	self:CreateGibEntity("prop_ragdoll","models/gibs/agrunt/torso.mdl",{Pos=self:LocalToWorld(Vector(0,0,6)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-100,100)+self:GetForward()*math.Rand(-100,100)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/agrunt/right_leg.mdl",{Pos=self:LocalToWorld(Vector(0,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(100,250)+self:GetForward()*math.Rand(-300,300)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/agrunt/right_leg.mdl",{Pos=self:LocalToWorld(Vector(0,20,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-100,-250)+self:GetForward()*math.Rand(-300,300)})
	self:CreateGibEntity("obj_vj_gib","models/gibs/agrunt/left_arm_lower.mdl",{BloodType="Yellow",Pos=self:LocalToWorld(Vector(0,0,6)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(0,-70)+self:GetForward()*math.Rand(-50,50)})
	self:CreateGibEntity("prop_physics","models/gibs/agrunt/gib_back_armor.mdl",{Pos=self:LocalToWorld(Vector(-1,0,7)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-40,-70)+self:GetForward()*math.Rand(-90,-110)})
	self:CreateGibEntity("prop_physics","models/gibs/agrunt/gib_shoulder_armor.mdl",{Pos=self:LocalToWorld(Vector(0,0,8)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-80,-100)})
	self:CreateGibEntity("prop_physics","models/gibs/agrunt/gib_helmet.mdl",{Pos=self:LocalToWorld(Vector(0,0,10)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-10,10)+self:GetForward()*math.Rand(20,20)})
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	return true
end