if SERVER then
	AddCSLuaFile()
end

require "ra"

TOOL.Category = "Faction Wars"
TOOL.Name = "#faction wars object creator"
TOOL.ClientConVar[ "entity" ] = ""
TOOL.ClientConVar[ "entity_option" ] = ""
TOOL.ClientConVar[ "rotate" ] = "0"

local data = {}
FW_Map_Objects = FW_Map_Objects or {}
local function Load()
	-- Clear
	print("Loading map entities ..")
	for _,ent in ipairs(FW_Map_Objects) do
		SafeRemoveEntity(ent)
	end
	table.Empty(FW_Map_Objects)
	-- Spawn
	for _,data in ipairs(data) do
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

		ent:Spawn()
		table.insert(FW_Map_Objects,ent)
	end
end
local function Save()
	local json = util.TableToJSON(data)
	if string.len(json)<=1 then error("FW Object maneger: JSON is damaged!") return end
	file.Write("factionwars_sv/entities_sv/"..game.GetMap()..".dat",json)
end
local function AddObject( ent, key_value, value )
	if CLIENT then return end
	table.insert(data,{class = ent:GetClass(), pos= ent:GetPos(), ang = ent:GetAngles(),model = ent:GetModel(), key = key_value, value =value} )
	table.insert(FW_Map_Objects,ent)
	Save()
end

local function RemoveObject( ent )
	for key,data in ipairs(data) do
		if data.pos:Distance(ent:GetPos())<10 and ent:GetClass()==data.class then
			table.remove(data,key)
			break
		end
	end
	SafeRemoveEntity(ent)
	Save()
end

if CLIENT then
	language.Add( "tool.fw_object_creator.name", "FW Object Creator" )
	language.Add("tool.fw_object_creator.select_entity","Entities")
	language.Add( "tool.fw_object_creator.0", "Primary: Place an object.\nSecondary: Delete an object.\nReload: Rotate 90 degrees." )
	RunConsoleCommand("fw_object_creator_entity","")

	hook.Add("PostDrawOpaqueRenderables", "fw.toolgun.objectcreator", function()
		if !LocalPlayer() then return end
		if !IsValid(LocalPlayer():GetActiveWeapon()) then return end
		if LocalPlayer():GetActiveWeapon():GetClass()!="gmod_tool" then return end
		if LocalPlayer():GetInfo( "gmod_toolmode","" )!="fw_object_creator" then return end
		if !LocalPlayer():GetTool() then return end
		local ent = LocalPlayer():GetTool().GhostEntity
		if !IsValid(ent) then return end

		render.SetColorMaterial()
		render.DrawBox(ent:GetPos(),ent:GetAngles(),ent:OBBMins(),ent:OBBMaxs(),Color(255,0,0,155))
	end)
else
	file.CreateDir("factionwars_sv/entities_sv")
	if file.Exists("factionwars_sv/entities_sv/"..game.GetMap()..".dat","DATA") then
		local f_data = util.JSONToTable(file.Read("factionwars_sv/entities_sv/"..game.GetMap()..".dat"))
		if table.Count(f_data)>=1 then
			data = f_data
			Load()
		end
	end
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

	local selected_entity = self:GetClientInfo("entity") or ""
	local selected_entity_option = self:GetClientInfo("entity_option") or ""

	if CLIENT then
		if selected_entity=="" then
			local ent = trace.Entity
			if !IsValid(ent) or ent:IsWorld() or objects[trace.Entity:GetClass()] then
				return false
			else
				return trace.Entity:GetClass() == "prop_physics"
			end
		end
		return true
	end

	if selected_entity=="" then
		if !IsValid(trace.Entity) or objects[trace.Entity:GetClass()] then
			self:GetOwner():ChatPrint("No entity selected")
			return false
		elseif trace.Entity:GetClass() == "prop_physics" then
			AddObject( trace.Entity )
			trace.Entity:SetColor(Color(255,0,0))
			return true			 
		end
	end
	if !objects[selected_entity] then return false end
	PrintTable(trace)

	local ent_data = objects[selected_entity]
	if selected_entity_option!="" then
		ent_data = ent_data[string.lower(selected_entity_option)] or ent_data
	end


	local ent = ents.Create(selected_entity)
	local vec = trace.HitPos
	if type(vec)=="string" then
		local a = string.Explode(" ",trace.HitPos)
		vec = Vector(a[1]:tonumber(),a[2]:tonumber(),a[3]:tonumber())
		print(vec,a[1],a[2])
	end
	
	if ent_data[2] and ent_data[3] then
		ent[ent_data[2]] = ent_data[3]
	end
	
	ent:Spawn()
	ent:SetPos(vec+Vector(0,0,-ent:OBBMins().z))
	ent:SetAngles( Angle( 0, trace.Normal:Angle().yaw+self:GetClientNumber("rotate",0), 0 ) )
	AddObject( ent, ent_data[2], ent_data[3] )

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
	if not IsFirstTimePredicted() then return false end

	return true
end

function TOOL:Think()
	local selected_entity = self:GetClientInfo("entity")
	local selected_entity_option = self:GetClientInfo("entity_option")

	if selected_entity=="" then 
		if IsValid(self.GhostEntity) then
			SafeRemoveEntity(self.GhostEntity)
		end
		return 
	end
	local entity_data = objects[selected_entity]
	if selected_entity_option !="" then
		entity_data = entity_data[string.lower(selected_entity_option)]
	end
	local model = entity_data[1]

	if ( !IsValid( self.GhostEntity ) || self.GhostEntity.model != model and model ) then
	
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

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()

	local CurPos = ent:GetPos()
	local NearestPoint = ent:NearestPoint( CurPos - ( trace.HitNormal * 512 ) )
	local Offset = CurPos - NearestPoint

	local pos = trace.HitPos + Offset

	ent:SetPos( pos )
	ent:SetAngles( Angle( 0, ply:GetAngles().yaw+self:GetClientNumber("rotate",0), 0 ) )

	ent:SetNoDraw( false )

end

function TOOL:RightClick( trace )
	if game.SinglePlayer() then error "This tool will not work in single player." end
	if not self:GetOwner():IsSuperAdmin() then return false end
	if not IsFirstTimePredicted() then return false end

	if IsValid(trace.Entity) and (trace.Entity:GetClass() == "prop_physics" or objects[trace.Entity:GetClass()]) then
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
	local rotate = self:GetClientNumber("rotate",0)
	if CLIENT then
		rotate = ((rotate or 0)-90)%360
		RunConsoleCommand("fw_object_creator_rotate",rotate)
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
