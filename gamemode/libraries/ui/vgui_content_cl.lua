local panelBg = fw.ui.const_panel_background
local frameBg = fw.ui.const_frame_background

vgui.Register('FWUIPanel', {
	Paint = function(self, w, h)
		if not self._noBackground then 
			surface.SetDrawColor(panelBg)
			surface.DrawRect(0, 0, w, h)
		end

		if self._bgTint then
			surface.SetDrawColor(self._bgTint)
			surface.DrawRect(1, 1, w - 2, h - 2)
		end

		if not self._noOutline then 
			surface.SetDrawColor(255, 255, 255, 5)
			surface.DrawOutlinedRect(0, 0, w, h)
		end
	end,

	SetNoOutline = function(self, bOutline)
		self._noOutline = bOutline
	end,

	SetNoBackground = function(self, bNoBackground)
		self._noBackgruond = bNoBackground
	end,

	SetBackgroundTint = function(self, tint, intensity)
		if tint == nil then 
			self._bgTint = nil 
			return self 
		end

		self._bgTint = Color(tint.r, tint.g, tint.b, intensity or 40)

		return self 
	end,
}, 'STYPanel')

vgui.Register('FWUIButton', {

	Init = function(self)
		self.BaseClass.Init(self)

		self._bgTint = {}

		self:SetNoOutline(false)
		self:SetBackgroundTint('normal', nil)
		self:SetBackgroundTint('hovered', Color(255, 255, 255, 50), 10)
		self:SetBackgroundTint('pressed', Color(255, 255, 255, 100), 30)
	end,

	SetNoOutline = function(self, bOutline)
		self._noOutline = bOutline 
	end,

	SetNoBackground = function(self, bBackground)
		self._noBackground = bBackground 
	end,

	PerformLayout = function(self)
		self.BaseClass.PerformLayout(self)
	end,

	-- KEY = normal or hovered or pressed
	SetBackgroundTint = function(self, key, tint, intensity)
		if tint == nil then 
			self._bgTint[key] = nil 
			return self 
		end

		self._bgTint[key] = Color(
			tint.r * 0.3 + 255 * 0.7, 
			tint.g * 0.3 + 255 * 0.7, 
			tint.b * 0.3 + 255 * 0.7, 
			intensity or 100)

		return self 
	end,

	PaintBackground= function(self, w, h)
		if not self._noBackground then 
			surface.SetDrawColor(panelBg)
			surface.DrawRect(0, 0, w, h)
		end
	end,

	PaintNormal = function(self, w, h)
		self:PaintBackground(w, h)

		if self._bgTint['normal'] then
			surface.SetDrawColor(self._bgTint['normal'])
			surface.DrawRect(1, 1, w - 2, h - 2)
		end
	end,

	PaintHovered = function(self, w, h)
		self:PaintBackground(w, h)

		if self._bgTint['hovered'] then
			surface.SetDrawColor(self._bgTint['hovered'])
			surface.DrawRect(1, 1, w - 2, h - 2)
		end
	end,

	PaintPressed = function(self, w, h)
		self:PaintBackground(w, h)

		if self._bgTint['pressed'] then
			surface.SetDrawColor(self._bgTint['pressed'])
			surface.DrawRect(1, 1, w - 2, h - 2)
		end
	end,

	PaintOver = function(self, w, h)
		if not self._noOutline then 
			surface.SetDrawColor(255, 255, 255, 5)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		end
	end,

}, 'STYButton')

vgui.Register('FWUIFrame', {
	Init = function(self)
		self._shaddow = vgui.Create('FWUIDropShadow')
			:SetColor(Color(0, 0, 0, 150))
			:SetRadius(32)
			:SetNoBackground(true)
			:ParentTo(self)

		self._titleBar = vgui.Create('FWUIPanel', self)
		self._titleBar._titleLabel = Label('Unnamed Frame', self._titleBar)
		self._titleBar:SetBackgroundTint(color_black, 200)

		self._titleBar.OnMousePressed = function(self)
			local xoffset, yoffset = self:GetParent():CursorPos()
			self:SetBackgroundTint(color_black, 130)

			self.Think = function()
				if input.IsMouseDown(MOUSE_LEFT) then
					local x, y = input.GetCursorPos()
					self:GetParent():SetPos(x - xoffset, y - yoffset)
				else
					self:SetBackgroundTint(color_black, 200)
					self.Think = ra.util.noop 
				end
			end
		end
		self:SetMouseInputEnabled(true)

		self._titleBar._closeButton = sty.With(vgui.Create('FWUIButton', self._titleBar))
			:SetFont(fw.fonts.default)
			:SetText('X')
			:Dock(RIGHT)
			:SetNoBackground(true)
			:SetNoOutline(true) ()
		self._titleBar._closeButton.DoClick = function()
			self:DoClose()
		end
	end,

	DoClose = function(self)
		self:Remove()
	end,


	SetShowClose = function(self, bShowClose)
		self._titleBar._closeButton:SetVisible(bShowClose)
	end,

	SetCanDrag = function(self, bCanDrag)
		self._titleBar:SetMouseInputEnabled(bCanDrag)
	end,

	SetTitle = function(self, text)
		self._titleBar._titleLabel:SetText(text:upper())
	end,

	PerformLayout = function(self)
		if self:GetTall() < sty.ScreenScale(20) then
			self:SetTall(sty.ScreenScale(20))
		end

		local w, h = self:GetSize()

		self._titleBar:SetSize(w, sty.ScreenScale(13))
		sty.With(self._titleBar._titleLabel)
			:SetFont(
				fw.fonts.default:fitToView(
					self._titleBar,
					sty.ScreenScale(1), 
					self._titleBar._titleLabel:GetText()))
			:SizeToContents()
			:SetX(sty.ScreenScale(5))
			:CenterVertical()

		self._titleBar._closeButton:SetSize(self._titleBar:GetTall(), self._titleBar:GetTall())
	end,

	OnRemove = function(self)
		self._shaddow:Remove()
	end,

	SetShowShadow = function(self, shouldShow)
		self._shaddow:SetVisible(shouldShow)
	end,

	GetHeaderYOffset = function(self) -- the yoffset for content demmanded by the space used by the header
		return self._titleBar:GetTall() 
	end,

	Paint = function(self, w, h)
		surface.SetDrawColor(frameBg)
		surface.DrawRect(0, 0, w, h)
	end,
}, 'EditablePanel')

concommand.Add('fw_ui_testFrame', function()
	if IsValid(__FWUI_TESTFRAME) then
		__FWUI_TESTFRAME:Remove()
	end
	__FWUI_TESTFRAME = vgui.Create('FWUIFrame')
	sty.With(__FWUI_TESTFRAME)
		:SetSize(400, 400)
		:Center()
		:MakePopup()
end)