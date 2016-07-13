include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90)

	-- TODO: Optimze
	cam.Start3D2D(self:LocalToWorld(self:OBBMaxs()), ang, 0.2)
		surface.SetDrawColor(Color(0, 0, 0, 150))
		surface.DrawOutlinedRect(-155, -165, 150, 150)
		surface.DrawRect(-155, -165, 150, 150)
		surface.DrawOutlinedRect(-150, -160, 140, 140)
		surface.DrawRect(-150, -160, 140, 140)
		draw.SimpleText(self.Name, fw.fonts.default:atSize(fw.fonts.default:fitToView(150, 150, self.Name)), -80.5, -135, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		-- draw.SimpleText("Ink: " .. self:GetInk() .. "/" .. self.InkCap, fw.fonts.default:atSize(12), -40.25, -115, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Paper: " .. self:GetPaper() .. "/" .. self.PaperCap, fw.fonts.default:atSize(fw.fonts.default:fitToView(75, 150, "Paper: " .. self:GetPaper() .. "/" .. self.PaperCap)), -80.5, -110, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		-- draw.SimpleText("Money stored: $" .. self:GetMoney(), fw.fonts.default:atSize(fw.fonts.default:fitToView(150, 150, "Money stored: $" .. self:GetMoney())), -80.5, -85, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if self:GetPrintStatus() then
			draw.RoundedBox(0, -145, -85, 130, 24, Color(0, 0, 0))
			draw.RoundedBox(0, -145, -85, (1 - (self:GetNextPrintTime() - CurTime()) / self.PrintSpeed) * 130, 24, Color(39, 174, 96))
		else
			draw.RoundedBox(0, -145, -85, 130, 24, Color(math.abs(math.sin(CurTime() * 1.5)) * 180, math.abs(math.sin(CurTime() * 1.5)) * 57, math.abs(math.sin(CurTime() * 1.5)) * 43))
			draw.SimpleText("ERROR", fw.fonts.default:atSize(fw.fonts.default:fitToView(150, 150, "ERROR")), -80.5, -75, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end