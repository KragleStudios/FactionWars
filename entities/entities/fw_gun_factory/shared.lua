ENT.PrintName = "Weapon Parts"
ENT.Base = "base_entity"
ENT.Type = "anim"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Parts")
	self:NetworkVar("Int", 1, "Scrap")
end