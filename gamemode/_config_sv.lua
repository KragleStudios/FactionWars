fw.config = {} -- for now. todo: make into a module

fw.config.datadir = 'factionwars'

fw.config.datastore = 'text' -- text documents

fw.config.data_cacheUpdateInterval = 60 -- SECONDS
fw.config.data_storeUpdateInterval = 60 * 10 -- SECONDS
assert(fw.config.data_storeUpdateInterval > fw.config.data_cacheUpdateInterval, "defeats the point of caching")
