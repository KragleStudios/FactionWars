local Player = FindMetaTable('Player')

function Player:setMoney(amount)
	if type(amount) ~= 'number' then error("player money must be a number") end
	ndoc.table.fwPlayers[self].money = amount
end

function Player:addMoney(amount)
	self:setMoney(self:getMoney() + amount)
end
