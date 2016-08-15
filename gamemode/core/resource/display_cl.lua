local debugEntityPaintPosition = false -- toggles drawing sphere at the aim entity's paint position
local baseScale = 0.25

-- LOCALIZE VARIABLES
local surface = surface

-- DEFINE GLOBALS
fw.resource.INFO_ROW_HEIGHT = 16 / baseScale
fw.resource.PANEL_WIDTH = 200 / baseScale

-- CLEANUP
if IsValid(_FW_RESOURCE_PANEL) then
	_FW_RESOURCE_PANEL:Remove()
end

--
-- SETUP VGUI CLASSES
--
vgui.Register('fwEntityInfoPanel', {
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
}, 'STYPanel')

vgui.Register('fwResourceRow', {
	-- basically a row panel with an icon for the resource and a layout manager that manages content to the right
	Init = function(self)
		local icon = vgui.Create('STYImage', self)
		icon:SetMaterial(resource.material)
		icon.PerformLayout = function()
			icon:SetWide(icon:GetTall())
		end
		icon.Paint = function(self, w, h)
			if not self._material then return end
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(self._material)
			surface.DrawTexturedRect(1 / baseScale, 1 / baseScale, w - 2 / baseScale, h - 2 / baseScale)
		end
		self._icon = icon
	end,

	SetResource = function(self, resource)
		self._resource = resource
		self._icon:SetMaterial(resource.material)
	end,

	SetContentPanel = function(self, panel)
		self._contents = panel
		panel:SetParent(self)
	end,

	SetContentHeight = function(self, height)
		self._contentHeight = height
	end,

	PerformLayout = function(self)
		local w, h = self:GetSize()

		self._icon:SetPos(0, 0)
		self._icon:SetSize(h, h)

		if self._contents then
			self._contents:SetPos(self._icon:GetWide() + 1 / baseScale, 0)
			self._contents:SetSize(w - self._icon:GetWide() - 1 / baseScale, self._contentHeight or h)
			self._contents:CenterVertical()
			self._contents:InvalidateLayout(true)
		end
	end
}, 'STYPanel')

vgui.Register('fwResourceDisplayBar', {
	Init = function()

	end,
	SetUpdater = function(self, max, func)
		self._max = max
		self._updater = func
	end,

	PerformLayout = function(self)
		local w, h = self:GetSize()
		self._stepsize = math.Round((w - 2) / math.max(self._max, 5))
	end,

	Think = function(self)
		self._stop1, self._stop2 = self._updater()
	end,

	Paint = function(self, w, h)
		surface.SetDrawColor(0, 255, 0, 220)
		local x = 1
		local stepsize = self._stepsize
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, stepsize * self._max + 1, h)

		surface.SetDrawColor(0, 255, 0, 220)
		for i = 1, self._stop1 do
			surface.DrawRect(x, 1, stepsize - 1, h - 2)
			x = x + stepsize
		end

		surface.SetDrawColor(0, 100, 0, 220)
		for i = self._stop1 + 1, self._stop2 do
			surface.DrawRect(x, 1, stepsize - 1, h - 2)
			x = x + stepsize
		end

		surface.SetDrawColor(255, 255, 255, 15)
		for i = self._stop2 + 1, self._max do
			surface.DrawRect(x, 1, stepsize - 1, h - 2)
			x = x + stepsize
		end
	end
}, 'STYPanel')

vgui.Register('fwResourceDisplayText', {
	SetUpdater = function(self, prefix, max, func)
		self._prefix = prefix
		self._updater = func
		self._max = max
	end,

	Think = function(self)
		local value = self._updater()
		if value ~= self._lastvalue then
			self._lastvalue = value
			self:SetText(self._prefix .. ': ' .. tostring(value) .. '/' .. self._max)
		end
	end,

	Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
	end
}, 'FWUITextBox')

local Entity = FindMetaTable('Entity')
for k,v in ipairs(ents.GetAll()) do
	if IsValid(v._fwInfoPanel) then v._fwInfoPanel:Remove() end
end

