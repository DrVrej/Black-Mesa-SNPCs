AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_BLACKMESA/houndeye.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_bms_houndeye_h")
ENT.HullType = HULL_TINY
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.Immune_Sonic = true -- Immune to sonic damage
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {"vjseq_attack3"} -- Melee Attack Animations
ENT.MeleeAttackDistance = 164 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 300 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 1.15 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = GetConVarNumber("vj_bms_houndeye_d")
ENT.MeleeAttackDamageType = DMG_SONIC -- Type of Damage
ENT.MeleeAttackDSPSoundType = 34 -- What type of DSP effect? | Search online for the types
ENT.MeleeAttackDSPSoundUseDamage = false -- Should it only do the DSP effect if gets damaged x or greater amount
ENT.DisableDefaultMeleeAttackDamageCode = true -- Disables the default melee attack damage code
ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {ACT_DIESIMPLE} -- Death Animations
ENT.DeathAnimationChance = 2 -- Put 1 if you want it to play the animation all the time
ENT.PushProps = false -- Should it push props when trying to move?
ENT.AttackProps = false -- Should it attack props when trying to move?
ENT.FootStepTimeRun = 0.3 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
ENT.AnimTbl_IdleStand = {ACT_IDLE, "leaderlook"}
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 2 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.FlinchChance = 1 -- Chance of it flinching from 1 to x | 1 will make it always flinch
ENT.AnimTbl_Flinch = {ACT_SMALL_FLINCH} -- If it uses normal based animation, use this
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_bms_houndeye/he_step1.wav","vj_bms_houndeye/he_step2.wav","vj_bms_houndeye/he_step3.wav"}
ENT.SoundTbl_Idle = {"vj_bms_houndeye/he_idle1.wav","vj_bms_houndeye/he_idle2.wav","vj_bms_houndeye/he_idle3.wav","vj_bms_houndeye/he_idle4.wav","vj_bms_houndeye/he_idle5.wav","vj_bms_houndeye/he_idle6.wav","vj_bms_houndeye/he_idle7.wav","vj_bms_houndeye/he_idle8.wav","vj_bms_houndeye/he_idle9.wav","vj_bms_houndeye/he_idle10.wav"}
ENT.SoundTbl_Alert = {"vj_bms_houndeye/he_alert1.wav","vj_bms_houndeye/he_alert2.wav","vj_bms_houndeye/he_alert3.wav","vj_bms_houndeye/he_alert4.wav","vj_bms_houndeye/he_alert5.wav","vj_bms_houndeye/he_alert6.wav","vj_bms_houndeye/he_alert7.wav","vj_bms_houndeye/he_alert8.wav","vj_bms_houndeye/he_alert9.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_bms_houndeye/charge1.wav","vj_bms_houndeye/charge2.wav","vj_bms_houndeye/charge3.wav"}
//ENT.SoundTbl_MeleeAttack = {"vj_bms_houndeye/charge1.wav","vj_bms_houndeye/charge2.wav","vj_bms_houndeye/charge3.wav"}
ENT.SoundTbl_Pain = {"vj_bms_houndeye/pain1.wav","vj_bms_houndeye/pain2.wav","vj_bms_houndeye/pain3.wav"}
ENT.SoundTbl_Death = {"vj_bms_houndeye/die1.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(25, 25, 45), Vector(-25, -25, 0))
	//self:SetCollisionBounds(Vector(30, 20, 60), Vector(-30, -20, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAlert()
	if self.VJ_IsBeingControlled then return end
	self:VJ_ACT_PLAYACTIVITY({"vjseq_madidle","vjseq_madidle3"},true,1,true) // ACT_IDLE_ANGRY
	/*timer.Simple(1,function() if self:IsValid() then
		//self:TaskComplete()
		self.NextChaseTime = CurTime()
		self:DoChaseAnimation()
		end
	end)*/
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if IsValid(self:GetEnemy()) then
		self.AnimTbl_IdleStand = {ACT_IDLE}
	else
		self.AnimTbl_IdleStand = {ACT_IDLE,"leaderlook"}
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_BeforeChecks()
	effects.BeamRingPoint(self:GetPos(), 0.3, 2, 400, 16, 0, Color(188, 220, 255), {material="sprites/vj_bms_shockwave", framerate=20})
	effects.BeamRingPoint(self:GetPos(), 0.3, 2, 200, 16, 0, Color(188, 220, 255), {material="sprites/vj_bms_shockwave", framerate=20})
	
	if self.HasSounds == true && GetConVarNumber("vj_npc_sd_meleeattack") == 0 then
		VJ.EmitSound(self,"vj_bms_houndeye/blast1.wav",100,math.random(80,100))
	end
	
	VJ.ApplyRadiusDamage(self, self, self:GetPos(), 400, 25, self.MeleeAttackDamageType, true, true, {DisableVisibilityCheck=true, Force=80})
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomDeathAnimationCode(dmginfo,hitgroup)
	self:SetLocalPos(Vector(self:GetPos().x,self:GetPos().y,self:GetPos().z +5))
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
	self:CreateGibEntity("prop_ragdoll","models/gibs/houndeye/torso.mdl",{Pos=self:LocalToWorld(Vector(0,0,-3)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-50,50)+self:GetForward()*math.Rand(-50,50)+self:GetUp()*math.Rand(30,100)})
	self:CreateGibEntity("obj_vj_gib","models/gibs/houndeye/right_leg_upper.mdl",{BloodType="Yellow",Pos=self:LocalToWorld(Vector(0,0,-3)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(50,50)+self:GetForward()*math.Rand(-50,50)})
	self:CreateGibEntity("obj_vj_gib","models/gibs/houndeye/right_leg_lower.mdl",{BloodType="Yellow",Pos=self:LocalToWorld(Vector(0,0,-3)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(50,50)+self:GetForward()*math.Rand(-50,50)})
	self:CreateGibEntity("obj_vj_gib","models/gibs/houndeye/left_leg.mdl",{BloodType="Yellow",Pos=self:LocalToWorld(Vector(0,0,-3)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-50,-50)+self:GetForward()*math.Rand(-50,50)})
	self:CreateGibEntity("obj_vj_gib","models/gibs/houndeye/back_leg.mdl",{BloodType="Yellow",Pos=self:LocalToWorld(Vector(0,0,-3)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-50,50)+self:GetForward()*math.Rand(-50,-50)})
	return true
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/