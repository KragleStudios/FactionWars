

local math = math 
local net = net 


fw.zone.zoneList = {}
fw.zone.points = ra.ds.newRBTree()

-- 
-- POINTS SYSTEM
-- 
function fw.zone.registerPoint(p)
	fw.zone.points:insert(p)
	return p
end

function fw.zone.getPoint(p)
	return fw.zone.points:find(p) or fw.zone.registerPoint(p)
end 


--
-- CREATE ZONE META OBJECT
-- 
local zone_mt = {}
zone_mt.__index = zone_mt

function zone_mt:ctor(id, name, polygon)
	self.maxX = -math.huge 
	self.minX = math.huge 
	self.maxY = -math.huge
	self.minY = math.huge 

	self.id = id
	self.name = name or 'unnamed'

	-- convert it to points in the red black tree for nice snapping to grid :)
	self.polygon = {}
	for k,v in ipairs(polygon) do
		v.x = math.floor(v[1])
		v.y = math.floor(v[2])
		self.polygon[k] = fw.zone.getPoint(v)
	end

	-- triangulate the polygon and compute the bounds
	self.triangles = ra.geom.triangulatePolygon(unpack(self.polygon))
	for k,v in ipairs(self.polygon) do
		if v[1] > self.maxX then self.maxX = v[1] end
		if v[1] < self.minX then self.minX = v[1] end 
		if v[2] > self.maxY then self.maxY = v[2] end
		if v[2] < self.minY then self.minY = v[2] end
	end

	return self
end

if SERVER then
	function zone_mt:send()
		net.WriteUInt(self.id, 16)
		net.WriteString(self.name)
		net.WriteUInt(#self.polygon, 12)

		for k,v in ipairs(self.polygon) do
			net.WriteInt(v[1], 32)
			net.WriteInt(v[2], 32)
		end

		return self 
	end
else
	function zone_mt:receive()
		local id = net.ReadUInt(16)
		local name = net.ReadString(self.name)
		local polygon = {}

		for i = 1, net.ReadUInt(12) do
			table.insert(polygon, ra.geom.point(net.ReadInt(32), net.ReadInt(32)))
		end

		self:ctor(id, name, polygon)

		return self 
	end
end

function zone_mt:isPointInZone(x, y)
	if x >= self.maxX or x < self.minX or y >= self.maxY or y < self.minY then return false end
	
	for k,v in ipairs(self.triangles) do
		if v:isPointInside(x, y) then return true end 
	end

	return false 
end

-- writes a zone to a file
function zone_mt:writeToFile(file)
	file:WriteShort(self.id)
	file:WriteByte(#self.name)
	file:Write(self.name)
	file:WriteShort(#self.polygon)
	for k,v in ipairs(self.polygon) do
		file:WriteLong(v[1])
		file:WriteLong(v[2])
	end
end

-- reads a zone from a file
function zone_mt:readFromFile(file)
	local id = file:ReadShort()
	local name = file:Read(file:ReadByte())

	local polygon = {}
	for i = 1, file:ReadShort() do
		table.insert(polygon, ra.geom.point(file:ReadLong(), file:ReadLong()))
	end

	self:ctor(id, name, polygon)
end

function fw.zone.new()
	return setmetatable({}, zone_mt)
end

--
-- SAVE /LOAD ZONE FROM FILE
--

function fw.zone.getSaveFileName()
	return fw.zone.zoneDataDir .. game.GetMap() .. '.dat' -- since it's binary
end

function fw.zone.createZonesBackup()
	local backupName = fw.zone.zoneDataDir .. game.GetMap() .. ' - ' .. os.date( "%d-%m-%Y - %H-%M-%S - ", os.time()) .. '.dat'
	file.Write(backupName, file.Read(fw.zone.getSaveFileName(), 'DATA'))
end

function fw.zone.saveZonesToFile(filename)
	local f = file.Open(filename, 'DATA', 'wb')

	f:WriteShort(table.Count(fw.zone.list))
	for k,v in pairs(fw.zone.list) do
		v:writeToFile(f)
	end

	f:Close()
end

function fw.zone.loadZonesFromFile(filename)
	local f = file.Open(filename, 'DATA', 'rb')
	for i = 1, file:ReadShort() do
		local zone = fw.zone.new()
		zone:readFromFile(f)
		fw.zone.zoneList[zone.id] = zone
	end
end

-- get the zone the player is inside
function fw.zone.playerGetZoneInside(ply)
	local pos = ply:GetPos()
	local x, y = pos.x, pos.y

	for k, zone in pairs(fw.zone.zoneList) do
		if zone:isPointInside(x, y) then
			return zone
		end
	end

	return nil
end


