AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/wood_crate001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
	end

	self:SetUseType(SIMPLE_USE)
	self:SetTrigger(true)
end

function ENT:Use(event, ply)
	if IsValid(ply) and ply:IsPlayer() then
		local remain = self:GetRemaining()
		if (remain - 1 < 0) then 
			return 
		end
		if (remain - 1 == 0) then
			self:Remove()
			self.ent:Remove()
			return
		end

		self:SetRemaining(remaining - 1)

		local ent = ents.Create(self.entity)
		ent:SetPos(self:GetPos() + Vector(0, 0, 20))
		ent:Spawn()
		ent:Activate()
	end
end

function ENT:OnRemove()
	if (self.ent) then self.ent:Remove() end
end

function ENT:setEntityModel(path)
	self.ent = ents.Create("prop_physics")
	self.ent:SetModel(path)
end

function ENT:Think()
	if (IsValid(self.ent)) then
	
		self.ent:SetPos(self:GetPos() + Vector(0, 0, 30))
		self.ent:SetAngles(Angle(0, CurTime() * 10, 0))
	end
end

function ENT:setEntity(class)
	self.entity = class
end

function ENT:setShipmentAmount(count)
	self:SetRemaining(count)
end

