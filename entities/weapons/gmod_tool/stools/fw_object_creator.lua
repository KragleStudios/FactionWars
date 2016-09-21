if SERVER then
	AddCSLuaFile()
end

require "ra"

TOOL.Category = "Faction Wars"
TOOL.Name = "#faction wars object creator"
TOOL.ClientConVar[ "entity" ] = ""
TOOL.ClientConVar[ "entity_option" ] = ""
TOOL.ClientConVar[ "p" ] = "0"
TOOL.ClientConVar[ "y" ] = "0"
TOOL.ClientConVar[ "r" ] = "0"

local data = {}
FW_Map_Objects = FW_Map_Objects or {}
local function Load()
	if CLIENT then return end

	local f_data = util.JSONToTable(file.Read("factionwars_sv/entities_sv/"..game.GetMap()..".dat"))
	if table.Count(f_data) >=1 then
		data = f_data
	end
	-- Clear
	print("Loading map entities ..")
	for ent,_ in pairs(FW_Map_Objects) do
		SafeRemoveEntity(ent)
	end
	table.Empty(FW_Map_Objects)
	-- Spawn
	for key,data in ipairs(data) do
		local pos,class = data.pos,data.class

		local ent = ents.Create(data.class)
		if data.model then
			ent:SetModel(data.model)
		end

		if data.key then
			local value = data.value
			ent[data.key] = value
		end
		ent:SetPos(data.pos)
		ent:SetAngles(data.ang)
		print("["..key.."]: ",ent)
		ent:Spawn()
		ent:SetAngles(data.ang)
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
		FW_Map_Objects[ent] = key
	end
end
local function Save()
	local json = util.TableToJSON(data)
	if string.len(json)<=1 then error("FW Object maneger: JSON is damaged!") return end
	file.Write("factionwars_sv/entities_sv/"..game.GetMap()..".dat",json)
end
local function AddObject( ent, key_value, value )
	if CLIENT then return end
	FW_Map_Objects[ent] = table.insert(data,{class = ent:GetClass(), pos= ent:GetPos(), ang = ent:GetAngles(),model = ent:GetModel(), key = key_value, value =value} )
	Save()
end
Load()
local function RemoveObject( ent )
	if not FW_Map_Objects[ent] then return end
	local num = FW_Map_Objects[ent]
	table.remove(data,num)
	FW_Map_Objects[ent] = nil
	
	local tab = table.SortByKey( FW_Map_Objects , true ) 

	for I=1,#tab do
		FW_Map_Objects[tab[I]] = I
	end

	sound.Play("buttons/button4.wav",ent:GetPos())

	local effectdata = EffectData()
	effectdata:SetOrigin( ent:GetPos() )
	util.Effect( "ManhackSparks", effectdata, true, true )

	SafeRemoveEntity(ent)
	Save()
end

if CLIENT then
	language.Add( "tool.fw_object_creator.name", "FW Object Creator" )
	language.Add("tool.fw_object_creator.select_entity","Entities")
	language.Add( "tool.fw_object_creator.0", "Primary: Place an object.\nSecondary: Delete an object.\nReload: Rotate 45 degrees." )
	RunConsoleCommand("fw_object_creator_entity","")

	local Arrow = Material("vgui/gmod_tool")
	hook.Add("PostDrawOpaqueRenderables", "fw.toolgun.objectcreator", function()
		if not LocalPlayer() then return end
		if not IsValid(LocalPlayer():GetActiveWeapon()) then return end
		if LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_tool" then return end
		if LocalPlayer():GetInfo( "gmod_toolmode","" ) ~= "fw_object_creator" then return end
		if not LocalPlayer():GetTool() then return end
		local ent = LocalPlayer():GetTool().GhostEntity
		if not IsValid(ent) then return end
		local min,max = ent:OBBMins(),ent:OBBMaxs()

		render.SetColorMaterial()
		render.DrawBox(ent:GetPos(),ent:GetAngles(),min,max,Color(255,0,0,155))

		local w,h = max.x-min.x,max.y-min.y
		cam.Start3D2D( ent:LocalToWorld(Vector(min.x,min.y,0)), ent:GetAngles(), 0.1)
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(Arrow)
			
			surface.DrawTexturedRect(0,-h*10,w*10,h*10)
		cam.End3D2D()
	end)
else
	hook.Add("InitPostEntity","Faction Wars Entitie_stool",function()
		file.CreateDir("factionwars_sv/entities_sv")
		if file.Exists("factionwars_sv/entities_sv/"..game.GetMap()..".dat","DATA") then
			Load()
		end
	end)
end
local objects = {} -- entity: options{ [name] = {Model,Set a value on the entity,The value, scale} }
	objects["fw_trashbin"] = {["small money box"] = {"models/props_junk/cardboard_box004a.mdl","Type",0},
							["street trash"] = {"models/props_junk/trashcluster01a.mdl","Type",1},
							["trashbin 1"] = {"models/props_trainstation/trashcan_indoor001a.mdl","Type",2},
							["trashbin 2"] = {"models/props_junk/trashbin01a.mdl","Type",3},
							["dumpster"] = {"models/props_lab/scrapyarddumpster_static.mdl","Type",4,0.5}}

