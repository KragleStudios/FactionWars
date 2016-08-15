vgui.Register("FWUITableViewSection", {
	Init = function(self)
		self.header = vgui.Create("FWUIButton", self)
		self.contentWrapper = vgui.Create("STYPanel", self)
		self.content = vgui.Create("STYLayoutVertical", self.contentWrapper)
		self.expanded = true
		self:SetPadding(0)

		self.header.DoClick = function()
			if self._animating then return end

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

		sty.Detour(self.contentWrapper, "PerformLayout", function()
			self:PerformLayout()
		end)
	end,

	SetPadding = function(self, padding)
		self._padding = padding
		self.content:SetPadding(padding)

		return self 
	end,


	SetTitle = function(self, text)
		self.header:SetText(text)
		self.header:SetFont(fw.fonts.default)
		
		return self 
	end,

	SetTitleTint = function(self, tint, intensity)
		self.header:SetBackgroundTint("normal", tint, 10)
		self.header:SetBackgroundTint("hovered", tint, 25)
		self.header:SetBackgroundTint("pressed", tint, 50)
		
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
		local w, h = self:GetSize()

		self.content:PerformLayout()

		if not self._animating then 
			self.header:SetSize(self:GetWide(), sty.ScreenScale(12))

			self.content:SetWide(w - self._padding * 2)

			if self.expanded then 
				self.contentWrapper:SetTall(self.content:GetTall())
			else
				self.contentWrapper:SetTall(0)
			end
		end
		
		self.contentWrapper:SetWide(w - self._padding * 2)
		self.contentWrapper:SetPos(self._padding, self._padding + self.header:GetTall())
		self:SetTall(self.header:GetTall() + self.contentWrapper:GetTall() + (self.expanded and self._padding * 2 or 0))
		
		local parent = self:GetParent()
		if IsValid(parent) and parent.PerformLayout then
			parent:PerformLayout()
		end
	end,

	SizeToContents = function(self)
		self._animating = nil
		self:PerformLayout()
	end,
}, "FWUIPanel")

vgui.Register("FWUITableViewItem", {
	SetText = function(self, text)
		if self._text then
			self._text:SetText(text)
			return self 
		end

		self._text = vgui.Create("FWUITextBox", self)
		self._text:DockMargin(sty.ScreenScale(2), sty.ScreenScale(1), sty.ScreenScale(1), 0)
		self._text:Dock(FILL)
		self._text:SetFont(fw.fonts.default)
		self._text:SetText(text)

		return self 
	end,

	AddButton = function(self, title, doClick)
		local button = vgui.Create("FWUIButton", self)
		button:SetFont(fw.fonts.default)
		button:SetText(title)
		button:Dock(RIGHT)
		button:DockMargin(sty.ScreenScale(1), 0, 0, 0)
		button.DoClick = doClick 

		return button 
	end,
}, "FWUIPanel")