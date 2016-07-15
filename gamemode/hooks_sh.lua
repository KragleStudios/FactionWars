function GM:Initialize(...)
	return fw.hook.Call('Initialize', ...)
end

function GM:PlayerSpawn(...)
	return fw.hook.Call('PlayerSpawn', ...)
end

function GM:PlayerInitialSpawn(...)
	return fw.hook.Call('PlayerInitialSpawn', ...)
end

function GM:PlayerDeath(...)
	return fw.hook.Call('PlayerDeath', ...)
end

function GM:PlayerLoadout(...)
	return fw.hook.Call('PlayerLoadout', ...)
end

function GM:PlayerSetModel(...)
	return fw.hook.Call('PlayerSetModel', ...)
end

function GM:HUDPaint(...)
	return fw.hook.Call('HUDPaint', ...)
end

function GM:HUDShouldDraw(...)
	return fw.hook.Call('HUDShouldDraw', ...) ~= false 
end

function GM:OnEntityCreated(...)
	return fw.hook.Call('OnEntityCreated', ...)
end

function GM:PlayerDisconnected(...)
	return fw.hook.Call('PlayerDisconnected', ...)
end

function GM:InitPostEntity(...)
	return fw.hook.Call('InitPostEntity', ...)
end

function GM:PlayerSay(...)
	return fw.hook.Call('PlayerSay', ...)
end

function GM:Initialize(...)
	return fw.hook.Call("Initialize", ...)
end

function GM:ScoreboardShow(...)
	return fw.hook.Call('ScoreboardShow', ...)
end

function GM:ScoreboardHide(...)
	return fw.hook.Call('ScoreboardHide', ...)
end

function GM:PlayerSpawnedProp(...)
	return fw.hook.Call("PlayerSpawnedProp", ...)
end

function GM:EntityTakeDamage(...)
	return fw.hook.Call("EntityTakeDamage", ...)
end

function GM:StartChat(...)
	return fw.hook.Call("StartChat", ...)
end

function GM:Think(...)
	return fw.hook.Call("Think", ...)
end

function GM:EntityRemoved(...)
	return fw.hook.Call("EntityRemoved", ...)
end
--
-- MODELE TEAMS
--
function GM:CanPlayerJoinTeam(...)
	return fw.hook.Call('CanPlayerJoinTeam', ...)
end

function GM:PlayerChangedTeam(teamFrom, teamTo)
	return fw.hook.Call('PlayerChangedTeam', teamFrom, teamTo)
end

function GM:PlayerLeftFaction(factionId)
	return fw.hook.Call('PlayerLeftFaction', factionId)
end

function GM:PlayerJoinedFaction(factionId)
	return fw.hook.Call('PlayerJoinedFaction', factionId)
end

--
-- MODULE ITEMS
--

function GM:CanPlayerBuyItem(...)
	return fw.hook.Call('CanPlayerBuyItem', ...)
end
