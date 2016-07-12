-- create the exported table
fw.chat = fw.chat or {}

-- load internal dependencies
fw.dep(SHARED, 'hook')

-- proper include system
fw.include_sv 'chat_sv.lua'