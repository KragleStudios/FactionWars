fw.ents.item_list = fw.ents.item_list or {}

function fw.ents.registerItem(name, tbl)
	assert(tbl.model or tbl.models, "must provide world model for: "..name)
	assert(tbl.stringID, "must provide stringID for: "..name)
	assert(tbl.entity, "must provide entity class name for: "..name)
	assert(tbl.price, "must provide price for: "..name)
	
	tbl.max = tbl.max or 0
	tbl.command = tbl.command or "fw_item_"..tbl.stringID
	tbl.name = name
	tbl.color = tbl.color or Color(100, 100, 100)
	tbl.category = tbl.category or "General Merch"

	local ind = table.insert(fw.ents.item_list, tbl)
	fw.ents.item_list[ind].index = ind	

	if (SERVER) then
		concommand.Add(tbl.command, function(ply)
			fw.ents.buyItem(ply, ind)
		end)
	end

	fw.hook.Call("FWItemRegistered", tbl)
end

function fw.ents.registerWeapon(name, tbl)
	tbl.weapon = true

	fw.ents.registerItem(name, tbl)
end

function fw.ents.registerShipment(name, tbl)
	assert(tbl.model, "must provide world model for: "..name)
	assert(tbl.stringID, "must provide stringID for: "..name)
	assert(tbl.entity, "must provide entity class name for: "..name)
	assert(tbl.price, "must provide price for: "..name)
	assert(tbl.shipmentCount, "must provide count for how many are in the shipment :"..name)

	tbl.seperate = tbl.seperate or false
	tbl.max = tbl.max or 0
	tbl.command = tbl.command or "fw_item_"..tbl.stringID
	tbl.name = name
	tbl.color = tbl.color or Color(100, 100, 100)
	tbl.category = tbl.category or "General Merch"

	if (tbl.seperate) then
		assert(tbl.seperatePrice, "must provide a price for each individual weapon for :"..name)
	
		local indx = table.insert(fw.ents.item_list, {
			model = tbl.model,
			stringID = tbl.stringID.."_sep",
			entity = tbl.entity,
			price = tbl.seperatePrice,
			max = tbl.max,
			command = tbl.command.."_sep",
			name = tbl.name,
			color = tbl.color,
			category = tbl.category,
			storable = tbl.storable,
			weapon = tbl.weapon,
			useable = tbl.useable
		})
		fw.ents.item_list[indx].index = indx

		if (SERVER) then
			concommand.Add(tbl.command.."_sep", function(ply)
				fw.ents.buyItem(ply, indx)
			end)
		end


		fw.hook.Call("FWItemRegistered", fw.ents.item_list[indx])
	end

	local ind = table.insert(fw.ents.item_list, {
			model = tbl.model,
			stringID = tbl.stringID,
			entity = tbl.entity,
			price = tbl.price,
			max = tbl.max,
			command = tbl.command,
			name = tbl.name.. " Shipment",
			color = tbl.color,
			category = tbl.category,
			storable = tbl.storable,
			shipment = true,
			shipmentCount = tbl.shipmentCount
		})

	tbl.shipment = true

	fw.ents.item_list[ind].index = ind	

	if (SERVER) then
		concommand.Add(tbl.command, function(ply)
			fw.ents.buyItem(ply, ind)
		end)
	end

	fw.hook.Call("FWItemRegistered", fw.ents.item_list[ind])
end

function fw.ents.canPlayerBuyItem(ply, itemID)
	local i = fw.ents.item_list[itemID]
	if (not i) then
		return false
	end

	local canbuy, msg = fw.hook.Call("CanPlayerBuyItem", ply, i)

	if (not canbuy and msg) then
		return false, msg
	end

	local maxItem  = i.max
	local faction = i.faction
	local jobs = i.jobs
	local price = i.price

	ply.maxItems = ply.maxItems or {}

	if (i.jobs and not istable(i.jobs)) then i.jobs = {i.jobs} end
	if (i.faction and not istable(i.faction)) then i.faction = {i.faction} end

	if (not ply:canAfford(price)) then return false, "you can't afford this!" end
	if (faction and isstring(faction) and (ply:getFaction() != faction)) then return false, "you aren't the right faction for this!" end
	if jobs and (not table.HasValue(jobs, ply:Team())) then return false, "you aren't the right job for this!" end
	
	if (ply.maxItems[i.entity] and maxItem and maxItem != 0 and ply.maxItems[i.entity] + 1 > maxItem) then
		return false, "you already have the max allowed of this item!"
	end

	if (i.canBuy) then 
		return i.canBuy(i, ply)
	end

	return true
end