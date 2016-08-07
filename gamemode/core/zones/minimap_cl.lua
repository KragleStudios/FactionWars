local MINIMAP_SCALE_FACTOR = fw.config.minimapScaleFactor

local renderers = {}

local function getRendererForZone(zone, outline_color, fill_color)
	local r = renderers[zone]
	if not r or r.fillColor ~= fill_color or r.outlineColor ~= outline_color then
		if r then
			renderers[zone] = nil
			r:destroy()
		end
		r = zone:constructRenderer(outline_color, fill_color)
		renderers[zone] = r
	end
	return r
end

fw.hook.Add('PostDrawOpaqueRenderables', function()
	if not input.IsKeyDown(KEY_LALT) and not input.IsKeyDown(KEY_RALT) then return end

	local m = Matrix()
	m:SetScale(Vector(0.08, 0.08, 0.08))

	LocalPlayer():EnableMatrix( "RenderMultiply", m)
	LocalPlayer():DrawModel()

	inside = false

	local curZone = fw.zone.playerGetZone(LocalPlayer())
	local tr = util.QuickTrace(LocalPlayer():GetPos(), Vector(0, 0,-10000), me)
	local z = tr.HitPos.z + 0.1

	local color_inside = Color(0, 255, 0, 200)
	local color_outside = Color(255, 255, 255, 200)
	local color_nofaction = Color(0, 0, 0, 50)

	cam.IgnoreZ(true)

	local m = Matrix()
	m:Translate(LocalPlayer():GetPos())
	m:SetScale(Vector(MINIMAP_SCALE_FACTOR, MINIMAP_SCALE_FACTOR, MINIMAP_SCALE_FACTOR))
	m:Translate(-LocalPlayer():GetPos())

	cam.PushModelMatrix(m)
	for k, zone in pairs(fw.zone.zoneList) do
		local territoryOwner = zone:getControllingFaction()
		getRendererForZone(zone, zone == curZone and color_inside or color_outside, territoryOwner and territoryOwner.colorTransparent or color_nofaction):draw()
	end
	cam.PopModelMatrix()

	cam.IgnoreZ(false)

end)

hook.Add('ShouldDrawLocalPlayer', 'do stuff', function()
	if inside then return true end
	return false
end)
