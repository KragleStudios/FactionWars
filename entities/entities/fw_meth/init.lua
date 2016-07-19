AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

fw.dep("hook")

function ENT:Initialize()
	self:SetModel("models/props_lab/huladoll.mdl")
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
		ply:GetFWData().methTime = (ply:GetFWData().methTime or CurTime()) + 60
		self:Remove()
	end
end

fw.hook.Add("EntityTakeDamage", "MethEffects", function(entity, dmgInfo)
	if (entity:IsPlayer() and entity:GetFWData().beerTime and CurTime() <= entity:GetFWData().beerTime) then
		dmgInfo:ScaleDamage(0.9)
	end
end)