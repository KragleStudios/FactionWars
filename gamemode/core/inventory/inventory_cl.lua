net.Receive("fw.openInventory", function()
	local items = ndoc.table.items[LocalPlayer()].inventory
end)