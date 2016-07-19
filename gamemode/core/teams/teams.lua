--
-- FACTIONS
--
FACTION_POLICE = fw.team.registerFaction('Police', {
	stringID = 'f_police',
})

FACTION_GANGA = fw.team.registerFaction('Gang A', {
	stringID = 'f_gangA',
})

FACTION_GANGB = fw.team.registerFaction('Gang B', {
	stringID = 'f_gangB',
})

--
-- TEAMS/CLASSES
--
TEAM_BOSS = fw.team.register("Boss", {
	stringID = "t_boss",
	models = {"models/player/breen.mdl"},
	weapons = {"weapon_fists"},
	factionOnly = true,
	salary = 50,
	max = 1,
	boss = true,
	election = true
})


TEAM_CIVILIAN = fw.team.register("Civilian", {
	stringID = "t_civilian",
	models = {"models/player/mossman.mdl"},
	weapons = {"weapon_fists"},
	factionOnly = false,
	salary = 50,
})

TEAM_DRUG = fw.team.register("Drug Dealer", {
	stringID = "t_drug_dealer",
	models = {"models/player/eli.mdl"},
	weapons = {"weapon_fists"},
	factionOnly = false,
	election = true,--testing
	salary = 50,
	max = 4,
})

TEAM_MERC = fw.team.register("Mercenary", {
	stringID = "t_merc",
	models = {"models/player/odessa.mdl"},
	weapons = {"weapon_fists"},
	factionOnly = false,
	salary = 50,
	max = 4,
})

TEAM_GUN = fw.team.register("Gun Dealer", {
	stringID = "t_gun_dealer",
	models = {"models/player/monk.mdl"},
	weapons = {"weapon_fists"},
	factionOnly = true,
	salary = 50,
	max = 4,
})

TEAM_MEDIC = fw.team.register("Medic", {
	stringID = "t_medic",
	models = {"models/player/kleiner.mdl"},
	weapons = {"weapon_medkit", "weapon_fists"},
	factionOnly = true,
	salary = 50,
	max = 4,
})

TEAM_SOLDIER = fw.team.register("Soldier", {
	stringID = "soldier",
	models = {"models/player/barney.mdl"},
	weapons = {"weapon_fists"},
	factionOnly = true,
	salary = 50,
	max = 4,
})

if (SERVER) then
	-- TODO: make this configured in a text file with a chatcommand
	fw.team.registerSpawn("police_officer", Vector(384.719086, 712.536865, -29.674372), Angle(11.538577, 205.371857, 0.000000))
end


TEAM_POLICE = fw.team.register("Police Officer", {
	stringID = "t_police_officer",
	models = {"models/player/combine_soldier.mdl"},
	weapons = {"weapon_357", "weapon_fists"},
	factionOnly = false,
	faction = FACTION_POLICE,
	salary = 50,
	max = 4,
})

TEAM_POLICE_CHIEF = fw.team.register("Police Chief", {
	stringID = "t_police_officer_chief",
	models = {"models/player/combine_super_soldier.mdl"},
	weapons = {"weapon_fists"},
	factionOnly = true,
	faction = FACTION_POLICE,
	salary = 50,
	boss = true,
	max = 1,
	canJoin = function(pc_team, ply)
		return ply:GetFWData().team == TEAM_POLICE:getID()
	end,
})