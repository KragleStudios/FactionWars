fw.hook.Add("CanRemoveFromInventory", "RemoveItem", function(ply, item)
	if (not ply:inDefaultFaction() and item.factionOnly) then
		return false, "You need to be in a faction to use this item!"
	end
	--TODO: This needs to be converted to use player team vars!! TEAM_* etc
	if (item.jobOnly and not table.HasValue(item.jobOnly, ply:Team())) then
		return false, "You are the incorrect job to use this item!"
	end

	local count = ndoc.table.items[ply].inventory[item.stringID].count
	if (count - 1 < 0) then
		return false, "You don't have enough items for this!"
	end
	return true
end)