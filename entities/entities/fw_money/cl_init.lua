include("shared.lua")

local aFont = fw.fonts.default:atSize(32)
local bgColor = Color(0, 0, 0, 220)

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 180)

	cam.Start3D2D(self:LocalToWorld(Vector(3.2, -0.9, 1)), ang, 0.05)
		draw.WordBox(2, 0, 0, "$" .. self:GetValue(), aFont, bgColor, color_white)
	cam.End3D2D()
end
