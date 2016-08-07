if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Money Printer"
ENT.Author			= "thelastpenguin"
ENT.Category        = "Faction Wars"

ENT.NETWORK_SIZE = 500
ENT.Resources = true

ENT.MaxConsumption = {
	["power"] = 2,
}
ENT.PrintInterval = 30

ENT.Spawnable = true
ENT.AdminSpawnable = true

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_c17/consolebox01a.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end

		self.Consumes = {
			['power'] = 2,
		}

		fw.resource.addEntity(self)
	end

	function ENT:Think()

	end

	function ENT:OnRemove()
		fw.resource.removeEntity(self)
	end

else

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbcenter.x, obbcenter.y, obbmax.z), Angle(0, 90, 0), 0.15
	end
end
