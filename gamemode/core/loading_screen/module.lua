if SERVER then
	AddCSLuaFile()
end

fw.dep(CLIENT, 'hook')
fw.dep(CLIENT, 'ui')

fw.include_cl "loading_cl.lua"