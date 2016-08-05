function fw.zone.createNewZone(name, polygon)
	local zoneId
	repeat 
		zoneId = math.random(1, 9999999) -- maximum support is 9 million zones. that should be enough
	until not fw.zone.zoneList[zoneId]

	local newZone = fw.zone.new():ctor(zoneId, name, polygon)

	-- there is a permission check done serverside
	net.Start('fw.zone.new')
	newZone:send()
	net.SendToServer()

	return zoneId
end

net.Receive('fw.zone.new', function()
	local zone = fw.zone.new():receive()
	fw.zone.zoneList[zone.id] = zone
end)

net.Receive('fw.zone.remove', function()
	fw.zone.zoneList[net.ReadUInt(32)] = nil
end)

hook.Add("HUDPaint", "fw.zones.showZoneInfo", function()
	local z = fw.zone.playerGetZone(LocalPlayer())

	if (not z) then return end

	local xOffset = ScrW()
	local headFont = fw.fonts.default:atSize(20)

	local maxX = 0
	for k,v in pairs(fw.team.factions) do
		surface.SetFont(headFont)
		local x, y = surface.GetTextSize(v.name)

		if (x > maxX) then
			maxX = x
		end
	end

	local zoneData = fw.zone.getZoneData(z)

	if (not zoneData) then return end
	
	for fac,v in pairs(zoneData) do
		local faction = fw.team.factions[fac]

		local color = faction.color
		local name = faction.name

		local players = v.players
		local score   = v.controlling and fw.config.zoneCaptureScore or v.score
		local iscontesting = v.contestingZone
		local iscontrolling = v.controlsZone

		--if (#players == 0) then continue end

		local yOffset = 0

		surface.SetFont(headFont)
		local x, y = surface.GetTextSize(name)
		x = maxX

		xOffset = xOffset - maxX - 10
		yOffset = y + 5

		draw.SimpleText(name, headFont, xOffset + (maxX / 2), 0, color, TEXT_ALIGN_CENTER)
		draw.RoundedBox(0, xOffset, y, maxX, 4, Color(0, 0, 0))

		local xBarWidth = (score / fw.config.zoneCaptureScore) * x
		draw.RoundedBox(0, xOffset, y, xBarWidth, 4, color)

		local name = "Members: "..#players
		local nameFont = fw.fonts.default:fitToView(x, y, name)

		surface.SetFont(nameFont)
		local x, y = surface.GetTextSize(name)

		local players = #players
		draw.SimpleText(name, nameFont, xOffset + (maxX / 2), yOffset, Color(0, 0, 0), TEXT_ALIGN_CENTER)

		yOffset = yOffset + y

		if (iscontesting) then
			draw.SimpleText("Contesting Zone!", nameFont,  xOffset + (maxX / 2), yOffset, Color(0, 0, 0), TEXT_ALIGN_CENTER)

			yOffset = yOffset + y
		end

		if (iscontrolling) then
			draw.SimpleText("Controlling Zone!", nameFont,  xOffset + (maxX / 2), yOffset, Color(0, 0, 0), TEXT_ALIGN_CENTER)

			yOffset = yOffset + y
		end

		--[[for k,v in pairs(players) do
			if (v:getFaction() != fac) then continue end

			local nick = v:Nick()

			local nameFont = fw.fonts.default:fitToView(x, y, nick)

			surface.SetFont(nameFont)
			local x, y = surface.GetTextSize(nick)

			draw.SimpleText(nick, nameFont, xOffset, yOffset, team.GetColor(v:Team()))

			yOffset = yOffset + y
		end]]
	end
end)

fw.hook.Add('PostDrawOpaqueRenderables', 'fw.zones.render', function()
	local curZone = fw.zone.playerGetZone(LocalPlayer())

	local tr = util.QuickTrace(LocalPlayer():GetPos(), Vector(0, 0,-10000), me)
	local z = tr.HitPos.z + 0.1

	for k, zone in pairs(fw.zone.zoneList) do
		-- render all the zones
		if zone == curZone then
			zone:render(z, Color(0, 255, 0, 55))
		else 
			zone:render(z, Color(255, 255, 255, 55))
		end
	end
end)