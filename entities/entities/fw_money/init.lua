AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/money.mdl")
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
		ply:addMoney(self:GetValue())
		self:Remove()
	end
end

function ENT:Touch(ent)
	if ent:GetClass() == "fw_money" and not ent.Used then
		ent.Used = true
		self:SetValue(self:GetValue() + ent:GetValue())
		if not self.Used then
			ent:Remove()
		end
		timer.Simple(1, function()
			if IsValid(self) then
				self.Used = false
			end
		end )
	end
end
