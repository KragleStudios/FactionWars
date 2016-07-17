
include("shared.lua")
surface.CreateFont("TimeTitle", {font="OpenSans", size=38, weight=500})
surface.CreateFont("TimeTitle2", {font="OpenSans", size=42, weight=500})
surface.CreateFont("Countdown", {font="OpenSans", size=72, weight=800})

function ENT:Initialize()
	self.LastRun = 0
end

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 270)
	ang:RotateAroundAxis(ang:Forward(), 0)

	cam.Start3D2D(self:GetPos() + self:GetUp() * 31.6 - self:GetRight() * 6 + self:GetForward() * 7.5, ang, .1)
		surface.SetDrawColor(32,32,32,230)
			surface.DrawRect(0,0,120,150)
		surface.SetDrawColor(16,16,16)
			surface.DrawOutlinedRect(0,0,120,150)
		surface.SetTextColor(240,240,240)
			if self:GetEnable() then
				surface.SetFont("Countdown")
				surface.SetTextPos(60 - surface.GetTextSize(math.floor(self:GetDetonateTime() - CurTime())) * .5,24)
					surface.DrawText(math.floor(self:GetDetonateTime() - CurTime()))
				surface.SetFont("TimeTitle")
				surface.SetTextPos(4,100)
					surface.DrawText("Seconds")
			else
				surface.SetFont("TimeTitle2")
				surface.SetTextPos(3,52)
					surface.DrawText("Press E")
			end

	cam.End3D2D()
end

function ENT:Think()
	if self:GetEnable() and self.LastRun + 2 < CurTime() then
		self.LastRun = CurTime()
		self:EmitSound("HL1/fvox/beep.wav", self:GetPos(), self:EntIndex(), CHAN_AUTO, 1, 140, 150)
	end
end
