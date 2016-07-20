AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("SmallBomb")

function ENT:Initialize()

	self:SetModel( "models/props_c17/oildrum001_explosive.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )  
	self:SetMoveType( MOVETYPE_VPHYSICS)
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType(SIMPLE_USE)
	self:SetModelScale(.7)

	self.Timer = 45

	self:PhysWake()

	self.Pack = ents.Create("prop_physics")
	self.Pack:SetModel("models/weapons/w_c4_planted.mdl")
	self.Pack:SetModelScale(.65)
	self.Pack:SetAngles(Angle(-90,0,0))
	self.Pack:SetPos(self:GetPos() + self:GetUp() * 20.5 - self:GetRight() - self:GetForward() * 5.9)
	self.Pack:SetParent(self)
end


function ENT:Use(activator,caller)
	if not self:GetEnable() then
		activator:ChatPrint("Bomb has been enabled!")
		self:SetEnable(true)
		timer.Simple(self.Timer, function()
			if IsValid(self) then
				self:Explode()
			end
		end)
		self:SetDetonateTime(CurTime() + self.Timer)
	end
end

function ENT:Explode()
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "HelicopterMegaBomb", effectdata )
	util.BlastDamage(self, self, self:GetPos(), 800, 500)
	self:Remove()
end

function ENT:Think()

end

function ENT:SpawnFunction( ply, tr, ClassName )
	if (  not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent
end
