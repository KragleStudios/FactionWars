util.AddNetworkString('fw.zone.new')

net.Receive('fw.zone.new', function(_, pl)
	if not pl:IsSuperAdmin() then
		pl:FWChatPrintError("You must be a super admin to create zones")
		return 
	end
	local zone = fw.zone.new():receive()
	fw.zone.zoneList[zone.id] = zone

	net.Start('fw.zone.new')
		zone:send()
	net.Send(player.GetAll())
end)

function fw.zone.createNewZone(zoneId, name, polygon)
	local zone = fw.zone.new():ctor(zoneId, name, polygon)
	fw.zone.zoneList[zone] = zone
	return zone
end

concommand.Add('fw_zone_saveAllZones', function(pl)
	if not pl:IsSuperAdmin() then
		return pl:FWConPrint(Color(255, 0, 0), "you do not have permission to run this command")
	end
	
	fw.zone.saveZonesToFile()
	pl:FWConPrint("Saved all zones.")
end)

concommand.Add('fw_zone_createBackup', function(pl)
	if not pl:IsSuperAdmin() then
		return pl:FWConPrint(Color(255, 0, 0), "you do not have permission to run this command")
	end

	fw.zone.createZonesBackup()
	pl:FWConPrint(Color(0, 255, 0), "Created a backup of the zones file.")
end)