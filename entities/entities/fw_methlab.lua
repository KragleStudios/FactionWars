
ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Meth Lab"
ENT.Author			= "sanny"
ENT.Category 		= "Faction Wars"

ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "NextProduceTime")
	self:NetworkVar("Int", 0, "Uses")
end

if (SERVER) then
	AddCSLuaFile()

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
				--print("spawn meth")
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
else
	function ENT:Draw()
		self:DrawModel()
	end
end
