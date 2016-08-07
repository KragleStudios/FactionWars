if SERVER then
	AddCSLuaFile()
end

fw.dep(SHARED, 'hook')

fw.include_sh 'egg_sh.lua'