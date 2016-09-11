if SERVER then
	AddCSLuaFile()
end

fw.dep(SHARED, 'hook')
fw.dep(CLIENT, 'ui')

fw.include_cl "help_cl.lua"
fw.include_sv "help_sv.lua"