if SERVER then
	AddCSLuaFile()
end

fw.dep(SHARED, 'hook')
fw.dep(CLIENT, 'ui')

fw.include_cl "survey_cl.lua"
fw.include_sv "survey_sv.lua"