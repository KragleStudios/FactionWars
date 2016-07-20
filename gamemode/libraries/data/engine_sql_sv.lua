require 'ezdb'

local engine = {database = ezdb.create(fw.config.sql)}

function engine.database:onConnected()
	fw.print('Connected to the database')

	self:create('fw_playerdata')
		:create('id', 'INTEGER NOT NULL AUTO_INCREMENT')
		:create('steamid', 'VARCHAR(255) UNIQUE NOT NULL')
		:create('money', "INTEGER NOT NULL DEFAULT '0'")
		:create('data', "BLOB DEFAULT '{}'")
		:primaryKey('id')
	:execute()
end

function engine.database:onConnectionFailed(err)
	fw.print(err)
end

engine.loadPlayerData = function(steamid64, callback)
	engine.database:select('fw_playerdata'):where('steamid', steamid64):execute(function(result)
		if (#result == 1) then
			data = util.JSONToTable(result[1].data)
			data.money = result[1].money
			callback(data)
		else
			callback({})
		end
	end)
end

engine.updatePlayerData = function(steamid64, data, callback)
	engine.database:select('fw_playerdata'):where('steamid', steamid64):execute(function(result)
		if (#result == 1) then
			engine.database:update('fw_playerdata')
				:update('data', util.TableToJSON(data))
				:update('money', data.money)
				:where('steamid', steamid64)
			:execute(callback)
		else
			engine.database:insert('fw_playerdata')
				:insert('steamid', steamid64)
				:insert('money', data.money)
				:insert('data', util.TableToJSON(data))
			:execute(callback)
		end
	end)
end

return engine
