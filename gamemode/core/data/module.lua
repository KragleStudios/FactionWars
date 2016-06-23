if not SERVER then return end -- we don't AddCSLua anyway so it shouldn't ever make it to this code 

if true then return end -- disabled for now

local data = {}

-- dependencies
fw.dep(SERVER, "hook")
require 'spon' spon.noCompat = true 

-- create directories
data._cachedir = fw.config.datadir .. '/cache'
data._rootdir = fw.config.datadir 
file.CreateDir(data._rootdir)
file.CreateDir(data._cachedir)

-- load data engines
-- TODO: add error reporting if the datastore doesn't exist
-- TODO: convert this library to use pathlib
local engine = include('engine_' .. config.datastore .. '_sv.lua')


local function updateCache(data)

end





-- use cache to update the engine
local cacheFiles = file.Find(data._cachedir .. '/*.dat', 'DATA')
ra.async.eachSeries(cacheFiles, function(k, v, callback)
	engine.updatePlayerData()
end)

for k,v in ipairs(cacheFiles) do
	local steamid64 = v:match('p(.*?)%.dat')
	if steamid64 then

	end
end




data.players = {}

fw.hook.Add('PlayerInitialSpawn', function(pl)
	data.players = spon.decode()
end)
