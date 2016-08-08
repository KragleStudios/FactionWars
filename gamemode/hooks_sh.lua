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
	if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().HUDShouldDraw then
		local res = LocalPlayer():GetActiveWeapon():HUDShouldDraw(...)
		if res ~= nil then
			return res
		end
	end

	return fw.hook.Call('HUDShouldDraw', ...) ~= false
end

function GM:CalcView(...)
	return fw.hook.Call("CalcView", ...)
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

function GM:PlayerSay(pl, text, ...)
	local res = fw.hook.Call('PlayerSay', pl, text, ...)
	if res == nil then return text end
	return ""
end

function GM:OnPlayerChat(...)
	return fw.hook.Call('OnPlayerChat', ...)
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

function GM:GravGunPunt(...)
	local ret = fw.hook.Call("GravGunPunt", ...)
	if ret == nil then
		return false
	end
	return ret
end

function GM:ShouldCollide(...)
	return fw.hook.Call("ShouldCollide", ...)
end


function GM:Think(...)
	return fw.hook.Call("Think", ...)
end

function GM:OnReloaded(...)
	_REFRESH = true

	local ret = fw.hook.Call('OnReloaded', ...)

	fw.hook.Call('Initialize')

	for k, pl in ipairs(player.GetAll()) do
		fw.hook.Call('PlayerInitialSpawn', pl)
		fw.hook.Call('PlayerSpawn', pl)
	end

	_REFRESH = nil

	return ret
end

function GM:PlayerCanHearPlayersVoice(...)
	return fw.hook.Call("PlayerCanHearPlayersVoice", ...)
end

function GM:RenderScreenspaceEffects(...)
	return fw.hook.Call('RenderScreenspaceEffects', ...)
end

function GM:EntityRemoved(...)
	return fw.hook.Call("EntityRemoved", ...)
end

function GM:PreRender(...)
	return fw.hook.Call('PreRender', ...)
end

function GM:PostDrawOpaqueRenderables(...)
	return fw.hook.Call('PostDrawOpaqueRenderables', ...)
end

function GM:PostDrawTranslucentRenderables(...)
	return fw.hook.Call('PostDrawTranslucentRenderables', ...)
end

function GM:PlayerSwitchWeapon(...)
	return fw.hook.Call("PlayerSwitchWeapon", ...)
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

function GM:PlayerCanJoinFaction(...)
	return fw.hook.Call('PlayerCanJoinFaction', ...)
end

function GM:KeyPress(...)
	return fw.hook.Call("KeyPress", ...)
end

function GM:KeyRelease(...)
	return fw.hook.Call("KeyRelease", ...)
end
--
-- MODULE ITEMS
--

function GM:CanPlayerBuyItem(...)
	return fw.hook.Call('CanPlayerBuyItem', ...)
end

function GM:PlayerEnteredZone(...)
	return fw.hook.Call('PlayerEnteredZone', ...)
end
