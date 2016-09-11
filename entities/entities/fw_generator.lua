if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Generator"
ENT.Author			= "thelastpenguin"
ENT.Category        = "Faction Wars"

ENT.NETWORK_SIZE = 500
ENT.Resources = true
ENT.MaxProduction = {
	["power"] = 5
}
ENT.MaxConsumption = {
	["gas"] = 1,
}

ENT.Spawnable = false
ENT.AdminSpawnable = false

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

		local function consumeResources()
			if not IsValid(self) then return end
			local succ = self:ConsumeResource("gas", 1)
			if succ then
				self.Produces.power = 5
				timer.Simple(30, consumeResources)
			else
				if self.Produces.power > 0 then
					fw.hud.pushNotification(self:FWGetOwner(), self.PrintName, 'Out of gas', Color(255, 0, 0))
				end
				self.Produces.power = 0
				timer.Simple(5, consumeResources)
			end
		end
		consumeResources()
	end

	function ENT:Think()

	end

	function ENT:OnRemove()
		fw.resource.removeEntity(self)
		timer.Destroy("generator-" .. self:EntIndex())
	end

else

	function ENT:Draw()
		self:DrawModel()
		self:FWDrawInfo()
	end

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbcenter.x - 25, obbmax.y, obbcenter.z), Angle(0, 180, 90), 0.2
	end
end

if SERVER then
	function ENT:IsActive() -- optional server side property of an entity that returns if it is active
		return (self.fwResourcesStatic["gas"] or 0) >= 1
	end
end
