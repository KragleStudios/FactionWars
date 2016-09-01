local votePanels = {}

local function realignVotes()
	local width = 200
	local tall  = 150

	local c = 0
	for k,v in pairs(votePanels) do
		local offset = (ScrW() / 2) - (width / 2) + ((width + 10) * c)
		--local c = #votePanels
		v:SetPos( (ScrW() / 2) - (width / 2) + (8 * c), ScrH() - tall)
		v:MoveToBack()
		if (c ~= 0) then
			v:SetBG(true, c)
		else
			v:SetBG(false)
		end
		c = c + 1
	end
end

local function removeVotePanel(pnl, index)
	votePanels[index] = nil

	if (IsValid(pnl)) then
		pnl:Remove()
	end

	realignVotes()
end

-- play nice with lua refresh this does not.
ndoc.observe(ndoc.table, "fw.votes", function(vIndex, tbl)
	if tbl == nil then
		if IsValid(votePanels[vIndex]) then
			votePanels[vIndex]:Remove()
			fw.print("stopped vote with id #" .. vIndex)
		end
		return
	end

	timer.Simple(0.5, function()
		-- wait for the table to finish syncing.

		fw.print("vote started with id #" .. vIndex)

		local vote = tbl

		local yesText = vote.yesText
		local noText  = vote.noText

		local length = vote.voteLength
		local title  = vote.title
		local desc   = vote.desc

		pnl = vgui.Create("FWUIFrame")
		pnl:SetSize(200, 150)
		pnl:SetTitle(title)
		pnl:Center()
		function pnl:DoClose()
		  	removeVotePanel(self)
		end

		function pnl:SetBG(bool, count)
			if (bool) then
				self.color = Color(0, 0, 0, 50 * count)
				self.inback = true
			else
				self.color = Color(0, 0, 0, 0)
				self.inback = false
			end
		end

		votePanels[vIndex] = pnl
		realignVotes()

		timer.Create("vote_"..vIndex, tbl.voteLength or vote_defLen, 1, function()
			removeVotePanel(pnl, vIndex)
		end)

		local desc_f = fw.fonts.default:atSize(20)
		local timeLeft_f = fw.fonts.default:atSize(15)

		function pnl:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(46, 46, 46))

			draw.SimpleText(desc, desc_f, w/2, 20, color_white, TEXT_ALIGN_CENTER)

			local timeLeft = timer.TimeLeft("vote_"..vIndex) or 0

			if (not self.inback) then
				draw.RoundedBox(0, 0, h - 80, w, 30, Color(0, 0, 0))
				draw.RoundedBox(0, 5, h - 75, (timeLeft / length) * (w -10) , 20, Color(255, 0, 0))
				draw.SimpleText(math.Round(timeLeft).. " seconds", timeLeft_f, 10, (h - 71) , Color(255, 255, 255))
			end

		end

		local w,h = pnl:GetSize()

		local no = vgui.Create("FWUIButton", pnl)
       		no:SetSize((w / 2) - 7.5, 25)
        	no:Dock(BOTTOM)
        	no:SetText(noText .." ".. ndoc.table.fwVotes[vIndex].no)
        	no:SetFont(fw.fonts.default)

        	local yes = vgui.Create("FWUIButton", pnl)
        	yes:SetSize((w / 2) - 7.5, 25)
        	yes:Dock(BOTTOM)
        	yes:SetText(yesText .." ".. ndoc.table.fwVotes[vIndex].yes)
        	yes:SetFont(fw.fonts.default)

		function yes:DoClick()
			net.Start("fw.sendVoteResponse")
				net.WriteInt(vIndex, 32)
				net.WriteString(yesText)
			net.SendToServer()

			removeVotePanel(pnl, vIndex)
		end

		function no:DoClick()
			net.Start("fw.sendVoteResponse")
				net.WriteInt(vIndex, 32)
				net.WriteString(noText)
			net.SendToServer()

			removeVotePanel(pnl, vIndex)
		end
	end)
end, ndoc.compilePath("fwVotes.?"))
