AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.MODEL = "models/props_junk/garbage_plasticbottle003a.mdl"


ENT.LASTINGEFFECT = 60; --how long the high lasts in seconds

--called when you use it (after it sets the high visual values and removes itself already)
function ENT:High(activator,caller)
		
	local sayings = {
		"OH MY GOD I JUST DEFLATED",
		"I WONDER WHAT HAPPENS WHEN I POUR GASOLINE ALL OVER MYSELF? THAT MUST BE THE CURE FOR CANCER, DUDE"
	}
	self:Say(activator, ""..sayings[math.random(1,#sayings)])
		
end



function ENT:SpawnFunction( ply, tr ) 
   
 	if ( not tr.Hit ) then return end 
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 16 
 	 
 	local ent = ents.Create( self.Classname ) 
 		ent:SetPos( SpawnPos ) 
 	ent:Spawn() 
 	ent:Activate() 
 	 
 	return ent 
 	 
 end 



