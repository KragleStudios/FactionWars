AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/gravestone002a.mdl")

	self:PhysicsInit(SOLID_OBB)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_OBB)
	self:SetPos(self:GetPos() + Vector(0, 0, 20))
	self:SetAngles(Angle(0, 0, 0))
	self:DropToFloor()

	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:SetUseType(SIMPLE_USE)
	self:SetHealt(self.Healt)
end

function ENT:Think()
	self:SetAngles(Angle(0, 0, 0))
end

function ENT:OnTakeDamage(dmg)
	local damage = dmg:GetDamage()
	if (self:GetHealt() - damage < 0) then
		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		util.Effect("Explosion", effect)

		self:Remove()
		return
	end

	self:SetHealt(self:GetHealt() - damage)
end

fw.hook.Add("PlayerSpawn", "SpawnAtSpawnPoint", function(ply)
	local sp = ply:GetNWEntity("spawn_point")

	if (sp and IsValid(sp)) then
		ply:SetPos(sp:GetPos())

		fw.hud.pushNotification(ply, "Faction Wars", "You have been respawned at your respawn point!")

		sp:Remove()

		ply:SetNWEntity("spawn_point", nil)

		return true
	end
end)
