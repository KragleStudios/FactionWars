util.AddNetworkString("playerBuyItem")


function fw.ents.buyItem(ply, item_index)
	local canjoin = hook.Call("CanPlayerBuyItem", GAMEMODE, ply, item_index)

	if (not canjoin) then return end

	local item = fw.ents.item_list[item_index]

	local ent = ents.Create(item.entity)
	if (not IsValid(ent)) then return end

	ent:SetPos(ply:GetPos() + Vector(10, 0, 20))
	ent:Spawn()
	ent.owner = ply

	ply.owned_items = ply.owned_items or {}

	table.insert(ply.owned_items, ent)
end

net.Receive("playerBuyItem", function(len, ply)
	fw.ents.buyItem(ply, net.ReadInt(32))
end)

fw.hook.Add("OnEntityCreated", "", function(ent)
	if (ent.owner and IsValid(ent.owner)) then
		local ply = ent.owner
		ply.cur_items[item_index] = Entity(ply).cur_items[item_index] or 0
		ply.cur_items[item_index] = Entity(ply).cur_items[item_index] + 1
	end
end)

fw.hook.Add("PlayerDisconnected", "RemoveSpareItems", function(ply)
	local id = ply:SteamID()
	local cur_items = ply.cur_items or {}
	local owned_items = ply.owned_items or {}

	--if the player rejoined cancel removing their things and reset to before they left
	timer.Simple(120, function()
		for k,v in pairs(player.GetAll()) do
			if (v:SteamID() == id) then
				v.cur_items = cur_items
				v.owned_items = owned_items

				return
			end
		end

		if (ply.owned_items) then
			for k,v in pairs(ply.owned_items) do
				if (v.removeOnDisc) then
					v:Remove()
				end
			end
		end
	end)
end)