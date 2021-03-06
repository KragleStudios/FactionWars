ndoc.table.fwPP = ndoc.table.fwPP or {}

--[[
	Docs: 
	0 - everyone can use
	1 - only the player can use
	2 - anyone in the faction can use
]]
util.AddNetworkString("fw.whoCanPhysgun")
util.AddNetworkString("fw.whoCanTool")

util.AddNetworkString("fw.addPlayerToWhitelist")
util.AddNetworkString("fw.removePlayerFromWhitelist")

net.Receive("fw.whoCanPhysgun", function(l, ply)
	local status = net.ReadUInt(8)

	ndoc.table.fwPP[ply].whoCanPhysgun = status
end)

net.Receive("fw.whoCanTool", function(l, ply)
	local status = net.ReadUInt(8)

	ndoc.table.fwPP[ply].whoCanTool = status
end)

net.Receive("fw.addPlayerToWhitelist", function(l, ply)
	local target = net.ReadEntity()

	ndoc.table.fwPP[ply].whitelist[target] = true
end)

net.Receive("fw.removePlayerFromWhitelist", function(l, ply)
	local target = net.ReadEntity()

	ndoc.table.fwPP[ply].whitelist[target] = nil
end)

fw.hook.Add("PlayerInitialSpawn", "SetupNDOCTables", function(ply)
	ndoc.table.fwPP[ply] = {
		whoCanPhysgun = 1,
		whoCanTool    = 1,
		whitelist = {}
	}
end)

fw.hook.Add("PlayerSpawnedProp", "SetOwner", function(ply, _, ent)
	ent:FWSetOwner(ply)
end)