function fw.zone.createNewZone(name, polygon)
	local zoneId
	repeat 
		zoneId = math.random(1, 9999999) -- maximum support is 9 million zones. that should be enough
	until not fw.zone.zoneList[zoneId]

	local newZone = fw.zone.new():ctor(zoneId, name, polygon)

	-- there is a permission check done serverside
	net.Start('fw.zone.new')
	newZone:send()
	net.SendToServer()

	return zoneId
end

net.Receive('fw.zone.new', function()
	local zone = fw.zone.new():receive()
	fw.zone.zoneList[zone.id] = zone
end)


fw.hook.Add('PostDrawOpaqueRenderables', 'fw.zones.render', function()

	local curZone = fw.zone.playerGetZone(LocalPlayer())

	local tr = util.QuickTrace(LocalPlayer():GetPos(), Vector(0, 0,-10000), me)
	local z = tr.HitPos.z + 0.1

	for k, zone in pairs(fw.zone.zoneList) do
		-- render all the zones
		if zone == curZone then
			zone:render(z, Color(0, 255, 0, 55))
		else 
			zone:render(z, Color(255, 255, 255, 55))
		end
	end
end)