if SERVER then AddCSLuaFile() end

fw.notif = {}

fw.dep(CLIENT, 'fonts')

fw.include_cl 'notifications_cl.lua'
fw.include_sv 'notifications_sv.lua'