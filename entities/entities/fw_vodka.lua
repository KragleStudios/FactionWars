ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Vodka"
ENT.Category 		= "Faction Wars"
ENT.Author			= "crazyscouter, sanny"

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.NETWORK_SIZE = 0
ENT.Resources = true
ENT.MaxStorage = {
	["vodka"] = 5,
	["alcohol"] = 10
}

if (SERVER) then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/props_junk/GlassBottle01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysWake()

		self:SetUseType(SIMPLE_USE)

		self.Storage = {
			['vodka'] = 5,
		}
		self.Storage = {
			['alcohol'] = 10,
		}

		fw.resource.addEntity(self)
	end

	function ENT:Use(event, ply)
		if IsValid(ply) then
			ply:GetFWData().vodkaTime = (ply:GetFWData().vodkaTime or CurTime()) + 60
			self:Remove()
		end
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

	fw.hook.Add("RenderScreenspaceEffects", "BeerEffects", function()
		if (IsValid(LocalPlayer())) then
			if (LocalPlayer():GetFWData().vodkaTime and CurTime() <= LocalPlayer():GetFWData().vodkaTime) then
				DrawSobel(0.5)
			end
		end
	end)

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbmax.x, obbcenter.y, obbcenter.z), Angle(0, 0, 0), 0.1
	end
end