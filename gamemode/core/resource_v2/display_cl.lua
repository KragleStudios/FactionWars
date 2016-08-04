local debugEntityPaintPosition = false -- toggles drawing sphere at the aim entity's paint position


local function paintEntityResources(entity, alpha)
	local types = fw.resource.types

	if not entity._fw_lastSync or (CurTime() - entity._fw_lastSync) > fw.config.resourceSyncInterval then
		fw.print("requesting a sync from the server")
		fw.resource.fetchEntityStatsFromServer(entity)
		entity._fw_lastSync = CurTime()
	end

	if not IsValid(entity._fw_panel) then
		local panel = vgui.Create('STYLayoutVertical')
		entity._fw_panel = panel
		panel.CalcLocation = function()
			local pos, ang, scale = entity:GetDisplayPosition()
			pos = entity:LocalToWorld(pos)
			ang = entity:LocalToWorldAngles(ang)
			return pos, ang, scale
		end

		panel:SetWide(200)
		panel:SetPadding(2)

		panel.Think = function()
			if LocalPlayer():GetEyeTrace().Entity ~= entity then
				panel:Remove()
			end
		end

		--
		-- HELPERS
		--
		local function addHeader(titleText)
			local textBox = vgui.Create('FWUITextBox', panel)
			textBox:SetText('PRODUCTION')
			textBox:SetTall(20)
			textBox:SetAlign('center')
			textBox.Paint = function(self, w, h)
				surface.SetDrawColor(0, 0, 0, 220)
				surface.DrawRect(0, 0, w, h)
			end
		end

		local function addResourceRow(resource, amount, outof)
			if type(resource) == 'string' then
				resource = types[resource]
				if not resource then return end
			end

			local row = vgui.Create('STYPanel', panel)
			row:SetTall(15)
			row:DockPadding(2, 2, 2, 2)
			row.Paint = function(self, w, h)
				surface.SetDrawColor(0, 0, 0, 220)
				surface.DrawRect(0, 0, w, h)
			end

			local bar = vgui.Create('STYPanel', row)
			bar:Dock(FILL)

			local segmentWidth = 0
			bar.PerformLayout = function()
				local w = bar:GetWide()
				segmentWidth = (w + 1) / outof
			end
			bar.Paint = function(self, w, h)
				local x = 0
				surface.SetDrawColor(0, 220, 0, 220)
				for i = 1, outof do
					if i == amount + 1 then
						surface.SetDrawColor(0, 0, 0, 220)
					end
					surface.DrawRect(x, 0, segmentWidth - 1, h)
					x = x + segmentWidth
				end
			end
			bar:DockMargin(3, 8, 0, 0)
			bar:Dock(FILL)


			local icon = vgui.Create('STYImage', row)
			icon:SetMaterial(resource.material)
			icon.PerformLayout = function()
				icon:SetWide(icon:GetTall())
			end
			icon:Dock(LEFT)
		end

		-- add production
		if table.Count(entity.Produces) > 0 then
			addHeader("PRODUCTION")
			PrintTable(entity.Produces)

			for type, production in SortedPairs(entity.Produces) do
				addResourceRow(type, production, entity.MaxProduction[type] or production)
			end

		end

		vgui.make3d(panel)

	end

end

fw.hook.Add('PostDrawTranslucentRenderables', function()
	local hitent = LocalPlayer():GetEyeTrace().Entity
	if IsValid(hitent) and hitent.Resources then
		paintEntityResources(hitent, 1)
	end
end)

fw.hook.Add('UpdatedEntityResourceData', function(ent)
	if IsValid(ent._fw_panel) then
		ent._fw_panel:Remove()
	end
end)

concommand.Add('fw_resource_toggleDebugPaintPosition', function()
	debugEntityPaintPosition = not debugEntityPaintPosition
	print("debug entity paint: " .. tostring(debugEntityPaintPosition))
end)
