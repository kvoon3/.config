local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { 'C:/Program Files/Git/bin/bash.exe', '-l' }

local function scheme()
  return wezterm.gui.get_appearance():find('Dark') and 'Vitesse Black' or 'Vitesse Light Soft'
end
config.color_scheme = scheme()

wezterm.on('window-config-reloaded', function(window)
  window:set_config_overrides({ color_scheme = scheme() })
end)

return config
