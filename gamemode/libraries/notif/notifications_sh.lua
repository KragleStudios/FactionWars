fw.notif.colors = {
	[color_black] = 1,		-- black
	[color_white] = 2,		-- white
	[Color(255, 0, 0)] = 3, -- red
	[Color(0, 255, 0)] = 4, -- green
	[Color(0, 0, 255)] = 5, -- blue
}

-- can't index with colors normally, so we have to use __index
setmetatable(fw.notif.colors, {
	__index = function(self, key)
		for k, v in pairs(self) do
			if (k == key) then
				return v
			end
		end
	end
})