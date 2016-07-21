util.AddNetworkString("fw.openInventory")
util.AddNetworkString("fw.refreshInventory")
util.AddNetworkString("fw.dropItem")

net.Receive("fw.dropItem", function(_, ply)
	local itemIndex = net.ReadInt(32)
	local slot      = net.ReadInt(32)
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

	if (msg and not canRemove) then 
		ply:FWChatPrint(Color(0, 0, 0), "[Inventory]: ", Color(255, 255, 255), msg or "You can't do this!")
		return
	end

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
		ent:setShipmentAmount(shipCount)
		ent:setName(name)
	end

	ndoc.table.items[ply].inventory.slots[slot] = nil
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
	PrintTable(slots)
	for k,v in ndoc.pairs(slots) do
		if (not v) then
			return k
		end
		if (k == slotCount) then return false end --no open slots
	end

end

function fw.inv.addItem(ply, ent)
	if (not IsValid(ent)) then return end

	local item, name
	local isShipment = ent:GetClass() == "fw_shipment"
	for k,v in pairs(fw.ents.item_list) do
		if v.shipment and isShipment and (ent:GetEnt() == v.entity) then
			item = v
			name = k		
		elseif (v.entity == ent:GetClass() and not v.shipment) then
			item = v
			name = k
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

	ent:Remove()

	local slot = fw.inv.calcInvSpot(ply)
	if (not slot) then ply:FWChatPrintError("Your inventory is full!") return end

	item.slot = slot
	ndoc.table.items[ply].inventory[slot] = item

	net.Start("fw.refreshInventory")
	net.Send(ply)
end

fw.chat.addCMD("inv", "Opens your inventory", function(ply)
	net.Start("fw.openInventory")
	net.Send(ply)
end)

local dis = 7177.9691469085
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