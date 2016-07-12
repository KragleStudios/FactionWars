FACTION_POLICE = fw.team.registerFaction('Police', {
	stringID = 'f_police',
})

TEAM_POLICE = fw.team.register("Police Officer", {
	stringID = "t_police_officer",
	models = {"models/player/combine_soldier.mdl"},
	weapons = {"weapon_357"},
	faction = FACTION_POLICE,
	max = 4,
})

TEAM_CIVILIAN = fw.team.register("Civilian", {
	stringID = "t_civilian",
	models = {"models/player/mossman.mdl"},
	weapons = {},
	factionOnly = false,
	max = 0,
})

TEAM_DRUG = fw.team.register("Drug Dealer", {
	stringID = "t_drug_dealer",
	models = {"models/player/eli.mdl"},
	weapons = {},
	factionOnly = false,
	max = 4,
})

TEAM_MERC = fw.team.register("Mercenary", {
	stringID = "t_merc",
	models = {"models/player/odessa.mdl"},
	weapons = {},
	factionOnly = false,
	max = 4,
})

TEAM_GUN = fw.team.register("Gun Dealer", {
	stringID = "t_gun_dealer",
	models = {"models/player/monk.mdl"},
	weapons = {},
	factionOnly = true,
	max = 4,
})

TEAM_MEDIC = fw.team.register("Medic", {
	stringID = "t_medic",
	models = {"models/player/kleiner.mdl"},
	weapons = {},
	factionOnly = true,
	max = 4,
})

TEAM_BOSS = fw.team.register("Boss", {
	stringID = "t_boss",
	models = {"models/player/breen.mdl"},
	weapons = {},
	factionOnly = true,
	max = 1,
})

TEAM_SOLDIER = fw.team.register("Soldier", {
	stringID = "soldier",
	models = {"models/player/barney.mdl"},
	weapons = {},
	factionOnly = true,
	max = 4,
})

if (SERVER) then
	-- TODO: make this configured in a text file with a chatcommand
	fw.team.registerSpawn("police_officer", Vector(384.719086, 712.536865, -29.674372), Angle(11.538577, 205.371857, 0.000000))
end
