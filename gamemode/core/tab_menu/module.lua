require 'sty'
fw.dep(CLIENT, 'hook')
fw.dep(CLIENT, 'fonts')
fw.dep(CLIENT, 'ui')

if SERVER then
	AddCSLuaFile()
	return 
end

fw.tab_menu = {}


vgui.Register('fwTabMenuTabButton', {
	Init = function(self)
		self.BaseClass.Init(self)
	end,

	PaintHovered = function(self, w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end,

	PaintPressed = function(self, w, h)
		surface.SetDrawColor(255, 255, 255, 10)
		surface.DrawRect(0, 0, w, h)

		self:PaintHovered(w, h)
	end,
}, 'STYButton')


vgui.Register('fwTabMenu', {
		Init = function(self)
			local p = sty.ScreenScale(2)

			self.navView = vgui.Create('STYLayoutVertical', self)
			self.navView.Paint = function(self, w, h)
			end
			self.navView:SetPadding(5)
		end,

		AddNavButton = function(self, title, doClick)
			local p = vgui.Create('fwTabMenuTabButton', self.navView)
			p:SetText(title)
			p:SetFont(fw.fonts.default)
			p:SetTall(sty.ScreenScale(20))

			p.DoClick = doClick or ra.fn.noop
		end,

		AddView = function(self, title, panelClass)

		end,

		PerformLayout = function(self)
			local p = sty.ScreenScale(2)
			self.navView:SetWide(sty.ScreenScale(100))

			self:SetSize(self.navView:GetWide() + 2 * p, self.navView:GetTall() + 2 * p)
			self.navView:SetPos(p, p)

			self:CenterVertical()
		end,

		Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 230)
			surface.DrawRect(0, 0, w, h)
		end,
	}, 'STYPanel')


fw.hook.Add('ScoreboardShow', function()
	fw.print("Opening tab menu")
	__FW_TABMENU = vgui.Create('fwTabMenu')
	__FW_TABMENU:AddNavButton("JOBS / FACTIONS", nil)
	__FW_TABMENU:AddNavButton("PLAYERS", nil)
	__FW_TABMENU:AddNavButton("COMMANDS", nil)

	-- animate into view
	__FW_TABMENU:PerformLayout()
	__FW_TABMENU:SetX(-__FW_TABMENU:GetWide())
	__FW_TABMENU:MoveTo(0, __FW_TABMENU:GetY(), 0.1)
	__FW_TABMENU:MakePopup()

	vgui.Create('FWUIDropShadow')
		:SetRadius(32)
		:SetColor(Color(0, 0, 0, 155))
		:ParentTo(__FW_TABMENU)
end)

fw.hook.Add('ScoreboardHide', function()
	fw.print("Closing tab menu")
	if IsValid(__FW_TABMENU) then
		__FW_TABMENU:MoveTo(-__FW_TABMENU:GetWide(), __FW_TABMENU:GetY(), 0.1, 0, -1, function()
			if IsValid(__FW_TABMENU) then
				__FW_TABMENU:Remove()
				__FW_TABMENU:MakePopup()
			end
		end)
	end
end)