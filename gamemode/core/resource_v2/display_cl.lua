local debugEntityPaintPosition = false -- toggles drawing sphere at the aim entity's paint position

if IsValid(_FW_RESOURCE_PANEL) then
	_FW_RESOURCE_PANEL:Remove()
end

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
	local function addHeader(titleText)
		local textBox = vgui.Create('FWUITextBox', panel)
		textBox:SetText(titleText)
		textBox:SetTall(18)
		textBox:SetAlign('center')
		textBox.Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, 0, w, h)
		end
	end

	local ROW_HEIGHT = 18

	local function addResourceRow(resource, amountTable, usageTable, outof)
		if type(resource) == 'string' then
			resource = types[resource]
			if not resource then return end
		end

		local resType = resource.type

		local row = vgui.Create('STYPanel', panel)
		row:SetTall(ROW_HEIGHT)

		local bar = vgui.Create('STYPanel', row)
		bar:Dock(FILL)

		local segmentWidth = 0
		bar.PerformLayout = function()
			local w = bar:GetWide()
			segmentWidth = (w + 1) / math.max(outof, 5)
		end
		bar.Paint = function(self, w, h)
			local amount = amountTable[resType] or 0
			local usage = usageTable[resType] or 0

			local x = 0
			surface.SetDrawColor(0, 220, 0, 220)
			for i = 1, outof do
				if i == usage + 1 then
					surface.SetDrawColor(0, 100, 0, 220)
				end
				if i == amount + 1 then
					surface.SetDrawColor(0, 0, 0, 220)
				end
				surface.DrawRect(x, 0, segmentWidth - 1, h)
				x = x + segmentWidth
			end
		end
		bar:DockMargin(3, 5, 0, 5)
		bar:Dock(FILL)

		-- create the icon
		local icon = vgui.Create('STYImage', row)
		icon:SetMaterial(resource.material)
		icon.PerformLayout = function()
			icon:SetWide(icon:GetTall())
		end
		icon.Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(self._material)
			surface.DrawTexturedRect(1, 1, w - 2, h - 2)
		end
		icon:Dock(LEFT)
	end

	local function addStorageRow(resource, amountTable, outof)
		if type(resource) == 'string' then
			resource = types[resource]
			if not resource then return end
		end

		local resType = resource.type

		local row = vgui.Create('STYPanel', panel)
		row:SetTall(ROW_HEIGHT)

		local textbox = vgui.Create('FWUITextBox', row)
		textbox:Dock(FILL)
		textbox:DockMargin(2, 0, 0, 0)
		textbox:SetInset(2)
		local lastAmount = {}
		textbox.Paint = function(self, w, h)
			if lastAmount ~= amountTable[resType] then
				lastAmount = amountTable[resType]
				textbox:SetText(resource.PrintName .. ': ' .. tostring(amountTable[resType] or 0) .. ' / ' .. outof)
			end
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, 0, w, h)
		end

		-- create the icon
		local icon = vgui.Create('STYImage', row)
		icon:SetMaterial(resource.material)
		icon.PerformLayout = function()
			icon:SetWide(icon:GetTall())
		end
		icon.Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(self._material)
			surface.DrawTexturedRect(1, 1, w - 2, h - 2)
		end
		icon:Dock(LEFT)
	end

	-- add production
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
			_FW_RESOURCE_PANEL:Remove()
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
