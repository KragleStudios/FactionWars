AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/reciever_cart.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)  
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:PhysWake()

	fw.resource.addEntity(self)

	self.Consumes = {power = 1}
	self:FWSetResource("armor", 5)

	-- every minute add 1 armor
	timer.Create("fw-armourmachine-refill-" .. self:EntIndex(), 60, 0, function()
		if not IsValid(self) or self:FWHaveResource("power") < self.Consumes.power then return end
		local armor = self:FWHaveResource("armor") or 0
		self:FWSetResource("armor", math.min(armor + 1, self.MaxProduction.armor))
	end)
end

function ENT:Use(ply)
	if ply:Armor() < 100 then
		local armor = self:FWHaveResource("armor") or 0
		if armor > 0 then
			ply:SetArmor(100)
			self:EmitSound("hl1/fvox/boop.wav", 150, 100, 1, CHAN_AUTO)
			self:FWSetResource("armor", armor - 1)
		else
			self:EmitSound("hl1/fvox/buzz.wav", 150, 100, 1, CHAN_AUTO)
		end
	end
end

function ENT:SpawnFunction(ply, tr, ClassName)
	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36
	local ent = ents.Create(ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:OnRemove()
	fw.resource.removeEntity(self)
end
