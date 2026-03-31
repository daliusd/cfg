local wezterm = require('wezterm')

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.scrollback_lines = 10000

config.color_scheme = 'zenbones'
config.font = wezterm.font_with_fallback({
  { family = 'VictorMono Nerd Font Mono', weight = 'Bold' },
  { family = 'Symbols Nerd Font Mono', weight = 'Regular' },
})

local f = io.popen('uname')
local s = f:read('*a')
s = s:gsub('%s+', '')
f:close()

if s == 'Linux' then
  -- nothing to do
else
  config.window_decorations = 'RESIZE'
end

if s == 'Linux' then
  config.font_size = 15
else
  config.font_size = 17
end

config.window_frame = {
  font = wezterm.font({ family = 'VictorMono Nerd Font Mono', weight = 'Bold' }),

  font_size = s == 'Linux' and 15.0 or 17.0,
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

wezterm.on('toggle-tabbar', function(window, _)
  local overrides = window:get_config_overrides() or {}
  overrides.enable_tab_bar = window:get_dimensions().is_full_screen
  window:toggle_fullscreen()
  window:set_config_overrides(overrides)
end)

local process_icons = {
  nvim = '',
  fish = '󰈺',
  ssh = '󰣀',
  docker = '',
  node = '󰎙',
  ['volta-shim'] = '󰎙',
  python = '',
  ruby = '',
  go = '',
  claude = '',
  codex = '󰘦',
}

wezterm.on('format-tab-title', function(tab)
  local proc = string.gsub(tab.active_pane.foreground_process_name, '(.*[/\\])(.*)', '%2')
  local icon = proc:match('^codex') and '󰘦' or process_icons[proc] or ''

  local cwd = tab.active_pane.current_working_dir
  local last = cwd
    and (
      (type(cwd) == 'string' and cwd:gsub('^file://[^/]*', '') or cwd.file_path):gsub('[/\\]+$', ''):match('([^/\\]+)$')
    )

  return {
    { Foreground = { Color = '#ffffff' } },
    { Text = '{' .. icon .. '}' },
    { Foreground = { Color = '#a4a8a8' } },
    { Text = string.format(' %s', last or '') },
  }
end)

config.keys = {
  {
    key = 'c',
    mods = 'CMD',
    action = wezterm.action.CopyTo('Clipboard'),
  },
  {
    key = 'v',
    mods = 'CMD',
    action = wezterm.action.PasteFrom('Clipboard'),
  },
  {
    key = 's',
    mods = 'ALT',
    action = wezterm.action.ActivateCopyMode,
  },
  {
    key = 'n',
    mods = 'ALT',
    action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
  },
  {
    key = 'm',
    mods = 'ALT',
    action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
  },
  {
    key = 't',
    mods = 'ALT',
    action = wezterm.action_callback(function(window, pane)
      local tabs = window:mux_window():tabs_with_info()

      local current_index = 0
      for _, tab_info in ipairs(tabs) do
        if tab_info.is_active then
          current_index = tab_info.index
          break
        end
      end

      window:mux_window():spawn_tab({})
      window:perform_action(wezterm.action.MoveTab(current_index + 1), pane)
    end),
  },
  {
    key = 'k',
    mods = 'ALT',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'j',
    mods = 'ALT',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'h',
    mods = 'ALT',
    action = wezterm.action.MoveTabRelative(-1),
  },
  {
    key = 'l',
    mods = 'ALT',
    action = wezterm.action.MoveTabRelative(1),
  },
  {
    key = 'DownArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection('Down'),
  },
  {
    key = 'UpArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection('Up'),
  },
  {
    key = 'LeftArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection('Left'),
  },
  {
    key = 'RightArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection('Right'),
  },
  {
    key = 'DownArrow',
    mods = 'ALT|SHIFT',
    action = wezterm.action.AdjustPaneSize({ 'Down', 1 }),
  },
  {
    key = 'UpArrow',
    mods = 'ALT|SHIFT',
    action = wezterm.action.AdjustPaneSize({ 'Up', 1 }),
  },
  {
    key = 'LeftArrow',
    mods = 'ALT|SHIFT',
    action = wezterm.action.AdjustPaneSize({ 'Left', 1 }),
  },
  {
    key = 'RightArrow',
    mods = 'ALT|SHIFT',
    action = wezterm.action.AdjustPaneSize({ 'Right', 1 }),
  },
  {
    key = 'u',
    mods = 'ALT',
    action = wezterm.action.QuickSelectArgs({
      label = 'open url',
      patterns = { 'https?://\\S+' },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.open_with(url)
      end),
    }),
  },
  {
    key = 'g',
    mods = 'ALT',
    action = wezterm.action.QuickSelectArgs({
      label = 'select hash',
      patterns = { '[a-f0-9]{6,}' },
      action = wezterm.action_callback(function(window, pane)
        local hash = window:get_selection_text_for_pane(pane)
        pane:send_text(hash)
      end),
    }),
  },
  {
    key = 'p',
    mods = 'ALT',
    action = wezterm.action.QuickSelectArgs({
      label = 'select path',
      patterns = { '[a-zA-Z0-9-.]*\\/\\S+' },

      action = wezterm.action_callback(function(window, pane)
        local hash = window:get_selection_text_for_pane(pane)
        pane:send_text(hash)
      end),
    }),
  },
  {
    key = 'N',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = '-',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = '_',
    mods = 'CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = '_',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  },
}

local mux = wezterm.mux

wezterm.on('gui-startup', function()
  local tab, pane, window = mux.spawn_window({})
  window:gui_window():maximize()
end)

wezterm.on('update-right-status', function(window, pane)
  local date = wezterm.strftime('%Y-%m-%d %H:%M:%S')

  -- Make it italic and underlined
  window:set_right_status(wezterm.format({
    { Text = date .. ' ' },
  }))
end)

config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0.25cell',
  bottom = '0.1cell',
}

return config
