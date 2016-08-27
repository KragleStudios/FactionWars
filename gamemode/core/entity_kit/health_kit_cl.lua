local Entity = FindMetaTable('Entity')

function Entity:FWDrawHealth(pos, ang, radius)
	if LocalPlayer():GetEyeTrace().Entity ~= self then return end

	local maxHealth = self.MaxHealth
	local health = self:GetHealth()

	radius = radius * 10

	cam.Start3D2D(pos, ang, 0.1)
		draw.NoTexture()
		surface.SetDrawColor(0, 0, 0, 255)
		ra.surface.DrawArc(0, 0, radius, radius + 30, 0, 360, 30)
		surface.SetDrawColor(100, 255, 100, 100)
		ra.surface.DrawArc(0, 0, radius, radius + 10, 0, 360 * (health / maxHealth), 30)
	cam.End3D2D()
end
