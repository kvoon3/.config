local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- OpenGL renders a blank window on this AMD driver; WebGpu is the working path.
config.front_end = 'WebGpu'

config.default_prog = { 'wsl.exe', '-d', 'Ubuntu-24.04', '--cd', '~/i' }

config.font = wezterm.font_with_fallback {
  'Ioskeley Mono Term',
  'MesloLGM Nerd Font Mono',
  'Microsoft YaHei',
}
config.font_size = 14.0
config.line_height = 1.0

local vitesse_black = {
  foreground = '#dbd7ca',
  background = '#000000',
  cursor_bg = '#dbd7ca',
  cursor_fg = '#000000',
  cursor_border = '#dbd7ca',
  selection_fg = '#dbd7ca',
  selection_bg = '#111111',
  scrollbar_thumb = '#777777',
  split = '#444444',
  ansi = { '#000000', '#cb7676', '#4d9375', '#e6cc77', '#6394bf', '#d9739f', '#5eaab5', '#dbd7ca' },
  brights = { '#777777', '#cb7676', '#4d9375', '#e6cc77', '#6394bf', '#d9739f', '#5eaab5', '#ffffff' },
  tab_bar = {
    background = '#121212',
    active_tab = { bg_color = '#000000', fg_color = '#dbd7ca' },
    inactive_tab = { bg_color = '#121212', fg_color = '#777777' },
    inactive_tab_hover = { bg_color = '#121212', fg_color = '#dbd7ca' },
    new_tab = { bg_color = '#121212', fg_color = '#777777' },
    new_tab_hover = { bg_color = '#000000', fg_color = '#dbd7ca' },
  },
}

local vitesse_light_soft = {
  foreground = '#393a34',
  background = '#F1F0E9',
  cursor_bg = '#393a34',
  cursor_fg = '#F1F0E9',
  cursor_border = '#393a34',
  selection_fg = '#393a34',
  selection_bg = '#e5e5e3',
  scrollbar_thumb = '#999999',
  split = '#999999',
  ansi = { '#F1F0E9', '#ab5959', '#1e754f', '#bda437', '#296aa3', '#a13865', '#2993a3', '#393a34' },
  brights = { '#aaaaaa', '#ab5959', '#1e754f', '#bda437', '#296aa3', '#a13865', '#2993a3', '#dddddd' },
  tab_bar = {
    background = '#E7E5DB',
    active_tab = { bg_color = '#F1F0E9', fg_color = '#393a34' },
    inactive_tab = { bg_color = '#E7E5DB', fg_color = '#999999' },
    inactive_tab_hover = { bg_color = '#E7E5DB', fg_color = '#393a34' },
    new_tab = { bg_color = '#E7E5DB', fg_color = '#999999' },
    new_tab_hover = { bg_color = '#F1F0E9', fg_color = '#393a34' },
  },
}

config.color_schemes = {
  ['Vitesse Black'] = vitesse_black,
  ['Vitesse Light Soft'] = vitesse_light_soft,
}

local function scheme()
  return wezterm.gui.get_appearance():find('Dark') and 'Vitesse Black' or 'Vitesse Light Soft'
end
config.color_scheme = scheme()

wezterm.on('window-config-reloaded', function(window)
  window:set_config_overrides({ color_scheme = scheme() })
end)

config.window_background_opacity = 0.85
config.win32_system_backdrop = 'Acrylic'

config.window_decorations = 'RESIZE'
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true
config.tab_max_width = 36
config.audible_bell = 'Disabled'
config.default_cursor_style = 'BlinkingBar'
config.use_ime = true
config.enable_wayland = false

-- Never set enable_kitty_keyboard globally: it drops single-character CJK IME
-- commits on Windows (wezterm#8275). Send CSI-u per key instead.

config.launch_menu = {
  { label = 'PowerShell 7', args = { 'pwsh.exe', '-NoLogo' } },
  { label = 'Ubuntu 24.04 (WSL)', args = { 'wsl.exe', '-d', 'Ubuntu-24.04', '--cd', '~' } },
  { label = 'herdr (WSL)', args = { 'wsl.exe', '-d', 'Ubuntu-24.04', '--cd', '/home/kvoon', '--', 'bash', '-lic', 'herdr' } },
  { label = 'Command Prompt', args = { 'cmd.exe' } },
}

config.keys = {
  { key = 'p', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
  { key = 'p', mods = 'CTRL|SHIFT', action = wezterm.action.SendString '\x1b[112;6u' },
  { key = 'p', mods = 'CTRL|ALT', action = wezterm.action.ActivateCommandPalette },
  { key = ',', mods = 'CTRL', action = wezterm.action.SendString '\x1b[44;5u' },
  { key = '/', mods = 'CTRL', action = wezterm.action.SendString '\x1b[47;5u' },
  { key = '.', mods = 'CTRL', action = wezterm.action.SendString '\x1b[46;5u' },
  { key = "'", mods = 'CTRL', action = wezterm.action.SendString '\x1b[39;5u' },
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = false } },
  { key = 'd', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'r', mods = 'CTRL|SHIFT', action = wezterm.action.ReloadConfiguration },
  { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = '1', mods = 'ALT', action = wezterm.action.ActivateTab(0) },
  { key = '2', mods = 'ALT', action = wezterm.action.ActivateTab(1) },
  { key = '3', mods = 'ALT', action = wezterm.action.ActivateTab(2) },
  { key = '4', mods = 'ALT', action = wezterm.action.ActivateTab(3) },
  { key = '5', mods = 'ALT', action = wezterm.action.ActivateTab(4) },
  { key = 'r', mods = 'CTRL|ALT', action = wezterm.action.PromptInputLine {
      description = 'Rename tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line and #line > 0 then window:active_tab():set_title(line) end
      end),
    } },
}

return config
