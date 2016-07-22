AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self:SetModel( "models/props_vehicles/generatortrailer01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )  
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
end

function ENT:Use(activator,caller)
	caller:ChatPrint("Network Power: " .. self.net:GetSharedRescourceAvailable("res_power") .. " " .. fw.resource.manager.Resources["res_power"].printname)
end

function ENT:Think()

end
