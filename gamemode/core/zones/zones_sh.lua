local math = math
local net = net
local mesh = mesh
local ra = ra

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
fw.zone._zone_mt = zone_mt

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

	self.center = ra.geom.point(0, 0)

	for k,v in ipairs(self.polygon) do
		self.center[1] = self.center[1] + v[1]
		self.center[2] = self.center[2] + v[2]
		if v[1] > self.maxX then self.maxX = v[1] end
		if v[1] < self.minX then self.minX = v[1] end
		if v[2] > self.maxY then self.maxY = v[2] end
		if v[2] < self.minY then self.minY = v[2] end
	end

	-- compute center and radius
	self.center[1] = self.center[1] / #self.polygon
	self.center[2] = self.center[2] / #self.polygon
	self.radius = math.sqrt((self.maxX - self.minX) * (self.maxX - self.minX) + (self.maxY - self.minY) * (self.maxY - self.minY))

	-- track the players in the zone
	self.players = {}

	if (SERVER) then
		fw.zone.setupCaptureNetworking(self)
	end

	return self
end

function zone_mt:hasRadar()
	for k,v in pairs(ents.FindByClass("fw_radar")) do
		if (self:isPointInZone(v:GetPos())) then
			return true, v
		end
	end

	return false
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
	file:WriteLong(self.id)
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
	local id = file:ReadLong()
	local name = file:Read(file:ReadByte())

	local polygon = {}
	for i = 1, file:ReadShort() do
		table.insert(polygon, ra.geom.point(file:ReadLong(), file:ReadLong()))
	end

	self:ctor(id, name, polygon)
end

