if SERVER then
	AddCSLuaFile()
end

fw.dep(SHARED, 'hook')

fw.printers = fw.printers or {}

fw.include_sh 'printers_sh.lua'
fw.include_sh 'printers.lua'
