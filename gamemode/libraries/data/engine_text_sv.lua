local engine = {}

file.CreateDir(fw.config.dataDir .. '/PlayerData')

local dataDirPlayers = fw.config.dataDir .. '/PlayerData'

engine._getPlayerDataFile = function(steamid64)
	return dataDirPlayers .. '/p' .. (steamid64 or 0) .. '.dat'
end

engine.loadPlayerData = function(steamid64, callback)
	local fname = engine._getPlayerDataFile(steamid64)

	if file.Exists(fname, 'DATA') then
		return callback(spon.decode(util.Decompress(file.Read(fname, 'DATA'))))
	end
	return callback({})
end

engine.updatePlayerData = function(steamid64, data, callback)
	-- since storing player data is somewhat infrequent we can afford to util.Compress it
	file.Write(engine._getPlayerDataFile(steamid64), util.Compress(spon.encode(data)))
	callback()
end

return engine
