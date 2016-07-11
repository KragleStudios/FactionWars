# Economy
Adds ndoc.fwPlayers.?.money as a persited field.

# API
 - Player:getMoney() : number - returns account balance
 - Player:addMoney(amount) : number - adds money to acct, and returns the new balance
 - Player:setMoney(amount) : number - sets how much money they have, and returns the balance
 - Player:canAfford(amount) : bool - checks if the player can afford 'amount'