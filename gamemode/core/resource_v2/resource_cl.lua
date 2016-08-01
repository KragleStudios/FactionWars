local net_ReadUInt = net.ReadUInt

net.Receive('fw.resource.getInfo', function()
  local typeById = fw.resource.typeById

	local ent = net.ReadEntity()
	if not ent.fwResources or not ent.fwNetwork then return end

	-- read confusing binary data from server!
	local function helpReadStatistics()
    local table = {}
    while true do
      local id = net_ReadUInt(8)
      if id == 0 then break end
      local amount = net_ReadUInt(24)
      local type = typeById[id]
      if type then
        table[type.type] = amount
      end
    end
    return table
  end

	-- write the statistics tables!
  ent.fwNetwork = {}
  ent.fwNetwork.entCount = net_ReadUInt(12)

  ent.fwNetwork.totalProduction = helpReadStatistics()
  ent.fwNetwork.totalConsumption = helpReadStatistics()
  ent.fwNetwork.totalStorage = helpReadStatistics()
  ent.fwConsumption = helpReadStatistics()
  ent.fwResources = helpReadStatistics()

  fw.print("received resource information from server")
  PrintTable(ent.fwNetwork)
  PrintTable(ent.fwResources)
end)


function fw.resource.fetchEntityStatsFromServer(ent)
  net.Start('fw.resource.getInfo')
    net.WriteEntity(ent)
  net.SendToServer()
end

concommand.Add('fw_resource_fetchStats', function()
  local tr = LocalPlayer():GetEyeTrace()
  if IsValid(tr.Entity) then
    net.Start('fw.resource.getInfo')
      net.WriteEntity(tr.Entity)
    net.SendToServer()
  end
end, nil, "fetches resource info from the server and prints it to console as a table for debugging")
