AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/cardboard_box003a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:PhysWake()
end

function ENT:Use(activator, ply)
	if IsValid(ply) and ply:IsPlayer() then
		ply:GiveAmmo(5, "PropArmor")
		self:Remove()
	end
end