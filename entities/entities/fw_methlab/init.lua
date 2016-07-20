AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/props_lab/crematorcase.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)  
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetUses(5)
	self:SetNextProduceTime(CurTime() + 3)
	self:PhysWake()
end

function ENT:Think()
	if self:GetNextProduceTime() <= CurTime() then
		if (self:GetUses() > 0) then
			--[[local meth = ents.Create("fw_meth")
				meth:SetPos()
				meth:Spawn()
			meth:DropToFloor()]]
			print("spawn meth")
		elseif (self:GetUses() <= -3) then -- left unattended too long. 0 is when it stops functioning. -3 is when it blows up.
			return self:Explode()
		end

		self:SetUses(self:GetUses() - 1)		
		self:SetNextProduceTime(CurTime() + 3)
	end
end

function ENT:Explode()
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		util.Effect( "HelicopterMegaBomb", effectdata)
	util.BlastDamage(self, self, self:GetPos(), 800, 500)

	self:Remove()
end