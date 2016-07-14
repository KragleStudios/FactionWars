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

function GM:PlayerSpawnedProp(...)
	return fw.hook.Call("PlayerSpawnedProp", ...)
end

function GM:EntityTakeDamage(...)
	return fw.hook.Call("EntityTakeDamage", ...)
end
--
-- MODELE TEAMS
--

function GM:CanPlayerJoinTeam(...)
	return fw.hook.Call('CanPlayerJoinTeam', ...)
end

--
-- MODULE ITEMS
--

function GM:CanPlayerBuyItem(...)
	return fw.hook.Call('CanPlayerBuyItem', ...)
end