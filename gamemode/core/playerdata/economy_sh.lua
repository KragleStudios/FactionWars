local Player = FindMetaTable('Player')

function Player:canAfford(amount)
	return self:getMoney() > amount
end

function Player:getMoney()
	return ndoc.table.fwPlayers[self].money
end

