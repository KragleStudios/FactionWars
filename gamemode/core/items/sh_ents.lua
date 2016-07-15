fw.ents.item_list = fw.ents.item_list or {}

function fw.ents.registerItem(name, tbl)
	name = name or "Undefined"

	assert(tbl.model or tbl.models, "must provide world model for: "..name)
	assert(tbl.stringID, "must provide stringID for: "..name)
	assert(tbl.entity, "must provide entity class name for: "..name)
	assert(tbl.price, "must provide price for: "..name)
	assert(tbl.max, "must provide max for: "..name)
	assert(tbl.storable, "must dictate storability for: "..name)

	tbl.name = name
	tbl.color = tbl.color or Color(100, 100, 100)
	tbl.category = tbl.category or "General Merch"

	local ind = table.insert(fw.ents.item_list, tbl)
	fw.ents.item_list[ind].index = ind	
end

fw.hook.Add("CanPlayerBuyItem", "CanBuyItem", function(ply, item_index)
	local i = fw.ents.item_list[item_index]
	if (not i) then
		return false
	end

	local maxItem  = i.max
	local curItems = ndoc.table.items[ply].inventory[i.stringID]
	local factionOnly = i.factionOnly
	local jobOnly = i.jobOnly
	local price = i.price

	if (not ply:canAfford(price)) then return false end
	if ((maxItem != 0) and curItems == maxItem) then return false end
	if (factionOnly and isbool(factionOnly) and (ply:getFaction() == nil)) then return false end
	if (factionOnly and isstring(factionOnly) and (ply:getFaction() != factionOnly)) then return false end
	--TODO: this needs to be in sync with team string ids, not team index values
	if (jobOnly and istable(jobOnly) and (not table.HasValue(jobOnly, ply:Team()))) then return false end
	if (i.canBuy) then 
		return i.canBuy(i, ply)
	end

	return true
end)