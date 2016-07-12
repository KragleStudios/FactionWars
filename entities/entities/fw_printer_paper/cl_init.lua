include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 225)

	cam.Start3D2D(self:LocalToWorld(self:OBBMaxs()), ang, 0.1)
		draw.SimpleText(self.Name, fw.fonts.default:atSize(46), 190, -30, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end