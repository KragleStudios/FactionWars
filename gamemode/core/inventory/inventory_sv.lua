util.AddNetworkString("fw.openInventory")
util.AddNetworkString("fw.refreshInventory")
util.AddNetworkString("fw.dropItem")

net.Receive("fw.dropItem", function(_, ply)
	local itemStringID = net.ReadString()
	local inv = ndoc.table.items[ply].inventory
	local item = nil
	local name = "Name not found :("

	for k,v in pairs(fw.ents.item_list) do
		if (v.stringID == itemStringID) then
			item = v
			name = k
		end
	end

	if (not item) then return end
	local canRemove, msg = hook.Call("CanRemoveFromInventory", GAMEMODE, ply, item)

	if (not canRemove) then 
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), msg or "You can't do this!")
		return
	end
	local class = item.entity
	local shipCount = 0
	if (item.shipment) then
		class = "fw_shipment"
		shipCount = inv[item.stringID].remaining or item.shipmentCount
	end

	local ent = ents.Create(class)
	ent:SetPos(ply:GetPos() + Vector(20, 20, 20))
	ent:Spawn()
	ent:Activate()
	ent.owner = ply
	ent.stringID = item.stringID
	if (item.shipment) then
		ent:setEntityModel(item.model)
		ent:setEntity(item.entity)
		ent:setShipmentAmount(shipCount)
		ent:setName(name)
	end

	local count = ndoc.table.items[ply].inventory[item.stringID].count
	ndoc.table.items[ply].inventory[item.stringID].count = count - 1
	if (count == 0) then
		ndoc.table.items[ply].inventory[item.stringID].count = nil
	end

	net.Start("fw.refreshInventory")
	net.Send(ply)
end)

function fw.inv.addItem(ply, entity)
	if (not IsValid(entity)) then return end

	if (not ent.owner or not ent.stringID) then
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), "This item can't be added to your inventory!")
		return
	end
	local item = nil

	for k,v in pairs(fw.ents.item_list) do
		if (v.stringID == itemStringID) then
			item = v
		end
	end

	if (not item.storable) then
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), "This item can't be added to your inventory!")
		return
	end

	ent:Remove()
	ndoc.table.items[ply].inventory[item.stringID].count = count + 1
	if (item.shipment) then
		ndoc.table.items[ply].inventory[item.stringID].remaining = entity:getRemaining()
	end

	net.Start("fw.refreshInventory")
	net.Send(ply)
end

fw.chat.addCMD("inv", "Opens your inventory", function(ply)
	net.Start("fw.openInventory")
	net.Send(ply)
end)