ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Alochol Pack"
ENT.Author			= "crazyscouter"
ENT.Category        = "Faction Wars"

ENT.NETWORK_SIZE = 0
ENT.Resources = true
ENT.MaxStorage = {
	['alcohol'] = 25
}
ENT.Spawnable = true
ENT.AdminSpawnable = true

if SERVER then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/props/cs_militia/caseofbeer01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end

		self.Storage = {
			['alcohol'] = 25,
		}

		fw.resource.addEntity(self)
	end

	function ENT:OnRemove()
		fw.resource.removeEntity(self)
	end

	function ENT:Think()
		if self.Storage.alcohol == 0 then self:Remove() end
	end
else
	function ENT:Draw()
		self:DrawModel()
		self:FWDrawInfo()
	end

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(0, obbcenter.y + 6.3, obbcenter.z), Angle(0, 180, 90), 0.09
	end
end
