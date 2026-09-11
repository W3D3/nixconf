-- Get window position relative to monitor
local function normalise_current_window_pos()
	local active = hl.get_active_window()
	if active then
		local xpos = active.at.x
		if xpos > 1920 then
			xpos = xpos - 1920
			return xpos
		elseif xpos < 1 then
			xpos = xpos + 1920
			return xpos
		else
			return xpos
		end
	end
end

local function notif(text, timeout, icon)
	hl.notification.create({
		text = text or "notification",
		timeout = timeout or 2000,
		icon = icon or "ok",
	})
end

local mainMod = "SUPER + "
local recordingMode = 0

local globalAppBinds = {

	---- Window functions
	{ key = { "BACKSPACE" }, dispatch = hl.dsp.window.close() },
	{ key = { "b" }, dispatch = hl.dsp.window.fullscreen({ action = "toggle" }) },
	{ mod = mainMod, key = { "space" }, dispatch = hl.dsp.window.float() },

	---- Apps
	-- Launcher
	{
		key = { "d" },
		dispatch = function()
			if hl.get_windows({ class = "otter" })[1] ~= nil then
				hl.dispatch(hl.dsp.focus({ window = "class:otter" }))
			else
				hl.exec_cmd("kitty --class otter --title otter-launcher -e sh -c 'sleep 0.05 && otter-launcher'")
			end
		end,
	},

	-- Terminal
	{
		key = { "RETURN" },
		dispatch = function()
			if recordingMode == 1 then
				hl.exec_cmd("kitty -o font_size=24 -o window_margin_width=20")
			else
				hl.exec_cmd("kitty")
			end
		end,
	},

	-- Browsers
	{ key = { "f" }, dispatch = "firefox" },
	{ key = { "o" }, dispatch = "google-chrome-stable" },

	-- File browser
	{ key = { "s" }, dispatch = "nemo" },

	---- Move windows
	{ key = { "k" }, dispatch = hl.dsp.focus({ direction = "up" }) },
	{ key = { "j" }, dispatch = hl.dsp.focus({ direction = "down" }) },
	{ key = { "SHIFT + h" }, dispatch = hl.dsp.layout("swapcol l") },
	{ key = { "SHIFT + l" }, dispatch = hl.dsp.layout("swapcol r") },
	{
		key = { "l" },
		dispatch = function()
			hl.dispatch(hl.dsp.layout("move +col"))
			if not normalise_current_window_pos() then
				hl.dispatch(hl.dsp.layout("move -col"))
				hl.dispatch(hl.dsp.focus({ monitor = "right" }))
			end
		end,
	},
	{
		key = { "h" },
		dispatch = function()
			local pos = normalise_current_window_pos()
			if pos and pos == 9 then
				hl.dispatch(hl.dsp.focus({ monitor = "left" }))
			else
				hl.dispatch(hl.dsp.layout("move -col"))
			end
		end,
	},

	---- Special Workspaces
	{ key = { "m" }, dispatch = hl.dsp.workspace.toggle_special("music") },
	{ key = { "minus" }, dispatch = hl.dsp.workspace.toggle_special("scratch") },
	{ key = { "SHIFT + minus" }, dispatch = hl.dsp.window.move({ workspace = "special:scratch", follow = false }) },

	-- Recording mode
	{
		key = { "z" },
		dispatch = function()
			if recordingMode == 0 then
				recordingMode = 1
				hl.exec_cmd(
					"wshowkeys -a right -F 'FiraMono Nerd Font 35' -s '#cba6f7ff' -f  '#cdd6f4ff' -b '#45475a99' -m 70 -l 60 -t 1000 -a top"
				)
				notif("Recording Mode Enabled")
			else
				recordingMode = 0
				hl.exec_cmd("pkill wshowkeys")
				notif("Recording Mode Disabled")
			end
		end,
	},

	{
		key = { "x" },
		dispatch = function()
			if recordingMode == 1 then
				hl.exec_cmd("woomer --output DP-1 --radius 2 --monitor DP-1 -S")
			end
		end,
	},

	-- Logout menu
	{ key = { "a" }, dispatch = "quickshell ipc call root openLogoutMenu" },

	-- Screenshot
	{ mod = mainMod, key = { "SHIFT + s" }, dispatch = "grimblast copy area" },

	-- Mouse for moving windows
	{ mod = mainMod, key = { "mouse:272" }, dispatch = hl.dsp.window.drag(), opts = { mouse = true } },
	{ mod = mainMod, key = { "mouse:272" }, dispatch = hl.dsp.window.float(), opts = { mouse = true, click = true } },
	{
		mod = mainMod,
		key = { "mouse:272" },
		dispatch = hl.dsp.layout("promote"),
		opts = { mouse = true, release = true },
	},
	{ mod = mainMod, key = { "SHIFT + mouse:272" }, dispatch = hl.dsp.window.resize(), opts = { mouse = true } },
}

for _, bind in ipairs(globalAppBinds) do
	local modBind = bind.mod or mainMod
	local command

	if type(bind.dispatch) ~= "string" then
		command = bind.dispatch
	else
		command = hl.dsp.exec_cmd(bind.dispatch)
	end

	local opts = bind.opts or {}
	hl.bind(modBind .. bind.key[1], command, opts)
end

-- Media keys
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- Workspace switch keys (q w e r t y u i o p → workspaces 1–10)
local keyboardSplit = {}
for char in ("qwertyuiop"):gmatch(".") do
	table.insert(keyboardSplit, char)
end

for index, key in ipairs(keyboardSplit) do
	hl.bind(mainMod .. key, hl.dsp.focus({ workspace = index }))
	hl.bind(mainMod .. "SHIFT + " .. key, hl.dsp.window.move({ workspace = index, follow = false }))
end
