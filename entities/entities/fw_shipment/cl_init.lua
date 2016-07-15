include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	if (LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000 * 1000) then return end

	local ang = self:GetAngles() + Angle(0, 0, 90)

	cam.Start3D2D(self:LocalToWorld(Vector(0, -20, 5)), ang, 0.1)
		draw.SimpleText(self:GetName(),  fw.fonts.default:atSize(100), 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Remaining: " .. self:GetRemaining(), fw.fonts.default:atSize(60), 0, 80, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()

	local ang_two = ang + Angle(0, 180, 0)

	cam.Start3D2D(self:LocalToWorld(Vector(0, 20, 5)), ang_two, 0.1)
		draw.SimpleText(self:GetName(),  fw.fonts.default:atSize(100), 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Remaining: " .. self:GetRemaining(), fw.fonts.default:atSize(60), 0, 80, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
