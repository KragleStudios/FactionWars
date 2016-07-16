AddCSLuaFile("shared.lua")
AddCSLuaFile("3d2dvgui.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/de_nuke/IndustrialLight01.mdl")
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
	end

	self:SetUseType(SIMPLE_USE)
	--self:SetTrigger(true)

	self:SetUpgradeStatus(0)
	self:SetOwner(self)
	self:SetRemaining(10)
	self:SetTargeting(false)
	self:SetStatus(true)

	self.radius = 60
	self.targetable_ents = {
		"player",
	}

	self.floater = ents.Create("prop_physics")
	self.floater:SetModel("models/weapons/w_smg1.mdl")
	self.floater:SetAngles(self:GetAngles())
end

function ENT:ShouldTarget(target)
	return true --false
end

function ENT:FindNearest()
	local near = nil
	local range = self.radius * self.radius

	for _,ent in pairs(ents.GetAll()) do
		if (table.HasValue(self.targetable_ents, ent:GetClass())) then
			local dis = self:GetPos():DistToSqr(ent:GetPos())
			if (dis <= range) then
				near = ent
				range = dis
			end
		end
	end

	return near
end

function ENT:Think()
	if (IsValid(self.floater)) then
		self.floater:SetPos(self:LocalToWorld(self:GetPos() + Vector(0, 0, 10)))
		self.floater:SetAngles(self:GetAngles())
	end

	local ent = self:FindNearest()
	if (not IsValid(ent)) then return end
	if (not self:ShouldTarget(ent)) then return end


	--targetting code and shit
end


