if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName   = "Opioid Creation"
ENT.Author      = "crazyscouter"
ENT.Category    = "Faction Wars"

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.Color = color_white
ENT.NETWORK_SIZE = 500

ENT.Resources = true
ENT.Crafts = {
	["Morphine"] = {
		resources = {
			["water"] = 1,
			["opioid"] = 2,
		},
		entity = "fw_morphine_needle"
	},
	["Oxycontin"] = {
		resources = {
			["water"] = 1,
			["opioid"] = 3,
		},
		entity = "fw_oxycontin_pill"
	},
	["Vicodin"] = {
		resources = {
			["water"] = 1,
			["opioid"] = 4,
		},
		entity = "fw_vicodin_pill"
	}
}

if SERVER then
	util.AddNetworkString("fw.createOpioid")

	net.Receive("fw.createOpioid", function(l, ply)
		local factory = net.ReadEntity()
		local opioid_type = net.ReadString()

		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		--if (IsValid(ent) and ent:GetClass() == "fw_opioid_refinery" and ent:GetPos():DistToSqr(ply:GetPos()) < 30000) then

			local tbl = factory.Crafts[opioid_type]

			if (not tbl) then return end
			factory:CraftOpioid(tbl)
		--end
	end)

	function ENT:Initialize()
		self:SetModel("models/props/cs_italy/it_mkt_table1.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetTrigger(true)
		self:PhysWake()

		fw.resource.addEntity(self)
	end

	function ENT:CanCreateOpioid(tbl)
		for k,v in pairs(tbl.resources) do
			local consume = self:ConsumeResource(k, v)

			if (not consume) then return false end
		end

		return true
	end

	function ENT:CraftOpioid(tbl)
		if (not self:CanCreateOpioid(tbl)) then return end

		local ent = ents.Create(tbl.entity)
		ent:SetPos(self:GetPos() + Vector(0, 0, 50))
		ent:SetAngles(self:GetAngles())
		ent:Spawn()
		ent:Activate()
	end

	function ENT:OnRemove()
		timer.Destroy(self._timerName)
		fw.resource.removeEntity(self)
	end

	function ENT:OnRemove()
		fw.resource.removeEntity(self)
	end

else
	function ENT:Draw()
		self:DrawModel()
		self:FWDrawInfo()
	end

	function ENT:GetDisplayPosition()
		local obbcenter = self:OBBCenter()
		local obbmax = self:OBBMaxs()
		return Vector(obbcenter.x, obbcenter.y - 25, obbcenter.z + 15), Angle(0, 90, 15), 0.2
	end

	function ENT:CustomUI(panel)
		local ent = self

		local panels = {}

		local function populate()
			for k,v in pairs(self.Crafts) do
				local button = vgui.Create("FWUIButton", panel)
				button:SetTall(fw.resource.INFO_ROW_HEIGHT)
				button:SetText(k)

				button.DoClick = function()
					panel:createReq(k, v.resources)
				end

				table.insert(panels, button)
			end
		end
		populate()

		local function clearPanels()
			for k,v in pairs(panels) do
				v:Remove()

				panels[k] = nil
			end
		end

		function panel:createReq(name, data)
			clearPanels()

			local row = vgui.Create('fwEntityInfoRow', panel)
			row:SetTall(fw.resource.INFO_ROW_HEIGHT)

			local status = vgui.Create('FWUITextBox', row)
			status:SetAlign('center')
			status:SetText("Required for "..name)
			status:Dock(FILL)

			table.insert(panels, row)
			table.insert(panels, status)

			for k,v in pairs(data) do
				local row = vgui.Create('fwEntityInfoRow', panel)
				row:SetTall(fw.resource.INFO_ROW_HEIGHT)

				local hasRes, reqRes = ent:FWHaveResource(k), v
				local realname = fw.resource.types[k].PrintName

				local res = vgui.Create('FWUITextBox', row)
				res:SetAlign('center')
				res:SetText(realname.. ": " .. reqRes)
				res:Dock(FILL)

				table.insert(panels, row)
				table.insert(panels, res)
			end

			local Craft = vgui.Create("FWUIButton", panel)
			Craft:SetTall(fw.resource.INFO_ROW_HEIGHT)
			Craft:SetText("Craft")

			Craft.DoClick = function()
				net.Start("fw.createOpioid")
					net.WriteEntity(ent)
					net.WriteString(name)
				net.SendToServer()
			end

			local Back = vgui.Create("FWUIButton", panel)
			Back:SetTall(fw.resource.INFO_ROW_HEIGHT)
			Back:SetText("Back")

			Back.DoClick = function()

				clearPanels()
			 	populate()
			end

			table.insert(panels, Back)
			table.insert(panels, Craft)

		end

	end

end
