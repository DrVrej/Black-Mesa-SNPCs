/*--------------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "obj_vj_projectile_base"
ENT.PrintName		= "Hornet"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Information		= "Projectiles for my addons"
ENT.Category		= "Projectiles"

if (CLIENT) then
	local Name = "Hornet"
	local LangName = "obj_bms_hornet"
	language.Add(LangName, Name)
	killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
	language.Add("#"..LangName, Name)
	killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = {"models/weapons/w_hornet.mdl"} -- The models it should spawn with | Picks a random one from the table
ENT.MoveCollideType = MOVECOLLIDE_FLY_BOUNCE
ENT.RemoveOnHit = false -- Should it remove itself when it touches something? | It will run the hit sound, place a decal, etc.
ENT.DoesDirectDamage = true -- Should it do a direct damage when it hits something?
ENT.DirectDamage = 3.5 -- How much damage should it do when it hits something
ENT.DirectDamageType = DMG_SLASH -- Damage type
ENT.CollideCodeWithoutRemoving = true -- If RemoveOnHit is set to false, you can still make the projectile deal damage, place a decal, etc.
ENT.DecalTbl_DeathDecals = {"YellowBlood"}
ENT.DecalTbl_OnCollideDecals = {"YellowBlood"} -- Decals that paint when the projectile collides with something | It picks a random one from this table
ENT.SoundTbl_Startup = {"vj_bms_hornet/single.wav"}
ENT.SoundTbl_Idle = {"vj_bms_hornet/buzz.wav"}
ENT.SoundTbl_OnCollide = {"vj_bms_hornet/bug_impact.wav"}

ENT.IdleSoundPitch = VJ.SET(100, 100)

-- Custom
ENT.MyEnemy = NULL
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomPhysicsObjectOnInitialize(phys)
	phys:Wake()
	phys:SetMass(1)
	phys:SetBuoyancyRatio(0)
	phys:EnableDrag(false)
	phys:EnableGravity(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	timer.Simple(5,function() if IsValid(self) then self:Remove() end end)
	
	util.SpriteTrail(self, 0, Color(255,math.random(50,200),0,120), true, 12, 0, 1, 0.04, "sprites/vj_bms_hornettrail.vmt")

	local sprite = ents.Create( "env_sprite" )
	sprite:SetKeyValue( "rendercolor","255 128 0" )
	sprite:SetKeyValue( "GlowProxySize","2.0" )
	sprite:SetKeyValue( "HDRColorScale","1.0" )
	sprite:SetKeyValue( "renderfx","14" )
	sprite:SetKeyValue( "rendermode","3" )
	sprite:SetKeyValue( "renderamt","240" )
	sprite:SetKeyValue( "disablereceiveshadows","0" )
	sprite:SetKeyValue( "mindxlevel","0" )
	sprite:SetKeyValue( "maxdxlevel","0" )
	sprite:SetKeyValue( "framerate","10.0" )
	sprite:SetKeyValue( "model","sprites/blueflare1.spr" )
	sprite:SetKeyValue( "spawnflags","0" )
	sprite:SetKeyValue( "scale","0.60" )
	sprite:SetPos( self:GetPos() )
	sprite:Spawn()
	sprite:SetParent(self)
	self:DeleteOnRemove(sprite)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if IsValid(self.MyEnemy) then -- Homing Behavior
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(self:CalculateProjectile("Line", self:GetPos(), self.MyEnemy:GetPos() + self.MyEnemy:OBBCenter() + self.MyEnemy:GetUp()*math.random(-50,50) + self.MyEnemy:GetRight()*math.random(-50,50), 600))
			self:SetAngles(self:GetVelocity():GetNormal():Angle())
		end
	else
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(self:CalculateProjectile("Line", self:GetPos(), self:GetPos() + self:GetForward()*math.random(-80, 80)+ self:GetRight()*math.random(-80, 80) + self:GetUp()*math.random(-80, 80), 300))
			self:SetAngles(self:GetVelocity():GetNormal():Angle())
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDoDamage(data,phys,hitent)
	if data.HitEntity:IsNPC() or data.HitEntity:IsPlayer() then
		self:SetDeathVariablesTrue(data,phys)
		self:Remove()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPhysicsCollide(data, phys)
	local lastvel = math.max(data.OurOldVelocity:Length(), data.Speed) -- Get the last velocity and speed
	local newvel = phys:GetVelocity():GetNormal()
	lastvel = math.max(newvel:Length(), lastvel)
	local setvel = newvel * lastvel * 0.3
	phys:SetVelocity(setvel)
	self:SetAngles(self:GetVelocity():GetNormal():Angle())
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeathEffects(data,phys)
	local effectdata = EffectData()
	effectdata:SetOrigin(data.HitPos)
	effectdata:SetScale( 0.6 )
	util.Effect("StriderBlood",effectdata)
	ParticleEffect("antlion_gib_02_floaters", data.HitPos, Angle(0,0,0), nil)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/