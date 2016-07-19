AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
	end

	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(event, ply)
	if IsValid(ply) then
		ply:GetFWData().drunkTime = (ply:GetFWData().drunkTime or CurTime()) + 60
		self:Remove()
	end
end