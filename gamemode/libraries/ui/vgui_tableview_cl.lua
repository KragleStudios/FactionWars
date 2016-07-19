vgui.Register('FWUITableViewSection', {
	Init = function(self)
		self.header = vgui.Create('FWUIButton', self)
		self.contentWrapper = vgui.Create('STYPanel', self)
		self.content = vgui.Create('STYLayoutVertical', self.contentWrapper)
		self.expanded = true
		self._padding = 0

		self.header.DoClick = function()
			self.expanded = not self.expanded
			self._animating = true 
			if self.expanded then 
				self.contentWrapper:SizeTo(self:GetWide(), self.content:GetTall(), fw.config.uiAnimTimeSlower, 0, -1, function()
					self._animating = false
					self:InvalidateLayout()
				end)
			else
				self.contentWrapper:SizeTo(self:GetWide(), 0, fw.config.uiAnimTimeSlower, 0, -1, function()
					self._animating = false
					self:InvalidateLayout()
				end)
			end
		end
	end,

	SetPadding = function(self, padding)
		self._padding = self:GetPadding()
		self.content:SetPadding(padding)

		return self 
	end,


	SetTitle = function(self, text)
		self.header:SetText(text)
		self.header:SetFont(fw.fonts.default)
		
		return self 
	end,

	SetTitleTint = function(self, tint, intensity)
		self.header:SetBackgroundTint('normal', tint, 10)
		self.header:SetBackgroundTint('hovered', tint, 25)
		self.header:SetBackgroundTint('pressed', tint, 50)
		
		return self 
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
		if self._animating then return end 

		local w, h = self:GetSize()

		self.header:SetSize(self:GetWide(), sty.ScreenScale(12))

		self.contentWrapper:SetWide(w - self._padding * 2) 
		self.content:SetWide(w - self._padding * 2)
		self.content:SetPadding(sty.ScreenScale(2))

		if self.expanded then 
			self.contentWrapper:SetTall(self.content:GetTall())
		else
			self.contentWrapper:SetTall(0)
		end
		
		self.contentWrapper:SetPos(self._padding, self._padding + self.header:GetTall())

		self:SetTall(self.header:GetTall() + self.contentWrapper:GetTall() + self._padding * 2)
	end,
}, 'FWUIPanel')

