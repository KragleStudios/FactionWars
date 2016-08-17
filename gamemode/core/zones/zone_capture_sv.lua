ndoc.table.fwZoneControl = {}

local cache = {}
function fw.zone.setupCaptureNetworking(zone)
	ndoc.table.fwZoneControl[zone.id] = {}
	ndoc.table.fwZoneControl[zone.id].scores = {}

	if (cache[zone.id]) then
		ndoc.table.fwZoneControl[zone.id].isProtected = cache[zone.id].prot
		ndoc.table.fwZoneControl[zone.id].isNotCapturable = cache[zone.id].not_cap
		ndoc.table.fwZoneControl[zone.id].isFactionBase = cache[zone.id].fac_base
	end
end


---
--- LOADING AND SETTING OF ZONE CAPTURABILITY / PROTECTED ZONES AND BASES
---
local path = fw.zone.zoneDataDir..game.GetMap().."_cap.txt"
function fw.zone.loadCaptureData()
	local data = file.Read(path, "DATA")

	if (not data) then return end
	
	for k,v in pairs(spon.decode(data)) do

		cache[k] = v
	end
end

fw.zone.loadCaptureData()

function fw.zone.saveCaptureData()
	local cache = {}

	for zID, data in ndoc.pairs(ndoc.table.fwZoneControl) do
		local isProt = data.isProtected
		local isNotCap = data.isNotCapturable
		local isBase = data.isFactionBase

		--the zone is not protected, and it is capturable or a faction base, no point saving this data!
		if (not isProt and not isNotCap and not isBase) then continue end

		cache[zID] = {}

		if (isProt) then
			cache[zID].prot = true
		end
		if (isNotCap) then
			cache[zID].not_cap = true
		end
		if (isBase) then
			cache[zID].fac_base = isBase --isbase isn't a bool, it's a faction id!
		end
	end

	cache = spon.encode(cache)
	file.Write(path, cache)
end

---
--- CHAT COMMANDS FOR SETTING FACTION BASES, CAPTURABILITY, AND PROTECTED ZONES
---
fw.chat.addCMD({"setprotected", "setprot"}, "Sets a zone to be protected(no damage taken while inside) or not", function(ply, boolProtected)
	local pZone = fw.zone.playerGetZone(ply)

	if (not pZone) then return end

	ndoc.table.fwZoneControl[pZone.id].isProtected = boolProtected

	fw.zone.saveCaptureData()
end):addParam("bool_protect", "bool"):restrictTo("superadmin")

fw.chat.addCMD({"setcapturable", "setcap"}, "Sets a zone to be capturable or not", function(ply, boolCaptureable)
	local pZone = fw.zone.playerGetZone(ply)

	if (not pZone) then return end

	ndoc.table.fwZoneControl[pZone.id].isNotCapturable = not boolCaptureable
	
	fw.zone.saveCaptureData()
end):addParam("bool_capturable", "bool"):restrictTo("superadmin")

fw.chat.addCMD({"setfactionbase", "setbase"}, "Sets the zone to be a default base for a faction", function(ply, sFactionID)
	local pZone = fw.zone.playerGetZone(ply)

	if (not pZone) then return end

	local fac = fw.team.getFactionByStringID(sFactionID)
	if (not fac) then return end

	ndoc.table.fwZoneControl[pZone.id].isFactionBase = fac:getID()

	fw.zone.saveCaptureData()
end):addParam("faction_string_id", "string"):restrictTo("superadmin")

fw.chat.addCMD({"removefactionbase", "removebase"}, "Removes the base set to a zone you are in", function(ply)
	local pZone = fw.zone.playerGetZone(ply)

	if (not pZone) then return end

	local fac = pZone:getFactionBase()
	if (not fac) then return end

	ndoc.table.fwZoneControl[pZone.id].isFactionBase = false

	fw.zone.saveCaptureData()
end):restrictTo("superadmin")

concommand.Add("fw_zone_createBackup", function(pl)
	if not pl:IsSuperAdmin() then
		return pl:FWConPrint(Color(255, 0, 0), "you do not have permission to run this command")
	end

	fw.zone.createZonesBackup()
	pl:FWConPrint(Color(0, 255, 0), "Created a backup of the zones file.")
end)

--
-- SIMPLE ALGORITHMS THAT MANAGES ZONE CAPTURING
--	
function fw.zone._zone_mt:canBeCaptured()
	local canCapture = hook.Call("CanZoneBeCaptured", GAMEMODE, self)
	if (canCapture == false) then return false end

	local zoneData = ndoc.table.fwZoneControl[self.id]
	if (zoneData.isNotCapturable) then return false end
	if (zoneData.isProtected) then return false end
	if (zoneData.isFactionBase) then return false end
	
	return true
end

