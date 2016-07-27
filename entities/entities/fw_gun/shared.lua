ENT.PrintName = "Spawned Weapon"
ENT.Type = "anim"
ENT.Base = "base_entity"

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Weapon")
	self:NetworkVar("String", 1, "Buff")
end