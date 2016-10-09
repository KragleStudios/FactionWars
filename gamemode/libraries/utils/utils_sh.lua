--returns a table of players in the given radius from the position start
function player.findInSphere(startPos, radius)
	assert(isvector(startPos), "player.findInSphere requires a start position")
	assert(radius, "player.findInSphere requires a radius")

	local players = player.GetAll()
	local r_squared = radius * radius

	local cache = {}

	for k,v in pairs(players) do
		if (v:GetPos():DistToSqr(startPos) <= r_squared) then
			table.insert(cache, v)
		end
	end

	return cache
end

local events = {}
for I=1,12 do events[I] = {} end
events[2][14] = "Valentines Day"
events[3][8] = "Internation Womens Day"
events[4][1] = "April fools"
events[4][22] = "Earth day"
events[9][19] = "Speak Pirate Day"
events[10][24] = "Gmods Release"
events[10][31] = "Halloween"
events[11][19] = "Internation Mens Day"
events[12][24] = "Xmas"
events[12][31] = "New Year"

function util.GetSpecialDay()
    local date = os.date( "%d/%m/%Y" , os.time() )
    local dtab = string.Explode("/",date)
    local d,m,y = tonumber(dtab[1]),tonumber(dtab[2]),tonumber(dtab[3])
    
    if events[m][d] or events[m][d-1] then
        return events[m][d] or events[m][d-1]
    end

    if m==7 and d>=1 and d<=11 then
        return "Summer"
    end
    if m==12 then
        return "Winter"
    end
    return false
end