local MAX_CAPTURE_SCORE = fw.config.zoneCaptureScore
local ZONE_CAPTURE_RATE = fw.config.zoneCaptureRate
timer.Create("fw.zone_capture.updateCaptureProgress", 1, 0, function()
	for k, zone in pairs(fw.zone.zoneList) do
		if (not zone:canBeCaptured()) then continue end

		local zoneControl = ndoc.table.fwZoneControl[zone.id].scores

		local controllingInterests = {}
		local mostInterest = nil

		for k, pl in ipairs(zone.players) do
			local fac = pl:getFaction()
			if fac ~= FACTION_DEFAULT then
				controllingInterests[fac] = (controllingInterests[fac] or 0) + 1
				if not mostInterest or controllingInterests[mostInterest] < controllingInterests[fac] then
					mostInterest = fac
				end
			end
		end

		if mostInterest then

			if (zoneControl[mostInterest] or 0) < MAX_CAPTURE_SCORE then
				zoneControl[mostInterest] = math.min((zoneControl[mostInterest] or 0) + ZONE_CAPTURE_RATE, MAX_CAPTURE_SCORE)
			end
			for k,v in ndoc.pairs(zoneControl) do
				if k ~= mostInterest and v ~= 0 then
					zoneControl[k] = math.max(0, zoneControl[k] - ZONE_CAPTURE_RATE)
				end
			end
		end
	end
end)

---
--- HOOKS TO MAINTAIN CAPTURABILITY / BASE / PROTECTED ZONES
---
--stop players from taking damage in protected zones -from weapons
hook.Add("EntityTakeDamage", "StopPlayerDamageInProtectedZones", function(ent, dmg)
	if (ent:IsPlayer()) then
		local zone = fw.zone.playerGetZone(ent)
		if (zone) then

			local isprotected = zone:isProtected()
			if (isprotected) then dmg:SetDamage(0) end
		end
	end
end)

--don't let players pickup weapons in a protected zone
hook.Add("PlayerCanPickupWeapon", "StopPickingUpGunsWhileInProtectedZone", function(ply, wep)
	local zone = fw.zone.playerGetZone(ply)
	if (zone) then

		local isprotected = zone:isProtected()
		if (isprotected and ply.weaponCache) then

			return false

		end
	end
end)

--when a player enters a protected zone, strip their weapons
fw.hook.Add("PlayerEnteredZone", "PlayerGetsWeaponsrestricted", function(enterZone, lastZone, ply)
	if (not enterZone and lastZone) then
		local isprotected = lastZone:isProtected()
		if (isprotected and ply.weaponCache) then
			for k,v in pairs(ply.weaponCache) do
				ply:Give(k)
			end

			ply.weaponCache = nil
		end
	end

	if (enterZone) then
		local isprotected = enterZone:isProtected()
		if (isprotected) then

			ply.weaponCache = {}
			for k,v in pairs(ply:GetWeapons()) do
				ply.weaponCache[v:GetClass()] = true
			end

			ply:StripWeapons()

		end
	end
end)


