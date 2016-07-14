if SERVER then AddCSLuaFile() end

require 'sty'

fw.dep(CLIENT, 'hook')

fw.include_cl 'chat_cl.lua'
