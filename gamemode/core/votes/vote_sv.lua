
util.AddNetworkString("fw.sendVoteQuery")
util.AddNetworkString("fw.sendVoteResponse")
util.AddNetworkString("fw.sendVote")

local vCount = 1
ndoc.table.fwVotes = {}

local voteCache = {}

net.Receive("fw.sendVoteResponse", function(len, client)
	local index = net.ReadInt(32)
	local decision = net.ReadString()

	--assign it!
	voteCache[index] = voteCache[index] or {}

	local vote = ndoc.table.fwVotes[index]
	if (not vote) then 
		client:FWChatPrint(Color(0, 0, 0), "[Votes]: ", Color(255, 255, 255), "This vote may no longer exist!") 
		return 
	end
	
	if (voteCache[index][client]) then
		client:FWChatPrint(Color(0, 0, 0), "[Votes]: ", Color(255, 255, 255), "You have already voted!") 
		return
	end

	--record it!
	if (decision == vote.yesText) then
		ndoc.table.fwVotes[index].yes = ndoc.table.fwVotes[index].yes + 1
	else
		ndoc.table.fwVotes[index].no  = ndoc.table.fwVotes[index].no  + 1
	end

	--cache it!
	voteCache[index][client] = decision
end)

function fw.vote.getVoteStatus(index)
	local yes = 0
	local no  = 0

	local yesText = ndoc.table.fwVotes[index].yesText
	local noText  = ndoc.table.fwVotes[index].noText
	local yes     = ndoc.table.fwVotes[index].yes
	local no      = ndoc.table.fwVotes[index].no

	return yes > no, {yes, no, votes}
end

function fw.vote.createNew(vTitle, vDesc, vPlayers, vCallback, vYText, vNText, vote_len)
	assert(vCallback, "Callback function missing!")
	assert(istable(vPlayers), "Players passed must be a table!")

	--localize a version for the timer!!!! DUH ME
	local count = vCount

	local tbl = {
		index = count,
		title = vTitle, 
		desc = vDesc, 
		players = vPlayers, 
		yesText = vYText or "Yes", 
		noText = vNText or "No",
		voteLength = vote_len or fw.vote_defLen
	}

	local syncTable = {
		index = count,
		title = vTitle,
		desc = vDesc,
		yesText = vYText or "Yes",
		noText = nYText or "No",
		voteLength = vote_len or fw.vote_defLen,
		yes = 0,
		no = 0
	}

	timer.Create("vote_"..count, vote_len or fw.vote_defLen, 1, function()
		local decision, vote_tbl = fw.vote.getVoteStatus(count)

		vCallback(decision, tbl, vote_tbl)

		--clear the memory up
		ndoc.table.fwVotes[count] = nil		
		voteCache[count] = nil
	end)

	ndoc.table.fwVotes[count] = syncTable

	for k,v in pairs(vPlayers) do
		net.Start("fw.sendVoteQuery")
			net.WriteUInt(count, 32)
		net.Send(v)
	end
	
	vCount = vCount + 1
end