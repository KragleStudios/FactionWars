local surface = surface

local baseScale = 0.25
fw.entity_kit.UI_BASE_SCALE = baseScale

fw.entity_kit.INFO_ROW_HEIGHT = 16 / baseScale
fw.entity_kit.INFO_ROW_WIDTH = 200 / baseScale

for k,v in ipairs(ents.GetAll()) do
	if IsValid(v._fwInfoPanel) then v._fwInfoPanel:Remove() end
end

vgui.Register('fwEntityInfoRow', {
	Init = function(self)
		self:SetTall(fw.entity_kit.INFO_ROW_HEIGHT)
	end,

	Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
	end,

	SetRefresh = function(self, shouldRefresh, refresh)
		local memory = {}
		self.Think = function(self)
			if shouldRefresh(memory) then
				refresh()
			end
		end
	end,

	Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
	end,
}, 'STYPanel')

vgui.Register('fwEntityInfoWrapper', {
	Init = function(self)
		self.BaseClass.Init(self)
		self.shouldAutosize = false

		self.headerWrapper = vgui.Create('STYLayoutVertical', self)

		self.bodyWrapper = vgui.Create('STYPanel', self)
		self.bodyWrapper:SetVisible(false)
		self.panel = vgui.Create('STYLayoutVertical', self.bodyWrapper)
		self.panel:SetPadding(2 / baseScale)
		self.panel.AddHeader = function(_, ...)
			return self:AddHeader(...)
		end
		self.panel.AddSuperHeader = function(_, titleText)
			return self:AddHeader(titleText, self.headerWrapper)
		end

		self:SetPadding(2 / baseScale)
		self.isOpen = false
	end,

	AddHeader = function(self, titleText, parent)
		local header = vgui.Create('FWUITextBox', parent or self.panel)
		header:SetTall(fw.entity_kit.INFO_ROW_HEIGHT)
		header:SetInset(2 / baseScale)
		header:SetText(titleText)
		header:SetAlign('center')
		local underscoreHeight = 1 / baseScale
		header.Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(255, 255, 255, 15)
			surface.DrawRect(0, h - underscoreHeight, w, underscoreHeight)
		end
		header.SetRefresh = function(self, shouldRefresh, refresh)
			local memory = {}
			self.Think = function(self)
				if shouldRefresh(memory) then
					refresh()
				end
			end
		end
		return header
	end,

	PerformLayout = function(self)
		self.panel:SetWide(self:GetWide())
		self.bodyWrapper:SetWide(self:GetWide())

		if self.shouldAutosize then
			self.bodyWrapper:SetSize(self.panel:GetSize())
		end

		self.BaseClass.PerformLayout(self)
	end,

	EndAnimate = function(self)
		self.bodyWrapper:SetVisible(self.isOpen)
		if self.isOpen then
			self.shouldAutosize = true
			self.bodyWrapper:SetSize(self.panel:GetSize())
		else
			self.shouldAutosize = false
			self.bodyWrapper:SetSize(self.panel:GetWide(), 0)
		end
	end,

	BeginAnimate = function(self)
		self.bodyWrapper:SetVisible(true)
		self.shouldAutosize = false

		if self.isOpen then
			self.bodyWrapper:SetSize(self.panel:GetWide(), 0)
			self.bodyWrapper:AlphaTo(255, 0.1)
			self.bodyWrapper:SizeTo(self.panel:GetWide(), self.panel:GetTall(), 0.1, 0, -1, function()
				self:EndAnimate()
			end)
		else
			self.bodyWrapper:SetSize(self.panel:GetSize())
			self.bodyWrapper:AlphaTo(0, 0.1)
			self.bodyWrapper:SizeTo(self.panel:GetWide(), 0, 0.1, 0, -1, function()
				self:EndAnimate()
			end)
		end
	end,

	Expand = function(self)
		self.isOpen = true
		self:BeginAnimate()
	end,

	Collapse = function(self)
		self.isOpen = false
		self:BeginAnimate()
	end
}, 'STYLayoutVertical')



local info_providers = {}

function fw.entity_kit.registerInfoProvider(id, func)
	table.insert(info_providers, func)
end

function fw.entity_kit.rebuildEntityInfoPanel(ent)
	if IsValid(ent._fwInfoPanel) then
		ent._fwInfoPanel:Remove()
	end

	local panel = vgui.Create('fwEntityInfoWrapper')
	panel:SetWide(fw.entity_kit.INFO_ROW_WIDTH)
	ent._fwInfoPanel = panel

	if not ent.NoEntityInfoHeader then
		local header = panel:AddHeader(ent.PrintName or 'unnamed', panel.headerWrapper)
		header:SetTall(fw.entity_kit.INFO_ROW_HEIGHT * 1.2)
	end

	for k, func in ipairs(info_providers) do
		func(ent, panel.panel) -- panel.panel is the content panel
	end

end

function fw.entity_kit.invalidateInfoPanel(ent)
	if IsValid(ent._fwInfoPanel) then
		ent._fwInfoPanel:Remove()
		ent._fwInfoPanel = nil
	end
end

local lookingAt = nil

fw.hook.Add('Think', function()
	local nowLookingAt = LocalPlayer():GetEyeTrace().Entity
	if nowLookingAt ~= lookingAt then

		-- update fwHasFocus property of the entity
		if IsValid(nowLookingAt) then
			nowLookingAt.fwHasFocus = true
		end
		if IsValid(lookingAt) then
			lookingAt.fwHasFocus = false
		end

		-- collapse or expand the entity info as appropriate
		if lookingAt and IsValid(lookingAt._fwInfoPanel) then
			lookingAt._fwInfoPanel:Collapse()
		end
		if nowLookingAt and IsValid(nowLookingAt._fwInfoPanel) then
			nowLookingAt._fwInfoPanel:Expand()
		end

		lookingAt = nowLookingAt
	end
end)


local Entity = FindMetaTable('Entity')
function Entity:FWDrawInfo()
	if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 1000 * 1000 then
		if self._fwInfoPanel ~= nil then
			fw.entity_kit.invalidateInfoPanel(self)
		end
		return
	end

	if not IsValid(self._fwInfoPanel) then
		fw.entity_kit.rebuildEntityInfoPanel(self)
	end

	if IsValid(self._fwInfoPanel) then
		if not self.GetDisplayPosition then error("ENTITY:GetDisplayPosition must be defined to show FWInfoPanel") end
		local pos, ang, scale = self:GetDisplayPosition()
		scale = scale * baseScale
		pos = self:LocalToWorld(pos)
		ang = self:LocalToWorldAngles(ang)
		self._fwInfoPanel:Draw3D(pos, ang, scale)
		return
	end
end

fw.hook.Add('EntityRemoved', function(ent)
	if IsValid(ent._fwInfoPanel) then
		ent._fwInfoPanel:Remove()
	end
end)


--
-- DEFAULT UI PROVIDERS
--

fw.entity_kit.registerInfoProvider('CustomUI', function(entity, panel)
	if entity.CustomUI then
		entity:CustomUI(panel)
	end
end)
