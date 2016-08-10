util.AddNetworkString("playerBuyItem")

ndoc.table.items = {}

function fw.ents.buyItem(ply, item_index)
	local canjoin, msg = fw.ents.canPlayerBuyItem(ply, item_index)

	if (msg) then
		ply:FWChatPrintError(msg)
		return
	end
		
	local item = fw.ents.item_list[item_index]

	ply.maxItems = ply.maxItems or {}
	if (ply.maxItems[item.entity] and item.max and item.max != 0 and ply.maxItems[item.entity] + 1 > item.max) then
		ply:FWChatPrintError("You already have the max of this entity!")
		return
	end

	ply.maxItems[item.entity] = ply.maxItems[item.entity] and ply.maxItems[item.entity] + 1 or 1

	local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace).HitPos

	if (item.shipment) then
		local ship = ents.Create("fw_shipment")
		ship:SetPos(tr)
		ship:setEntity(item.entity)
		ship:setEntityModel(item.model[1])
		ship:setShipmentAmount(item.shipmentCount)
		ship:Spawn()
		ship:Activate()
		ship.itemData = item
		ship.owner = ply
		ship:SetNWEntity("owner", ply)
	else
		local ent = ents.Create(item.entity)
		ent:SetPos(tr)
		ent:Spawn()
		ent:Activate()
		ent.itemData = item
		ent.owner = ply
		ent:SetNWEntity("owner", ply)

		--respawn point compatability
		if (item.entity == "fw_respawn_point") then
			ply:SetNWEntity("spawn_point", ent)
		end
	end

	ply:addMoney(-item.price)
end

fw.hook.Add("EntityRemoved", "AdjustItemCount", function(ent)
	local own = ent:GetNWEntity("owner")
	local class = ent:GetClass()

	if (IsValid(own) and own.maxItems[class]) then
		own.maxItems[class] = own.maxItems[class] and own.maxItems[class] - 1 or nil
	end
end)