include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90)

	-- TODO: Optimze
	cam.Start3D2D(self:LocalToWorld(self:OBBMaxs()), ang, 0.2)
		draw.RoundedBox(0, -155, -165, 150, 150, self.Color)
		draw.SimpleText(self.Name, fw.fonts.default:atSize(fw.fonts.default:fitToView(150, 150, self.Name)), -80.5, -135, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Ink: " .. self:GetInk() .. "/" .. self.InkCap, fw.fonts.default:atSize(fw.fonts.default:fitToView(75, 150, "Ink: " .. self:GetInk() .. "/" .. self.InkCap)), -40.25, -115,Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Paper: " .. self:GetPaper() .. "/" .. self.PaperCap, fw.fonts.default:atSize(fw.fonts.default:fitToView(75, 150, "Paper: " .. self:GetPaper() .. "/" .. self.PaperCap)), -117.75, -115, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		-- draw.SimpleText("Money stored: $" .. self:GetMoney(), fw.fonts.default:atSize(fw.fonts.default:fitToView(150, 150, "Money stored: $" .. self:GetMoney())), -80.5, -85, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if self:GetPrintStatus() then
			draw.RoundedBox(0, -145, -85, 130 , 24, Color(0, 0, 0))
			draw.RoundedBox(0, -145, -85, (1 - (self:GetNextPrintTime() - CurTime()) / self.PrintSpeed) * 130, 24, Color(0, 255, 0))
		else
			draw.RoundedBox(0, -145, -85, 130, 24, Color(math.abs(math.sin(CurTime() * 1.5)) * 255, 0, 0))
			draw.SimpleText("ERROR", fw.fonts.default:atSize(fw.fonts.default:fitToView(150, 150, "ERROR")), -80.5, -75, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end