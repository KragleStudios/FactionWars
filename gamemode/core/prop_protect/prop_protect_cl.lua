fw.hook.Add("AddToolMenuTabs", "AddPPPanels", function()
	spawnmenu.AddToolTab("prop_protect", "Prop Protection", "icon16/shield.png")

	spawnmenu.AddToolCategory("prop_protect", "general", "General")

	spawnmenu.AddToolMenuOption("prop_protect", "general", "setstatus", "Update Settings", "", "", function(pnl)
		--
		-- CONTROLS FOR PHYSGUN
		--

		pnl:AddControl("Header", {Description = "Set who can physgun your props"})

		local status = {
			["Everyone"] = 0,
			["Me only"] = 1,
			["Faction only"] = 2
		}

		local combo = pnl:ComboBox("Set Physgun To", "update")
		combo:AddChoice("Everyone")
		combo:AddChoice("Me only")
		combo:AddChoice("Faction only")

		function combo:OnSelect(ind, val)
			local id = status[val]

			net.Start("fw.whoCanPhysgun")
				net.WriteUInt(id, 8)
			net.SendToServer()
		end


		--
		-- CONTROLS FOR TOOL GUN
		--
		pnl:AddControl("Header", {Description = "Set who can tool gun your props"})

		local combo = pnl:ComboBox("Set Tool Use To", "update")
		combo:AddChoice("Everyone")
		combo:AddChoice("Me only")
		combo:AddChoice("Faction only")

		function combo:OnSelect(ind, val)
			local id = status[val]

			net.Start("fw.whoCanTool")
				net.WriteUInt(id, 8)
			net.SendToServer()
		end


		--
		-- CONTROLS FOR WHITELIST
		--

		pnl:AddControl("Header", {Description = "Set who can access your props & tools regardless of above"})

		local combo = pnl:ComboBox("Add a buddy", "update")
		
		local function addChoices()
			for k,v in pairs(player.GetAll()) do
				if (v == LocalPlayer()) then continue end
				if (ndoc.table.pp[LocalPlayer()].whitelist[v]) then continue end

				local choice = combo:AddChoice(v:Nick(), v)
			end
		end
		addChoices()

		function combo:OnSelect(ind, val, ply)
			net.Start("fw.addPlayerToWhitelist")
				net.WriteEntity(ply)
			net.SendToServer()
		end

		local box = pnl:ListBox("Buddies")
		function box:OnSelect(line)
			net.Start("fw.removePlayerFromWhitelist")
				net.WriteEntity(line.ply)
			net.SendToServer()
		end

		ndoc.addHook("pp.?.whitelist.?", "set", function(ply)
			if (ply != LocalPlayer()) then return end

			box:Clear()

			for k,v in ndoc.pairs(ndoc.table.pp[LocalPlayer()].whitelist) do
				local line = box:AddItem(k:Nick())
				line.ply = k
			end

			combo:Clear()
			addChoices()

			box:Rebuild()
			box:SizeToContents()
		end)
	end)

end)