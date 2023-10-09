AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_BLACKMESA/sentry_ground.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_bms_turret_h")
ENT.HullType = HULL_HUMAN
ENT.SightDistance = 1300 -- How far it can see
ENT.MovementType = VJ_MOVETYPE_STATIONARY -- How does the SNPC move?
ENT.CanTurnWhileStationary = false -- If set to true, the SNPC will be able to turn while it's a stationary SNPC
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_UNITED_STATES"} -- NPCs with the same class with be allied to each other
ENT.AlertedToIdleTime = VJ.SET(8, 8) -- How much time until it calms down after the enemy has been killed/disappeared | Sets self.Alerted to false after the timer expires
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.DisableDefaultRangeAttackCode = true -- When true, it won't spawn the range attack entity, allowing you to make your own
ENT.DisableRangeAttackAnimation = true -- if true, it will disable the animation code
ENT.AnimTbl_RangeAttack = {"fire"} -- Range Attack Animations
ENT.RangeDistance = 1300 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 1 -- How close does it have to be until it uses melee?
ENT.RangeAttackAngleRadius = 100 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.TimeUntilRangeAttackProjectileRelease = 0.1 -- How much time until the projectile code is ran?
ENT.RangeAttackReps = 3 -- How many times does it run the projectile code?
ENT.NextRangeAttackTime = 0 -- How much time until it can use a range attack?
ENT.NextAnyAttackTime_Range = 0.3 -- How much time until it can use any attack again? | Counted in Seconds
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Alert = {"vj_bms_groundturret/deploy.wav"}
ENT.SoundTbl_Impact = {"ambient/energy/spark1.wav","ambient/energy/spark2.wav","ambient/energy/spark3.wav","ambient/energy/spark4.wav"}
ENT.SoundTbl_Death = {"vj_bms_groundturret/die.wav"}

ENT.AlertSoundLevel = 75

ENT.VJTag_ID_Turret = true

-- Custom
ENT.HECUTurret_StandDown = true
ENT.HECUTurret_CurrentParameter = 0
ENT.HECUTurret_NextAlarmT = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(13, 13, 60), Vector(-13, -13, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	local parameter = self:GetPoseParameter("aim_yaw")
	if parameter != self.HECUTurret_CurrentParameter then
		self.hecuturret_turningsd = CreateSound(self, "vj_bms_groundturret/motor_loop.wav")
		self.hecuturret_turningsd:SetSoundLevel(70)
		self.hecuturret_turningsd:PlayEx(1,100)
	else
		VJ.STOPSOUND(self.hecuturret_turningsd)
	end
	self.HECUTurret_CurrentParameter = parameter
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	local ene = self:GetEnemy()
	if IsValid(ene) or self.Alerted then
		self.HECUTurret_StandDown = false
		self.AnimTbl_IdleStand = {"idl"}
		local glow = ents.Create("env_sprite")
		glow:SetKeyValue("model","vj_base/sprites/vj_glow1.vmt")
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
			glow:SetKeyValue("model","vj_base/sprites/vj_glow1.vmt")
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
		
		if IsValid(ene) && self:CustomAttackCheck_RangeAttack() == true && (self.AttackType == VJ.ATTACK_TYPE_RANGE or self.EnemyData.IsVisible) then
			self:SetSkin(0)
		else
			self:SetSkin(1)
		end
	else
		if self.Alerted == false then
			self:SetSkin(0)
			if self.HECUTurret_StandDown == false then
				self.HECUTurret_StandDown = true
				self:VJ_ACT_PLAYACTIVITY({"retract"},true,1)
				VJ.EmitSound(self, "vj_bms_groundturret/retract.wav", 65, self:VJ_DecideSoundPitch(100,110))
			end
		end
		if self.HECUTurret_StandDown == true then
			self.AnimTbl_IdleStand = {"idle"}
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
function ENT:CustomOnAlert()
	//self.NextResetEnemyT = CurTime() + 0.7
	self:VJ_ACT_PLAYACTIVITY("deploy", true, 0.7)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomRangeAttackCode()
	local bullet = {}
	bullet.Num = 1
	bullet.Src = self:GetAttachment(self:LookupAttachment("muzzle")).Pos
	bullet.Dir = (self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter())-self:GetAttachment(self:LookupAttachment("muzzle")).Pos
	bullet.Spread = 0.001
	bullet.Tracer = 1
	bullet.TracerName = "Tracer"
	bullet.Force = 5
	bullet.Damage = GetConVarNumber("vj_bms_turret_d")
	bullet.AmmoType = "SMG1"
	self:FireBullets(bullet)
	
	VJ.EmitSound(self,{"vj_bms_groundturret/single.wav"},90,self:VJ_DecideSoundPitch(100,110))
	
	ParticleEffectAttach("vj_bms_turret_full",PATTACH_POINT_FOLLOW,self,2)
	timer.Simple(0.2,function() if IsValid(self) then self:StopParticles() end end)
	
	local FireLight1 = ents.Create("light_dynamic")
	FireLight1:SetKeyValue("brightness", "4")
	FireLight1:SetKeyValue("distance", "120")
	FireLight1:SetPos(self:GetAttachment(self:LookupAttachment("muzzle")).Pos)
	FireLight1:SetLocalAngles(self:GetAngles())
	FireLight1:Fire("Color", "255 150 60")
	FireLight1:SetParent(self)
	FireLight1:Spawn()
	FireLight1:Activate()
	FireLight1:Fire("TurnOn","",0)
	FireLight1:Fire("Kill","",0.07)
	self:DeleteOnRemove(FireLight1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo,hitgroup)
	self:SetSkin(3)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo,hitgroup,GetCorpse)
	ParticleEffectAttach("smoke_exhaust_01a",PATTACH_POINT_FOLLOW,GetCorpse,4)
	ParticleEffect("explosion_turret_break_fire", GetCorpse:GetAttachment(GetCorpse:LookupAttachment("smoke")).Pos, Angle(0,0,0), GetCorpse)
	ParticleEffect("explosion_turret_break_flash", GetCorpse:GetAttachment(GetCorpse:LookupAttachment("smoke")).Pos, Angle(0,0,0), GetCorpse)
	ParticleEffect("explosion_turret_break_pre_smoke Version #2", GetCorpse:GetAttachment(GetCorpse:LookupAttachment("smoke")).Pos, Angle(0,0,0), GetCorpse)
	ParticleEffect("explosion_turret_break_sparks", GetCorpse:GetAttachment(GetCorpse:LookupAttachment("smoke")).Pos, Angle(0,0,0), GetCorpse)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	VJ.STOPSOUND(self.hecuturret_turningsd)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/