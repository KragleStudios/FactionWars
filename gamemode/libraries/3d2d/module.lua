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

local isUsePressed = false
hook.Add( "KeyPress", "fw.3d2d.KeyPress", function( ply, key )
	if key ~= IN_USE then return end
	isUsePressed = true
end)

hook.Add("KeyRelease", "fw.3d2d.KeyRelease", function(ply, key)
	if key ~= IN_USE then return end
	isUsePressed = false
end)


--
-- HELPER FUNCTIONS
--
local function hoveredPanel(panel, mx, my)
	if not panel:IsVisible() or not panel:IsMouseInputEnabled() then return end
	local w, h = panel:GetSize()
	local x, y = panel:GetPos()
	if mx < x or my < y or mx > w + x or my > h + y then return end

	mx = mx - x
	my = my - y
	for _, child in ipairs(panel:GetChildren()) do
		local hovered = hoveredPanel(child, mx, my)
		if hovered then return hovered end
	end

	return panel
end

local Panel = FindMetaTable('Panel')

function Panel:Draw3D(pos, ang, scale)
	assert(type(pos) == 'Vector' and type(ang) == 'Angle' and type(scale) == 'number', 'bad parameters')
	local w, h = self:GetSize()

	pos = pos - ang:Forward() * (w * 0.5 * scale) - ang:Right() * (h * 0.5 * scale)

	local oldGetHoveredPanel = vgui.GetHoveredPanel
	local oldGuiMousePos = gui.MousePos
	local oldGuiMouseX = gui.MouseX
	local oldGuiMouseY = gui.MouseY
	local oldInputGetCursorPos = input.GetCursorPos

	local cursorX, cursorY
	do
		local realMouseX, realMouseY = gui.MousePos()
		if realMouseX == 0 and realMouseY == 0 then
			realMouseX, realMouseY = ScrW() * 0.5, ScrH() * 0.5
		end

		local cursorNormal = gui.ScreenToVector(realMouseX, realMouseY)
		local eyePos = LocalPlayer():EyePos()

		local nUp, nForward, nRight = ang:Up(), ang:Forward(), ang:Right( );

		local cursor3d = util.IntersectRayWithPlane(eyePos, cursorNormal, pos, nUp)
		if cursor3d then
			local w = cursor3d-pos;
		 	cursorX = w:DotProduct(nForward)/scale
			cursorY = w:DotProduct(nRight)/scale

			-- actually find the hovered panel and do stuff with it
			local hovered = hoveredPanel(self, cursorX, cursorY)

			if hovered ~= self.__last_hovered then
				if IsValid(self.__last_hovered) and self.__last_hovered.OnCursorExited then
					self.__last_hovered:OnCursorExited()
				end
				if IsValid(hovered) and hovered.OnCursorEntered then
					hovered:OnCursorEntered()
				end
				self.__last_hovered = hovered
			end

			if isUsePressed ~= self.__wasUsePressed then
				if self.__wasUsePressed == false and isUsePressed == true and IsValid(hovered) then
					self.__pressedPanel = hovered
					if hovered.OnMousePressed then hovered:OnMousePressed(MOUSE_LEFT) end
				end
				if IsValid(self.__pressedPanel) and isUsePressed == false then
					if self.__pressedPanel.OnMouseReleased then self.__pressedPanel:OnMouseReleased(MOUSE_LEFT) end
					--if self.__pressedPanel.DoClick and self.__pressedPanel == hovered then self.__pressedPanel:DoClick(MOUSE_LEFT) end
					self.__pressedPanel = nil
				end
				self.__wasUsePressed = isUsePressed
			end

			vgui.GetHoveredPanel = function()
				return hovered
			end

		end
	end

	cam.Start3D2D(pos, ang, scale)
		self:SetPaintedManually( false );
		local succ, err = pcall(self.PaintManual, self, -w*0.5, -h*0.5)
		self:SetPaintedManually( true );
	cam.End3D2D()

	vgui.GetHoveredPanel = oldGetHoveredPanel
	gui.MousePos = oldGuiMousePos
	gui.MouseX = oldGuiMouseX
	gui.MouseY = oldGuiMouseY
	input.GetCursorPos = oldInputGetCursorPos

	if not succ then
		error(err)
	end
end
