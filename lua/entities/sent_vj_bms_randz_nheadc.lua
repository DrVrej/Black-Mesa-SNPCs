/*--------------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()

ENT.Base 			= "obj_vj_spawner_base"
ENT.Type 			= "anim"
ENT.PrintName 		= "Random Crabless Zombie"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Purpose 		= "Spawn it and fight with it!"
ENT.Instructions 	= "Click on the spawnicon to spawn it."
ENT.Category		= "VJ Base Spawners"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false
---------------------------------------------------------------------------------------------------------------------------------------------

ENT.SingleSpawner = true -- If set to true, it will spawn the entities once then remove itself
ENT.EntitiesToSpawn = {
	{SpawnPosition = {vForward=0, vRight=0, vUp=0}, Entities = {"npc_vj_bmsz_zombiecop_nheadc:3", "npc_vj_bmsz_zecu_nheadc:4", "npc_vj_bmsz_zombiescito_nheadc:8", "npc_vj_bmsz_zombiecopto_nheadc:10", "npc_vj_bmsz_zecuto_nheadc:12", "npc_vj_bmsz_zombiesci_nheadc"}},
}