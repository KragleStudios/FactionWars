include("shared.lua")

function ENT:Initialize()
	fw.hook.Add("PostDrawTranslucentRenderables", "DrawFloatyText" .. self:EntIndex(), function()
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), CurTime() * 10)

		cam.Start3D2D(self:LocalToWorld(self:OBBCenter() + Vector(0, 0, 25 + math.sin(CurTime()))), ang, 0.1)
			draw.SimpleText("Weapon Grinder", fw.fonts.default:atSize(46), 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()

		ang:RotateAroundAxis(ang:Right(), 180)
		cam.Start3D2D(self:LocalToWorld(self:OBBCenter() + Vector(0, 0, 25 + math.sin(CurTime()))), ang, 0.1)
			draw.SimpleText("Weapon Grinder", fw.fonts.default:atSize(46), 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	fw.hook.Remove("PostDrawTranslucentRenderables", "DrawFloatyText" .. self:EntIndex())
end