AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2025 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/VJ_BLACKMESA/sentry_ground.mdl"
ENT.StartHealth = 100
ENT.HullType = HULL_HUMAN
ENT.SightDistance = 1300
ENT.MovementType = VJ_MOVETYPE_STATIONARY
ENT.CanTurnWhileStationary = false
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_UNITED_STATES"}
ENT.AlertTimeout = VJ.SET(8, 8)
ENT.HasMeleeAttack = false

ENT.HasRangeAttack = true
ENT.DisableDefaultRangeAttackCode = true
ENT.AnimTbl_RangeAttack = false
ENT.AnimTbl_RangeAttack = "fire"
ENT.RangeAttackMaxDistance = 1300
ENT.RangeAttackMinDistance = 1
ENT.RangeAttackAngleRadius = 100
ENT.TimeUntilRangeAttackProjectileRelease = 0.1
ENT.RangeAttackReps = 3
ENT.NextRangeAttackTime = 0
ENT.NextAnyAttackTime_Range = 0.3

ENT.SoundTbl_Alert = {"vj_bms_groundturret/deploy.wav"}
ENT.SoundTbl_Impact = {"ambient/energy/spark1.wav","ambient/energy/spark2.wav","ambient/energy/spark3.wav","ambient/energy/spark4.wav"}
ENT.SoundTbl_Death = {"vj_bms_groundturret/die.wav"}

ENT.AlertSoundLevel = 75

-- Custom
ENT.HECUTurret_StandDown = true
ENT.HECUTurret_CurrentParameter = 0
ENT.HECUTurret_NextAlarmT = 0
ENT.HECUTurret_AnimIdleAngry = ACT_INVALID
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(13, 13, 60), Vector(-13, -13, 0))
	self.HECUTurret_AnimIdleAngry = VJ.SequenceToActivity(self, "idl")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_IDLE && (self:GetNPCState() == NPC_STATE_ALERT or self:GetNPCState() == NPC_STATE_COMBAT or !self.HECUTurret_StandDown) then
		return self.HECUTurret_AnimIdleAngry
	end
	return self.BaseClass.TranslateActivity(self, act)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	local parameter = self:GetPoseParameter("aim_yaw")
	if parameter != self.HECUTurret_CurrentParameter then
		self.HECUTurret_TurningSD = CreateSound(self, "vj_bms_groundturret/motor_loop.wav")
		self.HECUTurret_TurningSD:SetSoundLevel(70)
		self.HECUTurret_TurningSD:PlayEx(1,100)
	else
		VJ.STOPSOUND(self.HECUTurret_TurningSD)
	end
	self.HECUTurret_CurrentParameter = parameter
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	local ene = self:GetEnemy()
	if IsValid(ene) or (self:GetNPCState() == NPC_STATE_ALERT or self:GetNPCState() == NPC_STATE_COMBAT) then
		self.HECUTurret_StandDown = false
		local glow = ents.Create("env_sprite")
		glow:SetKeyValue("model","vj_base/sprites/glow.vmt")
		glow:SetKeyValue("scale","0.04")
		glow:SetKeyValue("rendermode","5")
		glow:SetKeyValue("rendercolor","255 0 0")
		glow:SetKeyValue("spawnflags","1") -- If animated
		glow:SetParent(self)
		glow:Fire("SetParentAttachment","laser",0)
		glow:Spawn()
		glow:Activate()
		glow:Fire("Kill","",0.1)
		self:DeleteOnRemove(glow)
		
		if CurTime() > self.HECUTurret_NextAlarmT then
			glow = ents.Create("env_sprite")
			glow:SetKeyValue("model","vj_base/sprites/glow.vmt")
			glow:SetKeyValue("scale","0.1")
			glow:SetKeyValue("rendermode","5")
			glow:SetKeyValue("rendercolor","255 0 0")
			glow:SetKeyValue("spawnflags","1") -- If animated
			glow:SetParent(self)
			glow:Fire("SetParentAttachment","alarm",0)
			glow:Spawn()
			glow:Activate()
			glow:Fire("Kill","",0.1)
			self:DeleteOnRemove(glow)
			self.HECUTurret_NextAlarmT = CurTime() + 3
			VJ.EmitSound(self, "vj_bms_groundturret/ping.wav", 75, 100)
		end
		
		if IsValid(ene) && self:CustomAttackCheck_RangeAttack() == true && (self.AttackType == VJ.ATTACK_TYPE_RANGE or self.EnemyData.Visible) then
			self:SetSkin(0)
		else
			self:SetSkin(1)
		end
	else
		if self:GetNPCState() != NPC_STATE_ALERT && self:GetNPCState() != NPC_STATE_COMBAT then
			self:SetSkin(0)
			if self.HECUTurret_StandDown == false then
				self.HECUTurret_StandDown = true
				self:PlayAnim({"retract"},true,1)
				VJ.EmitSound(self, "vj_bms_groundturret/retract.wav", 65, math.random(100, 110))
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomAttackCheck_RangeAttack()
	local viewcode = ((self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter()) - (self:GetPos() + self:OBBCenter())):Angle()
	local viewang = math.abs(viewcode.y - (self:GetAngles().y + self:GetPoseParameter("aim_yaw")))
	if viewang >= 330 then viewang = viewang - 360 end
	if math.abs(viewang) <= 10 then return true end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	self:PlayAnim("deploy", true, 0.7)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomRangeAttackCode()
	local spawnPos = self:GetAttachment(self:LookupAttachment("muzzle")).Pos
	
	local bullet = {}
	bullet.Num = 1
	bullet.Src = spawnPos
	bullet.Dir = (self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter()) - spawnPos
	bullet.Spread = 0.001
	bullet.Tracer = 1
	bullet.TracerName = "Tracer"
	bullet.Force = 5
	bullet.Damage = 3
	bullet.AmmoType = "SMG1"
	self:FireBullets(bullet)
	
	VJ.EmitSound(self, "vj_bms_groundturret/single.wav", 90, math.random(100, 110))
	
	ParticleEffectAttach("vj_bms_turret_full", PATTACH_POINT_FOLLOW, self, 2)
	timer.Simple(0.2, function() if IsValid(self) then self:StopParticles() end end)
	
	local dynLight = ents.Create("light_dynamic")
	dynLight:SetKeyValue("brightness", "4")
	dynLight:SetKeyValue("distance", "120")
	dynLight:SetPos(spawnPos)
	dynLight:SetLocalAngles(self:GetAngles())
	dynLight:Fire("Color", "255 150 60")
	dynLight:SetParent(self)
	dynLight:Spawn()
	dynLight:Activate()
	dynLight:Fire("TurnOn")
	dynLight:Fire("Kill", "", 0.07)
	self:DeleteOnRemove(dynLight)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Finish" then
		self:SetSkin(3)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defAng = Angle(0, 0, 0)
--
function ENT:OnCreateDeathCorpse(dmginfo, hitgroup, corpseEnt)
	local spawnPos = corpseEnt:GetAttachment(corpseEnt:LookupAttachment("smoke")).Pos
	ParticleEffectAttach("smoke_exhaust_01a",PATTACH_POINT_FOLLOW,corpseEnt,4)
	ParticleEffect("explosion_turret_break_fire", spawnPos, defAng, corpseEnt)
	ParticleEffect("explosion_turret_break_flash", spawnPos, defAng, corpseEnt)
	ParticleEffect("explosion_turret_break_pre_smoke Version #2", spawnPos, defAng, corpseEnt)
	ParticleEffect("explosion_turret_break_sparks", spawnPos, defAng, corpseEnt)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	VJ.STOPSOUND(self.HECUTurret_TurningSD)
end