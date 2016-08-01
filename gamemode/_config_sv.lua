fw.config = fw.config or {} -- for now. todo: make into a module

-- where should data get stored
fw.config.dataDir = 'factionwars_sv'

fw.config.sql = {
	host = '',
	database = '',
	username = '',
	password = '',
	module = 'sqlite',
}

fw.config.dataStore = 'text' -- text OR sql

fw.config.data_cacheUpdateInterval = 60 -- SECONDS
fw.config.data_storeUpdateInterval = 60 * 10 -- SECONDS
assert(fw.config.data_storeUpdateInterval > fw.config.data_cacheUpdateInterval, "defeats the point of caching")

fw.config.dropBlacklist = {
	weapon_physgun = true,
	weapon_physcannon = true,
	gmod_tool = true,
	gmod_camera = true,
	weapon_fists = true,
}

fw.config.doorRespawnTime = 300 -- Amount of time for a dor to respawn, seconds

fw.config.chatTags = {
	['user'] = {Color(0, 0, 0), "U"},
	['admin'] = {Color(255, 0, 0), "A"},
	['superadmin'] = {Color(0, 0, 255), "SA"}
}