fw.inv_menu = {}

--lol i have no idea what im doing lol

vgui.Register("fwInvButton", {
	Init = function(self)
		self.BaseClass.Init(self)
	end,

	PaintNormal = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, w, h)
	end,

	PaintHovered = function(self, w, h)
		self:PaintNormal(w, h)

		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end,

	PaintPressed = function(self, w, h)
		self:PaintNormal(w, h)
		self:PaintHovered(w, h)

		surface.SetDrawColor(255, 255, 255, 20)
		surface.DrawRect(0, 0, w, h)
	end
}, 'STYButton')

vgui.Register("fwPlayerInv", {
	Init = function(self)
		local p = sty.ScreenScale(2)

		self.parent = vgui.Create("STYLayoutVertical", self)
		self.parent:SetPadding(5)
	end,

	AddItem = function(self, item_stringID)
		local item = nil
		for k,v in pairs(fw.ents.item_list) do
			if (v.stringID == item_stringID) then
				item = v
			end
		end

		if (not item) then return end

		local itemPanel = vgui.Create("STYPanel", self)
		itemPanel:SetSize(self.parent:GetWide(), 100)

		self.items = self.items or {}
		self.items[item_stringID].count = ndoc.table.items[LocalPlayer()].inventory[item_stringID].count or "wtf"

		local dropBtn = vgui.Create("fwInvButton", itemPanel)
		dropBtn:SetSize(100, 25)
		dropBtn:SetPos(itemPanel:GetWide() - dropBtn:GetWide() - 5, itemPanel:GetWide() - dropBtn:GetWide() - 5)

		local itemTitle = vgui.Create("DLabel", itemPanel)
		itemTitle:SetText(item.name)
		itemTitle:SetPos(5, 5)

		local canRemove, msg = fw.hook.Call("CanRemoveFromInventory", GAMEMODE, LocalPlayer(), item)
		if (not canRemove) then
			dropBtn:SetDisabled(true)
			dropBtn:SetTooltip(msg)
		end

		function dropBtn:DoClick()
			net.Start("fw.dropItem")
				net.WriteString(item_stringID)
			net.SendToServer()

			self.parent:Close()
		end

		
	end,

		Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(0, 0, w, h)
		end,

		SetSize = function(self, w, h)
			self.parent:SetSize(w, h)
		end



}, "STYPanel")

net.Receive("fw.openInventory", function()
	local inv = vgui.Create("fwPlayerInv")
	inv:SetSize(300, 300)
	inv:Center()
end)