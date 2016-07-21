AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/money.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()

	self:SetUseType(SIMPLE_USE)
end

function ENT:setWeapon(ply)
	self.Gun = ply:GetActiveWeapon():GetClass()
	self:SetModel(ply:GetActiveWeapon().WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self.Buff = self.Gun.Buff
end

function ENT:Use(event, ply)
	local gun = ply:GiveWeapon(self.Gun)
	gun:SetBuff(self.Buff)
	self:Remove()
end