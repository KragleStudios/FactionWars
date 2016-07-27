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

function ENT:Use(event, ply)
	local gun = ply:Give(self:GetWeapon())
	gun:SetBuff(self:GetBuff())
	self:Remove()
end