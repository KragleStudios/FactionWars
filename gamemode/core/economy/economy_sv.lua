local Player = FindMetaTable('Player')

fw.data.addPersistField('money')

-- Player:setMoney(amount:number)
-- @param amount:number - the amount of money to set
-- @ret amount:number same as the amount set
function Player:setMoney(amount)
	if type(amount) ~= 'number' then error("player money must be a number") end
	if amount < 0 then error("value must be positive") end
	self:GetFWData().money = amount
	return amount
end

-- Player:addMoney(amount:number)
-- @param amount:number - the amount of money to add
-- @ret amount:number player's current balance
function Player:addMoney(amount)
	return self:setMoney(self:getMoney() + amount)
end
