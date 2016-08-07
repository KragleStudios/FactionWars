# Zones

# Functions
 - fw.zone.playerGetZone(player) - gets the zone object that contains the player given (nil if they are not in a zone)
 - fw.zone.createZonesBackup() - creates a backup of the currently loaded zone file
 - fw.zone.saveZonesToFile() - saves the currently loaded zones to a file
 - fw.zone.loadZonesFromDisk() - loads the zones from the file for the current map
 - fw.zone.getZoneFileCRC() - returns the CRC32 string of the zone file for the current map
 - Player:getZoneInside() - returns the zone object that the player is inside
 - Zone:constructRenderer(color_outline, color_fill, border_width) - the object that this returns is a renderer. renderer:draw() will draw the zone. renderer:destroy() must be called when you are done with it or garry's mod will leak memory.

# Zone Objects
 - zone.players - table{player} - a table of players inside the zone
 - zone.polygon - the polygon outlineing the zone
 - zone.triangles - the triangles that fill the zone
 - Zone:isPointInside(x, y) - returns true if the x, y coordinates are inside the zone's region
 - Zone:ctor(id, name, polygon) - creates a new zone with the given id, name, and outline polygon. Shouldn't really be called unless you have read the source code and really understand what you are doing. Can be a dangerous function.
 - Zone:getPointsInsetByAmount(amount) - returns a new polygon shrunk by 'amount' units. This is used primarily by the renderer to generate the thick border lines you see.

# Shared Hooks
 - PlayerEnteredZone (zone entered, zone exited, player) - called when a player enters a zone

# TODO crazyscouter
## Functions
 - fw.zone.getControllingFaction(zone) - returns the controlling faction of a zone or nil
 - fw.zone.getContestingFaction(zone) - returns the faction contesting a zone or nil for none
 - fw.zone.getZoneData(zone) - returns a table containing all the factions, with the players in the zone, each faction's score, whether they are contesting or controlling the zone.
 - fw.zone.getControlledZones(factionID) - returns a table of all zones controlled by this faction, with the key as the zone id and the value as the zone object
 - fw.zone.isCapturableZone(zone) - returns whether or not a zone can be captured by a faction
 - fw.zone.isProtectedZone(zone) - returns whether or not a zone is protected
 - fw.zone.isFactionBase(zone) - returns whether or not a zone is a default zone for a faction, if it is, the returned value is the faction

## Serverside Hooks
 - FactionContestingZone (faction table, zone object) - passes the zone object and faction data with the factionID, playersInZone. NOTE: This is called every time the contest function is called, meaning this will be called A LOT
 - FactionCapturedZone (faction table, zone object) - passes the zone object and faction data with the factionID, playersInZone
 - CanZoneBeCaptured (zone object) - return whether or not the zone can be captured
 - PlayerEnteredZone (zone entered, zone exited, player) - called whenever a player enters a zone
