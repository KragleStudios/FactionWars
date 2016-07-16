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

	PaintNormal = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, w, h)
	end,

	PaintHovered = function(self, w, h)
		self:PaintNormal(w, h)

		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end,

	PaintPressed = function(self, w, h)
		self:PaintNormal(w, h)

		self:PaintHovered(w, h)

		surface.SetDrawColor(255, 255, 255, 20)
		surface.DrawRect(0, 0, w, h)

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

		-- @arg title:string
		-- @arg keepOpen:bool should it stay open when tab is released 
		AddView = function(self, title, keepOpen, populate)
			sty.RestoreCursor('fw.tab_menu.' .. tostring(title))	
			self:AddNavButton(title, function()
				self:Hide(function() if IsValid(self) then self:Remove() end end)
				fw.tab_menu.displayContentPanel(function(panel)
					panel.keepOpen = keepOpen

					panel.OnRemove = function()
						sty.SaveCursor('fw.tab_menu.' .. tostring(title))
					end
				end)
			end)
		end,

		PerformLayout = function(self)
			local p = sty.ScreenScale(2)
			self.navView:SetWide(sty.ScreenScale(100))

			self:SetSize(self.navView:GetWide() + 2 * p, self.navView:GetTall() + 2 * p)
			self.navView:SetPos(p, p)

			self:CenterVertical()
		end,

		Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(0, 0, w, h)
		end,

		Show = function(self, onFinish)
			sty.RestoreCursor('fw.tabmenu')

			-- animate into view
			self:PerformLayout()
			self:SetX(-self:GetWide())
			self:MoveTo(0, self:GetY(), fw.config.uiAnimTimeQuick, 0, -1, onFinish or ra.fn.noop)
			self:MakePopup()

		end,

		Hide = function(self, onFinish)
			sty.SaveCursor('fw.tabmenu')

			self:MoveTo(-self:GetWide(), self:GetY(), fw.config.uiAnimTimeQuick, 0, -1, onFinish)
		end,

	}, 'STYPanel')


fw.hook.Add('ScoreboardShow', function()
	fw.print("Opening tab menu")

	local function open()

		__FW_TABMENU = vgui.Create('fwTabMenu')
		__FW_TABMENU:AddView("JOBS / FACTIONS", false)
		__FW_TABMENU:AddView("PLAYERS", false)
		__FW_TABMENU:AddView("COMMANDS", false)
		__FW_TABMENU:AddView("INVENTORY", false)
		__FW_TABMENU:Show()

		vgui.Create('FWUIDropShadow')
			:SetRadius(32)
			:SetColor(Color(0, 0, 0, 50))
			:SetNoBackground(true)
			:ParentTo(__FW_TABMENU)

	end 

	if IsValid(__FW_CONTENTPANEL) then
		fw.tab_menu.hideContentPanel(open)
	else 
		open()
	end
end)

fw.hook.Add('ScoreboardHide', function()
	fw.print("Closing tab menu")
	if IsValid(__FW_TABMENU) then
		__FW_TABMENU:Hide(function()
			if IsValid(__FW_TABMENU) then __FW_TABMENU:Remove() end
		end)
	end

	if IsValid(__FW_CONTENTPANEL) and not __FW_CONTENTPANEL.keepOpen then
		fw.tab_menu.hideContentPanel()
	end
end)