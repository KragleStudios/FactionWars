if SERVER then AddCSLuaFile() end

require 'sty'

fw.dep(CLIENT, 'hook')
fw.dep(CLIENT, 'teams')
fw.dep(CLIENT, 'zones')

fw.include_cl 'hud_cl.lua'
fw.include_cl 'entity_info_cl.lua'