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

	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:SetUseType(SIMPLE_USE)
	self:SetHealt(self.Healt)
end

local func = ENT.SetNWEntity

function ENT:Think()
	self:SetAngles(Angle(0, 0, 0))
end

fw.hook.Add("PlayerSpawn", "SpawnAtSpawnPoint", function(ply)
	local sp = ply:GetNWEntity("spawn_point")

	if (sp and IsValid(sp)) then
		ply:SetPos(sp:GetPos())

		ply:FWChatPrint("You have been respawned at your respawn point!")

		sp:Remove()

		ply:SetNWEntity("spawn_point", nil)

		return true
	end
end)
