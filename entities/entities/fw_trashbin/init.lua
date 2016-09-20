AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Trashdata: Model, Trash type, [on_entity_spawn(self,entity)], [modelscale], Physic_function()
local TrashData = {
	[0] = {"models/props_junk/cardboard_box004a.mdl",0}, -- Money box
	[1] = {"models/props_junk/trashcluster01a.mdl",1}, -- Street trash
	[2] = {"models/props_trainstation/trashcan_indoor001a.mdl",1}, -- Trashbin
	[3] = {"models/props_junk/trashbin01a.mdl",1}, -- Trashbin2
	[4] = {"models/props_lab/scrapyarddumpster_static.mdl",2,function(self,ent)
		local min,max = self:OBBMaxs(),self:OBBMins()
		local vec = self:LocalToWorld(Vector(math.random(min.x,max.x),math.random(min.y,max.y),20-ent:OBBMins().z))
		ent:SetPos(vec)
		ent:Spawn()
	end,0.5,
	function(self,max,min)
		max.z = 15
		self:PhysicsInitBox(min,max)
	end} -- Big dumpster
}

-- Sets the model and premade "type" of trash
function ENT:SetModelType(num)
	local Data = TrashData[num] or TrashData[2]
	self.Data = num
	self:SetModel(Data[1])
	if self:GetSkin()>0 then
		self:SetSkin(math.random(1,self:GetSkin()))
	end
	if Data[4] then
		local n = Data[4],0
		self:SetModelScale(n)
		-- Activate can crash the server and clients tent to get stuck on entities
		if !Data[5] then
			local max,min = self:OBBMaxs(),self:OBBMins()
			self:PhysicsInitBox( min*n,max*n )
		end
	elseif !Data[5] then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
	end
	if Data[5] then
		Data[5](self,self:OBBMaxs(),self:OBBMins())
	end
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)	
	end
end

	-- Min Time, Max Time
local SpawnTimer = {60,60*10}

function ENT:Initialize()
	self:SetUseType(SIMPLE_USE)
	self.CanSpawn = SysTime()+math.random(SpawnTimer[1],SpawnTimer[2])
	self:SetNWFloat("CanSpawn",self.CanSpawn)

	self:SetModelType(self.Type or 0)
end

--[[ Types:
	0 - Only cash or nothing
	1 - Cash or ammo
	2 - Cash, ammo or a bad weapon (If my mod is installed)
	3 - Medium loot
	4 - High quality loot
]]
local WeaponList = {"weapon_smg1"}
local function spawnGarbadge(self)
	local num = TrashData[self.Data][2] or 0
	local r = math.random(0,num)
	local ent
	if num==0 and math.random(10)<=4 then
		return -- Nothing
	end
	if num == 0 or r==0 then
		if Item then
			ent = Item.Create("money",math.random(10,25),self:GetPos())
		else 
			ent = ents.Create("fw_money")
		end
		if ent:GetClass()=="fw_money" then
			ent:SetValue(math.random(10,25))
		end
		return ent
	end
	if num<3 then
		if r == 1 or !WeaponSys then
			-- ammo
			ent = ents.Create(table.Random({"item_ammo_357","item_ammo_ar2","item_ammo_pistol","item_box_buckshot","item_ammo_smg1","item_healthvial"}))
		elseif WeaponSys then -- Check if the weaponmod is installed
			-- Spawn a bad weapon
			ent = ents.Create(table.Random(WeaponList))
			WeaponSys.Create(ent,math.random(0,1))
		end
	end
	return ent
end

function SpawnGarbedgebin(numtype,pos)
	local ent = ents.Create("fw_trashbin")
	ent.Type = numtype
	ent:Spawn()
	ent:SetPos(pos+Vector(0,0,-ent:OBBMins().z))
	return ent 
end
function ENT:Think()
	if !IsValid(self.LastSpawn) then return end
	if !self.LastSpawn.Owner then return end
	if type(self.LastSpawn.Owner)=="Player" then
		self.LastSpawn = nil
	end
end
function ENT:Use(...)
	if (self.CanSpawn or 0)>=SysTime() then return end
	if self.LastSpawn then
		SafeRemoveEntity(self.LastSpawn)
	end
	self.CanSpawn = SysTime()+math.random(SpawnTimer[1],SpawnTimer[2])
	self:SetNWFloat("CanSpawn",self.CanSpawn)
	
	local ent = spawnGarbadge(self)
	if !ent then 
		for I=1,10 do
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos()+VectorRand()*5)
			effectdata:SetStart(self:GetPos()+VectorRand()*5)
			effectdata:SetEntity(self)
			effectdata:SetScale(1)
		util.Effect("WheelDust",effectdata,true,true)
		end
		self:EmitSound("physics/cardboard/cardboard_box_impact_hard"..math.random(1,5)..".wav")
		return false 
	end
	local Data = TrashData[self.Data]
	if Data[3] then
		Data[3](self,ent)
	else
		local max,min = self:OBBMaxs(),self:OBBMins()
		local _z = max.z-ent:OBBMins().z+5
		local vec = Vector(math.random(min.x,max.x),math.random(min.y,max.y),_z)
		ent:SetPos(self:LocalToWorld(vec))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys then
			local r = VectorRand()
				r.z = 0.1
			phys:SetVelocity(r*math.random(60,120)/phys:GetMass())
			print(phys:GetMass())
		end
	end
	self:EmitSound("physics/cardboard/cardboard_box_impact_hard"..math.random(1,5)..".wav")
	for I=1,10 do
			local effectdata = EffectData()
		effectdata:SetOrigin(ent:GetPos()+VectorRand()*5)
		effectdata:SetStart(ent:GetPos()+VectorRand()*5)
		effectdata:SetEntity(self)
		effectdata:SetScale(1)
	util.Effect("WheelDust",effectdata,true,true)
	end

	self.LastSpawn = ent
end