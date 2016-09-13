-- Dimensions
voiceVis.Width = 256 -- Width in pixels of the voice rectangle
voiceVis.VisWidth = 100 -- Width in pixels of the voice visualization rectangle
voiceVis.VisBarWidth = 4 -- Width in pixels of each bar in the visualizer
voiceVis.Height = 40 -- Height in pixels of the voice rectangle

-- Paddings
voiceVis.InnerMargin = 4 -- Inner margin in pixels between elements inside the voice rectangle
voiceVis.HorizontalMargin = 50 -- Margin in pixels from the right size of the screen
voiceVis.VerticalMargin = 100 -- Margin in pixels from the top and bottom of the screen

-- Colors
voiceVis.FrameColor = fw.ui.const_frame_background -- Background color of the voice rectangle

local font = fw.fonts.default:atSize(18)

timer.Simple(1, function() -- Delay because Gmod is great
	local PANEL = {}
	local PlayerVoicePanels = {}

	function PANEL:Init()
		local self2 = self

		local LabelName = vgui.Create("DLabel", self)
		LabelName:SetFont(font)
		LabelName:Dock(FILL)
		LabelName:DockMargin(voiceVis.InnerMargin, 0, voiceVis.InnerMargin, 0)
		LabelName:SetTextColor(color_white)

		self.LabelName = LabelName

		local Avatar = vgui.Create("AvatarImage", self)
		Avatar:Dock(LEFT)
		Avatar:SetSize(32, 32)

		self.Avatar = Avatar

		local Vis = vgui.Create("DPanel", self)
		Vis:Dock(RIGHT)
		Vis:SetWide(voiceVis.VisWidth)
		Vis.Spectrum = {}

		self.Vis = Vis

		self.Color = Color(255, 255, 255)

		local Bars = math.floor(Vis:GetWide() / voiceVis.VisBarWidth)

		function Vis:Paint(Width, Height)
			for i = 1, Bars do
				local w = voiceVis.VisBarWidth
				local h = Height * (self.Spectrum[i] or 0)
				local x = (i - 1) * w
				local y = Height - h

				surface.SetDrawColor(self2.Color)
				surface.DrawRect(x, y, w, h)
			end

            surface.SetDrawColor(0, 0, 0, 50)
			surface.DrawOutlinedRect(0, 0, Width, Height)
			surface.SetDrawColor(255, 255, 255, 5)
			surface.DrawOutlinedRect(0, 0, Width, Height)
		end

		function Vis:Think()
			local Volume = self2.Player:VoiceVolume()

			if (Volume > 0) then
				table.insert(self.Spectrum, Volume)
				if (#self.Spectrum > Bars) then
					table.remove(self.Spectrum, 1)
				end
			end
		end

		self.Vis = Vis

		self:SetSize(voiceVis.Width, voiceVis.Height)
		self:DockPadding(voiceVis.InnerMargin, voiceVis.InnerMargin, voiceVis.InnerMargin, voiceVis.InnerMargin)
		self:DockMargin(2, 2, 2, 2)
		self:Dock(BOTTOM)
	end

	function PANEL:Setup(Player)
		self.Player = Player
		self.LabelName:SetText(Player:Nick())
		self.Avatar:SetPlayer(Player)
		self.Color = team.GetColor(Player:Team())

		self:InvalidateLayout()
	end

	function PANEL:Paint(Width, Height)
		if (not (IsValid(self.Player))) then
			return
		end

		surface.SetDrawColor(voiceVis.FrameColor)
		surface.DrawRect(0, 0, Width, Height)

		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawOutlinedRect(0, 0, Width, Height)
		surface.SetDrawColor(255, 255, 255, 5)
		surface.DrawOutlinedRect(1, 1, Width-2, Height-2)
	end

	function PANEL:Think()
		if (IsValid(self.Player)) then
			self.LabelName:SetText(self.Player:Nick())
		end

		if (self.fadeAnim) then
			self.fadeAnim:Run()
		end
	end

	function PANEL:FadeOut(anim, delta, data)
		if (anim.Finished) then
			if (IsValid(PlayerVoicePanels[self.Player])) then
				PlayerVoicePanels[self.Player]:Remove()
				PlayerVoicePanels[self.Player] = nil
				return
			end
			return
		end
		self:SetAlpha(255 - (255 * delta))
	end

	derma.DefineControl("VoiceNotify", "", PANEL, "DPanel")

	function GAMEMODE:PlayerStartVoice(Player)
		if (not (IsValid(g_VoicePanelList))) then
			return
		end

		GAMEMODE:PlayerEndVoice(Player)

		if (IsValid(PlayerVoicePanels[Player])) then
			if (PlayerVoicePanels[Player].fadeAnim) then
				PlayerVoicePanels[Player].fadeAnim:Stop()
				PlayerVoicePanels[Player].fadeAnim = nil
			end

			PlayerVoicePanels[Player]:SetAlpha(255)

			return
		end

		if (not (IsValid(Player))) then
			return
		end

		local pnl = g_VoicePanelList:Add("VoiceNotify")
		pnl:Setup(Player)

		PlayerVoicePanels[Player] = pnl
	end

	timer.Create("VoiceClean", 10, 0, function()
		for k, v in pairs(PlayerVoicePanels) do
			if (not (IsValid(k))) then
				GAMEMODE:PlayerEndVoice(k)
			end
		end
	end)

	function GAMEMODE:PlayerEndVoice(Player)
		if (IsValid(PlayerVoicePanels[Player])) then
			if (PlayerVoicePanels[Player].fadeAnim) then return end
			PlayerVoicePanels[Player].fadeAnim = Derma_Anim("FadeOut", PlayerVoicePanels[Player], PlayerVoicePanels[Player].FadeOut)
			PlayerVoicePanels[Player].fadeAnim:Start(2)
		end
	end

	hook.Add("InitPostEntity", "CreateVoiceVGUI", function()
		if (IsValid(g_VoicePanelList)) then
			g_VoicePanelList:Remove()
		end

		g_VoicePanelList = vgui.Create("DPanel")
		g_VoicePanelList:ParentToHUD()
		g_VoicePanelList:SetPos(ScrW() - voiceVis.Width - voiceVis.HorizontalMargin, voiceVis.VerticalMargin)
		g_VoicePanelList:SetSize(voiceVis.Width, ScrH() - voiceVis.VerticalMargin * 2)
		g_VoicePanelList:SetPaintBackground(false)
	end)
end)
