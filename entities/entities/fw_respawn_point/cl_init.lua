include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if (LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000 * 1000) then return end

	local own = self:GetNWEntity("owner")

	local font = fw.fonts.default:atSize(30)
	local text = (IsValid(own) and own:Nick() or "owner") .. "'s "
	local text2 = "Spawn Point"
	local col = own:IsPlayer() and fw.team.factions[own:getFaction()].color or Color(255, 255, 255)

	surface.SetFont(font)
	local x = surface.GetTextSize(text)
	local x2, y = surface.GetTextSize(text2)

	local rotation = CurTime() * 11

	cam.Start3D2D(self:GetPos() + self:GetUp() * 90, Angle(0, rotation, 90), .25)
		draw.DrawText(text, font, -(x / 2), 0, col)
		draw.DrawText(text2, font, -(x2 / 2), y, col)
	cam.End3D2D()

	cam.Start3D2D(self:GetPos() + self:GetUp() * 90, Angle(0, rotation + 180, 90), .25)
		draw.DrawText(text, font, -(x / 2), 0, col)
		draw.DrawText(text2, font, -(x2 / 2), y, col)
	cam.End3D2D()
end