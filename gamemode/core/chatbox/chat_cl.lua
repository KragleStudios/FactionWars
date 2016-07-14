include('chat_config.lua')

local function RichTextFadeAway()
	if (timer.Exists("chatBox_RichTextTransparency")) then
		timer.Remove("chatBox_RichTextTransparency")
	end

	timer.Create("chatBox_RichTextTransparency", chatBox.FadeAwayTime, 1, function()
		if (chatBox.Opened) then
			return
		end

		chatBox.RichTextTargetTransparency = 0
	end)
end

function chat.AddText(...)
	if (not (chatBox.Initialized)) then
		return
	end

	local Args = {...}

	chatBox.RichText:InsertColorChange(255, 255, 255, 255)

	for i = 1, #Args do

		local Arg = Args[i]
		local Type = type(Arg)

		if (Type == "string") then
			chatBox.RichText:AppendText(Arg)
		elseif (Type == "table") then

			local c = {
				r = Arg.r or 255,
				g = Arg.g or 255,
				b = Arg.b or 255,
				a = Arg.a or 255
			}

			chatBox.RichText:InsertColorChange(c.r, c.g, c.b, c.a)

		elseif (Type == "Player") then
			local c = team.GetColor(Arg:Team())

			chatBox.RichText:InsertColorChange(c.r, c.g, c.b, c.a)
			chatBox.RichText:AppendText(Arg:Name())
		else
			chatBox.RichText:InsertColorChange(255, 255, 255, 255)
			chatBox.RichText:AppendText(tostring(Arg))
		end
	end

	chatBox.RichText:AppendText("\n")
	chatBox.RichText:GotoTextEnd()

	chatBox.RichTextTargetTransparency = 1

	RichTextFadeAway()
end

local BlurscreenMaterial = Material("pp/blurscreen")

local function DrawBlur( Panel, Intensity )
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(BlurscreenMaterial)

	local x, y = Panel:ScreenToLocal(0, 0)

	for i = 1, 3 do

		BlurscreenMaterial:SetFloat("$blur", ((i / 3) * 5) * Intensity)
		BlurscreenMaterial:Recompute()

		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect(x, y, ScrW(), ScrH())
	end
end

