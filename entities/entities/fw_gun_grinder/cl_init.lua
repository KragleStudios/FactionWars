include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	self:FWDrawInfo()
end

function ENT:GetDisplayPosition()
	local obbcenter = self:OBBCenter()
	local obbmax = self:OBBMaxs()
	return Vector(obbcenter.x, obbmax.y, obbcenter.z + 5), Angle(180, 0, -90), 0.15
end
