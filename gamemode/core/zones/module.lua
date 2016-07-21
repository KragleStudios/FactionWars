fw.zone = {}


require 'ra'

local math = math 
local net = net 


fw.zone.list = {}

--
-- CREATE TRIANGLE META OBJECT
--

local triangle_mt = {}
function triangle_mt:ctor(x1, y1, x2, y2, x3, y3)
	
	self.x1, self.y1 = x1, y1
	self.x2, self.y2 = x2, y2
	self.x3, self.y3 = x3, y3

	-- compute the transformation to the unit triangle
	local a1, b1 = x2 - x1, x3 - x1
	local c1, d1 = y2 - y1, y3 - y1
	local det = a1 * d1 - b1 * c1 
	local a, b = d1/det, -b1/det
	local c, d = -c1/det, a1/det

	self.isPointInside = function(self, x, y)
		x = x - x1 
		y = y - y1

		x = a * x + b * y 
		y = c * x + d * y

		return x >= 0 and y >= 0 and x + y < 1 
	end
end

function triangle_mt:isPointInside(x, y)
	return false 
end

triangle_mt.__index = triangle_mt

local function createTriangle(x1, y1, x2, y2, x3, y3)
	local obj = setmetatable({}, triangle_mt)
	obj:ctor(x1, y1, x2, y2, x3, y3)
	return obj 
end

--
-- CREATE ZONE META OBJECT
-- 
local zone_mt = {}
function zone_mt:ctor()
	self.name = 'unknown'
	self.triangles = {}
	self.maxX = -math.huge 
	self.maxY = -math.huge 
	self.minX = math.huge 
	self.minY = math.huge
end

if SERVER then
	function zone_mt:send()
		net.WriteUInt(self.id, 16)
		net.WriteString(self.name)
		net.WriteUInt(#self.triangles, 12)
		for k,v in ipairs(self.triangles) do
			net.WriteInt(v.x1, 32)
			net.WriteInt(v.y1, 32)
			net.WriteInt(v.x2, 32)
			net.WriteInt(v.y2, 32)
			net.WriteInt(v.x3, 32)
			net.WriteInt(v.y3, 32)
		end
	end
else
	function zone_mt:receive()
		self.id = net.ReadUInt(16)
		self.name = net.ReadString()
		for i = 1, net.ReadUInt(12) do
			self:addTriangle(
					net.ReadInt(32),
					net.ReadInt(32),
					net.ReadInt(32),
					net.ReadInt(32),
					net.ReadInt(32),
					net.ReadInt(32)
				)
		end
	end
end

function zone_mt:addTriangle(x1, y1, x2, y2, x3, y3)
	x1, y1, x2, y2, x3, y3 = math.Round(x1), math.Round(y1), math.Round(x2), math.Round(y2), math.Round(x3), math.Round(y3)

	table.insert(self.triangles, createTriangle(x1, y1, x2, y2, x3, y3))

	self.maxX = math.max(self.maxX, math.max(x1, math.max(x2, x3)))
	self.maxY = math.max(self.maxY, math.max(y1, math.max(y2, y3)))

	self.minX = math.min(self.minX, math.min(x1, math.min(x2, x3)))
	self.minX = math.min(self.minX, math.min(y1, math.min(y2, y3)))
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
	file:WriteShort(#self.triangles)
	for k,v in ipairs(self.triangles) do
		file:WriteLong(v.x1)
		file:WriteLong(v.y1)
		file:WriteLong(v.x2)
		file:WriteLong(v.y2)
		file:WriteLong(v.x3)
		file:WriteLong(v.y3)
	end
end

-- reads a zone from a file
function zone_mt:readFromFile(file)
	self.id = file:ReadShort()
	self.name = file:Read(file:ReadByte())
	for i = 1, file:ReadShort() do
		self:addTriangle(
				file:ReadLong(),
				file:ReadLong(),
				file:ReadLong(),
				file:ReadLong(),
				file:ReadLong(),
				file:ReadLong()
			)
	end
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
	-- TODO zone loading from file
end








-- get the zone the player is inside
function fw.zone.playerGetZoneInside(ply)
	local pos = ply:GetPos()
	local x, y = pos.x, pos.y

	for k, zone in ipairs(fw.zone.list) do
		if zone:isPointInside(x, y) then
			return zone
		end
	end

	return nil
end
