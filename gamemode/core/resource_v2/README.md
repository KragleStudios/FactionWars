# Resources

## Entity Fields
Resource Consumers
```Lua
ENT.MaxConsumption = {
	['resource name'] = amount,
}

function ENT:Initialize()
	-- setup how much it actually consumes
	self.Consumes = {
		['resource name'] = amount,
	}

	-- or if you want to take resources from storage entities at an interval then you can do that instead
	timer.Create('ent-consume-'..self:EntIndex(), 5, 0, function()
		local succ = self:ConsumeResource('resource name', amount)
		-- succ returns wether or not it successfully consumed the resource, the resource gets transfered into the haveResources table so you can check for it with
		if self:FWHaveResource('resource name') >= amount then
		   ...
		end
	end)
end
```


## Entity Functions (implement optionally)
 - SERVER SIDE ENT:IsActive() : bool - returns wether or not the entity has enough resources to run. This is only meaningful on producers and it will disable them if this field returns false. You can also self.Production to an empty table to indicate that the entity doesn't have any productive capability.
 - CLIENT SIDE ENT:CustomUI(parent panel) - this gets called whenever an entity's resource info panel is pulled up. It is called with a panel that is an instance of STYLayoutVertical. You can add your custom panels to this and it will get displayed as a part of the 3d entity info. Buttons will work with the use key so they can be included in your UI. TextBoxes will not work. It is recommended that you use an instance of vgui.Create('fwEntityInfoPanel') and parent your ui to this panel so that it will be themed properly with the rest of the entity info UI. The global fw.resource.INFO_ROW_HEIGHT is provided for you to properly set the row height for your custom info. We recommend you set the height of your panel to this value. If you need multiple rows of info just create multiple panels.
