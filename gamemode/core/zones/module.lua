if SERVER then
	AddCSLuaFile()
end

fw.zone = {}

-- external dependencies
require "ra"

-- require modules
fw.dep(SHARED, "data")
fw.dep(SHARED, "teams")
fw.dep(CLIENT, "fonts")

-- define constants
fw.zone.zoneDataDir = fw.config.dataDir .. (SERVER and "/zones_sv/" or "/zones_cl/")
file.CreateDir(fw.zone.zoneDataDir)

-- include files
fw.include_sv "zones_sv.lua"
fw.include_sh "zones_sh.lua"
fw.include_cl "zones_cl.lua"
fw.include_sh "zone_capture_sh.lua"
fw.include_sv "zone_capture_sv.lua"
fw.include_cl "minimap_cl.lua"

--
-- ZONE SYNC LOGIC
--
if SERVER then
	util.AddNetworkString("fw.zone.CRC")
	util.AddNetworkString("fw.zone.fetch")
	net.Receive("fw.zone.CRC", function(_ ,pl)
		if not file.Exists(fw.zone.getSaveFileName(), "DATA") then return end -- just don't respond
		fw.print("sending back the zone file crc")
		net.Start("fw.zone.CRC")
		net.WriteString(fw.zone.getZoneFileCRC())
		net.Send(pl)
	end)

	local limiter = {}
	net.Receive("fw.zone.fetch", function(_, pl)
		if limiter[pl] then return end
		local data = file.Read(fw.zone.getSaveFileName(), "DATA")
		if not data then return end
		fw.print("sending back zone data stream")
		net.Start("fw.zone.fetch")
		ra.net.WriteStream(data, pl, function()
			limiter[pl] = nil
		end)
		net.Send(pl)
	end)
else
	ra.net.WaitForPlayer(function()
		net.Start("fw.zone.CRC")
		net.SendToServer()
	end)

	net.Receive("fw.zone.CRC", function()
		local serverCRC = net.ReadString()
		local clientCRC = fw.zone.getZoneFileCRC()
		fw.print("zone crc check: ",serverCRC,clientCRC)
		if serverCRC ~= clientCRC then
			net.Start("fw.zone.fetch")
			net.SendToServer()
		else
			fw.zone.loadZonesFromDisk()
		end
	end)

	net.Receive("fw.zone.fetch", function()
		fw.print("receiving zone data from server")
		ra.net.ReadStream(function(data)
			fw.print("READ A BUNCH OF DATA FROM THE SERVER! ", string.len(data))
			file.Write(fw.zone.getSaveFileName(), data)
			fw.zone.loadZonesFromDisk()
		end)
	end)

	concommand.Add("fw_zone_recheckLocalCache", function()
		net.Start("fw.zone.CRC")
		net.SendToServer()
	end)
end

if SERVER then
	--
	-- LAST THING WE DO IS LOAD ZONES FROM DISK
	--
	if file.Exists(fw.zone.getSaveFileName(), "DATA") then
		fw.zone.loadZonesFromDisk()
	end
end
