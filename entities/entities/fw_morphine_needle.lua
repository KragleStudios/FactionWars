ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Morphine Needle"
ENT.Category 		= "Faction Wars"
ENT.Author			= "crazyscouter"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.NETWORK_SIZE = 0
ENT.Resources = true
ENT.MaxStorage = {
	["opioid"] = 2,
}

if (SERVER) then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/Gibs/HGIBS_spine.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysWake()

		self:SetUseType(SIMPLE_USE)

		self.Storage = {
			["opioid"] = 2,
		}

		fw.resource.addEntity(self)
	end

	function ENT:Use(event, ply)
		
	end


	function ENT:OnRemove()
		fw.resource.removeEntity(self)
	end

	function ENT:Think()
		if self.Storage.opioid == 0 then self:Remove() end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end

	fw.hook.Add("RenderScreenspaceEffects", "BeerEffects", function()
		if (IsValid(LocalPlayer())) then
		
		end
	end)

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbmax.x, obbcenter.y, obbcenter.z), Angle(0, 0, 0), 0.1
	end
end
