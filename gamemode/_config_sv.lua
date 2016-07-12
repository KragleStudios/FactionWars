fw.config = fw.config or {} -- for now. todo: make into a module

fw.config.dataDir = 'factionwars'

fw.config.dataStore = 'text' -- text documents

fw.config.data_cacheUpdateInterval = 60 -- SECONDS
fw.config.data_storeUpdateInterval = 60 * 10 -- SECONDS
assert(fw.config.data_storeUpdateInterval > fw.config.data_cacheUpdateInterval, "defeats the point of caching")
