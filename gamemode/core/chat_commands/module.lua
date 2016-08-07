-- create the exported table
fw.chat = fw.chat or {}

-- load internal dependencies
fw.dep(SHARED, 'hook')
fw.dep(SHARED, 'utils')

-- proper include system
fw.include_sv 'chat_sv.lua'
fw.include_sv 'command_definitions_sv.lua'
