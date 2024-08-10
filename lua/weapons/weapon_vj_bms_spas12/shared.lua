---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "SPAS-12"
SWEP.Author = "DrVrej"
SWEP.Contact = "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose = "This weapon is made for Players and NPCs"
SWEP.Instructions = "Controls are like a regular weapon."
SWEP.Category = "VJ Base"
	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.MadeForNPCsOnly = true -- Is this weapon meant to be for NPCs only?
SWEP.WorldModel = "models/vj_weapons/bms/w_shotgun.mdl"
SWEP.HoldType = "shotgun"
	-- NPC Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.NPC_NextPrimaryFire = 0.9 -- RPM of the weapon in seconds | Calculation: 60 / RPM
SWEP.NPC_TimeUntilFire = 0.2 -- How much time until the bullet/projectile is fired?
SWEP.NPC_ExtraFireSound = "vj_weapons/bms_shotgun/pump.wav" -- Plays an extra sound after it fires (Example: Bolt action sound)
SWEP.NPC_FiringDistanceScale = 0.5 -- Changes how far the NPC can fire | 1 = No change, x < 1 = closer, x > 1 = farther
	-- Primary Fire ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.Damage = 4 -- Damage
SWEP.Primary.Force = 1 -- Force applied on the object the bullet hits
SWEP.Primary.NumberOfShots = 7 -- How many shots per attack?
SWEP.Primary.ClipSize = 8 -- Max amount of bullets per clip
SWEP.Primary.Ammo = "Buckshot" -- Ammo type
SWEP.Primary.Sound = "vj_weapons/bms_shotgun/close1.wav"
SWEP.Primary.DistantSound = "vj_weapons/bms_shotgun/distant1.wav"
SWEP.PrimaryEffects_MuzzleAttachment = "muzzle"
SWEP.PrimaryEffects_ShellAttachment = "muzzle"
SWEP.PrimaryEffects_ShellType = "ShotgunShellEject"