--[[
function fw.zone.initiate(zone)
	local id = zone.id

	ndoc.table.zones[id] = {}
	ndoc.table.zones[id].controlling = nil
	ndoc.table.zones[id].factions = {}
	ndoc.table.zones[id].contesting = nil

	for k,v in pairs(fw.team.factions) do
		ndoc.table.zones[id].factions[k] = {}
		ndoc.table.zones[id].factions[k].score = 0
		ndoc.table.zones[id].factions[k].players = {}
	end
end

fw.zone.cap_cache = {}
--saves zone protection and capture data
local path = fw.zone.zoneDataDir..game.GetMap().."_cap.txt"
function fw.zone.saveCapCache()
	local pon = spon.encode(fw.zone.cap_cache)
	file.Write(path, pon)
end

--loads zone protection & capture data
function fw.zone.loadCapCache()
	local f = file.Read(path, "DATA")
	if (not f) then return end

	fw.zone.cap_cache = spon.decode(f)
	for k,v in pairs(fw.zone.cap_cache) do
		ndoc.table.zones[k].capturable = v.capturable
		ndoc.table.zones[k].protected  = v.protected
		ndoc.table.zones[k].faction_base = v.faction_base
	end
end

fw.chat.addCMD({"setprotected", "setprot"}, "Sets a zone to be protected(no damage taken while inside) or not", function(ply, boolProtected)
	local pZone = fw.zone.playerGetZone(ply)

	if (not pZone) then return end
	fw.zone.cap_cache[pZone.id] = fw.zone.cap_cache[pZone.id] or {}

	if (boolProtected == false) then
		fw.zone.cap_cache[pZone.id].protected = nil
		ndoc.table.zones[pZone.id].protected = nil

		fw.zone.saveCapCache()
		return
	end

	fw.zone.cap_cache[pZone.id].protected = boolProtected
	ndoc.table.zones[pZone.id].protected = boolProtected

	fw.zone.saveCapCache()
end):addParam("bool_protect", "bool"):restrictTo("superadmin")

fw.chat.addCMD({"setcapturable", "setcap"}, "Sets a zone to be capturable or not", function(ply, boolCaptureable)
	local pZone = fw.zone.playerGetZone(ply)

	if (not pZone) then return end
	fw.zone.cap_cache[pZone.id] = fw.zone.cap_cache[pZone.id] or {}

	if (boolCaptureable == true) then
		fw.zone.cap_cache[pZone.id].capturable = nil
		ndoc.table.zones[pZone.id].capturable = nil

		fw.zone.saveCapCache()
		return
	end

	fw.zone.cap_cache[pZone.id].capturable = boolCaptureable
	ndoc.table.zones[pZone.id].capturable = boolCaptureable

	fw.zone.saveCapCache()
end):addParam("bool_capturable", "bool"):restrictTo("superadmin")

fw.chat.addCMD({"setfactionbase", "setbase"}, "Sets the zone to be a default base for a faction", function(ply, sFactionID)
	local pZone = fw.zone.playerGetZone(ply)

	if (not pZone) then return end

	local fac = fw.team.getFactionByStringID(sFactionID)
	if (not fac) then return end

	fw.zone.cap_cache[pZone.id] = fw.zone.cap_cache[pZone.id] or {}

	fw.zone.cap_cache[pZone.id].faction_base = fac:getID()
	ndoc.table.zones[pZone.id].faction_base = fac:getID()

	fw.zone.saveCapCache()
end):addParam("faction_string_id", "string"):restrictTo("superadmin")

fw.chat.addCMD({"removefactionbase", "removebase"}, "Removes the base set to a zone you are in", function(ply)
	local pZone = fw.zone.playerGetZone(ply)

	if (not pZone) then return end

	local fac = fw.zone.isFactionBase(pZone)
	if (not fac) then return end

	fw.zone.cap_cache[pZone.id] = fw.zone.cap_cache[pZone.id] or {}

	fw.zone.cap_cache[pZone.id].faction_base = nil
	ndoc.table.zones[pZone.id].faction_base = nil

	fw.zone.saveCapCache()
end):restrictTo("superadmin")

concommand.Add("fw_zone_createBackup", function(pl)
	if not pl:IsSuperAdmin() then
		return pl:FWConPrint(Color(255, 0, 0), "you do not have permission to run this command")
	end

	fw.zone.createZonesBackup()
	pl:FWConPrint(Color(0, 255, 0), "Created a backup of the zones file.")
end)

--logic for contesting another faction's zone
function fw.zone.contest(zone, faction)
	--cooldown for adding score to teams!
	local id = zone.id
	local facScore = ndoc.table.zones[id].factions[faction.factionID].score

	if (ndoc.table.zones[id].controlling == faction.factionID) then return end

	if (facScore == fw.config.zoneCaptureScore) then
		ndoc.table.zones[id].controlling = faction.factionID
		ndoc.table.zones[id].contesting = nil

		hook.Call("FactionCapturedZone", GAMEMODE, faction, zone)

		for k,v in pairs(fw.team.factions) do
			if (k == faction.factionID) then continue end

			ndoc.table.zones[id].factions[k].score = 0
		end

		return
	end

	hook.Call("FactionContestingZone", GAMEMODE, faction, zone)

	ndoc.table.zones[id].contesting = faction
	ndoc.table.zones[id].factions[faction.factionID].score = ndoc.table.zones[id].factions[faction.factionID].score + 1
	zone.nextRegisterScore = CurTime() + fw.config.zoneCaptureRate
end

--returns whether or not a zone can be captured
function fw.zone.canBeCaptured(zone)
	local canCapture = hook.Call("CanZoneBeCaptured", GAMEMODE, zone)

	--make sure it's false, not just doesn't exist
	if (fw.zone.cap_cache[zone.id] and fw.zone.cap_cache[zone.id].faction_base) then return false end
	if (fw.zone.cap_cache[zone.id] and fw.zone.cap_cache[zone.id].capturable != nil and fw.zone.cap_cache[zone.id].capturable == false) then return false end
	if (fw.zone.cap_cache[zone.id] and fw.zone.cap_cache[zone.id].protected != nil and fw.zone.cap_cache[zone.id].protected == true) then return false end
	if (zone.nextRegisterScore and CurTime() - zone.nextRegisterScore < 0) then return false end

	return true
end

--stop players from taking damage in protected zones -from weapons
hook.Add("EntityTakeDamage", "StopPlayerDamageInProtectedZones", function(ent, dmg)
	if (ent:IsPlayer()) then
		local zone = fw.zone.playerGetZone(ent)
		if (zone) then

			local isprotected = fw.zone.isProtectedZone(zone)
			if (isprotected) then dmg:SetDamage(0) end
		end
	end
end)

--don't let players pickup weapons in a protected zone
hook.Add("PlayerCanPickupWeapon", "StopPickingUpGunsWhileInProtectedZone", function(ply, wep)
	local zone = fw.zone.playerGetZone(ply)
	if (zone) then
		local isprotected = fw.zone.isProtectedZone(zone)
		if (isprotected and ply.weaponCache) then

			return false

		end
	end
end)

--when a player leaves a protected zone, give their weapons back
fw.hook.Add("PlayerLeftZone", "PlayerGetsWeaponsback", function(zone, ply)
	local isprotected = fw.zone.isProtectedZone(zone)
	if (isprotected and ply.weaponCache) then
		for k,v in pairs(ply.weaponCache) do
			ply:Give(k)
		end

		ply.weaponCache = nil
	end
end)

--when a player enters a protected zone, strip their weapons
fw.hook.Add("PlayerEnteredZone", "PlayerGetsWeaponsrestricted", function(zone, ply)
	local isprotected = fw.zone.isProtectedZone(zone)
	if (isprotected) then

		ply.weaponCache = {}
		for k,v in pairs(ply:GetWeapons()) do
			ply.weaponCache[v:GetClass()] = true
		end

		ply:StripWeapons()

	end
end)

fw.hook.Add("Think", "ZoneControlLogic", function()
	--reset player counts for each faction in the zone
	for k,v in pairs(player.GetAll()) do
		local pZone = fw.zone.playerGetZone(v)

		--incase the player changed factions, and left the zone, we want to remove all instances of them being there
		if (not pZone and v.lastZone) then
			local zoneData = ndoc.table.zones[v.lastZone.id].factions

			local z = v.lastZone
			hook.Call("PlayerLeftZone", GAMEMODE, z, v)

			for k,fac in ndoc.pairs(zoneData) do

				ndoc.table.zones[v.lastZone.id].factions[k].players[v] = nil

			end

			v.lastZone = nil

		--if the player is in a zone, make sure the counter is ready, and insert them into the faction thingy
		elseif (pZone) then
			if (v.lastFaction and v.lastFaction != v:getFaction()) then
				ndoc.table.zones[pZone.id].factions[v.lastFaction].players[v] = nil

				v.lastFaction = nil
			end

			v.lastFaction = v:getFaction()

			local id = pZone.id

			--no use constantly syncing the player already in here
			if (not ndoc.table.zones[id].factions[v:getFaction()].players[v]) then
				ndoc.table.zones[id].factions[v:getFaction()].players[v] = true

				hook.Call("PlayerEnteredZone", GAMEMODE, pZone, v)
			end

			v.lastZone = pZone

			if (not fw.zone.canBeCaptured(pZone)) then continue end
		end
	end

	--loop through the zones and do the logic
	for zoneid, zoneTable in ndoc.pairs(ndoc.table.zones) do
		local factionInPower = nil
		local zone = fw.zone.zoneList[zoneid]

		if (not zone) then continue end
		if (not fw.zone.canBeCaptured(zone)) then continue end

		for fac,v in ndoc.pairs(zoneTable.factions) do
			local plys = {}
			for k,v in ndoc.pairs(v.players) do

				--remove players that left and stuff
				if (not IsValid(k)) then
					ndoc.table.zones[zoneid].factions[fac].players[k] = nil
				end
				table.insert(plys, k)
			end

			--if there are more players in another faction than the one who is control of the faction
			if (factionInPower and #plys > #factionInPower.playersInZone) then
				factionInPower = {}
				factionInPower.playersInZone = plys
				factionInPower.factionID = fac

				--equal disbursement of players in the zone for all factions
			elseif (factionInPower and #plys == #factionInPower.playersInZone) then
				if (ndoc.table.zones[zoneid].contesting and ndoc.table.zones[zoneid].contesting and ndoc.table.zones[zoneid].contesting.factionID != factionInPower.factionID) then
					ndoc.table.zones[zoneid].contesting = nil
				end

				return

				--for when players first enter a zone :D
			elseif (not factionInPower and #plys > 0) then
				factionInPower = {}
				factionInPower.playersInZone = plys
				factionInPower.factionID = fac
			end
		end

		--if we have a new faction in power, contest the zone
		if (factionInPower) then
			if (ndoc.table.zones[zoneid].contesting and ndoc.table.zones[zoneid].contesting.factionID != factionInPower.factionID) then
				ndoc.table.zones[zoneid].contesting = nil
			end

			fw.zone.contest(zone, factionInPower)
		end
	end
end)
]]
