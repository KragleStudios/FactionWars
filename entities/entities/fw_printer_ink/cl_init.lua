include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 225)

	cam.Start3D2D(self:LocalToWorld(self:OBBMaxs()), ang, 0.1)
		draw.SimpleText(self.Name, fw.fonts.default:atSize(30), 80, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end