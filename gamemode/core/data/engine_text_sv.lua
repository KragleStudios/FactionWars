local engine = {}

file.CreateDir(fw.config.datadir)
file.CreateDir(fw.config.datadir .. '/PlayerData')

local datadirPlayers = fw.config.datadir .. '/PlayerData'

engine._getPlayerDataFile = function(steamid64)
	return datadirPlayers .. '/p' .. (steamid64 or 0) .. '.dat'
end

engine.loadPlayerData = function(steamid64, callback)
	local fname = engine._getPlayerDataFile(steamid64)

	if file.Exists(fname, 'DATA') then
		return callback(spon.decode(util.Decompress(file.Read(fname, 'DATA')))
	end
	return callback({})
end

engine.updatePlayerData = function(steamid64, data, callback)
	file.Write(engine._getPlayerDataFile(), util.Compress(spon.encode(data)))
	callback()
end

return engine