function fw.zone._zone_mt:getControllingFaction()
	local control = ndoc.table.fwZoneControl[self.id]
	if not control then return nil end
	local maxFaction, maxValue = 0, 0
	for k,v in ndoc.pairs(control) do
		if v > maxValue then
			maxFaction = k
			maxValue = v
		end
	end
	return fw.team.factions[maxFaction]
end

--[[
--returns the faction controlling a zone
function fw.zone.getControllingFaction(zone)
	return ndoc.table.zones[zone.id] and ndoc.table.zones[zone.id].controlling
end

--returns the factiont trying to capture a zone
function fw.zone.getContestingFaction(zone)
	local contestingData = ndoc.table.zones[zone.id].contesting

	if (not contestingData) then return end

	local faction = fw.team.factions[contestingData.factionID]

	return faction
end

function fw.zone.isProtectedZone(zone)
	return ndoc.table.zones and ndoc.table.zones[zone.id].protected == true or false
end

function fw.zone.isCapturableZone(zone)
	return ndoc.table.zones and not (ndoc.table.zones[zone.id].capturable == false)
end

function fw.zone.isFactionBase(zone)
	return ndoc.table.zones and ndoc.table.zones[zone.id].faction_base
end


--returns a table of controlled zones by faction
function fw.zone.getControlledZones(faction)
	controlledZones = {}

	for k,v in pairs(fw.zone.zoneList) do
		local zID = v.id

		local fID = ndoc.table.zones[zID].controlling
		if (not fID) then continue end

		controlledZones[zID] = v
	end

	return controlledZones
end
]]
