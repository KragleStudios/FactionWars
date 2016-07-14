function fw.faction.bank.deposit(ply, amt)
	local fac = ply:getFaction()
	if (not fac) then 
		ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "wat. u shouldn't be able to do dis :v")
		return 
	end
	
	if (not ply:canAfford(amt)) then
		ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "You can't afford to depost this much!")
		return
	end

	fw.faction.bank[fac].money = fw.faction.bank[fac].money + amt

	for k,v in pairs(fw.team.getFactionPlayers(fac)) do
		v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), ply:Nick(), " has deposited $", amt, " into the faction bank! New Amount: $"..fw.faction.bank[fac].money)
	end	
end

function fw.faction.bank.withdraw(ply, amt)
	local fac = ply:getFaction()
	if (not fac) then 
		ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "wat. u shouldn't be able to do dis :v")
		return 
	end

	--this boss is the only one who can approve withdraws, however if there isn't one, we need to ask the other members. DEMOCRACY! :D
	local boss = fw.team.getBoss(fac)
	local players = fw.team.getFactionPlayers(fac)
	
	if (not isstring(boss)) then
		players = boss
	end

	if (fw.faction.bank[fac].money - amt < 0) then
		ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "The faction can't afford this withdraw!")
		return
	end
	
	fw.vote.createNew("Withdraw Query", ply:Nick().." wants to withdraw: $"..amt, players,
		function(decision)
			if (decision == "Yes") then
				ply:addMoney(amt)
				fw.faction.bank[fac].money = fw.faction.bank[fac].money - amt

				for k,v in pairs(fw.team.getFactionPlayers(fac)) do
					v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), ply:Nick(), " has withdrawn $", amt, " from the faction bank! New Amount: $"..fw.faction.bank[fac].money)
				end	
			end

		end, "Yes", "No", 15)
end

function fw.faction.bank.save(faction)
	local bank = fw.faction.bank or {money = 0, items = {}}

	if (not file.Exists("faction_data", "DATA")) then
		file.CreateDir("faction_data")
	end

	local path = "faction_data/faction_"..faction..".txt"
	local tbl = {money = bank.money, items = bank.items}
	tbl = spon.encode(tbl)

	file.Write(path, tbl)
end

--[[
		Structure: 
		tbl = {
			money = amount,
			items = {
				[item_stringID] = amount
			}
		}
	]]--
function fw.faction.bank.load(faction)
	local tbl = {money = 0, items = {}}
	local path = "faction_data/faction_"..faction..".txt"

	fw.faction.bank[faction] = tbl

	if (file.Exists(path, "DATA")) then
		local table = file.Read(path, "DATA")
		table = spon.decode(table)

		if (table) then tbl = table end
	end

	fw.faction.bank[faction].money = tbl.money
	fw.faction.bank[faction].items    = tbl.items
end

function fw.faction.bank.payroll(faction)
	local fac_players = fw.team.getFactionPlayers(faction)
	local useFacBank = fw.config.useFactionBank

	for k,v in pairs(fac_players) do
		local team = fw.team.list[v:Team()]
		if (not team) then continue end

		local salary = team.salary

		--use the faction bank? okay can the faction afford it?
		if (useFacBank and (fw.faction.bank[fac].money - salary > 0)) then
			fw.faction.bank[fac].money = fw.faction.bank[fac] - salary

			v:addMoney(salary)
		else
			v:addMoney(salary)
		end

		local text = "Payroll has been issued! Your salary: $"..salary
		v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), text)
	end
end

fw.hook.Add("Initialize", "IssueFactionPayroll", function()
	local payroll = fw.config.payrollTime or 60
	
	for k,v in pairs(fw.team.factions) do
		fw.faction.bank.load(k)
	end

	timer.Create("FunctionPayroll", payroll, 0, function() 
		for k,v in pairs(fw.team.factions) do
			fw.faction.bank.payroll(k)
			fw.faction.bank.save(k)
		end

		for k,v in pairs(player.GetAll()) do
			if (v:inFaction()) then continue end

			local team = fw.team.list[v:Team()]
			if (not team) then continue end

			local salary = team.salary
			v:addMoney(salary)

			local text = "Payroll has been issued! Your salary: $"..salary

			v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), text)
		end
	end)
end)