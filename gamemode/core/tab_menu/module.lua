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
		__FW_TABMENU:AddView('ITEMS', fw.tab_menu.itemManagement)
		__FW_TABMENU:AddView('INVENTORY', fw.tab_menu.playerInventory)
		if (LocalPlayer():isFactionBoss()) then
			__FW_TABMENU:AddView('FACTION', fw.tab_menu.factionAdministration)
		end
		if (LocalPlayer():IsAdmin()) then
			__FW_TABMENU:AddView('ADMIN', fw.tab_menu.administration)
		end


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

	if callback then callback() end
end

function fw.tab_menu.displayContent(title, constructor, callback)
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
		content:PerformLayout()

		local wrapper = vgui.Create('STYPanel', content)
		wrapper:SetPos(sty.CalcInsetPos(sty.ScreenScale(2), 0, content:GetHeaderYOffset()))
		wrapper:SetSize(
			sty.CalcInsetSize(
				sty.ScreenScale(2), content:GetWide(), 
				content:GetTall() - content:GetHeaderYOffset()
			))

		constructor(wrapper)
	end)
end

function fw.tab_menu.tabDisplayPlayersList(panel)
	local space = vgui.Create('DScrollPanel', panel)
	space:SetSize(panel:GetSize())

	local listLayout = vgui.Create('STYLayoutVertical', space)
	listLayout:SetWide(panel:GetWide())
	listLayout:SetPadding(sty.ScreenScale(5))

	for k, v in pairs(fw.team.factions) do
		local plys = v:getPlayers()

		if (#plys == 0) then continue end

		local factionPlayers = vgui.Create('FWUITableViewSection', listLayout)
		factionPlayers:SetTitle(v.name)
		factionPlayers:SetPadding(sty.ScreenScale(2))

		for k,v in pairs(plys) do
			local panel = vgui.Create('FWUIPanel', factionPlayers)
			panel:SetTall(sty.ScreenScale(15))

			local title = vgui.Create('FWUITextBox', panel)
			title:SetText(v:Nick())

			local job = vgui.Create('FWUITextBox', panel)
			job:SetText(fw.team.list[v:Team()].name)
			job:SizeToContents()
			job:SetWide(sty.ScreenScale(50))

			title:Dock(FILL)
			job:Dock(RIGHT)
		end
		
	end
end

--TODO: Faction Administration Panel
function fw.tab_menu.factionAdministration(pnl)

end

--TODO: Server administration Panel
function fw.tab_menu.administration(pnl)

end

--TODO: Item purchasing panel
function fw.tab_menu.itemManagement(pnl)

end

--TODO: Player inventory panel
function fw.tab_menu.playerInventory(pnl)

end

--job menu display! :D
function fw.tab_menu.tabDisplayJobsList(panel)
	local space = vgui.Create('DScrollPanel', panel)
	space:SetSize(panel:GetSize())

	local listLayout = vgui.Create('STYLayoutVertical', space)
	listLayout:SetWide(panel:GetWide())
	listLayout:SetPadding(sty.ScreenScale(2))

	local factionsListSection = vgui.Create('FWUITableViewSection', listLayout)
	factionsListSection:SetTitle('FACTIONS')
	factionsListSection:SetPadding(sty.ScreenScale(2))

	local function createFactionButton(fname, players, doClickJoin)
		local panel = vgui.Create('FWUIPanel')
		panel:SetTall(sty.ScreenScale(12))
		factionsListSection:Add(panel)

		local joinButton = vgui.Create('FWUIButton', panel)
		joinButton:SetFont(fw.fonts.default)
		joinButton:SetText('JOIN FACTION')
		joinButton.DoClick = doClickJoin
		joinButton:SetWide(sty.ScreenScale(60))

		local title = vgui.Create('FWUITextBox', panel)
		title:SetText(fname)

		joinButton:Dock(RIGHT)
		title:Dock(FILL)
	end

	for index, faction in pairs(fw.team.factions) do
		if LocalPlayer():getFaction() == faction:getID() then continue end

		createFactionButton(faction:getName(), #faction:getPlayers(), function()
			LocalPlayer():ConCommand(faction.command)
			fw.tab_menu.hideContent()
		end)
	end

	-- leave faction
	if LocalPlayer():inFaction() and LocalPlayer():getFaction() ~= FACTION_DEFAULT then 
		local panel = vgui.Create('FWUIPanel')
		panel:SetTall(sty.ScreenScale(12))
		factionsListSection:Add(panel)

		local joinButton = vgui.Create('FWUIButton', panel)
		joinButton:SetText('LEAVE')
		joinButton:SetFont(fw.fonts.default)
		joinButton.DoClick = function()
			fw.tab_menu .hideContent()
			LocalPlayer():ConCommand('fw_faction_leave \n')
		end

		joinButton:SetWide(sty.ScreenScale(60))

		local title = vgui.Create('FWUITextBox', panel)
		title:SetText('Leave ' .. fw.team.getFactionByID(LocalPlayer():getFaction()):getName())

		joinButton:Dock(RIGHT)
		title:Dock(FILL)

		panel:SetBackgroundTint(Color(200, 0, 0), 10)
	end 


	-- list of jobs
	local jobListSection = vgui.Create("FWUITableViewSection", listLayout)
	jobListSection:SetTitle("JOBS")
	jobListSection:SetPadding(sty.ScreenScale(2))

	local function createJobButton(job, players)
		local selectedModel, pref_model
		
		local pnl = vgui.Create("FWUIPanel")
		pnl:SetTall(sty.ScreenScale(12))
		jobListSection:Add(pnl)

		local title = vgui.Create('FWUITextBox', pnl)
		title:SetText(job:getName())
		title:Dock(FILL)

		local join = vgui.Create("FWUIButton", pnl)
		join:SetText("JOIN TEAM")
		join:SetFont(fw.fonts.default)
		join:SetWide(sty.ScreenScale(40))
		join:Dock(RIGHT)
		function join:DoClick()
			LocalPlayer():ConCommand(job.command)
			fw.tab_menu.hideContent()
		end

		if #job.models > 1 then
			local pickModel = vgui.Create('FWUIButton', pnl)
			pickModel:SetText("SET MODEL")
			pickModel:SetFont(fw.fonts.default)
			pickModel:SetWide(sty.ScreenScale(40))
			pickModel:Dock(RIGHT)

			-- model panels
			local mdlPanel = vgui.Create('FWUIPanel', self)
			mdlPanel:SetVisible(false)
			jobListSection:Add(mdlPanel)

			mdlPanel:SetTall(sty.ScreenScale(40))

			for k,v in ipairs(job.models) do
				local mdl = vgui.Create('SpawnIcon', mdlPanel)
				mdl:SetSize(mdlPanel:GetTall(), mdlPanel:GetTall())
				mdl:PerformLayout()
				mdl:SetModel(v)

				mdl.DoClick = function()
					fw.team.setPreferredModel(job:getID(), v)
					mdlPanel:SetVisible(false)
					jobListSection:SizeToContents()
				end
				mdl:Dock(LEFT)
			end

			pickModel.DoClick = function()
				mdlPanel:SetVisible(not mdlPanel:IsVisible())
				jobListSection:SizeToContents()
			end
		end

	end

	local myTeam = LocalPlayer():Team()
	for i, job in pairs(fw.team.list) do
		if (myTeam == job:getID()) then continue end
		if (not fw.team.canChangeTo(LocalPlayer(), job:getID(), false)) then continue end
		
		createJobButton(job, #job:getPlayers())
	end
end