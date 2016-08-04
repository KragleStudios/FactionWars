local net_ReadUInt = net.ReadUInt

net.Receive('fw.resource.syncInfo', function()
	fw.print("received resource info from the server")

	local typeById = fw.resource.typeById

	local ent = net.ReadEntity()

	-- read confusing binary data from server!
	local function helpReadStatistics(precision)
		local table = {}
		while true do
			local id = net_ReadUInt(8)
			if id == 0 then break end
			local amount = net_ReadUInt(precision)
			local type = typeById[id]
			if type then
				table[type.type] = amount
			end
		end
		PrintTable(table)
		return table
	end

	-- write the statistics tables!
	ent.fwNetwork = {
		entCount = net_ReadUInt(16),
		totalProduction = helpReadStatistics(12),
		totalConsumption = helpReadStatistics(12),
		totalStorage = helpReadStatistics(12)
	}

	print("PRODUCES")
	ent.Produces = helpReadStatistics(12)
	print "CONSUMES"
	ent.Consumes = helpReadStatistics(12)
	ent.Storage = helpReadStatistics(12)
	ent.fwProductionUse = helpReadStatistics(12)
	ent.fwResourcesStatic = helpReadStatistics(12)
	ent.fwResources = helpReadStatistics(12)

	fw.hook.Call('UpdatedEntityResourceData', ent)
end)


function fw.resource.fetchEntityStatsFromServer(ent)
	net.Start('fw.resource.syncInfo')
		net.WriteEntity(ent)
	net.SendToServer()
end

concommand.Add('fw_resource_fetchStats', function()
	local tr = LocalPlayer():GetEyeTrace()
	if IsValid(tr.Entity) then
		net.Start('fw.resource.syncInfo')
			net.WriteEntity(tr.Entity)
		net.SendToServer()
	end
end, nil, "fetches resource info from the server and prints it to console as a table for debugging")