function Entity:FWDrawInfo()
	local entity = self

	if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 1000 * 1000 then
		if IsValid(self._fwInfoPanel) then self._fwInfoPanel:Remove() end
		return
	end

	if IsValid(self._fwInfoPanel) then
		if not self.GetDisplayPosition then error("ENTITY:GetDisplayPosition must be defined to show FWInfoPanel") end
		local pos, ang, scale = entity:GetDisplayPosition()
		scale = scale * baseScale
		pos = entity:LocalToWorld(pos)
		ang = entity:LocalToWorldAngles(ang)
		self._fwInfoPanel:Draw3D(pos, ang, scale)
		return
	end

	--
	-- SETUP VARIABLES
	--
	local types = fw.resource.types
	local info = self:FWGetResourceInfo()
	if not info or not info.amProducing or not info.amStoring or not info.haveResources or not info.productionBeingUsed then return end

	local panel, outer

	--
	-- UTILS
	--
	local HEADER_HEIGHT = fw.resource.INFO_ROW_HEIGHT
	local ROW_HEIGHT = fw.resource.INFO_ROW_HEIGHT

	local function addHeader(titleText, parent)
		local textBox = vgui.Create('FWUITextBox', parent or panel)
		textBox:SetText(titleText)
		textBox:SetTall(size or HEADER_HEIGHT)
		textBox:SetInset(1)
		textBox:SetAlign('left')
		textBox.Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, 0, w, h)
		end
		return textBox
	end

	local function addResourceRow(resource, amountTable, usageTable, outof)
		print("addResourceRow("..tostring(resource)..", "..tostring(amountTable)..", " .. tostring(usageTable)..", "..tostring(outof)..")")
		if type(resource) == 'string' then
			resource = types[resource]
			if not resource then return end
		end

		local resType = resource.type

		local row = vgui.Create('fwResourceRow', panel)
		row:SetResource(resource)
		row:SetTall(ROW_HEIGHT)
		local info = vgui.Create('fwResourceDisplayBar')
		row:SetContentPanel(info)
		row:SetContentHeight(math.Round(ROW_HEIGHT * 0.4))

		info:SetUpdater(outof, function()
			return usageTable[resType] or 0, amountTable[resType] or 0
		end)

		return row
	end

	local function addStorageRow(resource, amountTable, outof)
		if type(resource) == 'string' then
			resource = types[resource]
			if not resource then return end
		end

		local resType = resource.type
		local row = vgui.Create('fwResourceRow', panel)

		row:SetResource(resource)
		row:SetTall(ROW_HEIGHT)
		local info = vgui.Create('fwResourceDisplayText')
		row:SetContentPanel(info)

		info:SetUpdater(resource.PrintName or '', outof, function()
			return amountTable[resType] or 0
		end)

		return row
	end

	--
	-- BUILD OUT PANELS
	--
	outer = vgui.Create('STYLayoutVertical')
	outer:SetWide(fw.resource.PANEL_WIDTH)
	outer:SetPadding(2 / baseScale)
	self._fwInfoPanel = outer
	addHeader(self.PrintName, outer):SetAlign('center'):SetTall(math.Round(ROW_HEIGHT * 1.2))

	local shouldAutosize = false
	local wrapper = vgui.Create('STYPanel', outer)
	wrapper.PerformLayout = function()
		if shouldAutosize then
			wrapper:SetSize(panel:GetSize())
		end
	end
	wrapper:SetVisible(false)
	wrapper:SetSize(outer:GetWide(), 0)

	panel = vgui.Create('STYLayoutVertical', wrapper)
	panel:SetPadding(2 / baseScale)
	panel:SetWide(fw.resource.PANEL_WIDTH)

	local wasBeingLookedAt = false
	outer.EndAnimate = function()
		wrapper:SetVisible(wasBeingLookedAt)
		if wasBeingLookedAt then
			outer:SetSize(panel:GetWide(), panel:GetTall())
		else
			outer:SetSize(panel:GetWide(), 0)
		end
		shouldAutosize = wasBeingLookedAt
	end
	outer.BeginAnimate = function()
		wrapper:SetVisible(true)
		shouldAutosize = false
		if wasBeingLookedAt then
			wrapper:SetSize(panel:GetWide(), 0)
			wrapper:AlphaTo(255, 0.1)
			wrapper:SizeTo(panel:GetWide(), panel:GetTall(), 0.1, 0, -1, function()
				outer:EndAnimate()
			end)
		else
			wrapper:SetSize(panel:GetSize())
			wrapper:AlphaTo(0, 0.1)
			wrapper:SizeTo(panel:GetWide(), 0, 0.1, 0, -1, function()
				outer:EndAnimate()
			end)
		end
	end
	outer.Think = function()
		local amBeingLookedAt = LocalPlayer():GetEyeTrace().Entity == self
		if amBeingLookedAt ~= wasBeingLookedAt then
			wasBeingLookedAt = amBeingLookedAt
			outer:BeginAnimate()
		end
	end

	--
	-- build out the ui
	--
	if entity.CustomUI then
		entity:CustomUI(panel)
	end

	if entity.MaxProduction and table.Count(entity.MaxProduction) > 0 and info.amProducing and info.productionBeingUsed then
		addHeader("PRODUCTION")
		for type, maxProduction in SortedPairs(entity.MaxProduction) do
			addResourceRow(type, info.amProducing, info.productionBeingUsed, maxProduction)
		end
	end

	if entity.MaxConsumption and table.Count(entity.MaxConsumption) > 0 and info.haveResources then
		addHeader("CONSUMPTION")
		for type, maxConsumption in SortedPairs(entity.MaxConsumption) do
			addResourceRow(type, info.haveResources, info.haveResources, maxConsumption)
		end
	end

	if entity.MaxStorage and table.Count(entity.MaxStorage) > 0 and info.amStoring then
		addHeader("STORAGE")
		for type, maxStorage in SortedPairs(entity.MaxStorage) do
			addStorageRow(type, info.amStoring, maxStorage)
		end
	end
end

concommand.Add('fw_resource_toggleDebugPaintPosition', function()
	debugEntityPaintPosition = not debugEntityPaintPosition
	print("debug entity paint: " .. tostring(debugEntityPaintPosition))
end)
