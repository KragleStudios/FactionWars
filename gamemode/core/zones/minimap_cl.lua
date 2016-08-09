--
-- Minimap by thelastpenguin
--

local math = math
local render = render
local Vector = Vector

local MINIMAP_SCALE_FACTOR = fw.config.minimapScaleFactor
local MINIMAP_RADIUS = 30

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

local function pushClippingCircle(pos, radius, edges)
	local stepSize = (2 * math.pi / edges)
	for i = 0, 2 * math.pi, stepSize do
		local x = math.sin(i)
		local y = math.cos(i)
		local v = Vector(x, y, 0)
		render.PushCustomClipPlane(v, (pos - v * radius):DotProduct(v))
	end
end

local function popClippingCircle(edges)
	local stepSize = (2 * math.pi / edges)
	for i = 0, 2 * math.pi, stepSize do
		render.PopCustomClipPlane()
	end
end


fw.hook.Add('PostDrawOpaqueRenderables', function()
	if not input.IsKeyDown(KEY_LALT) and not input.IsKeyDown(KEY_RALT) then return end

	local curZone = fw.zone.playerGetZone(LocalPlayer())
	local tr = util.QuickTrace(LocalPlayer():GetPos(), Vector(0, 0,-10000), me)
	local z = tr.HitPos.z + 0.1

	local color_inside = Color(0, 255, 0, 200)
	local color_outside = Color(255, 255, 255, 200)
	local color_nofaction = Color(0, 0, 0, 100)

	cam.IgnoreZ(true)

	-- transformation matrix
	local m = Matrix()
	m:Translate(LocalPlayer():GetPos())
	m:SetScale(Vector(MINIMAP_SCALE_FACTOR, MINIMAP_SCALE_FACTOR, MINIMAP_SCALE_FACTOR))
	m:Translate(-LocalPlayer():GetPos())
	local translate = m:GetTranslation()
	translate.z = LocalPlayer():GetPos().z
	m:SetTranslation(translate)

	-- push custom clipping planes
	local myPos = LocalPlayer():GetPos()
	local stepSize = (2 * math.pi / 6)

	pushClippingCircle(myPos, MINIMAP_RADIUS + 0.3, 6)
	cam.Start3D2D(myPos, Angle(0, 0, 0), 0.2)
		surface.SetDrawColor(255, 255, 255, 100)
		surface.DrawRect(-300, -300, 600, 600)

		surface.DrawRect(-300, -1, 600, 1)
		surface.DrawRect(-1, -300, 1, 600)

	cam.End3D2D()
	popClippingCircle(6)

	pushClippingCircle(myPos, MINIMAP_RADIUS, 6)
	cam.Start3D2D(myPos, Angle(0, 0, 0), 1)
		surface.SetDrawColor(0, 0, 20, 230)
		surface.DrawRect(-150, -150, 300, 300)
	cam.End3D2D()


	cam.PushModelMatrix(m)
	for k, zone in pairs(fw.zone.zoneList) do
		local territoryOwner = zone:getControllingFaction()
		local territoryOwner = fw.team.factions[territoryOwner]
		getRendererForZone(zone, zone == curZone and color_inside or color_outside, territoryOwner and territoryOwner.colorTransparent or color_nofaction):draw()
	end
	cam.PopModelMatrix()
	popClippingCircle(6)



	cam.IgnoreZ(false)

end)

hook.Add('ShouldDrawLocalPlayer', 'do stuff', function()
	if inside then return true end
	return false
end)
