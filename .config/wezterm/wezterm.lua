local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'zenbones'
config.font = wezterm.font { family = 'VictorMono Nerd Font Mono', weight = 'Bold' }
config.font_size = 17

config.window_frame = {
  font = wezterm.font { family = 'VictorMono Nerd Font Mono', weight = 'Bold' },

  font_size = 17.0,
  active_titlebar_bg = '#2c363c',
  inactive_titlebar_bg = '#2c363c',
}

config.colors = {
  tab_bar = {
    inactive_tab_edge = '#2c363c',
  },
}

-- Disable ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.keys = {
  {
    key = 's',
    mods = 'CMD',
    action = wezterm.action.ActivateCopyMode,
  },
  {
    key = '_',
    mods = 'CMD',
    action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
  },
  {
    key = '|',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
  },
  {
    key = 'k',
    mods = 'CMD',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'j',
    mods = 'CMD',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'h',
    mods = 'CMD',
    action = wezterm.action.MoveTabRelative(-1),
  },
  {
    key = 'l',
    mods = 'CMD',
    action = wezterm.action.MoveTabRelative(1),
  },
  {
    key = 'DownArrow',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection "Down",
  },
  {
    key = 'UpArrow',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection "Up",
  },
  {
    key = 'LeftArrow',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection "Left",
  },
  {
    key = 'RightArrow',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection "Right",
  },
  {
    key = 'DownArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.AdjustPaneSize { "Down", 1 },
  },
  {
    key = 'UpArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.AdjustPaneSize { "Up", 1 },
  },
  {
    key = 'LeftArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.AdjustPaneSize { "Left", 1 },
  },
  {
    key = 'RightArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.AdjustPaneSize { "Right", 1 },
  },
  {
    key = 'u',
    mods = 'CMD',
    action = wezterm.action.QuickSelectArgs {
      label = 'open url',
      patterns = { 'https?://\\S+' },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.open_with(url)
      end),
    },
  },
  {
    key = 'g',
    mods = 'CMD',
    action = wezterm.action.QuickSelectArgs {
      label = 'select hash',
      patterns = { '[a-f0-9]{6,}' },
      action = wezterm.action_callback(function(window, pane)
        local hash = window:get_selection_text_for_pane(pane)
        pane:send_text(hash)
      end),
    },
  },
}

local mux = wezterm.mux

wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window {}
  window:gui_window():maximize()
end)

return config
