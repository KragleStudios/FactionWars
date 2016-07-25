fw.ents.item_list = fw.ents.item_list or {}

function fw.inv.getItemByInvID(ply, id)
	local slots = ndoc.table.items[ply].inventory.slots
	local item, position

	id = tonumber(id)

	for k,v in ndoc.pairs(slots) do
		if (tonumber(v.invID) == id) then 
			position = k
			item = v 

			break 
		end
	end

	return item, position
end

function fw.ents.registerItem(name, tbl)
	assert(tbl.model or tbl.models, "must provide world model for: "..name)
	assert(tbl.stringID, "must provide stringID for: "..name)
	assert(tbl.entity, "must provide entity class name for: "..name)
	assert(tbl.price, "must provide price for: "..name)
	assert(tbl.max, "must provide max for: "..name)
	tbl.sortable = tbl.sortable or false
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

		if (tbl.weapon) then
			concommand.Add(tbl.command.."_equip", function(ply, cmd, args)
				if (not tbl.shipment) then				
					local invItemID = args[1]
					local item, position = fw.inv.getItemByInvID(ply, invItemID)

					local canRemove, msg = fw.inv.canRemoveItem(ply, item)

					if (msg) then 
						ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), msg or "You can't do this!")
						return
					end

					fw.inv.removeItem(ply, position)
					ply:Give(tbl.entity)
				end
			end)
		end

		if (tbl.useable) then
			concommand.Add(tbl.command.."_use", function(ply, cmd, args)
				if (not tbl.shipment) then				
					local invItemID = args[1]
					local item, position = fw.inv.getItemByInvID(ply, invItemID)

					local canRemove, msg = fw.inv.canRemoveItem(ply, item)

					if (msg) then 
						ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), msg or "You can't do this!")
						return
					end

					fw.inv.removeItem(ply, position)
					ply:Give(tbl.entity)
				end
			end)
		end
	end
end

function fw.ents.canPlayerBuyItem(ply, itemID)
	local i = fw.ents.item_list[itemID]
	if (not i) then
		return false
	end

	local canbuy, msg = fw.hook.Call("CanPlayerBuyItem", GAMEMODE, ply, i)

	if (not canbuy and msg) then
		return false, msg
	end

	local maxItem  = i.max
	local faction = i.faction
	local jobs = i.jobs
	local price = i.price

	if (i.jobs and not istable(i.jobs)) then i.jobs = {i.jobs} end
	if (i.faction and not istable(i.faction)) then i.faction = {i.faction} end

	if (not ply:canAfford(price)) then return false, "you can't afford this!" end
	if (faction and isstring(faction) and (ply:getFaction() != faction)) then return false, "you aren't the right faction for this!" end
	if jobs and (not table.HasValue(jobs, ply:Team())) then return false, "you aren't the right job for this!" end
	if (i.canBuy) then 
		return i.canBuy(i, ply)
	end

	return true
end

function fw.inv.canRemoveItem(ply, item)
	if (not ply:inFaction() and item.factions) then
		return false, "You need to be in a faction to use this item!"
	end
	--TODO: This needs to be converted to use player team vars!! TEAM_* etc
	if (item.jobs and not table.HasValue(item.jobs, ply:Team())) then
		return false, "You are the incorrect job to use this item!"
	end

	local canremove, msg = hook.Call("CanRemoveFromInventory", GAMEMODE, ply, item)
	if (msg) then
		return canremove, msg
	end
	return true
end