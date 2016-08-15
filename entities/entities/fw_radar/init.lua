AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/de_nuke/IndustrialLight01.mdl")
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetPos(self:GetPos() + Vector(0, 0, 20))
	self:SetAngles(Angle(0, 0, 0))
	self:DropToFloor()

	local ang = self:GetAngles()
	self:SetAngles(Angle(0, ang.y, 0))

	self:SetUseType(SIMPLE_USE)
end

function ENT:Think()
	self:SetAngles(Angle(0, 0, 0))
end