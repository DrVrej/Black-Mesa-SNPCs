ENT.Base 			= "base_ai"
ENT.Type 			= "ai"
ENT.PrintName		= "Snark Nest"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Information		= "SEnt for my SNPCs"
ENT.Category		= "Black Mesa"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.AutomaticFrameAdvance = true

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

if CLIENT then
	language.Add("sent_bms_snarknest", "Snark Nest")
	killicon.Add("sent_bms_snarknest","HUD/killicons/default",Color(255,80,0,255))

	language.Add("#sent_bms_snarknest", "Snark Nest")
	killicon.Add("#sent_bms_snarknest","HUD/killicons/default",Color(255,80,0,255))

	function ENT:Draw()
		self:DrawModel()
	end
end