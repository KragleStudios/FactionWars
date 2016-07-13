ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.Name = "Printer Ink"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Value")
end