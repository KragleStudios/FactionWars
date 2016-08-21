net.Receive("playerDeath", function()
	if (LocalPlayer().menu_open) then return end

	LocalPlayer().menu_open = true

    	local deathText
	local suicide = net.ReadBool()
	local attacker = net.ReadEntity()

	if suicide then
		deathText = "You killed yourself"
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
            		LocalPlayer().menu_open = false
		end
	end)
end)
