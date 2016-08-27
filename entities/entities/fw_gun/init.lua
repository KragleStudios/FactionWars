AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()

	self:SetUseType(SIMPLE_USE)
end

function ENT:setWeapon(ply)
	self.Gun = ply:GetActiveWeapon()
	self:SetModel(ply:GetActiveWeapon().WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetBuff(self.Gun:GetBuff())
	self:SetWeapon(self.Gun:GetClass())
end

function ENT:SetWeaponAndModel(weapon, model)
	self:SetWeapon(weapon)
	self:SetModel(model)
end


function ENT:Use(event, ply)
	local gun = ply:Give(self:GetWeapon())
	self:Remove()
	if self:GetBuff() and self:GetBuff():len() > 0 then
		gun:SetBuff(self:GetBuff())
	end
	if self.WeaponPrintName then
		fw.hud.pushNotification(ply, "PICKUP", "You picked up an "..self.WeaponPrintName)
	end
end
