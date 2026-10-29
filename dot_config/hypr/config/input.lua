-- Input configuration

hl.config({
	input = {
		sensitivity = 0.1,
		accel_profile = "flat",
		kb_layout = "us,si", -- list every layout you want
		kb_variant = "",
		kb_options = "grp:alt_shift_toggle", -- Alt+Shift cycles between them
	},
})

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down", action = "close" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left", action = "float" })