-- geometric algorithms
function zone_mt:getPointsInsetByAmount(inset)
	local polygon = self.polygon

	local edges = {}
	local last = polygon[#polygon]
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

	local result = {}
	for k,edge in ipairs(edges) do
		table.insert(result, edge[2])
	end

	return result
end

--
-- RENDERING ALGORITHMS
--
function zone_mt:constructRenderer(color_outline, color_fill, border_thickness)
	if self._rendermesh_outline then
		self._rendermesh_outline:Destroy()
		self._rendermesh_outline = nil
	end
	if self._rendermesh_fill then
		self._rendermesh_fill:Destroy()
		self._rendermesh_fill = nil
	end

	if not color_outline then
		color_outline = Color(255, 255, 255, 55)
	end
	if not color_fill then
		color_fill = Color(0, 0, 0, 0)
	end

	-- compute inset polygon
	self.polygon_inner = self:getPointsInsetByAmount(border_thickness or fw.config.zoneBorderThickness)

	-- build the outline mesh
	local m_outline = Mesh()

	local last_outer = self.polygon[#self.polygon]
	local last_inner = self.polygon_inner[#self.polygon]

	mesh.Begin(m_outline, MATERIAL_QUADS, #self.polygon)

	for i = 1, #self.polygon do
		local outer = self.polygon[i]
		local inner = self.polygon_inner[i]

		mesh.Position(Vector(last_outer[1], last_outer[2], 0))
		mesh.Color(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
		mesh.AdvanceVertex()

		mesh.Position(Vector(outer[1], outer[2], 0))
		mesh.Color(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
		mesh.AdvanceVertex()

		mesh.Position(Vector(inner[1], inner[2], 0))
		mesh.Color(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
		mesh.AdvanceVertex()

		mesh.Position(Vector(last_inner[1], last_inner[2], 0))
		mesh.Color(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
		mesh.AdvanceVertex()

		last_outer = outer
		last_inner = inner
	end

	mesh.End()

	self._meshcolor_outline = color_outline
	self._rendermesh_outline = m

	-- build the fill mesh
	local m_fill = Mesh()
	mesh.Begin(m_fill, MATERIAL_TRIANGLES, #self.triangles)

	for k, triangle in ipairs(self.triangles) do
		mesh.Position(Vector(triangle.p3[1], triangle.p3[2], 0))
		mesh.Color(color_fill.r, color_fill.g, color_fill.b, color_fill.a)
		mesh.AdvanceVertex()

		mesh.Position(Vector(triangle.p2[1], triangle.p2[2], 0))
		mesh.Color(color_fill.r, color_fill.g, color_fill.b, color_fill.a)
		mesh.AdvanceVertex()

		mesh.Position(Vector(triangle.p1[1], triangle.p1[2], 0))
		mesh.Color(color_fill.r, color_fill.g, color_fill.b, color_fill.a)
		mesh.AdvanceVertex()
	end

	mesh.End()

	return {
		draw = function()
			render.SetColorMaterial()
			render.CullMode(MATERIAL_CULLMODE_CW)
			m_outline:Draw()
			m_fill:Draw()
			render.CullMode(MATERIAL_CULLMODE_CCW)
			m_outline:Draw()
			m_fill:Draw()
		end,
		fillColor = color_fill,
		outlineColor = color_outline,
		destroy = function(self)
			self.destroy = ra.fn.noop
			self.draw = ra.fn.noop
			m_fill:Destroy()
			m_outline:Destroy()
		end
	}
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
local filename = fw.zone.zoneDataDir .. game.GetMap() .. '.dat'

function fw.zone.getSaveFileName()
	return filename
end

function fw.zone.createZonesBackup()
	local backupName = fw.zone.zoneDataDir .. game.GetMap() .. ' - ' .. os.date( "%d-%m-%Y - %H-%M-%S - ", os.time()) .. '.dat'
	file.Write(backupName, file.Read(fw.zone.getSaveFileName(), 'DATA'))
end

function fw.zone.saveZonesToFile()
	local filename = fw.zone.getSaveFileName()
	zoneFileCRC32 = nil

	local f = file.Open(filename, 'wb', 'DATA')
	f:WriteShort(table.Count(fw.zone.zoneList))
	for k,v in pairs(fw.zone.zoneList) do
		v:writeToFile(f)
	end
	f:Close()
end

function fw.zone.loadZonesFromDisk()
	local filename = fw.zone.getSaveFileName()
	zoneFileCRC32 = nil

	local f = file.Open(filename, 'rb', 'DATA')
	for i = 1, f:ReadShort() do
		local zone = fw.zone.new()
		zone:readFromFile(f)
		fw.zone.zoneList[zone.id] = zone
	end
	f:Close()
end

function fw.zone.getZoneFileCRC()
	if zoneFileCRC32 then
		return zoneFileCRC32
	end
	local fname = fw.zone.getSaveFileName()
	if not file.Exists(fname, 'DATA') then return 0 end
	zoneFileCRC32 = util.CRC(file.Read(fname, 'DATA') or '')
	return zoneFileCRC32
end

-- get the zone the player is inside
function fw.zone.playerGetZone(ply)
	local pos = ply:GetPos()
	local x, y = pos.x, pos.y

	for k, zone in pairs(fw.zone.zoneList) do
		if zone:isPointInZone(x, y) then
			return zone
		end
	end

	return nil
end

-- keep players in zones up to date
timer.Create('fw.zone.updatePlayers', 1, 0, function()
	for k, pl in pairs(player.GetAll()) do
		local inZone = fw.zone.playerGetZone(pl)
		if inZone ~= pl._fw_zone then
			local oldZone = pl._fw_zone

			if oldZone then
				for k,v in ipairs(oldZone.players) do
					if v == pl then
						table.remove(oldZone.players, k)
						break
					end
				end
			end
			if inZone then
				if not table.HasValue(inZone.players, pl) then
					table.insert(inZone.players, pl)
				end
			end

			pl._fw_zone = inZone

			hook.Call('PlayerEnteredZone', GAMEMODE, inZone, oldZone, pl)
		end
	end
end)

local Player = FindMetaTable('Player')
function Player:getZoneInside()
	return self._fw_zone
end
