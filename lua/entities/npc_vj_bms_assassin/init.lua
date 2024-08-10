AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/VJ_BLACKMESA/hassassin.mdl" -- Model(s) to spawn with | Picks a random one if it's a table 
ENT.StartHealth = 50
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_BLACKOPS"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1 -- Melee Attack Animations
ENT.MeleeAttackDamage = 10
ENT.MeleeAttackDistance = 35 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 70 -- How far does the damage go | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.TimeUntilMeleeAttackDamage = 0.3 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 0.5 -- How much time until it can use any attack again? | Counted in Seconds

ENT.AnimTbl_WeaponAttack = ACT_RANGE_ATTACK_PISTOL
ENT.CanCrouchOnWeaponAttack = false -- Can it crouch while shooting?
ENT.Weapon_NoSpawnMenu = true -- If set to true, the NPC weapon setting in the spawnmenu will not be applied for this SNPC
ENT.WeaponSpread = 0.9 -- What's the spread of the weapon? | Closer to 0 = better accuracy, Farther than 1 = worse accuracy
ENT.CallForBackUpOnDamage = false -- Should the SNPC call for help when damaged? (Only happens if the SNPC hasn't seen a enemy)
ENT.BringFriendsOnDeath = false -- Should the NPC's allies come to its position while it's dying?
ENT.MoveOrHideOnDamageByEnemy_OnlyMove = true -- Should it only move away and not hide behind cover?
ENT.MoveOrHideOnDamageByEnemy_NextTime = VJ.SET(2, 2.5) -- How long until it can do this behavior again? (hide behind cover or move away)
ENT.FootStepTimeRun = 0.3 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.3 -- Next foot step sound when it is walking
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_bms_assassin/step1.wav","vj_bms_assassin/step2.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_bms_assassin/kick1.wav","vj_bms_assassin/kick2.wav","vj_bms_assassin/kick3.wav","vj_bms_assassin/kick4.wav","vj_bms_assassin/kick5.wav","vj_bms_assassin/kick6.wav"}
ENT.SoundTbl_Pain = {"vj_bms_assassin/pain1.wav","vj_bms_assassin/pain2.wav","vj_bms_assassin/pain3.wav","vj_bms_assassin/pain4.wav","vj_bms_assassin/pain5.wav","vj_bms_assassin/pain6.wav",}
ENT.SoundTbl_Death = {"vj_bms_assassin/die1.wav","vj_bms_assassin/die2.wav","vj_bms_assassin/die3.wav","vj_bms_assassin/die4.wav","vj_bms_assassin/die5.wav","vj_bms_assassin/die6.wav",}

-- Custom
ENT.Assassin_NextJumpT = 0
ENT.Assassin_NextCloakT = 0
ENT.Assassin_Cloaking = false
ENT.Assassin_ControllerCloakLevel = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	//self:SetMaterial("models/effects/vol_ight001_")

	if GetConVarNumber("vj_npc_noidleparticle") == 0 then
		local eyeglow1 = ents.Create("env_sprite")
		eyeglow1:SetKeyValue("model", "vj_base/sprites/vj_glow1.vmt")
		eyeglow1:SetKeyValue("scale", "0.04")
		eyeglow1:SetKeyValue("rendermode", "5")
		eyeglow1:SetKeyValue("rendercolor", "255 0 0")
		eyeglow1:SetKeyValue("spawnflags", "1") -- If animated
		eyeglow1:SetParent(self)
		eyeglow1:Fire("SetParentAttachment", "eye1", 0)
		eyeglow1:Spawn()
		eyeglow1:Activate()
		self:DeleteOnRemove(eyeglow1)
		
		local eyeglow2 = ents.Create("env_sprite")
		eyeglow2:SetKeyValue("model", "vj_base/sprites/vj_glow1.vmt")
		eyeglow2:SetKeyValue("scale", "0.04")
		eyeglow2:SetKeyValue("rendermode", "5")
		eyeglow2:SetKeyValue("rendercolor", "255 0 0")
		eyeglow2:SetKeyValue("spawnflags", "1") -- If animated
		eyeglow2:SetParent(self)
		eyeglow2:Fire("SetParentAttachment", "eye2", 0)
		eyeglow2:Spawn()
		eyeglow2:Activate()
		self:DeleteOnRemove(eyeglow2)
		
		util.SpriteTrail(self, 6, Color(200, 0, 0), true, 6, 6, 0.1, 0.04167, "VJ_Base/sprites/vj_trial1.vmt")
		util.SpriteTrail(self, 7, Color(200, 0, 0), true, 6, 6, 0.1, 0.04167, "VJ_Base/sprites/vj_trial1.vmt")
	end
	
	if self.DisableWeapons == false then
		self:Give("weapon_vj_glock17")
		self:GetActiveWeapon().NPC_NextPrimaryFire = 0.15
		self:GetActiveWeapon().Primary.Sound = "vj_bms_assassin/silentpistol.wav"
		self:GetActiveWeapon().Primary.HasDistantSound = false
		self:GetActiveWeapon().Primary.Damage = 10
		self:GetActiveWeapon().PrimaryEffects_MuzzleFlash = false
		//self:GetActiveWeapon():SetRenderMode(RENDERMODE_TRANSALPHA)
		if self:GetActiveWeapon() != NULL then
			self.ExtraGunModel1 = ents.Create("prop_physics")
			self.ExtraGunModel1:SetModel("models/vj_weapons/w_glock_lh.mdl")
			self.ExtraGunModel1:SetLocalPos(self:GetPos())
			//self.ExtraGunModel1:SetPos(self:GetPos())
			self.ExtraGunModel1:SetOwner(self)
			self.ExtraGunModel1:SetParent(self)
			//self.ExtraGunModel1:SetLocalAngles(Angle(-120, 0, 90))
			//self.ExtraGunModel1:Fire("SetParentAttachmentMaintainOffset", "anim_attachment_LH")
			self.ExtraGunModel1:Fire("SetParentAttachment", "anim_attachment_LH")
			self.ExtraGunModel1:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			self.ExtraGunModel1:Spawn()
			self.ExtraGunModel1:Activate()
			self.ExtraGunModel1:SetSolid(SOLID_NONE)
			self.ExtraGunModel1:AddEffects(EF_BONEMERGE)
			//self.ExtraGunModel1:SetMaterial("models/effects/vol_light001.vmt")
			self.ExtraGunModel1:SetRenderMode(RENDERMODE_TRANSALPHA)
		end
	end
	timer.Simple(0.1, function() if IsValid(self) then self:SetRenderMode(RENDERMODE_TRANSALPHA) end end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_Initialize(ply)
	ply:ChatPrint("JUMP: Change Camouflage")
end
---------------------------------------------------------------------------------------------------------------------------------------------
local colorVis = Color(255, 255, 255, 255)
--
function ENT:BMSASSASSIN_RESETCLOAK()
	self.Assassin_Cloaking = false
	self:SetColor(colorVis)
	self:DrawShadow(true)
	self:RemoveFlags(FL_NOTARGET)
	if IsValid(self:GetActiveWeapon()) then
		if IsValid(self.ExtraGunModel1) then
			self.ExtraGunModel1:SetColor(colorVis)
			self.ExtraGunModel1:DrawShadow(true)
		end
		self:GetActiveWeapon().WorldModel_Invisible = false
	end
	self.DisableMakingSelfEnemyToNPCs = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
local colorInv = Color(0, 0, 0, 10)
--
function ENT:BMSASSASSIN_DOCLOAK()
	self.Assassin_Cloaking = true
	self:AddFlags(FL_NOTARGET)
	self:SetColor(colorInv)
	self:DrawShadow(false)
	if IsValid(self:GetActiveWeapon()) then
		if IsValid(self.ExtraGunModel1) then
			self.ExtraGunModel1:SetColor(colorInv)
			self.ExtraGunModel1:DrawShadow(false)
		end
		self:GetActiveWeapon().WorldModel_Invisible = true
	end
	self.DisableMakingSelfEnemyToNPCs = true
	if self.VJ_IsBeingControlled == false then
		timer.Simple(math.random(6, 9), function() if IsValid(self) then self:BMSASSASSIN_RESETCLOAK() end end)
	end
	self.Assassin_NextCloakT = CurTime() + math.random(13, 14)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	if self.VJ_IsBeingControlled && self.VJ_TheController:KeyDown(IN_JUMP) then
		self.VJ_TheController:PrintMessage(HUD_PRINTCENTER, "Changing Camouflage!")
		if self.Assassin_ControllerCloakLevel == 0 then
			self.Assassin_ControllerCloakLevel = 1
			self:BMSASSASSIN_DOCLOAK()
		elseif self.Assassin_ControllerCloakLevel == 1 then
			self.Assassin_ControllerCloakLevel = 0
			self:BMSASSASSIN_RESETCLOAK()
		end
	end
	if GetConVarNumber("vj_bms_blackopsassassin_cloak") == 1 && self.VJ_IsBeingControlled == false then
		if IsValid(self:GetEnemy()) then
			if CurTime() > self.Assassin_NextCloakT then
				self:BMSASSASSIN_DOCLOAK()
			end
		elseif self:GetNPCState() != NPC_STATE_ALERT && self:GetNPCState() != NPC_STATE_COMBAT then
			if self.Assassin_Cloaking == true then self:BMSASSASSIN_RESETCLOAK() end
		end
	end

	if IsValid(self:GetEnemy()) && self.DoingWeaponAttack_Standing == true && self.VJ_IsBeingControlled == false && CurTime() > self.Assassin_NextJumpT && self:GetPos():Distance(self:GetEnemy():GetPos()) < 1400 then
		self:VJ_ACT_PLAYACTIVITY({ACT_LEAP, ACT_JUMP}, true, 1, false)
		self.Assassin_NextJumpT = CurTime() + math.Rand(3.5, 6)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAlert()
	self.Assassin_NextJumpT = CurTime() + math.Rand(2, 3)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPriorToKilled(dmginfo,hitgroup)
	self:BMSASSASSIN_RESETCLOAK()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo, hitgroup, corpseEnt)
	-- Create the second pistol to drop with the gun
	self:CreateExtraDeathCorpse("weapon_vj_glock17", "None", {HasVel=false}, function(extraent)
		local phys = extraent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(60)
			phys:ApplyForceCenter(dmginfo:GetDamageForce())
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDropWeapon(dmginfo, hitgroup, wepEnt)
	wepEnt.WorldModel_Invisible = false
	wepEnt:SetNW2Bool("VJ_WorldModel_Invisible", false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local colorRed = VJ.Color2Byte(Color(130, 19, 10))
--
function ENT:SetUpGibesOnDeath(dmginfo, hitgroup)
	self.HasDeathSounds = false
	if self.HasGibDeathParticles then
		local effectData = EffectData()
		effectData:SetOrigin(self:GetPos() + self:OBBCenter())
		effectData:SetColor(colorRed)
		effectData:SetScale(120)
		util.Effect("VJ_Blood1", effectData)
		effectData:SetScale(8)
		effectData:SetFlags(3)
		effectData:SetColor(0)
		util.Effect("bloodspray", effectData)
		util.Effect("bloodspray", effectData)
	end
	
	self:CreateGibEntity("obj_vj_gib", "models/gibs/humans/brain_gib.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 60)), Ang=self:GetAngles()+Angle(0, -90, 0)})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/humans/eye_gib.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 55)), Ang=self:GetAngles()+Angle(0, -90, 0), Vel=self:GetRight()*math.Rand(150, 250)+self:GetForward()*math.Rand(-200, 200)})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/humans/eye_gib.mdl", {Pos=self:LocalToWorld(Vector(0, 3, 55)), Ang=self:GetAngles()+Angle(0, -90, 0), Vel=self:GetRight()*math.Rand(-150, -250)+self:GetForward()*math.Rand(-200, 200)})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/humans/heart_gib.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 40))})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/humans/lung_gib.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 41))})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/humans/lung_gib.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 42))})
	self:CreateGibEntity("obj_vj_gib", "models/gibs/humans/liver_gib.mdl", {Pos=self:LocalToWorld(Vector(0, 0, 35))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Small", {Pos=self:LocalToWorld(Vector(0, 0, 30))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Small", {Pos=self:LocalToWorld(Vector(0, 0, 31))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Small", {Pos=self:LocalToWorld(Vector(0, 0, 32))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(0, 0, 36))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(0, 0, 37))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(0, 0, 38))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(0, 1, 40))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(1, 0, 40))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(1, 1, 40))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(0, 0, 34))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(0, 1, 30))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(1, 0, 30))})
	self:CreateGibEntity("obj_vj_gib", "UseHuman_Big", {Pos=self:LocalToWorld(Vector(0, 1, 31))})
	return true
end