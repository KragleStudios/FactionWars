include("shared.lua")

--converts a player's position relative to the radar and computes position for the radar
function ENT:ComputePosition(ply)
	--setup our origin points
	local targPos = ply:GetPos()
	local realPos  = self:GetPos()

	--get the difference of the values and normalize it in terms of the unit vector
	local pos = (realPos - targPos)

	return pos.x, pos.y
end

--finds the targets and their positions 
function ENT:FindTargets()
	local pos = self:GetPos()
	local test = self.radius * self.radius

	local cache = {}

	for k,v in pairs(player.GetAll()) do
		local dis = pos:DistToSqr(v:GetPos())
		if (dis <= test and not v.hidden) then --support for like stealth items
			local px, py = self:ComputePosition(v)

			table.insert(cache, {
					target = v,
					x = px,
					y = py,
					distance = dis,
				})

		end
	end

	return cache
end

function ENT:TransformPoint(p, dis)
	local point = (p / self.radius) * 200

	return point
end

--taken from gmod wiki
local function drawCircle(x, y, radius, seg)
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is need for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local dis = 300 * 300
function ENT:Draw()
	self:DrawModel()

	if (LocalPlayer():GetPos():DistToSqr(self:GetPos()) > dis) then return end

	cam.Start3D2D(self:GetPos() + self:GetUp() * 6, Angle(0, 0, 0), .1)
		surface.SetDrawColor(0, 0, 0, 235)
		draw.NoTexture()
		drawCircle(0, 0, 200, 360)

		for k,v in pairs(self:FindTargets()) do
			local facCol = fw.team.factions[v.target:getFaction()].color or fw.team.factions[FACTION_DEFAULT].color
			
			--if the player has a bad weapon, show them as a threat if they aren't in the same faction


			surface.SetDrawColor(facCol)

			local x, y = self:TransformPoint(-v.x, v.distance), self:TransformPoint(v.y, v.distance)
			drawCircle(x, y, 5, 360)
		end
	cam.End3D2D()
end