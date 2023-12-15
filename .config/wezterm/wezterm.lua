local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.scrollback_lines = 10000

config.color_scheme = 'zenbones'
config.font = wezterm.font { family = 'VictorMono Nerd Font Mono', weight = 'Bold' }

config.window_decorations = "RESIZE"

local f = io.popen("uname")
local s = f:read("*a")
s = s:gsub("%s+", "")
f:close()

if (s == "Linux") then
  config.font_size = 13
else
  config.font_size = 17
end

config.window_frame = {
  font = wezterm.font { family = 'VictorMono Nerd Font Mono', weight = 'Bold' },

  font_size = s == "Linux" and 13.0 or 17.0,
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
    key = 'f',
    mods = 'CMD',
    action = wezterm.action.ToggleFullScreen,
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
    key = 't',
    mods = 'CMD',
    action = wezterm.action_callback(function(window, pane)
      local tabs = window:mux_window():tabs_with_info()

      local current_index = 0
      for _, tab_info in ipairs(tabs) do
        if tab_info.is_active then
          current_index = tab_info.index
          break
        end
      end

      window:mux_window():spawn_tab {}
      window:perform_action(wezterm.action.MoveTab(current_index + 1), pane)
    end),
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
  {
    key = 'p',
    mods = 'CMD',
    action = wezterm.action.QuickSelectArgs {
      label = 'select path',
      patterns = { '[a-zA-Z0-9]*\\/\\S+' },

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

local function get_current_working_dir(tab)
  local current_dir = tab.active_pane.current_working_dir
  local HOME_DIR = string.format('file://%s', os.getenv('HOME'))

  return current_dir == HOME_DIR and '.'
      or string.gsub(current_dir, '(.*[/\\])(.*)', '%2')
end

local function get_process(tab)
  local process_name = string.gsub(tab.active_pane.foreground_process_name, '(.*[/\\])(.*)', '%2')
  return process_name
end

wezterm.on(
  'format-tab-title',
  function(tab)
    local has_unseen_output = false
    if not tab.is_active then
      for _, pane in ipairs(tab.panes) do
        if pane.has_unseen_output then
          has_unseen_output = true
          break
        end
      end
    end

    local title = string.format('%s', get_process(tab))

    if has_unseen_output then
      return {
        { Foreground = { Color = 'Orange' } },
        { Text = title },
      }
    end
    return {
      { Text = title },
    }
  end
)



wezterm.on('update-right-status', function(window, pane)
  local date = wezterm.strftime '%Y-%m-%d %H:%M:%S'

  -- Make it italic and underlined
  window:set_right_status(wezterm.format {
    { Text = date .. ' ' },
  })
end)

config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0.25cell',
  bottom = 0,
}

return config
