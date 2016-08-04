if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Generator"
ENT.Author			= "Spai"
ENT.Category        = "Faction Wars"

ENT.NETWORK_SIZE = 500
ENT.Resources = true
ENT.Produces = {
	["power"] = 5
}
ENT.MaxProduction = {
	["power"] = 5
}

ENT.Spawnable = true
ENT.AdminSpawnable = true

if SERVER then
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

		fw.resource.addEntity(self)

		self.Produces = {
			['power'] = 5
		}

		timer.Create('generator-' .. self:EntIndex(), 1, 0, function()
			local succ = self:ConsumeResource('gas', 1)
			if succ then
				self.Produces = {
					['power'] = 5,
				}
			else
				self.Produces = {
					['power'] = 0,
				}
			end
		end)
	end

	function ENT:Think()

	end

	function ENT:OnRemove()
		fw.resource.removeEntity(self)
		timer.Destroy('generator-' .. self:EntIndex())
	end

else

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbcenter.x - 25, obbmax.y, obbcenter.z), Angle(0, 180, 90), 0.2
	end
end

function ENT:IsActive()
	return (self.fwResourcesStatic['gas'] or 0) >= 1
end
