fw.hook.Add('HUDShouldDraw', 'fw.hud', function(name)
	if name == 'CHudHealth' or (IsValid(LocalPlayer()) and LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") then
		return false
	end
end)

local gradient = surface.GetTextureID("gui/gradient_down.vtf")

local BASE_ALPHA = 240

vgui.Register('fwHudInfoCell', {
		Init = function(self)
			self.label = Label('', self)
			self.label:SetTextColor(color_white)
			self:SetAlpha(BASE_ALPHA)
			self.color = Color(255, 255, 255)
			self.color_full = Color(255, 255, 255)

			self.highlight = vgui.Create('DPanel', self)
			self.highlight.Paint = function(_, w, h)
				surface.SetDrawColor(self.color_full)
				surface.DrawRect(0, 0, w, h)
			end
			self.highlight:SetVisible(false)
		end,

		PerformLayout = function(self)
			local p = sty.ScreenScale(2)
			self._p = p

			self.highlight:SetSize(self:GetWide(), p)

			self.label:SetFont(fw.fonts.default:fitToView(self:GetWide() - p * 2, self:GetTall() - p * 3, self.label:GetText()))
			self.label:SizeToContents()
			self.label:CenterHorizontal()
			self.label:SetY((self:GetTall() - self.label:GetTall() - p) * 0.5 + p)
		end,

		SetTint = function(self, color)
			-- self.color = Color((color.r + 255) * 0.5, (color.g + 255) * 0.5, (color.b + 255) * 0.5)
			self.color_full = color
		end,

		SetText = function(self, value)
			self.label:SetText(value)
			self:InvalidateLayout(true)

			self.highlight:SetVisible(true)
			self.highlight:SetAlpha(0)
			self.highlight:AlphaTo(255, 0.1, 0, function()
				self.highlight:AlphaTo(0, 1, 0, function()
					self.highlight:SetVisible(false)
				end)
			end)
			self:AlphaTo(255, 0.1, 0, function()
				self:AlphaTo(BASE_ALPHA, 1, 0)
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

			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)

			surface.SetDrawColor(255, 255, 255, 15)
			surface.SetTexture(gradient)
	        surface.DrawTexturedRect(0, 0, w, h)

			surface.SetDrawColor(self.color)
			surface.DrawRect(0, 0, w, self._p)
		end,
	}, 'STYPanel')

vgui.Register('fwHudInfo', {
		Init = function(self)
			self.layout = vgui.Create('STYLayoutHorizontal', self)
			self.layout:SetPadding(5)

			-- display hp
			do
				self.hp = vgui.Create('fwHudInfoCell', self.layout)
				self.hp:SetTint(Color(255, 0, 0))

				self.hp:SetUpdater(function()
					return LocalPlayer():Health()
				end, function()
					return 'Health: ' .. LocalPlayer():Health()
				end)
			end

			-- display money
			do
				self.money = vgui.Create('fwHudInfoCell', self.layout)
				self.money:SetTint(Color(0, 255, 0))

				local function updateMoney()
					if not IsValid(self.money) then return end
					self.money:SetText('Money: ' .. fw.config.currencySymbol .. string.Comma(tostring(LocalPlayer():getMoney())))
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

					if LocalPlayer():inFaction() or (LocalPlayer():getFaction() == FACTION_DEFAULT) then
						local factionMeta = fw.team.getFactionByID(LocalPlayer():getFaction())
						if not factionMeta then return end
						self.faction:SetText('Faction: ' .. factionMeta:getName())
					else
						self.faction:SetText('NO FACTION')
					end
				end
				ndoc.addHook(ndoc.path('fwPlayers', LocalPlayer(), 'faction'), 'set', updateFaction)
				updateFaction()

			end

			-- display the boss
			do
				self.boss = vgui.Create('fwHudInfoCell', self.layout)

				local function updateBoss()
					if not IsValid(self.boss) then return end

					if LocalPlayer():inFaction() and LocalPlayer():getFaction() ~= FACTION_DEFAULT then
						local boss =  fw.team.factions[LocalPlayer():getFaction()]:getBoss()
						if (boss and boss:IsPlayer()) then
							boss = boss:Nick()
						else
							boss = "None"
						end

						self.boss:SetText('Boss: ' .. boss)
						self.boss:SetVisible(true)
					else
						self.boss:SetVisible(false)
						self.layout:PerformLayout() --refresh bars
					end
				end
				ndoc.addHook(ndoc.path('fwPlayers', LocalPlayer(), 'faction'), 'set', updateBoss)
				ndoc.addHook('fwFactions.?.boss', 'set', updateBoss)
				updateBoss()
			end

			-- display the zone
			do
				self.zone = vgui.Create('fwHudInfoCell', self.layout)
				self.territory = vgui.Create('fwHudInfoCell', self.layout)

				local function updateTerritory()
					local zone = fw.zone.playerGetZone(LocalPlayer())
					if not zone then
						self.territory:SetVisible(false)
						return
					end
					self.territory:SetVisible(true)

					if (not ndoc.table.fwZoneControl or not ndoc.table.fwZoneControl[zone.id]) then return end

					local zoneControl = ndoc.table.fwZoneControl[zone.id].scores
					local factionMax, controlMax = nil, 0
					for k,v in ndoc.pairs(zoneControl) do

						if v > controlMax then
							controlMax = v
							factionMax = k
						end
					end

					if factionMax then
						self.territory:SetTint(fw.team.factions[factionMax].color or color_white)
						self.territory:SetText(fw.team.factions[factionMax].name .. ' territory %' .. math.Round(controlMax/fw.config.zoneCaptureScore*100))
					else
						self.territory:SetText('Unclaimed Land')
					end
				end

				ndoc.addHook('fwZoneControl.?.scores.?', 'set', function(zoneId, factionId, amount)
					if not IsValid(self.territory) then return end
					updateTerritory() -- it might be alot of updates... but hopefully it's less than it could otherwise be!
				end)

				self.zone:SetUpdater(function()
					local zone = fw.zone.playerGetZone(LocalPlayer())
					return zone or -1
				end, function()
					local zone = fw.zone.playerGetZone(LocalPlayer())
					updateTerritory()
					if zone == nil then
						return 'Zone: The Streets'
					else
						return zone.name and ('Zone: ' .. zone.name) or 'unknown zone'
					end
				end)
			end

			--[[
			--TODO move this to it's own panel does not belong here
			do
				self.agenda = vgui.Create('fwHudInfoCell', self.layout)

				local function updateAgenda()
					if not IsValid(self.agenda) then return end
					print("UPDATING AGENDA")

					if LocalPlayer():inFaction() then
						local agenda =  ndoc.table.fwFactions[LocalPlayer():getFaction()].agenda or "No agenda currently set!"

						self.agenda:SetText(agenda)
						self.agenda:SetVisible(true)
					else
						self.agenda:SetVisible(false)
					end

					self.agenda:PerformLayout()
				end
				ndoc.addHook(ndoc.path('fwPlayers', LocalPlayer(), 'faction'), 'set', updateAgenda)
				ndoc.addHook('fwFactions.?.agenda', 'set', updateAgenda)
				updateAgenda()

			end
			]]
		end,

		PerformLayout = function(self)
			self.layout:SetTall(sty.ScreenScale(15))

			-- do layout
			local width = 80

			self.money:SetWide(sty.ScreenScale(width))
			self.job:SetWide(sty.ScreenScale(width))
			self.faction:SetWide(sty.ScreenScale(width))
			self.hp:SetWide(sty.ScreenScale(width))
			self.boss:SetWide(sty.ScreenScale(width))
			self.zone:SetWide(sty.ScreenScale(width))
			self.territory:SetWide(sty.ScreenScale(width))

			local p = sty.ScreenScale(3)
			self.layout:SetPadding(p)

			self.layout:SetPos(p, p)
			self:SetSize(self.layout:GetWide() + 2 * p, self.layout:GetTall() + 2 * p)
		end,

		Paint = function(self, w, h)
		end

	})

sty.WaitForLocalPlayer(function()
	if IsValid(__FW_HUDINFO) then
		__FW_HUDINFO:Remove()
	end
	__FW_HUDINFO = vgui.Create('fwHudInfo')
end)

fw.hook.Add("Think", "HideOnCamera", function()
	if IsValid(__FW_HUDINFO) and (LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") then
		__FW_HUDINFO:Remove()
	end

	if not IsValid(__FW_HUDINFO) then
		__FW_HUDINFO = vgui.Create('fwHudInfo')
	end
end)
