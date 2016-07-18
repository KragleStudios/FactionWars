vgui.Register('FWUITableViewSection', {
	Init = function(self)
		self.header = vgui.Create('FWUIButton', self)
		self.contentWrapper = vgui.Create('STYPanel', self)
		self.content = vgui.Create('STYLayoutVertical', self.contentWrapper)
		self.expanded = true

		self.header.DoClick = function()
			self.expanded = not self.expanded 
			if self.expanded then 
				self.content:SizeTo(self:GetWide(), self.content:GetTall(), fw.config.uiAnimTimeQuick)
			else
				self.content:SizeTo(self:GetWide(), 0, fw.config.uiAnimTimeQuick)
			end
		end
	end,

	SetTitle = function(self, text)
		self.header:SetText(text)
		self.header:SetFont(fw.fonts.default)
	end,

	SetTitleTint = function(self, tint, intensity)
		self.header:SetBackgroundTint('normal', tint, 10)
		self.header:SetBackgroundTint('hovered', tint, 25)
		self.header:SetBackgroundTint('pressed', tint, 50)
	end,

	OnChildAdded = function(self, child)
		child:SetParent(self.content)
		self:InvalidateLayout()
	end,

	Add = function(self, child)
		child:SetParent(self.content)
		self:InvalidateLayout()
	end,

	PerformLayout = function(self)
		local w, h = self:GetSize()

		self.header:SetSize(self:GetWide(), sty.ScreenScale(12))

		self.contentWrapper:SetWide(w)
		self.content:SetWide(w)
		self.content:SetPadding(sty.ScreenScale(2))

		if self.expanded then 
			self.contentWrapper:SetTall(self.content:GetTall())
		else
			self.contentWrapper:SetTall(0)
		end
		
		self.contentWrapper:SetPos(0, self.content._padding + self.header:GetTall())

		self:SetTall(self.header:GetTall() + self.contentWrapper:GetTall() + self.content._padding * 2)
	end,
}, 'STYPanel')

