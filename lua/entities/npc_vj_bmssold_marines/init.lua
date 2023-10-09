AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/humans/marine.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want 
ENT.StartHealth = GetConVarNumber("vj_bms_marines_h")
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_UNITED_STATES"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = GetConVarNumber("vj_bms_marines_d")
ENT.FootStepTimeRun = 0.4 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.5 -- Next foot step sound when it is walking
ENT.HasGrenadeAttack = true -- Should the NPC have a grenade attack?
ENT.HasOnPlayerSight = true -- Should do something when it sees the enemy? Example: Play a sound
ENT.OnPlayerSightDistance = 2000 -- How close should the player be until it runs the code?
ENT.OnPlayerSightDispositionLevel = 2 -- 0 = Run it every time | 1 = Run it only when friendly to player | 2 = Run it only when enemy to player
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS} -- If it uses normal based animation, use this
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {"vj_bms_hecu/idle1.wav","vj_bms_hecu/idle2.wav","vj_bms_hecu/idle3.wav","vj_bms_hecu/idle4.wav","vj_bms_hecu/idle5.wav","vj_bms_hecu/idle6.wav","vj_bms_hecu/idle7.wav","vj_bms_hecu/idle8.wav","vj_bms_hecu/idle9.wav","vj_bms_hecu/idle10.wav","vj_bms_hecu/idle11.wav","vj_bms_hecu/idle12.wav","vj_bms_hecu/idle13.wav","vj_bms_hecu/idle14.wav","vj_bms_hecu/idle15.wav","vj_bms_hecu/idle16.wav"}
ENT.SoundTbl_CombatIdle = {"vj_bms_hecu/idle_combat1.wav","vj_bms_hecu/idle_combat2.wav","vj_bms_hecu/idle_combat3.wav","vj_bms_hecu/idle_combat4.wav","vj_bms_hecu/idle_combat5.wav","vj_bms_hecu/idle_combat6.wav"}
ENT.SoundTbl_OnPlayerSight = {"vj_bms_hecu/freeman1.wav","vj_bms_hecu/freeman2.wav","vj_bms_hecu/freeman3.wav"}
ENT.SoundTbl_Alert = {"vj_bms_hecu/alert1.wav","vj_bms_hecu/alert2.wav","vj_bms_hecu/alert3.wav","vj_bms_hecu/alert4.wav","vj_bms_hecu/alert5.wav","vj_bms_hecu/alert6.wav","vj_bms_hecu/alert7.wav","vj_bms_hecu/alert8.wav","vj_bms_hecu/alert9.wav","vj_bms_hecu/alert10.wav"}
ENT.SoundTbl_OnReceiveOrder = {"vj_bms_hecu/answer1.wav","vj_bms_hecu/answer2.wav","vj_bms_hecu/answer3.wav","vj_bms_hecu/answer4.wav","vj_bms_hecu/answer5.wav"}
ENT.SoundTbl_Suppressing = {"vj_bms_hecu/supressing1.wav","vj_bms_hecu/supressing2.wav","vj_bms_hecu/supressing3.wav","vj_bms_hecu/supressing4.wav","vj_bms_hecu/supressing5.wav","vj_bms_hecu/supressing6.wav","vj_bms_hecu/supressing7.wav","vj_bms_hecu/supressing8.wav",}
ENT.SoundTbl_GrenadeAttack = {"vj_bms_hecu/throwgrenade1.wav","vj_bms_hecu/throwgrenade2.wav","vj_bms_hecu/throwgrenade3.wav","vj_bms_hecu/throwgrenade4.wav","vj_bms_hecu/throwgrenade5.wav","vj_bms_hecu/throwgrenade6.wav"}
ENT.SoundTbl_OnGrenadeSight = {"vj_bms_hecu/grenade1.wav","vj_bms_hecu/grenade2.wav","vj_bms_hecu/grenade3.wav","vj_bms_hecu/grenade4.wav","vj_bms_hecu/grenade5.wav","vj_bms_hecu/grenade6.wav","vj_bms_hecu/grenade7.wav","vj_bms_hecu/grenade8.wav","vj_bms_hecu/grenade9.wav"}
ENT.SoundTbl_Pain = {"vj_bms_hecu/pain1.wav","vj_bms_hecu/pain2.wav","vj_bms_hecu/pain3.wav","vj_bms_hecu/pain4.wav","vj_bms_hecu/pain5.wav","vj_bms_hecu/pain6.wav","vj_bms_hecu/pain7.wav","vj_bms_hecu/pain8.wav","vj_bms_hecu/pain9.wav","vj_bms_hecu/pain10.wav"}
ENT.SoundTbl_Death = {"vj_bms_hecu/die1.wav","vj_bms_hecu/die2.wav","vj_bms_hecu/die3.wav","vj_bms_hecu/die4.wav","vj_bms_hecu/die5.wav","vj_bms_hecu/die6.wav"}

ENT.OnPlayerSightSoundChance = 2

