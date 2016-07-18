include("shared.lua")
include("3d2dvgui.lua")


--colors for the buttons
cols = {
	outline = Color(255, 255, 255),
	outline_hov = Color(196, 196, 196),
	outline_click = Color(140, 140, 140),
	outline_disabled = Color(100, 100, 100),
	bg = Color(0, 0, 0, 100),
	bg_hov = Color(0, 0, 0, 200),
	bg_click = Color(0, 0, 0, 100),
		
	text = Color(255, 255, 255),
	text_hov = Color(196, 196, 196),
	text_click = Color(140, 140, 140),
	text_disabled = Color(100, 100, 100),
}

--create the inital menu to be turned into 3d2d
local function createMenu(ent)
	local form = vgui.Create("DFrame")
	form:SetPos(0, 0)
	form:SetSize(300, 300)
	form:SetTitle(" ")
	form:ShowCloseButton(false)
	form:SetVisible(true)
	function form:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
		draw.RoundedBox(0, 5, h - 42.5, w - 10, 37.5, Color(0, 0, 0, 255))

		local remain_width = (ent:GetRemaining() / ent:GetMaxClip()) * (w - 10)
		draw.RoundedBox(0, 5, h - 42.5, remain_width, 37.5, Color(34, 139, 34, 255))

		local health_width = (ent:GetTHealth() / ent:GetTMaxHealth()) * (w - 10)
		draw.RoundedBox(0, 5, h - 85, w - 10, 37.5, Color(0, 0, 0, 255))
		draw.RoundedBox(0, 5, h - 85, health_width, 37.5, Color(255, 0, 0, 255))

		local cooldown_width = (ent:GetCooldown() / ent:GetFireOffset()) * 145
		draw.RoundedBox(0, 150, h - 127.5, 145, 37.5, Color(0, 0, 0, 255))
		draw.RoundedBox(0, 150, h - 127.5, cooldown_width, 37.5, Color(255, 0, 0, 255))
	end

	local hidefont = fw.fonts.default:fitToView(0, 0, 'a')

	form.toggle = vgui.Create("DButton", form)
	form.toggle:SetSize(140, 60)
	form.toggle:SetFont(hidefont)
	form.toggle:SetPos(5, 5)

	function form.toggle:OnCursorEntered()
		self.hovered = true
	end
	function form.toggle:OnCursorExited()
		self.hovered = false
	end
	function form.toggle:Paint(w, h)
		self.outline = cols.outline
		self.text    = cols.text
		self.bg      = cols.bg
		if (self.hovered) then
			self.outline = cols.outline_hov
			self.text    = cols.text_hov
			self.bg      = cols.bg_hov
		end
		if (self.hovered and LocalPlayer():KeyDown(IN_USE)) then
			self.outline = cols.outline_click
			self.text    = cols.text_click
			self.bg      = cols.bg_click
		end
		if (self:GetDisabled()) then
			self.outline = cols.outline_disabled
			self.text    = cols.text_disabled
			self.bg      = cols.bg
		end

		draw.RoundedBox(0, 0, 0, w, h, self.bg)

		surface.SetDrawColor(self.outline)
		surface.DrawOutlinedRect(0, 0, w, h)

		local font = fw.fonts.default:fitToView(w, h, self:GetText())
		draw.SimpleText(self:GetText(), font, w / 2, h / 2, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end


	form.upgrade = vgui.Create("DButton", form)
	form.upgrade:SetSize(67.5, 67.5)
	form.upgrade:SetPos(5, 70)
	form.upgrade:SetText("Upgrade")
	form.upgrade:SetFont(hidefont)
	function form.upgrade:DoClick()
		net.Start("fw.upgradeTurret")
			net.WriteEntity(ent)
		net.SendToServer()
	end
	function form.upgrade:OnCursorEntered()
		self.hovered = true
	end
	function form.upgrade:OnCursorExited()
		self.hovered = false
	end
	function form.upgrade:Paint(w, h)
		self.outline = cols.outline
		self.text    = cols.text
		self.bg      = cols.bg
		if (self.hovered) then
			self.outline = cols.outline_hov
			self.text    = cols.text_hov
			self.bg      = cols.bg_hov
		end
		if (self.hovered and LocalPlayer():KeyDown(IN_USE)) then
			self.outline = cols.outline_click
			self.text    = cols.text_click
			self.bg      = cols.bg_click
		end
		if (self:GetDisabled()) then
			self.outline = cols.outline_disabled
			self.text    = cols.text_disabled
			self.bg      = cols.bg
		end

		draw.RoundedBox(0, 0, 0, w, h, self.bg)

		surface.SetDrawColor(self.outline)
		surface.DrawOutlinedRect(0, 0, w, h)

		local font = fw.fonts.default:fitToView(w, h, self:GetText())
		draw.SimpleText(self:GetText(), font, w / 2, h / 2, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	form.refillAmmo = vgui.Create("DButton", form)
	form.refillAmmo:SetSize(67.5, 67.5)
	form.refillAmmo:SetPos(77.5, 70)
	form.refillAmmo:SetText("Refill Ammmo")
	form.refillAmmo:SetFont(hidefont)
	function form.refillAmmo:DoClick()
		net.Start("fw.buyAmmo")
			net.WriteEntity(ent)
		net.SendToServer()
	end
	function form.refillAmmo:OnCursorEntered()
		self.hovered = true
	end
	function form.refillAmmo:OnCursorExited()
		self.hovered = false
	end
	function form.refillAmmo:Paint(w, h)
		self.outline = cols.outline
		self.text    = cols.text
		self.bg      = cols.bg
		if (self.hovered) then
			self.outline = cols.outline_hov
			self.text    = cols.text_hov
			self.bg      = cols.bg_hov
		end
		if (self.hovered and LocalPlayer():KeyDown(IN_USE)) then
			self.outline = cols.outline_click
			self.text    = cols.text_click
			self.bg      = cols.bg_click
		end
		if (self:GetDisabled()) then
			self.outline = cols.outline_disabled
			self.text    = cols.text_disabled
			self.bg      = cols.bg
		end

		draw.RoundedBox(0, 0, 0, w, h, self.bg)

		surface.SetDrawColor(self.outline)
		surface.DrawOutlinedRect(0, 0, w, h)

		local font = fw.fonts.default:fitToView(w, h, self:GetText())
		draw.SimpleText(self:GetText(), font, w / 2, h / 2, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end


	form.toggleRadius = vgui.Create("DButton", form)
	form.toggleRadius:SetSize(67.5, 67.5)
	form.toggleRadius:SetPos(5, 142.5)
	form.toggleRadius:SetText(ent.show_radius and "Radius Off" or "Radius On")
	form.toggleRadius:SetFont(hidefont)
	function form.toggleRadius:DoClick()
		ent.show_radius = not ent.show_radius
	end
	function form.toggleRadius:OnCursorEntered()
		self.hovered = true
	end
	function form.toggleRadius:OnCursorExited()
		self.hovered = false
	end
	function form.toggleRadius:Paint(w, h)
		self.outline = cols.outline
		self.text    = cols.text
		self.bg      = cols.bg
		if (self.hovered) then
			self.outline = cols.outline_hov
			self.text    = cols.text_hov
			self.bg      = cols.bg_hov
		end
		if (self.hovered and LocalPlayer():KeyDown(IN_USE)) then
			self.outline = cols.outline_click
			self.text    = cols.text_click
			self.bg      = cols.bg_click
		end
		if (self:GetDisabled()) then
			self.outline = cols.outline_disabled
			self.text    = cols.text_disabled
			self.bg      = cols.bg
		end

		draw.RoundedBox(0, 0, 0, w, h, self.bg)

		surface.SetDrawColor(self.outline)
		surface.DrawOutlinedRect(0, 0, w, h)

		local font = fw.fonts.default:fitToView(w, h, self:GetText())
		draw.SimpleText(self:GetText(), font, w / 2, h / 2, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	form.toggleMenu = vgui.Create("DButton", form)
	form.toggleMenu:SetSize(67.5, 67.5)
	form.toggleMenu:SetPos(77.5, 142.5)
	form.toggleMenu:SetText(ent:GetMenuOpen() and "Menu Off" or "Menu On")
	form.toggleMenu:SetFont(hidefont)
	function form.toggleMenu:DoClick()
		net.Start("fw.toggleMenu")
			net.WriteEntity(ent)
		net.SendToServer()
	end
	function form.toggleMenu:OnCursorEntered()
		self.hovered = true
	end
	function form.toggleMenu:OnCursorExited()
		self.hovered = false
	end
	function form.toggleMenu:Paint(w, h)
		self.outline = cols.outline
		self.text    = cols.text
		self.bg      = cols.bg
		if (self.hovered) then
			self.outline = cols.outline_hov
			self.text    = cols.text_hov
			self.bg      = cols.bg_hov
		end
		if (self.hovered and LocalPlayer():KeyDown(IN_USE)) then
			self.outline = cols.outline_click
			self.text    = cols.text_click
			self.bg      = cols.bg_click
		end
		if (self:GetDisabled()) then
			self.outline = cols.outline_disabled
			self.text    = cols.text_disabled
			self.bg      = cols.bg
		end

		draw.RoundedBox(0, 0, 0, w, h, self.bg)

		surface.SetDrawColor(self.outline)
		surface.DrawOutlinedRect(0, 0, w, h)

		local font = fw.fonts.default:fitToView(w, h, self:GetText())
		draw.SimpleText(self:GetText(), font, w / 2, h / 2, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end


	form.distance = vgui.Create("DLabel", form)
	form.distance:SetText("3")
	form.distance:SetPos(150, 30)

	form.maxclip = vgui.Create("DLabel", form)
	form.maxclip:SetText(" 2")
	form.maxclip:SetPos(10, form:GetTall() - 38)

	form.status = vgui.Create("DLabel", form)
	form.status:SetText("1")
	form.status:SetPos(150, 5)

	form.radius = vgui.Create("DLabel", form)
	form.radius:SetText("1")
	form.radius:SetPos(150, 65)

	form.damage = vgui.Create("DLabel", form)
	form.damage:SetText("1")
	form.damage:SetPos(150, 90)

	form.health = vgui.Create("DLabel", form)
	form.health:SetText("Health")
	form.health:SetPos(10, form:GetTall() - 80)

	form.upgrade_cost = vgui.Create("DLabel", form)
	form.upgrade_cost:SetText(" ")
	form.upgrade_cost:SetPos(150, 110)

	form.ammo_cost = vgui.Create("DLabel", form)
	form.ammo_cost:SetText(" ")
	form.ammo_cost:SetPos(150, 130)


	return form
end


--handles the 3d2d logic
local toggle = true
function ENT:Draw()

	--for the net msg
	local ent = self
	self:DrawModel()
	local on = self:GetStatus()

	if (LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000 * 1000) then
		self.form:SetVisible(false)
		return 
	end

	if (not self.form) then
		self.form = createMenu(self)
	end

	function self.form.toggle:DoClick()
		net.Start("fw.updateTurretStatus")
			net.WriteEntity(ent)
			if (on) then --i know this is stupid, but I can't figure out why the logical way isn't working??
				net.WriteBool(false)
			else
				net.WriteBool(true)
			end
		net.SendToServer()
	end

	self.form.toggle:SetText(on and "Off" or "On")
	self.form.toggleRadius:SetText(self.show_radius and "Radius Off" or "Radius On")
	self.form.toggleMenu:SetText(self:GetMenuOpen() and "Menu Off" or "Menu On")

	local disabled = tonumber(ent:GetRemaining()) == tonumber(ent:GetMaxClip())
	self.form.refillAmmo:SetDisabled(disabled)

	local disabled = false
	if (not self.upgrades[self:GetUpgradeStatus() + 1]) then
		disabled = true
	end
	self.form.upgrade:SetDisabled(disabled)

	local distance = "NO TARGET"
	if (self:GetTargeting()) then
		distance = self:GetTargetingDistance() .. " units away"
	end
	self.form:SetVisible(self:GetMenuOpen())

	self.form.distance:SetFont(fw.fonts.default:fitToView(142.5, 140, distance))
	self.form.distance:SetText(distance)
	self.form.distance:SizeToContents()

	local rad = "Targeting Radius: "..self:GetRadius()
	self.form.radius:SetFont(fw.fonts.default:fitToView(142.5, 140, rad))
	self.form.radius:SetText(rad)
	self.form.radius:SizeToContents()

	local dmg = "Damage: "..self:GetDamage().." every "..self:GetFireOffset().." ms"
	self.form.damage:SetFont(fw.fonts.default:fitToView(142.5, 140, dmg))
	self.form.damage:SetText(dmg)
	self.form.damage:SizeToContents()

	local text = self:GetRemaining() .. "/" ..self:GetMaxClip().. " shots left"
	self.form.maxclip:SetFont(fw.fonts.default:fitToView(180, 140, text))
	self.form.maxclip:SetText(text)
	self.form.maxclip:SizeToContents()

	local health = "Health: "..self:GetTHealth()
	self.form.health:SetFont(fw.fonts.default:fitToView(100, 140, health))
	self.form.health:SetText(health)
	self.form.health:SizeToContents()

	local upgradeInt = self:GetUpgradeStatus() + 1
	local upgradeCost = self.upgrades[upgradeInt] and "$"..self.upgrades[upgradeInt].cost or "MAX"
	local upgradeText = "Upgrade Cost: "..upgradeCost
	self.form.upgrade_cost:SetFont(fw.fonts.default:fitToView(145, 140, upgradeText))
	self.form.upgrade_cost:SetText(upgradeText)
	self.form.upgrade_cost:SizeToContents()

	local ammoInt = (self:GetRemaining() / self:GetMaxClip()) * self:GetAmmoCost()
	local ammoCost = math.Round(self:GetAmmoCost() - ammoInt)
	local ammoText = "Ammo Cost: $"..ammoCost
	self.form.ammo_cost:SetFont(fw.fonts.default:fitToView(145, 140, upgradeText))
	self.form.ammo_cost:SetText(ammoText)
	self.form.ammo_cost:SizeToContents()

	local text = "OFF"
	if (self:GetStatus() and self:GetTargeting()) then
		text = "TARGETING"
	elseif (self:GetStatus()) then
		text = "SEARCHING"
	elseif (self:GetRemaining() == 0) then
		text = "ERROR"
	end

	self.form.status:SetFont(fw.fonts.default:fitToView(142., 140, distance))
	self.form.status:SetText(text)
	self.form.status:SizeToContents()

	local outline_col = Color(255, 255, 255)
	local dis = self:GetTargetingDistance()
	if (self:GetTargeting()) then
		outline_col = self.targeting_outline_color
	end

	local ang = self:GetDefaultAngle()
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:SnapTo("r", 45)

	--TODO: FIX POSITIONING !!!!!
	local z = self:GetModel() == "models/combine_turrets/ground_turret.mdl" and 35 or 65
	local pos = self:GetPos() + Vector(-15, 15, z)

	vgui.Start3D2D(pos, ang, .1)
		self.form:Paint3D2D()
	vgui.End3D2D()

	if (not self.show_radius) then return end
	cam.Start3D2D(self:GetPos() - Vector(0, 0, 10), Angle(0, 0, 0), 1)
		surface.DrawCircle(0, 0, self:GetRadius(), 255, 255, 255, 255)
	cam.End3D2D()
end