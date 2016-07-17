
ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Small Bomb"
ENT.Category 		= "Faction Wars"
ENT.Author			= "Spai"

ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()

	self:NetworkVar("Bool", 0, "Enable")
	self:NetworkVar("Int", 0, "DetonateTime")

end