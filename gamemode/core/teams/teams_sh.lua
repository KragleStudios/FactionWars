fw.team.list = fw.team.list or {}
fw.team.factionAgendas = fw.team.factionAgendas or {}

-- meta table for a team
local team_mt = {
	getStringID = function(self)
		return self.stringID
	end,
	getModels = function(self)
		return self.models
	end,
	getWeapons = function(self)
		return self.weapons 
	end,
	getID = function(self)
		return self.index
	end,
	getPlayers = function(self)
		return team.GetPlayers(self.index) 
	end,
	addPlayer = function(self, pref_mdoel, forced)
		fw.team.playerChangeTeam(ply, self.index, pref_model, forced)
	end
}
team_mt.__index = team_mt

-- fw.team.register - Registers a new team to the system
-- @param name:string - the name of the team, ie: "Civilian", "Police Officer"
-- @param tbl:tbl - the table data of the new team
-- @ret a meta object of the new team assigned to the variable in the configuration
function fw.team.register(name, tbl) 
	-- DO CHECKS FOR TEAM CORRECT - TODO: finish
	assert(tbl.model or tbl.models, "must provide model or models")
	assert(tbl.stringID, "must provide stringID")
	assert(tbl.salary, "a salary must be provided!")

	local index = table.insert(fw.team.list, tbl)

	-- setup required properties
	tbl.name = name
	tbl.index = index
	tbl.color = tbl.color or Color(0, 155, 0)
	tbl.players = {}
	tbl.weapons = tbl.weapons or {}
	tbl.models = tbl.models or {tbl.model}
	tbl.election = tbl.election or false

	tbl.command = 'fw_job_' .. tbl.stringID

	-- set meta table and create the team
	setmetatable(tbl, team_mt)
	team.SetUp(tbl.index, name, tbl.color)

	if SERVER then
		concommand.Add('fw_team_' .. tbl.command, function(pl, cmd, args)
			if args[1] then -- preferred model is the first argument
				fw.team.setPreferredModel(tbl.index, pl, args[1])
			end

			self:addPlayer(nil, nil)
		end)
	end

	return tbl
end

concommand.Add("test", function()
	PrintTable(TEAM_CIVILIAN:getPlayers())
end)


function fw.team.getByIndex(index)
	return fw.team.list[index]
end

-- fw.team.getByStringId - Gets a team's data by the string used, "civilian", "police_officer"
-- @param team_textID:string - the string_id found in the team configuration
-- @ret the table team
function fw.team.getByStringID(id)
	for k,v in ipairs(fw.team.list) do -- todo: optimize this
		if (v.stringID == id) then
			return v
		end
	end

	error("FAILED TO FIND TEAM")
end

-- handles the ability of whether or not a player can join a team
fw.hook.Add("CanPlayerJoinTeam", "CanJoinTeam", function(ply, targ_team)
	local t = fw.team.list[targ_team]
	if (not t) then 
		return false 
	end
	
	
	-- enforce t.max players
	if t.max and #t:getPlayers() > t.max then 
		return false 
	end

	-- can't join a team you're already on
	if (ply:Team() == targ_team) then 
		return false 
	end

	-- SUPPORT FOR FACTION ONLY JOBS
	if ((t.factionOnly and not t.faction) and not ply:getFaction()) then 
		return false
	end 
	-- notify incorrect faction
	if ((t.factionOnly and t.faction) and (ply:getFaction() != t.faction)) then
		return false
	end

	local canjoin = t.canJoin
	if canjoin then
		if (istable(canjoin)) then
			for k,v in ipairs(canjoin) do
				if (ply:Team() == v) then
					return true
				end
			end
		else
			return canjoin(t, ply)
		end
	else
		return true
	end
end)

