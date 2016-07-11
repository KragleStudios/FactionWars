# Notifications
Provides a framework for notifying a player or set of players that something happened.
## API
 - fw.notif.conPrint(players, ...)
   - players:table a table of players to send to
   - ... variadic set of strings to send
 - fw.notif.chatPrint(players, ...)
   - players:table a table of players to send to
   - ... variardic set of colors and strings to send

# ConCommands
- fw\_data\_updateStore - updates the data store for all players immediately
- fw\_data\_updateCache - updates the cache for all players immediately