util.AddNetworkString("playerBuyItem")

ndoc.table.items = {}

fw.data.addPersistField('inventory')

function fw.ents.buyItem(ply, item_index)
	local canjoin, msg = fw.ents.canPlayerBuyItem(ply, item_index)

	if (not canjoin) then 
		if (msg) then
			ply:FWChatPrintError(msg)
		end
		return 
	end

	local item = fw.ents.item_list[item_index]
	local slot = fw.inv.calcInvSpot(ply)
	
	if (not slot) then 
		ply:FWChatPrintError("Your inventory is full, so you your item will be spawned instead!")
	else 
		item.slot = slot
		ndoc.table.items[ply].inventory[slot] = item_index
	end
	
	if (not item.storable or not slot) then
		if (item.shipment) then
			local ship = ents.Create("fw_shipment")
			ship:SetPos(ply:GetEyeTrace().HitPos) --TODO: Change this to smth better, we don't want to do eye trace
			ship:setEntity(item.entity)
			ship:setEntityModel(item.model)
			ship:setShipmentAmount(item.shipmentCount)
			ship:Spawn()
			ship:Activate()
			ship.itemData = item
			ship.owner = ply
		else
			local ent = ents.Create(item.entity)
			ent:SetPos(ply:GetEyeTrace().HitPos) --TODO: Change this to smth better, we don't want to do eye trace
			ent:Spawn()
			ent:Activate()
			ent.itemData = item
			ent.owner = ply
			ent:SetOwner(ply)--turret compatability
		end
	end

	--TODO: uncomment this line
	--ply:addMoney(-item.price)
end

net.Receive("playerBuyItem", function(len, ply)
	fw.ents.buyItem(ply, net.ReadInt(32))
end)

fw.hook.Add("PlayerInitialSpawn", "LoadItems", function(ply)
	ndoc.table.items[ply] = ndoc.table.items[ply] or {}
	ndoc.table.items[ply].inventory = ndoc.table.items[ply].inventory or {}
	ndoc.table.items[ply].inventory.slots = {}
	ndoc.table.items[ply].inventory.slotCount = x or fw.config.defaultInvSlots
end)

fw.hook.Add("PlayerDisconnected", "RemoveSpareItems", function(ply)
	local ownedItems = ndoc.table.items[ply].inventory

	--if the player rejoined cancel removing their things and reset to before they left
	timer.Simple(120, function()
		for k,v in pairs(player.GetAll()) do
			if (v:SteamID() == id) then
				ndoc.table.items[v].inventory = ownedItems

				return
			end
		end

		for k,v in pairs(ents.GetAll()) do
			if (v.owner and (v.owner == ply) and (v.stringID and fw.ents.item_list[v.stringID].removeOnDisc)) then
				v:Remove()
			end 
		end
	end)
end)