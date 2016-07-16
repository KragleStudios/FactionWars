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

		AddView = function(self, title, constructor)
			self:AddNavButton(title, function()
				fw.tab_menu.hideScoreboard()
				fw.tab_menu.displayContent(title, constructor, function() end)
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
	fw.tab_menu.showScoreboard()
end)

fw.hook.Add('ScoreboardHide', function()
	fw.tab_menu.hideScoreboard()
end)


function fw.tab_menu.showScoreboard()
	fw.print("Opening tab menu")

	fw.tab_menu.hideContent(function()

		__FW_TABMENU = vgui.Create('fwTabMenu')
		__FW_TABMENU:Show()

		__FW_TABMENU:AddView('PLAYERS', fw.tab_menu.tabDisplayPlayersList)
		__FW_TABMENU:AddView('JOBS', fw.tab_menu.tabDisplayJobsList)


		vgui.Create('FWUIDropShadow')
			:SetRadius(32)
			:SetColor(Color(0, 0, 0, 50))
			:ParentTo(__FW_TABMENU)
	end)
end

function fw.tab_menu.hideScoreboard(callback)
	fw.print("Closing tab menu")
	if IsValid(__FW_TABMENU) then
		__FW_TABMENU:Hide(function()
			if IsValid(__FW_TABMENU) then __FW_TABMENU:Remove() end
			if callback then callback() end
		end)
	end
end


function fw.tab_menu.hideContent(callback)
	if IsValid(__FW_TABMENU_CONTENT) then
		local content = __FW_TABMENU_CONTENT
		content:MoveTo(content:GetX(), sty.ScrH, fw.config.uiAnimTimeQuick, 0, -1, function()
			content:Remove()
			if callback then callback() end
		end)
		return 
	end

	callback()
end

function fw.tab_menu.displayContent(title, constructor, callback)
	lastContentName = title 

	fw.tab_menu.hideContent(function()

		__FW_TABMENU_CONTENT = vgui.Create('FWUIFrame')
		local content = __FW_TABMENU_CONTENT

		content:SetSize(sty.ScrH * 0.7, sty.ScrH * 0.7)
		content:MakePopup()
		content:SetTitle(title or 'Unknown Content Panel')
		content:CenterHorizontal()
		content.DoClose = function()
			fw.tab_menu.hideContent()
		end

		content:SetY(sty.ScrH)
		content:MoveTo(
			content:GetX(), 
			(sty.ScrH - content:GetTall()) * 0.5, 
			fw.config.uiAnimTimeQuick, 0, -1, 
			callback or ra.fn.noop)

		constructor(content)
	end)
end


function fw.tab_menu.tabDisplayPlayersList(panel)

	local space = vgui.Create('DScrollPanel', panel)
	space:SetSize(panel:GetWide() - 10, panel:GetTall() - panel:GetHeaderYOffset())
	space:SetPos(5, panel:GetHeaderYOffset())

	local listLayout = vgui.Create('STYLayoutVertical', space)
	listLayout:SetWide(panel:GetWide())
	listLayout:SetPadding(sty.ScreenScale(2))

	for k, v in pairs(player.GetAll()) do
		local panel = vgui.Create('FWUIButton', listLayout)
		panel:SetFont(fw.fonts.default)
		panel:SetTall(sty.ScreenScale(15))
		panel:SetText(v:Nick())

		panel.DoClick = function()
			// more info popup or something
		end

		panel:PerformLayout()
	end
end

function fw.tab_menu.tabDisplayJobsList(panel)
	local space = vgui.Create('DScrollPanel', panel)
	space:SetSize(panel:GetWide() - 10, panel:GetTall() - panel:GetHeaderYOffset())
	space:SetPos(5, panel:GetHeaderYOffset())

	local listLayout = vgui.Create('STYLayoutVertical', space)
	listLayout:SetWide(panel:GetWide())
	listLayout:SetPadding(sty.ScreenScale(2))

	
end