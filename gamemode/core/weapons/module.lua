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

concommand.Add("fw_reloadguns", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then pl:ChatPrint('insufficient privliages') return end
	fw.hook.GetTable("Initialize").LoadWeapons()
end)