AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/money.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()

	self:SetUseType(SIMPLE_USE)
	self:SetTrigger(true)
end

function ENT:Use(event, ply)
	if IsValid(ply) and ply:IsPlayer() then
		ply:addMoney(self:GetValue())

		if (IsValid(self.owner)) then 
			self.owner.maxmonay = self.owner.maxmonay - 1
		end

		self:Remove()
	end
end

function ENT:Touch(ent)
	/*if ent:GetClass() == "fw_money" and not ent.Used then
		ent.Used = true

		local selfVal = self:GetValue()
		local entVal  = ent:GetValue()
		local val = selfVal + entVal

		if (ent.valSet or self.valSet) then return end

		if val > 99999999 then
			return
		elseif (selfVal > entVal or selfVal == entVal) then
			ent:Remove()
			self:SetValue(val)
			self.valSet = true
		elseif (selfVal < entVal) then
			ent:SetValue(val)
			ent.valSet = true
			self:Remove()
		end
	end*/
end
