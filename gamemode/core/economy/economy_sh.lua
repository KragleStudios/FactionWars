local Player = FindMetaTable('Player')

-- Player:canAfford(amount:number)
-- @ret canAfford:bool - can the player afford the amount requested
function Player:canAfford(amount)
	return self:getMoney() or 0 >= amount
end

-- Player:getMoney()
-- @ret amount:number player's current balance
function Player:getMoney()
	return self:GetFWData().money or 0
end