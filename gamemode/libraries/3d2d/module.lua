if SERVER then AddCSLuaFile() return end

require 'ra'

--[[
RECOMMENDED VERSION
VERSION 1.0.0
Copyright thelastpenguin™ 
	All rights are reserved.
	Neither this script nor any edit of this script or partial code segment taken from this script
	may be used in any form without explicit permission from it's creator thelastpenguin™ 
	
	If you modify the code for any purpose, the above still applies to the modified code.
	
	The author is not held responsible for any d amages incured from the use of 3d2d UI Lib
]]
vgui3d = {};

local _R = debug.getregistry()

-- load functional libs

--[[
FUNCTION: calculate cursor position and any panels the cursor is hovering over
]]

do
	local function checkHovered( p, mx, my )
		if not p:IsVisible() or not p:IsMouseInputEnabled() then return end
		
		local w, h = p:GetSize();
		local x, y = p:GetPos();
		mx, my = mx-x, my-y;
		
		if mx < 0 or my < 0 or mx > w or my > h then
			return ;
		end
		
			
		local ph ;
		for _,p in pairs( p:GetChildren( ) )do
			ph = checkHovered( p, mx, my );
			if ph then return ph end
		end
		
		return p;
	end
	
	local xfn_true = function() return true end
	local xfn_false = function() return false end
	function _R.Panel:DoCursor( vOrigin, cursorNormal )
		local w, h = self:GetSize();
		
		-- perform projections
		local mousex, mousey = self:ProjectCursor( vOrigin, cursorNormal );
		self.mousex, self.mousey = mousex, mousey;
		
		local hovered = checkHovered( self, mousex, mousey );
		
		if self.hoveredPanel ~= hovered then
			
			-- reset the old hovered panel
			if ValidPanel( self.hoveredPanel ) then
				self.hoveredPanel.IsHovered = xfn_false;
				self.hoveredPanel.Hovered = false;
				
				(self.hoveredPanel.OnCursorExited or ra.fn.noop)( self.hoveredPanel );
				
			end
			
			-- set the new hovered panel
			if hovered then
				hovered.IsHovered = xfn_true;
				hovered.Hovered = true;
				(hovered.OnCursorEntered or ra.fn.noop)( hovered );
			end
			self.hoveredPanel = hovered;
		end
		
		if not hovered then
			self.HasCursor = true;
		else
			self.HasCursor = false;
		end
		
	end
end

--[[
FUNCTION: cache variables before any 3d rendering operation
]]
vgui.GetHoveredPanelOrig = vgui.GetHoveredPanelOrig or vgui.GetHoveredPanel ;
gui.MousePosOrig = gui.MousePosOrig or gui.MousePos ;
gui.MouseXOrig = gui.MouseXOrig or gui.MouseX ;
gui.MouseYOrig = gui.MouseYOrig or gui.MouseY ;

function _R.Panel:Begin3D( vOrigin, vAngles, cursorNormal )
	-- calculate the panel location
	local pos, ang, scale = self:CalcLocation( vOrigin, vAngles )
	local nUp, nForward, nRight = ang:Up(), ang:Forward(), ang:Right( );
	
	-- the top left corner
	pos = pos - nForward*(self:GetWide()*0.5*scale) - nRight*(self:GetTall()*0.5*scale);
	
	self.wPos, self.wAng, self.wScale = pos, ang, scale 
	
	vgui.GetHoveredPanel = function()
		return self.hoveredPanel;
	end
	
end
function _R.Panel:End3D( )
	vgui.GetHoveredPanel = vgui.GetHoveredPanelOrig ;
end

--[[
FUNCTION: paint the panel in 3d space
		NOTE: should be called after :Begin3D 
]]
function _R.Panel:Paint3D( )
	cam.Start3D2D( self.wPos, self.wAng, self.wScale );
		cam.IgnoreZ( true );
		
		self:SetPaintedManually( false );
		self:PaintManual( );
		self:SetPaintedManually( true );
		
		cam.IgnoreZ( false );
	cam.End3D2D( );
end

