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
end)

--[[
fw.hook.Add("InitPostEntity", "UpdateTeamGroupsCL", function()
	local tid = LocalPlayer():Team()
	table.insert(fw.team.list[tid].players, LocalPlayer())
end)]]--

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
