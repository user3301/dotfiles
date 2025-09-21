-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Catppuccin Frappe"

config.window_decorations = "INTEGRATED_BUTTONS"

config.scrollback_lines = 5000

config.font = wezterm.font("JetBrains Mono", { bold = false, italic = false })
config.font_size = 14.5

config.initial_rows = 40
config.initial_cols = 120

config.leader = {
	key = "a",
	mods = "CTRL",
	timeout_milliseconds = 1000,
}

-- ⌨️ Key bindings that use the leader key
config.keys = {
	-- Split pane horizontally: leader + "
	{
		key = '"',
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	-- Split pane vertically: leader + %
	{
		key = "%",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- Close current pane with confirmation: leader + x
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},

	-- Move between panes using vim-style keys
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
}

-- and finally, return the configuration to wezterm
return config
