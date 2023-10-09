AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/zombies/zombie_grunt.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_bms_zecu_h")
ENT.HullType = HULL_WIDE_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackDistance = 32 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 80 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.6 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 0.4 -- How much time until it can use any attack again? | Counted in Seconds
ENT.MeleeAttackDamage = GetConVarNumber("vj_bms_zecu_d")
ENT.FootStepTimeRun = 1 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS} -- If it uses normal based animation, use this
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_bms_zombies/foot1.wav","vj_bms_zombies/foot2.wav","vj_bms_zombies/foot3.wav"}
ENT.SoundTbl_Idle = {"vj_bms_zombies/idle1.wav","vj_bms_zombies/idle2.wav","vj_bms_zombies/idle3.wav","vj_bms_zombies/idle4.wav","vj_bms_zombies/idle5.wav","vj_bms_zombies/idle6.wav"}
ENT.SoundTbl_Alert = {"vj_bms_zombies/alert1.wav","vj_bms_zombies/alert2.wav","vj_bms_zombies/alert3.wav","vj_bms_zombies/alert4.wav","vj_bms_zombies/alert5.wav","vj_bms_zombies/alert6.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_bms_zombies/attack01.wav","vj_bms_zombies/attack02.wav","vj_bms_zombies/attack03.wav","vj_bms_zombies/attack04.wav","vj_bms_zombies/attack05.wav","vj_bms_zombies/attack06.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_bms_zombies/claw_miss1.wav","vj_bms_zombies/claw_miss2.wav"}
ENT.SoundTbl_Pain = {"vj_bms_zombies/pain1.wav","vj_bms_zombies/pain2.wav","vj_bms_zombies/pain3.wav","vj_bms_zombies/pain4.wav","vj_bms_zombies/pain5.wav","vj_bms_zombies/pain7.wav","vj_bms_zombies/pain8.wav","vj_bms_zombies/pain9.wav","vj_bms_zombies/pain10.wav"} /*,"vj_bms_zombies/pain6.wav"*/
ENT.SoundTbl_Death = {"vj_bms_zombies/die1.wav","vj_bms_zombies/die2.wav","vj_bms_zombies/die3.wav","vj_bms_zombies/die4.wav","vj_bms_zombies/die5.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if self:IsOnFire() then
		self.AnimTbl_Walk = {ACT_WALK_ON_FIRE}
		self.AnimTbl_Run = {ACT_WALK_ON_FIRE}
		self.AnimTbl_IdleStand = {ACT_IDLE_ON_FIRE}
	else
		self.AnimTbl_Walk = {ACT_WALK}
		self.AnimTbl_Run = {ACT_RUN}
		self.AnimTbl_IdleStand = {ACT_IDLE}
	end
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
	
	self:CreateGibEntity("prop_ragdoll","models/gibs/zombies/zombie_grunt/torso.mdl",{Pos=self:LocalToWorld(Vector(0,0,2)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-100,100)+self:GetForward()*math.Rand(-100,100)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/zombies/zombie_grunt/legs.mdl",{Pos=self:LocalToWorld(Vector(0,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-100,100)+self:GetForward()*math.Rand(-50,50)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/zombies/zombie_grunt/right_arm.mdl",{Pos=self:LocalToWorld(Vector(0,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(150,250)+self:GetForward()*math.Rand(-200,200)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/zombies/zombie_grunt/left_arm.mdl",{Pos=self:LocalToWorld(Vector(0,-3,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-150,-250)+self:GetForward()*math.Rand(-200,200)})
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo,hitgroup,GetCorpse)
	if self:GetBodygroup(1) == 1 then return false end
	local randcrab = math.random(1,3)
	local dmgtype = dmginfo:GetDamageType()
	if hitgroup == HITGROUP_HEAD then randcrab = math.random(1,2) end
	if dmgtype == DMG_CLUB or dmgtype == DMG_SLASH then randcrab = 1 end
	if randcrab == 1 then
		self:SetBodygroup(1,0)
	end
	if randcrab == 2 then
		self:CreateExtraDeathCorpse("prop_ragdoll","models/VJ_BLACKMESA/headcrab.mdl",{Pos=self:GetAttachment(self:LookupAttachment("headcrab")).Pos})
		self.Corpse:SetBodygroup(1,1)
	end
	if randcrab == 3 then
		self.Corpse:SetBodygroup(1,1)
		local spawncrab = ents.Create("npc_headcrab")
		local enemy = self:GetEnemy()
		local pos = self:GetAttachment(self:LookupAttachment("headcrab")).Pos
		spawncrab:SetPos(pos)
		spawncrab:SetAngles(self:GetAngles())
		spawncrab:SetVelocity(dmginfo:GetDamageForce()/58)
		spawncrab:Spawn()
		spawncrab:Activate()
		if self.Corpse:IsOnFire() then spawncrab:Ignite(math.Rand(8,10),0) end
		timer.Simple(0.05,function()
			spawncrab:SetPos(pos)
			if IsValid(enemy) then spawncrab:SetEnemy(enemy) spawncrab:SetSchedule(SCHED_CHASE_ENEMY) end
		end)
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/