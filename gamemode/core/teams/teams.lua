--
-- FACTIONS
--
FACTION_DEFAULT = fw.team.registerFaction('Common Wealth', {
	stringID = 'f_default',
	color = Color(255, 255, 255)
})

FACTION_GANGA = fw.team.registerFaction('Yakuza', {
	stringID = 'f_yakuza',
	color = Color(255, 25, 25)
})

FACTION_GANGB = fw.team.registerFaction('Aryan Brotherhook', {
	stringID = 'f_aryan',
	color = Color(25, 25, 255)
})

--
-- TEAMS/CLASSES
--
TEAM_BOSS = fw.team.register("Boss", {
	stringID = "t_boss",
	models = {"models/player/gman_high.mdl"},
	weapons = {"weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	faction = {FACTION_GANGA, FACTION_GANGB},
	salary = 55,
	max = 1,
	boss = true,
	election = true
})

TEAM_BMD = fw.team.register("Black Market Dealer", {
	stringID = "t_bmd",
	models = {"models/player/eli.mdl"},
	weapons = {"weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	faction = {FACTION_GANGA, FACTION_GANGB},
	salary = 40,
	max = 2,
})

TEAM_MAYOR = fw.team.register("Mayor", {
	stringID = "t_mayor",
	models = {"models/player/breen.mdl"},
	weapons = {"weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	faction = FACTION_DEFAULT,
	salary = 55,
	max = 1,
	boss = true,
	election = true
})

TEAM_CIVILIAN = fw.team.register("Civilian", {
	stringID = "t_civilian",
	models = {
			"models/player/Group02/male_02.mdl",
			"models/player/Group02/male_04.mdl",
			"models/player/Group02/male_06.mdl",

			"models/player/Group01/female_06.mdl",
			"models/player/Group01/female_01.mdl"},
	weapons = {"weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	salary = 30,
	max = 0
})

TEAM_DRUG = fw.team.register("Drug Dealer", {
	stringID = "t_drug_dealer",
	models = {"models/player/leet.mdl"},
	weapons = {"weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	salary = 40,
	max = 4,
})

TEAM_MERC = fw.team.register("Mercenary", {
	stringID = "t_merc",
	models = {"models/player/guerilla.mdl"},
	weapons = {"weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	salary = 4,
	max = 4,
})

TEAM_GUN = fw.team.register("Gun Dealer", {
	stringID = "t_gun_dealer",
	models = {"models/player/monk.mdl"},
	weapons = {"weapon_fists"},
	salary = 45,
	max = 4,
})

TEAM_MEDIC = fw.team.register("Medic", {
	stringID = "t_medic",
	models = {
		"models/player/Group03m/male_02.mdl",
		"models/player/Group03m/male_04.mdl",
		"models/player/Group03m/female_02.mdl",
		"models/player/Group03m/female_06.mdl"
	},
	weapons = {"weapon_medkit", "weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	faction = {FACTION_GANGA, FACTION_GANGB},
	salary = 45,
	max = 4,
})

TEAM_SOLDIER = fw.team.register("Soldier", {
	stringID = "soldier",
	models = {"models/player/Group03/male_02.mdl",
		"models/player/Group03/male_03.mdl",
		"models/player/Group03/male_07.mdl",
		"models/player/Group03/male_08.mdl"},
	weapons = {"weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	faction = {FACTION_GANGA, FACTION_GANGB},
	salary = 45,
	max = 4,
})

if (SERVER) then
	-- TODO: make this configured in a text file with a chatcommand
	fw.team.registerSpawn("police_officer", Vector(384.719086, 712.536865, -29.674372), Angle(11.538577, 205.371857, 0.000000))
end


TEAM_POLICE = fw.team.register("Police Officer", {
	stringID = "t_police_officer",
	models = {"models/player/urban.mdl"},
	weapons = {"weapon_357", "weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	faction = FACTION_DEFAULT,
	salary = 50,
	max = 8,
})

TEAM_POLICE_CHIEF = fw.team.register("Police Chief", {
	stringID = "t_police_officer_chief",
	models = {"models/player/riot.mdl"},
	weapons = {"weapon_fists", "gmod_tool", "gmod_camera", "weapon_physgun", "weapon_physcannon", "fw_repairtool"},
	faction = FACTION_DEFAULT,
	salary = 55,
	max = 1,
	canJoin = function(pc_team, ply)
		return ply:Team() == TEAM_POLICE
	end,
})