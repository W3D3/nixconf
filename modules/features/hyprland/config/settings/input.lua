hl.config({
	input = {
		kb_layout = "eu",
		follow_mouse = 1,

		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
		},

		sensitivity = -0.3,
		force_no_accel = false,
		tablet = {
			left_handed = true,
			output = "current",
		},
	},
	cursor = {
		inactive_timeout = 2,
		hide_on_key_press = true,
		warp_on_change_workspace = 1,
		warp_on_toggle_special = 1,
		persistent_warps = true,
	},
})
