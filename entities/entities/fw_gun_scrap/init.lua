AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("cl_init.lua")

function ENT:Initialize()
	self:SetModel("models/props_debris/concrete_chunk05g.mdl")
	self:SetMaterial("models/shiny")
	self:SetColor(Color(127, 127, 127))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:PhysWake()

	self:SetTrigger(true)
end