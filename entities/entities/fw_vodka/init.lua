AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

fw.dep("hook")

function ENT:Initialize()
	self:SetModel("models/props_junk/glassbottle01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:PhysWake()

	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(event, ply)
	if IsValid(ply) then
		ply:GetFWData().vodkaTime = (ply:GetFWData().vodkaTime or CurTime()) + 60
		self:Remove()
	end
end

fw.hook.Add("EntityTakeDamage", "VodkaEffects", function(entity, dmgInfo)
	-- awesome
	if (entity:IsPlayer() and entity:GetFWData().vodkaTime and CurTime() <= entity:GetFWData().vodkaTime) then
		dmgInfo:ScaleDamage(0.9)
	end
end)
