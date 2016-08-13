include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local font = fw.fonts.default_compact:atSize(45)

	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetUp(), 90)
	ang:RotateAroundAxis(-self:GetRight(), 90)

	cam.Start3D2D(self:GetPos() + self:GetUp() * 28 + self:GetForward() * 13 + self:GetRight() * 7.5, ang, .1)
		surface.SetDrawColor(32,32,32,235)
		surface.DrawRect(0,0,235,77)

		surface.SetDrawColor(100 - (self:GetCharge() / self:GetMaxCharge()) * 255, (self:GetCharge() / self:GetMaxCharge()) * 255, 0)
		surface.DrawRect(1,1, (self:GetCharge() / self:GetMaxCharge()) * 233, 35)

		if self:GetCharge() <= 0 then 
			surface.SetDrawColor(192, 57, 43)
			surface.DrawRect(1,1, 233, 35)
		end

		local txt = "Charge: " .. self:GetCharge() or "#Error"
		local txt2 = "HEALTH"

		surface.SetFont(font)
		surface.SetTextColor(Color(255,255,255))
		surface.SetTextPos(117.5 - surface.GetTextSize(txt) * .5,32)
		surface.DrawText(txt)

		surface.SetDrawColor(32,32,32)
		surface.DrawRect(0,80,235,35)	

		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0,80,235,35)

		surface.SetFont(font)
		surface.SetTextColor(Color(231, 76, 60))
		surface.SetTextPos(117.5 - surface.GetTextSize(txt2) * .5, 75)
		surface.DrawText(txt2)

		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0,0,235,77)
		surface.DrawOutlinedRect(0,0,235,37)
	cam.End3D2D()
end

function ENT:Initialize()
end