ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.Name = "Shipment"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Remaining")
	self:NetworkVar("String", 1, "Name")
end
