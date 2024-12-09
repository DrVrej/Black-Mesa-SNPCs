AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/VJ_BLACKMESA/houndeye.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 80
ENT.HullType = HULL_TINY
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.Immune_Sonic = true -- Immune to sonic damage

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.AnimTbl_MeleeAttack = ACT_RANGE_ATTACK1
ENT.MeleeAttackDistance = 164 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 300 -- How far does the damage go | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 25
ENT.MeleeAttackDamageType = DMG_SONIC -- Type of Damage
ENT.MeleeAttackDSPSoundType = 34 -- What type of DSP effect? | Search online for the types
ENT.MeleeAttackDSPSoundUseDamage = false -- Should it only do the DSP effect if gets damaged x or greater amount
ENT.DisableDefaultMeleeAttackDamageCode = true -- Disables the default melee attack damage code

ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = ACT_DIESIMPLE
ENT.DeathAnimationChance = 2 -- Put 1 if you want it to play the animation all the time
ENT.PushProps = false -- Should it push props when trying to move?
ENT.AttackProps = false -- Should it attack props when trying to move?
ENT.FootStepTimeRun = 0.3 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 2 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.FlinchChance = 1 -- Chance of it flinching from 1 to x | 1 will make it always flinch
ENT.AnimTbl_Flinch = ACT_SMALL_FLINCH -- The regular flinch animations to play
	-- ====== Sound Paths ====== --
ENT.SoundTbl_FootStep = {"vj_bms_houndeye/he_step1.wav","vj_bms_houndeye/he_step2.wav","vj_bms_houndeye/he_step3.wav"}
ENT.SoundTbl_Idle = {"vj_bms_houndeye/he_idle1.wav","vj_bms_houndeye/he_idle2.wav","vj_bms_houndeye/he_idle3.wav","vj_bms_houndeye/he_idle4.wav","vj_bms_houndeye/he_idle5.wav","vj_bms_houndeye/he_idle6.wav","vj_bms_houndeye/he_idle7.wav","vj_bms_houndeye/he_idle8.wav","vj_bms_houndeye/he_idle9.wav","vj_bms_houndeye/he_idle10.wav"}
ENT.SoundTbl_Alert = {"vj_bms_houndeye/he_alert1.wav","vj_bms_houndeye/he_alert2.wav","vj_bms_houndeye/he_alert3.wav","vj_bms_houndeye/he_alert4.wav","vj_bms_houndeye/he_alert5.wav","vj_bms_houndeye/he_alert6.wav","vj_bms_houndeye/he_alert7.wav","vj_bms_houndeye/he_alert8.wav","vj_bms_houndeye/he_alert9.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_bms_houndeye/charge1.wav","vj_bms_houndeye/charge2.wav","vj_bms_houndeye/charge3.wav"}
//ENT.SoundTbl_MeleeAttack = {"vj_bms_houndeye/charge1.wav","vj_bms_houndeye/charge2.wav","vj_bms_houndeye/charge3.wav"}
ENT.SoundTbl_Pain = {"vj_bms_houndeye/pain1.wav","vj_bms_houndeye/pain2.wav","vj_bms_houndeye/pain3.wav"}
ENT.SoundTbl_Death = {"vj_bms_houndeye/die1.wav"}

local animAlert = {"vjseq_madidle", "vjseq_madidle3"} // ACT_IDLE_ANGRY - Don't use this because "madidle2"  looks weird

-- Custom
ENT.Houndeye_IdleAnims = ACT_IDLE
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(25, 25, 45), Vector(-25, -25, 0))
	self.Houndeye_IdleAnims = {ACT_IDLE, ACT_IDLE, ACT_IDLE, ACT_IDLE, ACT_IDLE, ACT_IDLE, VJ.SequenceToActivity(self, "leaderlook")}
end
---------------------------------------------------------------------------------------------------------------------------------------------
local getEventName = util.GetAnimEventNameByID
--
function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	local eventName = getEventName(ev)
	if eventName == "AE_HOUND_RANGE_ATTACK1" then
		self:MeleeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_IDLE && !IsValid(self:GetEnemy()) then
		return self:ResolveAnimation(self.Houndeye_IdleAnims)
	end
	return self.BaseClass.TranslateActivity(self, act)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if self.VJ_IsBeingControlled then return end
	self:PlayAnim(animAlert, true, 1, true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_BeforeChecks()
	effects.BeamRingPoint(self:GetPos(), 0.3, 2, 400, 16, 0, Color(188, 220, 255), {material="sprites/vj_bms_shockwave", framerate=20})
	effects.BeamRingPoint(self:GetPos(), 0.3, 2, 200, 16, 0, Color(188, 220, 255), {material="sprites/vj_bms_shockwave", framerate=20})
	
	if self.HasSounds == true && GetConVarNumber("vj_npc_sd_meleeattack") == 0 then
		VJ.EmitSound(self, "vj_bms_houndeye/blast1.wav", 100, math.random(80, 100))
	end
	
	VJ.ApplyRadiusDamage(self, self, self:GetPos(), 400, 25, self.MeleeAttackDamageType, true, true, {DisableVisibilityCheck=true, Force=80})
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	-- Fix getting stuck in ground due to death anim
	if status == "DeathAnim" then
		self:SetLocalPos(Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z + 5))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local colorYellow = VJ.Color2Byte(Color(255, 221, 35))
--
function ENT:SetUpGibesOnDeath(dmginfo, hitgroup)
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
	
	self:CreateGibEntity("prop_ragdoll", "models/gibs/houndeye/torso.mdl", {Pos=self:LocalToWorld(Vector(0, 0, -3)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-50, 50)+self:GetForward()*math.Rand(-50, 50)+self:GetUp()*math.Rand(30, 100)})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/houndeye/right_leg_upper.mdl", {BloodType="Yellow", Pos=self:LocalToWorld(Vector(0, 0, -3)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(50, 50)+self:GetForward()*math.Rand(-50, 50)})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/houndeye/right_leg_lower.mdl", {BloodType="Yellow", Pos=self:LocalToWorld(Vector(0, 0, -3)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(50, 50)+self:GetForward()*math.Rand(-50, 50)})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/houndeye/left_leg.mdl", {BloodType="Yellow", Pos=self:LocalToWorld(Vector(0, 0, -3)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-50, -50)+self:GetForward()*math.Rand(-50, 50)})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/houndeye/back_leg.mdl", {BloodType="Yellow", Pos=self:LocalToWorld(Vector(0, 0, -3)), Ang=self:GetAngles(), Vel=self:GetRight()*math.Rand(-50, 50)+self:GetForward()*math.Rand(-50, -50)})
	return true
end