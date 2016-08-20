vgui.Register('fwNotificationFeed', {
	Init = function(self)
		self.BaseClass.Init(self)

		self._primaryNotification = nil
		self._panels = {}
	end,

	PerformLayout = function(self)

		local p = sty.ScreenScale(1)

		self:SetPos(sty.ScrW - self:GetWide(), p)

		local panels = self._panels
		local y = p
		local width = sty.ScreenScale(300)

		if panels[1] then
			panels[1]:SetPos(0, p)
			panels[1]:SetWide(width * 1.1)

			y = y + panels[1]:GetTall() + p

			for i = 2, #panels, 1 do
				local panel = panels[i]
				panel:SetPos(width * 0.1, y)
				panel:SetWide(width)
				y = y + panel:GetTall() + p
			end
		end

		self:SetSize(width * 1.1, y)

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

		panel:SetParent(self)
		panel:SetTall(sty.ScreenScale(14))
		panel:SetAlpha(255)

		if IsValid(self._panels[2]) then
			local second = self._panels[2]
			second:SetTall(sty.ScreenScale(11))
			second:AlphaTo(150, 0.3, 0)
		end

		while self:PanelsTotalHeight() > sty.ScreenScale(100) do
			self:Pop()
		end
	end,

	Pop = function(self, panel)
		if #self._panels == 0 then return end
		local toPop = panel or self._panels[#self._panels]
		toPop:AlphaTo(0, 0.3, 0, function()
			toPop:Remove()
			self:InvalidateLayout()
		end)
		table.RemoveByValue(self._panels, toPop)
	end
}, 'STYPanel')

sty.WaitForLocalPlayer(function()
	if IsValid(__FW_FEED) then
		__FW_FEED:Remove()
	end
	fw.hud.notifFeed = vgui.Create('fwNotificationFeed')
	__FW_FEED = fw.hud.notifFeed
end)

vgui.Register('fwNotificationRow', {
	SetMessage = function(self, prefix, message)
		self._prefix = prefix
		self._message = message

		self._prefixLabel = Label(prefix, self)
		self._messageLabel = Label(message, self)
		self._timeLabel = Label(os.date('%I:%M:%S %p'), self)
		self._timeLabel:SetTextColor(Color(255, 255, 255, 50))
		self._timeLabel:SizeToContents()
	end,

	PerformLayout = function(self)
		if not IsValid(self._prefixLabel) or not IsValid(self._messageLabel) then return end

		local p = sty.ScreenScale(2)

		local textW, textH = self:GetWide() - 2 * p, self:GetTall() - 2 * p

		local fontBold = fw.fonts.default_bold:fitToView(textW, textH, self._prefix)
		local fontNormal = fw.fonts.default:fitToView(textW, textH, self._message)
		local fontNormalTime = fw.fonts.default:fitToView(textW, textH - p, self._message)


		self._prefixLabel:SetFont(fontBold)
		self._messageLabel:SetFont(fontNormal)
		self._timeLabel:SetFont(fontNormalTime)
		self._prefixLabel:SizeToContents()
		self._messageLabel:SizeToContents()
		self._timeLabel:SizeToContents()

		self._prefixLabel:SetX(p, p, self._prefixLabel)
		self._prefixLabel:CenterVertical()
		self._messageLabel:SetPos(p * 3 + self._prefixLabel:GetWide(), self._prefixLabel:GetY() + self._prefixLabel:GetTall() - self._messageLabel:GetTall())
		self._messageLabel:CenterVertical()
		self._timeLabel:SetPos(self:GetWide() - self._timeLabel:GetWide() - p * 3, 0)
		self._timeLabel:CenterVertical()
	end,

	Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
	end,
})

function fw.hud.pushNotification(headerText, bodyString, bodyColor)
	if not IsValid(LocalPlayer()) then
		sty.WaitForLocalPlayer(function()
			fw.hud.addNotification(headerText, bodyString, bodyColor)
		end)
	end

	local notif = vgui.Create('fwNotificationRow')
	fw.hud.notifFeed:Push(notif)

	notif:SetMessage(headerText, bodyString)

	if bodyColor then
		notif._messageLabel:SetTextColor(bodyColor)
	end
end