function TOOL:LeftClick( trace, attach )
	if game.SinglePlayer() then error "This tool will not work in single player." end
	if not self:GetOwner():IsSuperAdmin() then print("Not super") return false end
	if not IsFirstTimePredicted() then return false end

	local selected_entity = self:GetClientInfo("entity") or ""
	local selected_entity_option = self:GetClientInfo("entity_option") or ""

	if CLIENT then
		if selected_entity=="" then
			local ent = trace.Entity
			if not IsValid(ent) or ent:IsWorld() or objects[trace.Entity:GetClass()] then
				return false
			else
				return trace.Entity:GetClass() == "prop_physics"
			end
		end
		return true
	end

	if selected_entity=="" then
		if not IsValid(trace.Entity) or objects[trace.Entity:GetClass()] then
			self:GetOwner():ChatPrint("No entity selected")
			return false
		elseif trace.Entity:GetClass() == "prop_physics" then
			AddObject( trace.Entity )
			local phys = trace.Entity:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
			trace.Entity:SetColor(Color(255,0,0))
			return true			 
		end
	end
	if not objects[selected_entity] then return false end

	local ent_data = objects[selected_entity]
	if selected_entity_option!="" then
		ent_data = ent_data[string.lower(selected_entity_option)] or ent_data
	end


	local ent = ents.Create(selected_entity)
	if ent_data[2] and ent_data[3] then
		ent[ent_data[2]] = ent_data[3]
	end
	ent:Spawn()

	local ang = Angle(self:GetClientNumber("p",0),self:GetClientNumber("y",0),self:GetClientNumber("r",0))
	ent:SetAngles(ang)

	local offset = ent:LocalToWorld(Vector(0,0,-ent:OBBMins().z))-ent:GetPos()
	local pos = trace.HitPos+offset

	ent:SetPos(pos)
	AddObject(ent, ent_data[2], ent_data[3])
	ent:EmitSound("buttons/button14.wav")

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	return true
end

function TOOL:Think()
	local selected_entity = self:GetClientInfo("entity")
	local selected_entity_option = self:GetClientInfo("entity_option")

	if selected_entity == "" then 
		if IsValid(self.GhostEntity) then
			SafeRemoveEntity(self.GhostEntity)
		end
		return 
	end
	local entity_data = objects[selected_entity]
	if selected_entity_option ~= "" then
		entity_data = entity_data[string.lower(selected_entity_option)]
	end
	local model = entity_data[1]

	if ( not IsValid( self.GhostEntity ) or self.GhostEntity.model ~= model and model ) then
	
		self:MakeGhostEntity( model, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )

		if ( IsValid( self.GhostEntity ) ) then 
			if entity_data[4] then
				self.GhostEntity:SetModelScale(entity_data[4],0)
			end
			self.GhostEntity.model = model 
		end

	end

	self:UpdateGhost( self.GhostEntity, self:GetOwner() )
end

function TOOL:UpdateGhost( ent, ply )

	if ( not IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()
	local rotate = self.rotate or 0

	local hitAngle = trace.HitNormal:Angle()
	local ang = Angle(hitAngle.pitch+90,hitAngle.yaw,0) 

	ent:SetAngles(ang)
	ent:SetAngles(ent:LocalToWorldAngles(Angle(0,rotate,0)))

	local offset = ent:LocalToWorld(Vector(0,0,-ent:OBBMins().z))-ent:GetPos()
	local pos = trace.HitPos+offset

	ent:SetPos(pos)
	local ang = ent:GetAngles()
	RunConsoleCommand("fw_object_creator_p",ang.p)
	RunConsoleCommand("fw_object_creator_y",ang.y)
	RunConsoleCommand("fw_object_creator_r",ang.r)

	ent:SetNoDraw(false)

end

function TOOL:RightClick( trace )
	if game.SinglePlayer() then error "This tool will not work in single player." end
	if not self:GetOwner():IsSuperAdmin() then return false end
	if not IsFirstTimePredicted() then return false end
	if not IsValid(trace.Entity)  then return false end

	if (trace.Entity:GetClass() == "prop_physics" or objects[trace.Entity:GetClass()]) then
		if CLIENT then return true end
		RemoveObject(trace.Entity)
		return true		
	end
	return false
end

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "ListBox", { Label = "#tool.fw_object_creator.objects", Height = "300", Options = RealOptions } )
end

local Lastrotated = 0
function TOOL:Reload()
	if (Lastrotated or 0)>=SysTime() then return end
	Lastrotated = SysTime()+0.2
	if CLIENT then
		if self:GetClientInfo("entity")~="" then
			local rotate = self.rotate or 0
			rotate = ((rotate or 0)-45)%360
			self.rotate = rotate
			LocalPlayer():EmitSound("buttons/blip1.wav")
		end
	else
		if self:GetClientInfo("entity")~="" then return end
		local trace = self:GetOwner():GetEyeTrace()
		local ent = trace.Entity
		if not ent then return end
		if ent:GetClass()~="prop_physics" then return end
		if not FW_Map_Objects[ent] then return end
		
		-- Rotate the prop
		for key,ent_data in ipairs(data) do
			if ent_data.pos:Distance(ent:GetPos())<10 and ent:GetClass()==ent_data.class then
				
				local newAng = trace.Entity:LocalToWorldAngles(Angle(0,45,0))
				ent:SetAngles(newAng)

				data[key].ang = ent:GetAngles()
				Save()
				self:GetOwner():EmitSound("buttons/button9.wav")
				break
			end
		end
	end
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )
	local RealOptions = {}

	RealOptions["Add prop"] = {fw_object_creator_entity = "",fw_object_creator_entity_option = "test"}
	for class_name, options in pairs( objects ) do
		if type(options) == "table" then
			for optionname,_ in pairs(options) do
				RealOptions[ class_name.." ("..optionname..")" ] = { fw_object_creator_entity_option = optionname,
											fw_object_creator_entity = class_name }
			end
		else
			RealOptions[ class_name ] = { fw_object_creator_entity_option = "",
											fw_object_creator_entity = class_name }
		end
	end

	CPanel:AddControl( "ListBox", { Label = "#tool.fw_object_creator.select_entity", Height = "300", Options = RealOptions } )
end
