# Contributing to gmFactionWars
Thank you for your interest in contributing to gmFactionWars. 

## Coding conventions
 * Use fw.print instead of print.
 * Use AddCSLuaFile() at the top of your module.
 * Use fw.hook instead of hook.
 * Use -- for comments.
 * Use the native Lua syntax only (not instead of !, and instead of &&, or instead of ||).
 * Use lowerCamelCase for all methods, local variables, etc.
 * Use fw.include instead of include.
```
fw.include_sh "file name" -- to include a shared file
fw.include_cl "file name" -- to include a client file
fw.include_sv "file name" -- to include a server file
```
 * Require external libraries first, dependencies next and lua files as last.
```
-- External libraries
require "spon"
require "tmysql"

-- Dependencies
fw.dep(SERVER, "hook")
fw.dep(SHARED, "data")

-- Lua files
fw.include_cl "myfile.lua"
```
 * Please try to use [netdoc](https://github.com/GMFactionWars/netdoc) for your networking needs. Check [libraries/data](gamemode/libraries/data/README.md) for more information.
 
You can find more documentations in the respective folders. 
([core/economy](gamemode/core/economy/README.md), [core/teams](gamemode/core/teams/README.md), [libraries/data](gamemode/libraries/data/README.md), [libraries/hook](gamemode/libraries/hook/README.md), [libraries/notif](gamemode/libraries/notif/README.md))
