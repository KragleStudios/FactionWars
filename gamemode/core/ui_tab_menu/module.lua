require "sty"
fw.dep(CLIENT, "hook")
fw.dep(CLIENT, "fonts")
fw.dep(CLIENT, "ui")
fw.dep(CLIENT, "teams")
fw.dep(CLIENT, "items")
fw.dep(CLIENT, "faction_banks")

if SERVER then
	AddCSLuaFile()
	return
end

fw.tab_menu = {}

vgui.Register("fwTabMenuTabButton", {
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
}, "STYButton")

vgui.Register("fwTabMenu", {
		Init = function(self)
			local p = sty.ScreenScale(2)

			self.navView = vgui.Create("STYLayoutVertical", self)
			self.navView.Paint = function(self, w, h)
			end
			self.navView:SetPadding(5)
		end,

		AddNavButton = function(self, title, doClick)
			local p = vgui.Create("fwTabMenuTabButton", self.navView)
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
			sty.RestoreCursor("fw.tabmenu")

			-- animate into view
			self:PerformLayout()
			self:SetX(-self:GetWide())
			self:MoveTo(0, self:GetY(), fw.config.uiAnimTimeQuick, 0, -1, onFinish or ra.fn.noop)
			self:MakePopup()

		end,

		Hide = function(self, onFinish)
			sty.SaveCursor("fw.tabmenu")

			self:MoveTo(-self:GetWide(), self:GetY(), fw.config.uiAnimTimeQuick, 0, -1, onFinish)
		end,

	}, "STYPanel")


fw.hook.Add("ScoreboardShow", function()
	fw.tab_menu.showScoreboard()
end)

fw.hook.Add("ScoreboardHide", function()
	fw.tab_menu.hideScoreboard()
end)


