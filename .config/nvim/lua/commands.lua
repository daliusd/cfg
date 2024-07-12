-- Commands

vim.api.nvim_create_user_command(
  'YoshiTest',
  function()
    vim.g['test#javascript#runner'] = 'jest'
    vim.g['test#javascript#jest#executable'] = 'yarn yoshi test'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'YoshiLibraryTest',
  function()
    vim.g['test#javascript#runner'] = 'jest'
    vim.g['test#javascript#jest#executable'] = 'yarn yoshi-library test'
  end,
  {}
)

-- format/unformat

vim.api.nvim_create_user_command(
  'FormatJSON',
  function()
    vim.cmd('%!python3 -m json.tool')
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'UnformatJSON',
  function()
    vim.cmd(':%!node ~/bin/unjson.js')
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'FormatSHTOUT',
  function()
    vim.cmd(":%!node ~/bin/sht.js")
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'UnformatSHTOUT',
  function()
    vim.cmd(":%!node ~/bin/usht.js")
    vim.bo.filetype = 'json'
  end,
  {}
)

vim.api.nvim_create_user_command(
  'FormatHtml',
  function()
    vim.cmd("%!tidy -q -i --show-errors 0")
  end,
  {}
)

vim.api.nvim_create_user_command(
  'FormatXml',
  function()
    vim.cmd("%!tidy -q -i --show-errors 0 -xml")
  end,
  {}
)

vim.api.nvim_create_user_command(
  'Rg',
  function(args)
    require("fzf-lua").live_grep_glob({ search = args['args'] })
  end,
  { nargs = '*' }
)

vim.cmd(":cnoreabbrev <expr> rg (getcmdtype() == ':' && getcmdline() ==# 'rg') ? 'Rg' : 'rg'")

local timer
vim.api.nvim_create_autocmd({ "CursorMoved", "ModeChanged" }, {
  desc = "Preview in wezterm",
  callback = function()
    local oil = require("oil")
    if vim.wo.previewwindow then
      return
    end

    -- Debounce and update the preview window
    if timer then
      timer:again()
      return
    end
    timer = vim.loop.new_timer()
    if not timer then
      return
    end
    timer:start(10, 100, function()
      timer:stop()
      timer:close()
      timer = nil
      vim.schedule(function()
        local entry = oil.get_cursor_entry()

        -- Don't update in visual mode. Visual mode implies editing not browsing,
        -- and updating the preview can cause flicker and stutter.
        local mode = vim.api.nvim_get_mode().mode
        local is_visaul_mode = mode:match("^[vV]") ~= nil

        if entry and not is_visual_mode then
          local full_path = oil.get_current_dir() .. entry.name

          -- find focused pane
          local listClientsResult = vim.system({'wezterm', 'cli', 'list-clients', '--format=json'}, { text = true}):wait()
          local focused_pane_id = vim.json.decode(listClientsResult.stdout)[1].focused_pane_id

          local listResult = vim.system({'wezterm', 'cli', 'list', '--format=json'}, { text = true}):wait()
          local panes = vim.json.decode(listResult.stdout)

          -- find relevant tab
          local tab_id = 0
          for _, v in ipairs(panes) do
            if v.pane_id == focused_pane_id then
              tab_id = v.tab_id
              break
            end
          end

          -- find pane for preview
          local preview_pane_id = -1
          for _, v in ipairs(panes) do
            if v.tab_id == tab_id and v.pane_id ~= focused_pane_id then
              preview_pane_id = v.pane_id
              break
            end
          end

          -- create preview pane if we don't have one
          if preview_pane_id == -1 then
            local splitPaneResult = vim.system({'wezterm', 'cli', 'split-pane', '--right'}, { text = true}):wait()
            preview_pane_id = splitPaneResult.stdout

            os.execute('wezterm cli activate-pane --pane-id ' .. focused_pane_id)
          end

          if full_path:match('.png$') then
            local command = 'wezterm cli send-text --no-paste --pane-id ' .. preview_pane_id .. ' "viu ' .. full_path .. '\r\n"'
            os.execute(command)
          elseif full_path:match('.svg$') then
            local command = 'wezterm cli send-text --no-paste --pane-id ' .. preview_pane_id .. ' "gm convert ' .. full_path .. ' PNG:- | viu -\r\n"'
            os.execute(command)
          end
        end
      end)
    end)
  end,
})

