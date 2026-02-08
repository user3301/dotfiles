-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Function to get system appearance and set theme accordingly
local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Frappe"
	else
		return "Catppuccin Latte"
	end
end

-- Function to get background gradient based on appearance
local function gradient_for_appearance(appearance)
	if appearance:find("Dark") then
		return {
			orientation = "Vertical",
			colors = {
				"#232634", -- Catppuccin Frappe Crust
				"#292c3c", -- Catppuccin Frappe Mantle
				"#303446", -- Catppuccin Frappe Base
			},
			interpolation = "Linear",
			blend = "Rgb",
		}
	else
		return {
			orientation = "Vertical",
			colors = {
				"#dce0e8", -- Catppuccin Latte Crust
				"#e6e9ef", -- Catppuccin Latte Mantle
				"#eff1f5", -- Catppuccin Latte Base
			},
			interpolation = "Linear",
			blend = "Rgb",
		}
	end
end

-- Automatically switch theme based on system appearance
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.window_background_gradient = gradient_for_appearance(wezterm.gui.get_appearance())

config.window_background_opacity = 1

config.window_decorations = "INTEGRATED_BUTTONS"

config.scrollback_lines = 5000

config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono" },
	{ family = "Ubuntu Mono" },
	{ family = "More Perfect DOS VGA" },
})
config.font_size = 15

config.initial_rows = 40
config.initial_cols = 120

-- Enable image protocols
config.enable_kitty_graphics = true
config.enable_kitty_keyboard = true

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
