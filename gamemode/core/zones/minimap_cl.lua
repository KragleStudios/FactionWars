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

local zoneLabelFont = fw.fonts.default_shadow:atSize(32)
local zoneLabelFontSmall = fw.fonts.default_shadow:atSize(26)

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

	-- draw the hexagon using clipping circles
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

	-- compute offsets to use in drawing the name label supports
	local eyeAnglesRotated = LocalPlayer():EyeAngles() + Angle(0, 180, 0)
	local eyeAnglesRotated2 = -LocalPlayer():EyeAngles()
	eyeAnglesRotated.p = 0
	local lblbeam_stop1 = Vector(0, 0, 500) -- the vertical offset for the name labels
	local lblbeam_stop2 = Vector(0, 0, 550) + eyeAnglesRotated:Right() * 50
	local lblbeam_stop3 = Vector(0, 0, 800) + eyeAnglesRotated:Right() * 50

	for k, zone in pairs(fw.zone.zoneList) do
		-- render the zone
		local territoryOwner = fw.team.factions[zone:getControllingFaction()]
		getRendererForZone(zone, zone == curZone and color_inside or color_outside, territoryOwner and territoryOwner.colorTransparent or color_nofaction):draw()

		-- render the label bar
		local center = Vector(zone.center[1], zone.center[2], 0)
		local s1 = center + lblbeam_stop1
		local s2 = center + lblbeam_stop2
		local s3 = center + lblbeam_stop3
		zone.label_pos = s3
		render.DrawLine(center, s1, color_white)
		render.DrawLine(s1, s2, color_white)
		render.DrawLine(s2, s3, color_white)
	end
	cam.PopModelMatrix()

	-- finish displaying the zone labels
	local camAngle = LocalPlayer():EyeAngles()
	camAngle:RotateAroundAxis(camAngle:Right(), 90)
	camAngle:RotateAroundAxis(camAngle:Up(), -90)

	for k, zone in pairs(fw.zone.zoneList) do
		local territoryOwner = fw.team.factions[zone:getControllingFaction()]
		local zonePosActual = m * zone.label_pos
		cam.Start3D2D(zonePosActual, camAngle, 0.05)
		draw.SimpleText(zone.name, zoneLabelFont, 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if territoryOwner then
			local scores = ndoc.table.fwZoneControl[zone.id].scores
			draw.SimpleText(territoryOwner.name .. ' %'.. scores[territoryOwner.index], zoneLabelFontSmall, 0, 26, territoryOwner.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		cam.End3D2D()
	end


	popClippingCircle(6)

	cam.IgnoreZ(false)

end)
for i = 1, 10000 do
	render.PopCustomClipPlane()
end

hook.Add('ShouldDrawLocalPlayer', 'do stuff', function()
	if inside then return true end
	return false
end)
