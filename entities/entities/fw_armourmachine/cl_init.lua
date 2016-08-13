include("shared.lua")

function ENT:InitializeVGUI()
	if IsValid(self._panel) then return end 

	local font = fw.fonts.default:fitToView(470, 45, "CHARGE")
	local pnl = vgui.Create("DPanel")
	pnl:SetSize(470, 150)
	pnl.Paint = function(pnl, w, h)
		surface.SetDrawColor(40, 40, 45, 255)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText("CHARGE", font, w / 2, h - 45 / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local chargeBar = vgui.Create("DPanel", pnl)
	chargeBar:SetPos(0, 0)
	chargeBar:SetSize(pnl:GetWide(), pnl:GetTall() - 45)

	local maxBars = 8
	local space = 10
	local barWidth = (chargeBar:GetWide() - space * (maxBars + 1) - 4) / maxBars

	chargeBar.Paint = function(pnl, w, h)
		local charge, maxCharge = self:GetCharge(), self:GetMaxCharge()
		local fr = charge / maxCharge

		surface.SetDrawColor(50, 50, 53, 255)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(200 - 200 * fr, 200 * fr, 30, 80)
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

		for i = 1, maxBars do
			local prev = i - 1
			local barFraction = i <= 0 and 0 or (prev / maxBars)
			if fr <= barFraction then continue end
			surface.DrawRect(space + 2 + (barWidth + space) * (i - 1), space + 2, barWidth, h - space * 2 - 4)
		end
	end

	self._panel = pnl
end

function ENT:Draw()
	self:DrawModel()

	if not IsValid(self._panel) then return end

	local offset = self:GetUp() * 24.2 + self:GetForward() * 13 + self:GetRight() * -4.25
	local ang = self:GetAngles()

	ang:RotateAroundAxis(self:GetUp(), 90)
	ang:RotateAroundAxis(-self:GetRight(), 90)

	self._panel:Draw3D(self:GetPos() + offset, ang, 0.05)
end

function ENT:Initialize()
	self:InitializeVGUI()
end