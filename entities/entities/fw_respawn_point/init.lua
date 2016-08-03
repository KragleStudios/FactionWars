AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/player/skeleton.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetPos(self:GetPos() + Vector(0, 0, 20))
	self:SetAngles(Angle(0, 0, 0))
	self:DropToFloor()

	local l = self:GetPhysicsObject()
	if l and l:IsValid() then
		l:EnableMotion(false)
	end

	self:SetUseType(SIMPLE_USE)

	self:SetHealt(self.Healt)
end

local func = ENT.SetNWEntity

function ENT:Think()
	self:SetAngles(Angle(0, 0, 0))
end

function ENT:Health()
	return self:GetHealt()
end

function ENT:SetHealth(amt)
	self:SetHealt(amt)
end

function ENT:OnTakeDamage(dmg)
	local dmg = dmg:GetDamage()
	local cur = self:GetHealt()

	if (cur - dmg <= 0) then
		self:Remove()

		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		util.Effect("Explosion", effect)

		return
	end

	self:SetHealt(cur - dmg)
end

fw.hook.Add("PlayerSpawn", "SpawnatSpawnPoint", function(ply)
	local sp = ply:GetNWEntity("spawn_point")

	if (sp and IsValid(sp)) then
		ply:SetPos(sp:GetPos())
		
		ply:FWChatPrint("You have been respawned at your respawn point!")

		sp:Remove()

		ply:SetNWEntity("spawn_point", nil)

		return true
	end
end)
