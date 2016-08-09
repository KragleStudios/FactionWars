include("shared.lua")

function ENT:GetDisplayPosition()
	local obbcenter = self:OBBCenter()
	local obbmax = self:OBBMaxs()
	return Vector(obbcenter.x, obbcenter.y, obbmax.z), Angle(0, 90, 0), 0.15
end

function ENT:Draw()
	self:DrawModel()
	self:FWDrawInfo()
end
