util.AddNetworkString('fw.zone.new')
util.AddNetworkString('fw.zone.remove')

net.Receive('fw.zone.new', function(_, pl)
	if not pl:IsSuperAdmin() then
		pl:FWChatPrintError("You must be a super admin to create zones")
		return 
	end
	local zone = fw.zone.new():receive()
	fw.zone.zoneList[zone.id] = zone

	fw.zone.initiate(zone)

	net.Start('fw.zone.new')
		zone:send()
	net.Send(player.GetAll())
end)

ndoc.table.zones = ndoc.table.zones or {}

function fw.zone.initiate(zone)
	local id = zone.id

	ndoc.table.zones[id] = {}
	ndoc.table.zones[id].controlling = nil
	ndoc.table.zones[id].factions = {}
	ndoc.table.zones[id].contesting = nil

	for k,v in pairs(fw.team.factions) do
		ndoc.table.zones[id].factions[k] = {}
		ndoc.table.zones[id].factions[k].score = 0
		ndoc.table.zones[id].factions[k].players = {}
	end
end

function fw.zone.createNewZone(zoneId, name, polygon)
	local zone = fw.zone.new():ctor(zoneId, name, polygon)
	fw.zone.zoneList[zone] = zone

	fw.zone.initiate(zone)

	return zone
end

concommand.Add('fw_zone_saveAllZones', function(pl)
	if not pl:IsSuperAdmin() then
		return pl:FWConPrint(Color(255, 0, 0), "you do not have permission to run this command")
	end
	
	fw.zone.saveZonesToFile()
	pl:FWConPrint("Saved all zones.")
end)

concommand.Add('fw_zone_removeZone', function(pl)
	if not pl:IsSuperAdmin() then 
		return pl:FWConPrint(Color(255, 0, 0), "you do not have permission to run this command")
	end

	local zone = fw.zone.playerGetZone(pl)
	if not zone then
		return pl:FWConPrint(Color(255, 0, 0), "You are not currently inside any zone.")
	end

	fw.zone.zoneList[zone.id] = nil -- remove the zone

	pl:FWConPrint("Removed the zone with id " .. tostring(zone.id) .. ":" .. tostring(zone.name))
	net.Start('fw.zone.remove')
		net.WriteUInt(zone.id, 32)
	net.Send(player.GetAll())

	pl:ConCommand('fw_zone_saveAllZones\n')
end)

concommand.Add('fw_zone_createBackup', function(pl)
	if not pl:IsSuperAdmin() then
		return pl:FWConPrint(Color(255, 0, 0), "you do not have permission to run this command")
	end

	fw.zone.createZonesBackup()
	pl:FWConPrint(Color(0, 255, 0), "Created a backup of the zones file.")
end)

function fw.zone.contest(zone, faction)
	--cooldown for adding score to teams!
	local id = zone.id
	local facScore = ndoc.table.zones[id].factions[faction.factionID].score

	if (ndoc.table.zones[id].controlling == faction.factionID) then return end

	if (facScore == fw.config.zoneCaptureScore) then
		ndoc.table.zones[id].controlling = faction.factionID
		ndoc.table.zones[id].contesting = nil

		hook.Call("FactionCapturedZone", GAMEMODE, faction, zone)

		for k,v in pairs(fw.team.factions) do
			if (k == faction.factionID) then continue end

			ndoc.table.zones[id].factions[k].score = 0
		end

		return
	end

	hook.Call("FactionContestingZone", GAMEMODE, faction, zone)

	ndoc.table.zones[id].contesting = faction
	ndoc.table.zones[id].factions[faction.factionID].score = ndoc.table.zones[id].factions[faction.factionID].score + 1
	zone.nextRegisterScore = CurTime() + fw.config.zoneCaptureRate
end

function fw.zone.canBeCaptured(zone)
	local canCapture = hook.Call("CanZoneBeCaptured", GAMEMODE, zone)

	if (zone.nextRegisterScore and CurTime() - zone.nextRegisterScore < 0) then return false end

	return true
end

hook.Add("Think", "ZoneControlLogic", function()
	--reset player counts for each faction in the zone
	for k,v in pairs(player.GetAll()) do
		local pZone = fw.zone.playerGetZone(v)

		--incase the player changed factions, and left the zone, we want to remove all instances of them being there
		if (not pZone and v.lastZone) then 
			local zoneData = ndoc.table.zones[v.lastZone.id].factions
			for k,fac in ndoc.pairs(zoneData) do

				ndoc.table.zones[v.lastZone.id].factions[k].players[v] = nil

			end

			v.lastZone = nil

		--if the player is in a zone, make sure the counter is ready, and insert them into the faction thingy
		elseif (pZone) then

			if (not fw.zone.canBeCaptured(pZone)) then continue end
			if (v.lastFaction and v.lastFaction != v:getFaction()) then
				ndoc.table.zones[pZone.id].factions[v.lastFaction].players[v] = nil

				v.lastFaction = nil
			end

			v.lastFaction = v:getFaction()

			local id = pZone.id

			if (not ndoc.table.zones[id]) then
				fw.zone.initiate(pZone)
			end

			--no use constantly syncing the player already in here
			if (not ndoc.table.zones[id].factions[v:getFaction()].players[v]) then
				ndoc.table.zones[id].factions[v:getFaction()].players[v] = true
			end

			v.lastZone = pZone
		end
	end

	--loop through the zones and do the logic 
	for zoneid, zoneTable in ndoc.pairs(ndoc.table.zones) do
		local factionInPower = nil
		local zone = fw.zone.zoneList[zoneid]

		if (not zone) then continue end
		if (not fw.zone.canBeCaptured(zone)) then return end

		for fac,v in ndoc.pairs(zoneTable.factions) do
			local plys = {}
			for k,v in ndoc.pairs(v.players) do
				table.insert(plys, k)
			end

			--if there are more players in another faction than the one who is control of the faction
			if (factionInPower and #plys > #factionInPower.playersInZone) then
				factionInPower = {}
				factionInPower.playersInZone = plys
				factionInPower.factionID = fac

				--equal disbursement of players in the zone for all factions
			elseif (factionInPower and #plys == #factionInPower.playersInZone) then
				if (ndoc.table.zones[zoneid].contesting and ndoc.table.zones[zoneid].contesting and ndoc.table.zones[zoneid].contesting.factionID != factionInPower.factionID) then
					ndoc.table.zones[zoneid].contesting = nil
				end

				return

				--for when players first enter a zone :D
			elseif (not factionInPower and #plys > 0) then
				factionInPower = {}
				factionInPower.playersInZone = plys
				factionInPower.factionID = fac
			end
		end

		--if we have a new faction in power, contest the zone
		if (factionInPower) then
			if (ndoc.table.zones[zoneid].contesting and ndoc.table.zones[zoneid].contesting.factionID != factionInPower.factionID) then
				ndoc.table.zones[zoneid].contesting = nil
			end
			
			fw.zone.contest(zone, factionInPower)
		end
	end
end)