local votePanels = {}

local function realignVotes()
	local width = 200
	local tall  = 150

	local totalWidth = 0
	local maximumHeight = 0
	for k, v in pairs(votePanels) do
		if not IsValid(v) then
			table.remove(votePanels, k)
			realignVotes()
			break
		end
		totalWidth = totalWidth + v:GetWide()
		maximumHeight = math.max(maximumHeight, v:GetTall())
	end

	local x = (sty.ScrW - totalWidth) * 0.5
	local y = sty.ScrH - maximumHeight
	for k,v in SortedPairs(votePanels) do
		v:SetPos(x, y)
		x = x + v:GetWide()
	end
end

local function removeVotePanel(pnl, index)
	votePanels[index] = nil
	pnl:Remove()

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

		local isInPool = false
		for k,v in ndoc.ipairs(vote.players) do
			if (v == LocalPlayer()) then isInPool = true end
		end
		if (not isInPool) then return end

		local length = vote.voteLength
		local title  = vote.title
		local desc   = vote.desc

		local pnl = vgui.Create("FWUIFrame")
		pnl:SetSize(200, 150)
		ndoc.observe(ndoc.table.fwVotes[vIndex], 'fw.votes.titleChange', function(value)
			pnl:SetTitle(value)
		end, 'title')
		pnl:Center()
		pnl.DoClose = function(self)
		  removeVotePanel(self, vIndex)
		end

		local textLabel = vgui.Create("DLabel", pnl)
		textLabel:SetPos(0, pnl:GetHeaderYOffset())
		textLabel:Dock(FILL)
		textLabel:SetWrap(true)
		textLabel:SetFont(fw.fonts.default:atSize(sty.ScreenScale(10)))

		ndoc.observe(ndoc.table.fwVotes[vIndex], 'fw.votes.descChange', function(value)
			textLabel:SetText(value)
		end, 'desc')

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
			if IsValid(pnl) then
				removeVotePanel(pnl, vIndex)
			end
		end)

		local desc_f = fw.fonts.default:atSize(20)
		local timeLeft_f = fw.fonts.default:atSize(15)

		function pnl:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(46, 46, 46))

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

			pnl:DoClose()
		end

		function no:DoClick()
			net.Start("fw.sendVoteResponse")
				net.WriteInt(vIndex, 32)
				net.WriteString(noText)
			net.SendToServer()

			pnl:DoClose()
		end

		local noCount = 0
		local yesCount = 0
		ndoc.observe(ndoc.table.fwVotes[vIndex], 'ndoc.vote.yesCountChange', function(_yesCount)
			if not IsValid(pnl) then return end
			yesCount = _yesCount
			yes:SetText(yesText .. ' ' .. yesCount)
		end, 'yes')
		ndoc.observe(ndoc.table.fwVotes[vIndex], 'ndoc.vote.noCountChange', function(_noCount)
			if not IsValid(pnl) then return end
			noCount = _noCount
			no:SetText(noText .. ' ' .. noCount)
		end, 'no')

		pnl:SetMouseInputEnabled(true)
		pnl:MoveToFront()
	end)
end, ndoc.compilePath("fwVotes.?"))
