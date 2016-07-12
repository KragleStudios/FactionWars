fw.data = fw.data or {}
local data = fw.data

-- load external dependencies
require 'spon' spon.noCompat = true

-- load internal dependencies
fw.dep(SERVER, 'hook')


-- create directories
data._rootdir = fw.config.datadir 
data._cacheFile = data._rootdir .. '/sessionCache.txt'
file.CreateDir(data._rootdir)

local engine = fw.include_sv 'engine_text_sv.lua'

--
-- CREATE PLAYER DATA TABLE
-- 

-- fields to persist
data.persistFields = {}
function data.addPersistField(name)
	if not table.HasValue(data.persistFields, name) then
		table.insert(data.persistFields, name)

		ndoc.addHook('fwPlayers.?.' .. name, 'set', function(pl, value)
			if not data.player[pl] then return end -- for some reason their data is not loaded yet. It can not be modified.
			data.player[pl][name] = value
		end)
	end
end


-- player data table
data.player = {}
ndoc.table.fwPlayers = {}

function data.loadPlayer(player)
	fw.print("loading data for " .. tostring(player).. ".")

	ndoc.table.fwPlayers[player] = {}
	engine.loadPlayerData(player:SteamID64() or '0', function(_data)
		-- copy the data to data.player
		data.player[player] = _data

		-- copy it into the net table
		local pdataTable = player:GetFWData()
		for k,v in pairs(_data) do
			pdataTable[k] = v
		end

		hook.Call('FWLoadedPlayerData', player)
	end)
end

function data.updateStore(player)
	fw.print("update store for " .. tostring(player))
	if not data.player[player] then
		pl:FWChatPrint(Color(255, 0, 0), '[FACTION WARS] [ERROR] your account data is currently loaded in offline mode. Your progress will not save. Please reconnect.')
		return 
	end

	engine.updatePlayerData(player:SteamID64() or '0', data.player[player], ra.fn.noop) -- no callback
end

--
-- HOOKS TO LOAD AND STORE PLAYER SESSION DATA
--
fw.hook.Add('PlayerInitialSpawn', function(pl)
	data.loadPlayer(pl)
end)

fw.hook.Add('PlayerDisconnected', function(pl)
	data.updateStore(player)

	data.player[pl] = nil
	ndoc.table.fwPlayers[pl] = nil
end)

fw.hook.Add('ShutDown', function(pl)
	data.updateGlobalCache()
end)

--
-- SAVE ALL PLAYER DATA TO A SESSION CACHE
--
function data.updateGlobalCache()
	local persist = {}
	for player, data in pairs(data.player) do
		persist[player:SteamID64() or '0'] = data
	end
	
	file.Write(data._cacheFile, spon.encode(persist))
end

timer.Create('fwUpdateCache', fw.config.data_cacheUpdateInterval, 0, function()
	data.updateGlobalCache()
end)

timer.Create('fwUpdateStore', fw.config.data_storeUpdateInterval, 0, function()
	for k, player in ipairs(player.GetAll()) do
		data.updateStore(player)
	end
end)

--
-- restore sessions from the cache to the perminant data store
--
if file.Exists(data._cacheFile, 'DATA') then
	local succ, sessionCache = pcall(spon.decode, file.Read(data._cacheFile, 'DATA'))
	if not succ then 
		fw.print("failed to recover player data session cache!")
		fw.print(sessionCache)
	else

		for steamid64, sessionData in pairs(sessionCache) do
			fw.print("recovered session data for player " .. steamid64)

			-- if the player is somehow online then force them to reload their data
			engine.updatePlayerData(steamid64, sessionData, function()
				for k,v in pairs(player.GetAll()) do
					if v:SteamID64() == steamid64 then
						data.loadPlayer(v)
					end
				end
			end)
		end

	end
end

--
-- some lua refresh compatability
--
for k,v in ipairs(player.GetAll()) do
	data.loadPlayer(v)
end

--
-- CONSOLE COMMANDS
-- 
concommand.Add('fw_data_updateStore', function(pl, cmd, args)
	if not pl:IsSuperAdmin() then pl:ChatPrint('insufficient privliages') end

	pl:FWConPrint("updated data store for all players")

	for k,v in pairs(player.GetAll()) do
		data.updateStore(v)
	end
end, function()
	return {"commits all changes to player data to the long term storage"}
end)

concommand.Add('fw_data_updateCache', function(pl, cmd, args)
	if not pl:IsSuperAdmin() then pl:ChatPrint('insufficient privliages') end

	pl:FWConPrint("updated global cache")

	data.updateGlobalCache()
end, function()
	return {"updates the local value cache, this is for crash tolerance"}
end)
