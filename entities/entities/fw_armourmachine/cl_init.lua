include("shared.lua")

function ENT:GetDisplayPosition()
	local obbcenter = self:OBBCenter()
	local obbmax = self:OBBMaxs()
	return Vector(obbcenter.x + 15, obbmax.y - 18, obbcenter.z + 23), Angle(0, 90, 90), 0.2
end

function ENT:Draw()
	self:DrawModel()
	self:FWDrawInfo()
end
