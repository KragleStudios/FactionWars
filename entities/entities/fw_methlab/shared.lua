
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