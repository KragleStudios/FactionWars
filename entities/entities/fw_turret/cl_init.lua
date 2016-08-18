include("shared.lua")

function ENT:GetDisplayPosition()
	local obbcenter = self:OBBCenter()
	local obbmax = self:OBBMaxs()
	return Vector(obbcenter.x + 20, obbmax.y - 14, obbcenter.z + (self:GetModel() == "models/combine_turrets/ground_turret.mdl" and 0 or 10)), Angle(0, 90, 90), 0.2
end

function ENT:Draw()
	self:DrawModel()

	if self:GetMenuOpen() then
		self:FWDrawInfo()
	end

	if self.show_radius then
		cam.Start3D2D(self:GetPos() - Vector(0, 0, 10), Angle(0, 0, 0), 1)
			surface.DrawCircle(0, 0, self:GetRadius(), 255, 255, 255, 255)
		cam.End3D2D()
	end
end

local function makeButton(btn, font)
	local font = fw.fonts.default:atSize(btn:GetTall() - 20)
	btn.OnCursorEntered = function(self) self.Hovered = true end
	btn.OnCursorExited = function(self) self.Hovered = false end
	btn.OnMousePressed = function(self) self.Depressed = true end
	btn.OnMouseReleased = function(self)
		self.Depressed = false
		if self.Hovered then
			self:DoClick()
		end
	end
	btn.Paint = function(self, w, h)
		local g = (self.Depressed and 45) or (self.Hovered and 50) or 40
		surface.SetDrawColor(g, g, g + 5, 255)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.SetDrawColor(200, 200, 200, 15)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
	end
	btn:SetTextColor(color_white)
	btn:SetFont(font)
end

local function addText(panel, text)
	local textbox = vgui.Create("DPanel", panel)
	textbox:SetTall(fw.resource.INFO_ROW_HEIGHT * 0.5)
	textbox.text = text

	local font = fw.fonts.default:atSize(textbox:GetTall() - 4)
	textbox.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText(self.text, font, 5, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	return textbox
end

function ENT:CustomUI(panel)
	local client = LocalPlayer()
	local height = math.ceil(fw.resource.INFO_ROW_HEIGHT * 0.75)
	local red, yellow = Color(229, 57, 53), Color(253, 216, 53)

	local condition = vgui.Create("DPanel", panel)
	condition:SetTall(height)
	condition.Paint = function(pnl, w, h)
		-- transparent background
		surface.SetDrawColor(0, 0, 0, 160)
		surface.DrawRect(0, 0, w, h)
		-- health
		surface.SetDrawColor(red)
		surface.DrawRect(0, 0, self:GetTHealth() / self:GetTMaxHealth() * w, h / 2)
		-- ammo
		local ammoWidth = self:GetRemaining() / self:GetMaxClip() * w
		surface.SetDrawColor(yellow)
		surface.DrawRect(0, h / 2, ammoWidth, h / 2)
		-- cooldown
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, h / 2, math.min(ammoWidth * (self:GetCooldown() / self:GetFireOffset()), ammoWidth), h / 2)
	end

	local target = addText(panel, "")
	local radius = addText(panel, "Targeting Radius: " .. self:GetRadius() .. " units")
	local fireRate = self:GetFireOffset()
	local damage = addText(panel, "Damage: " .. self:GetDamage() .. " dmg every " .. fireRate .. " second" .. (fireRate > 0 and "s" or ""))

	local toggle = vgui.Create("DButton", panel)
	toggle:SetTall(height)
	toggle.DoClick = function()
		net.Start("fw.updateTurretStatus")
		net.WriteEntity(self)
		net.WriteBool(not self:GetStatus())
		net.SendToServer()
	end

	local upgrade = vgui.Create("DButton", panel)
	upgrade:SetTall(height)
	upgrade.DoClick = function()
		net.Start("fw.upgradeTurret")
		net.WriteEntity(self)
		net.SendToServer()
	end

	local refill = vgui.Create("DButton", panel)
	refill:SetTall(height)
	refill.DoClick = function()
		net.Start("fw.buyAmmo")
		net.WriteEntity(self)
		net.SendToServer()
	end

	local visual = vgui.Create("DPanel", panel)
	visual:SetTall(height)

	local showradius = vgui.Create("DButton", visual)
	showradius:SetText(self.show_radius and "Disable Visual Radius" or "Enable Visual Radius")
	showradius.DoClick = function()
		self.show_radius = not self.show_radius
		showradius:SetText(self.show_radius and "Disable Visual Radius" or "Enable Visual Radius")
	end

	local hidemenu = vgui.Create("DButton", visual)
	hidemenu:SetText("Hide Menu")
	hidemenu.DoClick = function()
		net.Start("fw.toggleMenu")
		net.WriteEntity(self)
		net.SendToServer()
	end

	visual.PerformLayout = function()
		showradius:SetSize(visual:GetWide() / 2, height)
		hidemenu:SetX(visual:GetWide() / 2)
		hidemenu:SetSize(visual:GetWide() / 2, height)
		local font = fw.fonts.default:atSize(showradius:GetTall() - 20)
		showradius:SetFont(font)
		hidemenu:SetFont(font)
	end

	condition.Think = function()
		if not IsValid(self) then return end
		local money = client:getMoney()

		toggle:SetText(self:GetStatus() and "Disable" or "Enable")

		if IsValid(upgrade) then
			local nextUp =  self.upgrades[self:GetUpgradeStatus() + 1]
			if not nextUp then
				upgrade:Remove()
				panel:InvalidateLayout()
			else
				upgrade:SetText("Upgrade (" .. nextUp.cost .. "$)")
				if nextUp.cost > client:getMoney() then
					upgrade:SetColor(red)
				else
					upgrade:SetColor(color_white)
				end
			end
		end

		local ammoCost = math.Round(self:GetAmmoCost() - self:GetRemaining() / self:GetMaxClip() * self:GetAmmoCost())
		refill:SetText("Refill Ammunition (" .. (ammoCost == 0 and "Full" or (ammoCost .. "$")) .. ")")
		if ammoCost > money then
			refill:SetColor(red)
		else
			refill:SetColor(color_white)
		end

		local trgt = "NO TARGET"
		if self:GetStatus() == false then
			trgt = "OFFLINE"
		elseif self:GetTargeting() then
			trgt = "TARGETING: " .. self:GetTargetingDistance() .. " units away"
		end
		target.text = trgt
		radius.text = "Targeting Radius: " .. self:GetRadius() .. " units"
		local fireRate = self:GetFireOffset()
		damage.text = "Damage: " .. self:GetDamage() .. " dmg every " .. fireRate .. " second" .. (fireRate > 0 and "s" or "")
	end

	makeButton(upgrade, btnFont)
	makeButton(refill, btnFont)
	makeButton(showradius, btnFont)
	makeButton(hidemenu, btnFont)
	makeButton(toggle, btnFont)
end