-- Custom
ENT.HECU_Beret = false
ENT.HECU_GasMask = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	-- Beret Hat
	if math.random(1, 6) == 1 then
		self.HECU_Beret = true
		self.BeretHat = ents.Create("prop_physics")
		self.BeretHat:SetModel("models/humans/props/marine_beret.mdl")
		self.BeretHat:SetLocalPos(self:GetPos())
		self.BeretHat:SetOwner(self)
		self.BeretHat:SetParent(self)
		//self.BeretHat:SetLocalAngles(Angle(-120,0,90))
		//self.BeretHat:Fire("SetParentAttachmentMaintainOffset","anim_attachment_LH")
		self.BeretHat:Fire("SetParentAttachment","eyes")
		self.BeretHat:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self.BeretHat:Spawn()
		self.BeretHat:Activate()
		self.BeretHat:SetSolid(SOLID_NONE)
		self.BeretHat:AddEffects(EF_BONEMERGE)
	end
	
	self:SetSkin(math.random(0, 14))
	
	self:SetBodygroup(3, math.random(1, 2)) -- Gloves
	self:SetBodygroup(7, math.random(0, 1)) -- Holster
	self:SetBodygroup(8, math.random(0, 1)) -- Pack Chest
	self:SetBodygroup(9, math.random(0, 1)) -- Pack Hips
	self:SetBodygroup(10, math.random(0, 1)) -- Pack Thighs

	if !self.HECU_Beret then
		local randHat = math.random(1, 6)
		if randHat == 1 then -- Medic
			self:SetBodygroup(6, 1)
			self.IsMedicSNPC = true
		elseif randHat == 2 then -- Night vision gas mask
			self:SetBodygroup(4, 1)
			self.HECU_GasMask = true
		elseif randHat == 3 then -- Regular helmet
			self:SetBodygroup(5, 1)
		elseif randHat == 4 then -- Gas mask
			self:SetBodygroup(5, 2)
			self.HECU_GasMask = true
		elseif randHat == 5 then -- Shades
			self:SetBodygroup(5, 3)
		end
	else
		if math.random(1,2) == 1 then self:SetBodygroup(5,3) end
	end

	-- Cigar
	if self.HECU_GasMask == false && math.random(1, (self.HECU_Beret == true and 2) or 4) == 1 then
		self:SetBodygroup(2, 1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnSetupWeaponHoldTypeAnims(hType)
	timer.Simple(0.1, function()
		if IsValid(self) && (hType == "ar2" or hType == "smg" or hType == "rpg") then
			self.WeaponAnimTranslations[ACT_IDLE] = ACT_IDLE
		end
	end)
	return false
end -- return true to disable the base code
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
	if self.HasGibDeathParticles == true then
		local bloodeffect = EffectData()
		bloodeffect:SetOrigin(self:GetPos() +self:OBBCenter())
		bloodeffect:SetColor(VJ.Color2Byte(Color(130,19,10)))
		bloodeffect:SetScale(120)
		util.Effect("VJ_Blood1",bloodeffect)
		
		local bloodspray = EffectData()
		bloodspray:SetOrigin(self:GetPos())
		bloodspray:SetScale(8)
		bloodspray:SetFlags(3)
		bloodspray:SetColor(0)
		util.Effect("bloodspray",bloodspray)
		util.Effect("bloodspray",bloodspray)
	end
	
	self:CreateGibEntity("obj_vj_gib","models/gibs/humans/brain_gib.mdl",{Pos=self:LocalToWorld(Vector(0,0,68)),Ang=self:GetAngles()+Angle(0,-90,0)})
	self:CreateGibEntity("obj_vj_gib","models/gibs/humans/eye_gib.mdl",{Pos=self:LocalToWorld(Vector(0,0,65)),Ang=self:GetAngles()+Angle(0,-90,0),Vel=self:GetRight()*math.Rand(150,250)+self:GetForward()*math.Rand(-200,200)})
	self:CreateGibEntity("obj_vj_gib","models/gibs/humans/eye_gib.mdl",{Pos=self:LocalToWorld(Vector(0,3,65)),Ang=self:GetAngles()+Angle(0,-90,0),Vel=self:GetRight()*math.Rand(-150,-250)+self:GetForward()*math.Rand(-200,200)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/humans/marines/torso.mdl",{Pos=self:LocalToWorld(Vector(0,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-100,100)+self:GetForward()*math.Rand(-100,100)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/humans/marines/right_leg.mdl",{Pos=self:LocalToWorld(Vector(0,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(100,250)+self:GetForward()*math.Rand(-300,300)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/humans/marines/left_leg.mdl",{Pos=self:LocalToWorld(Vector(0,0,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-100,-250)+self:GetForward()*math.Rand(-300,300)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/humans/marines/right_arm.mdl",{Pos=self:LocalToWorld(Vector(0,-5,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(150,250)+self:GetForward()*math.Rand(-200,200)})
	self:CreateGibEntity("prop_ragdoll","models/gibs/humans/marines/left_arm.mdl",{Pos=self:LocalToWorld(Vector(0,5,0)),Ang=self:GetAngles(),Vel=self:GetRight()*math.Rand(-150,-250)+self:GetForward()*math.Rand(-200,200)})
	self:CreateGibEntity("obj_vj_gib","UseHuman_Small",{Pos=self:LocalToWorld(Vector(0,0,30))})
	self:CreateGibEntity("obj_vj_gib","UseHuman_Small",{Pos=self:LocalToWorld(Vector(0,0,31))})
	self:CreateGibEntity("obj_vj_gib","UseHuman_Small",{Pos=self:LocalToWorld(Vector(0,0,32))})
	self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos=self:LocalToWorld(Vector(0,0,40))})
	self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos=self:LocalToWorld(Vector(0,0,35))})
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo,hitgroup,GetCorpse)
	if self:GetBodygroup(2) == 1 then
		GetCorpse:SetBodygroup(2,0)
		self:CreateExtraDeathCorpse("prop_physics","models/humans/props/marine_cigar.mdl",{Pos=self:LocalToWorld(Vector(0,0,-5))})
	end
	if self.HECU_Beret == true then
		self:CreateExtraDeathCorpse("prop_physics","models/humans/props/marine_beret.mdl",{Pos=self:LocalToWorld(Vector(0,0,-2))})
	end
end