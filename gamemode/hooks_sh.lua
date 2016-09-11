function GM:Initialize(...)
	return fw.hook.Call("Initialize", ...)
end

function GM:ShutDown(...)
	return fw.hook.Call('ShutDown', ...)
end

function GM:PlayerSpawn(...)
	return fw.hook.Call("PlayerSpawn", ...)
end

function GM:PlayerInitialSpawn(...)
	return fw.hook.Call("PlayerInitialSpawn", ...)
end

function GM:PlayerDeath(...)
	return fw.hook.Call("PlayerDeath", ...)
end

function GM:PlayerLoadout(...)
	return fw.hook.Call("PlayerLoadout", ...)
end

function GM:PlayerSetModel(...)
	return fw.hook.Call("PlayerSetModel", ...)
end

function GM:HUDPaint(...)
	return fw.hook.Call("HUDPaint", ...)
end

function GM:HUDShouldDraw(...)
	if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().HUDShouldDraw then
		local res = LocalPlayer():GetActiveWeapon():HUDShouldDraw(...)
		if res ~= nil then
			return res
		end
	end

	return fw.hook.Call("HUDShouldDraw", ...) ~= false
end

function GM:CalcView(...)
	return fw.hook.Call("CalcView", ...)
end

function GM:OnEntityCreated(...)
	return fw.hook.Call("OnEntityCreated", ...)
end

function GM:PlayerDisconnected(...)
	return fw.hook.Call("PlayerDisconnected", ...)
end

function GM:InitPostEntity(...)
	return fw.hook.Call("InitPostEntity", ...)
end

function GM:PlayerSay(pl, text, ...)
	print(pl, text, ...)
	local message = fw.hook.Call('PlayerSay', pl, text, ...)
	print(type(message))
	print("PlayerSay: " .. tostring(message))
	return message
end

function GM:OnPlayerChat(player, text, bTeamOnly, bPlayerIsDead)
	local stop = fw.hook.Call("OnPlayerChat", ply, text, teamChat, isDead)
	if stop ~= nil then return end

	local tab = {}

	if ( bPlayerIsDead ) then
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
	end

	if ( bTeamOnly ) then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "( TEAM ) " )
	end

	if ( IsValid( player ) ) then
		local fac = fw.team.factions[ player:getFaction() ]
		local fname = fac:getName()
		local fcolor = fac:getColor()
		table.insert( tab, fcolor )
		table.insert( tab, '[' .. string.sub(fname, 1, 1) .. ']')
		table.insert( tab, player )
	else
		table.insert( tab, "Console" )
	end

	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": " .. text )

	chat.AddText(unpack(tab))

	return true
end

function GM:ScoreboardShow(...)
	return fw.hook.Call("ScoreboardShow", ...)
end

function GM:ScoreboardHide(...)
	return fw.hook.Call("ScoreboardHide", ...)
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

	local ret = fw.hook.Call("OnReloaded", ...)

	fw.hook.Call("Initialize")

	for k, pl in ipairs(player.GetAll()) do
		fw.hook.Call("PlayerInitialSpawn", pl)
		fw.hook.Call("PlayerSpawn", pl)
	end

	_REFRESH = nil

	return ret
end

function GM:DoPlayerDeath(...)
	return fw.hook.Call("DoPlayerDeath", ...)
end

function GM:PlayerCanHearPlayersVoice(...)
	return fw.hook.Call("PlayerCanHearPlayersVoice", ...)
end

function GM:PlayerCanSeePlayersChat(text, teamonly, listener, speaker)
	return listener:GetPos():DistToSqr(speaker:GetPos()) < 500 * 500
end

function GM:RenderScreenspaceEffects(...)
	return fw.hook.Call("RenderScreenspaceEffects", ...)
end

function GM:EntityRemoved(...)
	return fw.hook.Call("EntityRemoved", ...)
end

function GM:GetFallDamage( ply, speed )
	return speed / 7
end

function GM:PreRender(...)
	return fw.hook.Call("PreRender", ...)
end

function GM:PostDrawOpaqueRenderables(...)
	return fw.hook.Call("PostDrawOpaqueRenderables", ...)
end

function GM:PostDrawTranslucentRenderables(...)
	return fw.hook.Call("PostDrawTranslucentRenderables", ...)
end

function GM:PlayerSwitchWeapon(...)
	return fw.hook.Call("PlayerSwitchWeapon", ...)
end

function GM:PlayerSpawnSENT(pl)
	return pl:IsSuperAdmin()
end

function GM:PlayerSpawnSWEP()
	return pl:IsSuperAdmin()
end

function GM:PlayerGiveSWEP()
	return pl:IsSuperAdmin()
end

function GM:PlayerSpawnNPC()
	return pl:IsSuperAdmin()
end


--
-- MODELE TEAMS
--
function GM:CanPlayerJoinTeam(...)
	return fw.hook.Call("CanPlayerJoinTeam", ...)
end

function GM:PlayerChangedTeam(teamFrom, teamTo)
	return fw.hook.Call("PlayerChangedTeam", teamFrom, teamTo)
end

function GM:PlayerLeftFaction(factionId)
	return fw.hook.Call("PlayerLeftFaction", factionId)
end

function GM:PlayerJoinedFaction(factionId)
	return fw.hook.Call("PlayerJoinedFaction", factionId)
end

function GM:PlayerCanJoinFaction(...)
	return fw.hook.Call("PlayerCanJoinFaction", ...)
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
	return fw.hook.Call("CanPlayerBuyItem", ...)
end

function GM:PlayerEnteredZone(...)
	return fw.hook.Call("PlayerEnteredZone", ...)
end

function GM:AddToolMenuTabs(...)
	return fw.hook.Call("AddToolMenuTabs", ...)
end

function GM:PhysgunPickup(...)
	return fw.hook.Call("PhysgunPickup", ...)
end

function GM:CanTool(...)
	return fw.hook.Call("CanTool", ...)
end
