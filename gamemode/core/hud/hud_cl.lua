fw.hook.Add('HUDShouldDraw', 'fw.hud', function(name)
	if name == 'CHudHealth' then
		return false
	end
end)

vgui.Register('fwHudInfoCell', {
		Init = function(self)
			self.label = Label('', self)
			self:SetAlpha(155)
		end,

		PerformLayout = function(self)
			self.label:SetFont(fw.fonts.default:fitToView(self:GetWide() - 10, self:GetTall() - 10, self.label:GetText()))
			self.label:SizeToContents()
			self.label:Center()
		end,

		SetText = function(self, value)
			self.label:SetText(value)
			self.label:SetTextColor(color_white)
			self:InvalidateLayout(true)

			self:AlphaTo(255, 0.1, 0, function()
				self:AlphaTo(155, 1, 0)
			end)
		end,

		-- for things like HP
		SetUpdater = function(self, fn, genText)
			local lastValue = nil
			self.Think = function(self)
				local tmp = fn()
				if tmp ~= lastValue then
					lastValue = tmp
					self:SetText(genText())
				end
			end
		end,

		Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, w, h)
			
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawOutlinedRect(0, 0, w, h)
		end,
	}, 'STYPanel')

vgui.Register('fwHudAgenda', {
		-- TODO: flesh this out with the same style as fwHudInfo and general code too
	})

vgui.Register('fwHudInfo', {
		Init = function(self)
			self.layout = vgui.Create('STYLayoutHorizontal', self)
			self.layout:SetPadding(5)

			-- display hp
			do
				self.hp = vgui.Create('fwHudInfoCell', self.layout)

				self.hp:SetUpdater(function()
					return LocalPlayer():Health()
				end, function()
					return 'HP: ' .. LocalPlayer():Health()
				end)
			end

			-- display money
			do
				self.money = vgui.Create('fwHudInfoCell', self.layout)

				local function updateMoney()
					if not IsValid(self.money) then return end
					self.money:SetText('MONEY: ' .. fw.config.currencySymbol .. string.Comma(tostring(LocalPlayer():getMoney())))
				end
				ndoc.addHook(ndoc.path('fwPlayers', LocalPlayer(), 'money'), 'set', updateMoney)
				updateMoney()

			end

			-- display job
			do
				self.job = vgui.Create('fwHudInfoCell', self.layout)
				self.job:SetUpdater(function()
					return LocalPlayer():Team()
				end, function()
					local t = fw.team.getByIndex(LocalPlayer():Team())
					if not t then
						return 'unknown team'
					end
					return t.name .. ' $' .. (t.salary or 0) 
				end)

			end

			-- display faction
			do
				self.faction = vgui.Create('fwHudInfoCell', self.layout)
				
				local function updateFaction()
					if not IsValid(self.faction) then return end

					if LocalPlayer():inFaction() then
						local factionMeta = fw.team.getFactionByID(LocalPlayer():getFaction())
						if not factionMeta then return end
						self.faction:SetText('FACTION: ' .. factionMeta:getName())
					else
						self.faction:SetText('NO FACTION')
					end
				end
				ndoc.addHook(ndoc.path('fwPlayers', LocalPlayer(), 'faction'), 'set', updateFaction)
				updateFaction()

			end
			
			do
				self.boss = vgui.Create('fwHudInfoCell', self.layout)

				local function updateBoss()
					if not IsValid(self.boss) then return end

					if LocalPlayer():inFaction() then
						local boss =  fw.team.getBoss(LocalPlayer():getFaction())
						if (not isstring(boss)) then
							boss = boss:Nick()
						end

						self.boss:SetText('BOSS: ' .. boss)
						self.boss:SetVisible(true)
					else
						self.boss:SetVisible(false)
					end
				end
				ndoc.addHook(ndoc.path('fwPlayers', LocalPlayer(), 'faction'), 'set', updateBoss)
				ndoc.addHook('fwFactions.?.boss', 'set', updateBoss)
				updateBoss()
			end

			do
				if (not LocalPlayer():inFaction()) then return end
				
				self.agenda = vgui.Create('fwHudInfoCell', self.layout)

				local function updateAgenda()
					if not IsValid(self.agenda) then return end

					if LocalPlayer():inFaction() then
						local agenda =  fw.team.factionAgendas[faction] or "No agenda currently set!" 

						self.agenda:SetText(agenda)
					else
						self.agenda:SetText('NO AGENDA')
					end
				end
				ndoc.addHook(ndoc.path('fwPlayers', LocalPlayer(), 'faction'), 'set', updateAgenda)
				updateAgenda()

			end
		end,

		PerformLayout = function(self)
			self.layout:SetTall(sty.ScreenScale(20))

			-- do layout
			self.money:SetWide(sty.ScreenScale(100))
			self.job:SetWide(sty.ScreenScale(100))
			self.faction:SetWide(sty.ScreenScale(100))
			self.hp:SetWide(sty.ScreenScale(100))

			local p = sty.ScreenScale(2)
			self.layout:SetPadding(p)

			self.layout:SetPos(p, p)
			self:SetSize(self.layout:GetWide() + 2 * p, self.layout:GetTall() + 2 * p)
		end,

		Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 150)
			surface.DrawRect(0, 0, w, h)
		end

	})

sty.WaitForLocalPlayer(function()
	if IsValid(__FW_HUDINFO) then
		__FW_HUDINFO:Remove()
	end
	__FW_HUDINFO = vgui.Create('fwHudInfo')
end)
