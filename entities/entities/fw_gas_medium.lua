if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Medium Gas Can"
ENT.Author			= "thelastpenguin"
ENT.Category        = "Faction Wars"

ENT.NETWORK_SIZE = 500
ENT.Resources = true
ENT.MaxStorage = {
	['gas'] = 100
}

ENT.Spawnable = true
ENT.AdminSpawnable = true

if SERVER then
	function ENT:Initialize()
		self:SetModel "models/props_junk/gascan001a.mdl"
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end

		self.Storage = {
			['gas'] = 100,
		}

		fw.resource.addEntity(self)
	end

	function ENT:OnRemove()
		fw.resource.removeEntity(self)
	end

	function ENT:Think()
		if self.Storage.gas == 0 then self:Remove() end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbmax.x, obbcenter.y, obbcenter.z), Angle(0, 90, 90), 0.09
	end

end
