# Faction Wars
The core gamemode that holds everything together

# What is "Faction Wars?"
FactionWars is a combat oriented roleplay gamemode that pits factions against one another in a battle for territory and resources. Each server offers a set of factions that players can choose to align themselves with. Once aligned with a faction you can work with your teammates to launch wars, capture land, and construct illegal enterprises using our advanced resource system providing electricity, money printers, drugs, weapons, and more. 

Uses semantic versioning http://semver.org

### Faction Wars is plugin based
```
<your module name>/
  module.lua
```
example of module.lua
```Lua
if SERVER then AddCSLuaFile() end -- for modules that should run on client
fw.dep(SHARED, "hook") -- module uses hooks
fw.hook.Add("PlayerSay", function(pl) -- automagically injects the hook into the gamemode table
  pl:Kill() -- speaking out against the authority is death~
end)
```
# Utility Functions and Recommendations
Please read over the modules by thelastpenguin for reference to find how to properly use netdoc and existing libraries properly in your code.
Please use stylish fonts. from libraries/fonts 

## When doing prints
Please always use fw.print over print

## When including files
Please always use
```
fw.include_sh "file name" -- to include a shared file
fw.include_cl "file name" -- to include a client file
fw.include_sv "file name" -- to include a server file
```
## When loading dependencies
```
-- Require External libraries first
require "spon"
require "tmysql"
...
-- Require Dependend modules next
fw.dep(SERVER, "hook")
fw.dep(SHARED, "data")
...
-- Require lua files last
fw.include_cl "myfile.lua"
...
```
Also remember if your module runs any code client side you must add 
```
if SERVER then AddCSLuaFile() end
```
to the top, Faction Wars does not AddCSLuaFiles for you! It aims to give you maximum control over how your files are loaded.
## When adding hooks
always use the fw.hook module, the syntax for this is 
```
fw.hook.Add("hook name", "optional hook id", function(...) end)
```
just as usual. Hooks get injected into the GM[hook name] table. They will always be called in the same order that they are added which means hooks in modules you require with fw.dep(...) will get called before hooks in your module, but this behavior can get funky with lua refresh. If you choose not to provide the "optional hook id" the source path of the file it is defined in will be used instead.

## Networking
Please try to use netdoc for your networking needs. The data module defines a helper function Player:GetFWData() that you can use to get the network data table for that player. The player's money for example is stored in player:GetFWData().money, the faction in player:GetFWData().faction. You can add fields as desired. For more information about this please see the module docs at the bottom of this page for [libraries/data](gamemode/libraries/data/README.md).

# Dependencies
Please install and keep the following up to date
 - https://github.com/GMFactionWars/netdoc for networking
 - https://github.com/GMFactionWars/ra
 - https://github.com/thelastpenguin/sPON for table serialization and deserialization

# Style Guide
 - use -- for comments
 - use native lua syntax only please aka not instead of !
 - use lowerCamelCase for all methods and local variables etc. If you find somewhere that isn't lower camel case please change it.

# Module Docs
 - [core/economy](gamemode/core/economy/README.md)
 - [core/teams](gamemode/core/teams/README.md)
 - [libraries/data](gamemode/libraries/data/README.md)
 - [libraries/hook](gamemode/libraries/hook/README.md)
 - [libraries/notif](gamemode/libraries/notif/README.md)
