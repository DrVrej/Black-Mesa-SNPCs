AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/zombies/zombie_sci_torso.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_bms_zscientist_torso_h")
ENT.HullType = HULL_TINY
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackDistance = 15 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 65 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.4 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 0.44 -- How much time until it can use any attack again? | Counted in Seconds
ENT.MeleeAttackDamage = GetConVarNumber("vj_bms_zscientist_torso_d")
ENT.FootStepTimeRun = 0.6 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.6 -- Next foot step sound when it is walking
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
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
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(20, 20 , 26), Vector(-20, -20, 0))
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
		self:CreateExtraDeathCorpse("prop_ragdoll","models/VJ_BLACKMESA/headcrab.mdl",{Pos=self:GetAttachment(self:LookupAttachment("head")).Pos,Ang=self:GetAttachment(self:LookupAttachment("head")).Ang})
		self.Corpse:SetBodygroup(1,1)
	end
	if randcrab == 3 then
		self.Corpse:SetBodygroup(1,1)
		local spawncrab = ents.Create("npc_headcrab")
		local enemy = self:GetEnemy()
		local pos = self:GetAttachment(self:LookupAttachment("head")).Pos
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