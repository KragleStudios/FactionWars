

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
		v[1] = math.floor(v[1])
		v[2] = math.floor(v[2])
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

-- renders a zone
function zone_mt:render()
	local polygon = self.polygon 

	local edges = {}
	local last = polygon[#polygon]
	local inset = 5
	for i = 1, #polygon do
		local cur = polygon[i]
		local N = (last - cur):normalize()
		N = ra.geom.point(-N[2], N[1])

		-- todo: apply intersection algorithms
		table.insert(edges, ra.geom.edge(last + N * inset, cur + N * inset))

		last = cur
	end

	local e1 = edges[#edges - 1]
	local e2 = edges[#edges]
	local e3 = edges[1]

	for i = 2, #edges + 1 do

		local didIntersect, x, y = e1:intersectWith(e2, true) -- true indicates it should ignore the length
		if didIntersect then 
			e1[2][1] = x
			e1[2][2] = y
			e2[1][1] = x
			e2[1][2] = y
		end

		local didIntersect, x, y = e2:intersectWith(e3, true) -- true indicates that it should ignore the length
		if didIntersect then 
			e2[2][1] = x
			e2[2][2] = y
			e3[1][1] = x
			e3[1][2] = y
		end

		e1 = e2
		e2 = e3 
		e3 = edges[i]
	end

	local z = LocalPlayer():GetPos().z 
	for k, edge in ipairs(edges) do
		render.DrawLine(Vector(edge[1][1], edge[1][2], z), Vector(edge[2][1], edge[2][2], z), Color(0, 0, 255))
	end

	--[[

	local p1 = polygon[#polygon - 1]
	local p2 = polygon[#polygon]
	local p3 = polygon[1]

	for i = 2, #polygon + 1 do
		local u = (p1 - p2):normalize()
		local v = (p3 - p2):normalize()
		local d = (u + v):normalize()
		if i == 3 then
			render.DrawLine(Vector(0, 0, 0), Vector(u[1], u[2], 0) * 100, Color(0, 255, 0))
			render.DrawLine(Vector(0, 0, 0), Vector(v[1], v[2], 0) * 100, Color(0, 0, 255))
			render.DrawLine(Vector(0, 0, 0), Vector(d[1], d[2], 0) * 100, Color(255, 0, 255))
		end
		
		local N = d:normalize()

		-- 	N = ra.geom.point(-u[2], u[1]):normalize() -- (-uy/|u|, ux/|u|)

		table.insert(points, {
			p = p2,
			N = N
		})

		p1 = p2
		p2 = p3
		p3 = polygon[i]
	end 

	local c = Color(255, 0, 0)
	local z = LocalPlayer():GetPos().z
	local w = 10 -- line weight

	local last = points[#points]
	for i = 1, #points do
		local cur = points[i]

		local p1 = Vector(last.p[1] + last.N[1] * w, last.p[2] + last.N[2] * w, z)
		local p2 = Vector(cur.p[1] + cur.N[1] * w, cur.p[2] + cur.N[2] * w, z)

		render.DrawLine(p1, p2, c)
		last = cur 
	end	

	render.SetColorMaterial()
	pcall(mesh.Begin, MATERIAL_QUADS, #points)
		local last = points[#points]
		for i = 1, #points do
			local cur = points[i]

			mesh.Position(Vector(last.p[1], last.p[2], z))
			mesh.Color(255, 0, 0, 255)
			mesh.AdvanceVertex()

			mesh.Position(Vector(cur.p[1], cur.p[2], z))
			mesh.Color(255, 0, 0, 255)
			mesh.AdvanceVertex()

			mesh.Position(Vector(cur.p[1] + cur.N[1] * w, cur.p[2] + cur.N[2], z))
			mesh.Color(255, 0, 0, 255)
			mesh.AdvanceVertex()

			mesh.Position(Vector(last.p[1] + last.N[1] * w, last.p[2] + last.N[2], z))
			mesh.Color(255, 0, 0, 255)
			mesh.AdvanceVertex()

			last = cur 
		end	
	mesh.End()

	PrintTable(points)
	]]
end

function fw.zone.new()
	return setmetatable({}, zone_mt)
end

-- get a new unused zone id
function fw.zone.getUnusedZoneId()
	local zoneId = nil
	
	repeat 
		zoneId = math.random(1, 99999999)
	until not fw.zone.zoneList[zoneId]

	return zoneId
end	

--
-- SAVE /LOAD ZONE FROM FILE
--

local zoneFileCRC32 = nil 

function fw.zone.getSaveFileName()
	return fw.zone.zoneDataDir .. game.GetMap() .. '.dat' -- since it's binary
end

function fw.zone.createZonesBackup()
	local backupName = fw.zone.zoneDataDir .. game.GetMap() .. ' - ' .. os.date( "%d-%m-%Y - %H-%M-%S - ", os.time()) .. '.dat'
	file.Write(backupName, file.Read(fw.zone.getSaveFileName(), 'DATA'))
end

function fw.zone.saveZonesToFile(filename)
	zoneFileCRC32 = nil 
	if not filename then
		filename = fw.zone.getSaveFileName()
	end 

	local f = file.Open(filename, 'wb', 'DATA')

	f:WriteShort(table.Count(fw.zone.zoneList))
	for k,v in pairs(fw.zone.zoneList) do
		v:writeToFile(f)
	end

	f:Close()
end

function fw.zone.loadZonesFromFile(filename)
	zoneFileCRC32 = nil 
	if not filename then
		filename = zone.getSaveFileName()
	end

	local f = file.Open(filename, 'rb', 'DATA')
	for i = 1, file:ReadShort() do
		local zone = fw.zone.new()
		zone:readFromFile(f)
		fw.zone.zoneList[zone.id] = zone
	end
end

function fw.zone.getZoneFileCRC()
	if zoneFileCRC32 then
		return zoneFileCRC32
	end
	zoneFileCRC32 = util.CRC(file.Read(fw.zone.getSaveFileName(), 'DATA') or '')
	return zoneFileCRC32
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