-- playerChangeTeam - handles player team switching
-- @param ply:player object - the player object switching teams
-- @param targ_team:int - the index of the team in the table
-- @param pref_model:string - the model selected on the switch team screen is sent here
-- @param optional forced:bool - should we ignore canjoin conditions?
-- @ret nothing
function fw.team.playerChangeTeam(ply, targ_team, pref_model, forced)
	local canjoin, message = hook.Call("CanPlayerJoinTeam", GAMEMODE, ply, targ_team)
	if (not forced and not canjoin) then
		-- TODO: notify can't join team
		return false 
	end
	local t = fw.team.list[targ_team]
	if not t then
		-- TODO: notify player the team doesn't exist
		fw.print("no such team! " .. targ_team)
		return false 
	end

	-- find a good pref_model
	if not pref_model then
		pref_model = ply:GetFWData().preferred_models and ply:GetFWData().preferred_models[t.stringID] or table.Random(t.models)
	end

	-- set the data
	if (SERVER) then

		if (t.election) then
			local players = player.GetAll()

			if (t.factionOnly) then
				local faction = ply:getFaction()
				players = fw.team.getFactionPlayers(faction) or players
			end

			local job_title = t.name or "Nil"

			fw.vote.createNew("Job Vote", ply:Nick().." for ".. job_title, players, 
				function(decision)

				--make sure another player hasn't already got the job
				if (decision == "Yes" and t.max and #t:getPlayers() < t.max ) then
					for k,v in pairs(players) do
						v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Elections]: ", Color(255, 255, 255), ply:Nick(), " has won the election for ", job_title)

						ply:GetFWData().team = targ_team 

						ply:SetTeam(targ_team)
						if not ply:GetFWData().preferred_models then
							ply:GetFWData().preferred_models = {}
						end
						ply:GetFWData().preferred_models[t.stringID] = pref_model
						ply:GetFWData().pref_model = pref_model

						-- TODO: NOTIFY PLAYER CHANGED TEAM
						ply:Spawn()

						--if the player is changing FROM a boss team, remove them based on the player's faction
						local old_team = ply:GetFWData().team or TEAM_CIVILIAN:getID()
						local old_t = fw.team.list[old_team]
						if (old_t and old_t.boss) then
							fw.team.factions[ply:getFaction()].boss = nil

							net.Start("updateBossClientSide")
								net.WriteBool(false)
								net.WriteEntity(ply)
							net.Broadcast()
						end

						if (t.boss) then
							fw.team.factions[ply:getFaction()].boss = ply

							net.Start("updateBossClientSide")
								net.WriteBool(true)
								net.WriteEntity(ply)
							net.Broadcast()
						end
					end
				else
					for k,v in pairs(players) do
						v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Elections]: ", Color(255, 255, 255), ply:Nick(), " has LOST the election for ", job_title)
					end

					return
				end
			end, "Yes", "No", 15)

			return
		end

		ply:GetFWData().team = targ_team 

		ply:SetTeam(targ_team)
		if not ply:GetFWData().preferred_models then
			ply:GetFWData().preferred_models = {}
		end
		ply:GetFWData().preferred_models[t.stringID] = pref_model
		ply:GetFWData().pref_model = pref_model

		-- TODO: NOTIFY PLAYER CHANGED TEAM
		ply:Spawn()

		--if the player is changing FROM a boss team, remove them based on the player's faction
		local old_team = ply:GetFWData().team or TEAM_CIVILIAN:getID()
		local old_t = fw.team.list[old_team]
		if (old_t and old_t.boss) then
			fw.team.factions[ply:getFaction()].boss = nil

			net.Start("updateBossClientSide")
				net.WriteBool(false)
				net.WriteEntity(ply)
			net.Broadcast()
		end

		if (t.boss) then
			fw.team.factions[ply:getFaction()].boss = ply

			net.Start("updateBossClientSide")
				net.WriteBool(true)
				net.WriteEntity(ply)
			net.Broadcast()
		end
	end
end

if (CLIENT) then
	net.Receive("updateBossClientSide", function()
		local turningIntoBoss = net.ReadBool()
		local ply = net.ReadEntity()

		if (not turningIntoBoss) then
			fw.team.factions[ply:getFaction()].boss = nil
			return
		end
		--if the player is changing into a boss team, update the faction's info based on the player's faction
		fw.team.factions[ply:getFaction()].boss = ply
	end)
end

if (SERVER) then
	-- TODO: this should be a concommand.
	net.Receive("playerChangeTeam", function(l, client)
		local team_id = net.ReadInt(32)
		local model = net.ReadString()

		fw.team.playerChangeTeam(client, team_id, model)
	end)
end


local Player = FindMetaTable("Player")

function Player:getPrefModel()
	return ply:GetFWData().pref_model
