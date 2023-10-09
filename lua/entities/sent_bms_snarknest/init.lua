AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Dead = false

local defVec = Vector(0, 0, 0)
local defAng = Angle(0, 0, 0)
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/VJ_BLACKMESA/snarknest.mdl")
	self:SetHealth(10)
	self:SetHullType(HULL_TINY)
	self:SetHullSizeNormal()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTakeDamage(dmginfo,data)
	self:SpawnBloodParticles(dmginfo)
	self:SpawnBloodDecal(dmginfo)
	self:EmitSound("vj_flesh/alien_flesh1.wav",80,math.random(80,100))
	
	self:SetHealth(self:Health() -dmginfo:GetDamage())
	if self:Health() <= 0 && !self.Dead then
		self.Dead = true
		self:SetHealth(self:GetMaxHealth())
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos() + defVec)
		effectdata:SetScale(0.6)
		util.Effect("StriderBlood",effectdata)
		util.Effect("StriderBlood",effectdata)
		ParticleEffect("antlion_spit",self:GetPos(),defAng,nil)
		
		for _ = 1, 8 do
			local ent = ents.Create("npc_vj_bmsno_snark")
			ent:SetPos(self:GetPos())
			ent:SetAngles(defAng)
			ent:SetVelocity(self:GetUp()*math.Rand(250,350) + self:GetRight()*math.Rand(-100,100) + self:GetForward()*math.Rand(-100,100))
			ent:Spawn()
			ent:Activate()
		end
		self:Remove()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnBloodParticles(dmginfo,hitgroup)
	local DamagePos = dmginfo:GetDamagePosition()
	if DamagePos == defVec then DamagePos = self:GetPos() + self:OBBCenter() end

	local bloodeffect = ents.Create("info_particle_system")
	bloodeffect:SetKeyValue("effect_name", "blood_impact_yellow_01")
	bloodeffect:SetPos(DamagePos) 
	bloodeffect:Spawn()
	bloodeffect:Activate() 
	bloodeffect:Fire("Start","",0)
	bloodeffect:Fire("Kill","",0.1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnBloodDecal(dmginfo,hitgroup)
	local force = dmginfo:GetDamageForce()
	local length = math.Clamp(force:Length() *10, 100, 300)
	local paint = tobool(math.random(0, math.Round(length *0.125)) <= 1000)
	if !paint then return end
	local posStart = dmginfo:GetDamagePosition()
	local posEnd = posStart +force:GetNormal() *length
	local tr = util.TraceLine({start = posStart, endpos = posEnd, filter = self})
	if !tr.HitWorld then return end
	util.Decal("VJ_Blood_Red",tr.HitPos +tr.HitNormal,tr.HitPos -tr.HitNormal)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/