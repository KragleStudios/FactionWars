# Data
A simple framework for storing player data. No real extra work required.

Data is temporarly cached in memory. Every 60 seconds the data for every player is written to a 
sessionCache.txt file on disk as a SPON encoded table. Every 10 minutes every player's data is written
to the storage engine. Currently only a text storage engine is provided but this could easily accomidate MySQL.
Player data is also immediately written to the storage engine on disconnect or whenever the server starts up
to recover any sessions that might have been on disk when the server crashed.

## API
 - Player:GetFWData() - returns a table that contains all of the networked data about the player
 	editing values in this table on the server will cause them to sync with the client
 - fw.data.addPersistField(field name) - indicates that the data storage system should persist
 	this field between gameplay sessions not just syncing it accross the network. 
 - fw.data.loadPlayer(player) - loads the player's data from the storage engine calling 
 	```
 	hook.Call('FWLoadedPlayerData', player)
 	```
 	when complete. Should not be called manually as it gets called for you on PlayerInitialSpawn
 - data.updateStore(player) - commits a player's data to the storage engine which is free to encode and store it.
   This should not be called manually as it is called for you in 'PlayerDisconnected'
 - data.updateGlobalCache() - writes the entire data.players table to the sessionCache.txt on disk. This is 
   used to make sure data on disk will be recovered after a crash if it hasn't been committed to the store yet.
   Do this before operations that might cause a crash, but do it very spairingly as it is relatively slow. Should never really need to call this.
 - 