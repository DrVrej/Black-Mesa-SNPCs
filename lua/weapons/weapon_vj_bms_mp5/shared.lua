SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "MP5"
SWEP.Author = "DrVrej"
SWEP.Contact = "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose = "This weapon is made for Players and NPCs"
SWEP.Instructions = "Controls are like a regular weapon."
SWEP.Category = "VJ Base"
	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.MadeForNPCsOnly = true -- Is this weapon meant to be for NPCs only?
SWEP.WorldModel = "models/vj_weapons/bms/w_mp5.mdl"
SWEP.HoldType = "ar2"
	-- NPC Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.NPC_NextPrimaryFire = 1 -- Next time it can use primary fire
SWEP.NPC_TimeUntilFire = 0.1 -- How much time until the bullet/projectile is fired?
SWEP.NPC_TimeUntilFireExtraTimers = {0.1,0.2,0.3,0.4,0.5,0.6} -- Next time it can use primary fire
SWEP.NPC_ReloadSound = {"vj_weapons/bms_mp5/reload.wav"} -- Sounds it plays when the base detects the SNPC playing a reload animation
SWEP.NPC_HasSecondaryFire = true -- Can the weapon have a secondary fire?
SWEP.NPC_SecondaryFireSound = {"vj_weapons/bms_mp5/double.wav"} -- The sound it plays when the secondary fire is used
	-- Primary Fire ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.Damage = 5 -- Damage
SWEP.Primary.Force = 5 -- Force applied on the object the bullet hits
SWEP.Primary.ClipSize = 30 -- Max amount of bullets per clip
SWEP.Primary.Ammo = "SMG1" -- Ammo type
SWEP.Primary.Sound = {"vj_weapons/bms_mp5/close1.wav"}
SWEP.Primary.DistantSound = {"vj_weapons/bms_mp5/distant1.wav"}
SWEP.PrimaryEffects_MuzzleAttachment = "muzzle"
SWEP.PrimaryEffects_ShellAttachment = "ejectbrass"
SWEP.PrimaryEffects_ShellType = "ShellEject"