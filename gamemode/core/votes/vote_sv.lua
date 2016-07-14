
util.AddNetworkString("fw.sendVoteQuery")
util.AddNetworkString("fw.sendVoteResponse")
util.AddNetworkString("fw.sendVote")

net.Receive("fw.sendVoteResponse", function(len, client)
	local index = net.ReadInt(32)
	local decision = net.ReadString()

	local vote = fw.vote.list[index]
	if (not vote) then 
		client:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Votes]: ", Color(255, 255, 255), "This vote may no longer exist!") 
		return 
	end
	
	if (vote.votes[client]) then
		client:FWChatPrint(Color(0, 0, 0), "[Faction Wars][Votes]: ", Color(255, 255, 255), "You have already voted!") 

		return
	end

	fw.vote.list[index].votes[client] = decision
end)

function fw.vote.getVoteStatus(index)
	local yes = 0
	local no  = 0

	local vote = fw.vote.list[index]
	if (not vote) then return "No", {yes, no} end
	
	for k,v in pairs(vote.votes) do
		if (v == vote.yesText) then
			yes = yes + 1
		elseif (v == vote.noText) then
			no = no + 1
		end
	end

	return yes > no, {yes, no, vote.votes}
end

function fw.vote.createNew(vTitle, vDesc, vPlayers, vCallback, vYText, vNText, vote_len)
	local tbl = {
		title = vTitle, 
		desc = vDesc, 
		players = vPlayers, 
		cback = vCallback, 
		votes = {}, 
		yesText = vYText or "Yes", 
		noText = vNText or "No",
		voteLength = vote_len or fw.vote_defLen
	}

	local indx = table.insert(fw.vote.list, tbl)

	tbl.index = indx

	fw.vote.list[indx].index = indx

	assert(vCallback, "Callback function missing!")
	assert(istable(vPlayers), "Players passed must be a table!")

	timer.Create("vote_"..indx, vote_len or vote_defLen, 1, function()
		local decision, vote_tbl = fw.vote.getVoteStatus(indx)

		vCallback(decision, tbl, vote_tbl)
		
		table.remove(fw.vote.list, indx)
	end)

	tbl.players = nil
	tbl.cback = nil

	for k,v in pairs(vPlayers) do
		net.Start("fw.sendVoteQuery")
			net.WriteTable(tbl)
		net.Send(v)			
	end
end

