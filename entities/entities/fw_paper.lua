ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.Author      = "meharryp"
ENT.PrintName   = "Printer Paper"
ENT.Category    = "Faction Wars"

ENT.NETWORK_SIZE = 0
ENT.Resources = true
ENT.MaxStorage = {
	['paper'] = 100
}

if SERVER then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/props_junk/cardboard_box003a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self:PhysWake()

		self.Storage = {
			['paper'] = 100,
		}

		fw.resource.addEntity(self)
	end

	function ENT:Think()
		if self.Storage.paper <= 0 then self:Remove() end
	end

	function ENT:OnRemove()
		fw.resource.removeEntity(self)
	end
else
	function ENT:Draw()
		self:DrawModel()

		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 225)

		self:FWDrawInfo()
	end

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbcenter.x, obbcenter.y, obbmax.z), Angle(0, 90, 0), 0.12
	end
end
