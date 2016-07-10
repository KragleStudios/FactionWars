TEAM_POLICE = fw.team.register("Police Officer", {
	stringID = "police_officer",
	models = {"models/player/combine_soldier.mdl"},
	weapons = {"weapon_357"},
	factionOnly = false,
	//OPTIONAL
	//faction = "FACTION_COMMONWEALTH",
	max = 1,
	canJoin = function(team, ply) return true end,
	onSpawn = function(team, ply) end,
	onDeath = function(team, ply) end,
})

TEAM_CIVILIAN = fw.team.register("Civilian", {
	stringID = "civilian",
	models = {"models/player/mossman.mdl"},
	weapons = {},
	factionOnly = false,
	max = 0,
	canJoin = function(team, ply) return true end,
	onSpawn = function(team, ply) end,
	onDeath = function(team, ply) end,
})

TEAM_DRUG = fw.team.register("Drug Dealer", {
	stringID = "drug_dealer",
	models = {"models/player/eli.mdl"},
	weapons = {},
	factionOnly = false,
	max = 1,
	canJoin = function(team, ply) return true end,
	onSpawn = function(team, ply) end,
	onDeath = function(team, ply) end,
})

TEAM_MERC = fw.team.register("Mercenary", {
	stringID = "merc",
	models = {"models/player/odessa.mdl"},
	weapons = {},
	factionOnly = false,
	max = 1,
	canJoin = function(team, ply) return true end,
	onSpawn = function(team, ply) end,
	onDeath = function(team, ply) end,
})




TEAM_GUN = fw.team.register("Gun Dealer", {
	stringID = "gun_dealer",
	models = {"models/player/monk.mdl"},
	weapons = {},
	factionOnly = true,
	max = 1,
	canJoin = function(team, ply) return true end,
	onSpawn = function(team, ply) end,
	onDeath = function(team, ply) end,
})

TEAM_MEDIC = fw.team.register("Medic", {
	stringID = "medic",
	models = {"models/player/kleiner.mdl"},
	weapons = {},
	factionOnly = true,
	max = 1,
	canJoin = function(team, ply) return true end,
	onSpawn = function(team, ply) end,
	onDeath = function(team, ply) end,
})

TEAM_BOSS = fw.team.register("Boss", {
	stringID = "boss",
	models = {"models/player/breen.mdl"},
	weapons = {},
	factionOnly = true,
	max = 1,
	canJoin = function(team, ply) return true end,
	onSpawn = function(team, ply) end,
	onDeath = function(team, ply) end,
})

TEAM_SOLDIER = fw.team.register("Soldier", {
	stringID = "soldier",
	models = {"models/player/barney.mdl"},
	weapons = {},
	factionOnly = true,
	max = 1,
	canJoin = function(team, ply) return true end,
	onSpawn = function(team, ply) end,
	onDeath = function(team, ply) end,
})

if (SERVER) then
	fw.team.registerSpawn("police_officer", Vector(384.719086, 712.536865, -29.674372), Angle(11.538577, 205.371857, 0.000000))
end