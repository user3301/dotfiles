-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Gruvbox Dark (Gogh)"

config.font = wezterm.font("ZedMono Nerd Font", { bold = false, italic = false })
config.font_size = 16

config.initial_rows = 40
config.initial_cols = 120

-- and finally, return the configuration to wezterm
return config