end
--[[
if (CLIENT) then
	local colors = {
	head = Color(192, 57, 43, 255),
	back = Color(236, 240, 241, 255),
	text = Color(100, 100, 100, 255),
	btn = Color(52, 73, 94, 255),
	btn_hover = Color(44, 62, 80, 255),
	buy = Color(46, 204, 113, 255),
	buy_hover = Color(39, 174, 96, 255),
	cancel = Color(231, 76, 60, 255),
	cancel_hover = Color(192, 57, 43, 255),
	bar = Color(189, 195, 199, 255),
	barup = Color(127, 140, 141, 255),
	spawn = Color(230, 126, 34, 255),
	spawn_hover = Color(211, 84, 0, 255),
}

surface.CreateFont("head", {font = "coolvetica", size = 60, weight = 500})
surface.CreateFont("btn", {font = "coolvetica", size = 30, weight = 500})
surface.CreateFont("btnsmall", {font = "coolvetica", size = 20, weight = 500})

net.Receive("fw_agendaupdate", function()
	local agenda = net.ReadString()
	local faction = net.ReadInt(32)

	fw.team.factionAgendas[faction] = agenda
end)

hook.Add("HUDPaint", "LoadGUI", function()
	local tid = LocalPlayer():Team()
	local name = fw.team.list[tid].name
	draw.SimpleText(name, "head", 10, 10, colors.text)

	local faction = LocalPlayer():getFaction()
	local agenda_text = fw.team.factionAgendas[faction] or "No agenda currently set!" 
	draw.SimpleText(agenda_text, "btn", 10, 150, colors.text)

	local boss = fw.team.getBoss(LocalPlayer():getFaction())
	if (not isstring(boss)) then
		boss = "Boss: " ..boss:Nick()
	end
	draw.SimpleText(boss, "btn", ScrW() / 2, 0, colors.text)
end)



concommand.Add("teams", function()
	if (!LocalPlayer():Alive()) then return end

	local frame = vgui.Create("DFrame")
	frame:SetSize(520, 300)
	frame:Center()
	frame:SetTitle(" ")
	frame:SetDraggable(true)
	frame:MakePopup()

	local ds = vgui.Create("DScrollPanel", frame);
	ds:SetSize(500, 260)
	ds:SetPos(10, 30);
	ds:GetVBar().Paint = function() draw.RoundedBox(0, 0, 0, ds:GetVBar():GetWide(), ds:GetVBar():GetTall(), Color(255, 255, 255, 0)) end
	ds:GetVBar().btnUp.Paint = function() draw.RoundedBox(0, 0, 0, ds:GetVBar().btnUp:GetWide(), ds:GetVBar().btnUp:GetTall(), colors.barup) end
	ds:GetVBar().btnDown.Paint = function() draw.RoundedBox(0, 0, 0, ds:GetVBar().btnDown:GetWide(), ds:GetVBar().btnDown:GetTall(), colors.barup) end
	ds:GetVBar().btnGrip.Paint = function(w, h) draw.RoundedBox(0, 0, 0, ds:GetVBar().btnGrip:GetWide(), ds:GetVBar().btnGrip:GetTall(), colors.bar) end

	for k,v in ipairs(fw.team.list) do
		local pan = vgui.Create("DPanel", ds)
		pan:SetSize(490, 100)
		pan:SetPos(0, ((k - 1) * 110))

		local job = v.name or ""
		local models = v.models or {}
		local weapons = v.weapons or {}
		local canjoin = hook.Call("CanPlayerJoinTeam", GAMEMODE, LocalPlayer(), k)

		surface.SetFont("btn")
		local wide,high = surface.GetTextSize(job)

		function pan:Paint(w, h)
			local text = #v.players.. "/" ..v.max
			if (v.max == 0) then
				text = "Infinite"
			elseif (#v.players == v.max) then
				text = "Full"
			end
			draw.RoundedBox(0, 0, 0, w, h, colors.back)
			draw.SimpleText(job, "btn", wide + 5, 15, colors.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText("Joinable?: "..tostring(canjoin), "Default", 50, 30, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Weapons: "..table.concat(weapons), "Default", 50, 90, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
			draw.SimpleText(text, "btnsmall", w - 100, 90, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local join = vgui.Create("DButton", pan)
		join:SetSize(100, 50)
		join:SetPos(pan:GetWide() - 110, 5)
		join:SetText("Join Team")
		function join:DoClick()
			if (!canjoin) then return end
			
			net.Start("playerChangeTeam")
				net.WriteInt(k, 32)
				net.WriteString(models[1]) //to do model selection client side
			net.SendToServer()

			fw.team.playerChangeTeam(LocalPlayer(), k, models[1])// so we update info client side too

			frame:Close()
		end

		join:SetDisabled(!canjoin)
	end
end)

end]]--