--[[
FUNCTION: project the cursor defined by noraml vector cursorNormal onto the world plane of the panel
RETURNS: mousex, mousey
]]
function _R.Panel:ProjectCursor( vOrigin, cursorNormal ) -- gui.ScreenToVector( gui.MousePos() )
	
	-- cache variables.
	local wPos, wAng, wScale = self.wPos, self.wAng, self.wScale;
	local nUp, nForward, nRight = wAng:Up(), wAng:Forward(), wAng:Right( );

	-- intersect the cursorNormal with the panel's world plane
	local wCursor = util.IntersectRayWithPlane( vOrigin, cursorNormal, wPos, nUp ) or Vector(0,0,0);
	
	local ux = nForward -- unit vector on x axis.
	local uy = nRight -- unit vector on y axis
	
	local w = wCursor-wPos;
	local mousex = w:DotProduct(ux)/wScale;
	local mousey = w:DotProduct(uy)/wScale;
	
		
	return mousex, mousey;
	
end




-- process all panels.
local userpanels = {};

function vgui.make3d( panel )
	table.insert( userpanels, panel );	
end

local _vOrigin, _vAngle
function vgui.set3d2dOrigin(vOrigin, vAngle)
	_vOrigin = vOrigin
	_vAngle = vAngle
end


local function draw( )
	local cursorNormal = gui.ScreenToVector(gui.MousePos())
	local vOrigin = LocalPlayer():EyePos();
	local vAngle = LocalPlayer():EyeAngles();

	for k,v in pairs( userpanels )do
		v:KillFocus( );
		v:Begin3D( vOrigin, vAngle, cursorNormal );
		v:DoCursor( _vOrigin or vOrigin, cursorNormal );
		v:Paint3D( vOrigin, vAngle, cursorNormal );
		v:End3D();
	end
end

hook.Add('PostDrawTranslucentRenderables', 'ba-3d2d-p', function()
	
	userpanels = ra.util.filter( userpanels, ValidPanel );
	
	-- PREVENT PIXELATION
	for i = 1, 8 do
		render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	end
	local succ, err = pcall( draw );
	if not succ then
		MsgC( Color(255,0,0), 'FAILED TO DRAW TRANSLUCENT RENDERABLES!\n');
		print( err );
	end
	
	render.SetViewPort(0,0,ScrW(),ScrH());
	render.SetScissorRect(0,0,0,0,false);
	DisableClipping( true );
	
	for i = 1, 8 do
		render.PopFilterMag()
		render.PopFilterMin()
	end
end);


function vgui.CalcParentedOffset( _offset, angle, scale )
	
	local offset = angle:Forward()*_offset.x + angle:Right()*_offset.y + angle:Up()*_offset.z;
	
	local ang = offset:Angle();
	ang:RotateAroundAxis( ang:Right(), 90 );
	ang:RotateAroundAxis( ang:Up(), -90 );
	ang.r = 90
	
	return function( self, pos, _ang )
		local campos = pos + offset;
		return campos, ang, scale;
	end
	
end

hook.Add( 'PlayerBindPress', '3d2d', function( pl, bind, pressed )
	if bind:find('+use') then
		if pressed then
			for k,v in pairs( userpanels )do
				if v.hoveredPanel then
					return false ;
				end
			end
		end
	end
end)



local lastMouseRight = false
local lastMouseLeft = false
hook.Add('Think', '3d2d_mouse', function()
	local mouseLeft = input.IsMouseDown(MOUSE_LEFT)
	local mouseRight = input.IsMouseDown(MOUSE_RIGHT)

	if mouseLeft and not lastMouseLeft then
		lastMouseLeft = true
		for k,v in pairs(userpanels)do
			if v.hoveredPanel then
				if v.hoveredPanel.OnMousePressed then v.hoveredPanel:OnMousePressed(MOUSE_LEFT) end
				if v.hoveredPanel.DoClick then v.hoveredPanel:DoClick(MOUSE_LEFT) end
			end
		end
	elseif lastMouseLeft and not mouseLeft then
		lastMouseLeft = false
		for k,v in pairs(userpanels)do
			if v.hoveredPanel then
				if v.hoveredPanel.OnMouseReleased then v.hoveredPanel:OnMouseReleased(MOUSE_LEFT) end
			end
		end
	end

	if mouseRight and not lastMouseRight then
		lastMouseRight = true
		for k,v in pairs(userpanels)do
			if v.hoveredPanel then
				if v.hoveredPanel.OnMousePressed then v.hoveredPanel:OnMousePressed(MOUSE_RIGHT) end
				if v.hoveredPanel.DoClick then v.hoveredPanel:DoClick(MOUSE_RIGHT) end
			end
		end
	elseif lastMouseRight and not mouseRight then
		lastMouseRight = false
		for k,v in pairs(userpanels)do
			if v.hoveredPanel then
				if v.hoveredPanel.OnMouseReleased then v.hoveredPanel:OnMouseReleased(MOUSE_RIGHT) end
			end
		end
	end

end)
