AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_BLACKMESA/snark.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_bms_snark_h")
ENT.HullType = HULL_TINY
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_SNARK"} -- NPCs with the same class with be allied to each other
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {} -- Melee Attack Animations
ENT.MeleeAttackDistance = 50 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 50 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.1 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 0.4 -- How much time until it can use any attack again? | Counted in Seconds
ENT.MeleeAttackDamage = GetConVarNumber("vj_bms_snark_bite_d")
ENT.HasLeapAttack = true -- Should the SNPC have a leap attack?
ENT.AnimTbl_LeapAttack = {ACT_GLIDE} -- Melee Attack Animations
ENT.LeapDistance = 200 -- The distance of the leap, for example if it is set to 500, when the SNPC is 500 Unit away, it will jump
ENT.LeapToMeleeDistance = 0 -- How close does it have to be until it uses melee?
ENT.TimeUntilLeapAttackDamage = 0.4 -- How much time until it runs the leap damage code?
ENT.NextLeapAttackTime = 0.4 -- How much time until it can use a leap attack?
ENT.NextAnyAttackTime_Leap = 0.4 -- How much time until it can use any attack again? | Counted in Seconds
ENT.LeapAttackExtraTimers = {0.2, 0.6} -- Extra leap attack timers | it will run the damage code after the given amount of seconds
ENT.LeapAttackVelocityForward = 100 -- How much forward force should it apply?
ENT.LeapAttackVelocityUp = 180 -- How much upward force should it apply?
ENT.LeapAttackDamage = GetConVarNumber("vj_bms_snark_jumpbite_d")
ENT.LeapAttackDamageDistance = 100 -- How far does the damage go?
ENT.HasDeathRagdoll = false -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.PushProps = false -- Should it push props when trying to move?
ENT.EntitiesToNoCollide = {"npc_vj_bmsno_snark"}
ENT.FindEnemy_UseSphere = true -- Should the SNPC be able to see all around him? (360) | Objects and walls can still block its sight!
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {"vj_bms_snark/hunt1.wav","vj_bms_snark/hunt2.wav","vj_bms_snark/hunt3.wav","vj_bms_snark/hunt4.wav"}
ENT.SoundTbl_Alert = {"vj_bms_snark/deploy1.wav","vj_bms_snark/deploy2.wav","vj_bms_snark/deploy3.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_bms_snark/bite01.wav","vj_bms_snark/bite02.wav","vj_bms_snark/bite03.wav","vj_bms_snark/bite04.wav","vj_bms_snark/bite05.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_bms_snark/hunt1.wav","vj_bms_snark/hunt2.wav","vj_bms_snark/hunt3.wav","vj_bms_snark/hunt4.wav"}
ENT.SoundTbl_LeapAttackDamage = {"vj_bms_snark/bite01.wav","vj_bms_snark/bite02.wav","vj_bms_snark/bite03.wav","vj_bms_snark/bite04.wav","vj_bms_snark/bite05.wav"}
ENT.SoundTbl_LeapAttackDamageMiss = {"vj_bms_snark/hunt1.wav","vj_bms_snark/hunt2.wav","vj_bms_snark/hunt3.wav","vj_bms_snark/hunt4.wav"}
ENT.SoundTbl_Pain = {"vj_bms_snark/die01.wav","vj_bms_snark/die02.wav","vj_bms_snark/die03.wav","vj_bms_snark/die04.wav"}
ENT.SoundTbl_Death = {"vj_bms_snark/blast1.wav"}

-- Custom
ENT.Snark_Explodes = true
ENT.Snark_NextJumpWalkTime1 = 0.35
ENT.Snark_NextJumpWalkTime2 = 0.8
ENT.Snark_NextJumpWalkT = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(5, 5, 10), Vector(-5, -5, 0))
	//self:PhysicsInitBox(self:GetModelBounds())
	//self.MeleeAttackDamage = math.random(3,5)
	//self.LeapAttackDamage = math.random(3,5)
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_CLIMB))
	self.Snark_EnergyTime = CurTime() + GetConVarNumber("vj_bms_snarkexplodetime")
	if GetConVarNumber("vj_bms_snarkexplode") == 0 then self.Snark_Explodes = false end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	//PrintMessage(HUD_PRINTTALK,"CURTIME: "..CurTime())
	//PrintMessage(HUD_PRINTTALK,self.Snark_EnergyTime)
	if IsValid(self:GetEnemy()) && self.VJ_IsBeingControlled == false && self:IsOnGround() && self:Visible(self:GetEnemy()) && self:GetPos():Distance(self:GetEnemy():GetPos()) > self.LeapDistance + 10 && CurTime() > self.Snark_NextJumpWalkT then
		self:VJ_ACT_PLAYACTIVITY(ACT_GLIDE,false,0.7,true)
		self:SetGroundEntity(NULL)
		self:SetLocalVelocity((self:GetEnemy():GetPos() -self:GetPos()):GetNormal() *500 +self:GetUp() *math.Rand(165,200) +self:GetForward() *math.Rand(180,220))
		self.Snark_NextJumpWalkT = CurTime() + math.Rand(self.Snark_NextJumpWalkTime1,self.Snark_NextJumpWalkTime2)
	end
	if self.Snark_Explodes == true && self.Snark_EnergyTime < CurTime() then
		self:TakeDamage(self:Health(), self, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterChecks(TheHitEntity)
	//PrintMessage(HUD_PRINTTALK,"MELEE")
	self.Snark_EnergyTime = self.Snark_EnergyTime + 0.5
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnLeapAttack_AfterChecks(TheHitEntity)
	self.Snark_EnergyTime = self.Snark_EnergyTime + 0.5
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnKilled(dmginfo,hitgroup)
	if self.HasGibDeathParticles == true then
		local bloodeffect = EffectData()
		bloodeffect:SetOrigin(self:GetPos() +self:OBBCenter())
		bloodeffect:SetColor(VJ.Color2Byte(Color(255,221,35)))
		bloodeffect:SetScale(40)
		util.Effect("VJ_Blood1",bloodeffect)
		
		local bloodspray = EffectData()
		bloodspray:SetOrigin(self:GetPos() +self:OBBCenter())
		bloodspray:SetScale(6)
		bloodspray:SetFlags(3)
		bloodspray:SetColor(1)
		util.Effect("bloodspray",bloodspray)
		util.Effect("bloodspray",bloodspray)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos() +self:OBBCenter())
		effectdata:SetScale(0.4)
		util.Effect("StriderBlood",effectdata)
		util.Effect("StriderBlood",effectdata)
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/