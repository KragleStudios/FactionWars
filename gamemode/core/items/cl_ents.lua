--[[
    When creating a menu, this info is important!

    This should be called to see if a player can buy the item, so they don't think they can
    local canBuy = fw.ents.canPlayerBuyItem(LocalPlayer(), i.index)

    This should be put in the buy:DoClick() function
    net.Send("playerBuyItem")
    net.WriteInt(i.index)
    net.SendToServer()
]]
