include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if (LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000 * 1000) then return end

	local own = self:FWGetOwner()

	local font = fw.fonts.default_compact_shadow:atSize(100)
	local text = (IsValid(own) and own:Nick() or "owner") .. "'s "
	local text2 = "Spawn Point"
	local col = own:IsPlayer() and fw.team.factions[own:getFaction()].color or Color(255, 255, 255)

	surface.SetFont(font)
	local x = surface.GetTextSize(text)
	local x2, y = surface.GetTextSize(text2)

	local eye = LocalPlayer():EyeAngles()

	cam.Start3D2D(self:GetPos() + self:GetUp() * 50, Angle(0, eye.y - 90, 90), .05)
	    draw.SimpleTextOutlined(text, font, -(x / 2), 0, col, 0, 0, 0.5, Color(0, 0, 0, 255))
	    draw.SimpleTextOutlined(text2, font, -(x2 / 2), y, col, 0, 0, 0.5, Color(0, 0, 0, 255))
	cam.End3D2D()

	cam.Start3D2D(self:GetPos() + self:GetUp() * 90, Angle(0, eye.y - 90, 90), .05)
		draw.SimpleTextOutlined(text, font, -(x / 2), 0, col, 0, 0, 0.5, Color(0, 0, 0, 255))
		draw.SimpleTextOutlined(text2, font, -(x2 / 2), y, col, 0, 0, 0.5, Color(0, 0, 0, 255))
	cam.End3D2D()
end