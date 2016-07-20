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
	local list = ndoc.table.items[ply].inventory[item.stringID]

	if (not list and item.storable) then
		ndoc.table.items[ply].inventory[item.stringID] = {}
		ndoc.table.items[ply].inventory[item.stringID].count = 1
	elseif (item.storable) then
		ndoc.table.items[ply].inventory[item.stringID].count = list.count + 1
	end
	if (item.shipment and item.storable) then
		ndoc.table.items[ply].inventory[item.stringID].remaining = item.shipmentCount
	end
	if (not item.storable) then
		if (item.shipment) then
			local ship = ents.Create("fw_shipment")
			ship:SetPos(ply:GetEyeTrace().HitPos) --TODO: Change this to smth better, we don't want to do eye trace
			ship:setEntity(item.entity)
			ship:setEntityModel(item.model)
			ship:setShipmentAmount(item.shipmentCount)
			ship:Spawn()
			ship:Activate()
		else
			local ent = ents.Create(item.entity)
			ent:SetPos(ply:GetEyeTrace().HitPos) --TODO: Change this to smth better, we don't want to do eye trace
			ent:Spawn()
			ent:Activate()
		end
	end
	--ply:addMoney(-item.price)
end

net.Receive("playerBuyItem", function(len, ply)
	fw.ents.buyItem(ply, net.ReadInt(32))
end)

fw.hook.Add("PlayerInitialSpawn", "LoadItems", function(ply)
	ndoc.table.items[ply] = ndoc.table.items[ply] or {}
	ndoc.table.items[ply].inventory = ndoc.table.items[ply].inventory or {}
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
