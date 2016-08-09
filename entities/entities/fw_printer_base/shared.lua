-- This is a base for the money printers and has some real OP stats. Don't actually let people spawn this.

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "Base Money Printer"
ENT.Category = "Faction Wars Printers"

ENT.PrintSpeed = 5 -- How fast can the printer print (in seconds)?
ENT.PrintAmount = 100 -- How much money does it print per cycle?

ENT.PowerRequired = 2 -- How much power does the printer require (in AU/s)
ENT.PaperCap = 100 -- How many sheets of paper can this printer hold?
ENT.InkCap = 100 -- How much ink (in ml) can this printer hold?

ENT.PaperDrain = 5 -- How many sheets of paper are consumed in each print?
-- ENT.InkDrain = 10 -- How much ink is consumed in each print?

ENT.Color = Color(26, 188, 156, 100) -- Color of printer + UI elements

ENT.NETWORK_SIZE = 500
ENT.Resources = true

ENT.MaxConsumption = {
	["power"] = ENT.PowerRequired,
}

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "NextPrintTime")
	self:NetworkVar("Int", 1, "Money")
	self:NetworkVar("Int", 2, "Paper")
	 --self:NetworkVar("Int", 3, "Ink")
	self:NetworkVar("Bool", 4, "PrintStatus")
end
