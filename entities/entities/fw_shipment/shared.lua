ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.Name = "Shipment"

function ENT:getRemaining()
	return self:GetNWInt("remaining", 0)
end