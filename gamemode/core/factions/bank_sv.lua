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

	fw.faction.bank[fac].currency = fw.faction.bank[fac].currency + amt

	for k,v in pairs(fw.team.getFactionPlayers(fac)) do
		v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), ply:Nick(), " has deposited $", amt, " into the faction bank! New Amount: $", fw.faction.bank[fac].currency)
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

	if (fw.faction.bank[fac].currency - amt < 0) then
		ply:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "The faction can't afford this withdraw!")
		return
	end
	
	fw.vote.createNew("Withdraw Query", ply:Nick().." wants to withdraw: $"..amt, players,
		function(decision)
			if (decision == "Yes") then
				ply:addMoney(amt)
				fw.faction.bank[fac].currency = fw.faction.bank[fac].currency - amt

				for k,v in pairs(fw.team.getFactionPlayers(fac)) do
					v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), ply:Nick(), " has withdrawn $", amt, " from the faction bank! New Amount: $", fw.faction.bank[fac].currency)
				end	
			end

		end, "Yes", "No", 15)
end

function fw.faction.bank.payroll(faction)
	local fac_players = fw.team.getFactionPlayers(faction)
	local useFacBank = fw.config.useFactionBank

	for k,v in pairs(fac_players) do
		local team = fw.team.list[v:Team()]
		if (not team) then continue end

		local salary = team.salary

		--use the faction bank? okay can the faction afford it?
		if (useFacBank and (fw.faction.bank[fac].currency - salary > 0)) then
			fw.faction.bank[fac].currency = fw.faction.bank[fac] - salary

			v:addMoney(salary)
		else
			v:addMoney(salary)
		end

		v:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Faction]: ", Color(255, 255, 255), "Payroll has been issued! Your salary: $", salary)
	end
end

hook.Add("Initialize", "IssueFactionPayroll", function()
	local payroll = fw.config.payrollTime or 60

	timer.Create("FunctionPayroll", payroll, 0, function() 
		for k,v in pairs(fw.team.factions) do
			fw.faction.bank.payroll(k)
		end

		for k,v in pairs(player.GetAll()) do
			if (v:inFaction()) then continue end

			local team = fw.team.list[v:Team()]
			if (not team) then continue end

			local salary = team.salary
			v:addMoney(salary)
		end
	end)
end)