function chatBox:Init()
	if (self.Frame) then
		self.Frame:Remove()
	end

	local HiddenFrame = vgui.Create("DFrame")
	HiddenFrame:SetSize(self.Width, self.Height)
	HiddenFrame:SetPos(self.HorizontalMargin, ScrH() - self.Height - chatBox.VerticalMargin)
	HiddenFrame:ShowCloseButton(false)
	HiddenFrame:SetTitle("")

	function HiddenFrame:Paint(Width, Height)
		return true
	end

	local Panel = vgui.Create("DPanel", HiddenFrame)
	Panel:SetSize(self.Width, self.Height)
	Panel:SetPos(0, 0)

	function Panel:Paint(Width, Height)
		if (chatBox.Transparency > 0) then
			DrawBlur(self, chatBox.Transparency)
		end

		local c = table.Copy(chatBox.FrameColor)
		local t = c.a
		c.a = chatBox.Transparency * t

		surface.SetDrawColor(c)
		surface.DrawRect(0, 0, Width, Height)

		local c = table.Copy(chatBox.OutlineColor)
		local t = c.a
		c.a = chatBox.Transparency * t

		surface.SetDrawColor(c)
		surface.DrawOutlinedRect(0, 0, Width, Height)

		-- Typing area

		local x = chatBox.OuterMargin
		local y = Height - chatBox.InputHeight - chatBox.OuterMargin
		local w = Width - chatBox.OuterMargin * 2
		local h = chatBox.InputHeight

		local c = table.Copy(chatBox.InputColor)
		local t = c.a
		c.a = chatBox.Transparency * t

		surface.SetDrawColor(c)
		surface.DrawRect(x, y, w, h)

		local c = table.Copy(chatBox.OutlineColor)
		local t = c.a
		c.a = chatBox.Transparency * t

		surface.SetDrawColor(c)
		surface.DrawOutlinedRect(x, y, w, h)

	end

	local RichText = vgui.Create("RichText", Panel)
	RichText:Dock(FILL)
	RichText:DockMargin(self.OuterMargin, self.OuterMargin, self.OuterMargin, 0)

	function RichText:PerformLayout()
		self:SetFontInternal("ChatFont")
	end

	function RichText:Think()
		self:SetAlpha(chatBox.RichTextTransparency * 255)
	end

	local TextEntry = vgui.Create("DTextEntry", Panel)
	TextEntry:SetTall(chatBox.InputHeight)
	TextEntry:Dock(BOTTOM)
	TextEntry:DockMargin(self.OuterMargin, self.InnerMargin, self.OuterMargin, self.OuterMargin)
	TextEntry:SetUpdateOnType(true)
	TextEntry:SetDrawBackground(false)
	TextEntry:SetFont("ChatFont")
	TextEntry:SetTextColor(Color(255, 255, 255))
	TextEntry:SetCursorColor(Color(255, 255, 255))

	function TextEntry:Think()
		local c = table.Copy(chatBox.TextColor)
		local t = c.a
		c.a = chatBox.Transparency * t

		self:SetTextColor( c )

		local c = table.Copy(chatBox.CursorColor)
		local t = c.a
		c.a = chatBox.Transparency * t

		self:SetCursorColor(c)
	end

	function TextEntry:OnValueChange(String)
		if (#String > chatBox.MaxMessageLength) then
			self:SetText(String:sub(1, chatBox.MaxMessageLength))
			self:SetCaretPos(chatBox.MaxMessageLength)
		end
	end

	function TextEntry:OnEnter()
	       	if (self:GetValue() != "") then
			RunConsoleCommand("say" .. (chatBox.Teamed and "_team" or ""), self:GetValue())
		end
		chatBox:Close()
	end
	self.Frame = HiddenFrame
	self.RichText = RichText
	self.TextEntry = TextEntry
end

function chatBox:Open(TeamChat)
	if (not (IsValid(self.Frame))) then
		return
	end

	self.Opened = true
	self.Teamed = TeamChat
	self.TargetTransparency = 1
	self.RichTextTargetTransparency = 1

	self.Frame:MakePopup()
	self.TextEntry:RequestFocus()

	self.RichText:SetVerticalScrollbarEnabled(true)
end

function chatBox:Close()
	if (not(IsValid(self.Frame))) then
		return
	end

	self.Opened = false
	self.Teamed = false
	self.TargetTransparency = 0

	RichTextFadeAway()

	self.Frame:SetMouseInputEnabled(false)
	self.Frame:SetKeyboardInputEnabled(false)

	self.TextEntry:SetText("")

	self.RichText:SetVerticalScrollbarEnabled(false)

	chat.Close()
end

fw.hook.Add( "StartChat", "chatBox_StartChat", function(TeamChat)
	chatBox:Open(TeamChat)
	return true
end)

fw.hook.Add("HUDShouldDraw", "chatBox_HUDShouldDraw", function(Element)
	if (Element == "CHudChat") then
		return false
	end
end)

fw.hook.Add( "Think", "chatBox_Think", function()
	if (IsValid(LocalPlayer()) and not (chatBox.Initialized)) then
		chatBox:Init()
		chatBox.Initialized = true
	else

		local t = Lerp(FrameTime() * 5, chatBox.Transparency, chatBox.TargetTransparency)

		if (chatBox.TargetTransparency == 0) then
			if (t < 0.005) then
				t = 0
			end

		elseif (chatBox.TargetTransparency == 1) then
			if ( t > 0.995 ) then
				t = 1
			end
		end

		chatBox.Transparency = t

		local t = Lerp(FrameTime() * 5, chatBox.RichTextTransparency, chatBox.RichTextTargetTransparency)

		if (chatBox.RichTextTargetTransparency == 0) then
		        if ( t < 0.005 ) then
				t = 0
			end

		elseif (chatBox.RichTextTargetTransparency == 1) then
		       	if (t > 0.995) then
				t = 1
			end
		end

		chatBox.RichTextTransparency = t

		if (chatBox.Opened) and (input.IsKeyDown(KEY_ESCAPE)) then
                        chatBox:Close()     
                end
	end
end)
