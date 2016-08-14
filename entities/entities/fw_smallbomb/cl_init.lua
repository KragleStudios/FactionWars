include("shared.lua")

local font = fw.fonts.default_compact:atSize(45)
local font2 = fw.fonts.default_compact:atSize(100)

-- Thanks gmod wiki & crazyscouter
local function drawCircle(x, y, radius, seg)
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is need for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

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
		draw.NoTexture()
		drawCircle(60, 75, 80, 80)

		surface.SetTextColor(240,240,240)

		if self:GetEnable() then
			surface.SetFont(font2)
			surface.SetTextPos(60 - surface.GetTextSize(math.floor(self:GetDetonateTime() - CurTime())) * .5,24)
			surface.DrawText(math.floor(self:GetDetonateTime() - CurTime()))
		else
			surface.SetFont(font)
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
