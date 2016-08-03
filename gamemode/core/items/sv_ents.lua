util.AddNetworkString("playerBuyItem")

ndoc.table.items = {}

fw.data.addPersistField('inventory')

local invItemID = 1

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

	ply.maxItems = ply.maxItems or {}
	if (ply.maxItems[item.entity] and item.max and item.max != 0 and ply.maxItems[item.entity] + 1 > item.max) then
		ply:FWChatPrintError("You already have the max of this entity!")
		return 
	end

	if (not slot) then 
		ply:FWChatPrintError("Your inventory is full, so you your item will be spawned instead!")
	elseif (item.storable) then
		local data = item.shipment and {itemIndex = item_index, invID = invItemID, remaining = item.shipmentCount} or {itemIndex = item_index, invID = invItemID}
		ndoc.table.items[ply].inventory.slots[slot] = data
	end

	ply.maxItems[item.entity] = ply.maxItems[item.entity] and ply.maxItems[item.entity] + 1 or 1
	
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
			ent:SetNWEntity("owner", ply)
		else
			local ent = ents.Create(item.entity)
			ent:SetPos(ply:GetEyeTrace().HitPos) --TODO: Change this to smth better, we don't want to do eye trace
			ent:Spawn()
			ent:Activate()
			ent.itemData = item
			ent.owner = ply
			ent:SetNWEntity("owner", ply)--turret compatability
		end

		return
	end

	invItemID = invItemID + 1
	ply:addMoney(-item.price)
end

fw.hook.Add("EntityRemoved", "AdjustItemCount", function(ent)
	local own = ent:GetNWEntity("owner") 
	local class = ent:GetClass()
	
	if (IsValid(own) and own.maxItems[class]) then
		own.maxItems[class] = own.maxItems[class] and own.maxItems[class] - 1 or nil
	end
end)

util.AddNetworkString("fw.openInventory")
util.AddNetworkString("fw.refreshInventory")
util.AddNetworkString("fw.dropItem")

net.Receive("fw.dropItem", function(_, ply)
	local itemIndex = net.ReadInt(32)
	local invID      = net.ReadInt(32)

	local inv = ndoc.table.items[ply].inventory
	local item = fw.ents.item_list[itemIndex]
	local name = "Name not found :("

	if (not item) then return end
	local canRemove, msg = fw.inv.canRemoveItem(ply, item)

	if (msg) then 
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), msg or "You can't do this!")
		return
	end

	local class = item.shipment and "fw_shipment" or item.entity
	local it, pos = fw.inv.getItemByInvID(ply, invID)

	local ent = ents.Create(class)
	--TODO: Change entity spawn pos
	ent:SetPos(ply:GetEyeTrace().HitPos)
	ent:Spawn()
	ent:Activate()
	ent:SetOwner(ply)
	ent.stringID = item.stringID
	if (item.shipment) then
		ent:setEntityModel(item.model)
		ent:setEntity(item.entity)
		ent:setShipmentAmount(ndoc.table.items[ply].inventory.slots[pos].remaining)
		ent:setName(name)
	end

	

	fw.inv.removeItem(ply, pos)
end)

--[[
	Inventory tree structure:
	ndoc.table
		Player
			Inventory
				Slots = {item data}
				slotCount = int available slots for the player
]]


function fw.inv.calcInvSpot(ply)
	local slotCount = ndoc.table.items[ply].inventory.slotCount or fw.config.defaultInvSlots
	local slots     = ndoc.table.items[ply].inventory.slots

	local count = 0
	for k,v in ndoc.pairs(ndoc.table.items[ply].inventory.slots) do
		count = count + 1
	end

	return (count != slotCount) and count + 1 or nil
end

--removes the value from the player's inv and shifts all other values up :D
function fw.inv.removeItem(ply, position)
	for k,v in ndoc.pairs(ndoc.table.items[ply].inventory.slots) do
		if (k == position) then
			ndoc.table.items[ply].inventory.slots[position] = nil --remove the value
		end
		if (k > position) then
			local new_index = k - 1
			local data = ndoc.table.items[ply].inventory.slots[k]
			local newData = data.remaining and {itemIndex = data.itemIndex, invID = data.invID, remaining = data.remaining} or {itemIndex = data.itemIndex, invID = data.invID} --reconstrct the table since we can't directly copy from netdoc

			ndoc.table.items[ply].inventory.slots[new_index] = newData --shift it up a value
			ndoc.table.items[ply].inventory.slots[k] = nil --remove the value
		end
	end
end

function fw.inv.addItem(ply, ent)
	if (not IsValid(ent)) then return end

	local item, index
	local isShipment = ent:GetClass() == "fw_shipment"
	for k,v in pairs(fw.ents.item_list) do
		if v.shipment and isShipment and (ent:GetEnt() == v.entity) then
			item = v
			index = k		
		elseif (v.entity == ent:GetClass() and not v.shipment) then
			item = v
			index = k
		end
	end

	if (not item) then
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), "This item can't be added to your inventory!")
		return
	end
	if (not item.storable) then
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), "This item can't be added to your inventory!")
		return
	end


	local slot = fw.inv.calcInvSpot(ply)
	if (not slot) then ply:FWChatPrintError("Your inventory is full!") return end

	local data = item.shipment and {itemIndex = index, invID = invItemID, remaining = ent:GetRemaining()} or {itemIndex = index, invID = invItemID}
	ndoc.table.items[ply].inventory.slots[slot] = data

	ent:Remove()

	invItemID = invItemID + 1

	net.Start("fw.refreshInventory")
	net.Send(ply)
end

local dis = 100
fw.hook.Add("KeyPress", "Pickup items", function(ply, key)
	if (key == IN_SPEED) then
		local tr = ply:GetEyeTrace()
		if (tr.Hit and tr.Entity and ply:EyePos():DistToSqr(tr.HitPos) <= dis * dis) then
			fw.inv.addItem(ply, tr.Entity)
		end
		
		ply.in_shift = false
	end
end)

fw.hook.Add("KeyRelease", "Pickup Items Release", function(ply, key)
	if (key == IN_SPEED) then
		ply.in_shift = false
	end
end)

fw.hook.Add("PlayerCanPickupWeapon", "StopAutoTouching", function(ply, key)
	if (ply:KeyDown(IN_USE)) then return true end

	return false
end)

net.Receive("playerBuyItem", function(len, ply)
	fw.ents.buyItem(ply, net.ReadInt(32))
end)

fw.hook.Add("PlayerInitialSpawn", "LoadItems", function(ply)
	ndoc.table.items[ply] = ndoc.table.items[ply] or {}
	ndoc.table.items[ply].inventory = ndoc.table.items[ply].inventory or {slots = {}, slotCount = fw.config.defaultInvSlots}
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