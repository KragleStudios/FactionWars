function fw.team.factionDeposit(ply, amt)
	local fac = ply:getFaction()
	if (not ply:inFaction() or ply:getFaction() == FACTION_DEFAULT) then
		return
	end

	if (not ply:canAfford(amt)) then
		ply:FWChatPrint("You can't afford to depost this much!")
		return
	end

	ndoc.table.fwFactions[fac].money = ndoc.table.fwFactions[fac].money + amt

	local str = ply:Nick().." has deposited $"..string.Comma(amt).. " into the faction bank! New Amount: $"..string.Comma(ndoc.table.fwFactions[fac].money)
	for k,v in pairs(fw.team.getFactionPlayers(fac)) do
		v:FWChatPrint(str)
	end
end

function fw.team.factionWithdraw(ply, amt)
	local fac = ply:getFaction()
	if (not ply:inFaction() or ply:getFaction() == FACTION_DEFAULT) then
		return
	end

	--this boss is the only one who can approve withdraws, however if there isn't one, we need to ask the other members. DEMOCRACY! :D
	local players = fw.team.getBoss(fac) or fw.team.getFactionPlayers(fac)
	if (not fw.team.getBoss(fac) and #players < 5) then
		ply:FWChatPrintError("There must be at least 5 players in the faction to approve a withdraw!")
		return
	end

	--only allow 25% of the funds to be taken out at a time
	if (amt > (ndoc.table.fwFactions[fac].money * .25)) then
		ply:FWChatPrintError("You can only take out 25% of the funds at a time!")
		return
	end

	if (ndoc.table.fwFactions[fac].money - amt < 0) then
		ply:FWChatPrint("The faction can't afford this withdraw!")
		return
	end

	fw.vote.createNew("Withdraw Query", ply:Nick().." wants to withdraw: $"..amt, players,
		function(decision)
			if (decision) then
				ply:addMoney(amt)
				ndoc.table.fwFactions[fac].money = ndoc.table.fwFactions[fac].money - amt

				local str = ply:Nick().." has withdrawn $"..string.Comma(amt).." from the faction bank! New Amount: $"..string.Comma(ndoc.table.fwFactions[fac].money)
				for k,v in pairs(fw.team.getFactionPlayers(fac)) do
					v:FWChatPrint(str)
				end
			else
				fw.hud.pushNotification(ply, "Faction Bank", "The boss has rejected your withdrawl proposal!")
			end

		end, "Yes", "No", 15)
end

fw.chat.addCMD("faction_withdraw", "Withdraw query from the faction bank", function(ply, amt)
	fw.team.factionWithdraw(ply, amt)
end):addParam("amount", "money")

fw.chat.addCMD("faction_deposit", "Deposit money into the faction bank!", function(ply, amt)
	fw.team.factionDeposit(ply, amt)
end):addParam("amount", "number")

function fw.team.saveFactionBanks()
	local masterTable = {}
	for k,v in ndoc.pairs(ndoc.table.fwFactions) do
		masterTable[v.stringID] = v.money
	end

	if (not file.Exists("faction_data", "DATA")) then
		file.CreateDir("faction_data")
	end

	local path = "faction_data/faction_banks.txt"
	masterTable = spon.encode(masterTable)

	file.Write(path, masterTable)
end

--[[
		Structure:
		tbl = {
			money = amount,
		}
	]]--
function fw.team.loadFactionBanks()
	local path = "faction_data/faction_bank.txt"

	if (file.Exists(path, "DATA")) then
		local table = file.Read(path, "DATA")
		table = spon.decode(table)

		for k,v in ndoc.pairs(ndoc.table.fwFactions) do
			if (table[v.stringID]) then
				ndoc.table.fwFactions[k].money = table[v.stringID]
			end
		end
	end
end

function fw.team.factionPayroll(faction)
	local fac_players = fw.team.getFactionPlayers(faction)
	local useFacBank = fw.config.useFactionBank

	local reward = 0
	for k, zone in pairs(fw.zone.zoneList) do
		if zone:getControllingFaction() == faction then
			reward = reward + 1
		end
	end
	reward = reward * fw.config.zoneCaptureReward

	for k,v in pairs(fac_players) do
		local team = fw.team.list[v:Team()]

		local salary = team.salary + reward

		v:addMoney(salary)

		local text = "Payroll has been issued! Your salary: $"..salary
		fw.hud.pushNotification(v, "Faction", text)
	end
end

local payroll = fw.config.payrollTime or 60

hook.Add("Initialize", "LoadBanks", function()
	if (fw.config.factionBankPersist) then
		fw.team.loadFactionBanks()
	end
end)

timer.Create("fw.teams.pay", payroll, 0, function()
	for k,v in pairs(fw.team.factions) do
		fw.team.factionPayroll(k)
	end

	if (fw.config.factionBankPersist) then
		fw.team.saveFactionBanks()
	end

	for k,v in pairs(player.GetAll()) do
		if (v:inFaction()) then continue end

		local team = fw.team.list[v:Team()]
		if (not team) then continue end

		local salary = team.salary
		v:addMoney(salary)

		local text = "Payroll has been issued! You've been paid $"..salary

		fw.hud.pushNotification(v, "Faction Bank", text)
	end
end)
