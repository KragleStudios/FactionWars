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

local function removeVotePanel(pnl)
	table.RemoveByValue(votePanels, pnl)

	realignVotes()
end

net.Receive("sendVoteQuery", function()
	local tbl = net.ReadTable()

	local vIndex = tbl.index
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

	table.insert(votePanels, pnl)
	realignVotes()

	timer.Create("vote_"..vIndex, tbl.voteLength or vote_defLen, 1, function()
		pnl:Close()

		removeVotePanel(pnl)
		
		table.remove(fw.vote.list, vIndex)
	end)

	function pnl:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255))
		draw.SimpleText(title, "Default", w / 2, 0, Color(0, 0, 0), TEXT_ALIGN_CENTER)
		draw.SimpleText(desc, "Default", w / 2, 20, Color(0, 0, 0), TEXT_ALIGN_CENTER)

		local timeLeft = timer.TimeLeft("vote_"..vIndex) or 0

		if (not self.inback) then
			draw.RoundedBox(0, 0, h - 30, w, 30, Color(0, 0, 0))
			draw.RoundedBox(0, 5, h - 25, (timeLeft / length) * (w -10) , 20, Color(255, 0, 0))
			draw.SimpleText(math.Round(timeLeft).. " seconds", "Default", 10, (h - 21) , Color(255, 255, 255))
		end
		draw.RoundedBox(0, 0, 0, w, h, self.color)
	end

	local w,h = pnl:GetSize()

	local yes = vgui.Create("DButton", pnl)
	yes:SetSize((w / 2) - 7.5, 50)
	yes:SetPos(5, pnl:GetTall() - yes:GetTall() - 35)
	yes:SetText(" ")
	function yes:Paint(w, h)
		local col = Color(0, 0, 0, 255)
		if (self:IsHovered()) then
			col = Color(0, 0, 0, 155)
		end

		draw.RoundedBox(0, 0, 0, w, h, col)
		draw.SimpleText(yesText, "Trebuchet24", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local no = vgui.Create("DButton", pnl)
	no:SetSize((w / 2) - 7.5, 50)
	no:SetPos((w / 2), pnl:GetTall() - yes:GetTall() - 35)
	no:SetText(" ")

	function no:Paint(w, h)
		local col = Color(0, 0, 0, 255)
		if (self:IsHovered()) then
			col = Color(0, 0, 0, 155)
		end

		draw.RoundedBox(0, 0, 0, w, h, col)
		draw.SimpleText(noText, "Trebuchet24", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function yes:DoClick()
		net.Start("sendVoteResponse")
			net.WriteInt(vIndex, 32)
			net.WriteString(yesText)
		net.SendToServer()

		removeVotePanel(pnl)

		pnl:Close()
	end
	function no:DoClick()
		net.Start("sendVoteResponse")
			net.WriteInt(vIndex, 32)
			net.WriteString(noText)
		net.SendToServer()

		removeVotePanel(pnl)

		pnl:Close()
	end
end)