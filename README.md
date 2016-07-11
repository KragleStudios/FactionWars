# kragle
The core gamemode that holds everything together

Uses semantic versioning http://semver.org

### Kragle is plugin based
```
<your module name>/
  module.lua
```
example of module.lua
```Lua
if SERVER then AddCSLuaFile() end -- for modules that should run on client
fw.dep(SHARED, 'hook') -- module uses hooks
fw.hook.Add('PlayerSay', function(pl) -- automagically injects the hook into the gamemode table
  pl:Kill() -- speaking out against the authority is death~
end)
```
# Dependencies
Please install and keep the following up to date
 - https://github.com/GMFactionWars/netdoc for networking
 - https://github.com/GMFactionWars/ra
 - https://github.com/thelastpenguin/sPON for table serialization and deserialization

# Style Guide
 - use -- for comments
 - use native lua syntax only plaese aka not instead of !
 - use lowerCammelCase for all methods etc. If you find somewhere that isn't lower camel case please change it.
 - Try to use lowerCamelCase or _ scores for variable names.