function fw.tab_menu.showScoreboard()
	fw.print("Opening tab menu")

	fw.tab_menu.hideContent(function()

		__FW_TABMENU = vgui.Create("fwTabMenu")
		__FW_TABMENU:Show()

		__FW_TABMENU:AddView("PLAYERS", fw.tab_menu.tabDisplayPlayersList)
		__FW_TABMENU:AddView("JOBS", fw.tab_menu.tabDisplayJobsList)
		__FW_TABMENU:AddView("ITEMS", fw.tab_menu.itemManagement)
		__FW_TABMENU:AddView("INVENTORY", fw.tab_menu.playerInventory)

		if (LocalPlayer():inFaction() and LocalPlayer():getFaction() ~= FACTION_DEFAULT) then
			__FW_TABMENU:AddView("FACTION", fw.tab_menu.faction)
		end
		if (LocalPlayer():IsAdmin()) then
			__FW_TABMENU:AddView("ADMIN", fw.tab_menu.administration)
		end

		vgui.Create("FWUIDropShadow")
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

		__FW_TABMENU_CONTENT = vgui.Create("FWUIFrame")
		local content = __FW_TABMENU_CONTENT

		content:SetSize(sty.ScrH * 0.7, sty.ScrH * 0.7)
		content:MakePopup()
		content:SetTitle(title or "Unknown Content Panel")
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

		local wrapper = vgui.Create("STYPanel", content)
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
	local space = vgui.Create("DScrollPanel", panel)
	space:SetSize(panel:GetSize())

	local listLayout = vgui.Create("STYLayoutVertical", space)
	listLayout:SetWide(panel:GetWide())
	listLayout:SetPadding(sty.ScreenScale(5))

	for k, fac in pairs(fw.team.factions) do
		local plys = fac:getPlayers()

		if (#plys == 0) then continue end

		local factionPlayers = vgui.Create("FWUITableViewSection", listLayout)
		factionPlayers:SetTitle(fac.name.." - "..#plys.." PLAYER(S) TOTAL")
		factionPlayers:SetPadding(sty.ScreenScale(2))

		local teamList = {}
		for k,v in pairs(plys) do
			teamList[v:Team()] = teamList[v:Team()] or {}
			table.insert(teamList[v:Team()], v)
		end

		for k, job in pairs(fw.team.list) do
			local jobs = job:getName()
			local jobPlayers = teamList[k]
			if not jobPlayers or #jobPlayers == 0 then continue end

			local factionJobs = vgui.Create("FWUITableViewSection", factionPlayers)
			factionJobs:SetTitle(jobs)
			factionJobs:SetTitleTint(team.GetColor(job:getID()))
			factionJobs:SetPadding(sty.ScreenScale(2))

			for k,ply in pairs(jobPlayers) do
				if (ply:getFaction() != fac:getID()) then continue end

				local panel = vgui.Create("FWUIPanel", factionJobs)
				panel:SetTall(sty.ScreenScale(15))
				panel:SetBackgroundTint(team.GetColor(ply:Team()), 5)

				local title = vgui.Create("FWUITextBox", panel)
				title:SetInset(sty.ScreenScale(2))
				title:SetText(ply:Nick())
				title:DockMargin(sty.ScreenScale(4), 0, 0, 0)
				title:Dock(FILL)

				local ping = vgui.Create("FWUITextBox", panel)
				ping:SetInset(sty.ScreenScale(2))
				ping:SetText("Ping: "..ply:Ping())
				ping:Dock(RIGHT)

				local deaths = vgui.Create("FWUITextBox", panel)
				deaths:SetInset(sty.ScreenScale(2))
				deaths:SetText("Deaths: "..ply:Deaths())
				deaths:Dock(RIGHT)

				local kills = vgui.Create("FWUITextBox", panel)
				kills:SetInset(sty.ScreenScale(2))
				kills:SetText("Kills: "..ply:Frags())
				kills:Dock(RIGHT)
			end

		end
	end
end

--TODO: Faction Administration Panel
function fw.tab_menu.faction(pnl)
	local space = vgui.Create("DScrollPanel", pnl)
	space:SetSize(pnl:GetSize())

	local listLayout = vgui.Create("STYLayoutVertical", space)
	listLayout:SetWide(space:GetWide())
	listLayout:SetPadding(sty.ScreenScale(5))

	local factionTools = vgui.Create("FWUITableViewSection", listLayout)
	factionTools:SetTitle("Currency")
	factionTools:SetPadding(sty.ScreenScale(2))

	local currencyWrapper = vgui.Create("FWUIPanel", factionTools)
	currencyWrapper:SetTall(sty.ScreenScale(30))
	currencyWrapper:SetBackgroundTint(fw.team.factions[LocalPlayer():getFaction()].color or Color(255, 255, 255), 10)

	local amount = ndoc.table.fwFactions[LocalPlayer():getFaction()].money
	local amountText = vgui.Create("FWUITextBox", currencyWrapper)
	amountText:SetInset(sty.ScreenScale(5))
	amountText:SetText("Balance: $"..string.Comma(amount))
	amountText:Dock(FILL)
	amountText:SetAlign("center")
	amountText:SizeToContents()

	ndoc.addHook("fwFactions.?.money", "set", function(index, money)
		if (not IsValid(amountText) or index ~= LocalPlayer():getFaction()) then return end

		amountText:SetText("Balance: $"..string.Comma(money))
		amountText:SizeToContents()
	end)

	local actionButtons = vgui.Create("FWUIPanel", factionTools)
	actionButtons:SetTall(sty.ScreenScale(12))

	local depositBtn = vgui.Create("FWUIButton", actionButtons)
	depositBtn:SetText("Deposit")
	depositBtn:Dock(LEFT)
	depositBtn:SetWide(sty.ScreenScale(100))
	function depositBtn:DoClick()
		Derma_StringRequest("Deposit", "How much?", "", function(amt) local amt = tonumber(amt) if (not amt) then return end LocalPlayer():ConCommand("fw_faction_deposit "..amt) end)
	end

	local withdrawBtn = vgui.Create("FWUIButton", actionButtons)
	withdrawBtn:SetText("Withdraw")
	withdrawBtn:Dock(RIGHT)
	withdrawBtn:SetWide(sty.ScreenScale(100))
	function withdrawBtn:DoClick()
		Derma_StringRequest("Withdraw", "How much?", "", function(amt) local amt = tonumber(amt) if (not amt) then return end LocalPlayer():ConCommand("fw_faction_withdraw "..amt) end)
	end
	withdrawBtn:SetPos(depositBtn:GetWide(), currencyWrapper:GetTall() - withdrawBtn:GetTall())

	local players = fw.team.getFactionPlayers(LocalPlayer():getFaction())
	local pList = vgui.Create("FWUITableViewSection", listLayout)
	pList:SetTitle("Players")
	pList:SetPadding(sty.ScreenScale(2))

		for k, v in pairs(fw.team.list) do
			local jobs = v:getName()
			local jobPlayers = v:getPlayers()
			if #jobPlayers == 0 then continue end

			local factionJobs = vgui.Create("FWUITableViewSection", pList)
			factionJobs:SetTitle(jobs)
			factionJobs:SetTitleTint(team.GetColor(v:getID()))
			factionJobs:SetPadding(sty.ScreenScale(2))

			for k,v in pairs(jobPlayers) do
				if (v:getFaction() != LocalPlayer():getFaction()) then continue end

				local panel = vgui.Create("FWUIButton", factionJobs)
				panel:SetTall(sty.ScreenScale(12))
				panel:SetText(v:Nick())
				function panel:DoClick()
					local menu = DermaMenu(self)

					local demoteButton = LocalPlayer():isFactionBoss() and "Force Demote" or "Vote Demote"
					local kickButton = LocalPlayer():isFactionBoss() and "Force Kick" or "Vote Kick"

					menu:AddOption(demoteButton, function()
						LocalPlayer():ConCommand("fw_factiondemote \""..v:SteamID().."\"")
					end)
					menu:AddOption(kickButton, function()
						LocalPlayer():ConCommand("fw_factionkick \""..v:SteamID().."\"")
					end)
					menu:Open()
				end
			end

		end
end

function fw.tab_menu.administration(pnl)
	local space = vgui.Create("DScrollPanel", pnl)
	space:SetSize(pnl:GetSize())

	local listLayout = vgui.Create("STYLayoutVertical", space)
	listLayout:SetWide(space:GetWide())
	listLayout:SetPadding(sty.ScreenScale(5))

	local playerList = vgui.Create("FWUITableViewSection", listLayout)
	playerList:SetTitle("Players")
	playerList:SetPadding(sty.ScreenScale(2))

	for k,v in pairs(player.GetAll()) do
		local plyButton = vgui.Create("FWUIButton", playerList)
		plyButton:SetText(v:Nick())
		plyButton:SetTall(sty.ScreenScale(15))
		plyButton.ply = v
		plyButton.DoClick = function(self)
			local ply = self.ply
			local menu = DermaMenu(plyButton)
			menu:AddOption("Kick", function()
				Derma_StringRequest("Kick Player", "Enter reason...", "Reason...", function(reason) RunConsoleCommand("fw_kick", ply:Nick(), reason) end)
			end)
			menu:AddOption("Ban", function()
				Derma_StringRequest("Ban Player", "Enter reason...", "Reason...", function(reason)
					Derma_StringRequest("Ban Player", "Enter time...", "60 Minutes", function(time) time = ra.util.timestring(time) if time != false then RunConsoleCommand("fw_ban", ply:Nick(), reason, tonumber(time)) else chat.AddText(color_black, "[Faction Wars] [Admin]", color_white, "You used an incorrectly formatted timestring!") end end)
				end)
			end)
			menu:AddOption("Slay", function() RunConsoleCommand("fw_slay", ply:Nick()) end)
			menu:AddOption("Mute", function() RunConsoleCommand("fw_mute", ply:Nick()) end)
			menu:AddOption("Unmute", function() RunConsoleCommand("fw_unmute", ply:Nick()) end)
			menu:AddOption("Gag", function() RunConsoleCommand("fw_gag", ply:Nick()) end)
			menu:AddOption("Ungag", function() RunConsoleCommand("fw_ungag", ply:Nick()) end)
			menu:AddOption("Freeze", function() RunConsoleCommand("fw_freeze", ply:Nick()) end)
			menu:AddOption("Unfreeze", function() RunConsoleCommand("fw_unfreeze", ply:Nick()) end)
			menu:AddOption("Set job", function()
				Derma_StringRequest("Set job", "Enter job StringID...", "t_citizen", function(job) RunConsoleCommand("fw_setjob", ply:Nick(), job) end)
			end)
			menu:AddOption("Set faction", function()
				Derma_StringRequest("Set faction", "Enter faction StringID...", "f_commonwealth", function(faction) RunConsoleCommand("fw_setfaction", ply:Nick(), faction) end)
			end)
			menu:Open()
		end
	end

	local aCvars = {"sbox_godmode", "sbox_maxballoons", "sbox_maxbuttons", "sbox_maxdynamite", "sbox_maxeffects", "sbox_maxemitters", "sbox_maxhoverballs",
	"sbox_maxlamps", "sbox_maxlights", "sbox_maxnpcs", "sbox_maxprops", "sbox_maxragdolls", "sbox_maxsents", "sbox_maxthrusters", "sbox_maxvehicles", "sbox_maxwheels",
	"sbox_noclip"}

	if LocalPlayer():IsSuperAdmin() then
		local settings = vgui.Create("FWUITableViewSection", listLayout)
		settings:SetTitle("Server settings")
		settings:SetPadding(sty.ScreenScale(2))

		for k,v in pairs(aCvars) do
			local panel = vgui.Create("FWUIPanel", settings)
			panel:SetTall(sty.ScreenScale(15))

			local title = vgui.Create("FWUITextBox", panel)
			title:SetInset(sty.ScreenScale(2))
			title:SetText(v)
			title:DockMargin(sty.ScreenScale(4), 0, 0, 0)
			title:Dock(FILL)

			local val = vgui.Create("DNumberWang", panel)
			val:Dock(RIGHT)
			val:SetValue(GetConVar(v):GetInt())
			val.cvar = GetConVar(v)
			val.OnValueChanged = function(self, val)
				RunConsoleCommand("fw_cvar", self.cvar:GetName(), val)
			end
		end
	end
end

function fw.tab_menu.itemManagement(parent)
	parent.categories = {}
	local space = vgui.Create("DScrollPanel", parent)
	space:SetSize(parent:GetSize())

	local listLayout = vgui.Create("STYLayoutVertical", space)
	listLayout:SetWide(parent:GetWide())
	listLayout:SetPadding(sty.ScreenScale(2))

	local function addItemPanel(item, sectionParent)
		local price = string.Comma(item.price)

		if item:shouldDisplay(LocalPlayer()) == false then return end

		local categoryPanel = sectionParent.categoryPanels[item.category]

		if not categoryPanel then
			categoryPanel = vgui.Create('FWUITableViewSection', sectionParent)
			categoryPanel:SetTitle(string.upper(item.category))
			categoryPanel:SetPadding(sty.ScreenScale(2))
			sectionParent.categoryPanels[item.category] = categoryPanel
		end

		local panel = vgui.Create("FWUIPanel", categoryPanel)
		panel:SetTall(sty.ScreenScale(12))

		local buyButton = vgui.Create("FWUIButton", panel)
		buyButton:SetFont(fw.fonts.default)
		buyButton:SetText("BUY ITEM $"..price)
		buyButton.DoClick = function()
			LocalPlayer():ConCommand(item.command)
		end
		buyButton:SetWide(sty.ScreenScale(60))
		buyButton:Dock(RIGHT)

		if not item:canBuy(LocalPlayer()) then
			panel:SetBackgroundTint(Color(200, 0, 0), 10)
			buyButton:SetAlpha(100)
		end

		local title = vgui.Create("FWUITextBox", panel)
		title:SetText(item.name or 'unnamed')
		title:Dock(FILL)
		title:DockMargin(sty.ScreenScale(1),sty.ScreenScale(1),sty.ScreenScale(1),sty.ScreenScale(1))
	end

	local itemSection = vgui.Create('FWUITableViewSection', listLayout)
	itemSection:SetTitle(string.upper('Items'))
	itemSection:SetPadding(sty.ScreenScale(2))
	itemSection.categoryPanels = {}

	local weaponSection = vgui.Create('FWUITableViewSection', listLayout)
	weaponSection:SetTitle(string.upper('Weapons'))
	weaponSection:SetPadding(sty.ScreenScale(2))
	weaponSection.categoryPanels = {}

	local shipmentSection = vgui.Create('FWUITableViewSection', listLayout)
	shipmentSection:SetTitle(string.upper('Shipments'))
	shipmentSection:SetPadding(sty.ScreenScale(2))
	shipmentSection.categoryPanels = {}

	for k, item in ipairs(fw.ents.item_list) do
		addItemPanel(item, itemSection)
	end

	for k, item in ipairs(fw.ents.shipment_list) do
		addItemPanel(item, shipmentSection)
	end

	for k, item in ipairs(fw.ents.weapon_list) do
		addItemPanel(item, weaponSection)
	end
end

--job menu display! :D
function fw.tab_menu.tabDisplayJobsList(panel)
	local space = vgui.Create("DScrollPanel", panel)
	space:SetSize(panel:GetSize())

	local listLayout = vgui.Create("STYLayoutVertical", space)
	listLayout:SetWide(panel:GetWide())
	listLayout:SetPadding(sty.ScreenScale(2))

	local factionsListSection = vgui.Create("FWUITableViewSection", listLayout)
	factionsListSection:SetTitle("FACTIONS")
	factionsListSection:SetPadding(sty.ScreenScale(2))

	local function createFactionButton(fname, players, doClickJoin)
		local panel = vgui.Create("FWUIPanel")
		panel:SetTall(sty.ScreenScale(12))
		factionsListSection:Add(panel)

		local joinButton = vgui.Create("FWUIButton", panel)
		joinButton:SetFont(fw.fonts.default)
		joinButton:SetText("JOIN FACTION")
		joinButton.DoClick = doClickJoin
		joinButton:SetWide(sty.ScreenScale(60))

		local title = vgui.Create("FWUITextBox", panel)
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
		local panel = vgui.Create("FWUIPanel")
		panel:SetTall(sty.ScreenScale(12))
		factionsListSection:Add(panel)

		local joinButton = vgui.Create("FWUIButton", panel)
		joinButton:SetText("LEAVE")
		joinButton:SetFont(fw.fonts.default)
		joinButton.DoClick = function()
			fw.tab_menu .hideContent()
			LocalPlayer():ConCommand("fw_faction_leave \n")
		end

		joinButton:SetWide(sty.ScreenScale(60))

		local title = vgui.Create("FWUITextBox", panel)
		title:SetText("Leave " .. fw.team.getFactionByID(LocalPlayer():getFaction()):getName())

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

		local title = vgui.Create("FWUITextBox", pnl)
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
			local pickModel = vgui.Create("FWUIButton", pnl)
			pickModel:SetText("SET MODEL")
			pickModel:SetFont(fw.fonts.default)
			pickModel:SetWide(sty.ScreenScale(40))
			pickModel:Dock(RIGHT)

			-- model panels
			local mdlPanel = vgui.Create("FWUIPanel", self)
			mdlPanel:SetVisible(false)
			jobListSection:Add(mdlPanel)

			mdlPanel:SetTall(sty.ScreenScale(40))

			for k,v in ipairs(job.models) do
				local mdl = vgui.Create("SpawnIcon", mdlPanel)
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
