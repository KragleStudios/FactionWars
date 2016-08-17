vgui.Register('fwNotificationFeed', {
	Init = function(self)
		self.BaseClass.Init(self)

		self:SetPadding(sty.ScreenScale(3))
		self._primaryNotification = nil
		self._panels = {}
	end,

	PanelsTotalHeight = function(self)
		local total = 0
		for k,v in ipairs(self._panels) do
			total = total + v:GetTall()
		end
		return total
	end,

	Push = function(self, panel)
		table.insert(self._panels, 1, panel)

		panel:SetTall(sty.ScreenScale(15))
		panel:SetAlpha(255)

		if IsValid(self._panels[2]) then
			local second = self._panels[2]
			second:SetTall(sty.ScreenScale(10))
			second:AlphaTo(100, 0.3, 0)
		end

		while self:PanelsTotalHeight() > sty.ScreenScale(300) do
			self:Pop()
		end
	end,

	Pop = function(self)
		if #self._panels == 0 then return end
		local toPop = self._panels[#self._panels]
		toPop:AlphaTo(0, 0.3, 0, function()
			toPop:Remove()
		end)
		self._panels[#self._panels] = nil
	end
}, 'STYLayoutVertical')

-- TODO: finish notifications
