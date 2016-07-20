
include("shared.lua")
surface.CreateFont("ChargeFont", {font = "OpenSans", size = 44, weight = 500})
surface.CreateFont("HealthSign", {font = "OpenSans", size= 72, weight  = 900})

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetUp(), 90)
	ang:RotateAroundAxis(-self:GetRight(), 90)

	cam.Start3D2D(self:GetPos() + self:GetUp() * 28 + self:GetForward() * 13 + self:GetRight() * 7.5, ang, .1)
		surface.SetDrawColor(32,32,32,235)
			surface.DrawRect(0,0,235,77)

		surface.SetDrawColor(100 - (self:GetCharge() / self:GetMaxCharge()) * 255, 0 , (self:GetCharge() / self:GetMaxCharge()) * 255)
			surface.DrawRect(1,1, (self:GetCharge() / self:GetMaxCharge()) * 233, 35  )

		if self:GetCharge() <= 0 then 
			surface.SetDrawColor(192, 57, 43)
				surface.DrawRect(1,1, 233, 35)
		end

		local txt = "Charge: " .. self:GetCharge() or "#Error"
		surface.SetFont("ChargeFont")
		surface.SetTextColor(Color(255,255,255))
		surface.SetTextPos(117.5 - surface.GetTextSize(txt) * .5,32)
			surface.DrawText(txt)

		surface.SetDrawColor(0,0,0,255)
			surface.DrawOutlinedRect(0,0,235,77)
			surface.DrawOutlinedRect(0,0,235,37)

		surface.SetDrawColor(32,32,32)
			surface.DrawRect(80,80, 75,47)	

		surface.SetFont("HealthSign")
		surface.SetTextPos(117.5 - surface.GetTextSize("+") * .5, 60)
			surface.DrawText("⛑")

	cam.End3D2D()
end

function ENT:Initialize()

end
