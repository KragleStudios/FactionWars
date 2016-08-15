local matH = Material "kragle/drop-shadow-h.png"
local matV = Material "kragle/drop-shadow-v.png"

vgui.Register("FWUIDropShadow", {
	Init = function(self)
		self:SetRadius(32)
		self:SetColor(color_black)
	end,

	SetRadius = function(self, radius)
		self._radius = radius

		return self 
	end,

	SetColor = function(self, color)
		self._color = color

		return self  
	end,

	SetNoBackground = function(self, noBackground)
		self._noBackground = noBackground 
		return self 
	end,

	ParentTo = function(self, panel)
		self._following = panel
		self:SetParent(panel:GetParent())

		return self 
	end,

	Paint = function(self, w, h)
		local panel = self._following
		if not IsValid(panel) then self:Remove() return end
		self:SetPos(panel:GetX() - self._radius, panel:GetY() - self._radius)
		self:SetSize(panel:GetWide() + self._radius * 2, panel:GetTall() + self._radius * 2)

		local r = self._radius 

		surface.SetDrawColor(self._color)

		if self._noBackground then
			surface.DrawRect(r, r, w - 2 * r, h - 2 * r)
		end

		surface.SetMaterial(matH)
		-- top horizontal
		surface.DrawTexturedRectUV(r, 0, w - 2*r, r, 0, 1, 0.5, 0)
		-- bottom horizontal
		surface.DrawTexturedRectUV(r, h - r, w - 2*r, r, 0, 0, 0.5, 1)


		-- top left corner
		surface.DrawTexturedRectUV(0, 0, r, r, 1, 1, 0.5, 0)
		surface.DrawTexturedRectUV(w - r, 0, r, r, 0.5, 1, 1, 0)

		surface.DrawTexturedRectUV(0, h - r, r, r, 1, 0, 0.5, 1)
		surface.DrawTexturedRectUV(w - r, h - r, r, r, 0.5, 0, 1, 1)


		surface.SetMaterial(matV)
		-- left vertical 
		surface.DrawTexturedRectUV(0, r, r, h - 2*r, 0, 0, 1, 0.5)
		-- right vertical
		surface.DrawTexturedRectUV(w - r, r, r, h - 2*r, 1, 0, 0, 0.5)
		
	end,

}, "STYPanel")


concommand.Add("fw_ui_dropShadowTest", function()
	local frame = vgui.Create("DFrame")
	frame:SetSize(300, 300)
	frame:Center()
	frame:MakePopup()

	local shadow = vgui.Create("FWUIDropShadow", frame)
	shadow:ParentTo(frame)
end)