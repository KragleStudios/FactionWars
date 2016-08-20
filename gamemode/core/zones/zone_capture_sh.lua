function fw.zone._zone_mt:getControllingFaction()
	if not ndoc.table.fwZoneControl or not ndoc.table.fwZoneControl[self.id] then return end
	local control = ndoc.table.fwZoneControl[self.id].scores
	if not control then return nil end
	local maxFaction, maxValue = 0, 0
	for k,v in ndoc.pairs(control) do
		if v > maxValue then
			maxFaction = k
			maxValue = v
		end
	end
	return maxFaction
end

--if it returns a value, it's the faction id of the base!
function fw.zone._zone_mt:getFactionBase()
	return ndoc.table.fwZoneControl[self.id].isFactionBase
end

function fw.zone._zone_mt:isCapturable()
	return not (ndoc.table.fwZoneControl[self.id].isNotCapturable == true)
end

function fw.zone._zone_mt:isProtected()
	return ndoc.table.fwZoneControl[self.id].isProtected
end
