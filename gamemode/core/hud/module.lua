if SERVER then AddCSLuaFile() end

require 'sty'

fw.dep(CLIENT, 'hook')
fw.dep(CLIENT, 'teams')

fw.include_cl 'hud_cl.lua'