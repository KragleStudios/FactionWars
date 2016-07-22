
local mEntity = FindMetaTable("Entity")
local defaultrad = 250

function mEntity:GetNetworkRadius()
	return self.NetworkRadius || defaultrad
end

function mEntity:IsNode()
	if self.net then
		return true
	end
	return false 
end

function mEntity:IsConnected()
	if self.GenerationRequirements != nil && self.connectednet != nil then
		return true
	end
	return false
end

function mEntity:ConnectToNet()
	for k,v in pairs(ents.GetAll()) do
		if not v:IsNode() then continue end
		print(v, self, v:GetPos():Distance(self:GetPos()), v:GetNetworkRadius(),v:GetPos():Distance(self:GetPos()) < v:GetNetworkRadius()  )
		print("Position: ",self:GetPos(), "Ent Index: ", self:EntIndex())
		if v:GetPos():Distance(self:GetPos()) < v:GetNetworkRadius() then
			print("FOUND ONE")
			self.connectednet = v.net
			v.net.receivers[self:EntIndex()] = self
			print("WE CONNECTED TO " .. v.net:GetID())
			v.net:UpdateGenerationCost("res_power")	
			break
		end
	end
end

function mEntity:GetNode()
	return self.connectednet
end

function mEntity:SetNode(netwrk)
	self.connectednet = netwrk
end

function mEntity:RemoveNode()
	self.connectednet = nil
end

function mEntity:IsPowered()
	--print(self:IsConnected(), self:GetNet():GetID(), self:GetNet():IsOverloaded() == false)
	if self:IsConnected() && self:GetNode():IsOverloaded() == false then
		return true
	end
	return false
end