fw.notif.colors = {
	color_black,		-- black
	color_white,		-- white
	Color(255, 0, 0),	-- red
	Color(0, 255, 0),	-- green
	Color(0, 0, 255),	-- blue
}

function fw.notif.addColor(color)
	return table.insert(fw.notif.colors, color)
end