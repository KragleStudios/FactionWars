if SERVER then
	AddCSLuaFile()
end

require 'ra'

TOOL.Category = "Faction Wars"
TOOL.Name = "#faction wars zone creator"

local points = {}
local zone 

local lastInsert = CurTime()

function TOOL:LeftClick( trace, attach )
	if game.SinglePlayer() then error "This tool will not work in single player." end
	if not self:GetOwner():IsSuperAdmin() then return false end

	if SERVER then return false end
	if not IsFirstTimePredicted() then return false end

	table.insert(points, ra.geom.point(math.Round(trace.HitPos.x), math.Round(trace.HitPos.y)))
	
	if #points >= 3 then
		local oldZone = zone 
		zone = fw.zone.new()
		local succ = pcall(zone.ctor, zone, 0, 'a name', points)
		if not succ then
			zone = oldZone
		end 
	else
		zone = nil
	end

	return true	
end

function TOOL:RightClick( trace )
	if game.SinglePlayer() then error "This tool will not work in single player." end
	if not self:GetOwner():IsSuperAdmin() then return false end
	if not IsFirstTimePredicted() then return false end

	if zone then
		-- we will upload that zone

		local points = points 

		Derma_Query(
			"Are you sure you want to create this zone?", 
			"Zone Creator", "YES", function()
				Derma_StringRequest("Zone Creator", "Enter the zone name", "a zone", function(zoneName)
					if string == 'zoneName' then return end

					fw.zone.createNewZone(zoneName, points)
					
					LocalPlayer():ConCommand('fw_zone_saveAllZones')

					chat.AddText(Color(0, 255, 0), "Created a new zone")
				end)
			end, "NO", ra.fn.noop)

	end

	points = {}
	zone = nil 
end

function TOOL:Reload()
	print "Reloaded tool"
	points = {}
	zone = nil 
end



hook.Add('PostDrawOpaqueRenderables', 'fw.toolgun.zonecreator', function()
	render.SetColorMaterial()

	local mypos = LocalPlayer():GetPos()
	local me = LocalPlayer()

	local tr = util.QuickTrace(mypos, Vector(0, 0,-1000), me)

	local z = tr.HitPos.z
	local sphere_color = Color(255, 0, 0, 255)
	local line_color = Color(0, 255, 0, 255)

	local function pointToVector(p)
		return Vector(p:getX(), p:getY(), z)
	end 

	for k, point in ipairs(points) do
		render.DrawWireframeSphere(Vector(point:getX(), point:getY(), z), 1, 5, 5, sphere_color, false)
	end
	
	if zone then
		for k, triangle in ipairs(zone.triangles) do
			render.DrawLine(pointToVector(triangle.p1), pointToVector(triangle.p2), line_color)
			render.DrawLine(pointToVector(triangle.p1), pointToVector(triangle.p3), line_color)
			render.DrawLine(pointToVector(triangle.p2), pointToVector(triangle.p3), line_color)
		end
	end

end)

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "A tool for creating zones!" } )

end
