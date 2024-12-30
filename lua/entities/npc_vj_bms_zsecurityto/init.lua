AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/zombies/zombie_guard_torso.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 50
ENT.HullType = HULL_TINY
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 30 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 50 -- How far does the damage go | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 25

ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound Paths ====== --
ENT.SoundTbl_FootStep = {"vj_bms_zombies/foot1.wav","vj_bms_zombies/foot2.wav","vj_bms_zombies/foot3.wav"}
ENT.SoundTbl_Idle = {"vj_bms_zombies/idle1.wav","vj_bms_zombies/idle2.wav","vj_bms_zombies/idle3.wav","vj_bms_zombies/idle4.wav","vj_bms_zombies/idle5.wav","vj_bms_zombies/idle6.wav"}
ENT.SoundTbl_Alert = {"vj_bms_zombies/alert1.wav","vj_bms_zombies/alert2.wav","vj_bms_zombies/alert3.wav","vj_bms_zombies/alert4.wav","vj_bms_zombies/alert5.wav","vj_bms_zombies/alert6.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_bms_zombies/attack01.wav","vj_bms_zombies/attack02.wav","vj_bms_zombies/attack03.wav","vj_bms_zombies/attack04.wav","vj_bms_zombies/attack05.wav","vj_bms_zombies/attack06.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_bms_zombies/claw_miss1.wav","vj_bms_zombies/claw_miss2.wav"}
ENT.SoundTbl_Pain = {"vj_bms_zombies/pain1.wav","vj_bms_zombies/pain2.wav","vj_bms_zombies/pain3.wav","vj_bms_zombies/pain4.wav","vj_bms_zombies/pain5.wav","vj_bms_zombies/pain7.wav","vj_bms_zombies/pain8.wav","vj_bms_zombies/pain9.wav","vj_bms_zombies/pain10.wav"} /*,"vj_bms_zombies/pain6.wav"*/
ENT.SoundTbl_Death = {"vj_bms_zombies/die1.wav","vj_bms_zombies/die2.wav","vj_bms_zombies/die3.wav","vj_bms_zombies/die4.wav","vj_bms_zombies/die5.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(20, 20 , 26), Vector(-20, -20, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
local getEventName = util.GetAnimEventNameByID
--
function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	local eventName = getEventName(ev)
	if eventName == "AE_ZOMBIE_STEP_LEFT" or eventName == "AE_ZOMBIE_STEP_RIGHT" then
		self:FootStepSoundCode()
	elseif eventName == "AE_ZOMBIE_ATTACK_LEFT" then
		self:MeleeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateDeathCorpse(dmginfo,  hitgroup,  corpseEnt)
	if self:GetBodygroup(1) == 1 then return false end -- Only continue if crab bodygroup is set
	local spawnType = math.random(1, 3)
	local dmgType = dmginfo:GetDamageType()
	if hitgroup == HITGROUP_HEAD then spawnType = math.random(1, 2) end
	if bit.band(dmgType, DMG_CLUB) != 0 or bit.band(dmgType, DMG_SLASH) != 0 then spawnType = 1 end -- Crab stays on if it's melee
	if spawnType == 1 then -- Crab stays on
		self:SetBodygroup(1, 0)
	elseif spawnType == 2 then -- Dead crab spawns
		self:CreateExtraDeathCorpse("prop_ragdoll", "models/VJ_BLACKMESA/headcrab.mdl", {Pos=self:GetAttachment(self:LookupAttachment("head")).Pos, Ang=self:GetAttachment(self:LookupAttachment("head")).Ang})
		corpseEnt:SetBodygroup(1, 1)
	elseif spawnType == 3 then -- Alive crab spawns
		corpseEnt:SetBodygroup(1, 1)
		local crab = ents.Create("npc_headcrab")
		local enemy = self:GetEnemy()
		local pos = self:GetAttachment(self:LookupAttachment("head")).Pos
		crab:SetPos(pos)
		crab:SetAngles(self:GetAngles())
		crab:SetVelocity(dmginfo:GetDamageForce() / 58)
		crab:Spawn()
		crab:Activate()
		if corpseEnt:IsOnFire() then crab:Ignite(math.Rand(8, 10), 0) end
		timer.Simple(0.05, function()
			if IsValid(crab) then
				crab:SetPos(pos)
				if IsValid(enemy) then
					crab:SetEnemy(enemy)
					crab:SetSchedule(SCHED_CHASE_ENEMY)
				end
			end
		end)
	end
end