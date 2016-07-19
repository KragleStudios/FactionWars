AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self:SetModel( "models/props_lab/reciever_cart.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )  
	self:SetMoveType( MOVETYPE_VPHYSICS)
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( CONTINUOUS_USE )

	self:SetMaxCharge(350)
	self:SetCharge(350)
	self.LastCall = 0

	local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
end


function ENT:Use(ply)
	if ply:Armor() < 100 and self:GetCharge() > 0 and self.LastCall + .1 < CurTime() then
		self.LastCall = CurTime()
		self:SetCharge(self:GetCharge() - 1)
		ply:SetArmor(ply:Armor() + 1)
		self:EmitSound("hl1/fvox/boop.wav", 150, 100, 1, CHAN_AUTO)
	end
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if (  !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent
end
