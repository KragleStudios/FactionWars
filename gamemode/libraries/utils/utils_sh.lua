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
