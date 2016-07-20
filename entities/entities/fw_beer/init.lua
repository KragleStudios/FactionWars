AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()

	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(event, ply)
	if IsValid(ply) then
		ply:GetFWData().beerTime = (ply:GetFWData().beerTime or CurTime()) + 60
		self:Remove()
	end
end