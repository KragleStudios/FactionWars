local debugEntityPaintPosition = false -- toggles drawing sphere at the aim entity's paint position

-- DEFINE GLOBALS
fw.resource.INFO_ROW_HEIGHT = 16

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
			surface.DrawTexturedRect(1, 1, w - 2, h - 2)
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
			self._contents:SetPos(self._icon:GetWide() + 1, 0)
			self._contents:SetSize(w - self._icon:GetWide() - 1, self._contentHeight or h)
			self._contents:CenterVertical()
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

		surface.SetDrawColor(0, 155, 0, 220)
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


local function paintEntityResources(entity, info)
	local types = fw.resource.types
	if not entity.GetDisplayPosition then error("ENTITY MUST DEFINE ENTITY:GetDisplayPosition IF IT IS A RESOURCE ENTITY") end

	local panel = vgui.Create('STYLayoutVertical')
	_FW_RESOURCE_PANEL = panel

	panel.CalcLocation = function()
		local pos, ang, scale = entity:GetDisplayPosition()
		pos = entity:LocalToWorld(pos)
		ang = entity:LocalToWorldAngles(ang)
		return pos, ang, scale
	end

	panel:SetWide(200)
	panel:SetPadding(2)

	--
	-- HELPERS
	--
	local ROW_HEIGHT = 16
	local HEADER_HEIGHT = 16

	local function addHeader(titleText, size)
		local textBox = vgui.Create('FWUITextBox', panel)
		textBox:SetText(titleText)
		textBox:SetTall(size or HEADER_HEIGHT)
		textBox:SetInset(1	)
		textBox:SetAlign('left')
		textBox.Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, 0, w, h)
		end
		return textBox
	end


	local function addResourceRow(resource, amountTable, usageTable, outof)
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

	-- add production
	addHeader(entity.PrintName):SetAlign('center')

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

	vgui.make3d(panel)

end


local lastHitEntity = nil
fw.hook.Add('PostDrawTranslucentRenderables', function()
	local hitent = LocalPlayer():GetEyeTrace().Entity

	if lastHitEntity ~= hitent then
		lastHitEntity = hitent
		if IsValid(_FW_RESOURCE_PANEL) then
			local panel = _FW_RESOURCE_PANEL
			panel:AlphaTo(0, 0.5, 0, function()
				panel:Remove()
			end)
			_FW_RESOURCE_PANEL = nil
		end
		if IsValid(hitent) and hitent:FWGetResourceInfo() then
			paintEntityResources(hitent, hitent:FWGetResourceInfo())
		end
	end

	if debugEntityPaintPosition and IsValid(hitent) then
		local pos = hitent:GetDisplayPosition()
		render.DrawWireframeSphere(hitent:LocalToWorld(pos), 5, 5, 5, Color(255, 0, 0))
	end
end)

concommand.Add('fw_resource_toggleDebugPaintPosition', function()
	debugEntityPaintPosition = not debugEntityPaintPosition
	print("debug entity paint: " .. tostring(debugEntityPaintPosition))
end)
