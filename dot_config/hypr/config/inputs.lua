-- Input configuration

hl.config({
	input = {
		sensitivity = 0.25,
		accel_profile = "flat",
		kb_layout = "us,si", -- list every layout you want
		kb_variant = "",
		kb_options = "grp:alt_shift_toggle", -- Alt+Shift cycles between them
	},
	-- Software cursors: hardware cursor is invisible on RX 580 with kernel 7.3 (2026-10-23)
	cursor = {
	    no_hardware_cursors = 1,
	},
})

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down", action = "close" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left", action = "float" })
