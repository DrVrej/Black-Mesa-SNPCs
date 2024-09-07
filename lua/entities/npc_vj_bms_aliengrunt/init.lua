AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/VJ_BLACKMESA/agrunt.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 200
ENT.HullType = HULL_MEDIUM_TALL
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

ENT.HasRangeAttack = true -- Can this NPC range attack?
ENT.AnimTbl_RangeAttack = ACT_IDLE_ANGRY -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_vj_bms_hornet" -- Entities that it can spawn when range attacking | If set as a table, it picks a random entity
ENT.RangeDistance = 1000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 250 -- How close does it have to be until it uses melee?
ENT.TimeUntilRangeAttackProjectileRelease = 0.2 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 3 -- How much time until it can use a range attack?
ENT.RangeAttackReps = 8 -- How many times does it run the projectile code?

ENT.FootStepTimeRun = 0.5 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound Paths ====== --
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
local getEventName = util.GetAnimEventNameByID
--
function ENT:CustomOnHandleAnimEvent(ev, evTime, evCycle, evType, evOptions)
	local eventName = getEventName(ev)
	if (eventName == "AE_AGRUNT_MELEE_ATTACK_LOW" && self:GetActivity() != ACT_MELEE_ATTACK2) or eventName == "AE_AGRUNT_MELEE_ATTACK_HIGH" then
		self:MeleeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	if self.NearestPointToEnemyDistance > 150 && self.NearestPointToEnemyDistance < 210 && !self.PropAP_IsVisible then
		self.MeleeAttackDistance = 210
		self.MeleeAttackDamageDistance = 115
		self.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK2
		self.MeleeAttackDamage = 60
		self.HasMeleeAttackKnockBack = true
	else
		self.MeleeAttackDistance = 40
		self.MeleeAttackDamageDistance = 75
		self.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
		self.MeleeAttackDamage = 40
		self.HasMeleeAttackKnockBack = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(hitEnt)
	return self:GetForward()*math.random(270, 290) + self:GetUp()*300
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomRangeAttackCode_AfterProjectileSpawn(projectile)
	if IsValid(self:GetEnemy()) then
		projectile.MyEnemy = self:GetEnemy()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjSpawnPos(projectile)
	return self:GetAttachment(self:LookupAttachment("muzzle")).Pos
end
---------------------------------------------------------------------------------------------------------------------------------------------
local colorYellow = VJ.Color2Byte(Color(255, 221, 35))
--
function ENT:SetUpGibesOnDeath(dmginfo, hitgroup)
	self.HasDeathSounds = false
	if self.HasGibDeathParticles then
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
	
	self:CreateGibEntity("prop_ragdoll", "models/gibs/agrunt/torso.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 6)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-100, 100)+self:GetForward()*math.Rand(-100, 100)})
	self:CreateGibEntity("prop_ragdoll", "models/gibs/agrunt/right_leg.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 0)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(100, 250)+self:GetForward()*math.Rand(-300, 300)})
	self:CreateGibEntity("prop_ragdoll", "models/gibs/agrunt/right_leg.mdl", {Pos=self:LocalToWorld(Vector(0, 20, 0)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-100, -250)+self:GetForward()*math.Rand(-300, 300)})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/agrunt/left_arm_lower.mdl", {BloodType="Yellow", Pos=self:LocalToWorld(Vector(0, 0, 6)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(0, -70)+self:GetForward()*math.Rand(-50, 50)})
	self:CreateGibEntity("prop_physics", "models/gibs/agrunt/gib_back_armor.mdl", {Pos=self:LocalToWorld(Vector(-1, 0, 7)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-40, -70)+self:GetForward()*math.Rand(-90, -110)})
	self:CreateGibEntity("prop_physics", "models/gibs/agrunt/gib_shoulder_armor.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 8)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-80, -100)})
	self:CreateGibEntity("prop_physics", "models/gibs/agrunt/gib_helmet.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 10)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-10, 10)+self:GetForward()*math.Rand(20, 20)})
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	return true
end