if SERVER then
	AddCSLuaFile()
end

fw.dep(SHARED, 'hook')

fw.weapons = fw.weapons or {}

fw.weapons.SLOT_PISTOL = 1
fw.weapons.SLOT_SMG = 2
fw.weapons.SLOT_SHOTGUN = 3
fw.weapons.SLOT_RIFLE = 4

fw.include_sh 'weapons_sh.lua'
fw.include_sh 'weapons.lua'
