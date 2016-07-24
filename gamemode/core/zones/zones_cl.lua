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
