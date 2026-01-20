local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

vim.g.mapleader = ' ' -- we need to setup this before plugins

function vim.getVisualSelection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})

  text = string.gsub(text, '\n', '')
  if #text > 0 then
    return text
  else
    return ''
  end
end

require('opts')

local function on_list(options)
  vim.fn.setqflist({}, ' ', options)
  vim.api.nvim_command('cfirst')
end

require('lazy').setup({
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme rose-pine]])
    end,
    keys = {
      { '<leader>l', ':Lazy<cr>', silent = true, desc = 'Lazy' },
    },
  },

  -- Generic plugins
  'nvim-tree/nvim-web-devicons',
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      local wk = require('which-key')
      wk.setup({
        delay = function(ctx)
          return ctx.plugin and 0 or 500
        end,
      })
      wk.add({
        { '<leader>a', group = 'lsp' },
        { '<leader>w', group = 'window' },
        { '<leader>g', group = 'git' },
        { '<leader>u', group = 'ghlite' },
      })
    end,
    keys = {
      {
        '<leader>e',
        vim.diagnostic.open_float,
        silent = true,
        desc = 'Diagnostics float',
      },
      {
        '<leader>ak',
        function()
          vim.diagnostic.jump({ count = -1, float = true })
        end,
        silent = true,
        desc = 'Diagnostics prev',
      },
      {
        '<leader>ap',
        function()
          vim.diagnostic.jump({
            count = -1,
            float = true,
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        silent = true,
        desc = 'Diagnostics Error prev',
      },
      {
        '[e',
        function()
          vim.diagnostic.jump({
            count = -1,
            float = true,
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        silent = true,
        desc = 'Diagnostics Error prev',
      },
      {
        '<leader>aj',
        function()
          vim.diagnostic.jump({ count = 1, float = true })
        end,
        silent = true,
        desc = 'Diagnostics next',
      },
      {
        '<leader>an',
        function()
          vim.diagnostic.jump({
            count = 1,
            float = true,
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        silent = true,
        desc = 'Diagnostics Error next',
      },
      {
        ']e',
        function()
          vim.diagnostic.jump({
            count = 1,
            float = true,
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        silent = true,
        desc = 'Diagnostics Error next',
      },
      -- Grep
      {
        '<leader>G',
        function()
          local text = vim.fn.expand('<cword>')
          vim.fn.histadd(':', 'gr ' .. text)
          vim.cmd('silent gr ' .. text)
        end,
        silent = true,
        desc = 'Grep word',
      },
      -- Misc
      { '<leader>n', ':silent noh<cr>', silent = true, desc = 'noh' },
      { '<leader>q', ':qa<cr>', silent = true, desc = 'quit' },
      { '<leader>pp', ":let @+ = fnamemodify(expand('%'), ':.')<cr>", silent = true, desc = 'copy relative path' },
      { '<leader>pn', ":let @+ = expand('%:t')<cr>", silent = true, desc = 'copy file name' },
      { '<leader>pf', ":let @+ = expand('%:p')<cr>", silent = true, desc = 'copy full file name' },
      { '<leader>s', ':w<cr>', silent = true, desc = 'write' },
      { '<leader>t', ':ToggleCheckbox<cr>', silent = true, desc = 'write' },
      -- window commands
      { '<leader>ww', '<c-w>w', silent = true, desc = 'window switch' },
      { '<leader>wc', '<c-w>c', silent = true, desc = 'window close' },
      { '<leader>wo', '<c-w>o', silent = true, desc = 'window close other' },
      { '<leader>wh', '<c-w>h', silent = true, desc = 'window k' },
      { '<leader>wj', '<c-w>j', silent = true, desc = 'window j' },
      { '<leader>wk', '<c-w>k', silent = true, desc = 'window k' },
      { '<leader>wl', '<c-w>l', silent = true, desc = 'window l' },
      {
        '<leader>wf',
        function()
          vim.g.lualine_hidden = not vim.g.lualine_hidden
          local new_cursor = 'a:hor1-Cursor/lCursor'
          if vim.o.guicursor ~= new_cursor then
            vim.g.old_cursor = vim.o.guicursor
          end

          require('lualine').hide({ unhide = not vim.g.lualine_hidden })

          if vim.g.lualine_hidden then
            vim.o.laststatus = 0
            vim.o.showtabline = 0
            vim.o.cmdheight = 0
            vim.o.signcolumn = 'no'
            vim.o.spell = false
            vim.opt.fillchars = { eob = ' ' }
            vim.o.guicursor = new_cursor

            vim.o.number = false
            vim.g.number_autocmd_id = vim.api.nvim_create_autocmd('BufEnter', {
              callback = function()
                vim.o.number = false
              end,
            })
          else
            vim.o.laststatus = 3
            vim.o.showtabline = 2
            vim.o.cmdheight = 1
            vim.o.signcolumn = 'yes'
            vim.o.spell = true
            vim.opt.fillchars = { eob = '~' }
            vim.o.guicursor = vim.g.old_cursor

            vim.o.number = true
            vim.api.nvim_del_autocmd(vim.g.number_autocmd_id)
          end
        end,
        silent = true,
        desc = 'toggle fullscreen',
      },

      -- LSP
      -- Mapping to c-] because LSP go to definition then works with c-t
      { '<leader>d', '<c-]>', silent = true, desc = 'definition' },
      {
        '<leader>ad',
        function()
          vim.lsp.buf.declaration({ on_list = on_list })
        end,
        silent = true,
        desc = 'declaration',
      },
      { '<leader>k', vim.lsp.buf.hover, silent = true, desc = 'hover' },
      {
        '<leader>at',
        function()
          vim.lsp.buf.type_definition({ on_list = on_list })
        end,
        silent = true,
        desc = 'type definition',
      },
      { '<leader>ar', vim.lsp.buf.rename, silent = true, desc = 'rename' },
      { '<leader>m', vim.lsp.buf.code_action, silent = true, desc = 'code actions' },
      {
        '<leader>m',
        vim.lsp.buf.code_action,
        mode = 'v',
        silent = true,
        desc = 'code actions',
      },
      {
        '<leader>/',
        function()
          vim.lsp.buf.references(nil, { on_list = on_list })
        end,
        silent = true,
        desc = 'references',
      },

      -- vimrc file
      { '<leader>v', ':e ~/.config/nvim/init.lua<cr>', silent = true, desc = 'load nvim init.lua' },
      { '<leader>V', ':source $MYVIMRC<cr>', silent = true, desc = 'source nvim init.lua' },

      { '<leader>x', ':GithubCopyUrl<cr>', silent = true, desc = 'Copy GitHub URL', mode = { 'n', 'v' } },
      { '<leader>gr', ':CodeDiff<cr>', silent = true, 'Review changes using CodeDiff' },
    },
  },
  {
    'daliusd/incr.nvim',
    -- dir = '~/projects/incr.nvim',
    config = true,
  },
  {
    'https://codeberg.org/andyg/leap.nvim',
    config = function()
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
      vim.keymap.set({ 'n' }, 'S', '<Plug>(leap-backward)')
    end,
  },
  {
    'j-hui/fidget.nvim',
    opts = {
      -- options
      notification = {
        override_vim_notify = true,
      },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto',
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = {
            {
              'filename',
              path = 3,
            },
          },
          lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              sections = { 'error', 'warn', 'info', 'hint' },
              symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
            },
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        tabline = {
          lualine_a = {
            {
              'tabs',
              max_length = vim.o.columns,
              mode = 2,
              tabs_color = { active = 'lualine_a_normal', inactive = 'lualine_c_normal' },
            },
          },
          lualine_z = { 'filesize' },
        },
      })
    end,
  },
  {
    'ibhagwan/fzf-lua',
    config = function()
      local fzf_lua = require('fzf-lua')
      fzf_lua.setup({
        winopts = { height = 0.95, width = 0.95, preview = { border = 'rounded', layout = 'vertical' } },
        files = {
          git_icons = false,
        },
        grep = {
          git_icons = false,
          actions = {
            ['ctrl-l'] = {
              function()
                local text = require('fzf-lua').get_last_query() .. ' -- *_en.json'
                require('fzf-lua').live_grep({ search = text, no_esc = true })
              end,
            },
            ['ctrl-g'] = {
              function()
                local text = require('fzf-lua').get_last_query() .. ' -- *.js *.jsx *.ts *.tsx'
                require('fzf-lua').live_grep({ search = text, no_esc = true })
              end,
            },
          },
        },
      })
      vim.cmd('FzfLua register_ui_select')
    end,
    lazy = false,
    keys = {
      { '<leader>h', ':FzfLua oldfiles<cr>', silent = true, desc = 'Old files' },
      { '<leader>f', ':FzfLua files<cr>', silent = true, desc = 'Files' },
      {
        '<leader>r',
        function()
          local text = vim.fn.expand('<cword>')
          vim.fn.histadd(':', 'Rg ' .. text)
          require('fzf-lua').live_grep({ search = text })
        end,
        silent = true,
        desc = 'Rg',
      },
      {
        '<leader>r',
        function()
          local text = vim.getVisualSelection()
          vim.fn.histadd(':', 'Rg ' .. text)
          require('fzf-lua').live_grep({ search = text })
        end,
        mode = 'v',
        silent = true,
        desc = 'Rg',
      },
      {
        '<leader>G',
        function()
          local text = vim.getVisualSelection()
          vim.fn.histadd(':', 'gr ' .. text)
          vim.cmd('silent gr ' .. text)
        end,
        mode = 'v',
        silent = true,
        desc = 'gr',
      },
      { '<leader>R', ':FzfLua live_grep<cr>', silent = true },
      {
        '<leader>f',
        function()
          local text = vim.getVisualSelection()
          require('fzf-lua').files({ query = text })
        end,
        mode = 'v',
        silent = true,
        desc = 'Files',
      },

      { '<leader>c', ':FzfLua commands<cr>', silent = true, desc = 'Commands' },
      {
        '<leader>c',
        ':FzfLua commands<cr>',
        silent = true,
        mode = 'v',
        desc = 'Commands',
      },
      { '<leader>z', ':FzfLua spell_suggest<cr>', silent = true, desc = 'Spell suggest' },
    },
  },
  {
    'stevearc/oil.nvim',
    opts = {
      default_file_explorer = true,
      columns = {
        'icon',
        'size',
      },
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ['gs'] = false,
        ['~'] = false,
      },
    },
    keys = {
      {
        '-',
        function()
          require('oil').open()
        end,
        desc = 'Open Parent directory',
        silent = true,
      },
    },
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'kylechui/nvim-surround',
    config = true,
  },
  {
    'numToStr/Comment.nvim',
    config = true,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            schemas = {
              ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
            },
          },
        },
      })
      vim.lsp.enable('yamlls', true)

      -- vim.lsp.enable('astro', true)
      vim.lsp.enable('buf_ls', true)
      vim.lsp.config('cssls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('cssls', true)
      vim.lsp.enable('cssmodules_ls', true)

      local base_on_attach = vim.lsp.config.eslint.on_attach
      vim.lsp.config('eslint', {
        root_dir = function(bufnr, on_dir)
          local util = require('lspconfig.util')
          local root = util.root_pattern('.eslintrc.js', '.eslintrc.json', '.eslintrc', 'package.json')(
            vim.api.nvim_buf_get_name(bufnr)
          )
          if root then
            on_dir(root)
          end
        end,
        settings = {
          workingDirectory = {
            mode = 'location',
          },
        },
        on_attach = function(client, bufnr)
          if not base_on_attach then
            return
          end

          base_on_attach(client, bufnr)
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            command = 'LspEslintFixAll',
          })
        end,
      })
      vim.lsp.enable('eslint', true)

      vim.lsp.config('html', {
        capabilities = capabilities,
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      })
      vim.lsp.enable('html', true)
      vim.lsp.config('jsonls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('jsonls', true)
      vim.lsp.enable('typos_lsp', true)
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
            hint = { enable = true },
          },
        },
      })
      vim.lsp.enable('lua_ls', true)
      vim.lsp.enable('tsgo', true)

      -- lang-lsp for translation hints
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        callback = function()
          vim.lsp.start({
            name = 'lang-lsp',
            cmd = { 'lang-lsp', '--stdio' },
            root_dir = vim.fs.root(0, { 'package.json', '.git' }),
          })
        end,
      })

      -- prettier-lsp for formatting (only if prettier config exists)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'json', 'html', 'css' },
        callback = function()
          local root_dir = vim.fs.root(0, {
            '.prettierrc.js',
            '.prettierrc.mjs',
            '.prettierrc.json',
          })

          -- Only start LSP if prettier config was found
          if root_dir then
            vim.lsp.start({
              name = 'prettier-lsp',
              cmd = { 'prettier-lsp', '--stdio' },
              root_dir = root_dir,
            })
          end
        end,
      })

      vim.lsp.enable('stylua')
      vim.lsp.enable('biome')

      -- Format on write
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if
            client ~= nil
            and (
              (
                client:supports_method('textDocument/formatting')
                and client.name ~= 'ts_ls'
                and client.name ~= 'lua_ls'
                and client.name ~= 'tsgo'
              ) or client.name == 'biome'
            )
          then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
              end,
            })
          end
        end,
      })
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },
  {
    'newtoallofthis123/blink-cmp-fuzzy-path',
    dependencies = { 'saghen/blink.cmp' },
    opts = {
      filetypes = { 'markdown', 'json' },
      trigger_char = '@',
      max_results = 5,
    },
  },
  {
    'saghen/blink.cmp',
    version = '*',
    dependencies = {
      'moyiz/blink-emoji.nvim',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {

      sources = {
        default = { 'fuzzy-path', 'lsp', 'path', 'snippets', 'buffer', 'emoji' },
        providers = {
          lsp = { fallbacks = {} },
          emoji = {
            module = 'blink-emoji',
            name = 'Emoji',
            score_offset = 15,
            opts = { insert = true },
          },
          ['fuzzy-path'] = {
            name = 'Fuzzy Path',
            module = 'blink-cmp-fuzzy-path',
            score_offset = 0,
          },
        },
      },

      keymap = {
        preset = 'none',
        ['<C-i>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'mono',
      },
      signature = { enabled = true },

      cmdline = {
        enabled = false,
      },

      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        documentation = {
          auto_show = true,
        },
      },
    },
    opts_extend = { 'sources.completion.enabled_providers' },
  },
  'jamessan/vim-gnupg',
  -- Git
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true })

          map('n', '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true })

          map('n', '<leader>ghh', gs.stage_hunk)
          map('n', '<leader>ghr', gs.reset_hunk)

          map('v', '<leader>ghh', function()
            gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)

          map('v', '<leader>ghr', function()
            gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)
        end,
      })
    end,
  },
  {
    'esmuellert/codediff.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    cmd = 'CodeDiff',
  },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gg', ':Git | only<cr>', silent = true, desc = 'Git' },
      { '<leader>gd', ':Gvdiffsplit<cr>', silent = true, desc = 'Git diff split' },
      { '<leader>gb', ':Git blame<cr>', silent = true, desc = 'Git blame' },
      { '<leader>gp', ':Git push<cr>', silent = true, desc = 'Git push' },
      { '<leader>gl', ':Git pull<cr>', silent = true, desc = 'Git pull' },
    },
  },

  -- Tree-sitter
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup({
        install_dir = vim.fn.stdpath('data') .. '/site',
      })

      local ensureInstalled = {
        'astro',
        'c',
        'cmake',
        'comment',
        'cpp',
        'css',
        'diff',
        'dockerfile',
        'fish',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gpg',
        'html',
        'http',
        'javascript',
        'jq',
        'json',
        'lua',
        'luadoc',
        'make',
        'markdown',
        'markdown_inline',
        'mermaid',
        'python',
        'regex',
        'rust',
        'sql',
        'svelte',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      }

      require('nvim-treesitter').install(ensureInstalled)

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '*' },
        callback = function()
          -- remove error = false when nvim 0.12+ is default
          if vim.treesitter.get_parser(nil, nil, { error = false }) then
            vim.treesitter.start()
          end
        end,
      })
    end,
  },
  {
    dir = '~/projects/ghlite.nvim',
    config = function()
      require('ghlite').setup({
        debug = false,
        view_split = '',
        diff_split = '',
        open_command = 'open',
        keymaps = {
          diff = {
            open_file_tab = 'gt',
          },
        },
      })
    end,
    keys = {
      { '<leader>us', ':GHLitePRSelect<cr>', silent = true, desc = 'PR Select' },
      { '<leader>uo', ':GHLitePRCheckout<cr>', silent = true, desc = 'PR Checkout' },
      { '<leader>uv', ':GHLitePRView<cr>', silent = true, desc = 'PR View' },
      { '<leader>uu', ':GHLitePRLoadComments<cr>', silent = true, desc = 'PR Load Comments' },
      { '<leader>up', ':GHLitePRDiff<cr>', silent = true, desc = 'PR Diff' },
      { '<leader>ul', ':GHLitePRDiffview<cr>', silent = true, desc = 'PR Diffview' },
      { '<leader>ua', ':GHLitePRAddComment<cr>', silent = true, desc = 'PR Add comment' },
      { '<leader>ua', ':GHLitePRAddComment<cr>', mode = 'x', silent = true, desc = 'PR Add comment' },
      { '<leader>uc', ':GHLitePRUpdateComment<cr>', silent = true, desc = 'PR Update comment' },
      { '<leader>ud', ':GHLitePRDeleteComment<cr>', silent = true, desc = 'PR Delete comment' },
      { '<leader>ug', ':GHLitePROpenComment<cr>', silent = true, desc = 'PR Open comment' },
    },
  },

  'tpope/vim-abolish',
  {
    'AlexBeauchemin/biome-lint.nvim',
    config = function()
      require('biome-lint').setup({
        severity = 'error', -- "error", "warn", "info". Default is "error"
      })
    end,
  },
})

require('misc')
require('highlights')
require('keymaps')
require('commands')
