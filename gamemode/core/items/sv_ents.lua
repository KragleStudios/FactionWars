util.AddNetworkString("playerBuyItem")

ndoc.table.items = {}

function fw.ents.buyItem(ply, item_index)
	local canjoin = hook.Call("CanPlayerBuyItem", GAMEMODE, ply, item_index)

	if (not canjoin) then return end

	local item = fw.ents.item_list[item_index]
	local list = ndoc.table.items[ply].inventory[item.stringID]

	if (list) then
		ndoc.table.items[ply].inventory[item.stringID] = list + 1
	else
		ndoc.table.items[ply].inventory[item.stringID] = 1
	end
end

net.Receive("playerBuyItem", function(len, ply)
	fw.ents.buyItem(ply, net.ReadInt(32))
end)

fw.hook.Add("PlayerInitialSpawn", "LoadItems", function(ply)
	ndoc.table.items[ply] = ndoc.table.items[ply] or {}
	ndoc.table.items[ply].inventory = ndoc.table.items[ply].inventory or {}
end)

fw.hook.Add("PlayerDisconnected", "RemoveSpareItems", function(ply)
	local play = ply --grab a copy to remove stuff
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
			if (v.owner and (v.owner == play) and (v.stringID and fw.ents.item_list[v.stringID].removeOnDisc)) then
				v:Remove()
			end 
		end
	end)
end)
