net.Receive("playerDeath", function()
        local deathText
	local suicide = net.ReadBool()
        local attacker = net.ReadEntity()

	if suicide then
	    deathText = "You committed suicide"
	elseif IsValid(attacker) then
		deathText = "You were killed by "..(attacker:IsPlayer() and attacker:Nick() or attacker:GetClass())
	end

	-- Death Screen Panel
	local deathPanel = vgui.Create("DFrame")
	deathPanel:SetSize(ScrW(), ScrH())
	deathPanel:Center()
	deathPanel:SetTitle("")
   	deathPanel:SetDraggable(false)
	deathPanel:ShowCloseButton(false)
	deathPanel.Paint = function (self, w, h)
	        Derma_DrawBackgroundBlur(self, 0)

		local seed = 10
		local tick = (CurTime() + seed*40)
		local speed = seed % 4 + 1 + (seed * 0.05)
		local realTick = (CurTime() * 2 + tick * speed * 100) % w

		draw.SimpleText("RIP", fw.fonts.default:atSize(100), realTick, 0 + (h*2/4) + math.sin(realTick/200) * 100, color_white)
	end

	-- Label
	local deathLabel = vgui.Create("DLabel", deathPanel)
	deathLabel:Dock(BOTTOM)
	deathLabel:SetText(deathText)
  	deathLabel:SetTextColor(color_white)
	deathLabel:SetFont(fw.fonts.default:atSize(100))
	deathLabel:SetAutoStretchVertical(true)
	deathLabel:SetWrap(true)

	-- If the player is alive, removes the death screen.
	timer.Create("checkIfAlive", 0.5, 0, function()
                if LocalPlayer():Alive() then
	                deathPanel:Remove()
		end
	end)
end)
