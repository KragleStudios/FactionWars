# kragle
The core gamemode that holds everything together

# Kragle is based on a module loader framework
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
