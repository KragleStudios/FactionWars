if SERVER then AddCSLuaFile() end

require 'sty'

fw.dep(SERVER, 'hook')

fw.include_cl 'death_cl.lua'
fw.include_sv 'death_sv.lua'
