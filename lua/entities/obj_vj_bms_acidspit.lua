/*--------------------------------------------------
	*** Copyright (c) 2012-2025 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "obj_vj_projectile_base"
ENT.PrintName		= "Acid"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Information		= "Projectile, usually used for NPCs & Weapons"
ENT.Category		= "Projectiles"

if (CLIENT) then
	local Name = "Acid"
	local LangName = "obj_vj_bms_acidspit"
	language.Add(LangName, Name)
	killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
	language.Add("#"..LangName, Name)
	killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = {"models/vj_base/projectiles/spit_acid_small.mdl", "models/vj_base/projectiles/spit_acid_medium.mdl"} -- Model(s) to spawn with | Picks a random one if it's a table
ENT.ProjectileType = VJ.PROJ_TYPE_GRAVITY
ENT.DoesRadiusDamage = true -- Should it deal radius damage when it collides with something?
ENT.RadiusDamageRadius = 70
ENT.RadiusDamage = 3
ENT.RadiusDamageUseRealisticRadius = true -- Should the damage decrease the farther away the hit entity is from the radius origin?
ENT.RadiusDamageType = DMG_ACID
ENT.CollisionDecals = "VJ_AcidSlime1"
ENT.SoundTbl_Idle = "vj_base/ambience/acid_idle.wav"
ENT.SoundTbl_OnCollide = "vj_base/ambience/acid_splat.wav"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	ParticleEffectAttach("vj_acid_idle", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	ParticleEffectAttach("vj_acid_impact1", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defAng = Angle(0, 0, 0)
--
function ENT:OnDestroy(data,phys)
	local effectData = EffectData()
	effectData:SetOrigin(data.HitPos)
	effectData:SetScale(1)
	util.Effect("StriderBlood", effectData)
	util.Effect("StriderBlood", effectData)
	util.Effect("StriderBlood", effectData)
	ParticleEffect("vj_acid_impact3_floaters", data.HitPos, defAng)
	ParticleEffect("vj_acid_impact2_juice", data.HitPos, defAng)
end