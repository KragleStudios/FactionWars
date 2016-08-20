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

net.Receive('fw.zone.remove', function()
	fw.zone.zoneList[net.ReadUInt(32)] = nil
end)
