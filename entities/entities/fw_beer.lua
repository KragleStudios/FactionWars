ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Beer"
ENT.Category 		= "Faction Wars"
ENT.Author			= "crazyscouter, sanny"

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.NETWORK_SIZE = 0
ENT.Resources = true
ENT.MaxStorage = {
	["alcohol"] = 1,
}

if (SERVER) then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysWake()

		self:SetUseType(SIMPLE_USE)

		self.Storage = {
			["alcohol"] = 1,
		}

		fw.resource.addEntity(self)
	end

	function ENT:Use(event, ply)
		if IsValid(ply) then
			ply:GetFWData().beerTime = (ply:GetFWData().beerTime or CurTime()) + 60
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
			if (LocalPlayer():GetFWData().beerTime and CurTime() <= LocalPlayer():GetFWData().beerTime) then
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