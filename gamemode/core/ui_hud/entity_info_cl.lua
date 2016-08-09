vgui.Register('FWHUDEntityInfo', {
	Init = function(self)
		self.content = vgui.Create('STYLayoutVertical', self)
		self.content:SetPadding(sty.ScreenScale(1))

		self.panelStack = {self.content}
	end,

	SetEntity = function(self, entity)
		self._entity = entity

		-- TODO: make entity health update
		if entity:getHealth() then
			self:GetTop():Add(vgui.Create('FWUITableViewItem'):SetText('HEALTH: ' .. entity:getHealth() .. '/' .. entity:getMaxHealth()))
		end

		if entity.GetBuff and entity:GetBuff() != "" then
			self:GetTop():Add(vgui.Create('FWUITableViewItem'):SetText(fw.weapons.buffs[entity:GetBuff()][2]))
		end

		self:GetTop():Add(vgui.Create('FWUITableViewItem'):SetText('OWNER: ' .. 'unknown'))

		self:GetTop():Add(self:PushPanel(vgui.Create('FWUITableViewSection'):SetTitle("RESOURCES")))

		-- add panels to self:GetTop() here for resource information

		self:EndPanel()
	end,

	PushPanel = function(self, panel)
		table.insert(self.panelStack, panel)
		return panel
	end,

	EndPanel = function(self)
		self.panelStack[#self.panelStack]:PerformLayout()
		self.panelStack[#self.panelStack] = nil
	end,

	GetTop = function(self)
		return self.panelStack[#self.panelStack]
	end,

	PerformLayout = function(self)
		self.content:SetWide(self:GetWide())
		self:SetSize(sty.ScreenScale(100), self.content:GetTall())
		self:SetPos(sty.ScrW * 0.5 - self:GetWide() * 0.5, sty.ScrH * 0.5 + sty.ScreenScale(30))
		self.content:PerformLayout()
	end,

}, 'STYPanel')

if IsValid(__FWHUD_ENTITYINFO) then
	__FWHUD_ENTITYINFO:Remove()
end

fw.hook.Add('PreRender', 'fw.hud.entityInfo', function()
	local ent = LocalPlayer():GetEyeTrace().Entity

	if IsValid(__FWHUD_ENTITYINFO) then
		if __FWHUD_ENTITYINFO._entity ~= ent then
			__FWHUD_ENTITYINFO:Remove()
		else
			return
		end
	end

	if IsValid(ent) and not (LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") then

		__FWHUD_ENTITYINFO = vgui.Create('FWHUDEntityInfo')
		__FWHUD_ENTITYINFO:SetEntity(ent)
		__FWHUD_ENTITYINFO:PerformLayout()

	end

	if not IsValid(ent) then
		if IsValid(__FWHUD_ENTITYINFO) then
		end
	end

end)
