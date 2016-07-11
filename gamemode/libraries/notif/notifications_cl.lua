net.Receive('fw.notif.conprint', function()
	-- i never said it was pretty
	local function printHelper(a, ...)
		fw.print('[notif] ' .. (a or ''), ...)
	end
	printHelper(unpack(net.ReadTable()))
end)

net.Receive('fw.notif.chatprint', function()
	local table = net.ReadTable()
	chat.AddText(unpack(table))
end)

vgui.Register('fwNotification', {
		Init = function(self)
			self.titleLabel = sty.With(Label('', self))
				:SetTextColor(Color(20, 20, 20)) ()
			self.messageLabel = sty.With(Label('', self))
				:SetTextColor(Color(20, 20, 20)) ()
		end,

		SetTitle = function(self, text)
			self.titleLabel:SetText(text)

			self:InvalidateLayout()
		end,

		SetMessage = function(self, text)
			self.messageLabel:SetText(text)

			self:InvalidateLayout()
		end,

		SetTimeout = function(self, timer, onDistroy)
			timer.Simple(timer, function()
				self:AlphaTo(0, 0.5, 0, function()
					if IsValid(self) then self:Remove() end
					if onDistroy then onDistory() end
				end)
			end)
		end,

		PerformLayout = function(self)
			self:SetSize(sty.ScrW, sty.ScreenScale(100))

			local p = sty.ScreenScale(4) * 2 -- padding

			self.titleLabel:SetSize(self:GetWide(), self:GetTall() * 0.6)
			self.messageLabel:SetSize(self:GetWide(), self:GetTall() * 0.4)
			self.messageLabel:SetPos(0, self.titleLabel:GetTall())

			self.titleLabel:SetFont(
					fw.fonts.default:fitToView(
						self.titleLabel:GetWide() - p, 
						self.titleLabel:GetWide() - p, 
						self.titleLabel:GetText()
				))

			self.messageLabel:SetFont(
					fw.fonts.default:fitToView(
						self.titleLabel:GetWide() - p, 
						self.titleLabel:GetWide() - p, 
						self.titleLabel:GetText()
				))
		end,

		Paint = function(self, w, h) 
			surface.SetDrawColor(240, 240, 240, 240)
			surface.DrawRect(0, 0, w, h)
		end,

	}, 'STYPanel')

