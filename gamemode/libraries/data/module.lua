if not SERVER then return end -- we don't AddCSLua anyway so it shouldn't ever make it to this code 

local data = {}
fw.data = data -- preset table

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

-- player data table
data.player = {}
ndoc.table.fwPlayers = {}

ndoc.addHook('fwPlayers.?', 'set', function(pl, value)
	data.player[pl] = {}
end)

ndoc.addHook('fwPlayers.?.?', 'set', function(pl, key, value)
	data.player[pl][key] = value
end)

function data.loadPlayer(player)
	ndoc.table.fwPlayers[player] = {}
	engine.loadPlayerData(player:SteamID64() or '0', function(data)
		for k,v in pairs(data) do
			ndoc.table.fwPlayers[k] = v
		end

		hook.Call('FWLoadedPlayerData', player)
	end)
end

function data.updateStore(player)
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

timer.Create('fwUpdateCache', 30, 0, function()
	data.updateGlobalCache()
end)

timer.Create('fwUpdateStore', 600, 0, function()
	for k, player in ipairs(player.GetAll()) do
		data.updateStore(player)
	end
end)

--
-- restore sessions from the cache to the perminant data store
--
if file.Exists(data._cacheFile, 'DATA') then
	local succ, sessionCache = pcall(spon.decode(file.Read(data._cacheFile, 'DATA')))
	if not succ then fw.print("failed to recover player data session cache!") return end

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

--
-- some lua refresh compatability
--
for k,v in ipairs(player.GetAll()) do
	data.loadPlayer(pl)
end

