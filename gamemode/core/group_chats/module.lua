if SERVER then
	AddCSLuaFile()
end

-- create the exported table
fw.group = fw.group or {}
fw.group.chats = fw.group.chats or {}
fw.group.voice = fw.group.voice or {}

-- load internal dependencies
fw.dep(SHARED, 'notif')
fw.dep(SERVER, 'chat_commands')
fw.dep(SHARED, 'hook')
fw.dep(SHARED, 'teams')
fw.dep(SHARED, 'utils')

-- proper include system
fw.include_sh 'groups_sh.lua'
fw.include_sv 'groups_sv.lua'

-- should really be placed somewhere else
fw.include_sh 'groups.lua'
