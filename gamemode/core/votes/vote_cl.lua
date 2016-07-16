local votePanels = {}

local function realignVotes()
	local width = 150
	local tall  = 150

	local c = 0
	for k,v in pairs(votePanels) do
		local offset = (ScrW() / 2) - (width / 2) + ((width + 10) * c)
		--local c = #votePanels
		v:SetPos( (ScrW() / 2) - (width / 2) + (8 * c), ScrH() - tall)
		v:MoveToBack()
		if (c != 0) then
			v:SetBG(true, c)
		else
			v:SetBG(false)
		end
		c = c + 1
	end
end

local function removeVotePanel(pnl, index)
	votePanels[index] = nil

	realignVotes()
end

local function wrapText(string, width)
	local tbl = {}
	for k,v in pairs(markup.Parse(string, width).blocks) do
		table.insert(tbl, v.text)
	end

	return tbl
end

-- play nice with lua refresh this does not.
ndoc.addHook('fwVotes.?', 'set', function(vIndex, tbl)
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

		local pnl = vgui.Create("DFrame")
		pnl:SetSize(150, 150)
		pnl:Center()
		pnl:ShowCloseButton(false)
		pnl:SetTitle(" ")
		pnl.color = Color(0, 0, 0, 0)
		pnl.inback = false

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
				pnl:Close()
			end

			removeVotePanel(pnl, vIndex)
		end)

		local title_f = fw.fonts.default:fitToView(pnl:GetWide(), 75, title)
		local desc_f = fw.fonts.default:fitToView(pnl:GetWide(), 60, "aaaaaaaaaaaaaaaa")
		local timeLeft_f = fw.fonts.default:fitToView(pnl:GetWide() / 2, 15, "15 seconds")
		local wrappedText = wrapText(desc, pnl:GetWide() / 1.5)

		function pnl:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255))
			draw.SimpleText(title, title_f, w / 2, 0, Color(0, 0, 0), TEXT_ALIGN_CENTER)

			for k,v in pairs(wrappedText) do
				if (k > 2) then continue end

				draw.SimpleText(v, desc_f, w / 2, 5 + (k * 15), Color(0, 0, 0), TEXT_ALIGN_CENTER)
			end

			local timeLeft = timer.TimeLeft("vote_"..vIndex) or 0

			if (not self.inback) then
				draw.RoundedBox(0, 0, h - 30, w, 30, Color(0, 0, 0))
				draw.RoundedBox(0, 5, h - 25, (timeLeft / length) * (w -10) , 20, Color(255, 0, 0))
				draw.SimpleText(math.Round(timeLeft).. " seconds", timeLeft_f, 10, (h - 21) , Color(255, 255, 255))
			end
			draw.RoundedBox(0, 0, 0, w, h, self.color)
		end

		local w,h = pnl:GetSize()

		local yes = vgui.Create("DButton", pnl)
		yes:SetSize((w / 2) - 7.5, 50)
		yes:SetPos(5, pnl:GetTall() - yes:GetTall() - 35)
		yes:SetText(" ")

		local yes_f = fw.fonts.default:fitToView(yes:GetWide() / 2, 20, yesText)

		function yes:Paint(w, h)
			local col = Color(0, 0, 0, 255)
			if (self:IsHovered()) then
				col = Color(0, 0, 0, 155)
			end

			draw.RoundedBox(0, 0, 0, w, h, col)
			draw.SimpleText(yesText .." ".. ndoc.table.fwVotes[vIndex].yes, yes_f, w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local no = vgui.Create("DButton", pnl)
		no:SetSize((w / 2) - 7.5, 50)
		no:SetPos((w / 2), pnl:GetTall() - yes:GetTall() - 35)
		no:SetText(" ")

		local no_f = fw.fonts.default:fitToView(no:GetWide() / 2, 20, noText)

		function no:Paint(w, h)
			local col = Color(0, 0, 0, 255)
			if (self:IsHovered()) then
				col = Color(0, 0, 0, 155)
			end

			draw.RoundedBox(0, 0, 0, w, h, col)
			draw.SimpleText(noText .." ".. ndoc.table.fwVotes[vIndex].no, no_f, w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		function yes:DoClick()
			net.Start("fw.sendVoteResponse")
				net.WriteInt(vIndex, 32)
				net.WriteString(yesText)
			net.SendToServer()

			removeVotePanel(pnl, vIndex)

			pnl:Close()
		end
		function no:DoClick()
			net.Start("fw.sendVoteResponse")
				net.WriteInt(vIndex, 32)
				net.WriteString(noText)
			net.SendToServer()

			removeVotePanel(pnl, vIndex)

			pnl:Close()
		end
	end)
end)
