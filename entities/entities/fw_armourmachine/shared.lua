
ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "Armour Machine"
ENT.Author			= "Spai"
ENT.Category 		= "Faction Wars"

ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()

	self:NetworkVar("Int", 0, "Charge")
	self:NetworkVar("Int", 1, "MaxCharge")
	
end